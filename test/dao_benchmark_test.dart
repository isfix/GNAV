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

  test('Benchmark getTrailForBasecamp', () async {
    // 1. Setup Data
    const mountainId = 'mt_merbabu';
    await mountainDao.into(db.mountainRegions).insert(
      MountainRegionsCompanion.insert(
        id: mountainId,
        name: 'Merbabu',
        boundaryJson: '{}',
        lat: const Value(-7.45),
        lng: const Value(110.43),
      ),
    );

    // Basecamp at specific location
    const basecampId = 'bc_wekas';
    const basecampLat = -7.430;
    const basecampLng = 110.420;

    await navigationDao.into(db.pointsOfInterest).insert(
      PointsOfInterestCompanion.insert(
        id: basecampId,
        mountainId: mountainId,
        type: PoiType.basecamp,
        lat: basecampLat,
        lng: basecampLng,
        name: const Value('Wekas Basecamp'),
      ),
    );

    final basecamp = await navigationDao.getPoiById(basecampId);
    expect(basecamp, isNotNull);

    // Insert 1000 trails
    const int totalTrails = 1000;

    // Nearest trail
    await navigationDao.insertTrail(
      TrailsCompanion.insert(
        id: 'trail_near',
        mountainId: mountainId,
        name: 'Near Trail',
        geometryJson: createTrailPoints(basecampLat, basecampLng, 10),
        minLat: Value(basecampLat),
        maxLat: Value(basecampLat + 0.001),
        minLng: Value(basecampLng),
        maxLng: Value(basecampLng + 0.001),
      )
    );

    // Far trails
    final farTrails = <TrailsCompanion>[];
    for (int i = 0; i < totalTrails - 1; i++) {
        // Positioned 1 degree away (~111km)
        final lat = basecampLat + 1.0 + (i * 0.0001);
        final lng = basecampLng + 1.0 + (i * 0.0001);

        farTrails.add(TrailsCompanion.insert(
          id: 'trail_far_$i',
          mountainId: mountainId,
          name: 'Far Trail $i',
          geometryJson: createTrailPoints(lat, lng, 100),
          minLat: Value(lat),
          maxLat: Value(lat + 0.01),
          minLng: Value(lng),
          maxLng: Value(lng + 0.01),
        ));
    }

    // Batch insert
    await db.batch((batch) {
      batch.insertAll(db.trails, farTrails);
    });

    // 2. Measure Execution Time
    final stopwatch = Stopwatch()..start();
    final result = await navigationDao.getTrailForBasecamp(basecamp!);
    stopwatch.stop();

    print('Benchmark: getTrailForBasecamp took ${stopwatch.elapsedMilliseconds} ms for $totalTrails trails');

    expect(result, isNotNull);
    expect(result!.id, 'trail_near');
  });
}
