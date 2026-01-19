import 'package:flutter_test/flutter_test.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';
import 'package:pandu_navigation/features/navigation/logic/deviation_engine.dart';

void main() {
  test('Benchmark DeviationEngine.calculateMinDistance', () {
    // 1. Setup: Create a large trail
    // 10,000 points spanning from (0,0) to (1,1)
    final points = <TrailPoint>[];
    const int count = 10000;
    for (int i = 0; i < count; i++) {
      final t = i / count;
      points.add(TrailPoint(t, t, 0.0));
    }

    final trail = Trail(
      id: 'bench_trail',
      mountainId: 'mt_bench',
      name: 'Benchmark Trail',
      geometryJson: points,
      minLat: 0.0,
      maxLat: 1.0,
      minLng: 0.0,
      maxLng: 1.0,
      distance: 0,
      elevationGain: 0,
      difficulty: 1,
      summitIndex: 0,
      isOfficial: true,
      startLat: 0.0,
      startLng: 0.0,
    );

    // User is near the middle of the trail
    // The closest point should be around (0.5, 0.5)
    // We place user slightly off-track: (0.50001, 0.50001) is very close to (0.5, 0.5)
    // Actually (0.50001, 0.50001) is ON the line defined by (0,0) -> (1,1).
    // So distance should be ~0.
    final userLoc = LatLng(0.50001, 0.50001);

    // 2. Warmup & Verification
    final warmupDist = DeviationEngine.calculateMinDistance(userLoc, [trail]);
    expect(warmupDist, closeTo(0.0, 0.1), reason: "User is on the trail line, distance should be near zero");

    // 3. Measure
    final stopwatch = Stopwatch()..start();
    const int iterations = 100; // Run multiple times to amplify difference
    for (int i = 0; i < iterations; i++) {
       DeviationEngine.calculateMinDistance(userLoc, [trail]);
    }
    stopwatch.stop();

    print('Benchmark: DeviationEngine.calculateMinDistance took ${stopwatch.elapsedMilliseconds} ms for $iterations iterations with $count points');
  });
}
