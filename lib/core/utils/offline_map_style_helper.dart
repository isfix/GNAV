import 'dart:convert';
import 'package:flutter/services.dart';

/// Helper to load offline vector map styles with local MBTiles injection.
///
/// This enables 100% offline map rendering using pre-downloaded MBTiles files.
/// The style JSON must have a 'openmaptiles' source with '{path}' placeholder.
class OfflineMapStyleHelper {
  /// Loads the vector style and injects the local MBTiles path.
  ///
  /// [mbtilesPath] - Absolute path to the .mbtiles file on device.
  /// Returns a JSON string ready for MapLibre's styleString parameter.
  static Future<String> getOfflineStyle(String mbtilesPath) async {
    // 1. Load the style template
    final styleString =
        await rootBundle.loadString('assets/map_styles/mapstyle.json');
    final Map<String, dynamic> style = json.decode(styleString);

    // 2. Inject the local file path into the 'openmaptiles' source
    // MapLibre requires the 'mbtiles://' scheme for local files
    if (style.containsKey('sources') &&
        style['sources'].containsKey('openmaptiles')) {
      style['sources']['openmaptiles']['url'] = 'mbtiles://$mbtilesPath';
    }

    return json.encode(style);
  }

  /// Returns the raw style JSON for online development mode.
  /// This can be used when MBTiles are not available.
  static Future<String> getStyleTemplate() async {
    return await rootBundle.loadString('assets/map_styles/mapstyle.json');
  }

  /// Checks if a style file exists in assets.
  static Future<bool> hasStyleAsset() async {
    try {
      await rootBundle.loadString('assets/map_styles/mapstyle.json');
      return true;
    } catch (e) {
      return false;
    }
  }
}
