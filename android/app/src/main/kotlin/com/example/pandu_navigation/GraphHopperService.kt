package com.example.pandu_navigation

import android.content.Context
import com.graphhopper.GHRequest
import com.graphhopper.GHResponse
import com.graphhopper.GraphHopper
import com.graphhopper.config.Profile
import com.graphhopper.util.Parameters
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.File

/**
 * GraphHopper Routing Service for offline turn-by-turn navigation.
 * 
 * IMPORTANT: This service ONLY loads pre-processed graphs.
 * We do NOT process raw .osm.pbf files on mobile devices because:
 * 1. It causes OutOfMemory crashes (Java needs 2GB+ heap for processing)
 * 2. It takes 10+ minutes even if it doesn't crash
 * 
 * The graph must be pre-built on a development machine and shipped as a zip.
 */
class GraphHopperService(private val context: Context) {
    
    private var hopper: GraphHopper? = null
    private var isInitialized = false
    
    /**
     * Loads a PRE-BUILT GraphHopper graph from the specified folder.
     * 
     * The folder must contain the processed graph files (nodes, edges, etc),
     * NOT a raw .osm.pbf file.
     * 
     * @param folderPath The absolute path to the pre-processed graph folder
     * @return true if successful, false otherwise
     */
    suspend fun loadGraph(folderPath: String): Boolean = withContext(Dispatchers.IO) {
        try {
            val graphFolder = File(folderPath)
            if (!graphFolder.exists()) {
                throw IllegalArgumentException("Graph folder does not exist: $folderPath")
            }
            
            // Verify this is a pre-processed graph (check for nodes file)
            val nodesFile = File(folderPath, "nodes")
            if (!nodesFile.exists()) {
                throw IllegalArgumentException(
                    "Invalid graph folder: missing 'nodes' file. " +
                    "Graph must be pre-processed on a development machine."
                )
            }
            
            hopper = GraphHopper().apply {
                // Configure for foot/pedestrian profile (must match the processed graph)
                setProfiles(
                    Profile("foot")
                        .setVehicle("foot")
                        .setWeighting("fastest")
                        .setTurnCosts(false)
                )
                
                // Set graph location
                graphHopperLocation = folderPath
                
                // CRITICAL: Use load() NOT importOrLoad()
                // This prevents OOM by refusing to process raw OSM data
                // If the graph is missing/corrupt, we fail fast with an error
                load()
            }
            
            isInitialized = true
            true
        } catch (e: Exception) {
            e.printStackTrace()
            isInitialized = false
            false
        }
    }
    
    /**
     * Calculates a route between two points.
     * @return Map containing: points, distance (meters), time (ms), and optional error
     */
    suspend fun getRoute(
        startLat: Double,
        startLon: Double,
        endLat: Double,
        endLon: Double
    ): Map<String, Any> = withContext(Dispatchers.IO) {
        if (!isInitialized || hopper == null) {
            return@withContext mapOf(
                "success" to false,
                "error" to "GraphHopper not initialized. Call loadGraph first."
            )
        }
        
        try {
            val request = GHRequest(startLat, startLon, endLat, endLon)
                .setProfile("foot")
                .setAlgorithm(Parameters.Algorithms.ASTAR_BI)
                .putHint(Parameters.Routing.INSTRUCTIONS, true)
            
            val response: GHResponse = hopper!!.route(request)
            
            if (response.hasErrors()) {
                return@withContext mapOf(
                    "success" to false,
                    "error" to response.errors.joinToString(", ") { it.message ?: "Unknown error" }
                )
            }
            
            val best = response.best
            val points = best.points.map { point ->
                listOf(point.lat, point.lon, point.ele)
            }
            
            mapOf(
                "success" to true,
                "points" to points,
                "distance" to best.distance,
                "time" to best.time,
                "ascend" to best.ascend,
                "descend" to best.descend
            )
        } catch (e: Exception) {
            mapOf(
                "success" to false,
                "error" to (e.message ?: "Unknown routing error")
            )
        }
    }
    
    /**
     * Checks if the routing engine is ready.
     */
    fun isReady(): Boolean = isInitialized
    
    /**
     * Releases resources.
     */
    fun close() {
        hopper?.close()
        hopper = null
        isInitialized = false
    }
}
