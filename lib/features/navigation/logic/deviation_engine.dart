import 'package:latlong2/latlong.dart';
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

      // 1. AABB Check (Optimization)
      // We calculate bounds on the fly. In production, this should be cached in the specific Trail object extension.
      final bounds = trail.bounds;
      if (!bounds.contains(userLoc, padding: _boundsPadding)) {
        continue; // Skip this trail, it's too far away.
      }

      // 2. Detailed Segment Check
      // Cast to handle stale generated code
      final points = (trail.geometryJson as List).cast<TrailPoint>();
      for (int i = 0; i < points.length - 1; i++) {
        final p1 = points[i];
        final p2 = points[i + 1];
        final dist =
            GeoMath.distanceToSegment(userLoc, p1.toLatLng(), p2.toLatLng());
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
  /// Simple caching could be added here using Expando if needed,
  /// but for now we calculate on fly (O(N) single pass is cheap compared to N*GeoDistance).
  /// To purely optimize, we should store bounds in DB or transient property.
  TrailBounds get bounds {
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    final points = (geometryJson as List).cast<TrailPoint>();
    for (final pt in points) {
      if (pt.lat < minLat) minLat = pt.lat;
      if (pt.lat > maxLat) maxLat = pt.lat;
      if (pt.lng < minLng) minLng = pt.lng;
      if (pt.lng > maxLng) maxLng = pt.lng;
    }
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
