import 'dart:math' as math;
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../data/local/db/converters.dart';
import '../../../core/utils/geo_math.dart';
import '../../../data/local/db/app_database.dart'; // For Trail entity

enum SafetyStatus {
  safe, // < 20m
  warning, // 20m - 50m
  danger, // > 50m
}

class DeviationEngine {
  static const double thresholdSafe = 20.0;
  static const double thresholdWarning = 50.0;

  // Hysteresis State
  // We need to store the last N statuses.
  // In a Riverpod world, this state would live in the Notifier.
  // We will expose a helper class `DeviationMonitor` that holds this state.

  // 100m padding. If user is > 100m outside the entire trail box, skip entirely.
  static const double _boundsPadding = 0.001; // Approx 110m

  static double calculateMinDistance(LatLng userLoc, List<Trail> trails) {
    double minDistance = double.infinity;

    for (final trail in trails) {
      if (trail.geometryJson.isEmpty) continue;

      // 1. O(1) AABB Check using pre-calculated DB columns
      // Uses minLat/maxLat/minLng/maxLng stored in the Trail entity
      // This avoids expensive JSON parsing for trails the user is nowhere near
      if (!trail.bounds.contains(userLoc, padding: _boundsPadding)) {
        continue; // Skip this trail - user is outside bounding box
      }

      // 2. Detailed Segment Check (only runs for nearby trails)
      final points = trail.geometryJson;

      // Pre-calculate meters per degree for optimization
      const double metersPerLat = 111320.0;
      final double latRad = userLoc.latitude * math.pi / 180.0;
      final double metersPerLng = 111320.0 * math.cos(latRad);

      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];

        // Optimization: Bounding Box Check per segment
        // If minDistance is already found, we can skip segments that are definitely farther away.
        if (minDistance != double.infinity) {
          final double minLat = p1.lat < p2.lat ? p1.lat : p2.lat;
          final double maxLat = p1.lat > p2.lat ? p1.lat : p2.lat;
          double dLat = 0.0;
          if (userLoc.latitude < minLat) dLat = minLat - userLoc.latitude;
          else if (userLoc.latitude > maxLat) dLat = userLoc.latitude - maxLat;

          // Check latitude distance
          if (dLat * metersPerLat > minDistance) continue;

          final double minLng = p1.lng < p2.lng ? p1.lng : p2.lng;
          final double maxLng = p1.lng > p2.lng ? p1.lng : p2.lng;
          double dLng = 0.0;
          if (userLoc.longitude < minLng) dLng = minLng - userLoc.longitude;
          else if (userLoc.longitude > maxLng) dLng = userLoc.longitude - maxLng;

          // Check longitude distance
          if (dLng * metersPerLng > minDistance) continue;
        }

        // Use raw coordinates to avoid TrailPoint.toLatLng() allocation
        final dist = GeoMath.distanceToSegmentRaw(
            userLoc.latitude, userLoc.longitude,
            p1.lat, p1.lng,
            p2.lat, p2.lng);
        if (dist < minDistance) {
          minDistance = dist;
        }
      }
    }
    return minDistance;
  }

  static SafetyStatus determineStatus(double distanceMeters) {
    if (distanceMeters <= thresholdSafe) return SafetyStatus.safe;
    if (distanceMeters <= thresholdWarning) return SafetyStatus.warning;
    return SafetyStatus.danger;
  }
}

// -----------------------------------------------------------------------------
// HELPER: AABB (Axis Aligned Bounding Box)
// -----------------------------------------------------------------------------
class TrailBounds {
  final double minLat;
  final double maxLat;
  final double minLng;
  final double maxLng;

  TrailBounds(this.minLat, this.maxLat, this.minLng, this.maxLng);

  bool contains(LatLng point, {double padding = 0.0}) {
    return point.latitude >= (minLat - padding) &&
        point.latitude <= (maxLat + padding) &&
        point.longitude >= (minLng - padding) &&
        point.longitude <= (maxLng + padding);
  }
}

extension TrailBoundsExt on Trail {
  /// Uses pre-calculated bounds stored in the DB (minLat, maxLat, minLng, maxLng).
  /// This is O(1) and avoids parsing geometry JSON or iterating points.
  TrailBounds get bounds {
    return TrailBounds(minLat, maxLat, minLng, maxLng);
  }
}

// Stateful Monitor for Hysteresis
class DeviationMonitor {
  final List<SafetyStatus> _buffer = [];
  final int _bufferSize = 3;

  SafetyStatus _currentStatus = SafetyStatus.safe;
  SafetyStatus get currentStatus => _currentStatus;

  void addReading(double distanceMeters) {
    // 1. Determine raw status
    SafetyStatus raw;
    if (distanceMeters <= DeviationEngine.thresholdSafe) {
      raw = SafetyStatus.safe;
    } else if (distanceMeters <= DeviationEngine.thresholdWarning) {
      raw = SafetyStatus.warning;
    } else {
      raw = SafetyStatus.danger;
    }

    // 2. Add to buffer
    _buffer.add(raw);
    if (_buffer.length > _bufferSize) {
      _buffer.removeAt(0);
    }

    // 3. Hysteresis Logic
    // Only switch state if ALL readings in buffer match the new state
    // OR if we are escalating to Danger (Fail Safe - react fast to danger, react slow to safety)
    // Actually, "Fail Safe" means we should warn immediately, but safety return should be debounced.

    // Robust Logic:
    // If ANY reading in buffer is Danger -> Status is Danger (Immediate Warning)
    // If ALL readings are Safe -> Status is Safe (Debounced Recovery)
    // Else -> Warning.

    if (_buffer.contains(SafetyStatus.danger)) {
      _currentStatus = SafetyStatus.danger;
    } else if (_buffer.every((s) => s == SafetyStatus.safe)) {
      _currentStatus = SafetyStatus.safe;
    } else {
      // Mixed bag, usually means Warning trend or transition
      _currentStatus = SafetyStatus.warning;
    }
  }
}
