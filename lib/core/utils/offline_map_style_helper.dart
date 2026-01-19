import 'dart:convert';
import 'package:flutter/services.dart';

/// Helper to load offline vector map styles with local MBTiles injection.
///
/// This enables 100% offline map rendering using pre-downloaded MBTiles files.
/// The style JSON must have an 'openmaptiles' source that will be replaced
/// with the local file path.
class OfflineMapStyleHelper {
  /// Loads the dark mountain style and injects the local MBTiles path.
  ///
  /// [mbtilesPath] - Absolute path to the .mbtiles file on device.
  /// Returns a JSON string ready for MapLibre's styleString parameter.
  static Future<String> getOfflineStyle(String mbtilesPath) async {
    // 1. Load the existing vector style
    final styleString =
        await rootBundle.loadString('assets/map_styles/dark_mountain.json');
    final Map<String, dynamic> style = json.decode(styleString);

    // 2. Inject the local file path into the 'openmaptiles' source
    // MapLibre requires the 'mbtiles://' scheme for local files
    if (style.containsKey('sources') &&
        style['sources'].containsKey('openmaptiles')) {
      style['sources']['openmaptiles']['url'] = 'mbtiles://$mbtilesPath';
      // Ensure type is vector
      style['sources']['openmaptiles']['type'] = 'vector';
    }

    return json.encode(style);
  }

  /// Checks if the style has an openmaptiles source that can be replaced.
  static Future<bool> canUseOffline() async {
    try {
      final styleString =
          await rootBundle.loadString('assets/map_styles/dark_mountain.json');
      final Map<String, dynamic> style = json.decode(styleString);
      return style.containsKey('sources') &&
          style['sources'] is Map &&
          (style['sources'] as Map).containsKey('openmaptiles');
    } catch (e) {
      return false;
    }
  }
}
