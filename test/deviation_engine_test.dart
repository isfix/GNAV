import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pandu_navigation/features/navigation/logic/deviation_engine.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';

void main() {
  group('DeviationEngine Tests', () {
    test('calculateMinDistance returns correct distance for user on segment', () {
      final points = [
        TrailPoint(0, 0, 0),
        TrailPoint(0, 10, 0),
      ];
      final trail = Trail(
        id: '1',
        mountainId: 'm1',
        name: 't1',
        geometryJson: points,
        distance: 1000,
        elevationGain: 0,
        difficulty: 1,
        summitIndex: 1,
        minLat: -1,
        maxLat: 1,
        minLng: -1,
        maxLng: 11,
        isOfficial: true,
      );

      final userLoc = LatLng(0, 5); // Directly on the line
      final dist = DeviationEngine.calculateMinDistance(userLoc, [trail]);

      expect(dist, closeTo(0, 0.1));
    });

    test('calculateMinDistance returns correct distance for user off segment', () {
      // 1 degree lat is approx 111,111 meters
      final points = [
        TrailPoint(0, 0, 0),
        TrailPoint(0, 10, 0),
      ];
      final trail = Trail(
        id: '1',
        mountainId: 'm1',
        name: 't1',
        geometryJson: points,
        distance: 1000,
        elevationGain: 0,
        difficulty: 1,
        summitIndex: 1,
        minLat: -1,
        maxLat: 1,
        minLng: -1,
        maxLng: 11,
        isOfficial: true,
      );

      final userLoc = LatLng(0.001, 5); // Approx 111m north of line
      final dist = DeviationEngine.calculateMinDistance(userLoc, [trail]);

      // 0.001 degrees * 111111 meters/degree ~= 111.111 meters
      expect(dist, closeTo(111.19, 1.0)); // Adjusted for slight variation
    });

    test('calculateMinDistance skips trails outside bounds', () {
      final points = [
        TrailPoint(10, 10, 0),
        TrailPoint(10, 20, 0),
      ];
      final trail = Trail(
        id: '1',
        mountainId: 'm1',
        name: 't1',
        geometryJson: points,
        distance: 1000,
        elevationGain: 0,
        difficulty: 1,
        summitIndex: 1,
        minLat: 10,
        maxLat: 10,
        minLng: 10,
        maxLng: 20,
        isOfficial: true,
      );

      final userLoc = LatLng(0, 0); // Far away
      // calculateMinDistance returns infinity if no trails are nearby/valid
      final dist = DeviationEngine.calculateMinDistance(userLoc, [trail]);

      expect(dist, double.infinity);
    });

    test('calculateMinDistance selects closest segment', () {
      final points = [
        TrailPoint(0, 0, 0),
        TrailPoint(0, 10, 0), // Segment 1
        TrailPoint(1, 10, 0), // Segment 2
      ];
      final trail = Trail(
        id: '1',
        mountainId: 'm1',
        name: 't1',
        geometryJson: points,
        distance: 1000,
        elevationGain: 0,
        difficulty: 1,
        summitIndex: 1,
        minLat: -1,
        maxLat: 2,
        minLng: -1,
        maxLng: 11,
        isOfficial: true,
      );

      // User is closer to Segment 2
      final userLoc = LatLng(1.001, 10);
      // Distance to (1, 10) is 0.001 deg lat ~= 111m

      final dist = DeviationEngine.calculateMinDistance(userLoc, [trail]);

      expect(dist, closeTo(111.19, 1.0));
    });
  });
}
