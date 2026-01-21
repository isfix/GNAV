import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:pandu_navigation/core/services/seeding_service.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:path/path.dart' as p;

// Mock AssetBundle
class TestAssetBundle extends AssetBundle {
  final Map<String, Uint8List> _assets = {};

  void addAsset(String key, List<int> value) {
    _assets[key] = Uint8List.fromList(value);
  }

  void addStringAsset(String key, String value) {
    addAsset(key, utf8.encode(value));
  }

  @override
  Future<ByteData> load(String key) async {
    if (_assets.containsKey(key)) {
      // Simulate some async delay for I/O
      await Future.delayed(const Duration(milliseconds: 10));
      return ByteData.view(_assets[key]!.buffer);
    }
    throw FlutterError('Unable to load asset: "$key".');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (_assets.containsKey(key)) {
      return utf8.decode(_assets[key]!);
    }
    throw FlutterError('Unable to load asset: "$key".');
  }
}

void main() {
  late AppDatabase db;
  late SeedingService seedingService;
  late TestAssetBundle testBundle;
  late Directory tempDir;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    testBundle = TestAssetBundle();
    seedingService = SeedingService(db, bundle: testBundle);
    tempDir = Directory.systemTemp.createTempSync('seeding_bench_');

    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock path_provider
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return tempDir.path;
    });
  });

  tearDown(() async {
    await db.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Seeding benchmark: Sequential vs Parallel Map Seeding', () async {
    // 1. Setup Manifest with many map files
    const int mapCount = 50;
    final Map<String, List<Object>> manifestData = {};

    // Create fake map files
    for (int i = 0; i < mapCount; i++) {
      final key = 'assets/map_data/map_$i.mbtiles';
      manifestData[key] = [{'asset': key}];
      // Add a 100KB dummy file
      testBundle.addAsset(key, List.filled(100 * 1024, 0));
    }

    // Encode Manifest
    final ByteData? binData = const StandardMessageCodec().encodeMessage(manifestData);
    testBundle.addAsset('AssetManifest.bin', binData!.buffer.asUint8List(binData.offsetInBytes, binData.lengthInBytes));

    // 2. Measure Execution Time
    final stopwatch = Stopwatch()..start();

    await seedingService.discoverAndSeedAssets();

    stopwatch.stop();
    print('Seeding $mapCount maps took: ${stopwatch.elapsedMilliseconds}ms');

    // Verify
    final regions = await db.select(db.mountainRegions).get();
    expect(regions.length, mapCount);
  });
}
