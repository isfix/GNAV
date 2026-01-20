import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/daos/daos.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';

List<TrailPoint> createHeavyGeometry(double startLat, double startLng, int pointsCount) {
  final points = <TrailPoint>[];
  for (int i = 0; i < pointsCount; i++) {
    points.add(TrailPoint(startLat + i * 0.00001, startLng + i * 0.00001, 1000.0));
  }
  return points;
}

void main() {
  late AppDatabase db;
  late NavigationDao navigationDao;
  late MountainDao mountainDao;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    navigationDao = NavigationDao(db);
    mountainDao = MountainDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('Benchmark: getNearbyTrails performance', () async {
    // 1. Setup Data
    const mountainId = 'mt_benchmark';
    await mountainDao.into(db.mountainRegions).insert(
      MountainRegionsCompanion.insert(
        id: mountainId,
        name: 'Benchmark Mountain',
        boundaryJson: '{}',
        lat: const Value(0.0),
        lng: const Value(0.0),
      ),
    );

    final trailsToAdd = <TrailsCompanion>[];

    // 100 Valid Trails (Inside 0.005 radius)
    // Placed at (0.001, 0.001). Dist ~0.0014 < 0.005.
    for (int i = 0; i < 100; i++) {
      trailsToAdd.add(TrailsCompanion.insert(
        id: 'valid_$i',
        mountainId: mountainId,
        name: 'Valid Trail $i',
        geometryJson: createHeavyGeometry(0.001, 0.001, 500),
        minLat: const Value(0.001),
        maxLat: const Value(0.002),
        minLng: const Value(0.001),
        maxLng: const Value(0.002),
      ));
    }

    // 1000 Corner Trails (Inside Square but Outside Circle)
    // Placed at (0.004, 0.004). Box [0.004, 0.005].
    // Square check: 0.004 <= 0 + 0.005 (True).
    // Circle check: Dist(0, 0, Box) = sqrt(0.004^2 + 0.004^2) = 0.00565 > 0.005.
    for (int i = 0; i < 1000; i++) {
      trailsToAdd.add(TrailsCompanion.insert(
        id: 'corner_$i',
        mountainId: mountainId,
        name: 'Corner Trail $i',
        geometryJson: createHeavyGeometry(0.004, 0.004, 500),
        minLat: const Value(0.004),
        maxLat: const Value(0.005),
        minLng: const Value(0.004),
        maxLng: const Value(0.005),
      ));
    }

    // 1000 Far Trails
    // Placed at (0.01, 0.01).
    for (int i = 0; i < 1000; i++) {
      trailsToAdd.add(TrailsCompanion.insert(
        id: 'far_$i',
        mountainId: mountainId,
        name: 'Far Trail $i',
        geometryJson: createHeavyGeometry(0.01, 0.01, 500),
        minLat: const Value(0.01),
        maxLat: const Value(0.011),
        minLng: const Value(0.01),
        maxLng: const Value(0.011),
      ));
    }

    await db.batch((batch) {
      batch.insertAll(db.trails, trailsToAdd);
    });

    // Warmup
    await navigationDao.getNearbyTrails(0.0, 0.0, buffer: 0.005);

    // Measure
    final stopwatch = Stopwatch()..start();
    const iterations = 10;
    int count = 0;
    for (int i = 0; i < iterations; i++) {
      final results = await navigationDao.getNearbyTrails(0.0, 0.0, buffer: 0.005);
      count += results.length;
    }
    stopwatch.stop();

    print('Benchmark: getNearbyTrails took ${stopwatch.elapsedMilliseconds} ms for $iterations iterations.');
    print('Average time: ${stopwatch.elapsedMilliseconds / iterations} ms');
    print('Total trails found: $count (Avg ${count / iterations})');
  });
}
