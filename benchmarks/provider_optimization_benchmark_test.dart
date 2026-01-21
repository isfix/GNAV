import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:pandu_navigation/data/local/db/converters.dart';
import 'package:pandu_navigation/features/navigation/logic/native_bridge.dart' as bridge;

// Mocks the structure returned by NativeBridge
// Note: NativeBridge returns a JSON string representing a list of trails.
// Each trail has a 'geometryJson' field which is ALSO a JSON string (double serialization).
List<Map<String, dynamic>> createNativeBridgePayload(List<Trail> trails) {
  return trails.map((t) {
    // Native implementation (as seen in parsing logic) implies geometryJson is a string
    // containing the JSON array of points.

    // 1. Convert points to List of Lists (like GeoJsonConverter does)
    final pointsList = t.geometryJson.map((p) => [p.lng, p.lat, p.elevation]).toList();

    // 2. Serialize geometry to string
    final geometryString = jsonEncode(pointsList);

    return {
      'id': t.id,
      'mountainId': t.mountainId,
      'name': t.name,
      'distance': t.distance,
      'elevationGain': t.elevationGain,
      'difficulty': t.difficulty,
      'geometryJson': geometryString, // Stringified JSON
      'minLat': t.minLat,
      'maxLat': t.maxLat,
      'minLng': t.minLng,
      'maxLng': t.maxLng,
    };
  }).toList();
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  test('Benchmark: Direct DB Access vs Native Bridge Simulation', () async {
    // 1. Setup Data
    const mountainId = 'mt_benchmark';
    await db.into(db.mountainRegions).insert(MountainRegionsCompanion.insert(
      id: mountainId,
      name: 'Benchmark Mountain',
      boundaryJson: '[]',
    ));

    // Create 100 trails, each with 500 points
    // This simulates a reasonable mountain network
    final trailsToInsert = <TrailsCompanion>[];
    final largeGeometry = List.generate(
      500,
      (index) => TrailPoint(0.0 + index * 0.0001, 110.0 + index * 0.0001, 100.0)
    );

    for (int i = 0; i < 100; i++) {
      trailsToInsert.add(TrailsCompanion.insert(
        id: 'trail_$i',
        mountainId: mountainId,
        name: 'Trail $i',
        geometryJson: largeGeometry,
        distance: const drift.Value(1000),
        elevationGain: const drift.Value(500),
        difficulty: const drift.Value(1),
        summitIndex: const drift.Value(0),
        minLat: const drift.Value(0.0),
        maxLat: const drift.Value(1.0),
        minLng: const drift.Value(110.0),
        maxLng: const drift.Value(111.0),
      ));
    }

    await db.batch((batch) {
      batch.insertAll(db.trails, trailsToInsert);
    });

    // Fetch trails once to get objects for payload creation
    final trails = await db.navigationDao.getTrailsForMountain(mountainId);
    expect(trails.length, 100);

    // Prepare NativeBridge Payload (JSON String)
    // The native bridge returns a String which is a JSON encoded List of Maps.
    final nativePayloadObj = createNativeBridgePayload(trails);
    final nativePayloadString = jsonEncode(nativePayloadObj);

    print('Payload size: ${(nativePayloadString.length / 1024).toStringAsFixed(2)} KB');

    // --- Benchmark 1: Native Bridge Simulation ---
    // Overhead = (Channel Call - ignored) + JSON Decode (String -> List) + Map -> Object + Geometry JSON Decode

    final swNative = Stopwatch()..start();

    // Simulate what happens in the isolate/parsing logic
    // 1. Decode main list
    final List<dynamic> rawList = jsonDecode(nativePayloadString);

    // 2. Parse each trail
    final parsedTrails = rawList.map((rawJson) {
       final Map<String, dynamic> json = rawJson;
       List<TrailPoint> geometry = [];
       if (json['geometryJson'] != null) {
          // Inner decode for geometry
          final List<dynamic> rawPoints = jsonDecode(json['geometryJson']);
          geometry = rawPoints.map((p) {
             final lat = (p[1] as num).toDouble();
             final lng = (p[0] as num).toDouble();
             final ele = (p.length > 2 ? (p[2] as num).toDouble() : 0.0);
             return TrailPoint(lat, lng, ele);
          }).toList();
       }

       return Trail(
          id: json['id'],
          mountainId: json['mountainId'],
          name: json['name'],
          geometryJson: geometry,
          distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
          elevationGain: (json['elevationGain'] as num?)?.toDouble() ?? 0.0,
          difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
          summitIndex: 0,
          minLat: (json['minLat'] as num?)?.toDouble() ?? 0,
          maxLat: (json['maxLat'] as num?)?.toDouble() ?? 0,
          minLng: (json['minLng'] as num?)?.toDouble() ?? 0,
          maxLng: (json['maxLng'] as num?)?.toDouble() ?? 0,
          isOfficial: true,
       );
    }).toList();

    swNative.stop();
    print('Native Bridge Simulation (Parse Only): ${swNative.elapsedMilliseconds} ms');
    expect(parsedTrails.length, 100);


    // --- Benchmark 2: Direct DAO Access ---
    // Note: In a real app, Drift also parses JSON for geometryJson column.
    // So we need to measure the query time.
    // However, Drift's converter might be cleaner/optimized, and we avoid the DOUBLE serialization (Native -> Flutter -> Object)
    // and the Channel overhead (not measured here).

    final swDao = Stopwatch()..start();
    final directTrails = await db.navigationDao.getTrailsForMountain(mountainId);
    swDao.stop();

    print('Direct DAO Access: ${swDao.elapsedMilliseconds} ms');
    expect(directTrails.length, 100);

    print('Speedup Factor (excluding Channel overhead): ${(swNative.elapsedMilliseconds / swDao.elapsedMilliseconds).toStringAsFixed(1)}x');
  });
}
