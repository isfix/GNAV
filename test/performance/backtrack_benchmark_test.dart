import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';
import 'package:pandu_navigation/features/navigation/logic/backtrack_engine.dart';
import 'package:pandu_navigation/features/navigation/logic/deviation_engine.dart';

void main() {
  late AppDatabase db;
  late BacktrackEngine engine;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    engine = BacktrackEngine(db);
  });

  tearDown(() async {
    await db.close();
  });

  List<TrailPoint> generateTrailPoints(int count, {double startLat = 0, double startLng = 0}) {
    return List.generate(count, (i) {
      return TrailPoint(startLat + (i * 0.0001), startLng + (i * 0.0001), 0);
    });
  }

  Future<void> seedData(int trailPointsCount, int breadcrumbCount) async {
    // 1. Create a Mountain Region
    await db.into(db.mountainRegions).insert(MountainRegionsCompanion.insert(
          id: 'mt1',
          name: 'Mount Test',
          boundaryJson: '{}',
        ));

    // 2. Create a complex trail
    final points = generateTrailPoints(trailPointsCount);
    await db.into(db.trails).insert(TrailsCompanion.insert(
          id: 't1',
          mountainId: 'mt1',
          name: 'Test Trail',
          geometryJson: points,
          minLat: Value(0.0),
          maxLat: Value(1.0), // Large bounds to ensure inclusion check passes
          minLng: Value(0.0),
          maxLng: Value(1.0),
        ));

    // 3. Create breadcrumbs (simulating backtracking)
    // We want the last breadcrumb (first in retrace) to be far, and eventually getting closer.
    // The points in trail are (0,0) -> (0.1, 0.1) roughly.
    // Let's make breadcrumbs start far away and move towards the trail.

    // User started at (0.2, 0.2) and walked to (0.3, 0.3).
    // So history (newest first) is at (0.3, 0.3) -> (0.2, 0.2).
    // Trail ends at approx (trailPointsCount * 0.0001, ...).
    // If count=1000, end is (0.1, 0.1).

    // We want the engine to scan some points before finding safety.
    // Or scan all and fail (worst case).

    // Let's simulate scanning all 200 points without success for worst case performance.
    // We want Newest (History Start) to be FAR, and Oldest (History End) to be SAFE.
    // So user walked from Safe -> Danger.
    DateTime startTime = DateTime.now().subtract(Duration(hours: 1));
    for (int i = 0; i < breadcrumbCount; i++) {
      // i=0: Oldest (Safe, 0.5)
      // i=199: Newest (Danger, 0.52)
      double lat = 0.5 + (i * 0.0001);

      await db.into(db.userBreadcrumbs).insert(UserBreadcrumbsCompanion.insert(
            sessionId: 'session1',
            lat: lat,
            lng: lat,
            accuracy: 5.0,
            timestamp: startTime.add(Duration(seconds: i * 10)),
          ));
    }
  }

  test('BacktrackEngine performance benchmark', () async {
    const trailPointsCount = 5000;
    const breadcrumbCount = 200;

    await seedData(trailPointsCount, breadcrumbCount);

    final trails = await db.select(db.trails).get();

    // Warmup
    await engine.getSafeRetracePath('session1', trails);

    final stopwatch = Stopwatch()..start();
    await engine.getSafeRetracePath('session1', trails);
    stopwatch.stop();

    print('Execution time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
