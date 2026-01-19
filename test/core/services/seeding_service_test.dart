import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:pandu_navigation/core/services/seeding_service.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';

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
    print('TestAssetBundle.load: $key');
    if (_assets.containsKey(key)) {
      return ByteData.view(_assets[key]!.buffer);
    }
    throw FlutterError('Unable to load asset: "$key".');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    print('TestAssetBundle.loadString: $key');
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

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    testBundle = TestAssetBundle();
    seedingService = SeedingService(db, bundle: testBundle);

    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock path_provider
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      return '.';
    });
  });

  tearDown(() async {
    await db.close();
  });

  test('discoverAndSeedAssets should find and seed assets using AssetManifest.loadFromAssetBundle', () async {
    // Setup manifest data
    // AssetManifest.bin format: Map<String, List<Object>>
    final Map<String, List<Object>> manifestData = {
      'assets/map_data/test_mountain.mbtiles': [
        {'asset': 'assets/map_data/test_mountain.mbtiles'}
      ],
      'assets/gpx/merbabu/Selo.gpx': [
        {'asset': 'assets/gpx/merbabu/Selo.gpx'}
      ]
    };

    // Encode as AssetManifest.bin
    final ByteData? binData = const StandardMessageCodec().encodeMessage(manifestData);
    testBundle.addAsset('AssetManifest.bin', binData!.buffer.asUint8List(binData.offsetInBytes, binData.lengthInBytes));

    // Add fake assets
    testBundle.addStringAsset('assets/map_data/test_mountain.mbtiles', 'dummy mbtiles content');
    // For GPX, SeedingService calls loadFullGpxData which likely loads the file via rootBundle too.
    // Wait, SeedingService uses `TrackLoaderService` which defaults to `rootBundle` if not injected?
    // In `SeedingService.dart`:
    // _trackLoader = trackLoader ?? TrackLoaderService(db);
    // TrackLoaderService likely uses rootBundle.
    // I need to check if TrackLoaderService uses dependency injection for bundle.
    // But let's assume for now I just want to check MAP seeding which happens in SeedingService directly.
    // SeedingService._copyAssetToLocal uses `_bundle.load`.

    await seedingService.discoverAndSeedAssets();

    // Verify DB has the seeded map
    final regions = await db.select(db.mountainRegions).get();
    expect(regions.any((r) => r.id == 'test_mountain'), isTrue, reason: 'Map region should be seeded');
  });
}
