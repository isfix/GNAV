import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/foundation.dart';

class HapticCompassController {
  final bool _isVibrating = false;
  DateTime _lastHapticTime = DateTime.now();

  // Threshold angle in degrees (e.g., 10 degrees cone)
  static const double targetCone = 10.0;

  Future<void> checkHeading(double currentHeading, double targetBearing) async {
    // 1. Calculate Delta
    double diff = (currentHeading - targetBearing).abs();
    // Normalize to 0-180
    if (diff > 180) diff = 360 - diff;

    // 2. Check Cone
    if (diff <= targetCone) {
      await _triggerHeartbeat();
    }
  }

  Future<void> _triggerHeartbeat() async {
    // Throttle: Don't Spam
    if (DateTime.now().difference(_lastHapticTime).inMilliseconds < 1000) {
      return;
    }
    _lastHapticTime = DateTime.now();

    // Check capability
    if (await Vibration.hasVibrator() ?? false) {
      // "Heartbeat" pattern: beat... beat...
      Vibration.vibrate(pattern: [0, 50, 100, 50]);
    }
  }
}
