import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pandu_navigation/features/navigation/logic/routing/routing_engine.dart';
import 'package:pandu_navigation/features/navigation/logic/routing/topology_builder.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';

void main() {
  test('RoutingEngine findNearestNode benchmark', () {
    final engine = RoutingEngine();
    final random = Random(42);
    final trails = <Trail>[];

    // Generate a 100x100 grid of points covering roughly 1 degree x 1 degree
    // This gives 10,000 nodes.
    const startLat = 0.0;
    const startLng = 0.0;
    const step = 0.01; // Approx 1km step
    const gridSize = 100;

    print('Generating graph with ${gridSize * gridSize} nodes...');

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        final lat = startLat + i * step;
        final lng = startLng + j * step;

        final p1 = TrailPoint(lat, lng, 0);

        final trail = Trail(
          id: 'trail_${i}_$j',
          mountainId: 'mt_1',
          name: 'Trail $i $j',
          geometryJson: [p1],
          distance: 0,
          elevationGain: 0,
          difficulty: 1,
          summitIndex: 0,
          minLat: lat,
          maxLat: lat,
          minLng: lng,
          maxLng: lng,
          isOfficial: true,
        );
        trails.add(trail);
      }
    }

    final stopwatch = Stopwatch()..start();
    engine.initializeGraph(trails);
    stopwatch.stop();
    print('Graph initialization took ${stopwatch.elapsedMilliseconds}ms');

    // Benchmark lookup
    const iterations = 100;
    print('Running $iterations lookups...');

    final lookups = <LatLng>[];
    for (int k = 0; k < iterations; k++) {
      // Random point within the grid area
      final lat = startLat + random.nextDouble() * (step * gridSize);
      final lng = startLng + random.nextDouble() * (step * gridSize);
      lookups.add(LatLng(lat, lng));
    }

    stopwatch.reset();
    stopwatch.start();

    for (final p in lookups) {
      // Using findRoute with same start/end to isolate findNearestNode cost (x2)
      engine.findRoute(p, p);
    }

    stopwatch.stop();
    final totalTime = stopwatch.elapsedMilliseconds;
    final avgTime = totalTime / iterations;

    print('Total time for $iterations lookups: ${totalTime}ms');
    print('Average time per lookup (2x findNearestNode): ${avgTime.toStringAsFixed(4)}ms');
  });
}
