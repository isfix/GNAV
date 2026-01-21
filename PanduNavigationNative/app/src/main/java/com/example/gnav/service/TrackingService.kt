package com.example.gnav.service

import android.Manifest
import android.annotation.SuppressLint
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import com.example.gnav.MainActivity
import com.example.gnav.core.math.DeviationEngine
import com.example.gnav.core.math.KalmanFilter
import com.example.gnav.domain.model.Coord
import com.example.gnav.domain.repository.NavigationRepository
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority
import dagger.hilt.android.AndroidEntryPoint
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class TrackingService : Service() {

    @Inject
    lateinit var repository: NavigationRepository

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    // State
    private var activePath: List<Coord> = emptyList()
    private val kalmanFilter = KalmanFilter(3f) // Initial variance 3m?
    
    companion object {
        const val ACTION_START_TRACKING = "START_TRACKING"
        const val ACTION_STOP_TRACKING = "STOP_TRACKING"
        const val EXTRA_TRAIL_ID = "TRAIL_ID"
        const val NOTIFICATION_ID = 123
        const val CHANNEL_ID = "tracking_channel"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
        
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                for (location in locationResult.locations) {
                    processLocation(location)
                }
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when(intent?.action) {
            ACTION_START_TRACKING -> {
                val trailId = intent.getStringExtra(EXTRA_TRAIL_ID)
                if (trailId != null) {
                    startForeground(NOTIFICATION_ID, buildNotification("Initializing..."))
                    startTracking(trailId)
                }
            }
            ACTION_STOP_TRACKING -> {
                stopTracking()
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        return START_STICKY
    }

    private fun startTracking(trailId: String) {
        serviceScope.launch {
            val trail = repository.getTrail(trailId)
            if (trail != null) {
                activePath = trail.geometry
                requestLocationUpdates()
                updateNotification("Tracking on ${trail.name}")
            }
        }
    }

    @SuppressLint("MissingPermission")
    private fun requestLocationUpdates() {
        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            return
        }
        val request = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 1000)
            .setMinUpdateDistanceMeters(2f)
            .build()
        fusedLocationClient.requestLocationUpdates(request, locationCallback, Looper.getMainLooper())
    }

    private fun processLocation(location: Location) {
        // 1. Kalman Filter
        kalmanFilter.process(
            location.latitude,
            location.longitude,
            location.accuracy,
            location.time
        )
        
        val refinedLat = kalmanFilter.lat
        val refinedLng = kalmanFilter.lng
        val refinedCoord = Coord(refinedLat, refinedLng)

        // 2. Deviation Engine
        val result = DeviationEngine.calculateDeviation(refinedCoord, activePath)
        
        val isOffTrail = result is DeviationEngine.DeviationResult.OffTrail
        
        // 3. Persist
        serviceScope.launch {
            repository.insertBreadcrumb(refinedLat, refinedLng, location.accuracy, isOffTrail)
        }
        
        // 4. Alert (Simple Log/Audio hook for now)
        if (result is DeviationEngine.DeviationResult.OffTrail && result.status == DeviationEngine.SafetyStatus.DANGER) {
           // Should trigger audio/vibration here
        }
    }

    private fun stopTracking() {
        fusedLocationClient.removeLocationUpdates(locationCallback)
        serviceScope.cancel()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Tracking Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(text: String): Notification {
        val pendingIntent = PendingIntent.getActivity(
            this, 0,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE
        )
        
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Pandu Navigation")
            .setContentText(text)
            .setSmallIcon(android.R.drawable.ic_menu_compass) // Placeholder
            .setContentIntent(pendingIntent)
            .build()
    }
    
    private fun updateNotification(text: String) {
        val manager = getSystemService(NotificationManager::class.java)
        manager.notify(NOTIFICATION_ID, buildNotification(text))
    }

    override fun onBind(intent: Intent?): IBinder? = null
    
    override fun onDestroy() {
        super.onDestroy()
        serviceScope.cancel()
    }
}
