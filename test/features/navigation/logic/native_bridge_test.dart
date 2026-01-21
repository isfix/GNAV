import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/features/navigation/logic/native_bridge.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.pandu.nav/commands');

  test('getTrails parses JSON in background', () async {
    // Generate test data
    final trailsData = [
      {
        'id': 'trail_1',
        'mountainId': 'mt_1',
        'name': 'Trail 1',
        'distance': 1000.0,
        'elevationGain': 100.0,
        'difficulty': 2,
        'geometryJson': jsonEncode([
          [110.0, -7.0, 1000.0],
          [110.001, -7.001, 1010.0]
        ]),
        'minLat': -7.001,
        'maxLat': -7.0,
        'minLng': 110.0,
        'maxLng': 110.001,
      }
    ];
    final jsonStr = jsonEncode(trailsData);

    // Mock the method channel
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getTrails') {
        return jsonStr;
      }
      return null;
    });

    // Call the method
    final trails = await NativeBridge.getTrails('mt_1');

    // Verify results
    expect(trails, isA<List<Trail>>());
    expect(trails.length, 1);
    expect(trails.first.id, 'trail_1');
    expect(trails.first.name, 'Trail 1');
    expect(trails.first.geometryJson.length, 2);
    expect(trails.first.geometryJson[0].lat, -7.0);
    expect(trails.first.geometryJson[0].lng, 110.0);
  });
}
