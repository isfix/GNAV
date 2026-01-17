import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gpx/gpx.dart';
import 'package:drift/drift.dart' as drift;
import 'package:maplibre_gl/maplibre_gl.dart';
import '../../data/local/db/app_database.dart';
import '../../data/local/db/converters.dart';
import '../utils/geo_math.dart';

class TrackLoaderService {
  final AppDatabase _db;

  TrackLoaderService(this._db);

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
      final xmlString = await rootBundle.loadString(assetPath);
      final gpx = GpxReader().fromString(xmlString);

      // 2. Process Tracks -> Trails table
      if (gpx.trks.isNotEmpty) {
        await _processTrack(gpx, mountainId, trailId);
      }

      // 3. Process Waypoints -> PointsOfInterest table
      if (gpx.wpts.isNotEmpty) {
        await _processWaypoints(gpx.wpts, mountainId, trailId);
      }

      debugPrint('[TrackLoader] Loaded GPX: $assetPath');
    } catch (e) {
      debugPrint('[TrackLoader] Error loading GPX: $e');
      rethrow;
    }
  }

  /// Process GPX tracks into Trails table with spatial bounds
  Future<void> _processTrack(Gpx gpx, String mountainId, String trailId) async {
    final trk = gpx.trks.first;
    final trailName = trk.name ?? trailId;

    // Collect all points from all segments
    final allPoints = <Wpt>[];
    for (final seg in trk.trksegs) {
      allPoints.addAll(seg.trkpts);
    }

    if (allPoints.isEmpty) return;

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

    final dbPoints = <TrailPoint>[];

    for (int i = 0; i < allPoints.length; i++) {
      final p = allPoints[i];
      final lat = p.lat ?? 0.0;
      final lon = p.lon ?? 0.0;
      final ele = p.ele ?? 0.0;

      // Convert to TrailPoint for DB
      dbPoints.add(TrailPoint(lat, lon, ele));

      // Update spatial bounds
      if (lat < minLat) minLat = lat;
      if (lat > maxLat) maxLat = lat;
      if (lon < minLng) minLng = lon;
      if (lon > maxLng) maxLng = lon;

      // Detect summit (highest point)
      if (ele > maxElevation) {
        maxElevation = ele;
        summitIndex = i;
      }

      // Calculate distance and elevation gain
      if (i > 0) {
        final prev = allPoints[i - 1];
        final d = GeoMath.distanceMeters(
          LatLng(prev.lat ?? 0, prev.lon ?? 0),
          LatLng(lat, lon),
        );
        totalDist += d;

        final dEle = ele - (prev.ele ?? 0);
        if (dEle > 0) {
          elevationGain += dEle;
        }
      }
    }

    // Insert into Trails table
    final trailEntry = TrailsCompanion(
      id: drift.Value(trailId),
      mountainId: drift.Value(mountainId),
      name: drift.Value(trailName),
      geometryJson: drift.Value(dbPoints),
      difficulty: const drift.Value(3),
      distance: drift.Value(totalDist),
      elevationGain: drift.Value(elevationGain),
      summitIndex: drift.Value(summitIndex),
      isOfficial: const drift.Value(true),
      // Spatial bounds for indexed lookups
      minLat: drift.Value(minLat),
      maxLat: drift.Value(maxLat),
      minLng: drift.Value(minLng),
      maxLng: drift.Value(maxLng),
    );

    await _db.navigationDao.insertTrail(trailEntry);
    debugPrint(
        '[TrackLoader] Trail saved: $trailName (${dbPoints.length} points, ${(totalDist / 1000).toStringAsFixed(1)}km)');
  }

  /// Process GPX waypoints into PointsOfInterest table with Smart Tagging
  Future<void> _processWaypoints(
      List<Wpt> waypoints, String mountainId, String trailId) async {
    for (final wpt in waypoints) {
      final name = wpt.name ?? 'Unknown';
      final lat = wpt.lat ?? 0.0;
      final lon = wpt.lon ?? 0.0;
      final ele = wpt.ele ?? 0.0;

      if (lat == 0 || lon == 0) continue;

      // Smart Tagging: Determine POI type from name
      final poiType = _categorizeWaypoint(name);

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
      );

      await _db.into(_db.pointsOfInterest).insertOnConflictUpdate(poiEntry);
      debugPrint('[TrackLoader] POI saved: $name (${poiType.name})');
    }
  }

  /// Smart Tagging: Categorizes waypoints based on name patterns
  PoiType _categorizeWaypoint(String name) {
    final lowerName = name.toLowerCase();

    // Basecamp patterns (Indonesian + English)
    if (lowerName.contains('basecamp') ||
        lowerName.contains('base camp') ||
        lowerName.contains('pos pendakian') ||
        lowerName.contains('starting point')) {
      return PoiType.basecamp;
    }

    // Summit patterns
    if (lowerName.contains('summit') ||
        lowerName.contains('puncak') ||
        lowerName.contains('top') ||
        lowerName.contains('peak')) {
      return PoiType.summit;
    }

    // Water source patterns
    if (lowerName.contains('water') ||
        lowerName.contains('sumber air') ||
        lowerName.contains('mata air') ||
        lowerName.contains('spring')) {
      return PoiType.water;
    }

    // Emergency/danger patterns
    if (lowerName.contains('emergency') ||
        lowerName.contains('danger') ||
        lowerName.contains('bahaya')) {
      return PoiType.dangerZone;
    }

    // Default: Shelter (covers Pos, Viewpoint, Rest Area, etc.)
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
