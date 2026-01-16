import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

/// Model containing route calculation results
class RouteResult {
  final bool success;
  final List<LatLng> points;
  final double distance; // meters
  final int time; // milliseconds
  final double ascend; // meters
  final double descend; // meters
  final String? error;

  RouteResult({
    required this.success,
    this.points = const [],
    this.distance = 0,
    this.time = 0,
    this.ascend = 0,
    this.descend = 0,
    this.error,
  });

  factory RouteResult.fromMap(Map<dynamic, dynamic> map) {
    final success = map['success'] as bool? ?? false;

    if (!success) {
      return RouteResult(
        success: false,
        error: map['error'] as String?,
      );
    }

    final pointsList = (map['points'] as List?)?.map((p) {
          final coords = p as List;
          return LatLng(
            coords[0] as double,
            coords[1] as double,
          );
        }).toList() ??
        [];

    return RouteResult(
      success: true,
      points: pointsList,
      distance: (map['distance'] as num?)?.toDouble() ?? 0,
      time: (map['time'] as num?)?.toInt() ?? 0,
      ascend: (map['ascend'] as num?)?.toDouble() ?? 0,
      descend: (map['descend'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Formats the distance in a human-readable way
  String get formattedDistance {
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
    return '${distance.toStringAsFixed(0)} m';
  }

  /// Formats the time in a human-readable way
  String get formattedTime {
    final totalMinutes = (time / 60000).round();
    if (totalMinutes >= 60) {
      final hours = totalMinutes ~/ 60;
      final mins = totalMinutes % 60;
      return '${hours}h ${mins}m';
    }
    return '${totalMinutes}m';
  }
}

/// Native routing service that bridges to GraphHopper via MethodChannel
class NativeRoutingService {
  static const MethodChannel _channel =
      MethodChannel('com.example.pandu/routing');

  bool _isLoaded = false;

  /// Loads the routing graph from the specified path
  /// @param path The absolute path to the GraphHopper graph folder
  Future<bool> loadRoutingGraph(String path) async {
    try {
      final result = await _channel.invokeMethod('loadGraph', {'path': path});
      _isLoaded = (result as Map)['success'] == true;
      return _isLoaded;
    } on PlatformException catch (e) {
      debugPrint('Error loading routing graph: ${e.message}');
      _isLoaded = false;
      return false;
    }
  }

  /// Calculates a route between two points
  Future<RouteResult> calculateRoute(LatLng start, LatLng end) async {
    try {
      final result = await _channel.invokeMethod('calculateRoute', {
        'startLat': start.latitude,
        'startLon': start.longitude,
        'endLat': end.latitude,
        'endLon': end.longitude,
      });
      return RouteResult.fromMap(result as Map);
    } on PlatformException catch (e) {
      return RouteResult(
        success: false,
        error: e.message ?? 'Platform error calculating route',
      );
    }
  }

  /// Checks if the routing engine is ready
  Future<bool> isReady() async {
    try {
      final result = await _channel.invokeMethod('isReady');
      return result as bool? ?? false;
    } on PlatformException {
      return false;
    }
  }

  /// Returns the local loaded state (without native call)
  bool get isLoaded => _isLoaded;
}

/// Singleton instance for easy access
final nativeRoutingService = NativeRoutingService();
