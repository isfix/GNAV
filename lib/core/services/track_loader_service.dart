import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gpx/gpx.dart';
import 'package:drift/drift.dart' as drift;
import 'package:xml/xml.dart' as xml;
import '../../data/local/db/app_database.dart';
import '../../data/local/db/converters.dart';
import '../utils/geo_math.dart';

/// Container for data parsed from a GPX file in an isolate.
class GpxParsingResult {
  final Gpx gpx;
  final Map<int, TrackPointExtensions> extensions;

  GpxParsingResult(this.gpx, this.extensions);
}

/// Unified parsing function to run in an isolate.
GpxParsingResult _parseGpxAndExtensionsIsolate(String rawXml) {
  // 1. Parse core GPX data
  final gpx = GpxReader().fromString(rawXml);

  // 2. Parse extensions from the same XML document
  final extensions = <int, TrackPointExtensions>{};
  try {
    final document = xml.XmlDocument.parse(rawXml);
    final trkpts = document.findAllElements('trkpt');
    int index = 0;
    for (final trkpt in trkpts) {
      String? surface;
      String? sacScale;
      String? highway;
      final extensionsNode = trkpt.findElements('extensions').firstOrNull;
      if (extensionsNode != null) {
        for (final child
            in extensionsNode.descendants.whereType<xml.XmlElement>()) {
          final localName = child.name.local.toLowerCase();
          final text = child.innerText.trim();
          if (localName == 'surface' && text.isNotEmpty) {
            surface = text;
          } else if (localName == 'sac_scale' && text.isNotEmpty) {
            sacScale = text;
          } else if (localName == 'highway' && text.isNotEmpty) {
            highway = text;
          }
        }
      }
      if (surface != null || sacScale != null || highway != null) {
        extensions[index] = TrackPointExtensions(
          surface: surface,
          sacScale: sacScale,
          highway: highway,
        );
      }
      index++;
    }
  } catch (e) {
    debugPrint('[TrackLoader] Error parsing extensions in isolate: $e');
  }

  return GpxParsingResult(gpx, extensions);
}

/// Parsed extension data from GPX track points
class TrackPointExtensions {
  final String? surface;
  final String? sacScale;
  final String? highway;

  const TrackPointExtensions({this.surface, this.sacScale, this.highway});
}

class TrackLoaderService {
  final AppDatabase _db;
  final AssetBundle _bundle;

  TrackLoaderService(this._db, {AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  /// Loads a complete GPX file from assets, processing both Tracks and Waypoints.
  ///
  /// - Tracks (`<trk>`) are saved to the Trails table with spatial bounds.
  /// - Waypoints (`<wpt>`) are saved to PointsOfInterest with Smart Tagging.
  ///
  /// [assetPath] - Full asset path (e.g., 'assets/gpx/merbabu/Selo.gpx')
  /// [mountainId] - ID of the mountain region (e.g., 'merbabu')
  /// [trailId] - Unique trail ID (e.g., 'merbabu_selo')
  Future<void> loadFullGpxData(
    String assetPath,
    String mountainId,
    String trailId,
  ) async {
    try {
      // 1. Read & Parse GPX
      final xmlString = await _bundle.loadString(assetPath);

      // Validation: Check for empty file
      if (xmlString.trim().isEmpty) {
        debugPrint('[TrackLoader] Error: Empty GPX file: $assetPath');
        return;
      }

      // GpxReader().fromString is a CPU-bound synchronous operation that can freeze the UI.
      // We run it in a separate isolate to avoid blocking the main thread.
      final parsingResult =
          await compute(_parseGpxAndExtensionsIsolate, xmlString);
      final gpx = parsingResult.gpx;

      // Validation: Check for empty content
      if (gpx.trks.isEmpty && gpx.wpts.isEmpty) {
        debugPrint(
            '[TrackLoader] Warning: GPX has no tracks or waypoints: $assetPath');
        return;
      }

      // 2. Process Tracks -> Trails table
      if (gpx.trks.isNotEmpty) {
        // We need raw XML to extract extensions (gpx package doesn't expose them)
        await _processTrackWithExtensions(
            gpx, parsingResult.extensions, mountainId, trailId);
      }

      // 3. Process Waypoints -> PointsOfInterest table
      if (gpx.wpts.isNotEmpty) {
        await _processWaypoints(gpx.wpts, mountainId, trailId);
      }

      debugPrint('[TrackLoader] Loaded GPX: $assetPath');
    } on FormatException catch (e) {
      debugPrint('[TrackLoader] Invalid GPX format in $assetPath: $e');
    } catch (e, stackTrace) {
      debugPrint('[TrackLoader] Error loading GPX $assetPath: $e');
      debugPrint('[TrackLoader] StackTrace: $stackTrace');
      rethrow;
    }
  }

  /// Process GPX tracks with extension data extraction
  Future<void> _processTrackWithExtensions(
    Gpx gpx,
    Map<int, TrackPointExtensions> extensionsMap,
    String mountainId,
    String trailId,
  ) async {
    final trk = gpx.trks.first;
    final trailName = trk.name ?? trailId;

    // Collect all points from all segments
    final allPoints = <Wpt>[];
    for (final seg in trk.trksegs) {
      allPoints.addAll(seg.trkpts);
    }

    if (allPoints.isEmpty) {
      debugPrint('[TrackLoader] Warning: Track has no points');
      return;
    }

    // Calculate stats and spatial bounds
    double totalDist = 0;
    double elevationGain = 0;
    double maxElevation = -double.infinity;
    int summitIndex = 0;

    // Spatial bounds for O(1) lookups
    double minLat = 90.0;
    double maxLat = -90.0;
    double minLng = 180.0;
    double maxLng = -180.0;

    // Track difficulty from SAC scales
    final sacScales = <SacScale>[];

    final dbPoints = <TrailPoint>[];

    for (int i = 0; i < allPoints.length; i++) {
      final p = allPoints[i];
      final lat = p.lat ?? 0.0;
      final lon = p.lon ?? 0.0;
      final ele = p.ele ?? 0.0;

      // Skip invalid points
      if (lat == 0.0 && lon == 0.0) continue;

      // Get extension data for this point (by index)
      final ext = extensionsMap[i] ?? const TrackPointExtensions();
      final sacScale = parseSacScale(ext.sacScale);
      if (sacScale != null) {
        sacScales.add(sacScale);
      }

      // Convert to TrailPoint for DB with extended metadata
      dbPoints.add(TrailPoint(
        lat,
        lon,
        ele,
        surface: ext.surface,
        sacScale: sacScale,
        highway: ext.highway,
      ));

      // Update spatial bounds
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lon < minLng) minLng = lon;
      if (lon > maxLng) maxLng = lon;

      // Detect summit (highest point)
      if (ele > maxElevation) {
        maxElevation = ele;
        summitIndex = dbPoints.length - 1;
      }

      // Calculate distance and elevation gain using Haversine
      if (i > 0) {
        final prev = allPoints[i - 1];
        final d = GeoMath.distanceMetersRaw(
          prev.lat ?? 0,
          prev.lon ?? 0,
          lat,
          lon,
        );
        totalDist += d;

        final dEle = ele - (prev.ele ?? 0);
        if (dEle > 0) {
          elevationGain += dEle;
        }
      }
    }

    // Calculate difficulty from collected SAC scales
    final difficulty = _calculateOverallDifficulty(sacScales);

    // Insert into Trails table
    final trailEntry = TrailsCompanion(
      id: drift.Value(trailId),
      mountainId: drift.Value(mountainId),
      name: drift.Value(trailName),
      geometryJson: drift.Value(dbPoints),
      difficulty: drift.Value(difficulty),
      distance: drift.Value(totalDist),
      elevationGain: drift.Value(elevationGain),
      summitIndex: drift.Value(summitIndex),
      isOfficial: const drift.Value(true),
      // Spatial bounds for indexed lookups
      minLat: drift.Value(minLat),
      maxLat: drift.Value(maxLat),
      minLng: drift.Value(minLng),
      maxLng: drift.Value(maxLng),
      startLat: drift.Value(dbPoints.isNotEmpty ? dbPoints.first.lat : null),
      startLng: drift.Value(dbPoints.isNotEmpty ? dbPoints.first.lng : null),
    );

    await _db.navigationDao.insertTrail(trailEntry);
    debugPrint(
        '[TrackLoader] Trail saved: $trailName (${dbPoints.length} points, ${(totalDist / 1000).toStringAsFixed(1)}km, difficulty: $difficulty)');
  }

  /// Calculate overall trail difficulty from collected SAC scales
  int _calculateOverallDifficulty(List<SacScale> scales) {
    if (scales.isEmpty) return 2; // Default moderate

    // Use the maximum difficulty encountered (most challenging segment)
    int maxDifficulty = 1;
    for (final scale in scales) {
      final diff = sacScaleToDifficulty(scale);
      if (diff > maxDifficulty) {
        maxDifficulty = diff;
      }
    }
    return maxDifficulty;
  }

  /// Process GPX waypoints into PointsOfInterest table with Smart Tagging
  Future<void> _processWaypoints(
      List<Wpt> waypoints, String mountainId, String trailId) async {
    await _db.batch((batch) {
      for (final wpt in waypoints) {
        final name = wpt.name ?? 'Unknown';
        final lat = wpt.lat ?? 0.0;
        final lon = wpt.lon ?? 0.0;
        final ele = wpt.ele ?? 0.0;

        // Get description from desc or cmt fields
        final description = wpt.desc ?? wpt.cmt ?? '';

        // Get sym tag (GPX symbol) for icon type
        final sym = wpt.sym ?? '';

        if (lat == 0 || lon == 0) continue;

        // Smart Tagging: Prioritize sym tag, fallback to name/description heuristics
        final poiType = sym.isNotEmpty
            ? _symToPoiType(sym)
            : _categorizeWaypoint(name, description);

        // Generate unique ID
        final poiId =
            '${mountainId}_${name.toLowerCase().replaceAll(' ', '_').replaceAll(RegExp(r'[^a-z0-9_]'), '')}';

        final poiEntry = PointsOfInterestCompanion(
          id: drift.Value(poiId),
          mountainId: drift.Value(mountainId),
          name: drift.Value(name),
          lat: drift.Value(lat),
          lng: drift.Value(lon),
          type: drift.Value(poiType),
          elevation: drift.Value(ele),
          metadataJson: drift.Value(
              description.isNotEmpty ? '{"desc":"$description"}' : null),
        );

        batch.insert(_db.pointsOfInterest, poiEntry,
            onConflict: drift.DoUpdate((_) => poiEntry));
      }
    });
    debugPrint('[TrackLoader] POIs saved: ${waypoints.length}');
  }

  /// Maps GPX <sym> tag values to PoiType for icon selection
  PoiType _symToPoiType(String sym) {
    final lowerSym = sym.toLowerCase();

    // Standard GPX symbol mappings
    switch (lowerSym) {
      case 'summit':
      case 'mountain':
        return PoiType.summit;
      case 'water source':
      case 'drinking water':
      case 'water':
        return PoiType.water;
      case 'campground':
      case 'camp':
      case 'tent':
        return PoiType.campsite;
      case 'lodge':
      case 'hotel':
      case 'residence':
      case 'house':
        return PoiType.basecamp;
      case 'binoculars':
      case 'scenic area':
      case 'viewpoint':
        return PoiType.viewpoint;
      case 'forest':
      case 'tree':
      case 'park':
        return PoiType.shelter;
      case 'danger':
      case 'skull and crossbones':
      case 'caution':
        return PoiType.dangerZone;
      case 'trail head':
      case 'trailhead':
        return PoiType.junction;
      default:
        // Try to match partial strings
        if (lowerSym.contains('water')) return PoiType.water;
        if (lowerSym.contains('camp')) return PoiType.campsite;
        if (lowerSym.contains('summit') || lowerSym.contains('peak'))
          return PoiType.summit;
        if (lowerSym.contains('lodge') || lowerSym.contains('base'))
          return PoiType.basecamp;
        return PoiType.shelter; // Default fallback
    }
  }

  /// Smart Tagging: Categorizes waypoints based on name and description patterns
  PoiType _categorizeWaypoint(String name, String description) {
    final lowerName = name.toLowerCase();
    final lowerDesc = description.toLowerCase();
    final combined = '$lowerName $lowerDesc';

    // Summit patterns
    if (combined.contains('summit') ||
        combined.contains('puncak') ||
        combined.contains('top') ||
        combined.contains('peak') ||
        combined.contains('syarif')) {
      return PoiType.summit;
    }

    // Basecamp patterns (Indonesian + English)
    if (combined.contains('basecamp') ||
        combined.contains('base camp') ||
        combined.contains('pos pendakian') ||
        combined.contains('starting point') ||
        combined.contains('pendaftaran')) {
      return PoiType.basecamp;
    }

    // Water source patterns
    if (combined.contains('water') ||
        combined.contains('sumber air') ||
        combined.contains('mata air') ||
        combined.contains('spring') ||
        combined.contains('telaga')) {
      return PoiType.water;
    }

    // Emergency/danger patterns
    if (combined.contains('emergency') ||
        combined.contains('danger') ||
        combined.contains('bahaya') ||
        combined.contains('evac')) {
      return PoiType.dangerZone;
    }

    // Viewpoint patterns
    if (combined.contains('view') ||
        combined.contains('lookout') ||
        combined.contains('panorama') ||
        combined.contains('puncak mati')) {
      return PoiType.viewpoint;
    }

    // Campsite patterns
    if (combined.contains('camp') ||
        combined.contains('bivouac') ||
        combined.contains('shelter') ||
        combined.contains('pos')) {
      return PoiType.campsite;
    }

    // Junction patterns
    if (combined.contains('junction') ||
        combined.contains('intersection') ||
        combined.contains('simpang') ||
        combined.contains('fork')) {
      return PoiType.junction;
    }

    // Default: Shelter (covers Rest Area, etc.)
    return PoiType.shelter;
  }

  /// Legacy method - kept for backward compatibility
  /// Prefer using loadFullGpxData instead
  Future<void> loadGpxTrack(
    String assetPath,
    String mountainId,
    String trailId,
    String trailName,
  ) async {
    await loadFullGpxData(assetPath, mountainId, trailId);
  }
}
