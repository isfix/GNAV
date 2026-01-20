import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NativeBridge {
  static const MethodChannel _commandChannel =
      MethodChannel('com.pandu.nav/commands');
  static const EventChannel _updateChannel =
      EventChannel('com.pandu.nav/updates');

  static Future<void> startService() async {
    await _commandChannel.invokeMethod('startService');
  }

  static Future<void> stopService() async {
    await _commandChannel.invokeMethod('stopService');
  }

  static Future<int> loadGpx(String filePath, String mountainId) async {
    final int count = await _commandChannel.invokeMethod('loadGpx', {
      'filePath': filePath,
      'mountainId': mountainId,
    });
    return count;
  }

  static Stream<Map<String, dynamic>> get navigationUpdates {
    return _updateChannel.receiveBroadcastStream().map((event) {
      if (event is String) {
        return jsonDecode(event) as Map<String, dynamic>;
      }
      return {};
    });
  }
}

final nativeNavigationProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return NativeBridge.navigationUpdates;
});
