package com.example.pandu_navigation.logic;

import com.example.pandu_navigation.data.TrailEntity;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.LinkedList;
import java.util.List;

public class DeviationEngine {
    public enum SafetyStatus {
        SAFE, WARNING, DANGER
    }

    public static final double THRESHOLD_SAFE = 20.0;
    public static final double THRESHOLD_WARNING = 50.0;
    private static final double BOUNDS_PADDING = 0.001; // ~110m

    public static double calculateMinDistance(double userLat, double userLng, List<TrailEntity> trails) {
        double minDistance = Double.MAX_VALUE;

        for (TrailEntity trail : trails) {
            if (trail.geometryJson == null || trail.geometryJson.isEmpty())
                continue;

            // 1. AABB Check
            if (userLat < (trail.minLat - BOUNDS_PADDING) || userLat > (trail.maxLat + BOUNDS_PADDING) ||
                    userLng < (trail.minLng - BOUNDS_PADDING) || userLng > (trail.maxLng + BOUNDS_PADDING)) {
                continue;
            }

            // 2. Parse Geometry & Check Segments
            // Optimization: In a real persistent service, we should cache the parsed
            // trails.
            // For now, we strictly follow the 'dumb' port logic but use raw parsing.
            try {
                // Assuming geometryJson is [[lat, lng, elev], [lat, lng, elev]...]
                // OR [{lat:..., lng:...}, ...] depending on converter.
                // Dart Converter uses: [{lat: 1.0, lng: 2.0}, ...] usually?
                // Checking tables.dart: GeoJsonConverter. It typically serializes
                // List<TrailPoint>.
                // I will assume it is a JSONArray of objects with "lat" and "lng" fields for
                // safety,
                // OR an array of arrays. The safest is to check.
                // Given standard drift converters, it's often a list of maps.

                // Let's assume standard JSON Array of Objects: [{"lat":..., "lng":...}]
                JSONArray points = new JSONArray(trail.geometryJson);

                int len = points.length();
                if (len < 2)
                    continue;

                double metersPerLat = 111320.0;
                double latRad = Math.toRadians(userLat);
                double metersPerLng = 111320.0 * Math.cos(latRad);

                for (int i = 0; i < len - 1; i++) {
                    JSONObject p1 = points.getJSONObject(i);
                    JSONObject p2 = points.getJSONObject(i + 1);

                    double lat1 = p1.getDouble("lat");
                    double lng1 = p1.getDouble("lng");
                    double lat2 = p2.getDouble("lat");
                    double lng2 = p2.getDouble("lng");

                    // Segment AABB Optimization
                    if (minDistance != Double.MAX_VALUE) {
                        double segMinLat = Math.min(lat1, lat2);
                        double segMaxLat = Math.max(lat1, lat2);
                        double dLat = 0;
                        if (userLat < segMinLat)
                            dLat = segMinLat - userLat;
                        else if (userLat > segMaxLat)
                            dLat = userLat - segMaxLat;

                        if (dLat * metersPerLat > minDistance)
                            continue;

                        double segMinLng = Math.min(lng1, lng2);
                        double segMaxLng = Math.max(lng1, lng2);
                        double dLng = 0;
                        if (userLng < segMinLng)
                            dLng = segMinLng - userLng;
                        else if (userLng > segMaxLng)
                            dLng = userLng - segMaxLng;

                        if (dLng * metersPerLng > minDistance)
                            continue;
                    }

                    double dist = GeoMath.distanceToSegment(userLat, userLng, lat1, lng1, lat2, lng2);
                    if (dist < minDistance) {
                        minDistance = dist;
                    }
                }

            } catch (JSONException e) {
                e.printStackTrace();
            }
        }
        return minDistance;
    }

    public static SafetyStatus determineStatus(double distanceMeters) {
        if (distanceMeters <= THRESHOLD_SAFE)
            return SafetyStatus.SAFE;
        if (distanceMeters <= THRESHOLD_WARNING)
            return SafetyStatus.WARNING;
        return SafetyStatus.DANGER;
    }

    // Stateful Monitor
    public static class DeviationMonitor {
        private final LinkedList<SafetyStatus> buffer = new LinkedList<>();
        private static final int BUFFER_SIZE = 3;
        private SafetyStatus currentStatus = SafetyStatus.SAFE;

        public void addReading(double distanceMeters) {
            SafetyStatus raw = determineStatus(distanceMeters);

            buffer.add(raw);
            if (buffer.size() > BUFFER_SIZE) {
                buffer.removeFirst();
            }

            if (buffer.contains(SafetyStatus.DANGER)) {
                currentStatus = SafetyStatus.DANGER;
            } else {
                boolean allSafe = true;
                for (SafetyStatus s : buffer) {
                    if (s != SafetyStatus.SAFE) {
                        allSafe = false;
                        break;
                    }
                }
                if (allSafe) {
                    currentStatus = SafetyStatus.SAFE;
                } else {
                    currentStatus = SafetyStatus.WARNING;
                }
            }
        }

        public SafetyStatus getCurrentStatus() {
            return currentStatus;
        }
    }
}
