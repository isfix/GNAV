package com.example.pandu_navigation.logic;

import com.example.pandu_navigation.data.TrailEntity;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.List;

public class DeviationEngine {

    // Thresholds in meters
    private static final double WARNING_THRESHOLD = 50.0;
    private static final double DANGER_THRESHOLD = 150.0;

    public enum SafetyStatus {
        SAFE, WARNING, DANGER
    }

    private final Gson gson = new Gson();

    /**
     * Checks if the user is on track.
     * Use simple geometry: distance to nearest segment of ANY nearby trail.
     */
    public SafetyStatus checkSafety(double userLat, double userLng, List<TrailEntity> nearbyTrails) {
        if (nearbyTrails == null || nearbyTrails.isEmpty()) {
            // No trails nearby? That's strictly OFF TRAIL if we expect trails.
            // But if we haven't loaded trails yet, we might flag false positives.
            // Assuming nearbyTrails are correctly queryable.
            return SafetyStatus.DANGER;
        }

        double minDistance = Double.MAX_VALUE;

        // Iterate all trails
        for (TrailEntity trail : nearbyTrails) {
            // Parse geometry (List<List<Double>> assumed: [[lng, lat, ele], ...]) or
            // similar
            // In TrailEntity we stored it as String (JSON).
            // We need to parse it. This is heavy for the main loop, so we should cache it
            // or parse once.
            // For now, parsing every frame is inefficient but completes the logic port.
            // Optimization: TrailEntity could have a transient field 'parsedGeometry'.

            List<List<Double>> points = parseGeometry(trail.geometryJson);
            if (points == null || points.size() < 2)
                continue;

            for (int i = 0; i < points.size() - 1; i++) {
                List<Double> p1 = points.get(i);
                List<Double> p2 = points.get(i + 1);

                // GeoJSON is [lng, lat, ele]
                double dist = GeoMath.distanceToSegment(
                        userLat, userLng,
                        p1.get(1), p1.get(0), // lat, lng
                        p2.get(1), p2.get(0));

                if (dist < minDistance) {
                    minDistance = dist;
                }
            }
        }

        if (minDistance <= WARNING_THRESHOLD) {
            return SafetyStatus.SAFE;
        } else if (minDistance <= DANGER_THRESHOLD) {
            return SafetyStatus.WARNING;
        } else {
            return SafetyStatus.DANGER;
        }
    }

    // Helper to parse cached geometry
    private List<List<Double>> parseGeometry(String json) {
        Type listType = new TypeToken<List<List<Double>>>() {
        }.getType();
        return gson.fromJson(json, listType);
    }
}
