import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sunrise_sunset_calc/sunrise_sunset_calc.dart';
import '../../../core/utils/geo_math.dart';

class EtaEngine {
  // Naismith's Rule:
  // 1 hour for every 5 km horizontal.
  // 1 hour for every 600 m of ascent.

  static const double _speedKmPerHour = 4.0;
  static const double _ascentMetersPerHour = 600.0;

  static Duration calculateEta(
      LatLng userLoc, double userAlt, LatLng targetLoc, double targetAlt) {
    // 1. Horizontal Distance (using GeoMath Haversine)
    final distMeters = GeoMath.distanceMeters(userLoc, targetLoc);
    final distKm = distMeters / 1000.0;

    // 2. Vertical Ascent (Only positive gain matters for effort)
    double ascent = targetAlt - userAlt;
    if (ascent < 0) ascent = 0; // Downhill is "free" in Naismith (simplified)

    // 3. Time Calculation
    final timeHoursFlat = distKm / _speedKmPerHour;
    final timeHoursVert = ascent / _ascentMetersPerHour;

    final totalHours = timeHoursFlat + timeHoursVert;

    // Sanity Check: If distance is absurd (> 100km) or ETA > 24h, return cap
    if (totalHours > 24) {
      return const Duration(hours: 24);
    }

    return Duration(minutes: (totalHours * 60).round());
  }

  /// Returns true if arrivalTime is AFTER sunset
  static bool checkDaylightStatus(LatLng location, Duration eta) {
    // 1. Calculate Sunset
    final result = getSunriseSunset(
        location.latitude,
        location.longitude,
        const Duration(hours: 7), // WIB Timezone for Indonesia Context
        DateTime.now());
    final sunset = result.sunset;

    // 2. Calculate Arrival Time
    final arrivalTime = DateTime.now().add(eta);

    // 3. Compare
    return arrivalTime.isAfter(sunset);
  }

  static String formatDuration(Duration d) {
    if (d >= const Duration(hours: 24)) return "> 24h";
    if (d.inHours > 0) {
      return "${d.inHours}h ${d.inMinutes % 60}m";
    }
    return "${d.inMinutes}m";
  }
}
