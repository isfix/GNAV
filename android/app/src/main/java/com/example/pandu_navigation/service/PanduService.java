package com.example.pandu_navigation.service;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.location.Location;
import android.os.Build;
import android.os.IBinder;
import android.os.Looper;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.ActivityCompat;
import androidx.core.app.NotificationCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.example.pandu_navigation.data.AppDatabase;
import com.example.pandu_navigation.data.AssetConfigLoader;
import com.example.pandu_navigation.data.BreadcrumbEntity;
import com.example.pandu_navigation.data.NavigationDao;
import com.example.pandu_navigation.data.TrailEntity;
import com.example.pandu_navigation.logic.DeviationEngine;
import com.example.pandu_navigation.logic.KalmanFilter;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.android.gms.location.Priority;
import com.google.gson.Gson;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class PanduService extends Service {
    private static final String TAG = "PanduService";
    private static final String CHANNEL_ID = "PanduNavigationChannel";
    private static final int NOTIFICATION_ID = 12345;

    // Logic Components
    private AppDatabase db;
    private NavigationDao dao;
    private KalmanFilter kalmanFilter;
    private DeviationEngine deviationEngine;
    private AssetConfigLoader configLoader;

    // Location
    private FusedLocationProviderClient fusedLocationClient;
    private LocationCallback locationCallback;

    private ExecutorService bgExecutor;
    private Gson gson;

    private boolean isTracking = false;

    @Override
    public void onCreate() {
        super.onCreate();

        // Init Components
        db = AppDatabase.getDatabase(this);
        dao = db.navigationDao();
        kalmanFilter = new KalmanFilter(10); // Initial variance
        deviationEngine = new DeviationEngine();
        configLoader = new AssetConfigLoader(this, dao);
        bgExecutor = Executors.newSingleThreadExecutor();
        gson = new Gson();

        // Pre-seed if needed
        configLoader.loadInitialData();

        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this);

        setupLocationCallback();
        createNotificationChannel();
    }

    private void setupLocationCallback() {
        locationCallback = new LocationCallback() {
            @Override
            public void onLocationResult(LocationResult locationResult) {
                if (locationResult == null) {
                    return;
                }
                for (Location location : locationResult.getLocations()) {
                    processLocation(location);
                }
            }
        };
    }

    private void processLocation(Location location) {
        bgExecutor.execute(() -> {
            // 1. Kalman Filter
            kalmanFilter.process(
                    location.getLatitude(),
                    location.getLongitude(),
                    location.getAccuracy(),
                    location.getTime());

            double kLat = kalmanFilter.getLat();
            double kLng = kalmanFilter.getLng();

            // 2. Save Breadcrumb
            // Logic: Only save if moved explicit amount or time passed?
            // For now save every point for Breadcrumb Trail (maybe throttle in real world)
            dao.insertBreadcrumb(new BreadcrumbEntity(
                    kLat, kLng,
                    location.getAltitude(),
                    location.getAccuracy(),
                    location.getBearing(),
                    location.getSpeed(),
                    location.getTime()));

            // 3. Deviation Check
            // Query nearby trails (within ~200m padding = 0.002 deg approx)
            double padding = 0.002;
            List<TrailEntity> nearbyTrails = dao.getNearbyTrails(kLat, kLng, padding);

            DeviationEngine.SafetyStatus status = deviationEngine.checkSafety(kLat, kLng, nearbyTrails);

            if (status == DeviationEngine.SafetyStatus.DANGER) {
                // Vibrate or similar?
                Log.w(TAG, "DANGER: USER OFF TRAIL!");
            }

            // 4. Stream to Flutter
            Intent intent = new Intent("PanduNavigationUpdate");
            intent.putExtra("lat", kLat);
            intent.putExtra("lng", kLng);
            intent.putExtra("status", status.name());
            intent.putExtra("altitude", location.getAltitude());
            intent.putExtra("accuracy", location.getAccuracy());
            intent.putExtra("bearing", location.getBearing());
            intent.putExtra("speed", location.getSpeed());
            intent.putExtra("distance", deviationEngine.getLastDeviationDistance()); // Add distance to trail
            LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        });
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        String action = intent != null ? intent.getAction() : null;
        if ("START_TRACKING".equals(action)) {
            String trailId = intent.getStringExtra("trailId");
            startTracking(trailId);
        } else if ("STOP_TRACKING".equals(action)) {
            stopTracking();
        }

        // Start Foreground immediately to ensure service survival
        startForeground(NOTIFICATION_ID, getNotification("Pandu Navigation Active"));

        return START_STICKY; // Unkillable
    }

    private String activeTrailId;

    private void startTracking(String trailId) {
        this.activeTrailId = trailId;
        if (isTracking)
            return;

        if (ActivityCompat.checkSelfPermission(this,
                android.Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            Log.e(TAG, "No Location Permission");
            return;
        }

        LocationRequest locationRequest = new LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 2000)
                .setMinUpdateIntervalMillis(1000)
                .build();

        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper());
        isTracking = true;
        Log.d(TAG, "Tracking Started");
    }

    private void stopTracking() {
        if (!isTracking)
            return;
        fusedLocationClient.removeLocationUpdates(locationCallback);
        isTracking = false;
        stopForeground(true);
        stopSelf();
        Log.d(TAG, "Tracking Stopped");
    }

    private Notification getNotification(String content) {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("Pandu Navigation")
                .setContentText(content)
                .setSmallIcon(android.R.drawable.ic_menu_compass) // Replace with app icon
                .setPriority(NotificationCompat.PRIORITY_LOW);

        return builder.build();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "Pandu Navigation Service",
                    NotificationManager.IMPORTANCE_LOW);
            NotificationManager manager = getSystemService(NotificationManager.class);
            if (manager != null) {
                manager.createNotificationChannel(serviceChannel);
            }
        }
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
