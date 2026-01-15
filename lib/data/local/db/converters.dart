import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:latlong2/latlong.dart';

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

  const TrailPoint(this.lat, this.lng, this.elevation);

  // Helper to convert to LatLng for Map display
  LatLng toLatLng() => LatLng(lat, lng);
}

// Converter for List<TrailPoint> <-> JSON String [lng, lat, alt]
class GeoJsonConverter extends TypeConverter<List<TrailPoint>, String> {
  const GeoJsonConverter();

  @override
  @override
  List<TrailPoint> fromSql(String fromDb) {
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList.map((chunk) {
      // Chunk: [lng, lat, alt] (GeoJSON standard + Z)
      // Fallback: [lng, lat] -> alt = 0
      final lng = chunk[0] as double;
      final lat = chunk[1] as double;
      final alt = (chunk.length > 2) ? (chunk[2] as double) : 0.0;
      return TrailPoint(lat, lng, alt);
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
