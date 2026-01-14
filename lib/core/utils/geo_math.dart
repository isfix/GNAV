import 'dart:math';
import 'package:latlong2/latlong.dart';

class GeoMath {
  static const double earthRadiusMeters = 6371000.0;

  /// Calculates the Great Circle distance (Haversine) between two points in meters.
  static double distanceMeters(LatLng p1, LatLng p2) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Meter, p1, p2);
  }

  /// Calculates the perpendicular distance from Point P to the Line Segment defined by Start and End.
  /// If the projection falls outside the segment, returns distance to the nearest endpoint.
  static double distanceToSegment(LatLng p, LatLng start, LatLng end) {
    final double latP = _degToRad(p.latitude);
    final double lngP = _degToRad(p.longitude);
    final double latA = _degToRad(start.latitude);
    final double lngA = _degToRad(start.longitude);
    final double latB = _degToRad(end.latitude);
    final double lngB = _degToRad(end.longitude);

    // Convert to Cartesian (assuming simple spherical approximation for short range projection logic is 'good enough' 
    // but typically for geodetic cross track we use specific formulas. 
    // Here we use a simpler planar projection approximation for small segments (<100m) which is standard for performance
    // OR we use the cross-track error formula if we want great circle precision.
    // Given the hiking context (meters matter), we will use cross track error but we need to handle the "segment" bound.
    
    // Approach:
    // 1. Calculate distance from A to B.
    // 2. If 0, return distance P to A.
    // 3. Project P onto line AB to find parameter t.
    // 4. Clamp t to [0, 1].
    // 5. Find nearest point on segment.
    // 6. Calculate distance P to nearest point.

    // Using Cartesian approximation for projection factor 't' on small scales:
    double x = (lngB - lngA) * cos((latA + latB) / 2);
    double y = latB - latA;
    double lenSq = x * x + y * y;

    if (lenSq == 0) return distanceMeters(p, start);

    double rx = (lngP - lngA) * cos((latA + latB) / 2);
    double ry = latP - latA;

    double t = (rx * x + ry * y) / lenSq;

    if (t < 0) return distanceMeters(p, start);
    if (t > 1) return distanceMeters(p, end);

    // Closest point is 't' along the way
    // For precise distance, we can interpolate lat/lng or just take the cross track distance if we trust the line.
    // Let's re-calculate the point 'Closest' coordinate and do Haversine to it for max accuracy.
    double latClosest = start.latitude + (end.latitude - start.latitude) * t;
    double lngClosest = start.longitude + (end.longitude - start.longitude) * t;

    return distanceMeters(p, LatLng(latClosest, lngClosest));
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
}
