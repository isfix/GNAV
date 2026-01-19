import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';

void main() {
  test('Benchmark Geometry Conversion', () {
    // Generate a large trail
    final points = <List<double>>[];
    for (int i = 0; i < 50000; i++) {
      points.add([110.0 + i * 0.0001, -7.0 + i * 0.0001, 100.0 + i]);
    }
    final jsonString = jsonEncode(points);
    final converter = const GeoJsonConverter();

    final stopwatch = Stopwatch()..start();

    // 1. Decode (Simulate DB retrieval)
    final trailPoints = converter.fromSql(jsonString);

    // 2. Transform (Simulate MapLayerService)
    final coordinates = trailPoints
            .map((p) => p.coordinates)
            .toList();

    stopwatch.stop();
    print('Total time (Baseline): ${stopwatch.elapsedMicroseconds} us');
    print('Points count: ${coordinates.length}');
  });
}
