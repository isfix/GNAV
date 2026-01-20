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
import com.example.pandu_navigation.logic.GpxImporter
import com.example.pandu_navigation.data.AppDatabase
import androidx.room.Room
import java.util.concurrent.Executors

class MainActivity: FlutterActivity() {
    private val COMMAND_CHANNEL = "com.pandu.nav/commands"
    private val UPDATE_CHANNEL = "com.pandu.nav/updates"

    private var eventSink: EventChannel.EventSink? = null
    private val executor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. Command Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, COMMAND_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startService" -> {
                    val intent = Intent(this, PanduService::class.java)
                    startForegroundService(intent)
                    result.success(null)
                }
                "stopService" -> {
                    val intent = Intent(this, PanduService::class.java)
                    intent.action = "STOP"
                    startForegroundService(intent)
                    result.success(null)
                }
                "loadGpx" -> {
                    val filePath = call.argument<String>("filePath")
                    val mountainId = call.argument<String>("mountainId")
                    if (filePath != null && mountainId != null) {
                        loadGpxBackground(filePath, mountainId, result)
                    } else {
                        result.error("INVALID_ARGS", "Path or ID missing", null)
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

    private fun loadGpxBackground(path: String, mountainId: String, result: MethodChannel.Result) {
        executor.execute {
            try {
                val db = Room.databaseBuilder(applicationContext,
                    AppDatabase::class.java, "pandu_db.sqlite")
                    .build()
                
                val trails = GpxImporter.parse(path, mountainId)
                db.navigationDao().insertTrails(trails)
                
                runOnUiThread { result.success(trails.size) }
            } catch (e: Exception) {
                runOnUiThread { result.error("PARSE_ERROR", e.message, null) }
            }
        }
    }

    private val receiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            val payload = intent.getStringExtra("payload")
            eventSink?.success(payload)
        }
    }

    private fun registerReceiver() {
        LocalBroadcastManager.getInstance(this).registerReceiver(
            receiver,
            IntentFilter(PanduService.ACTION_BROADCAST)
        )
    }

    private fun unregisterReceiver() {
        LocalBroadcastManager.getInstance(this).unregisterReceiver(receiver)
    }
}
