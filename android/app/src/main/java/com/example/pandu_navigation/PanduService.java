package com.example.pandu_navigation;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.os.Build;
import android.os.IBinder;
import android.os.Vibrator;
import android.os.Looper;
import android.os.VibrationEffect; // Added for newer API

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;
import androidx.room.Room;

import com.example.pandu_navigation.data.AppDatabase;
import com.example.pandu_navigation.data.BreadcrumbEntity;
import com.example.pandu_navigation.data.TrailEntity;
import com.example.pandu_navigation.logic.DeviationEngine;
import com.example.pandu_navigation.logic.KalmanFilter;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.Priority;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class PanduService extends Service {
    private static final String CHANNEL_ID = "pandu_navigation_channel";
    private static final int NOTIFICATION_ID = 777;
    public static final String ACTION_BROADCAST = "com.pandu.nav.UPDATE";

    private FusedLocationProviderClient fusedLocationClient;
    private LocationCallback locationCallback;
    private AppDatabase db;
    private ExecutorService bgExecutor;

    // Logic State
    private KalmanFilter kalmanFilter;
    private DeviationEngine.DeviationMonitor monitor;
    private String currentSessionId;

    private boolean isRunning = false;

    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();

        // Init Components
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);
        db = Room.databaseBuilder(getApplicationContext(),
                AppDatabase.class, "pandu_db.sqlite")
                // .createFromAsset("pandu_db.sqlite") // If using pre-populated, but we assume
                // migration
                .build();
        bgExecutor = Executors.newSingleThreadExecutor();

        kalmanFilter = KalmanFilter.createForest(); // Default to forest
        monitor = new DeviationEngine.DeviationMonitor();

        // Define Callback
        locationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                if (locationResult == null)
                    return;
                for (Location location : locationResult.getLocations()) {
                    processLocation(location);
                }
            }
        };
    }

    private void processLocation(Location rawLocation) {
        bgExecutor.execute(() -> {
            try {
                // 1. Filter
                KalmanFilter.Result smoothed = kalmanFilter.process(rawLocation.getLatitude(),
                        rawLocation.getLongitude());

                // 2. Insert Breadcrumb
                BreadcrumbEntity breadcrumb = new BreadcrumbEntity();
                breadcrumb.sessionId = currentSessionId != null ? currentSessionId : "current_session";
                breadcrumb.lat = smoothed.lat;
                breadcrumb.lng = smoothed.lng;
                breadcrumb.altitude = rawLocation.getAltitude();
                breadcrumb.accuracy = rawLocation.getAccuracy();
                breadcrumb.speed = (double) rawLocation.getSpeed();
                breadcrumb.timestamp = System.currentTimeMillis();
                breadcrumb.isSynced = false;

                db.navigationDao().insertBreadcrumb(breadcrumb);

                // 3. Deviation Check
                // Buffer 0.05 degrees ~ 5km radius window
                List<TrailEntity> nearbyTrails = db.navigationDao().getNearbyTrails(smoothed.lat, smoothed.lng, 0.05);

                double minDistance = DeviationEngine.calculateMinDistance(smoothed.lat, smoothed.lng, nearbyTrails);
                monitor.addReading(minDistance);

                DeviationEngine.SafetyStatus status = monitor.getCurrentStatus();

                // 4. Alert
                if (status == DeviationEngine.SafetyStatus.DANGER) {
                    triggerVibration();
                }

                // 5. Broadcast
                JSONObject json = new JSONObject();
                json.put("lat", smoothed.lat);
                json.put("lng", smoothed.lng);
                json.put("status", status.toString());
                json.put("distance", minDistance);
                json.put("eta", -1); // Placeholder

                Intent intent = new Intent(ACTION_BROADCAST);
                intent.putExtra("payload", json.toString());
                LocalBroadcastManager.getInstance(this).sendBroadcast(intent);

            } catch (Exception e) {
                e.printStackTrace();
            }
        });
    }

    private void triggerVibration() {
        Vibrator v = (Vibrator) getSystemService(Context.VIBRATOR_SERVICE);
        if (v != null && v.hasVibrator()) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                v.vibrate(VibrationEffect.createOneShot(500, VibrationEffect.DEFAULT_AMPLITUDE));
            } else {
                v.vibrate(500);
            }
        }
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if (intent != null) {
            String action = intent.getAction();
            if ("STOP".equals(action)) {
                stopSelf();
                return START_NOT_STICKY;
            }
        }

        if (!isRunning) {
            if (intent != null && intent.hasExtra("sessionId")) {
                currentSessionId = intent.getStringExtra("sessionId");
            }
            if (currentSessionId == null) {
                currentSessionId = "current_session";
            }

            startForeground(NOTIFICATION_ID, buildNotification());
            startLocationUpdates();
            isRunning = true;
        } else if (intent != null && intent.hasExtra("sessionId")) {
            // Allow updating session ID while running
            currentSessionId = intent.getStringExtra("sessionId");
        }

        return START_STICKY;
    }

    private void startLocationUpdates() {
        LocationRequest locationRequest = new LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 1000)
                .setMinUpdateIntervalMillis(500)
                .build();

        try {
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper());
        } catch (SecurityException e) {
            // Permission should be checked before starting service
            e.printStackTrace();
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        fusedLocationClient.removeLocationUpdates(locationCallback);
        bgExecutor.shutdown();
        isRunning = false;
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    private Notification buildNotification() {
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent,
                PendingIntent.FLAG_IMMUTABLE);

        return new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("PANDU Navigation Active")
                .setContentText("Tracking location and safety...")
                .setSmallIcon(android.R.drawable.ic_menu_compass) // Replace with app icon
                .setContentIntent(pendingIntent)
                .setOngoing(true)
                .build();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Pandu Navigation Channel",
                    NotificationManager.IMPORTANCE_DEFAULT);
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(serviceChannel);
            }
        }
    }
}
