import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
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

  test('BacktrackEngine returns null when no history', () async {
    final trails = <Trail>[];
    final result = await engine.getSafeRetracePath('session1', trails);
    expect(result, isNull);
  });

  test('BacktrackEngine returns path when safe point is found', () async {
    // 1. Setup Trail (0,0) -> (0.1, 0.1)
    final points = generateTrailPoints(1000); // 1000 * 0.0001 = 0.1
    final trail = Trail(
      id: 't1',
      mountainId: 'm1',
      name: 'Test',
      geometryJson: points,
      distance: 1000,
      elevationGain: 0,
      difficulty: 1,
      summitIndex: 0,
      minLat: 0,
      maxLat: 0.1,
      minLng: 0,
      maxLng: 0.1,
      isOfficial: true,
    );
    await db.into(db.trails).insert(trail);

    // 2. Setup History
    // Oldest (Safe): (0.05, 0.05) - On trail
    // Newest (Danger): (0.2, 0.2) - Far away

    final now = DateTime.now();

    // Insert Safe point (Oldest)
    await db.into(db.userBreadcrumbs).insert(UserBreadcrumbsCompanion.insert(
      sessionId: 'session1',
      lat: 0.05,
      lng: 0.05,
      accuracy: 5,
      timestamp: now.subtract(const Duration(minutes: 10)),
    ));

    // Insert Middle point (Warning/Danger)
    await db.into(db.userBreadcrumbs).insert(UserBreadcrumbsCompanion.insert(
      sessionId: 'session1',
      lat: 0.15,
      lng: 0.15,
      accuracy: 5,
      timestamp: now.subtract(const Duration(minutes: 5)),
    ));

    // Insert Danger point (Newest)
    await db.into(db.userBreadcrumbs).insert(UserBreadcrumbsCompanion.insert(
      sessionId: 'session1',
      lat: 0.2,
      lng: 0.2,
      accuracy: 5,
      timestamp: now,
    ));

    // 3. Execute
    final result = await engine.getSafeRetracePath('session1', [trail]);

    // 4. Verify
    expect(result, isNotNull);
    // Should contain points from Newest -> Safe
    // Expected: (0.2, 0.2), (0.15, 0.15), (0.05, 0.05)
    expect(result!.length, 3);
    expect(result.first.latitude, closeTo(0.2, 0.0001)); // Newest
    expect(result.last.latitude, closeTo(0.05, 0.0001)); // Safe
  });

  test('BacktrackEngine returns null when no safe point found', () async {
    // 1. Setup Trail
    final points = generateTrailPoints(10); // (0,0) to (0.001, 0.001)
    final trail = Trail(
      id: 't1',
      mountainId: 'm1',
      name: 'Test',
      geometryJson: points,
      distance: 100,
      elevationGain: 0,
      difficulty: 1,
      summitIndex: 0,
      minLat: 0,
      maxLat: 0.001,
      minLng: 0,
      maxLng: 0.001,
      isOfficial: true,
    );
    await db.into(db.trails).insert(trail);

    // 2. Setup History (All far away)
    final now = DateTime.now();
    await db.into(db.userBreadcrumbs).insert(UserBreadcrumbsCompanion.insert(
      sessionId: 'session1',
      lat: 0.5,
      lng: 0.5,
      accuracy: 5,
      timestamp: now,
    ));

    // 3. Execute
    final result = await engine.getSafeRetracePath('session1', [trail]);

    // 4. Verify
    expect(result, isNull);
  });
}
