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

  // POI Layer constants
  static const String poiSourceId = 'poi-source';
  static const String poiLayerId = 'poi-layer';

  bool _trailLayerAdded = false;
  bool _backtrackLayerAdded = false;
  bool _dangerZoneLayerAdded = false;
  bool _poiLayerAdded = false;

  void attach(MapLibreMapController controller) {
    _controller = controller;
    _trailLayerAdded = false;
    _backtrackLayerAdded = false;
    _dangerZoneLayerAdded = false;
    _poiLayerAdded = false;
  }

  void detach() {
    _controller = null;
    _trailLayerAdded = false;
    _backtrackLayerAdded = false;
    _dangerZoneLayerAdded = false;
    _poiLayerAdded = false;
  }

  /// Draws trail polylines on the map
  /// If [highlightTrailId] is provided, that trail is drawn with a thicker, brighter line
  Future<void> drawTrails(List<Trail> trails,
      {String? highlightTrailId}) async {
    if (_controller == null || trails.isEmpty) return;

    try {
      // Separate highlighted and regular trails
      final regularFeatures = <Map<String, dynamic>>[];
      final highlightFeatures = <Map<String, dynamic>>[];

      for (final trail in trails) {
        final points = trail.geometryJson as List<TrailPoint>?;
        if (points == null || points.isEmpty) continue;

        final coordinates = points
            .map((p) => [p.lng, p.lat]) // GeoJSON uses [lng, lat]
            .toList();

        final feature = {
          'type': 'Feature',
          'properties': {
            'id': trail.id,
            'name': trail.name,
            'difficulty': trail.difficulty ?? 3,
          },
          'geometry': {'type': 'LineString', 'coordinates': coordinates},
        };

        if (trail.id == highlightTrailId) {
          highlightFeatures.add(feature);
        } else {
          regularFeatures.add(feature);
        }
      }

      // Regular trails (muted green)
      final regularGeoJson = {
        'type': 'FeatureCollection',
        'features': regularFeatures
      };

      // Highlighted trail (bright green, thicker)
      final highlightGeoJson = {
        'type': 'FeatureCollection',
        'features': highlightFeatures
      };

      // Add or update regular trails source
      if (!_trailLayerAdded) {
        await _controller!.addGeoJsonSource(trailSourceId, regularGeoJson);
        await _controller!.addLineLayer(
          trailSourceId,
          trailLayerId,
          LineLayerProperties(
            lineColor: '#0df259',
            lineWidth: 3.0,
            lineCap: 'round',
            lineJoin: 'round',
            lineOpacity: highlightTrailId != null
                ? 0.4
                : 1.0, // Dim if there's a highlight
          ),
        );

        // Add highlighted trail layer (on top)
        if (highlightFeatures.isNotEmpty) {
          await _controller!
              .addGeoJsonSource('${trailSourceId}_highlight', highlightGeoJson);
          await _controller!.addLineLayer(
            '${trailSourceId}_highlight',
            '${trailLayerId}_highlight',
            const LineLayerProperties(
              lineColor: '#0df259',
              lineWidth: 6.0,
              lineCap: 'round',
              lineJoin: 'round',
            ),
          );
        }

        _trailLayerAdded = true;
      } else {
        await _controller!.setGeoJsonSource(trailSourceId, regularGeoJson);
        if (highlightFeatures.isNotEmpty) {
          try {
            await _controller!.setGeoJsonSource(
                '${trailSourceId}_highlight', highlightGeoJson);
          } catch (_) {
            // Source doesn't exist yet, add it
            await _controller!.addGeoJsonSource(
                '${trailSourceId}_highlight', highlightGeoJson);
            await _controller!.addLineLayer(
              '${trailSourceId}_highlight',
              '${trailLayerId}_highlight',
              const LineLayerProperties(
                lineColor: '#0df259',
                lineWidth: 6.0,
                lineCap: 'round',
                lineJoin: 'round',
              ),
            );
          }
        }
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
    if (_controller == null) return;

    try {
      // Clear existing symbols first (legacy cleanup)
      await _controller!.clearSymbols();

      if (pois.isEmpty) {
        if (_poiLayerAdded) {
          await _controller!.removeLayer(poiLayerId);
          await _controller!.removeSource(poiSourceId);
          _poiLayerAdded = false;
        }
        return;
      }

      final features = pois.map((poi) {
        return {
          'type': 'Feature',
          'id': poi.id,
          'properties': {
            'name': poi.name,
            'type': poi.type.index,
          },
          'geometry': {
            'type': 'Point',
            'coordinates': [poi.lng, poi.lat],
          },
        };
      }).toList();

      final geojson = {'type': 'FeatureCollection', 'features': features};

      if (!_poiLayerAdded) {
        await _controller!.addGeoJsonSource(poiSourceId, geojson);
        await _controller!.addSymbolLayer(
          poiSourceId,
          poiLayerId,
          const SymbolLayerProperties(
            iconImage: 'marker',
            iconSize: 1.5,
            textField: ['get', 'name'],
            textOffset: [0, 2],
            textColor: '#ffffff',
            textHaloColor: '#000000',
            textHaloWidth: 1,
          ),
        );
        _poiLayerAdded = true;
      } else {
        await _controller!.setGeoJsonSource(poiSourceId, geojson);
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
  static const String mountainClusterLayerId = 'layer_mountain_clusters';
  static const String mountainClusterCountLayerId =
      'layer_mountain_cluster_count';

  static const String basecampMarkerSourceId = 'source_basecamp_markers';
  static const String basecampMarkerLayerId = 'layer_basecamp_markers';
  static const String basecampClusterLayerId = 'layer_basecamp_clusters';
  static const String basecampClusterCountLayerId =
      'layer_basecamp_cluster_count';

  bool _mountainMarkersAdded = false;
  bool _basecampMarkersAdded = false;

  /// Helper to add a clustered source and associated layers
  Future<void> _addClusteredSource({
    required String sourceId,
    required Map<String, dynamic> geojson,
    required String unclusteredLayerId,
    required CircleLayerProperties unclusteredCircleProps,
    required String unclusteredLabelLayerId,
    required SymbolLayerProperties unclusteredLabelProps,
    required String clusterLayerId,
    required String clusterCountLayerId,
    required String clusterColorHex,
  }) async {
    // maplibre_gl 0.25+ doesn't support native clustering via addSource
    // Workaround: Use addGeoJsonSource and simulate clustering with zoom filters

    // Add GeoJSON source (no clustering - that requires native style JSON)
    await _controller!.addGeoJsonSource(sourceId, geojson);

    // 1. Individual markers (visible at higher zoom)
    await _controller!.addCircleLayer(
      sourceId,
      unclusteredLayerId,
      unclusteredCircleProps,
      minzoom: 12, // Only show individual markers at zoom 12+
    );

    // 2. Labels for individual markers
    await _controller!.addSymbolLayer(
      sourceId,
      unclusteredLabelLayerId,
      unclusteredLabelProps,
      minzoom: 12,
    );

    // 3. Aggregated circle at low zoom (simulates cluster)
    // This shows a single marker at the centroid when zoomed out
    await _controller!.addCircleLayer(
      sourceId,
      clusterLayerId,
      CircleLayerProperties(
        circleColor: clusterColorHex,
        circleRadius: 18,
        circleStrokeWidth: 2,
        circleStrokeColor: '#ffffff',
      ),
      maxzoom: 12, // Only show at low zoom
    );

    // Note: True clustering requires setting cluster options in the style JSON
    // before loading the map. For full clustering support, use:
    // 1. A style JSON with pre-defined clustered source, OR
    // 2. Native code via MethodChannel to add clustered source
  }

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
        await _addClusteredSource(
          sourceId: mountainMarkerSourceId,
          geojson: geojson,
          unclusteredLayerId: mountainMarkerLayerId,
          unclusteredCircleProps: const CircleLayerProperties(
            circleRadius: 12,
            circleColor: '#2ecc40', // Green for mountains
            circleStrokeWidth: 3,
            circleStrokeColor: '#ffffff',
          ),
          unclusteredLabelLayerId: '${mountainMarkerLayerId}_labels',
          unclusteredLabelProps: const SymbolLayerProperties(
            textField: ['get', 'name'],
            textOffset: [0, 1.8],
            textSize: 13,
            textColor: '#ffffff',
            textHaloColor: '#000000',
            textHaloWidth: 2,
            textAllowOverlap: false,
          ),
          clusterLayerId: mountainClusterLayerId,
          clusterCountLayerId: mountainClusterCountLayerId,
          clusterColorHex: '#2ecc40',
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
        await _addClusteredSource(
          sourceId: basecampMarkerSourceId,
          geojson: geojson,
          unclusteredLayerId: basecampMarkerLayerId,
          unclusteredCircleProps: const CircleLayerProperties(
            circleRadius: 10,
            circleColor: '#ff851b', // Orange for basecamps
            circleStrokeWidth: 2,
            circleStrokeColor: '#ffffff',
          ),
          unclusteredLabelLayerId: '${basecampMarkerLayerId}_labels',
          unclusteredLabelProps: const SymbolLayerProperties(
            textField: ['get', 'name'],
            textOffset: [0, 1.5],
            textSize: 11,
            textColor: '#ffdc00',
            textHaloColor: '#000000',
            textHaloWidth: 1.5,
            textAllowOverlap: false,
          ),
          clusterLayerId: basecampClusterLayerId,
          clusterCountLayerId: basecampClusterCountLayerId,
          clusterColorHex: '#ff851b',
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
        await _controller!.removeLayer('${mountainMarkerLayerId}_labels');
        await _controller!.removeLayer(mountainMarkerLayerId);
        await _controller!.removeLayer(mountainClusterCountLayerId);
        await _controller!.removeLayer(mountainClusterLayerId);
        await _controller!.removeSource(mountainMarkerSourceId);
        _mountainMarkersAdded = false;
      }
      if (_basecampMarkersAdded) {
        await _controller!.removeLayer('${basecampMarkerLayerId}_labels');
        await _controller!.removeLayer(basecampMarkerLayerId);
        await _controller!.removeLayer(basecampClusterCountLayerId);
        await _controller!.removeLayer(basecampClusterLayerId);
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
