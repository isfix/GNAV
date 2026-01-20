package com.example.pandu_navigation.logic;

public class GeoMath {

    private static final double EARTH_RADIUS = 6371000; // meters

    /**
     * Calculates distance between two points in meters using Haversine formula.
     */
    public static double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLng = Math.toRadians(lng2 - lng1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLng / 2) * Math.sin(dLng / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS * c;
    }

    /**
     * Calculates the shortest distance from a point (pLat, pLng) to a line segment
     * defined by (startLat, startLng) and (endLat, endLng).
     */
    public static double distanceToSegment(double pLat, double pLng,
            double startLat, double startLng,
            double endLat, double endLng) {

        // Convert to Cartesian approximation for small distances (valid for trail
        // proximity)
        // Or use proper cross-track distance.
        // For efficiency in loop, we often use a specialized function.
        // Here is a robust implementation for local scale (Euclidean approximation
        // projected):

        double x = pLng;
        double y = pLat;
        double x1 = startLng;
        double y1 = startLat;
        double x2 = endLng;
        double y2 = endLat;

        double A = x - x1;
        double B = y - y1;
        double C = x2 - x1;
        double D = y2 - y1;

        double dot = A * C + B * D;
        double len_sq = C * C + D * D;

        double param = -1;
        if (len_sq != 0) // in case of 0 length line
            param = dot / len_sq;

        double xx, yy;

        if (param < 0) {
            xx = x1;
            yy = y1;
        } else if (param > 1) {
            xx = x2;
            yy = y2;
        } else {
            xx = x1 + param * C;
            yy = y1 + param * D;
        }

        // Return distance from Point (x,y) to Closest Point (xx,yy)
        return distanceMeters(y, x, yy, xx);
    }
}
