import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;
import 'package:vibration/vibration.dart';
import 'package:maplibre_gl/maplibre_gl.dart';

// Imports for Logic
import '../../data/local/db/app_database.dart';
import '../../features/navigation/logic/deviation_engine.dart';
import '../utils/kalman_filter.dart';

// Note: We cannot easily share Riverpod state between isolates without serialization.
// We will use the Database as the communication bus.

Future<void> initializeBackgroundService() async {
  final service = FlutterBackgroundService();

  // Create Notification Channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description: 'This channel is used for important notifications.',
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'PANDU Service',
      initialNotificationContent: 'Initializing...',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  try {
    // 1. Initialize Dart Bridge
    DartPluginRegistrant.ensureInitialized();

    // 1b. Initialize Notifications locally
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // 2. Initialize Database (New connection in this isolate)
    final db = AppDatabase();

    // Batch Buffer
    final List<UserBreadcrumbsCompanion> buffer = [];
    Timer? flushTimer;

    Future<void> flushBuffer() async {
      if (buffer.isEmpty) return;
      final batchData = List<UserBreadcrumbsCompanion>.from(buffer);
      buffer.clear();

      await db.batch((batch) {
        batch.insertAll(db.userBreadcrumbs, batchData);
      });
      print("[BG] Flushed ${batchData.length} points to DB");
    }

    // 3. Configure Geolocator Stream Management
    StreamSubscription<Position>? positionStream;

    // Safety Logic (runs in background, independent of UI)
    String _currentSafetyStatus = 'safe';

    // Hysteresis monitor to prevent flickering alerts from GPS noise
    final _deviationMonitor = DeviationMonitor();

    // Phase 4: Kalman Filter for GPS smoothing
    final _kalmanFilter =
        KalmanFilter.forest(); // Tuned for mountain/forest GPS noise

    void startStream(LocationSettings settings) {
      positionStream?.cancel();
      positionStream = Geolocator.getPositionStream(locationSettings: settings)
          .listen((Position? position) async {
        if (position != null) {
          // Phase 4: Apply Kalman Filter to smooth GPS noise
          final smoothed =
              _kalmanFilter.process(position.latitude, position.longitude);
          final lat = smoothed.lat;
          final lng = smoothed.lng;

          // A. BUFFER TO DB
          buffer.add(UserBreadcrumbsCompanion(
            sessionId: const drift.Value('current_session'),
            lat: drift.Value(lat),
            lng: drift.Value(lng),
            altitude: drift.Value(position.altitude),
            accuracy: drift.Value(position.accuracy),
            speed: drift.Value(position.speed),
            timestamp: drift.Value(DateTime.now()),
          ));

          // Flush if buffer full
          if (buffer.length >= 50) {
            flushTimer?.cancel();
            await flushBuffer();
          }

          // Or ensure we flush periodically (e.g. every 2 mins)
          flushTimer ??= Timer(const Duration(minutes: 2), () async {
            await flushBuffer();
            flushTimer = null;
          });

          // B. SAFETY CHECK (Decoupled from UI - Phase 1)
          try {
            // Use spatial query for nearby trails (optimized O(1) lookup)
            final nearbyTrails =
                await db.navigationDao.getNearbyTrails(lat, lng, buffer: 0.01);

            if (nearbyTrails.isNotEmpty) {
              final latLng = LatLng(lat, lng);
              final minDistance =
                  DeviationEngine.calculateMinDistance(latLng, nearbyTrails);

              // Use DeviationMonitor with hysteresis buffer to prevent flickering
              // This debounces false alarms from single GPS glitches
              _deviationMonitor.addReading(minDistance);
              final status = _deviationMonitor.currentStatus;

              final statusName = status.name;
              if (statusName != _currentSafetyStatus) {
                _currentSafetyStatus = statusName;

                // Send safety status to UI via service invoke
                service.invoke('safety_status',
                    {'status': statusName, 'distance': minDistance});

                // CRITICAL: If DANGER, vibrate immediately (even with screen off)
                if (status == SafetyStatus.danger) {
                  Vibration.vibrate(
                      pattern: [0, 500, 200, 500, 200, 500], amplitude: 255);
                } else if (status == SafetyStatus.warning) {
                  Vibration.vibrate(duration: 200);
                }
              }
            }
          } catch (e) {
            debugPrint('[BG] Safety check error: $e');
          }

          // C. UPDATE NOTIFICATION
          if (service is AndroidServiceInstance) {
            if (await service.isForegroundService()) {
              final safetyEmoji = _currentSafetyStatus == 'danger'
                  ? '🔴'
                  : _currentSafetyStatus == 'warning'
                      ? '🟡'
                      : '🟢';

              flutterLocalNotificationsPlugin.show(
                888,
                'PANDU $safetyEmoji',
                'Lat: ${lat.toStringAsFixed(5)}, Lng: ${lng.toStringAsFixed(5)}',
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                    'my_foreground',
                    'MY FOREGROUND SERVICE',
                    icon: 'ic_bg_service_small',
                    ongoing: true,
                  ),
                ),
              );
            }
          }

          service.invoke(
            'update',
            {
              "content":
                  "$_currentSafetyStatus: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}",
            },
          );
        }
      });
    }

    // Initial Start (Trekking Mode)
    startStream(const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    ));

    // 4. Listen for Mode Changes
    service.on("set_gps_mode").listen((event) {
      if (event == null) return;
      final mode = event["mode"] as String?;

      if (mode == "eco") {
        // LOW POWER: High accuracy (safe), but infrequent updates
        startStream(AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
          intervalDuration: const Duration(seconds: 30),
        ));
      } else if (mode == "emergency") {
        // EMERGENCY: Best accuracy, no filter
        startStream(const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 0,
        ));
      } else {
        // TREKKING (Default): High accuracy, 10m filter
        startStream(const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ));
      }
    });

    // 5. Handle Service Stop (Clean Resource Disposal)
    // This prevents memory leaks and "Database locked" errors on rapid restarts
    service.on('stopService').listen((event) async {
      debugPrint('[BG] Service stopping - cleaning up resources');

      // Cancel GPS stream
      positionStream?.cancel();
      positionStream = null;

      // Flush any remaining breadcrumbs
      await flushBuffer();

      // Cancel flush timer
      flushTimer?.cancel();
      flushTimer = null;

      // Close database connection
      await db.close();

      debugPrint('[BG] Resources cleaned up, stopping service');
      await service.stopSelf();
    });
  } catch (e, stack) {
    debugPrint('[BG] Fatal Error in background service: $e\n$stack');
  }
}
