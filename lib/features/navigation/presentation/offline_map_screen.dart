import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:drift/drift.dart' as drift;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

// INTERNAL IMPORTS
import '../../../data/local/db/converters.dart'; // For PoiType if needed
import '../../../data/local/db/app_database.dart';
import '../../../../core/services/seeding_service.dart';
import '../../../../core/services/background_service.dart';
import '../logic/navigation_providers.dart';
import '../logic/gps_state_machine.dart';
import '../logic/haptic_compass_controller.dart';
import '../logic/deviation_engine.dart';
import '../logic/backtrack_engine.dart';
import '../../../core/utils/geo_math.dart';
import '../../../core/services/map_layer_service.dart';
import '../../../core/services/routing_initialization_service.dart';

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
  MapLibreMapController? _mapController;

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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. ALWAYS seed discovery data first (no permission needed)
    await ref.read(seedingServiceProvider).seedDiscoveryData();

    // 2. Then check permissions for background service
    _checkPermissions();
    _checkBatteryOptimizations();

    // 3. Initialize routing engine in background (async, don't await)
    _initializeRoutingEngine();
  }

  Future<void> _initializeRoutingEngine() async {
    await routingInitializationService.initialize(
      onProgress: (status, progress) {
        debugPrint('Routing: $status ($progress)');
        // Optionally show status in UI
      },
    );
    if (routingInitializationService.isReady && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Offline routing engine ready'),
          backgroundColor: Color(0xFF0df259),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _checkBatteryOptimizations() async {
    // Android-specific: Request to ignore battery optimizations for reliable background tracking
    if (await Permission.ignoreBatteryOptimizations.status.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Recommended: Disable Battery Optimization for uninterrupted tracking.",
            ),
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
  }

  void _startSimulation({bool deviate = false}) {
    _simTimer?.cancel();
    _simIndex = 0;

    ref.read(backtrackPathProvider.notifier).state = null;
    ref.read(backtrackTargetProvider.notifier).state = null;

    _simPath = [];
    if (!deviate) {
      for (int i = 0; i < 20; i++) {
        _simPath.add(LatLng(-7.4526 + (i * -0.0003), 110.4422 + (i * 0.00025)));
      }
    } else {
      for (int i = 0; i < 30; i++) {
        double lngDrift = (i > 8) ? -0.0005 * (i - 8) : 0.00025 * i;
        _simPath.add(LatLng(-7.4526 + (i * -0.0003), 110.4422 + lngDrift));
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
      // TODO: PHASE 2 - MapLibre camera animation
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(pt, 16));
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Backtrack Path Found! Retrace your steps."),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No Safe Path found in history!"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadRegion(String id) async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Downloading Map Data...")));

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Download Complete!"),
            backgroundColor: Colors.green,
          ),
        );
        ref.refresh(allMountainsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Download Failed: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showTrackSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          title: const Text(
            "Select Route",
            style: TextStyle(color: Colors.white),
          ),
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
                    .where(
                      (key) =>
                          key.startsWith('assets/tracks/') &&
                          key.endsWith('.gpx'),
                    )
                    .toList();

                if (tracks.isEmpty) {
                  return const Text(
                    "No tracks found in assets.",
                    style: TextStyle(color: Colors.white54),
                  );
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
                      leading: const Icon(
                        Icons.terrain,
                        color: Colors.blueAccent,
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        path,
                        style: const TextStyle(
                          color: Colors.white24,
                          fontSize: 10,
                        ),
                      ),
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
                          path,
                          mountainId,
                          name.replaceAll(' ', '_'),
                          name,
                        );
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
    String assetPath,
    String mountainId,
    String trailId,
    String name,
  ) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Parsing GPX..."),
            duration: Duration(seconds: 1),
          ),
        );
      }

      await ref
          .read(trackLoaderProvider)
          .loadGpxTrack(assetPath, mountainId, trailId, name);

      // Update State
      ref.read(activeMountainIdProvider.notifier).state = mountainId;
      ref.refresh(activeTrailsProvider(mountainId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Route Loaded Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  /// Draws all map layers after style is loaded
  Future<void> _drawMapLayers() async {
    final activeMountainId = ref.read(activeMountainIdProvider);

    // Draw trails
    final trailsAsync = await ref.read(
      activeTrailsProvider(activeMountainId).future,
    );
    mapLayerService.drawTrails(trailsAsync);

    // Draw danger zones
    final dangerZones = ref.read(dangerZonesProvider);
    mapLayerService.drawDangerZones(dangerZones);

    // Draw backtrack if available
    final backtrackPath = ref.read(backtrackPathProvider);
    mapLayerService.drawBacktrackPath(backtrackPath);

    // Add POI markers
    final pois = await ref.read(activePoisProvider(activeMountainId).future);
    mapLayerService.addPOIMarkers(pois);

    // Add region markers
    final regions = await ref.read(allMountainsProvider.future);
    mapLayerService.addRegionMarkers(regions);
  }

  @override
  void dispose() {
    _simTimer?.cancel();
    mapLayerService.detach();
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

    // Heading Calculation (using GeoMath now)
    double compassHeading = 0;
    if (backtrackTarget != null && userLocAsync.value != null) {
      final userPt = LatLng(userLocAsync.value!.lat, userLocAsync.value!.lng);
      compassHeading = GeoMath.bearing(userPt, backtrackTarget);

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
            // 1. MAP LAYER (MapLibre - PHASE 2)
            MapLibreMap(
              styleString: 'asset://assets/map_styles/dark_mountain.json',
              initialCameraPosition: const CameraPosition(
                target: LatLng(-7.453, 110.448), // Mt. Merbabu
                zoom: 12.0,
              ),
              myLocationEnabled: true,
              compassEnabled: true,
              onMapCreated: (controller) {
                _mapController = controller;
                mapLayerService.attach(controller);
              },
              onStyleLoadedCallback: () {
                // Draw layers once style is loaded
                _drawMapLayers();
              },
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
                    _mapController?.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(region.lat, region.lng),
                        14,
                      ),
                    );
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
                ),
              ),

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
                  if (_mapController != null) {
                    final currentZoom =
                        _mapController!.cameraPosition?.zoom ?? 12;
                    _mapController!.animateCamera(
                      CameraUpdate.zoomTo(currentZoom + 1),
                    );
                  }
                },
                onZoomOut: () {
                  if (_mapController != null) {
                    final currentZoom =
                        _mapController!.cameraPosition?.zoom ?? 12;
                    _mapController!.animateCamera(
                      CameraUpdate.zoomTo(currentZoom - 1),
                    );
                  }
                },
                onCenter: () {
                  if (userLocAsync.value != null && _mapController != null) {
                    _mapController!.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(
                          userLocAsync.value!.lat,
                          userLocAsync.value!.lng,
                        ),
                        15,
                      ),
                    );
                  }
                },
                onLayer: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => const MapStyleSelector(),
                  );
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
  // TODO: PHASE 2 - Implement MapLibre-native helpers for POI symbols, Region clusters, etc.

  Widget _buildDevDrawer() {
    return Drawer(
      backgroundColor: const Color(0xFF141414),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black),
            child: Text(
              'DEV TOOLS',
              style: TextStyle(
                color: Color(0xFF0df259),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow, color: Color(0xFF0df259)),
            title: const Text(
              'Simulate Safe Walk',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _startSimulation(deviate: false);
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning, color: Color(0xFFff3b30)),
            title: const Text(
              'Simulate Deviation',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _startSimulation(deviate: true);
            },
          ),
          ListTile(
            leading: const Icon(Icons.stop, color: Colors.grey),
            title: const Text(
              'Stop Simulation',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
              _simTimer?.cancel();
            },
          ),
        ],
      ),
    );
  }
}
