import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import '../daos/daos.dart';
import 'converters.dart';

part 'app_database.g.dart';
// Force Rebuild

@DriftDatabase(
  tables: [
    MountainRegions,
    Trails,
    PointsOfInterest,
    UserBreadcrumbs,
    OfflineMapPackages
  ],
  daos: [MountainDao, NavigationDao, TrackingDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Version 2: Added lat and lng to MountainRegions
          await m.addColumn(mountainRegions, mountainRegions.lat);
          await m.addColumn(mountainRegions, mountainRegions.lng);
        }
        if (from < 3) {
          await m.addColumn(pointsOfInterest, pointsOfInterest.name);
        }
        if (from < 4) {
          // Version 4: Added speed to UserBreadcrumbs
          await m.addColumn(userBreadcrumbs, userBreadcrumbs.speed);
        }
        if (from < 5) {
          // Version 5: Added OfflineMapPackages
          await m.createTable(offlineMapPackages);
        }
        if (from < 6) {
          // Version 6: Added Trail Metadata & Apex Index
          await m.addColumn(trails, trails.distance);
          await m.addColumn(trails, trails.elevationGain);
          // difficulty already existed but was not defaulted in previous versions,
          // essentially we are altering the valid columns.
          // Drift's addColumn is safe for new columns.
          // Note: difficulty was ALREADY in v1-5 but defined as integer().
          // In tables.dart I added default(1). This is metadata change only unless I add column.
          // Wait, previous code had `IntColumn get difficulty => integer()();`
          // So column EXISTS.

          await m.addColumn(trails, trails.summitIndex);
        }
        if (from < 7) {
          // Version 7: Added performance indexes
          await m.createIndex(trailsMountainIdx);
          await m.createIndex(poiMountainIdx);
          await m.createIndex(breadcrumbsSessionIdx);
          await m.createIndex(breadcrumbsSyncedIdx);
        }
        if (from < 8) {
          // Version 8: Added startLat and startLng to Trails
          await m.addColumn(trails, trails.startLat);
          await m.addColumn(trails, trails.startLng);
        }
        if (from < 9) {
          // Version 9: Added timestamp index for UserBreadcrumbs
          await m.createIndex(breadcrumbsTimestampIdx);
        }
      },
    );
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'pandu_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
