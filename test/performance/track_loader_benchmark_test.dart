import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/core/services/track_loader_service.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;

class MockAssetBundle extends AssetBundle {
  final Map<String, String> _assets = {};

  void addAsset(String key, String value) {
    _assets[key] = value;
  }

  @override
  Future<ByteData> load(String key) async {
    if (_assets.containsKey(key)) {
      return ByteData.view(Uint8List.fromList(utf8.encode(_assets[key]!)).buffer);
    }
    throw FlutterError('Asset not found: $key');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_assets.containsKey(key)) {
      return _assets[key]!;
    }
    throw FlutterError('Asset not found: $key');
  }
}

void main() {
  late AppDatabase database;
  late TrackLoaderService trackLoaderService;
  late MockAssetBundle mockBundle;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    mockBundle = MockAssetBundle();
    trackLoaderService = TrackLoaderService(database, bundle: mockBundle);

    // Seed MountainRegion
    await database.into(database.mountainRegions).insert(
          MountainRegionsCompanion(
            id: const drift.Value('mt_benchmark'),
            name: const drift.Value('Benchmark Mountain'),
            boundaryJson: const drift.Value('{}'),
            lat: const drift.Value(0.0),
            lng: const drift.Value(0.0),
          ),
        );
  });

  tearDown(() async {
    await database.close();
  });

  String generateGpx(int pointCount) {
    final buffer = StringBuffer();
    buffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    buffer.writeln('<gpx version="1.1" creator="PanduBenchmark">');
    buffer.writeln('  <trk>');
    buffer.writeln('    <name>Benchmark Trail</name>');
    buffer.writeln('    <trkseg>');

    for (int i = 0; i < pointCount; i++) {
      final lat = -7.0 + (i * 0.0001);
      final lon = 110.0 + (i * 0.0001);
      final ele = 1000.0 + (i % 100);
      buffer.writeln('      <trkpt lat="$lat" lon="$lon">');
      buffer.writeln('        <ele>$ele</ele>');
      // Add extensions every 10 points
      if (i % 10 == 0) {
        buffer.writeln('        <extensions>');
        buffer.writeln('          <surface>gravel</surface>');
        buffer.writeln('          <sac_scale>mountain_hiking</sac_scale>');
        buffer.writeln('        </extensions>');
      }
      buffer.writeln('      </trkpt>');
    }

    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');
    return buffer.toString();
  }

  test('Benchmark loadFullGpxData performance', () async {
    const pointCount = 5000;
    final gpxContent = generateGpx(pointCount);
    const assetPath = 'assets/gpx/benchmark.gpx';
    mockBundle.addAsset(assetPath, gpxContent);

    final stopwatch = Stopwatch()..start();
    await trackLoaderService.loadFullGpxData(assetPath, 'mt_benchmark', 'trail_bench');
    stopwatch.stop();

    debugPrint('Benchmark: Loaded $pointCount points in ${stopwatch.elapsedMilliseconds}ms');

    // Verify data
    final trails = await database.select(database.trails).get();
    expect(trails.length, 1);
    expect(trails.first.id, 'trail_bench');

    // Check points count
    final jsonPoints = trails.first.geometryJson;
    expect(jsonPoints.length, pointCount);
  });
}
