import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/daos/daos.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';

List<TrailPoint> createTrailPoints(double startLat, double startLng, int pointsCount) {
  final points = <TrailPoint>[];
  for (int i = 0; i < pointsCount; i++) {
    points.add(TrailPoint(startLat + i * 0.0001, startLng + i * 0.0001, 1000.0));
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

  test('Benchmark: trail_scan_benchmark - getTrailForBasecamp', () async {
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

    // Basecamp at (0, 0)
    const basecampId = 'bc_benchmark';
    const basecampLat = 0.0;
    const basecampLng = 0.0;

    await navigationDao.into(db.pointsOfInterest).insert(
      PointsOfInterestCompanion.insert(
        id: basecampId,
        mountainId: mountainId,
        type: PoiType.basecamp,
        lat: basecampLat,
        lng: basecampLng,
        name: const Value('Benchmark Basecamp'),
      ),
    );

    final basecamp = await navigationDao.getPoiById(basecampId);
    expect(basecamp, isNotNull);

    // 2. Insert Trails
    // Winner trail at (0, 0)
    await navigationDao.insertTrail(
      TrailsCompanion.insert(
        id: 'trail_winner',
        mountainId: mountainId,
        name: 'Winner Trail',
        geometryJson: createTrailPoints(0.0, 0.0, 10), // Starts at (0,0)
        minLat: const Value(0.0),
        maxLat: const Value(0.001),
        minLng: const Value(0.0),
        maxLng: const Value(0.001),
        startLat: const Value(0.0),
        startLng: const Value(0.0),
      )
    );

    // Noise trails
    // Positioned at (0.005, 0.005)
    // Distance from (0,0): sqrt(0.005^2 + 0.005^2) approx 0.007 degrees.
    // 0.007 deg * 111km ~ 770 meters.
    // Buffer is 0.006 deg.
    // Logic: minLat <= lat + buffer => 0.005 <= 0 + 0.006 (True)
    // So these trails ARE fetched by the bounding box query.
    // But distance is ~770m > 500m threshold.
    // So they should be rejected by the loop.

    const int noiseTrailsCount = 2000;
    final noiseTrails = <TrailsCompanion>[];
    for (int i = 0; i < noiseTrailsCount; i++) {
        final startLat = 0.005;
        final startLng = 0.005;

        noiseTrails.add(TrailsCompanion.insert(
          id: 'trail_noise_$i',
          mountainId: mountainId,
          name: 'Noise Trail $i',
          geometryJson: createTrailPoints(startLat, startLng, 500), // Larger geometry to simulate load
          minLat: Value(startLat),
          maxLat: Value(startLat + 0.01),
          minLng: Value(startLng),
          maxLng: Value(startLng + 0.01),
          startLat: Value(startLat),
          startLng: Value(startLng),
        ));
    }

    await db.batch((batch) {
      batch.insertAll(db.trails, noiseTrails);
    });

    // 3. Measure Execution Time
    final stopwatch = Stopwatch()..start();
    final result = await navigationDao.getTrailForBasecamp(basecamp!);
    stopwatch.stop();

    print('Benchmark: getTrailForBasecamp took ${stopwatch.elapsedMilliseconds} ms for ${noiseTrailsCount + 1} trails');

    expect(result, isNotNull);
    expect(result!.id, 'trail_winner');
  });
}
