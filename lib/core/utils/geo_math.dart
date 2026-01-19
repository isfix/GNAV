import 'dart:math';
import 'package:maplibre_gl/maplibre_gl.dart';

class GeoMath {
  static const double earthRadiusMeters = 6371000.0;

  /// Calculates the Great Circle distance (Haversine) between two points in meters.
  static double distanceMeters(LatLng p1, LatLng p2) {
    return distanceMetersRaw(p1.latitude, p1.longitude, p2.latitude, p2.longitude);
  }

  /// Calculates the Great Circle distance (Haversine) between two coordinates in meters.
  /// Optimized to avoid object allocation.
  static double distanceMetersRaw(double lat1, double lng1, double lat2, double lng2) {
    final phi1 = _degToRad(lat1);
    final phi2 = _degToRad(lat2);
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lng2 - lng1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(phi1) * cos(phi2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusMeters * c;
  }

  /// Calculates the perpendicular distance from Point P to the Line Segment defined by Start and End.
  /// If the projection falls outside the segment, returns distance to the nearest endpoint.
  static double distanceToSegment(LatLng p, LatLng start, LatLng end) {
    return distanceToSegmentRaw(
        p.latitude, p.longitude, start.latitude, start.longitude, end.latitude, end.longitude);
  }

  /// Calculates the perpendicular distance from Point P to the Line Segment defined by Start and End.
  /// Optimized to avoid object allocation.
  static double distanceToSegmentRaw(
      double latP, double lngP, double latA, double lngA, double latB, double lngB) {
    final double rLatP = _degToRad(latP);
    final double rLngP = _degToRad(lngP);
    final double rLatA = _degToRad(latA);
    final double rLngA = _degToRad(lngA);
    final double rLatB = _degToRad(latB);
    final double rLngB = _degToRad(lngB);

    // Using Cartesian approximation for projection factor 't' on small scales
    double x = (rLngB - rLngA) * cos((rLatA + rLatB) / 2);
    double y = rLatB - rLatA;
    double lenSq = x * x + y * y;

    if (lenSq == 0) return distanceMetersRaw(latP, lngP, latA, lngA);

    double rx = (rLngP - rLngA) * cos((rLatA + rLatB) / 2);
    double ry = rLatP - rLatA;

    double t = (rx * x + ry * y) / lenSq;

    if (t < 0) return distanceMetersRaw(latP, lngP, latA, lngA);
    if (t > 1) return distanceMetersRaw(latP, lngP, latB, lngB);

    // Note: t is calculated in projected space, applying it to lat/lng degrees works for small distances
    // (Cartesian approximation) which is consistent with the original implementation.
    double latClosest = latA + (latB - latA) * t;
    double lngClosest = lngA + (lngB - lngA) * t;

    return distanceMetersRaw(latP, lngP, latClosest, lngClosest);
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
