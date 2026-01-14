import 'package:latlong2/latlong.dart';
import 'package:drift/drift.dart';
import '../../../data/local/db/app_database.dart';
import 'deviation_engine.dart';

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

    final retracePath = <LatLng>[];

    // 2. Scan backwards
    for (final breadcrumb in history) {
      final loc = LatLng(breadcrumb.lat, breadcrumb.lng);
      retracePath.add(loc);

      // Calculate dist to trails
      final dist = DeviationEngine.calculateMinDistance(loc, trails);

      // If Safe (< 20m), we found the entry point. Return the path up to here.
      if (dist <= DeviationEngine.thresholdSafe) {
        return retracePath; // Contains points from Danger -> ... -> Safe
      }
    }

    return null; // No safe point found in recent history
  }

  /// Calculates bearing from Start to End in Degrees (0-360)
  double calculateBearing(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.bearing(start, end);
  }
}
