import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../../data/local/db/app_database.dart';

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
  final Set<String> _loadedIcons = {};

  // Route Layer constants
  static const String routeSourceId = 'route-source';
  static const String routeLayerId = 'route-layer';
  bool _routeLayerAdded = false;

  void attach(MapLibreMapController controller) {
    _controller = controller;
    _trailLayerAdded = false;
    _backtrackLayerAdded = false;
    _dangerZoneLayerAdded = false;
    _poiLayerAdded = false;
    _loadedIcons.clear();
  }

  void detach() {
    _controller = null;
    _trailLayerAdded = false;
    _backtrackLayerAdded = false;
    _dangerZoneLayerAdded = false;
    _poiLayerAdded = false;
    _userLocationLayerAdded = false;
    _loadedIcons.clear();
  }

  // User Location Constants
  static const String userLocationSourceId = 'user-location-source';
  static const String userLocationLayerId = 'user-location-layer';
  static const String userLocationHaloLayerId = 'user-location-halo-layer';
  bool _userLocationLayerAdded = false;

  /// Draws the user's location with a custom tactical style
  Future<void> drawUserLocation(LatLng location, double heading) async {
    if (_controller == null) return;

    try {
      final geojson = {
        'type': 'Feature',
        'geometry': {
          'type': 'Point',
          'coordinates': [location.longitude, location.latitude]
        },
        'properties': {'heading': heading}
      };

      if (!_userLocationLayerAdded) {
        await _controller!.addGeoJsonSource(userLocationSourceId, geojson);

        // 1. Halo (Pulsing effect simulation via transparency)
        await _controller!.addCircleLayer(
          userLocationSourceId,
          userLocationHaloLayerId,
          const CircleLayerProperties(
            circleColor: '#00FF00', // Neon Green
            circleRadius: 20,
            circleOpacity: 0.2,
            circleStrokeWidth: 0,
          ),
        );

        // 2. Core Dot
        await _controller!.addCircleLayer(
          userLocationSourceId,
          userLocationLayerId,
          const CircleLayerProperties(
            circleColor: '#00FF00', // Neon Green
            circleRadius: 6,
            circleStrokeWidth: 2,
            circleStrokeColor: '#FFFFFF',
          ),
        );

        _userLocationLayerAdded = true;
      } else {
        await _controller!.setGeoJsonSource(userLocationSourceId, geojson);
      }
    } catch (e) {
      debugPrint('Error drawing user location: $e');
    }
  }

  /// Draws trail polylines on the map with difficulty-based color coding
  /// If [highlightTrailId] is provided, that trail is drawn with a thicker line
  Future<void> drawTrails(List<Trail> trails,
      {String? highlightTrailId}) async {
    if (_controller == null || trails.isEmpty) return;

    try {
      final features = <Map<String, dynamic>>[];

      // Highlight features (entire trail)
      final highlightFeatures = <Map<String, dynamic>>[];

      for (final trail in trails) {
        final points = trail.geometryJson;
        if (points.isEmpty) continue;

        // 1. Add highlight feature (if applicable)
        if (trail.id == highlightTrailId) {
          final coordinates = points.map((p) => p.coordinates).toList();
          highlightFeatures.add({
            'type': 'Feature',
            'properties': {'id': trail.id, 'type': 'highlight'},
            'geometry': {'type': 'LineString', 'coordinates': coordinates},
          });
        }

        // 2. Segmentize trail by difficulty for detailed coloring
        var currentSegmentCoords = <List<dynamic>>[];
        // Default to trail level difficulty if point doesn't have it
        int currentDifficulty = points.first.difficulty > 0
            ? points.first.difficulty
            : trail.difficulty;

        // Start the first segment
        currentSegmentCoords.add(points.first.coordinates);

        for (int i = 1; i < points.length; i++) {
          final p = points[i];
          final difficulty = p.difficulty > 0
              ? p.difficulty
              : trail.difficulty; // Fallback to trail diff

          if (difficulty != currentDifficulty) {
            // End current segment
            // We duplicate the last point of the previous segment as the start of the next
            // to ensure visual continuity (no gaps).
            // Add current segment to features
            features.add({
              'type': 'Feature',
              'properties': {
                'id': trail.id,
                'difficulty': currentDifficulty,
              },
              'geometry': {
                'type': 'LineString',
                'coordinates': List.from(currentSegmentCoords), // Reset list
              },
            });

            // Start new segment
            currentSegmentCoords = [points[i - 1].coordinates, p.coordinates];
            currentDifficulty = difficulty;
          } else {
            currentSegmentCoords.add(p.coordinates);
          }
        }

        // Add final segment
        if (currentSegmentCoords.length > 1) {
          features.add({
            'type': 'Feature',
            'properties': {
              'id': trail.id,
              'difficulty': currentDifficulty,
            },
            'geometry': {
              'type': 'LineString',
              'coordinates': currentSegmentCoords,
            },
          });
        }
      }

      final geoJson = {'type': 'FeatureCollection', 'features': features};

      final highlightGeoJson = {
        'type': 'FeatureCollection',
        'features': highlightFeatures
      };

      if (!_trailLayerAdded) {
        // --- 1. Regular Trail Layer ---
        await _controller!.addGeoJsonSource(trailSourceId, geoJson);

        await _controller!.addLineLayer(
          trailSourceId,
          trailLayerId,
          LineLayerProperties(
            lineColor: [
              'match', ['get', 'difficulty'],
              1, '#00FFFF', // Cyan (Easy)
              2, '#0df259', // Green (Moderate)
              3, '#FFFF00', // Yellow (Hard)
              4, '#FFAA00', // Orange (Severe)
              5, '#FF3B30', // Red (Extreme)
              '#0df259' // Default
            ],
            lineWidth: 3.0,
            lineCap: 'round',
            lineJoin: 'round',
            lineOpacity: highlightTrailId != null ? 0.4 : 1.0,
          ),
        );

        // --- 2. Highlight Layer (Behind regular trails to create glow, or on top?)
        // Logic: Highlight selected trail.
        // If we draw on top, we obscure the difficulty colors.
        // Better to draw a "Core" highlight or "Outer" glow.
        // Let's draw an OUTER GLOW (thicker line underneath)

        if (highlightFeatures.isNotEmpty) {
          await _controller!
              .addGeoJsonSource('${trailSourceId}_highlight', highlightGeoJson);

          // Highlight Glow (Underneath)
          await _controller!.addLineLayer(
            '${trailSourceId}_highlight',
            '${trailLayerId}_highlight',
            const LineLayerProperties(
              lineColor: '#FFFFFF', // White Halo
              lineWidth: 6.0,
              lineOpacity: 0.5,
              lineBlur: 1.0,
              lineCap: 'round',
              lineJoin: 'round',
            ),
            belowLayerId: trailLayerId, // Draw BELOW the colored segments
          );
        }

        _trailLayerAdded = true;
      } else {
        await _controller!.setGeoJsonSource(trailSourceId, geoJson);

        if (highlightFeatures.isNotEmpty) {
          try {
            await _controller!.setGeoJsonSource(
                '${trailSourceId}_highlight', highlightGeoJson);
            // Update opacity of main layer if highlighting
            await _controller!.setLayerProperties(
                trailLayerId,
                LineLayerProperties(
                  lineOpacity: highlightTrailId != null ? 0.4 : 1.0,
                ));
          } catch (_) {}
        } else {
          // Clear highlight source
          try {
            await _controller!.setGeoJsonSource('${trailSourceId}_highlight',
                {'type': 'FeatureCollection', 'features': []});
            await _controller!.setLayerProperties(
                trailLayerId,
                const LineLayerProperties(
                  lineOpacity: 1.0,
                ));
          } catch (_) {}
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

  /// Loads POI icons from assets into the map controller
  /// Icons should be named matching PoiType enum values: basecamp.png, water.png, etc.
  Future<void> _loadPoiIcons() async {
    if (_controller == null) return;

    // Define all possible icons.
    final iconNames = [
      'basecamp', 'water', 'shelter', 'dangerZone', 'summit',
      'viewpoint', 'campsite', 'junction', 'default',
    ];

    // 1. Synchronously determine which icons are new.
    final iconsToLoad = iconNames
        .where((iconName) => !_loadedIcons.contains(iconName))
        .toList();

    // If there's nothing to load, exit early.
    if (iconsToLoad.isEmpty) {
      return;
    }

    // 2. Synchronously mark new icons as "in-progress" to prevent race conditions.
    // If a second call to _loadPoiIcons happens while the first is awaiting,
    // this ensures we don't try to load the same icons twice.
    _loadedIcons.addAll(iconsToLoad);

    // 3. Create and await the futures for only the necessary icons.
    final loadFutures = iconsToLoad.map((iconName) async {
      try {
        final ByteData bytes =
            await rootBundle.load('assets/icons/poi/$iconName.png');
        final Uint8List list = bytes.buffer.asUint8List();
        await _controller!.addImage('icon_$iconName', list);
        debugPrint('[MapLayer] Loaded icon: $iconName');
      } catch (e) {
        // If an icon fails to load, it remains in _loadedIcons for this session
        // to prevent repeated failed attempts. The map will use the fallback icon.
        debugPrint(
            '[MapLayer] Icon $iconName.png not found. Will use default.');
      }
    });

    await Future.wait(loadFutures);
  }

  /// Adds POI markers using symbols with dynamic icons based on PoiType
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

      // Ensure icons are loaded
      await _loadPoiIcons();

      final features = pois.map((poi) {
        // Convert PoiType enum to string name (e.g., PoiType.summit -> "summit")
        final typeString = poi.type.name;
        return {
          'type': 'Feature',
          'id': poi.id,
          'properties': {
            'name': poi.name,
            'type': typeString,
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

        // Symbol Layer with Dynamic Icon Logic matching PoiType enum names
        await _controller!.addSymbolLayer(
          poiSourceId,
          poiLayerId,
          SymbolLayerProperties(
            iconImage: [
              'match', ['get', 'type'],
              'basecamp', 'icon_basecamp',
              'water', 'icon_water',
              'shelter', 'icon_shelter',
              'dangerZone', 'icon_dangerZone',
              'summit', 'icon_summit',
              'viewpoint', 'icon_viewpoint',
              'campsite', 'icon_campsite',
              'junction', 'icon_junction',
              'icon_default' // Fallback
            ],
            iconSize: 1.0,
            iconAllowOverlap: true,
            textField: ['get', 'name'],
            textSize: 11,
            textOffset: [0, 1.5],
            textAnchor: 'top',
            textColor: '#000000',
            textHaloColor: '#ffffff',
            textHaloWidth: 1.5,
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

        /*
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
        */
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
    // True clustering is now supported by injecting sources into the style JSON
    // (via OfflineMapStyleHelper). We try to update data on the existing source.
    try {
      await _controller!.setGeoJsonSource(sourceId, geojson);
    } catch (_) {
      // Fallback: If source is missing (e.g. style didn't load correctly),
      // add it dynamically. Clustering will be lost in this fallback case.
      await _controller!.addGeoJsonSource(sourceId, geojson);
    }

    // 1. Individual markers (Non-clustered)
    await _controller!.addCircleLayer(
      sourceId,
      unclusteredLayerId,
      unclusteredCircleProps,
      filter: ['!has', 'point_count'],
    );

    // 2. Labels for individual markers
    await _controller!.addSymbolLayer(
      sourceId,
      unclusteredLabelLayerId,
      unclusteredLabelProps,
      filter: ['!has', 'point_count'],
    );

    // 3. Cluster Circles
    await _controller!.addCircleLayer(
      sourceId,
      clusterLayerId,
      CircleLayerProperties(
        circleColor: clusterColorHex,
        circleRadius: 18,
        circleStrokeWidth: 2,
        circleStrokeColor: '#ffffff',
      ),
      filter: ['has', 'point_count'],
    );

    // 4. Cluster Counts
    await _controller!.addSymbolLayer(
      sourceId,
      clusterCountLayerId,
      const SymbolLayerProperties(
        textField: ['get', 'point_count_abbreviated'],
        textSize: 12,
        textColor: '#ffffff',
        textAllowOverlap: true,
        textIgnorePlacement: true,
      ),
      filter: ['has', 'point_count'],
    );
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
            // textField: ['get', 'name'], // Disabled to prevent font crash
            iconImage: "marker-15",
            iconSize: 1.5,
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
            // textField: ['get', 'name'], // Disabled to prevent font crash
            iconImage: "marker-15",
            iconSize: 1.2,
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

  /// Draws the calculated route path on the map
  Future<void> drawRoute(List<LatLng> path) async {
    if (_controller == null || path.isEmpty) {
      // If empty, clear existing route
      await clearRoute();
      return;
    }

    try {
      final coordinates = path.map((p) => [p.longitude, p.latitude]).toList();
      final geoJson = {
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {},
            'geometry': {
              'type': 'LineString',
              'coordinates': coordinates,
            }
          }
        ]
      };

      if (!_routeLayerAdded) {
        await _controller!.addGeoJsonSource(routeSourceId, geoJson);
        await _controller!.addLineLayer(
          routeSourceId,
          routeLayerId,
          LineLayerProperties(
            lineColor: '#00BFFF', // Deep Sky Blue
            lineWidth: 4.0,
            lineDasharray: [2, 2], // Dashed line
            lineCap: 'round',
            lineJoin: 'round',
          ),
        );
        _routeLayerAdded = true;
      } else {
        await _controller!.setGeoJsonSource(routeSourceId, geoJson);
      }
    } catch (e) {
      debugPrint('[MapLayerService] Error drawing route: $e');
    }
  }

  /// Clears the route from the map
  Future<void> clearRoute() async {
    if (_controller == null || !_routeLayerAdded) return;
    try {
      // Set empty source instead of removing layer to avoid flickering/re-adding overhead
      final emptyGeoJson = {
        'type': 'FeatureCollection',
        'features': <Map<String, dynamic>>[]
      };
      await _controller!.setGeoJsonSource(routeSourceId, emptyGeoJson);
    } catch (e) {
      debugPrint('[MapLayerService] Error clearing route: $e');
    }
  }
}

/// Singleton provider
final mapLayerService = MapLayerService();
