import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../data/local/db/converters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;
import 'dart:async';
import '../logic/navigation_providers.dart';
import '../logic/deviation_engine.dart';
import '../logic/backtrack_engine.dart';
import 'package:drift/drift.dart' as drift;

import '../../../data/local/db/app_database.dart';
import '../../../../core/services/seeding_service.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/services/background_service.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;
import 'widgets/elevation_panel.dart';
import '../../../../core/utils/mbtiles_provider.dart';
import '../logic/eta_engine.dart';

// -----------------------------------------------------------------------------
// MAIN SCREEN
// -----------------------------------------------------------------------------

class OfflineMapScreen extends ConsumerStatefulWidget {
  const OfflineMapScreen({super.key});

  @override
  ConsumerState<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends ConsumerState<OfflineMapScreen> {
  final MapController _mapController = MapController();

  // Simulation State
  Timer? _simTimer;
  int _simIndex = 0;
  List<LatLng> _simPath = [];

  // Search State
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return;
    }

    // Permission Granted - Initialize Service
    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      await initializeBackgroundService();
    }

    // Seed Discovery Data
    await ref.read(seedingServiceProvider).seedDiscoveryData();
  }

  void _startSimulation({bool deviate = false}) {
    _simTimer?.cancel();
    _simIndex = 0;

    // Clear backtrack
    ref.read(backtrackPathProvider.notifier).state = null;
    ref.read(backtrackTargetProvider.notifier).state = null;

    // Create base path
    _simPath = [];
    if (!deviate) {
      // Safe Path
      for (int i = 0; i < 20; i++) {
        _simPath.add(LatLng(
          -7.4526 + (i * -0.0003),
          110.4422 + (i * 0.00025),
        ));
      }
    } else {
      // Deviation
      for (int i = 0; i < 30; i++) {
        double lngDrift = (i > 8) ? -0.0005 * (i - 8) : 0.00025 * i;
        _simPath.add(LatLng(
          -7.4526 + (i * -0.0003),
          110.4422 + lngDrift,
        ));
      }
    }

    _simTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (_simIndex >= _simPath.length) {
        timer.cancel();
        return;
      }
      final pt = _simPath[_simIndex];
      _simIndex++;

      // Mock Location Update
      final db = ref.read(databaseProvider);
      db.trackingDao.insertBreadcrumb(
        UserBreadcrumbsCompanion(
          sessionId: const drift.Value('sim_session'),
          lat: drift.Value(pt.latitude),
          lng: drift.Value(pt.longitude),
          altitude: const drift.Value(2000),
          accuracy: const drift.Value(5.0),
          timestamp: drift.Value(DateTime.now()),
        ),
      );

      _processNavigationLogic(pt);
      _mapController.move(pt, 16);
    });
  }

  Future<void> _processNavigationLogic(LatLng pos) async {
    final activeId = ref.read(activeMountainIdProvider);
    final trails = await ref.read(activeTrailsProvider(activeId).future);
    final dist = DeviationEngine.calculateMinDistance(pos, trails);
    final monitor = ref.read(deviationMonitorProvider);
    monitor.addReading(dist);
    ref.read(safetyStatusProvider.notifier).state = monitor.currentStatus;

    // We do NOT overwrite backtrackPathProvider here anymore.
    // The path is static (Ghost Trail) calculated by _activateBacktrack.
    /*
    final backTarget = ref.read(backtrackTargetProvider);
    if (backTarget != null) {
      ref.read(backtrackPathProvider.notifier).state = [pos, backTarget];
    }
    */
  }

  Future<void> _activateBacktrack() async {
    final db = ref.read(databaseProvider);
    final engine = BacktrackEngine(db);
    final activeId = ref.read(activeMountainIdProvider);
    final trails = await ref.read(activeTrailsProvider(activeId).future);

    // Use the simulator session for demo, or 'current_session' in real app
    final path = await engine.getSafeRetracePath('sim_session', trails);

    if (path != null && path.isNotEmpty) {
      ref.read(backtrackTargetProvider.notifier).state = path.last;
      ref.read(backtrackPathProvider.notifier).state = path;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Backtrack Path Found! Retrace your steps."),
          backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No Safe Path found in history!"),
          backgroundColor: Colors.red));
    }
  }

  Future<void> _downloadRegion(String id) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Downloading Map Data...")));

    final seeder = ref.read(seedingServiceProvider);
    try {
      switch (id) {
        case 'merbabu':
          await seeder.seedMerbabu();
          break;
        case 'rinjani':
          await seeder.seedRinjani();
          break;
        case 'semeru':
          await seeder.seedSemeru();
          break;
        case 'kerinci':
          await seeder.seedKerinci();
          break;
        case 'slamet':
          await seeder.seedSlamet();
          break;
        case 'sumbing':
          await seeder.seedSumbing();
          break;
        case 'arjuno':
          await seeder.seedArjuno();
          break;
        case 'raung':
          await seeder.seedRaung();
          break;
        case 'lawu':
          await seeder.seedLawu();
          break;
        case 'welirang':
          await seeder.seedWelirang();
          break;
        case 'sindoro':
          await seeder.seedSindoro();
          break;
        case 'argopuro':
          await seeder.seedArgopuro();
          break;
        case 'ciremai':
          await seeder.seedCiremai();
          break;
        case 'pangrango':
          await seeder.seedPangrango();
          break;
        case 'gede':
          await seeder.seedGede();
          break;
        case 'butak':
          await seeder.seedButak();
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Download Complete!"),
            backgroundColor: Colors.green));
        ref.refresh(allMountainsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Download Failed: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userLocAsync = ref.watch(userLocationProvider);
    final safetyStatus = ref.watch(safetyStatusProvider);
    final activeMountainId = ref.watch(activeMountainIdProvider);
    final trailsAsync = ref.watch(activeTrailsProvider(activeMountainId));
    final backtrackPath = ref.watch(backtrackPathProvider);
    final backtrackTarget = ref.watch(backtrackTargetProvider);
    final allMountainsAsync = ref.watch(allMountainsProvider);
    final mapStyle = ref.watch(mapStyleProvider);
    final dangerZones = ref.watch(dangerZonesProvider);

    // Dynamic Tile URL
    // Dynamic Tile URL
    String tileUrl;
    List<String> subdomains;

    switch (mapStyle) {
      case MapLayerType.cyclOsm:
        tileUrl =
            'https://{s}.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png';
        subdomains = ['a', 'b', 'c'];
        break;
      case MapLayerType.openTopo:
        tileUrl = 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png';
        subdomains = ['a', 'b', 'c'];
        break;
      case MapLayerType.satellite:
        tileUrl =
            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
        subdomains = [];
        break;
      case MapLayerType.googleHybrid:
        tileUrl = 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}';
        subdomains = [];
        break;
      case MapLayerType.osm:
      default:
        tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
        subdomains = ['a', 'b', 'c'];
    }

    // Heading Calculation
    double compassHeading = 0;
    if (backtrackTarget != null && userLocAsync.value != null) {
      const Distance distance = Distance();
      final userPt = LatLng(userLocAsync.value!.lat, userLocAsync.value!.lng);
      compassHeading = distance.bearing(userPt, backtrackTarget);
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF050505),
      endDrawer: _buildDevDrawer(),
      body: Stack(
        children: [
          // 1. MAP LAYER
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(-7.453, 110.445), // Default to Merbabu
              initialZoom: 13.0,
              minZoom: 10.0,
              maxZoom: 18.0,
            ),
            children: [
              // 1. Base Map Layer (Raster OR Vector)
              if (mapStyle == MapLayerType.vector)
                FutureBuilder<String?>(
                  future: ref
                      .read(mapPackageManagerProvider)
                      .getVectorFilePath(activeMountainId),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return VectorTileLayer(
                        theme: _getMapTheme(context),
                        tileProviders: TileProviders(
                          {
                            'openmaptiles':
                                MbTilesVectorTileProvider(path: snapshot.data!)
                          },
                        ),
                      );
                    }
                    return const Center(
                        child: Text(
                            "Vector Data Not Found\nPlease download package",
                            style: TextStyle(
                                backgroundColor: Colors.white,
                                color: Colors.red)));
                  },
                )
              else
                TileLayer(
                  urlTemplate: tileUrl,
                  subdomains: subdomains,
                  userAgentPackageName: 'com.pandu.navigation',
                ),

              // 2. Danger Zones
              PolygonLayer(
                polygons: dangerZones
                    .map((zone) => Polygon(
                        points: zone,
                        color: Colors.red.withOpacity(0.3),
                        borderColor: Colors.red,
                        borderStrokeWidth: 2.0,
                        isFilled: true,
                        label: "DANGER ZONE",
                        labelStyle: const TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold)))
                    .toList(),
              ),

              // Trails
              trailsAsync.when(
                data: (trails) => PolylineLayer(
                  polylines: trails
                      .map((t) => Polyline(
                            points: t.geometryJson,
                            strokeWidth: 4.0,
                            color: const Color(0xFF0df259), // PANDU Green
                          ))
                      .toList(),
                ),
                error: (e, s) => const SizedBox(),
                loading: () => const SizedBox(),
              ),

              // POIs
              ref.watch(activePoisProvider(activeMountainId)).when(
                    data: (pois) => MarkerLayer(
                      markers: pois.map((poi) => _buildPoiMarker(poi)).toList(),
                    ),
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),

              // Discovery Markers (All Mountains)
              allMountainsAsync.when(
                data: (regions) => MarkerLayer(
                  markers: regions
                      .where((r) => r.lat != 0)
                      .map((r) => _buildRegionMarker(r))
                      .toList(),
                ),
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),

              // Backtrack Line
              if (backtrackPath != null)
                PolylineLayer(polylines: [
                  Polyline(
                    points: backtrackPath,
                    strokeWidth: 4.0,
                    color: const Color(0xFFff3b30), // Danger Red
                    isDotted: true,
                  )
                ]),

              // Backtrack Target
              if (backtrackTarget != null)
                MarkerLayer(markers: [
                  Marker(
                    point: backtrackTarget,
                    child: const Icon(Icons.safety_check,
                        color: Color(0xFF0df259), size: 30),
                  )
                ]),

              // User Location
              MarkerLayer(markers: [
                if (userLocAsync.value != null)
                  Marker(
                    point: LatLng(
                        userLocAsync.value!.lat, userLocAsync.value!.lng),
                    width: 60,
                    height: 60,
                    child: _CompassBearing(
                      heading: compassHeading,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 2)
                          ],
                        ),
                      ),
                    ),
                  )
              ]),
            ],
          ),

          // 2. SEARCH BAR (Top)
          // 2. SEARCH BAR OR OVERLAY
          if (_isSearching)
            Positioned.fill(
              child: _SearchOverlay(
                onClose: () => setState(() => _isSearching = false),
                onSelect: (region) {
                  setState(() => _isSearching = false);
                  ref.read(activeMountainIdProvider.notifier).state = region.id;
                  _mapController.move(LatLng(region.lat, region.lng), 14);
                  if (!region.isDownloaded) {
                    _downloadRegion(region.id);
                  }
                },
              ),
            )
          else
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: GestureDetector(
                onTap: () => setState(() => _isSearching = true),
                child: const _MapSearchBar(enabled: false),
              ),
            ),

          // 3. HUD (Below Search Bar)

          // 4. OFF TRAIL WARNING (Floating)
          if (safetyStatus == SafetyStatus.danger)
            Positioned(
              top: MediaQuery.of(context).padding.top + 140,
              left: 0,
              right: 0,
              child: const Center(child: _OffTrailWarningBadge()),
            ),

          // 5. SIDE CONTROLS (Right)
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.35,
            child: _MapSideControls(
              onZoomIn: () {
                final curr = _mapController.camera.zoom;
                _mapController.move(_mapController.camera.center, curr + 1);
              },
              onZoomOut: () {
                final curr = _mapController.camera.zoom;
                _mapController.move(_mapController.camera.center, curr - 1);
              },
              onCenter: () {
                final loc = ref.read(userLocationProvider).value;
                if (loc != null) {
                  _mapController.move(LatLng(loc.lat, loc.lng), 16);
                }
              },
              onLayer: () {
                showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => const _MapStyleSelector());
              },
            ),
          ),

          // 5.5 Elevation Panel (Bottom Sheet style, above nav sheet)

          // 6. BOTTOM SHEET (Navigation & Survival)
          _NavigationSheet(
            status: safetyStatus,
            userLoc: userLocAsync.value,
            heading: compassHeading,
            trail: (trailsAsync.value != null && trailsAsync.value!.isNotEmpty)
                ? trailsAsync.value!.first
                : null,
            onBacktrack: _activateBacktrack,
            onSimulateMenu: () => Scaffold.of(context).openEndDrawer(),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildDevDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF141414),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Text('DEV TOOLS',
                style: TextStyle(
                    color: Color(0xFF0df259),
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow, color: Color(0xFF0df259)),
            title: const Text('Simulate Safe Walk',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _startSimulation(deviate: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning, color: Color(0xFFff3b30)),
            title: const Text('Simulate Deviation',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _startSimulation(deviate: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.stop, color: Colors.grey),
            title: const Text('Stop Simulation',
                style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pop(context);
              _simTimer?.cancel();
            },
          ),
        ],
      ),
    );
  }

  Marker _buildPoiMarker(dynamic poi) {
    IconData icon = Icons.place;
    Color color = Colors.white;
    switch (poi.type) {
      case PoiType.water:
        icon = Icons.water_drop;
        color = Colors.blueAccent;
        break;
      case PoiType.summit:
        icon = Icons.flag;
        color = Colors.orangeAccent;
        break;
      case PoiType.shelter:
        icon = Icons.home_filled;
        color = Colors.yellowAccent;
        break;
      case PoiType.basecamp:
        icon = Icons.holiday_village;
        color = const Color(0xFF0df259);
        break;
      case PoiType.dangerZone:
        icon = Icons.warning;
        color = const Color(0xFFff3b30);
        break;
      default:
        break;
    }
    return Marker(
      point: LatLng(poi.lat, poi.lng),
      width: 40,
      height: 40,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 2),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Marker _buildRegionMarker(dynamic region) {
    final isMerapi = region.id == 'merapi';
    return Marker(
      point: LatLng(region.lat, region.lng),
      width: 70,
      height: 70,
      child: GestureDetector(
        onTap: () {
          if (isMerapi) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('DANGER ZONE: Mount Merapi is closed!'),
                backgroundColor: Colors.red));
            return;
          }
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (ctx) => _RegionPreviewSheet(
                  region: region,
                  onAction: (LatLng? target) {
                    Navigator.pop(context);
                    // Update Active Region so trails/POIs load
                    ref.read(activeMountainIdProvider.notifier).state =
                        region.id;

                    // If not downloaded, trigger download
                    if (!region.isDownloaded) {
                      _downloadRegion(region.id);
                    }

                    // Move to specific target (basecamp) or region center (default)
                    final dest = target ?? LatLng(region.lat, region.lng);
                    _mapController.move(dest, 15);
                  }));
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isMerapi
                    ? const Color(0xFFff3b30)
                    : const Color(0xFF0df259).withOpacity(0.8),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(isMerapi ? Icons.warning_amber : Icons.terrain,
                  color: Colors.white, size: 24),
            ),
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4)),
              child: Text(region.name.replaceAll('Mount ', ''),
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPER: Vector Map Theme (Dark / Hiking)
  // ---------------------------------------------------------------------------
  vtr.Theme _getMapTheme(BuildContext context) {
    // Minimal style for offline usage
    return vtr.ThemeReader().read({
      "version": 8,
      "name": "Dark",
      "layers": [
        {
          "id": "background",
          "type": "background",
          "paint": {"background-color": "#121212"}
        },
        {
          "id": "water",
          "type": "fill",
          "source": "openmaptiles",
          "source-layer": "water",
          "paint": {"fill-color": "#1f2937"}
        }
      ]
    });
  }

  // ---------------------------------------------------------------------------
  // HELPER: Build Elevation Panel
  // ---------------------------------------------------------------------------
  Widget _buildElevationPanel(
      BuildContext context, UserBreadcrumb? userLoc, Trail trail) {
    if (userLoc == null) return const SizedBox.shrink();

    final points = trail.geometryJson;
    // Mock Altitude Profile (Sine Wave + Uphill Trend)
    // In production, Z values should come from trail.geometryJson or a DEM service
    final altitudes = List<double>.generate(
        points.length, (i) => 1500.0 + (math.sin(i / 10) * 500) + (i * 2));

    // Calculate Progress
    int closestIndex = 0;
    double minD = double.infinity;
    final u = LatLng(userLoc.lat, userLoc.lng);

    for (int i = 0; i < points.length; i++) {
      final d = const Distance().as(LengthUnit.Meter, u, points[i]);
      if (d < minD) {
        minD = d;
        closestIndex = i;
      }
    }

    final progress = closestIndex / points.length;
    final endPt = points.last;
    final endAlt = altitudes.last;
    final uAlt = userLoc.altitude ?? altitudes[closestIndex];
    // Use our new EtaEngine
    final eta = EtaEngine.calculateEta(u, uAlt, endPt, endAlt);

    return ElevationPanel(
      trailPoints: points,
      altitudes: altitudes,
      currentProgress: progress,
      etaToNextPos: eta,
      nextPosName: "Summit",
    );
  }
}

// -----------------------------------------------------------------------------
// UI WIDGETS (STITCH DESIGN)
// -----------------------------------------------------------------------------

class _CockpitHud extends StatelessWidget {
  final double altitude;
  final double accuracy;
  final double bearing;
  final SafetyStatus status;

  const _CockpitHud({
    required this.altitude,
    required this.accuracy,
    required this.bearing,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _GlassPill(
              icon: Icons.landscape,
              label: 'ALT',
              value: altitude.toStringAsFixed(0),
              unit: 'm'),
          _GlassPill(
              icon: Icons.explore,
              label: 'HEAD',
              value: bearing.toStringAsFixed(0),
              unit: '° NW',
              isCenter: true),
          _GlassPill(
              icon: Icons.my_location,
              label: 'GPS',
              value: '±${accuracy.toStringAsFixed(0)}',
              unit: 'm'),
        ],
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool isCenter;

  const _GlassPill(
      {required this.icon,
      required this.label,
      required this.value,
      required this.unit,
      this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: isCenter ? 24 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414).withOpacity(0.6),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF0df259), size: 20),
              const SizedBox(width: 8),
              if (!isCenter)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: value,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: unit,
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 10))
                    ]))
                  ],
                )
              else
                Text('$value$unit',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _OffTrailWarningBadge extends StatelessWidget {
  const _OffTrailWarningBadge();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFff3b30).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFff3b30).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFff3b30).withOpacity(0.4),
                  blurRadius: 20)
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('OFF TRAIL DETECTED',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapSideControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onCenter;
  final VoidCallback onLayer;

  const _MapSideControls(
      {required this.onZoomIn,
      required this.onZoomOut,
      required this.onCenter,
      required this.onLayer});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GlassIconBtn(icon: Icons.add, onTap: onZoomIn),
        const SizedBox(height: 12),
        _GlassIconBtn(icon: Icons.remove, onTap: onZoomOut),
        const SizedBox(height: 12),
        _GlassIconBtn(icon: Icons.near_me, onTap: onCenter, isPrimary: true),
        const SizedBox(height: 12),
        _GlassIconBtn(icon: Icons.layers, onTap: onLayer),
      ],
    );
  }
}

class _GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _GlassIconBtn(
      {required this.icon, required this.onTap, this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF141414).withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isPrimary
                      ? const Color(0xFF0df259).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon,
                color: isPrimary ? const Color(0xFF0df259) : Colors.white,
                size: 24),
          ),
        ),
      ),
    );
  }
}

class _NavigationSheet extends StatefulWidget {
  final SafetyStatus status;
  final UserBreadcrumb? userLoc;
  final double heading;
  final Trail? trail;
  final VoidCallback onBacktrack;
  final VoidCallback onSimulateMenu;

  const _NavigationSheet({
    required this.status,
    required this.userLoc,
    required this.heading,
    this.trail,
    required this.onBacktrack,
    required this.onSimulateMenu,
  });

  @override
  State<_NavigationSheet> createState() => _NavigationSheetState();
}

class _NavigationSheetState extends State<_NavigationSheet> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // Start at Main Dashboard
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.40,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121212).withOpacity(0.95),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2))),

                  // Pager
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      children: [
                        _buildCompassPage(),
                        _buildDashboardPage(scrollController),
                        _buildSurvivalPage(scrollController),
                      ],
                    ),
                  ),

                  // Indicators
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        // Simple indicator logic if we had state listening,
                        // but for now simple dots or just skip
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2)),
                        );
                      }),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // PAGE 0: Compass & Altitude
  Widget _buildCompassPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: (widget.heading * (math.pi / 180) * -1),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0df259), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF0df259).withOpacity(0.2),
                        blurRadius: 20)
                  ]),
              child: Stack(
                children: [
                  const Center(
                      child: Icon(Icons.navigation,
                          size: 60, color: Colors.white)),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(width: 4, height: 20, color: Colors.red),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("${widget.heading.toStringAsFixed(0)}°",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("ALT: ${widget.userLoc?.altitude?.toStringAsFixed(0) ?? '--'}m",
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // PAGE 1: Main Dashboard
  Widget _buildDashboardPage(ScrollController controller) {
    // Calculate Elevation Data
    Widget elevationGraph = const Center(
        child: Text("No Active Trail", style: TextStyle(color: Colors.grey)));
    Duration? eta;

    if (widget.trail != null && widget.userLoc != null) {
      final points = widget.trail!.geometryJson;
      final altitudes = List<double>.generate(
          points.length, (i) => 1500.0 + (math.sin(i / 10) * 500) + (i * 2));

      int closestIndex = 0;
      double minD = double.infinity;
      final u = LatLng(widget.userLoc!.lat, widget.userLoc!.lng);

      for (int i = 0; i < points.length; i++) {
        final d = const Distance().as(LengthUnit.Meter, u, points[i]);
        if (d < minD) {
          minD = d;
          closestIndex = i;
        }
      }

      final progress = closestIndex / points.length;
      final endPt = points.last;
      final endAlt = altitudes.last;
      final uAlt = widget.userLoc!.altitude ?? altitudes[closestIndex];
      eta = EtaEngine.calculateEta(u, uAlt, endPt, endAlt);

      elevationGraph = ElevationPanel(
        trailPoints: points,
        altitudes: altitudes,
        currentProgress: progress,
        etaToNextPos: eta,
        nextPosName: "Summit",
      );
    }

    return SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                    child: _StatCard(
                        label: "ALTITUDE",
                        value:
                            "${widget.userLoc?.altitude?.toStringAsFixed(0) ?? '-'}m",
                        isHighlight: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatCard(
                        label: "ETA",
                        value: eta != null
                            ? EtaEngine.formatDuration(eta)
                            : "--")),
                const SizedBox(width: 12),
                const Expanded(
                    child: _StatCard(label: "SUNSET", value: "18:42")),
              ],
            ),
            const SizedBox(height: 24),

            // Elevation Graph
            SizedBox(height: 180, child: elevationGraph),
            const SizedBox(height: 24),

            // Button
            GestureDetector(
              onTap: widget.status == SafetyStatus.danger
                  ? widget.onBacktrack
                  : null,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                    color: widget.status == SafetyStatus.danger
                        ? const Color(0xFFff3b30)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (widget.status == SafetyStatus.danger)
                        BoxShadow(
                            color: const Color(0xFFff3b30).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4))
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        widget.status == SafetyStatus.danger
                            ? Icons.u_turn_left
                            : Icons.check,
                        color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                        widget.status == SafetyStatus.danger
                            ? "INITIATE BACKTRACK"
                            : "SYSTEM OPTIMAL",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2))
                  ],
                ),
              ),
            ),

            TextButton(
                onPressed: widget.onSimulateMenu,
                child: Text("DEV TOOLS",
                    style: TextStyle(
                        color: Colors.grey.withOpacity(0.5), fontSize: 10)))
          ],
        ),
      ),
    );
  }

  // PAGE 2: Survival
  Widget _buildSurvivalPage(ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SURVIVAL GUIDE",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            SizedBox(height: 16),
            _SurvivalCard(
                icon: Icons.water_drop,
                color: Colors.blue,
                label: "Find Water"),
            SizedBox(height: 12),
            _SurvivalCard(
                icon: Icons.roofing,
                color: Colors.amber,
                label: "Build Shelter"),
            SizedBox(height: 12),
            _SurvivalCard(
                icon: Icons.local_fire_department,
                color: Colors.red,
                label: "Start Fire"),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isHighlight;

  const _StatCard(
      {required this.label, required this.value, this.isHighlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: isHighlight ? const Color(0xFF0df259) : Colors.white,
                  fontSize: 18,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SurvivalCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _SurvivalCard(
      {required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        String message = "Advice: Stay calm.";
        if (label == "Find Water") {
          message = "Look for valleys, animal tracks, or morning dew.";
        }
        if (label == "Build Shelter") {
          message = "Find a wind-blocked area, insulate from ground.";
        }
        if (label == "Start Fire") {
          message = "Gather dry tinder, shield from wind, use sparks.";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _MapSearchBar extends StatelessWidget {
  final Function(String)? onSearch;
  final bool enabled;

  const _MapSearchBar({this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414).withOpacity(0.8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey),
              const SizedBox(width: 8),
              Expanded(
                child: enabled
                    ? TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Search mountain...",
                          hintStyle: TextStyle(color: Colors.grey),
                          border: InputBorder.none,
                        ),
                        onSubmitted: onSearch,
                      )
                    : const Text("Search mountain...",
                        style: TextStyle(color: Colors.grey)),
              ),
              if (!enabled)
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Text("Tap to Search",
                        style: TextStyle(
                            color: Colors.white30,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)))
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SEARCH OVERLAY (Stitch Design)
// -----------------------------------------------------------------------------
class _SearchOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  final Function(dynamic) onSelect;

  const _SearchOverlay({required this.onClose, required this.onSelect});

  @override
  ConsumerState<_SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<_SearchOverlay> {
  final TextEditingController _ctrl = TextEditingController();
  String _query = "";

  @override
  Widget build(BuildContext context) {
    // 1. Fetch Data
    final allMountains = ref.watch(allMountainsProvider).valueOrNull ?? [];

    // 2. Filter
    final results = _query.isEmpty
        ? allMountains
        : allMountains
            .where((m) => m.name.toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        color: const Color(0xFF050505).withOpacity(0.95),
        child: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                            color: const Color(0xFF141414).withOpacity(1.0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    const Color(0xFF0df259).withOpacity(0.4)),
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      const Color(0xFF0df259).withOpacity(0.15),
                                  blurRadius: 15)
                            ]),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFF0df259)),
                            const SizedBox(width: 12),
                            Expanded(
                                child: TextField(
                              controller: _ctrl,
                              autofocus: true,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Search active peaks...",
                                  hintStyle: TextStyle(color: Colors.white30)),
                              onChanged: (val) => setState(() => _query = val),
                            )),
                            if (_query.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  _ctrl.clear();
                                  setState(() => _query = "");
                                },
                                child: const Icon(Icons.cancel,
                                    color: Colors.white30, size: 20),
                              )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                        onPressed: widget.onClose,
                        child: const Text("Cancel",
                            style: TextStyle(
                                color: Color(0xFF0df259),
                                fontWeight: FontWeight.bold)))
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SECTION TITLE
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text("SEARCH RESULTS (${results.length})",
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2)),
              ),

              // RESULTS LIST
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: results.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final region = results[index];
// -----------------------------------------------------------------------------
// UI COMPONENTS
// -----------------------------------------------------------------------------
                    return GestureDetector(
                      onTap: () => widget.onSelect(region),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: const Color(0xFF141414).withOpacity(0.6),
                            borderRadius: BorderRadius.circular(16),
                            border: Border(
                              left: const BorderSide(
                                  color: Color(0xFF0df259), width: 4),
                              top: BorderSide(
                                  color: Colors.white.withOpacity(0.05)),
                              bottom: BorderSide(
                                  color: Colors.white.withOpacity(0.05)),
                              right: BorderSide(
                                  color: Colors.white.withOpacity(0.05)),
                            )),
                        child: Row(
                          children: [
                            // ICON
                            Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black,
                              ),
                              child: const Icon(Icons.filter_hdr,
                                  color: Color(0xFF0df259), size: 20),
                            ),
                            const SizedBox(width: 16),
                            // TEXT
                            Expanded(
                                child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(region.name,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    _Tag(text: region.id.toUpperCase()),
                                    const SizedBox(width: 8),
                                    if (region.isDownloaded)
                                      const _Tag(
                                          text: "OFFLINE",
                                          color: Color(0xFF0df259)),
                                  ],
                                )
                              ],
                            )),
                            // ARROW
                            const Icon(Icons.chevron_right,
                                color: Colors.white24)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // FOOTER
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.offline_pin,
                        color: Colors.white24, size: 16),
                    const SizedBox(width: 8),
                    Text("AVAILABLE OFFLINE",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5))
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  const _Tag({required this.text, this.color = const Color(0xFFFFFFFF)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Text(text,
          style: TextStyle(
              color: color.withOpacity(0.7),
              fontSize: 9,
              fontWeight: FontWeight.bold)),
    );
  }
}

// -----------------------------------------------------------------------------
// REGION PREVIEW SHEET (UPDATED: Basecamp Selection)
// -----------------------------------------------------------------------------
class _RegionPreviewSheet extends ConsumerWidget {
  final dynamic region; // MountainRegion
  final Function(LatLng?) onAction;

  const _RegionPreviewSheet({required this.region, required this.onAction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Fetch POIs for this region (to find Basecamps)
    final poisAsync = ref.watch(activePoisProvider(region.id));

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 600, // Fixed height for list
          decoration: BoxDecoration(
            color: const Color(0xFF121212).withOpacity(0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border:
                Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HANDLE
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // HEADER IMAGE
              Expanded(
                flex: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/mountains/${region.id}.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => Container(
                          color: Colors.grey[900],
                          child: const Center(
                              child: Icon(Icons.terrain,
                                  size: 64, color: Colors.white10))),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                            Colors.transparent,
                            const Color(0xFF121212).withOpacity(0.95)
                          ])),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(region.name.toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5)),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Color(0xFF0df259), size: 14),
                              const SizedBox(width: 4),
                              Text("CENTRAL JAVA, INDONESIA",
                                  style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 10,
                                      letterSpacing: 1.2))
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),

              // BASECAMPS LIST
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("SELECT BASECAMP",
                          style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                      const SizedBox(height: 16),
                      Expanded(
                        child: poisAsync.when(
                            loading: () => const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF0df259))),
                            error: (e, s) => Center(
                                child: Text("Failed to load basecamps: $e",
                                    style: const TextStyle(
                                        color: Colors.white30))),
                            data: (pois) {
                              // Filter for Basecamps (Type 0)
                              final basecamps =
                                  pois.where((p) => p.type == 0).toList();

                              if (basecamps.isEmpty) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.warning_amber,
                                        color: Colors.white30, size: 48),
                                    const SizedBox(height: 8),
                                    const Text("No Basecamps Found",
                                        style:
                                            TextStyle(color: Colors.white30)),
                                    const SizedBox(height: 24),
                                    // Fallback generic enter
                                    GestureDetector(
                                      onTap: () =>
                                          onAction(null), // Default move
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF0df259),
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: const Text("ENTER MAP ANYWAY",
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    )
                                  ],
                                );
                              }

                              return ListView.separated(
                                itemCount: basecamps.length,
                                separatorBuilder: (c, i) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  final bc = basecamps[index];
                                  return GestureDetector(
                                    onTap: () {
                                      // Move specific to basecamp
                                      onAction(LatLng(bc.lat, bc.lng));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                              color: Colors.white
                                                  .withOpacity(0.1))),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                color: const Color(0xFF0df259)
                                                    .withOpacity(0.1),
                                                shape: BoxShape.circle),
                                            child: const Icon(Icons.home_work,
                                                color: Color(0xFF0df259),
                                                size: 20),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(bc.name,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14)),
                                                const SizedBox(height: 4),
                                                Text(
                                                    "Elevation: ${bc.elevation}m",
                                                    style: TextStyle(
                                                        color: Colors.grey[500],
                                                        fontSize: 12))
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.arrow_forward_ios,
                                              color: Colors.white24, size: 14)
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapStyleSelector extends ConsumerWidget {
  const _MapStyleSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStyle = ref.watch(mapStyleProvider);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("SELECT MAP LAYER",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildOption(ref, MapLayerType.osm, "OSM", Icons.public,
                  currentStyle == MapLayerType.osm),
              const SizedBox(width: 16),
              _buildOption(ref, MapLayerType.cyclOsm, "CYCL",
                  Icons.directions_bike, currentStyle == MapLayerType.cyclOsm),
              const SizedBox(width: 16),
              _buildOption(ref, MapLayerType.openTopo, "TOPO", Icons.terrain,
                  currentStyle == MapLayerType.openTopo),
              const SizedBox(width: 16),
              _buildOption(ref, MapLayerType.vector, "VECT", Icons.map,
                  currentStyle == MapLayerType.vector),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildOption(WidgetRef ref, MapLayerType type, String label,
      IconData icon, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => ref.read(mapStyleProvider.notifier).state = type,
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF0df259).withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFF0df259)
                    : Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? const Color(0xFF0df259) : Colors.white,
                  size: 28),
              const SizedBox(height: 8),
              Text(label,
                  style: TextStyle(
                      color:
                          isSelected ? const Color(0xFF0df259) : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassBearing extends StatelessWidget {
  final double heading;
  final Widget child;
  const _CompassBearing({required this.heading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: (heading * (math.pi / 180)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_drop_up, color: Color(0xFFff3b30), size: 24),
          child,
        ],
      ),
    );
  }
}
