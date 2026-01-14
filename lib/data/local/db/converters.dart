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

// Converter for List<LatLng> <-> JSON String (for Trail Geometry)
class GeoJsonConverter extends TypeConverter<List<LatLng>, String> {
  const GeoJsonConverter();

  @override
  List<LatLng> fromSql(String fromDb) {
    final List<dynamic> jsonList = jsonDecode(fromDb);
    return jsonList.map((chunk) {
      // Expecting chunk to be [longitude, latitude] (GeoJSON standard) or [lat, lng]
      // Project context says: [[110.4, -7.5], ...] which is [lng, lat]
      return LatLng(chunk[1] as double, chunk[0] as double);
    }).toList();
  }

  @override
  String toSql(List<LatLng> value) {
    final jsonList = value.map((point) => [point.longitude, point.latitude]).toList();
    return jsonEncode(jsonList);
  }
}
