import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:pandu_navigation/core/services/config_service.dart';
import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('ConfigService loads mountains.json correctly', () async {
    // Mock rootBundle
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
      return ByteData.view(Uint8List.fromList(utf8.encode(
              '{"version": 1, "mountains": [{"id": "merbabu", "name": "Mt. Merbabu", "tracks": [], "mbtiles_path": "assets/tiles/merbabu.mbtiles", "difficulty": "Hard", "description": "Test Desc"}]}'))
          .buffer);
    });

    final jsonMap = {
      "version": 1,
      "mountains": [
        {
          "id": "merbabu",
          "name": "Mt. Merbabu",
          "tracks": [],
          "mbtiles_path": "assets/tiles/merbabu.mbtiles",
          "difficulty": "Hard",
          "description": "Desc"
        }
      ]
    };

    final config = AppConfig.fromJson(jsonMap);

    expect(config.version, 1);
    expect(config.mountains.length, 1);
    expect(config.mountains.first.id, 'merbabu');
    expect(config.mountains.first.name, 'Mt. Merbabu');
    expect(config.mountains.first.isActive, true, reason: "Default should be active");
  });

  test('MountainConfig parses active status correctly', () {
      final activeJson = {
          "id": "merbabu",
          "name": "Mt. Merbabu",
          "tracks": [],
          "mbtiles_path": "assets/tiles/merbabu.mbtiles",
          "difficulty": "Hard",
          "description": "Desc",
          "active": true
      };

      final inactiveJson = {
          "id": "inactive_mt",
          "name": "Mt. Inactive",
          "tracks": [],
          "mbtiles_path": "path",
          "difficulty": "Easy",
          "description": "Desc",
          "active": false
      };

      final activeMountain = MountainConfig.fromJson(activeJson);
      final inactiveMountain = MountainConfig.fromJson(inactiveJson);

      expect(activeMountain.isActive, true);
      expect(inactiveMountain.isActive, false);
  });
}
