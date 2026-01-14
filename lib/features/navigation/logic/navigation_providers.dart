import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:latlong2/latlong.dart';
import '../../../data/local/db/app_database.dart';
import 'deviation_engine.dart';
import 'gps_state_machine.dart';
import 'map_package_manager.dart';

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final mapPackageManagerProvider = Provider<MapPackageManager>((ref) {
  return MapPackageManager(ref.watch(databaseProvider));
});

// Current User Location Provider (Streamed)
// In a real app, this streams from Geolocator or Background Service via a Repository.
// Here we mock a stream or assume we hook into the DB if the service writes to it.
// For UI responsiveness, let's assume we read from a StreamController that the BackgroundService updates, or
// simply stream the latest Breadcrumb from DB.
final userLocationProvider = StreamProvider<UserBreadcrumb?>((ref) {
  final db = ref.watch(databaseProvider);
  // Watch the latest entry
  return (db.select(db.userBreadcrumbs)
        ..orderBy([
          (t) => OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
        ])
        ..limit(1))
      .watchSingleOrNull();
});

// Safety Monitor Provider (Stateful)
final deviationMonitorProvider =
    Provider<DeviationMonitor>((ref) => DeviationMonitor());

// Safety Status (Derived)
final safetyStatusProvider =
    StateProvider<SafetyStatus>((ref) => SafetyStatus.safe);

// Map Layer Types
enum MapLayerType {
  osm, // OpenStreetMap (Standard)
  cyclOsm, // CyclOSM (High Detail/Elevation)
  openTopo, // Topographic (Hiking)
  satellite, // Esri World Imagery
  googleHybrid, // Google Maps (Sat + Roads/Trails)
  hybrid, // Annotated Satellite (Esri/OpenStreet)
  vector, // MVT Vector Tiles (Offline)
}

final mapStyleProvider =
    StateProvider<MapLayerType>((ref) => MapLayerType.cyclOsm);

// GPS State Provider
final gpsStateProvider = StateNotifierProvider<GpsStateMachine, GpsMode>((ref) {
  return GpsStateMachine();
});

// Backtrack Path Provider (Nullable - only valid if backtracking active)
final backtrackPathProvider = StateProvider<List<LatLng>?>((ref) => null);
final backtrackTargetProvider = StateProvider<LatLng?>((ref) => null);
// Active Mountain Region Provider
final activeMountainIdProvider = StateProvider<String>((ref) => 'merbabu');

// Should fetch based on current active MountainRegion
final activeTrailsProvider =
    FutureProvider.family<List<Trail>, String>((ref, mountainId) async {
  final db = ref.watch(databaseProvider);
  return db.navigationDao.getTrailsForMountain(mountainId);
});
final activePoisProvider = FutureProvider.family<List<PointOfInterest>, String>(
    (ref, mountainId) async {
  final db = ref.watch(databaseProvider);
  return db.navigationDao.getPoisForMountain(mountainId);
});

// Discovery Provider: Fetch ALL regions to show on global map
final allMountainsProvider = StreamProvider<List<MountainRegion>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.mountainDao.watchAllRegions();
});

// Danger Zones Provider (Hardcoded for Demo)
// In production, this should come from a DB table or GeoJSON file.
final dangerZonesProvider = Provider<List<List<LatLng>>>((ref) {
  final activeId = ref.watch(activeMountainIdProvider);
  if (activeId == 'merapi') {
    // Merapi Summit Danger Zone (Approximate)
    return [
      [
        const LatLng(-7.5420, 110.4430),
        const LatLng(-7.5380, 110.4450),
        const LatLng(-7.5390, 110.4500),
        const LatLng(-7.5450, 110.4500),
        const LatLng(-7.5460, 110.4460),
      ]
    ];
  }
  if (activeId == 'semeru') {
    // Semeru Jonggring Saloko Danger Zone
    return [
      [
        const LatLng(-8.1050, 112.9150),
        const LatLng(-8.1000, 112.9200),
        const LatLng(-8.1020, 112.9300),
        const LatLng(-8.1100, 112.9250),
      ]
    ];
  }
  return [];
});
