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

  Future<MountainRegion?> getRegionById(String id) =>
      (select(mountainRegions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

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
    const buffer = 0.006;
    const maxDistance = 500.0 * 500.0;

    // Optimized query: Select only ID and start point
    // This avoids deserializing the heavy geometryJson column for every candidate
    final query = selectOnly(trails)
      ..addColumns([trails.id, trails.startLat, trails.startLng])
      ..where(trails.mountainId.equals(basecamp.mountainId) &
          trails.minLat.isSmallerOrEqualValue(basecamp.lat + buffer) &
          trails.maxLat.isBiggerOrEqualValue(basecamp.lat - buffer) &
          trails.minLng.isSmallerOrEqualValue(basecamp.lng + buffer) &
          trails.maxLng.isBiggerOrEqualValue(basecamp.lng - buffer));

    final rows = await query.get();
    if (rows.isEmpty) return null;

    String? bestTrailId;
    double minDistance = double.infinity;
    final idsToFetchFull = <String>[];

    for (final row in rows) {
      final startLat = row.read(trails.startLat);
      final startLng = row.read(trails.startLng);
      final id = row.read(trails.id)!;

      if (startLat != null && startLng != null) {
        // Fast path: Use indexed columns
        final dLat = (startLat - basecamp.lat) * 111320;
        final dLng = (startLng - basecamp.lng) * 111320 * 0.85;
        final dist = dLat * dLat + dLng * dLng;

        if (dist < maxDistance && dist < minDistance) {
          minDistance = dist;
          bestTrailId = id;
        }
      } else {
        // Fallback: Data not migrated or populated, must fetch full entity
        idsToFetchFull.add(id);
      }
    }

    // Process fallback for legacy data (if any)
    if (idsToFetchFull.isNotEmpty) {
      final fullTrails =
          await (select(trails)..where((t) => t.id.isIn(idsToFetchFull))).get();
      for (final trail in fullTrails) {
        final geometry = trail.geometryJson;
        if (geometry.isEmpty) continue;
        final firstPoint = geometry.first;

        final dLat = (firstPoint.lat - basecamp.lat) * 111320;
        final dLng = (firstPoint.lng - basecamp.lng) * 111320 * 0.85;
        final dist = dLat * dLat + dLng * dLng;

        if (dist < maxDistance && dist < minDistance) {
          minDistance = dist;
          bestTrailId = trail.id;
        }
      }
    }

    if (bestTrailId != null) {
      return (select(trails)..where((t) => t.id.equals(bestTrailId!)))
          .getSingle();
    }

    return null;
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
