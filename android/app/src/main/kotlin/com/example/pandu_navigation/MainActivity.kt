package com.example.pandu_navigation

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class MainActivity : FlutterActivity() {
    
    private val CHANNEL = "com.example.pandu/routing"
    private var routingService: GraphHopperService? = null
    private val scope = CoroutineScope(Dispatchers.Main)

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        routingService = GraphHopperService(applicationContext)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "loadGraph" -> {
                    val path = call.argument<String>("path")
                    if (path == null) {
                        result.error("INVALID_ARGUMENT", "path is required", null)
                        return@setMethodCallHandler
                    }
                    
                    scope.launch {
                        try {
                            val success = routingService?.loadGraph(path) ?: false
                            result.success(mapOf("success" to success))
                        } catch (e: Exception) {
                            result.error("LOAD_ERROR", e.message, null)
                        }
                    }
                }
                
                "calculateRoute" -> {
                    val startLat = call.argument<Double>("startLat")
                    val startLon = call.argument<Double>("startLon")
                    val endLat = call.argument<Double>("endLat")
                    val endLon = call.argument<Double>("endLon")
                    
                    if (startLat == null || startLon == null || endLat == null || endLon == null) {
                        result.error("INVALID_ARGUMENT", "start and end coordinates are required", null)
                        return@setMethodCallHandler
                    }
                    
                    scope.launch {
                        try {
                            val routeResult = routingService?.getRoute(startLat, startLon, endLat, endLon)
                            result.success(routeResult)
                        } catch (e: Exception) {
                            result.error("ROUTE_ERROR", e.message, null)
                        }
                    }
                }
                
                "isReady" -> {
                    result.success(routingService?.isReady() ?: false)
                }
                
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
    
    override fun onDestroy() {
        routingService?.close()
        super.onDestroy()
    }
}

