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

    // 3. Inject clustered sources
    _injectClusteredSources(style);

    return json.encode(style);
  }

  /// Returns the raw style JSON for online development mode with clustering support.
  /// [layer] - 'osm', 'cyclosm', 'opentopo', or 'vector'.
  static Future<String> getStyleTemplate({String layer = 'osm'}) async {
    final styleString =
        await rootBundle.loadString('assets/map_styles/mapstyle.json');
    final Map<String, dynamic> style = json.decode(styleString);

    // Dynamic Layer Switching
    if (layer != 'vector') {
      // Switch to Raster Source
      String tileUrl = "https://a.tile.openstreetmap.org/{z}/{x}/{y}.png";
      if (layer == 'cyclosm') {
        tileUrl =
            "https://a.tile-cyclosm.openstreetmap.fr/cyclosm/{z}/{x}/{y}.png";
      } else if (layer == 'opentopo') {
        tileUrl = "https://a.tile.opentopomap.org/{z}/{x}/{y}.png";
      }

      // Replace 'openmaptiles' source with raster
      if (style.containsKey('sources')) {
        style['sources']['openmaptiles'] = {
          "type": "raster",
          "tiles": [tileUrl],
          "tileSize": 256
        };
      }

      // Update layers to use raster
      if (style.containsKey('layers')) {
        final layers = style['layers'] as List;
        // Remove all vector-based layers that rely on 'openmaptiles' source-layer
        layers.removeWhere((l) =>
            l['source'] == 'openmaptiles' && l.containsKey('source-layer'));

        // Add a simple raster layer at the bottom
        layers.insert(0, {
          "id": "simple-tiles",
          "type": "raster",
          "source": "openmaptiles",
          "minzoom": 0,
          "maxzoom": 22
        });
      }
    }

    // Inject clustered sources
    _injectClusteredSources(style);

    return json.encode(style);
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

  /// Injects pre-defined clustered sources into the style JSON.
  /// This enables true clustering support (circles with counts) which
  /// cannot be achieved via addGeoJsonSource at runtime in some versions.
  static void _injectClusteredSources(Map<String, dynamic> style) {
    if (!style.containsKey('sources')) {
      style['sources'] = <String, dynamic>{};
    }

    final sources = style['sources'] as Map<String, dynamic>;

    // Define clustered sources
    // These IDs must match MapLayerService constants:
    // mountainMarkerSourceId = 'source_mountain_markers'
    // basecampMarkerSourceId = 'source_basecamp_markers'

    const clusteredSourceIds = [
      'source_mountain_markers',
      'source_basecamp_markers'
    ];

    for (final id in clusteredSourceIds) {
      if (!sources.containsKey(id)) {
        sources[id] = {
          'type': 'geojson',
          'data': {'type': 'FeatureCollection', 'features': []},
          'cluster': true,
          'clusterMaxZoom': 14,
          'clusterRadius': 50
        };
      }
    }
  }
}
