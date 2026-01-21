import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'dart:async';
import 'dart:math';

enum GpsMode {
  trekking, // High Accuracy, ~10s update
  eco, // Low Power, ~30s update (Walking slowly/stationary)
  emergency, // Panic Mode, ~3s update
}

class GpsStateMachine extends StateNotifier<GpsMode> {
  GpsStateMachine() : super(GpsMode.trekking) {
    _initAccelerometer();
  }

  StreamSubscription? _accelSubscription;
  DateTime? _lastMotionTime;
  DateTime _lastAccelCheck = DateTime.now();
  // Reduced threshold for demo/responsiveness, in real hiking maybe 5 mins
  static const int _ecoThresholdMinutes = 5;

  void _initAccelerometer() {
    _accelSubscription = accelerometerEventStream().listen((event) {
      // Throttle: Process only 4 times per second
      if (DateTime.now().difference(_lastAccelCheck).inMilliseconds < 250) {
        return;
      }
      _lastAccelCheck = DateTime.now();

      final double magnitude =
          sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      // Filter noise: Gravity is ~9.8m/s²
      if ((magnitude - 9.8).abs() > 0.5) {
        _onMotionDetected();
      } else {
        _checkIdle();
      }
    });
    _lastMotionTime = DateTime.now();
  }

  void _onMotionDetected() {
    _lastMotionTime = DateTime.now();
    if (state == GpsMode.eco) {
      _setMode(GpsMode.trekking);
    }
  }

  void _checkIdle() {
    if (state == GpsMode.trekking && _lastMotionTime != null) {
      final diff = DateTime.now().difference(_lastMotionTime!);
      if (diff.inMinutes >= _ecoThresholdMinutes) {
        _setMode(GpsMode.eco);
      }
    }
  }

  void _setMode(GpsMode newMode) {
    if (state != newMode) {
      state = newMode;
      // Communicate with Background Service
      // FlutterBackgroundService().invoke("set_gps_mode", {"mode": newMode.name});
    }
  }

  void triggerEmergency() {
    _setMode(GpsMode.emergency);
  }

  void clearEmergency() {
    _setMode(GpsMode.trekking);
    _lastMotionTime = DateTime.now();
  }

  @override
  void dispose() {
    _accelSubscription?.cancel();
    super.dispose();
  }
}
