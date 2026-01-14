import 'dart:io';
import 'package:drift/drift.dart';
import '../../../data/local/db/app_database.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class MapPackageManager {
  final AppDatabase db;

  MapPackageManager(this.db);

  /// Checks if the vector file for a region exists locally.
  /// Updates the database status accordingly.
  Future<bool> checkPackageAvailability(String regionId) async {
    final docDir = await getApplicationDocumentsDirectory();
    final filename = '$regionId.mbtiles';
    final filePath = p.join(docDir.path, 'maps', filename);
    final file = File(filePath);

    final exists = await file.exists();

    // Upsert status
    await db.into(db.offlineMapPackages).insertOnConflictUpdate(
          OfflineMapPackagesCompanion(
            regionId: Value(regionId),
            filePath: Value(filePath),
            isVector: const Value(true),
            status: Value(exists ? 2 : 0), // 2=Ready, 0=Missing
            lastUpdated: Value(DateTime.now()),
            sizeBytes: Value(exists ? await file.length() : 0),
          ),
        );

    return exists;
  }

  Future<String?> getVectorFilePath(String regionId) async {
    final record = await (db.select(db.offlineMapPackages)
          ..where((t) => t.regionId.equals(regionId)))
        .getSingleOrNull();

    if (record != null && record.status == 2) {
      return record.filePath;
    }
    return null;
  }
}
