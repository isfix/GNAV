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
      'assets/gpx/fake_mount/fake_trail.gpx': [
        {'asset': 'assets/gpx/fake_mount/fake_trail.gpx'}
      ]
    };

    // Encode as AssetManifest.bin
    final ByteData? binData = const StandardMessageCodec().encodeMessage(manifestData);
    testBundle.addAsset('AssetManifest.bin', binData!.buffer.asUint8List(binData.offsetInBytes, binData.lengthInBytes));

    // Add fake assets
    testBundle.addStringAsset('assets/map_data/test_mountain.mbtiles', 'dummy mbtiles content');
    testBundle.addStringAsset('assets/gpx/fake_mount/fake_trail.gpx', '''
<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="StravaGPX" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://www.topografix.com/GPX/1/1" xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1">
 <trk>
  <name>Fake Trail</name>
  <trkseg>
   <trkpt lat="-7.4526" lon="110.4422">
    <ele>1800.0</ele>
   </trkpt>
  </trkseg>
 </trk>
</gpx>
    ''');

    await seedingService.discoverAndSeedAssets();

    // Verify DB has the seeded map
    final regions = await db.select(db.mountainRegions).get();
    expect(regions.any((r) => r.id == 'test_mountain'), isTrue, reason: 'Map region should be seeded');

    // Verify DB has the seeded trail
    final trails = await db.select(db.trails).get();
    // This expects the trail to be seeded. If TrackLoaderService uses rootBundle, it won't find the fake gpx and this will fail.
    expect(trails.any((t) => t.id == 'fake_mount_fake_trail'), isTrue, reason: 'GPX trail should be seeded');
  });
}
