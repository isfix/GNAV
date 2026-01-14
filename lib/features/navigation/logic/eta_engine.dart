import 'package:latlong2/latlong.dart';

class EtaEngine {
  // Naismith's Rule:
  // 1 hour for every 5 km horizontal.
  // 1 hour for every 600 m of ascent.

  static const double _speedKmPerHour =
      4.0; // Average hiking speed (slightly slower than flat 5km/h)
  static const double _ascentMetersPerHour = 600.0;

  static Duration calculateEta(
      LatLng userLoc, double userAlt, LatLng targetLoc, double targetAlt) {
    // 1. Horizontal Distance
    final distMeters =
        const Distance().as(LengthUnit.Meter, userLoc, targetLoc);
    final distKm = distMeters / 1000.0;

    // 2. Vertical Ascent (Only positive gain matters for effort)
    double ascent = targetAlt - userAlt;
    if (ascent < 0) ascent = 0; // Downhill is "free" in Naismith (simplified)

    // 3. Time Calculation
    final timeHoursFlat = distKm / _speedKmPerHour;
    final timeHoursVert = ascent / _ascentMetersPerHour;

    final totalHours = timeHoursFlat + timeHoursVert;

    return Duration(minutes: (totalHours * 60).round());
  }

  static String formatDuration(Duration d) {
    if (d.inHours > 0) {
      return "${d.inHours}h ${d.inMinutes % 60}m";
    }
    return "${d.inMinutes}m";
  }
}
