import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:drift/drift.dart' as drift;

// Imports for Logic
import '../../data/local/db/app_database.dart';

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
  // 1. Initialize Dart Bridge
  DartPluginRegistrant.ensureInitialized();

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

  void startStream(LocationSettings settings) {
    positionStream?.cancel();
    positionStream = Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position? position) async {
      if (position != null) {
        // A. SAVE TO DB
        // A. BUFFER TO DB
        buffer.add(UserBreadcrumbsCompanion(
          sessionId: const drift.Value('current_session'),
          lat: drift.Value(position.latitude),
          lng: drift.Value(position.longitude),
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

        // B. UPDATE NOTIFICATION
        if (service is AndroidServiceInstance) {
          if (await service.isForegroundService()) {
            flutterLocalNotificationsPlugin.show(
              888,
              'PANDU ACTIVE',
              'Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}',
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
                "Active: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}",
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
}

// Global instance for simple access inside onStart if needed
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
