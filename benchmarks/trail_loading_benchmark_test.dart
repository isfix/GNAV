import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Trail loading benchmark: Fetch all vs Fetch one', () async {
    // 0. Disable FKs or insert dependency
    await db.into(db.mountainRegions).insert(MountainRegionsCompanion.insert(
      id: 'mt_1',
      name: 'Mount Test',
      boundaryJson: '[]',
    ));

    // 1. Seed Data
    print('Seeding database with 100 trails...');
    final trailsToInsert = <TrailsCompanion>[];

    // Create a large geometry (1000 points)
    final largeGeometry = List.generate(
      1000,
      (index) => TrailPoint(0.0 + index * 0.0001, 110.0 + index * 0.0001, 100.0)
    );

    for (int i = 0; i < 100; i++) {
      trailsToInsert.add(TrailsCompanion.insert(
        id: 'trail_$i',
        mountainId: 'mt_1',
        name: 'Trail $i',
        geometryJson: largeGeometry,
        distance: const drift.Value(1000),
        elevationGain: const drift.Value(500),
        difficulty: const drift.Value(1),
        summitIndex: const drift.Value(0),
        minLat: const drift.Value(0.0),
        maxLat: const drift.Value(1.0),
        minLng: const drift.Value(110.0),
        maxLng: const drift.Value(111.0),
      ));
    }

    await db.batch((batch) {
      batch.insertAll(db.trails, trailsToInsert);
    });

    print('Seeding complete.');

    // 2. Benchmark Current Approach
    final stopwatch = Stopwatch()..start();

    // Simulate what offline_map_screen does:
    // Fetch all trails for the mountain, then find the one we want.
    final trails = await db.navigationDao.getTrailsForMountain('mt_1');
    final selectedTrail = trails.where((t) => t.id == 'trail_50').firstOrNull;

    stopwatch.stop();
    print('Current Approach (Fetch All + Filter): ${stopwatch.elapsedMilliseconds}ms');

    expect(selectedTrail, isNotNull);
    expect(selectedTrail!.id, 'trail_50');
    expect(trails.length, 100);

    // 3. Benchmark New Approach
    stopwatch.reset();
    stopwatch.start();

    // Use specific query
    final optimizedTrail = await db.navigationDao.getTrailById('trail_50');

    stopwatch.stop();
    print('New Approach (Fetch One by ID): ${stopwatch.elapsedMilliseconds}ms');

    expect(optimizedTrail, isNotNull);
    expect(optimizedTrail!.id, 'trail_50');
  });
}
