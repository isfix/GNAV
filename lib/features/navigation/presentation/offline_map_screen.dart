import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:vector_map_tiles/vector_map_tiles.dart';
import 'package:vector_tile_renderer/vector_tile_renderer.dart' as vtr;

// INTERNAL IMPORTS
import '../../../data/local/db/converters.dart'; // For PoiType if needed
import '../../../data/local/db/app_database.dart';
import '../../../../core/services/seeding_service.dart';
import '../../../../core/services/background_service.dart';
import '../../../../core/utils/mbtiles_provider.dart';
import '../logic/navigation_providers.dart';
import '../logic/gps_state_machine.dart';
import '../logic/haptic_compass_controller.dart';
import '../logic/map_package_manager.dart';
import '../logic/deviation_engine.dart';
import '../logic/backtrack_engine.dart';

// WIDGET IMPORTS (REFACTORED)
import 'widgets/atoms/off_trail_warning_badge.dart';
import 'widgets/atoms/compass_bearing.dart';
import 'widgets/controls/map_search_bar.dart';
import 'widgets/controls/map_side_controls.dart';
import 'widgets/controls/map_style_selector.dart';
import 'widgets/sheets/navigation_sheet.dart';
import 'widgets/sheets/search_overlay.dart';
import 'widgets/sheets/region_preview_sheet.dart';

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

  // Background Service
  final bool _isServiceRunning = false;

  // Haptics
  final _hapticController = HapticCompassController();

  // Search State
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _checkBatteryOptimizations();
  }

  Future<void> _checkBatteryOptimizations() async {
    // Android-specific: Request to ignore battery optimizations for reliable background tracking
    if (await Permission.ignoreBatteryOptimizations.status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                "Recommended: Disable Battery Optimization for uninterrupted tracking."),
            action: SnackBarAction(
              label: "Disable",
              onPressed: () => Permission.ignoreBatteryOptimizations.request(),
            ),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    final service = FlutterBackgroundService();
    if (!await service.isRunning()) {
      await initializeBackgroundService();
    }

    await ref.read(seedingServiceProvider).seedDiscoveryData();
  }

  void _startSimulation({bool deviate = false}) {
    _simTimer?.cancel();
    _simIndex = 0;

    ref.read(backtrackPathProvider.notifier).state = null;
    ref.read(backtrackTargetProvider.notifier).state = null;

    _simPath = [];
    if (!deviate) {
      for (int i = 0; i < 20; i++) {
        _simPath.add(LatLng(
          -7.4526 + (i * -0.0003),
          110.4422 + (i * 0.00025),
        ));
      }
    } else {
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
  }

  Future<void> _activateBacktrack() async {
    final db = ref.read(databaseProvider);
    final engine = BacktrackEngine(db);
    final activeId = ref.read(activeMountainIdProvider);
    final trails = await ref.read(activeTrailsProvider(activeId).future);

    final path = await engine.getSafeRetracePath('current_session', trails);

    if (path != null && path.isNotEmpty) {
      ref.read(backtrackTargetProvider.notifier).state = path.last;
      ref.read(backtrackPathProvider.notifier).state = path;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Backtrack Path Found! Retrace your steps."),
            backgroundColor: Colors.green));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("No Safe Path found in history!"),
            backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _downloadRegion(String id) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Downloading Map Data...")));

    final seeder = ref.read(seedingServiceProvider);
    try {
      // Simplified mapping (could be dynamic in seeder)
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

  void _showTrackSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title:
              const Text("Select Route", style: TextStyle(color: Colors.white)),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<AssetManifest>(
              future: AssetManifest.loadFromAssetBundle(rootBundle),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allAssets = snapshot.data!.listAssets();
                final tracks = allAssets
                    .where((key) =>
                        key.startsWith('assets/tracks/') &&
                        key.endsWith('.gpx'))
                    .toList();

                if (tracks.isEmpty) {
                  return const Text("No tracks found in assets.",
                      style: TextStyle(color: Colors.white54));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: tracks.length,
                  itemBuilder: (context, index) {
                    final path = tracks[index];
                    final name = path
                        .split('/')
                        .last
                        .replaceAll('.gpx', '')
                        .replaceAll('_', ' ')
                        .toUpperCase();

                    return ListTile(
                      leading:
                          const Icon(Icons.terrain, color: Colors.blueAccent),
                      title: Text(name,
                          style: const TextStyle(color: Colors.white)),
                      subtitle: Text(path,
                          style: const TextStyle(
                              color: Colors.white24, fontSize: 10)),
                      onTap: () async {
                        Navigator.pop(context);
                        // Infer mountainId from path if possible, or default
                        // Format: assets/tracks/merbabu/selo.gpx
                        final parts = path.split('/');
                        String mountainId = 'unknown';
                        if (parts.length >= 3) {
                          mountainId = parts[2]; // e.g. merbabu
                        }

                        await _loadTrack(
                            path, mountainId, name.replaceAll(' ', '_'), name);
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadTrack(
      String assetPath, String mountainId, String trailId, String name) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Parsing GPX..."), duration: Duration(seconds: 1)));
      }

      await ref
          .read(trackLoaderProvider)
          .loadGpxTrack(assetPath, mountainId, trailId, name);

      // Update State
      ref.read(activeMountainIdProvider.notifier).state = mountainId;
      ref.refresh(activeTrailsProvider(mountainId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Route Loaded Successfully!"),
            backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
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

    // Dynamic Tile URL logic
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

      // Haptic Feedback
      _hapticController.checkHeading(0.0, compassHeading);
    }

    final isTactical = ref.watch(isTacticalModeProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFF050505),
      endDrawer: _buildDevDrawer(),
      body: ColorFiltered(
        colorFilter: isTactical
            ? const ColorFilter.mode(Colors.red, BlendMode.modulate)
            : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
        child: Stack(
          children: [
            // 1. MAP LAYER
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(-7.453, 110.445),
                initialZoom: 13.0,
                minZoom: 10.0,
                maxZoom: 18.0,
              ),
              children: [
                if (mapStyle == MapLayerType.vector)
                  FutureBuilder<String?>(
                    future: ref
                        .read(mapPackageManagerProvider)
                        .getVectorFilePath(activeMountainId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        return VectorTileLayer(
                          theme: _getMapTheme(context),
                          tileProviders: TileProviders({
                            'openmaptiles':
                                MbTilesVectorTileProvider(path: snapshot.data!)
                          }),
                        );
                      }
                      return const Center(
                          child: Text("Vector Data Not Found",
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

                // Danger Zones
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
                              points: (t.geometryJson as List)
                                  .cast<TrailPoint>()
                                  .map((p) => p.toLatLng())
                                  .toList(),
                              strokeWidth: 4.0,
                              color: const Color(0xFF0df259),
                            ))
                        .toList(),
                  ),
                  error: (e, s) => const SizedBox(),
                  loading: () => const SizedBox(),
                ),

                // POIs
                ref.watch(activePoisProvider(activeMountainId)).when(
                      data: (pois) => MarkerLayer(
                        markers:
                            pois.map((poi) => _buildPoiMarker(poi)).toList(),
                      ),
                      loading: () => const SizedBox(),
                      error: (_, __) => const SizedBox(),
                    ),

                // Discovery Markers
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
                      color: const Color(0xFFff3b30),
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
                      child: CompassBearing(
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

            // 2. SEARCH BAR OR OVERLAY
            if (_isSearching)
              Positioned.fill(
                child: SearchOverlay(
                  onClose: () => setState(() => _isSearching = false),
                  onSelect: (region) {
                    setState(() => _isSearching = false);
                    ref.read(activeMountainIdProvider.notifier).state =
                        region.id;
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
                    child: const MapSearchBar(enabled: false),
                  )),

            // 3. OFF TRAIL WARNING
            if (safetyStatus == SafetyStatus.danger)
              Positioned(
                top: MediaQuery.of(context).padding.top + 140,
                left: 0,
                right: 0,
                child: const Center(child: OffTrailWarningBadge()),
              ),

            // 4. SIDE CONTROLS
            Positioned(
              right: 16,
              bottom: 240, // Shifted up to avoid collision
              child: MapSideControls(
                onZoomIn: () {
                  final z = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, z + 1);
                },
                onZoomOut: () {
                  final z = _mapController.camera.zoom;
                  _mapController.move(_mapController.camera.center, z - 1);
                },
                onCenter: () {
                  if (userLocAsync.value != null) {
                    _mapController.move(
                        LatLng(
                            userLocAsync.value!.lat, userLocAsync.value!.lng),
                        15);
                  }
                },
                onLayer: () {
                  showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const MapStyleSelector());
                },
                onLoadRoute: _showTrackSelectionDialog,
              ),
            ),

            // 5. BOTTOM SHEET
            NavigationSheet(
              status: safetyStatus,
              userLoc: userLocAsync.value,
              heading: compassHeading,
              trail:
                  (trailsAsync.value != null && trailsAsync.value!.isNotEmpty)
                      ? trailsAsync.value!.first
                      : null,
              onBacktrack: _activateBacktrack,
              onSimulateMenu: () => Scaffold.of(context).openEndDrawer(),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers ---

  vtr.Theme _getMapTheme(BuildContext context) {
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
              builder: (ctx) => RegionPreviewSheet(
                  region: region,
                  onAction: (LatLng? target) {
                    Navigator.pop(context);
                    ref.read(activeMountainIdProvider.notifier).state =
                        region.id;
                    if (!region.isDownloaded) {
                      _downloadRegion(region.id);
                    }
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
}
