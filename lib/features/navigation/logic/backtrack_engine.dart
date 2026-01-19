import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:drift/drift.dart';
import '../../../data/local/db/app_database.dart';
import '../../../core/utils/geo_math.dart';
import 'deviation_engine.dart';

class BacktrackComputationData {
  final List<UserBreadcrumb> history;
  final List<Trail> trails;

  BacktrackComputationData(this.history, this.trails);
}

List<LatLng>? _findSafePathInIsolate(BacktrackComputationData data) {
  final retracePath = <LatLng>[];

  // 2. Scan backwards
  for (final breadcrumb in data.history) {
    final loc = LatLng(breadcrumb.lat, breadcrumb.lng);
    retracePath.add(loc);

    // Calculate dist to trails
    final dist = DeviationEngine.calculateMinDistance(loc, data.trails);

    // If Safe (< 20m), we found the entry point. Return the path up to here.
    if (dist <= DeviationEngine.thresholdSafe) {
      return retracePath; // Contains points from Danger -> ... -> Safe
    }
  }

  return null; // No safe point found in recent history
}

class BacktrackEngine {
  final AppDatabase db;

  BacktrackEngine(this.db);

  /// Analyzes the user's history to find the path back to Safety.
  /// Returns a list of points (Reverse Path) from Current -> Safety.
  /// Returns null if no safe point found in recent history.
  Future<List<LatLng>?> getSafeRetracePath(
      String sessionId, List<Trail> trails) async {
    // 1. Get recent breadcrumbs (reverse order: Newest First)
    // Limit to 200 points (~30 mins of hiking) to avoid scanning forever
    final history = await (db.select(db.userBreadcrumbs)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.timestamp, mode: OrderingMode.desc)
          ])
          ..limit(200))
        .get();

    if (history.isEmpty) return null;

    return compute(_findSafePathInIsolate, BacktrackComputationData(history, trails));
  }

  /// Calculates bearing from Start to End in Degrees (0-360)
  double calculateBearing(LatLng start, LatLng end) {
    return GeoMath.bearing(start, end);
  }
}
