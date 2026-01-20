package com.example.pandu_navigation.logic;

public class GeoMath {
    private static final double EARTH_RADIUS_METERS = 6371000.0;

    private static double degToRad(double deg) {
        return deg * Math.PI / 180.0;
    }

    private static double radToDeg(double rad) {
        return rad * 180.0 / Math.PI;
    }

    /**
     * Calculates the Great Circle distance (Haversine) between two coordinates in
     * meters.
     */
    public static double distanceMeters(double lat1, double lng1, double lat2, double lng2) {
        double phi1 = degToRad(lat1);
        double phi2 = degToRad(lat2);
        double dLat = degToRad(lat2 - lat1);
        double dLon = degToRad(lng2 - lng1);

        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(phi1) * Math.cos(phi2) * Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

        return EARTH_RADIUS_METERS * c;
    }

    /**
     * Calculates the perpendicular distance from Point P to the Line Segment
     * defined by A and B.
     */
    public static double distanceToSegment(double latP, double lngP, double latA, double lngA, double latB,
            double lngB) {
        double rLatP = degToRad(latP);
        double rLngP = degToRad(lngP);
        double rLatA = degToRad(latA);
        double rLngA = degToRad(lngA);
        double rLatB = degToRad(latB);
        double rLngB = degToRad(lngB);

        // Cartesian approximation for projection factor 't'
        double x = (rLngB - rLngA) * Math.cos((rLatA + rLatB) / 2);
        double y = rLatB - rLatA;
        double lenSq = x * x + y * y;

        if (lenSq == 0)
            return distanceMeters(latP, lngP, latA, lngA);

        double rx = (rLngP - rLngA) * Math.cos((rLatA + rLatB) / 2);
        double ry = rLatP - rLatA;

        double t = (rx * x + ry * y) / lenSq;

        if (t < 0)
            return distanceMeters(latP, lngP, latA, lngA);
        if (t > 1)
            return distanceMeters(latP, lngP, latB, lngB);

        // Project back to coords
        double latClosest = latA + (latB - latA) * t;
        double lngClosest = lngA + (lngB - lngA) * t;

        return distanceMeters(latP, lngP, latClosest, lngClosest);
    }
}
