import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables.dart';
import '../daos/daos.dart';
import 'package:latlong2/latlong.dart';
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
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

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
