import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';
import 'package:pandu_navigation/features/navigation/logic/navigation_providers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('activeTrailsProvider fetches trails from DAO', () async {
    // 1. Seed DB
    const mountainId = 'mt_test';
    await db.into(db.mountainRegions).insert(MountainRegionsCompanion.insert(
      id: mountainId,
      name: 'Test Mountain',
      boundaryJson: '[]',
    ));

    await db.into(db.trails).insert(TrailsCompanion.insert(
      id: 'trail_1',
      mountainId: mountainId,
      name: 'Test Trail',
      geometryJson: [], // Empty geometry
    ));

    // 2. Setup Container with overrides
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
      ],
    );

    // 3. Read Provider
    final trails = await container.read(activeTrailsProvider(mountainId).future);

    // 4. Verify
    expect(trails.length, 1);
    expect(trails.first.id, 'trail_1');
    expect(trails.first.name, 'Test Trail');
  });
}
