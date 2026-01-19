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
}

// Converter for PoiType <-> Int
class PoiTypeConverter extends TypeConverter<PoiType, int> {
  const PoiTypeConverter();

  @override
  PoiType fromSql(int fromDb) {
    return PoiType.values[fromDb];
  }

  @override
  int toSql(PoiType value) {
    return value.index;
  }
}

// 3D Point for Trails (Lat, Lng, Elevation)
class TrailPoint {
  final double lat;
  final double lng;
  final double elevation;

  // Optimization: Store the raw list from DB/JSON to avoid re-allocation during map drawing
  final List<dynamic>? _rawSource;

  const TrailPoint(this.lat, this.lng, this.elevation) : _rawSource = null;

  TrailPoint.fromChunk(this.lat, this.lng, this.elevation, this._rawSource);

  // Helper to convert to LatLng for Map display
  LatLng toLatLng() => LatLng(lat, lng);

  // Return the raw list if available to avoid allocation
  // GeoJSON uses [lng, lat, ele] order
  List<dynamic> get coordinates => _rawSource ?? [lng, lat, elevation];
}

// Converter for List<TrailPoint> <-> JSON String [lng, lat, alt]
class GeoJsonConverter extends TypeConverter<List<TrailPoint>, String> {
  const GeoJsonConverter();

  @override
  List<TrailPoint> fromSql(String fromDb) {
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList.map((chunk) {
      // Chunk: [lng, lat, alt] (GeoJSON standard + Z)
      // Fallback: [lng, lat] -> alt = 0
      final c = chunk as List;
      final lng = (c[0] as num).toDouble();
      final lat = (c[1] as num).toDouble();
      final alt = (c.length > 2) ? (c[2] as num).toDouble() : 0.0;
      // Pass the raw chunk list to TrailPoint to reuse it
      return TrailPoint.fromChunk(lat, lng, alt, c);
    }).toList();
  }

  @override
  String toSql(List<TrailPoint> value) {
    final jsonList = value
        .map((point) => [
              double.parse(point.lng.toStringAsFixed(6)),
              double.parse(point.lat.toStringAsFixed(6)),
              double.parse(point.elevation.toStringAsFixed(1))
            ])
        .toList();
    return jsonEncode(jsonList);
  }
}
