import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

// Enum for POI Types
enum PoiType {
  basecamp,
  water,
  shelter,
  dangerZone,
  summit,
  viewpoint, // NEW: Scenic lookout
  campsite, // NEW: Overnight camping area
  junction, // NEW: Trail intersection
}

// Converter for PoiType <-> Int
class PoiTypeConverter extends TypeConverter<PoiType, int> {
  const PoiTypeConverter();

  @override
  PoiType fromSql(int fromDb) {
    if (fromDb < 0 || fromDb >= PoiType.values.length) {
      return PoiType.shelter; // Default fallback for unknown types
    }
    return PoiType.values[fromDb];
  }

  @override
  int toSql(PoiType value) {
    return value.index;
  }
}

/// SAC Hiking Scale (Swiss Alpine Club)
/// Used to classify trail difficulty
enum SacScale {
  hiking, // T1: Easy walking paths
  mountainHiking, // T2: Mountain hiking
  demandingMountainHiking, // T3: Demanding mountain hiking
  alpineHiking, // T4: Alpine hiking
  demandingAlpineHiking, // T5: Demanding alpine hiking
  difficultAlpineHiking, // T6: Difficult alpine hiking
}

/// Parses SAC scale string to enum
SacScale? parseSacScale(String? value) {
  if (value == null) return null;
  switch (value.toLowerCase()) {
    case 'hiking':
      return SacScale.hiking;
    case 'mountain_hiking':
      return SacScale.mountainHiking;
    case 'demanding_mountain_hiking':
      return SacScale.demandingMountainHiking;
    case 'alpine_hiking':
      return SacScale.alpineHiking;
    case 'demanding_alpine_hiking':
      return SacScale.demandingAlpineHiking;
    case 'difficult_alpine_hiking':
      return SacScale.difficultAlpineHiking;
    default:
      return null;
  }
}

/// Converts SAC scale to difficulty 1-5
int sacScaleToDifficulty(SacScale? scale) {
  if (scale == null) return 1;
  switch (scale) {
    case SacScale.hiking:
      return 1;
    case SacScale.mountainHiking:
      return 2;
    case SacScale.demandingMountainHiking:
      return 3;
    case SacScale.alpineHiking:
      return 4;
    case SacScale.demandingAlpineHiking:
    case SacScale.difficultAlpineHiking:
      return 5;
  }
}

// 3D Point for Trails with extended metadata
class TrailPoint {
  final double lat;
  final double lng;
  final double elevation;

  // Extended metadata from GPX extensions (nullable for backward compatibility)
  final String? surface; // e.g., "unpaved", "gravel", "rock", "ground"
  final SacScale? sacScale; // SAC hiking difficulty
  final String? highway; // e.g., "footway", "path", "track"

  // Optimization: Store the raw list from DB/JSON to avoid re-allocation during map drawing
  final List<dynamic>? _rawSource;

  const TrailPoint(
    this.lat,
    this.lng,
    this.elevation, {
    this.surface,
    this.sacScale,
    this.highway,
  }) : _rawSource = null;

  TrailPoint.fromChunk(
    this.lat,
    this.lng,
    this.elevation,
    this._rawSource, {
    this.surface,
    this.sacScale,
    this.highway,
  });

  // Helper to convert to LatLng for Map display
  LatLng toLatLng() => LatLng(lat, lng);

  // Return the raw list if available to avoid allocation
  // GeoJSON uses [lng, lat, ele] order
  // Extended format: [lng, lat, ele, surface?, sacScaleIndex?, highway?]
  List<dynamic> get coordinates => _rawSource ?? [lng, lat, elevation];

  /// Returns difficulty 1-5 based on SAC scale
  int get difficulty => sacScaleToDifficulty(sacScale);

  /// Check if this point has extended metadata
  bool get hasExtendedData =>
      surface != null || sacScale != null || highway != null;
}

// Converter for List<TrailPoint> <-> JSON String
// Format: [lng, lat, alt] or extended [lng, lat, alt, surface, sacScaleIndex, highway]
class GeoJsonConverter extends TypeConverter<List<TrailPoint>, String> {
  const GeoJsonConverter();

  @override
  List<TrailPoint> fromSql(String fromDb) {
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList.map((chunk) {
      final c = chunk as List;
      final lng = (c[0] as num).toDouble();
      final lat = (c[1] as num).toDouble();
      final alt = (c.length > 2) ? (c[2] as num).toDouble() : 0.0;

      // Extended fields (backward compatible)
      String? surface;
      SacScale? sacScale;
      String? highway;

      if (c.length > 3 && c[3] != null) {
        surface = c[3] as String?;
      }
      if (c.length > 4 && c[4] != null) {
        final sacIndex = c[4] as int?;
        if (sacIndex != null &&
            sacIndex >= 0 &&
            sacIndex < SacScale.values.length) {
          sacScale = SacScale.values[sacIndex];
        }
      }
      if (c.length > 5 && c[5] != null) {
        highway = c[5] as String?;
      }

      return TrailPoint.fromChunk(
        lat,
        lng,
        alt,
        c,
        surface: surface,
        sacScale: sacScale,
        highway: highway,
      );
    }).toList();
  }

  @override
  String toSql(List<TrailPoint> value) {
    final jsonList = value.map((point) {
      // Only include extended fields if they exist (saves space)
      if (point.hasExtendedData) {
        return [
          double.parse(point.lng.toStringAsFixed(6)),
          double.parse(point.lat.toStringAsFixed(6)),
          double.parse(point.elevation.toStringAsFixed(1)),
          point.surface,
          point.sacScale?.index,
          point.highway,
        ];
      } else {
        // Compact format for points without extended data
        return [
          double.parse(point.lng.toStringAsFixed(6)),
          double.parse(point.lat.toStringAsFixed(6)),
          double.parse(point.elevation.toStringAsFixed(1)),
        ];
      }
    }).toList();
    return jsonEncode(jsonList);
  }
}
