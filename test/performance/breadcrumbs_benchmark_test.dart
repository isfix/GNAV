import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/daos/daos.dart';

void main() {
  late AppDatabase db;
  late TrackingDao trackingDao;

  setUp(() async {
    // Use a file-based database to enable index usage
    final file = File('benchmark_breadcrumbs.db');
    if (await file.exists()) {
      await file.delete();
    }
    db = AppDatabase(NativeDatabase(file));
    trackingDao = TrackingDao(db);
  });

  tearDown(() async {
    await db.close();
    final file = File('benchmark_breadcrumbs.db');
    if (await file.exists()) {
      await file.delete();
    }
  });

  test('Benchmark cleanOldData performance', () async {
    // 1. Seed Data
    // We want a significant number of rows to make the index useful.
    // Let's say 20,000 rows.
    const totalRows = 20000;
    const batchSize = 1000;

    // 20% old data (to be deleted)
    final oldCutoff = DateTime.now().subtract(const Duration(days: 31));
    final recentDate = DateTime.now();

    print('Seeding $totalRows breadcrumbs...');

    for (int i = 0; i < totalRows; i += batchSize) {
      final batch = <UserBreadcrumbsCompanion>[];
      for (int j = 0; j < batchSize; j++) {
        final isOld = (i + j) < (totalRows * 0.2); // First 20% are old
        final timestamp = isOld
            ? oldCutoff.subtract(Duration(minutes: j))
            : recentDate.subtract(Duration(minutes: j));

        batch.add(UserBreadcrumbsCompanion.insert(
          sessionId: 'session_${(i+j) % 100}', // Distribute across sessions
          lat: -7.0,
          lng: 110.0,
          accuracy: 5.0,
          timestamp: timestamp,
          speed: const Value(1.5),
        ));
      }
      await trackingDao.insertBreadcrumbs(batch);
    }

    print('Seeding complete.');

    // 2. Measure Query/Delete Time
    final stopwatch = Stopwatch()..start();
    await trackingDao.cleanOldData();
    stopwatch.stop();

    print('Benchmark: cleanOldData took ${stopwatch.elapsedMilliseconds} ms');

    // Verify deletion
    final remaining = await db.select(db.userBreadcrumbs).get();
    expect(remaining.length, (totalRows * 0.8).round());
  });
}
