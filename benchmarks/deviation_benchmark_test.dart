import 'dart:core';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/features/navigation/logic/deviation_engine.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

void main() {
  test('Deviation Benchmark', () {
    print('Starting Deviation Benchmark...');

    // 1. Setup Data
    final int pointsCount = 10000;
    final List<TrailPoint> points = [];

    // Create a trail going from (0,0) to (0, 10)
    for (int i = 0; i < pointsCount; i++) {
      double lat = 0.0;
      double lng = i * (10.0 / pointsCount);
      points.add(TrailPoint(lat, lng, 100.0));
    }

    final trail = Trail(
      id: 'benchmark_trail',
      mountainId: 'mt_benchmark',
      name: 'Benchmark Trail',
      geometryJson: points,
      distance: 10000.0,
      elevationGain: 100.0,
      difficulty: 1,
      summitIndex: pointsCount - 1,
      minLat: -0.001, // Bounds
      maxLat: 0.001,
      minLng: -0.001,
      maxLng: 10.001,
      isOfficial: true,
    );

    final userLoc = LatLng(0.0001, 5.0); // Close to the middle of the trail

    // 2. Warmup
    print('Warming up...');
    for (int i = 0; i < 10; i++) {
      DeviationEngine.calculateMinDistance(userLoc, [trail]);
    }

    // 3. Benchmark
    print('Running benchmark...');
    final stopwatch = Stopwatch()..start();
    final iterations = 100;

    for (int i = 0; i < iterations; i++) {
      DeviationEngine.calculateMinDistance(userLoc, [trail]);
    }

    stopwatch.stop();
    final double avgTimeMs = stopwatch.elapsedMilliseconds / iterations;

    print('Total time: ${stopwatch.elapsedMilliseconds} ms for $iterations iterations');
    print('Average time per call: ${avgTimeMs.toStringAsFixed(4)} ms');
  });
}
