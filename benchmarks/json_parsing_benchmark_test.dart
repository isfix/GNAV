import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';

// Copy of the logic to benchmark
Trail parseNativeTrail(dynamic rawJson) {
    final Map<String, dynamic> json =
        (rawJson is String) ? jsonDecode(rawJson) : rawJson;

    List<TrailPoint> geometry = [];
    if (json['geometryJson'] != null) {
      try {
        final List<dynamic> rawPoints = jsonDecode(json['geometryJson']);
        geometry = rawPoints.map((p) {
          final lat = (p[1] as num).toDouble();
          final lng = (p[0] as num).toDouble();
          final ele = (p.length > 2 ? (p[2] as num).toDouble() : 0.0);
          return TrailPoint(lat, lng, ele);
        }).toList();
      } catch (e) {
        print("Error parsing geometry: $e");
      }
    }

    return Trail(
      id: json['id'],
      mountainId: json['mountainId'],
      name: json['name'],
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      elevationGain: (json['elevationGain'] as num?)?.toDouble() ?? 0.0,
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      geometryJson: geometry,
      minLat: (json['minLat'] as num?)?.toDouble() ?? 0,
      maxLat: (json['maxLat'] as num?)?.toDouble() ?? 0,
      minLng: (json['minLng'] as num?)?.toDouble() ?? 0,
      maxLng: (json['maxLng'] as num?)?.toDouble() ?? 0,
      isOfficial: true,
      summitIndex: 0,
    );
}

void main() {
  test('JSON Parsing Benchmark', () {
    // Generate large JSON
    const numTrails = 50;
    const pointsPerTrail = 2000;

    final List<Map<String, dynamic>> trails = [];

    for (int i = 0; i < numTrails; i++) {
      final List<List<double>> points = [];
      for (int j = 0; j < pointsPerTrail; j++) {
        points.add([110.0 + (j * 0.0001), -7.0 + (j * 0.0001), 1000.0 + j]);
      }

      trails.add({
        'id': 'trail_$i',
        'mountainId': 'mt_1',
        'name': 'Trail $i',
        'distance': 5000.0,
        'elevationGain': 500.0,
        'difficulty': 3,
        'geometryJson': jsonEncode(points),
        'minLat': -7.5,
        'maxLat': -7.0,
        'minLng': 110.0,
        'maxLng': 110.5,
      });
    }

    final jsonStr = jsonEncode(trails);
    print('Generated JSON size: ${(jsonStr.length / 1024 / 1024).toStringAsFixed(2)} MB');

    final stopwatch = Stopwatch()..start();

    // Simulate main thread parsing
    final List<dynamic> list = jsonDecode(jsonStr);
    final result = list.map((e) => parseNativeTrail(e)).toList();

    stopwatch.stop();

    print('Parsed ${result.length} trails with ${pointsPerTrail} points each.');
    print('Time taken: ${stopwatch.elapsedMilliseconds} ms');
  });
}
