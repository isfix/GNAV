package com.example.pandu_navigation

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import com.example.pandu_navigation.service.PanduService
import com.example.pandu_navigation.data.AppDatabase
import com.example.pandu_navigation.data.AssetConfigLoader
import com.google.gson.Gson
import java.util.concurrent.Executors

class MainActivity: FlutterActivity() {
    private val COMMAND_CHANNEL = "com.pandu.nav/commands"
    private val UPDATE_CHANNEL = "com.pandu.nav/updates"

    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Trigger initial data seed
        val db = AppDatabase.getDatabase(applicationContext)
        val loader = AssetConfigLoader(applicationContext, db.navigationDao())
        loader.loadInitialData()

        // 1. Command Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COMMAND_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val trailId = call.argument<String>("trailId")
                    val intent = Intent(this, PanduService::class.java)
                    intent.action = "START_TRACKING"
                    if (trailId != null) {
                        intent.putExtra("trailId", trailId)
                    }
                    startForegroundService(intent)
                    result.success(null)
                }
                "stopService" -> {
                    val intent = Intent(this, PanduService::class.java)
                    intent.action = "STOP_TRACKING"
                    startForegroundService(intent)
                    result.success(null)
                }
                "getTrails" -> {
                    val mountainId = call.argument<String>("mountainId")
                    if (mountainId != null) {
                       getTrailsBackground(mountainId, result)
                    } else {
                       result.error("INVALID", "No mountainId", null)
                    }
                }
                else -> result.notImplemented()
            }
        }

        // 2. Event Channel
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, UPDATE_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    registerReceiver()
                }

                override fun onCancel(arguments: Any?) {
                    unregisterReceiver()
                    eventSink = null
                }
            }
        )
    }

    private fun getTrailsBackground(mountainId: String, result: MethodChannel.Result) {
        val executor = Executors.newSingleThreadExecutor()
        executor.execute {
            try {
                val db = AppDatabase.getDatabase(applicationContext)
                val trails = db.navigationDao().getTrailsByMountain(mountainId)
                
                val gson = Gson()
                val jsonStr = gson.toJson(trails)
                
                runOnUiThread {
                    result.success(jsonStr) 
                }
            } catch (e: Exception) {
                runOnUiThread { result.error("DB_ERROR", e.message, null) }
            }
        }
    }

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val lat = intent.getDoubleExtra("lat", 0.0)
            val lng = intent.getDoubleExtra("lng", 0.0)
            val status = intent.getStringExtra("status") ?: "SAFE"
            
            val payload = mapOf(
                "lat" to lat,
                "lng" to lng,
                "status" to status
            )
            eventSink?.success(payload)
        }
    }

    private fun registerReceiver() {
        LocalBroadcastManager.getInstance(this).registerReceiver(
            receiver,
            IntentFilter("PanduNavigationUpdate")
        )
    }

    private fun unregisterReceiver() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(receiver)
    }
}
