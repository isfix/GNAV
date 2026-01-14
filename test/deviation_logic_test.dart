import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:pandu_navigation/core/utils/geo_math.dart';
import 'package:pandu_navigation/features/navigation/logic/deviation_engine.dart';

// Mock Trail Class if needed, or use simple Logic testing
// Since we can't import AppDatabase generated code easily in raw tests without generation, 
// we will test the Math and Engine logic with mock data structures or just the math functions.

void main() {
  group('GeoMath Tests', () {
    test('Haversine Distance', () {
      const p1 = LatLng(0, 0);
      const p2 = LatLng(0, 1); // ~111km
      final dist = GeoMath.distanceMeters(p1, p2);
      expect(dist, closeTo(111195, 500)); // Approx 111.19 km
    });

    test('Distance To Segment (Point On Line)', () {
      const start = LatLng(0, 0);
      const end = LatLng(0, 10);
      const p = LatLng(0, 5); // Middleware
      final dist = GeoMath.distanceToSegment(p, start, end);
      expect(dist, closeTo(0, 0.1));
    });

    test('Distance To Segment (Point Off Line)', () {
      const start = LatLng(0, 0);
      const end = LatLng(0, 0.001); // Small segment Vertical
      const p = LatLng(0.001, 0.0005); // To the side
      // 0.001 degrees lat is approx 111m
      final dist = GeoMath.distanceToSegment(p, start, end);
      expect(dist, greaterThan(100)); 
    });
  });

  group('DeviationEngine Tests', () {
    test('Status Determination', () {
      expect(DeviationEngine.determineStatus(10), SafetyStatus.safe);
      expect(DeviationEngine.determineStatus(30), SafetyStatus.warning);
      expect(DeviationEngine.determineStatus(60), SafetyStatus.danger);
    });
  });
}
