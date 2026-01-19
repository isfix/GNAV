import 'package:drift/drift.dart';
import '../db/app_database.dart';
import '../db/tables.dart';

part 'daos.g.dart';

@DriftAccessor(tables: [MountainRegions])
class MountainDao extends DatabaseAccessor<AppDatabase>
    with _$MountainDaoMixin {
  MountainDao(super.db);

  Future<List<MountainRegion>> getAllRegions() => select(mountainRegions).get();
  Stream<List<MountainRegion>> watchAllRegions() =>
      select(mountainRegions).watch();

  Future<List<MountainRegion>> getDownloadedRegions() =>
      (select(mountainRegions)..where((t) => t.isDownloaded.equals(true)))
          .get();

  Future<void> updateRegionPath(String id, String path) {
    return (update(mountainRegions)..where((t) => t.id.equals(id))).write(
      MountainRegionsCompanion(
        localMapPath: Value(path),
        isDownloaded: const Value(true),
      ),
    );
  }
}

@DriftAccessor(tables: [Trails, PointsOfInterest])
class NavigationDao extends DatabaseAccessor<AppDatabase>
    with _$NavigationDaoMixin {
  NavigationDao(super.db);

  Future<List<Trail>> getTrailsForMountain(String mountainId) {
    return (select(trails)..where((t) => t.mountainId.equals(mountainId)))
        .get();
  }

  Future<List<Trail>> getTrailsNearBasecamp(
      String mountainId, double lat, double lng, double buffer) {
    return (select(trails)
          ..where((t) =>
              t.mountainId.equals(mountainId) &
              t.minLat.isSmallerOrEqualValue(lat + buffer) &
              t.maxLat.isBiggerOrEqualValue(lat - buffer) &
              t.minLng.isSmallerOrEqualValue(lng + buffer) &
              t.maxLng.isBiggerOrEqualValue(lng - buffer)))
        .get();
  }

  /// Spatial query using pre-calculated bounding boxes.
  /// This is O(1) indexed lookup instead of O(N) table scan.
  ///
  /// [buffer] is in degrees, approximately:
  /// - 0.001 = ~110m
  /// - 0.005 = ~500m
  /// - 0.01 = ~1.1km
  Future<List<Trail>> getNearbyTrails(double userLat, double userLng,
      {double buffer = 0.005}) {
    return (select(trails)
          ..where((t) =>
              t.minLat.isSmallerOrEqualValue(userLat + buffer) &
              t.maxLat.isBiggerOrEqualValue(userLat - buffer) &
              t.minLng.isSmallerOrEqualValue(userLng + buffer) &
              t.maxLng.isBiggerOrEqualValue(userLng - buffer)))
        .get();
  }

  Future<List<PointOfInterest>> getPoisForMountain(String mountainId) {
    return (select(pointsOfInterest)
          ..where((t) => t.mountainId.equals(mountainId)))
        .get();
  }

  Future<void> insertTrail(TrailsCompanion trail) {
    return into(trails).insertOnConflictUpdate(trail);
  }

  // NOTE: Spatial query for nearest water source usually requires custom SQL or Iterate
  // Since we don't have Spatialite extension in standard build easily on all platforms,
  // we might filter by lat/lng bounding box in Dart or simple Euclidean approx if small dataset.
  Future<List<PointOfInterest>> getAllWaterSources(String mountainId) {
    return (select(pointsOfInterest)
          ..where((t) =>
              t.mountainId.equals(mountainId) & t.type.equals(1))) // 1 = Water
        .get();
  }

  /// Gets all basecamps for a mountain
  Future<List<PointOfInterest>> getBasecampsForMountain(String mountainId) {
    return (select(pointsOfInterest)
          ..where((t) =>
              t.mountainId.equals(mountainId) &
              t.type.equals(0))) // 0 = Basecamp
        .get();
  }

  /// Gets all basecamps across all mountains
  Future<List<PointOfInterest>> getAllBasecamps() {
    return (select(pointsOfInterest)
          ..where((t) => t.type.equals(0))) // 0 = Basecamp
        .get();
  }

  /// Gets a specific POI by ID
  Future<PointOfInterest?> getPoiById(String id) {
    return (select(pointsOfInterest)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Smart Trail Finder: Finds the trail that starts near a basecamp
  ///
  /// Logic:
  /// 1. Get all trails for the basecamp's mountain
  /// 2. Find trail whose first point is within 500m of basecamp
  /// 3. Return the nearest match
  Future<Trail?> getTrailForBasecamp(PointOfInterest basecamp) async {
    // Get trails near this basecamp (approx 0.006 degrees buffer ~ 660m)
    // This pre-filters trails using O(1) indexed bounding box lookup
    final mountainTrails = await getTrailsNearBasecamp(
        basecamp.mountainId, basecamp.lat, basecamp.lng, 0.006);
    if (mountainTrails.isEmpty) return null;

    Trail? nearestTrail;
    double minDistance = double.infinity;

    for (final trail in mountainTrails) {
      final geometry = trail.geometryJson;
      if (geometry.isEmpty) continue;

      // Get first point of trail
      final firstPoint = geometry.first;
      final trailStartLat = firstPoint.lat;
      final trailStartLng = firstPoint.lng;

      // Calculate approximate distance (Haversine simplified)
      final dLat = (trailStartLat - basecamp.lat) * 111320; // meters per degree
      final dLng = (trailStartLng - basecamp.lng) *
          111320 *
          0.85; // approx at -7° latitude
      final distance = (dLat * dLat + dLng * dLng);

      // 500m threshold (in squared meters to avoid sqrt)
      const maxDistance = 500.0 * 500.0;

      if (distance < maxDistance && distance < minDistance) {
        minDistance = distance;
        nearestTrail = trail;
      }
    }

    return nearestTrail;
  }
}

@DriftAccessor(tables: [UserBreadcrumbs])
class TrackingDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingDaoMixin {
  TrackingDao(super.db);

  Future<int> insertBreadcrumb(UserBreadcrumbsCompanion entry) {
    return into(userBreadcrumbs).insert(entry);
  }

  Future<void> insertBreadcrumbs(List<UserBreadcrumbsCompanion> entries) {
    return batch((batch) {
      batch.insertAll(userBreadcrumbs, entries);
    });
  }

  Future<List<UserBreadcrumb>> getSessionHistory(String sessionId) {
    return (select(userBreadcrumbs)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
        .get();
  }

  Future<void> cleanOldData() {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return (delete(userBreadcrumbs)
          ..where((t) => t.timestamp.isSmallerThanValue(thirtyDaysAgo)))
        .go();
  }
}
