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
}

@DriftAccessor(tables: [UserBreadcrumbs])
class TrackingDao extends DatabaseAccessor<AppDatabase>
    with _$TrackingDaoMixin {
  TrackingDao(super.db);

  Future<int> insertBreadcrumb(UserBreadcrumbsCompanion entry) {
    return into(userBreadcrumbs).insert(entry);
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
