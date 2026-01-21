import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/db/app_database.dart';
import '../../../data/local/db/converters.dart';

class NativeBridge {
  static const MethodChannel _commandChannel =
      MethodChannel('com.pandu.nav/commands');
  static const EventChannel _updateChannel =
      EventChannel('com.pandu.nav/updates');

  static Future<void> startService({String? trailId}) async {
    await _commandChannel.invokeMethod('startService', {'trailId': trailId});
  }

  static Future<void> stopService() async {
    await _commandChannel.invokeMethod('stopService');
  }

  static Future<List<Trail>> getTrails(String mountainId) async {
    try {
      final String jsonStr = await _commandChannel.invokeMethod('getTrails', {
        'mountainId': mountainId,
      });
      return await compute(_parseTrailsList, jsonStr);
    } catch (e) {
      print('Error parsing native trails: $e');
      return [];
    }
  }

  static Stream<Map<String, dynamic>> get navigationUpdates {
    return _updateChannel.receiveBroadcastStream().map((event) {
      if (event is Map) {
        return Map<String, dynamic>.from(event);
      }
      if (event is String) {
        try {
          return jsonDecode(event) as Map<String, dynamic>;
        } catch (_) {}
      }
      return {};
    });
  }
}

// Top-level function to be run in isolate
List<Trail> _parseTrailsList(String jsonStr) {
  final List<dynamic> list = jsonDecode(jsonStr);
  return list.map((e) => _parseNativeTrail(e)).toList();
}

Trail _parseNativeTrail(dynamic rawJson) {
  final Map<String, dynamic> json =
      (rawJson is String) ? jsonDecode(rawJson) : rawJson;

  List<TrailPoint> geometry = [];
  if (json['geometryJson'] != null) {
    try {
      final List<dynamic> rawPoints = jsonDecode(json['geometryJson']);
      geometry = rawPoints.map((p) {
        final lat = (p[1] as num).toDouble();
        final lng = (p[0] as num).toDouble();
        final ele = (p.length > 2 ? (p[2] as num).toDouble() : 0.0);
        return TrailPoint(lat, lng, ele);
      }).toList();
    } catch (e) {
      print("Error parsing geometry: $e");
    }
  }

  return Trail(
    id: json['id'],
    mountainId: json['mountainId'],
    name: json['name'],
    distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
    elevationGain: (json['elevationGain'] as num?)?.toDouble() ?? 0.0,
    difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
    geometryJson: geometry,
    minLat: (json['minLat'] as num?)?.toDouble() ?? 0,
    maxLat: (json['maxLat'] as num?)?.toDouble() ?? 0,
    minLng: (json['minLng'] as num?)?.toDouble() ?? 0,
    maxLng: (json['maxLng'] as num?)?.toDouble() ?? 0,
    isOfficial: true,
    summitIndex: 0,
  );
}

final nativeNavigationProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return NativeBridge.navigationUpdates;
});
