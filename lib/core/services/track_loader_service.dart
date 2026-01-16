import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:gpx/gpx.dart';
import 'package:drift/drift.dart' as drift;
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/converters.dart';
import '../utils/geo_math.dart';

class TrackLoaderService {
  final AppDatabase _db;

  TrackLoaderService(this._db);

  /// Loads a GPX file from assets, processes it, and saves it to the DB.
  Future<void> loadGpxTrack(String assetPath, String mountainId, String trailId,
      String trailName) async {
    try {
      // 1. Read & Parse
      final xmlString = await rootBundle.loadString(assetPath);
      final gpx = GpxReader().fromString(xmlString);

      if (gpx.trks.isEmpty) {
        throw Exception("No tracks found in GPX file");
      }

      final trk = gpx.trks.first;
      final seg = trk.trksegs.first;
      final points = seg.trkpts;

      if (points.isEmpty) return;

      // 2. Apex Detection & Stats
      double totalDist = 0;
      double elevationGain = 0;
      double maxElevation = -double.infinity;
      int summitIndex = 0;

      final dbPoints = <TrailPoint>[];

      for (int i = 0; i < points.length; i++) {
        final p = points[i];
        final ele = p.ele ?? 0.0;

        // Convert to strictly typed TrailPoint for our DB
        dbPoints.add(TrailPoint(p.lat ?? 0, p.lon ?? 0, ele));

        // Detect Apex
        if (ele > maxElevation) {
          maxElevation = ele;
          summitIndex = i;
        }

        // Stats
        if (i > 0) {
          final prev = points[i - 1];
          final d = GeoMath.distanceMeters(LatLng(prev.lat ?? 0, prev.lon ?? 0),
              LatLng(p.lat ?? 0, p.lon ?? 0));
          totalDist += d;

          final dEle = ele - (prev.ele ?? 0);
          if (dEle > 0) {
            elevationGain += dEle;
          }
        }
      }

      // 3. Save to DB
      final trailEntry = TrailsCompanion(
        id: drift.Value(trailId),
        mountainId: drift.Value(mountainId),
        name: drift.Value(trailName),
        geometryJson:
            drift.Value(dbPoints), // Converter handles List<TrailPoint> to JSON
        difficulty:
            const drift.Value(3), // Default difficulty, logic could be smarter
        distance: drift.Value(totalDist),
        elevationGain: drift.Value(elevationGain),
        summitIndex: drift.Value(summitIndex),
        isOfficial: const drift.Value(true),
      );

      await _db.navigationDao.insertTrail(trailEntry);
    } catch (e) {
      // Re-throw or log
      print("Error loading GPX: $e");
      rethrow;
    }
  }
}
