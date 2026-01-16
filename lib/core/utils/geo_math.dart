import 'dart:math';
import 'package:maplibre_gl/maplibre_gl.dart';

class GeoMath {
  static const double earthRadiusMeters = 6371000.0;

  /// Calculates the Great Circle distance (Haversine) between two points in meters.
  static double distanceMeters(LatLng p1, LatLng p2) {
    final lat1 = _degToRad(p1.latitude);
    final lat2 = _degToRad(p2.latitude);
    final dLat = _degToRad(p2.latitude - p1.latitude);
    final dLon = _degToRad(p2.longitude - p1.longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
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

    // Using Cartesian approximation for projection factor 't' on small scales
    double x = (lngB - lngA) * cos((latA + latB) / 2);
    double y = latB - latA;
    double lenSq = x * x + y * y;

    if (lenSq == 0) return distanceMeters(p, start);

    double rx = (lngP - lngA) * cos((latA + latB) / 2);
    double ry = latP - latA;

    double t = (rx * x + ry * y) / lenSq;

    if (t < 0) return distanceMeters(p, start);
    if (t > 1) return distanceMeters(p, end);

    double latClosest = start.latitude + (end.latitude - start.latitude) * t;
    double lngClosest = start.longitude + (end.longitude - start.longitude) * t;

    return distanceMeters(p, LatLng(latClosest, lngClosest));
  }

  /// Calculates bearing from p1 to p2 in degrees (0-360)
  static double bearing(LatLng p1, LatLng p2) {
    final lat1 = _degToRad(p1.latitude);
    final lat2 = _degToRad(p2.latitude);
    final dLon = _degToRad(p2.longitude - p1.longitude);

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final theta = atan2(y, x);

    return (_radToDeg(theta) + 360) % 360;
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
  static double _radToDeg(double rad) => rad * 180.0 / pi;
}
