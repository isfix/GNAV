import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'dart:math' show Point;
import 'package:drift/drift.dart' as drift;
import 'package:geolocator/geolocator.dart';

// INTERNAL IMPORTS
import '../../../data/local/db/app_database.dart';
import '../../../../core/services/seeding_service.dart';
import '../logic/navigation_providers.dart';
import '../logic/haptic_compass_controller.dart';
import '../logic/deviation_engine.dart';
import '../logic/backtrack_engine.dart';
import '../../../core/utils/geo_math.dart';
import '../../../core/utils/offline_map_style_helper.dart';
import '../../../core/services/map_layer_service.dart';

// WIDGET IMPORTS (REFACTORED)
import 'widgets/atoms/off_trail_warning_badge.dart';
import 'widgets/glass_hud.dart'; // NEW
import 'widgets/controls/map_style_selector.dart';
import 'widgets/sheets/navigation_sheet.dart';
import 'widgets/sheets/search_overlay.dart';
import 'widgets/sheets/mountain_detail_sheet.dart';
import 'widgets/sheets/basecamp_preview_sheet.dart';

// -----------------------------------------------------------------------------
// MAIN SCREEN
// -----------------------------------------------------------------------------

class OfflineMapScreen extends ConsumerStatefulWidget {
  final String? mountainId;
  final String? trailId;
  final bool isHeadless;

  const OfflineMapScreen({
    super.key,
    this.mountainId,
    this.trailId,
    this.isHeadless = false,
  });

  @override
  ConsumerState<OfflineMapScreen> createState() => _OfflineMapScreenState();
}

class _OfflineMapScreenState extends ConsumerState<OfflineMapScreen> {
  MapLibreMapController? _mapController;

  // Dynamic style string (loaded from MBTiles)
  String? _styleString;

  // Simulation State
  Timer? _simTimer;
  int _simIndex = 0;
  List<LatLng> _simPath = [];
  final List<UserBreadcrumbsCompanion> _simBreadcrumbBuffer = [];
  static const int _simBatchSize = 5;

  // Compass State
  final ValueNotifier<double> _compassHeading = ValueNotifier(0.0);
  StreamSubscription<CompassEvent>? _compassSubscription;

  // Search State
  bool _isSearching = false;
  bool _isLocationPermissionGranted = false;

  // Selected trail for highlighting
  Trail? _selectedTrail;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Seed discovery data (mountains registry)
    await ref.read(seedingServiceProvider).seedDiscoveryData();

    // 2. Seed Merbabu trails and basecamps from GPX files
    await ref.read(seedingServiceProvider).seedMerbabu();

    // 3. Load selected trail if trailId was passed
    if (widget.trailId != null) {
      await _loadSelectedTrail();
    }

    // 4. Set active mountain from params
    if (widget.mountainId != null) {
      ref.read(activeMountainIdProvider.notifier).state = widget.mountainId!;
    }

    // 5. Load Map Style
    await _loadMapStyle();

    // 6. Then check permissions for location (simplified)
    _checkPermissions();
    _checkBatteryOptimizations();

    // 7. Initialize Compass
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted && event.heading != null) {
        _compassHeading.value = event.heading!;
        // Update user location marker rotation immediately
        final userLoc = ref.read(userLocationProvider).value;
        if (userLoc != null) {
          mapLayerService.drawUserLocation(
            LatLng(userLoc.lat, userLoc.lng),
            event.heading!,
          );
        }
      }
    });
  }

  /// Load map style (Vector MBTiles or Online Fallback)
  Future<void> _loadMapStyle() async {
    final db = ref.read(databaseProvider);
    final mountainId = widget.mountainId ?? 'merbabu';
    final mountain = await db.mountainDao.getRegionById(mountainId);

    String style;
    if (mountain != null && mountain.localMapPath != null) {
      // Offline mode: Inject MBTiles path
      debugPrint(
          '[Map] Loading offline style for ${mountain.name} at ${mountain.localMapPath}');
      style =
          await OfflineMapStyleHelper.getOfflineStyle(mountain.localMapPath!);
    } else {
      // Fallback: Use standard style (online tiles or bundled)
      debugPrint('[Map] Loading default style (online fallback)');
      style = await OfflineMapStyleHelper.getStyleTemplate();
    }

    if (mounted) {
      setState(() {
        _styleString = style;
      });
    }
  }

  /// Load the selected trail from database
  Future<void> _loadSelectedTrail() async {
    if (widget.trailId == null) return;

    final db = ref.read(databaseProvider);
    final selectedTrail = await db.navigationDao.getTrailById(widget.trailId!);

    if (selectedTrail != null && mounted) {
      setState(() {
        _selectedTrail = selectedTrail;
      });
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

    if (mounted) {
      setState(() {
        _isLocationPermissionGranted = true;
      });
    }

    // Native Service is started by StitchMapScreen parent
  }

  void _stopSimulation() {
    _simTimer?.cancel();
    _simTimer = null;
    _flushSimBuffer();
  }

  Future<void> _flushSimBuffer() async {
    if (_simBreadcrumbBuffer.isNotEmpty) {
      final db = ref.read(databaseProvider);
      final toInsert =
          List<UserBreadcrumbsCompanion>.from(_simBreadcrumbBuffer);
      _simBreadcrumbBuffer.clear();
      await db.trackingDao.insertBreadcrumbs(toInsert);
    }
  }

  void _startSimulation({bool deviate = false}) {
    _stopSimulation(); // Ensure previous simulation is stopped and flushed
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
        _flushSimBuffer();
        return;
      }
      final pt = _simPath[_simIndex];
      _simIndex++;

      _simBreadcrumbBuffer.add(
        UserBreadcrumbsCompanion(
          sessionId: const drift.Value('sim_session'),
          lat: drift.Value(pt.latitude),
          lng: drift.Value(pt.longitude),
          altitude: const drift.Value(2000),
          accuracy: const drift.Value(5.0),
          timestamp: drift.Value(DateTime.now()),
        ),
      );

      if (_simBreadcrumbBuffer.length >= _simBatchSize) {
        _flushSimBuffer();
      }

      _processNavigationLogic(pt);

      // PHASE 2 - MapLibre camera animation
      // Calculate bearing for smooth rotation if we have history
      double targetBearing = _mapController?.cameraPosition?.bearing ?? 0.0;

      if (_simIndex >= 2) {
        final prev = _simPath[_simIndex - 2];
        targetBearing = GeoMath.bearing(prev, pt);
      }

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: pt,
            zoom: 17.0, // Closer zoom for navigation simulation
            bearing: targetBearing,
            tilt: 50.0, // Tactical 3D perspective
          ),
        ),
        duration: const Duration(milliseconds: 500),
      );
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
    final db = ref.read(databaseProvider);

    // 1. Fetch all async data concurrently
    final results = await Future.wait([
      ref.read(activeTrailsProvider(activeMountainId).future),
      ref.read(allMountainsProvider.future),
      db.navigationDao.getAllBasecamps(),
    ]);

    // Extract results
    final trails = results[0] as List<Trail>;
    final regions = results[1] as List<MountainRegion>;
    final basecamps = results[2] as List<PointOfInterest>;

    // 2. Get synchronous data
    final dangerZones = ref.read(dangerZonesProvider);
    final backtrackPath = ref.read(backtrackPathProvider);

    // 3. Draw all layers concurrently
    await Future.wait([
      mapLayerService.drawTrails(trails, highlightTrailId: _selectedTrail?.id),
      mapLayerService.drawDangerZones(dangerZones),
      mapLayerService.drawBacktrackPath(backtrackPath),
      mapLayerService.drawMountainMarkers(regions),
      mapLayerService.drawBasecampMarkers(basecamps),
    ]);

    // 4. If we have a selected trail, zoom to fit it
    if (_selectedTrail != null) {
      _zoomToTrail(_selectedTrail!);
    }

    debugPrint(
        '[MAP] Drew ${regions.length} mountains, ${basecamps.length} basecamps, selected: ${_selectedTrail?.name}');
  }

  /// Zoom the map to fit the selected trail bounds
  void _zoomToTrail(Trail trail) {
    if (_mapController == null) return;

    // Use the trail's bounding box
    final bounds = LatLngBounds(
      southwest: LatLng(trail.minLat, trail.minLng),
      northeast: LatLng(trail.maxLat, trail.maxLng),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds,
          left: 50, top: 100, right: 50, bottom: 150),
    );
  }

  /// Handles map taps to detect feature clicks on markers
  Future<void> _handleMapTap(LatLng latLng) async {
    if (_mapController == null) return;

    try {
      // Query features at tap point (radius in pixels)
      final screenPoint = await _mapController!.toScreenLocation(latLng);
      final features = await _mapController!.queryRenderedFeatures(
        Point(screenPoint.x.toDouble(), screenPoint.y.toDouble()),
        [
          MapLayerService.mountainMarkerLayerId,
          MapLayerService.mountainClusterLayerId,
          MapLayerService.basecampMarkerLayerId,
          MapLayerService.basecampClusterLayerId,
        ],
        null,
      );

      if (features.isEmpty) return;

      final feature = features.first;
      final properties = feature['properties'] as Map?;

      // Check for cluster click
      final isCluster = properties?['cluster'] == true;
      if (isCluster) {
        final currentZoom = _mapController!.cameraPosition?.zoom ?? 12;
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(latLng, currentZoom + 2),
          duration: const Duration(milliseconds: 300),
        );
        return;
      }

      final featureType = properties?['type'] as String?;

      if (featureType == 'mountain') {
        final mountainId = properties?['id'] as String?;
        if (mountainId != null) {
          _showMountainDetailSheet(mountainId);
        }
      } else if (featureType == 'basecamp') {
        final basecampId = properties?['id'] as String?;
        if (basecampId != null) {
          _showBasecampPreviewSheet(basecampId);
        }
      }
    } catch (e) {
      debugPrint('Error handling map tap: $e');
    }
  }

  /// Shows mountain detail sheet
  Future<void> _showMountainDetailSheet(String mountainId) async {
    final db = ref.read(databaseProvider);

    // Get mountain
    final mountains = await db.mountainDao.getAllRegions();
    final mountain = mountains.firstWhere(
      (m) => m.id == mountainId,
      orElse: () => mountains.first,
    );

    // Get basecamps for this mountain
    final basecamps =
        await db.navigationDao.getBasecampsForMountain(mountainId);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MountainDetailSheet(
        mountain: mountain,
        basecamps: basecamps,
        onBasecampTap: (basecamp) {
          Navigator.pop(ctx);
          // Zoom to basecamp
          _mapController?.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(basecamp.lat, basecamp.lng),
              15,
            ),
          );
          // Show basecamp preview after short delay
          Future.delayed(const Duration(milliseconds: 300), () {
            _showBasecampPreviewSheet(basecamp.id);
          });
        },
      ),
    );
  }

  /// Shows basecamp preview sheet with Start Hike button
  Future<void> _showBasecampPreviewSheet(String basecampId) async {
    final db = ref.read(databaseProvider);

    // Get basecamp
    final basecamp = await db.navigationDao.getPoiById(basecampId);
    if (basecamp == null || !mounted) return;

    // Find associated trail (Smart Trail Finder)
    final trail = await db.navigationDao.getTrailForBasecamp(basecamp);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BasecampPreviewSheet(
        basecamp: basecamp,
        associatedTrail: trail,
        onStartHike: trail != null
            ? () async {
                Navigator.pop(ctx);

                // Set active mountain
                ref.read(activeMountainIdProvider.notifier).state =
                    basecamp.mountainId;

                // Draw the trail
                mapLayerService.drawTrails([trail]);

                // Zoom to trail
                if (trail.geometryJson != null &&
                    (trail.geometryJson as List).isNotEmpty) {
                  final points = (trail.geometryJson as List);
                  final midpoint = points[points.length ~/ 2];
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLngZoom(
                      LatLng(midpoint.lat, midpoint.lng),
                      14,
                    ),
                  );
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Trail loaded: ${trail.name}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            : () {
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No mapped trail found for this basecamp'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
        errorMessage:
            trail == null ? 'No mapped trail found for this basecamp' : null,
      ),
    );
  }

  Future<void> _handleMapLongPress(LatLng destination) async {
    final userLoc = ref.read(userLocationProvider).value;
    if (userLoc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waiting for GPS location...')),
      );
      return;
    }

    final start = LatLng(userLoc.lat, userLoc.lng);

    // Calculate Route
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Calculating route...')),
    );

    // Run in background / ensure it doesn't block too much
    // Since RoutingEngine is synchronous (fast for <10k nodes), we can call directly.
    final engine = ref.read(routingEngineProvider);
    final path = engine.findRoute(start, destination);

    if (path != null) {
      ref.read(routePathProvider.notifier).state = path;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No trail route found to this location. Try tapping closer to a trail.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _stopSimulation();
    _compassSubscription?.cancel();
    _compassHeading.dispose();
    mapLayerService.detach();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styleString = _styleString;
    final userLocAsync = ref.watch(userLocationProvider);
    final safetyStatus = ref.watch(safetyStatusProvider);
    final activeMountainId = ref.watch(activeMountainIdProvider);
    final trailsAsync = ref.watch(activeTrailsProvider(activeMountainId));
    final backtrackTarget = ref.watch(backtrackTargetProvider);

    // HEADLESS MODE: Return ONLY the Map Widget
    if (widget.isHeadless) {
      if (styleString == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return _buildMapWidget(styleString);
    }

    // Heading Calculation
    double compassHeading = 0;
    if (backtrackTarget != null && userLocAsync.value != null) {
      final userPt = LatLng(userLocAsync.value!.lat, userLocAsync.value!.lng);
      compassHeading = GeoMath.bearing(userPt, backtrackTarget);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. MAP LAYER
          if (styleString != null)
            _buildMapWidget(styleString)
          else
            const Center(child: CircularProgressIndicator()),

          // 2. HUD LAYER (Glass)
          Positioned(
            top: MediaQuery.of(context).padding.top + 60,
            left: 16,
            right: 16,
            child: CockpitHud(
              altitude: userLocAsync.value?.altitude ?? 0.0,
              bearing: compassHeading,
              speed: userLocAsync.value?.speed,
            ),
          ),

          // 3. SEARCH & ACTIONS
          if (_isSearching)
            Positioned.fill(
              child: SearchOverlay(
                onClose: () => setState(() => _isSearching = false),
                onSelect: (region) {
                  setState(() => _isSearching = false);
                  ref.read(activeMountainIdProvider.notifier).state = region.id;
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
              right: 16,
              child: GlassFab(
                icon: Icons.search,
                onTap: () => setState(() => _isSearching = true),
              ),
            ),

          // 4. OFF TRAIL WARNING
          if (safetyStatus == SafetyStatus.danger)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 0,
              right: 0,
              child: const Center(child: OffTrailWarningBadge()),
            ),

          // 5. SIDE CONTROLS
          Positioned(
            right: 16,
            bottom: 240,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GlassFab(
                  icon: Icons.layers_outlined,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => const MapStyleSelector(),
                    );
                  },
                ),
                const SizedBox(height: 16),
                GlassFab(
                  icon: Icons.add,
                  onTap: () {
                    _mapController?.animateCamera(CameraUpdate.zoomTo(
                        (_mapController?.cameraPosition?.zoom ?? 12) + 1));
                  },
                ),
                const SizedBox(height: 16),
                GlassFab(
                  icon: Icons.remove,
                  onTap: () {
                    _mapController?.animateCamera(CameraUpdate.zoomTo(
                        (_mapController?.cameraPosition?.zoom ?? 12) - 1));
                  },
                ),
                const SizedBox(height: 16),
                GlassFab(
                    icon: Icons.my_location,
                    active: true,
                    onTap: () {
                      if (userLocAsync.value != null &&
                          _mapController != null) {
                        _mapController!.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(userLocAsync.value!.lat,
                                userLocAsync.value!.lng),
                            15,
                          ),
                        );
                      }
                    }),
                const SizedBox(height: 16),
                GlassFab(
                  icon: Icons.directions_walk,
                  onTap: _showTrackSelectionDialog,
                ),
              ],
            ),
          ),

          // 6. BOTTOM SHEET
          NavigationSheet(
            status: safetyStatus,
            userLoc: userLocAsync.value,
            heading: _compassHeading,
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

  Widget _buildMapWidget(String styleString) {
    return MapLibreMap(
      styleString: styleString,
      initialCameraPosition: const CameraPosition(
        target: LatLng(-7.453, 110.448), // Mt. Merbabu
        zoom: 12.0,
      ),
      myLocationEnabled: _isLocationPermissionGranted,
      myLocationRenderMode: _isLocationPermissionGranted
          ? MyLocationRenderMode.compass
          : MyLocationRenderMode.normal,
      myLocationTrackingMode: _isLocationPermissionGranted
          ? MyLocationTrackingMode.tracking
          : MyLocationTrackingMode.none,
      onMapCreated: (controller) {
        _mapController = controller;
        mapLayerService.attach(controller);
      },
      onStyleLoadedCallback: () {
        _drawMapLayers();
      },
      onMapClick: (point, latLng) => _handleMapTap(latLng),
      onMapLongClick: (point, latLng) => _handleMapLongPress(latLng),
      trackCameraPosition: true,
      compassEnabled: true,
      compassViewPosition: CompassViewPosition.topRight,
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
              _stopSimulation();
            },
          ),
        ],
      ),
    );
  }
}
