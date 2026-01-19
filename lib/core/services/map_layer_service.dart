import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../data/local/db/converters.dart';
import '../../../data/local/db/app_database.dart';

/// Service for managing dynamic map layers on MapLibre.
/// This handles trail polylines, POI markers, danger zones, etc.
class MapLayerService {
  MapLibreMapController? _controller;

  // Source & Layer IDs
  static const String trailSourceId = 'trail-source';
  static const String trailLayerId = 'trail-layer';
  static const String backtrackSourceId = 'backtrack-source';
  static const String backtrackLayerId = 'backtrack-layer';
  static const String dangerZoneSourceId = 'danger-zone-source';
  static const String dangerZoneLayerId = 'danger-zone-layer';

  bool _trailLayerAdded = false;
  bool _backtrackLayerAdded = false;
  bool _dangerZoneLayerAdded = false;

  void attach(MapLibreMapController controller) {
    _controller = controller;
    _trailLayerAdded = false;
    _backtrackLayerAdded = false;
    _dangerZoneLayerAdded = false;
  }

  void detach() {
    _controller = null;
    _trailLayerAdded = false;
    _backtrackLayerAdded = false;
    _dangerZoneLayerAdded = false;
  }

  /// Draws trail polylines on the map
  Future<void> drawTrails(List<Trail> trails) async {
    if (_controller == null || trails.isEmpty) return;

    try {
      // Prepare GeoJSON features from trails
      final features = <Map<String, dynamic>>[];

      for (final trail in trails) {
        final points = trail.geometryJson as List<TrailPoint>?;
        if (points == null || points.isEmpty) continue;

        final coordinates = points
            .map((p) => [p.lng, p.lat]) // GeoJSON uses [lng, lat]
            .toList();

        features.add({
          'type': 'Feature',
          'properties': {
            'name': trail.name,
            'difficulty': trail.difficulty ?? 3,
          },
          'geometry': {'type': 'LineString', 'coordinates': coordinates},
        });
      }

      final geojson = {'type': 'FeatureCollection', 'features': features};

      // Add or update source
      if (!_trailLayerAdded) {
        await _controller!.addGeoJsonSource(trailSourceId, geojson);
        await _controller!.addLineLayer(
          trailSourceId,
          trailLayerId,
          const LineLayerProperties(
            lineColor: '#0df259',
            lineWidth: 4.0,
            lineCap: 'round',
            lineJoin: 'round',
          ),
        );
        _trailLayerAdded = true;
      } else {
        await _controller!.setGeoJsonSource(trailSourceId, geojson);
      }
    } catch (e) {
      debugPrint('Error drawing trails: $e');
    }
  }

  /// Draws backtrack path (dashed red line)
  Future<void> drawBacktrackPath(List<LatLng>? path) async {
    if (_controller == null) return;

    try {
      if (path == null || path.isEmpty) {
        // Remove backtrack if exists
        if (_backtrackLayerAdded) {
          await _controller!.removeLayer(backtrackLayerId);
          await _controller!.removeSource(backtrackSourceId);
          _backtrackLayerAdded = false;
        }
        return;
      }

      final coordinates = path.map((p) => [p.longitude, p.latitude]).toList();

      final geojson = {
        'type': 'Feature',
        'geometry': {'type': 'LineString', 'coordinates': coordinates},
      };

      if (!_backtrackLayerAdded) {
        await _controller!.addGeoJsonSource(backtrackSourceId, geojson);
        await _controller!.addLineLayer(
          backtrackSourceId,
          backtrackLayerId,
          const LineLayerProperties(
            lineColor: '#ff3b30',
            lineWidth: 4.0,
            lineDasharray: [2, 2],
            lineCap: 'round',
          ),
        );
        _backtrackLayerAdded = true;
      } else {
        await _controller!.setGeoJsonSource(backtrackSourceId, geojson);
      }
    } catch (e) {
      debugPrint('Error drawing backtrack: $e');
    }
  }

  /// Draws danger zone polygons
  Future<void> drawDangerZones(List<List<LatLng>> zones) async {
    if (_controller == null) return;

    try {
      if (zones.isEmpty) {
        if (_dangerZoneLayerAdded) {
          await _controller!.removeLayer(dangerZoneLayerId);
          await _controller!.removeSource(dangerZoneSourceId);
          _dangerZoneLayerAdded = false;
        }
        return;
      }

      final features = zones.map((zone) {
        final coordinates = zone.map((p) => [p.longitude, p.latitude]).toList();
        // Close the polygon
        if (coordinates.isNotEmpty) {
          coordinates.add(coordinates.first);
        }
        return {
          'type': 'Feature',
          'properties': {'label': 'DANGER ZONE'},
          'geometry': {
            'type': 'Polygon',
            'coordinates': [coordinates],
          },
        };
      }).toList();

      final geojson = {'type': 'FeatureCollection', 'features': features};

      if (!_dangerZoneLayerAdded) {
        await _controller!.addGeoJsonSource(dangerZoneSourceId, geojson);
        await _controller!.addFillLayer(
          dangerZoneSourceId,
          dangerZoneLayerId,
          const FillLayerProperties(fillColor: '#ff3b30', fillOpacity: 0.3),
        );
        _dangerZoneLayerAdded = true;
      } else {
        await _controller!.setGeoJsonSource(dangerZoneSourceId, geojson);
      }
    } catch (e) {
      debugPrint('Error drawing danger zones: $e');
    }
  }

  /// Adds POI markers using symbols
  Future<void> addPOIMarkers(List<PointOfInterest> pois) async {
    if (_controller == null || pois.isEmpty) return;

    // MapLibre symbols require a sprite sheet.
    // For now, we'll use circles with text labels or add symbols manually.
    // This is a simplified implementation using addSymbol for each POI.

    try {
      // Clear existing symbols first
      await _controller!.clearSymbols();

      for (final poi in pois) {
        String iconName = 'marker';

        // Note: Custom icons require sprite configuration in the style JSON
        // For now we use default marker or add circles instead
        await _controller!.addSymbol(
          SymbolOptions(
            geometry: LatLng(poi.lat, poi.lng),
            iconImage: iconName,
            iconSize: 1.5,
            textField: poi.name,
            textOffset: const Offset(0, 2),
            textColor: '#ffffff',
            textHaloColor: '#000000',
            textHaloWidth: 1,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding POI markers: $e');
    }
  }

  /// Adds mountain region markers
  Future<void> addRegionMarkers(List<MountainRegion> regions) async {
    if (_controller == null || regions.isEmpty) return;

    try {
      for (final region in regions) {
        if (region.lat == 0 || region.lng == 0) continue;

        await _controller!.addSymbol(
          SymbolOptions(
            geometry: LatLng(region.lat, region.lng),
            iconImage: 'marker',
            iconSize: 2.0,
            textField: region.name.replaceAll('Mount ', ''),
            textOffset: const Offset(0, 2.5),
            textColor: '#ffffff',
            textHaloColor: '#000000',
            textHaloWidth: 1,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding region markers: $e');
    }
  }

  // ===========================================================================
  // CLICKABLE MARKER LAYERS (GeoJSON-based for feature click detection)
  // ===========================================================================

  static const String mountainMarkerSourceId = 'source_mountain_markers';
  static const String mountainMarkerLayerId = 'layer_mountain_markers';
  static const String basecampMarkerSourceId = 'source_basecamp_markers';
  static const String basecampMarkerLayerId = 'layer_basecamp_markers';

  bool _mountainMarkersAdded = false;
  bool _basecampMarkersAdded = false;

  /// Draws mountain markers as clickable GeoJSON layer with circle + text
  Future<void> drawMountainMarkers(List<MountainRegion> mountains) async {
    if (_controller == null || mountains.isEmpty) return;

    try {
      final features = <Map<String, dynamic>>[];

      for (final mountain in mountains) {
        if (mountain.lat == 0 || mountain.lng == 0) continue;

        features.add({
          'type': 'Feature',
          'id': mountain.id,
          'properties': {
            'id': mountain.id,
            'name': mountain.name,
            'type': 'mountain',
          },
          'geometry': {
            'type': 'Point',
            'coordinates': [mountain.lng, mountain.lat],
          },
        });
      }

      final geojson = {'type': 'FeatureCollection', 'features': features};

      if (!_mountainMarkersAdded) {
        await _controller!.addGeoJsonSource(mountainMarkerSourceId, geojson);

        // Circle layer for clickable markers (always renders)
        await _controller!.addCircleLayer(
          mountainMarkerSourceId,
          mountainMarkerLayerId,
          const CircleLayerProperties(
            circleRadius: 12,
            circleColor: '#2ecc40', // Green for mountains
            circleStrokeWidth: 3,
            circleStrokeColor: '#ffffff',
          ),
        );

        // Text layer for labels
        await _controller!.addSymbolLayer(
          mountainMarkerSourceId,
          '${mountainMarkerLayerId}_labels',
          const SymbolLayerProperties(
            textField: ['get', 'name'],
            textOffset: [0, 1.8],
            textSize: 13,
            textColor: '#ffffff',
            textHaloColor: '#000000',
            textHaloWidth: 2,
            textAllowOverlap: false,
          ),
        );

        _mountainMarkersAdded = true;
      } else {
        await _controller!.setGeoJsonSource(mountainMarkerSourceId, geojson);
      }

      debugPrint('[MapLayer] Drew ${features.length} mountain markers');
    } catch (e) {
      debugPrint('Error drawing mountain markers: $e');
    }
  }

  /// Draws basecamp markers as clickable GeoJSON layer with circle + text
  Future<void> drawBasecampMarkers(List<PointOfInterest> basecamps) async {
    if (_controller == null || basecamps.isEmpty) return;

    try {
      final features = <Map<String, dynamic>>[];

      for (final basecamp in basecamps) {
        features.add({
          'type': 'Feature',
          'id': basecamp.id,
          'properties': {
            'id': basecamp.id,
            'name': basecamp.name,
            'mountainId': basecamp.mountainId,
            'type': 'basecamp',
            'lat': basecamp.lat,
            'lng': basecamp.lng,
          },
          'geometry': {
            'type': 'Point',
            'coordinates': [basecamp.lng, basecamp.lat],
          },
        });
      }

      final geojson = {'type': 'FeatureCollection', 'features': features};

      if (!_basecampMarkersAdded) {
        await _controller!.addGeoJsonSource(basecampMarkerSourceId, geojson);

        // Circle layer for clickable markers (always renders)
        await _controller!.addCircleLayer(
          basecampMarkerSourceId,
          basecampMarkerLayerId,
          const CircleLayerProperties(
            circleRadius: 10,
            circleColor: '#ff851b', // Orange for basecamps
            circleStrokeWidth: 2,
            circleStrokeColor: '#ffffff',
          ),
        );

        // Text layer for labels
        await _controller!.addSymbolLayer(
          basecampMarkerSourceId,
          '${basecampMarkerLayerId}_labels',
          const SymbolLayerProperties(
            textField: ['get', 'name'],
            textOffset: [0, 1.5],
            textSize: 11,
            textColor: '#ffdc00',
            textHaloColor: '#000000',
            textHaloWidth: 1.5,
            textAllowOverlap: false,
          ),
        );

        _basecampMarkersAdded = true;
      } else {
        await _controller!.setGeoJsonSource(basecampMarkerSourceId, geojson);
      }

      debugPrint('[MapLayer] Drew ${features.length} basecamp markers');
    } catch (e) {
      debugPrint('Error drawing basecamp markers: $e');
    }
  }

  /// Clears all clickable marker layers
  Future<void> clearClickableMarkers() async {
    if (_controller == null) return;

    try {
      if (_mountainMarkersAdded) {
        await _controller!.removeLayer(mountainMarkerLayerId);
        await _controller!.removeSource(mountainMarkerSourceId);
        _mountainMarkersAdded = false;
      }
      if (_basecampMarkersAdded) {
        await _controller!.removeLayer(basecampMarkerLayerId);
        await _controller!.removeSource(basecampMarkerSourceId);
        _basecampMarkersAdded = false;
      }
    } catch (e) {
      debugPrint('Error clearing markers: $e');
    }
  }
}

/// Singleton provider
final mapLayerService = MapLayerService();
