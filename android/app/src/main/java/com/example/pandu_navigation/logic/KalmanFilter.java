package com.example.pandu_navigation.logic;

public class KalmanFilter {
    private double lat = 0.0;
    private double lng = 0.0;
    private double pLat = 1.0;
    private double pLng = 1.0;
    private final double q; // Process noise
    private final double r; // Measurement noise
    private boolean initialized = false;

    public KalmanFilter(double q, double r) {
        this.q = q;
        this.r = r;
    }

    public static KalmanFilter createForest() {
        return new KalmanFilter(0.000001, 0.001);
    }

    public static KalmanFilter createOpenTerrain() {
        return new KalmanFilter(0.00005, 0.00005);
    }

    public static class Result {
        public final double lat;
        public final double lng;

        public Result(double lat, double lng) {
            this.lat = lat;
            this.lng = lng;
        }
    }

    public Result process(double rawLat, double rawLng) {
        if (!initialized) {
            lat = rawLat;
            lng = rawLng;
            initialized = true;
            return new Result(lat, lng);
        }

        // Prediction
        double pLatPredicted = pLat + q;
        double pLngPredicted = pLng + q;

        // Kalman Gain
        double kLat = pLatPredicted / (pLatPredicted + r);
        double kLng = pLngPredicted / (pLngPredicted + r);

        // Update
        lat = lat + kLat * (rawLat - lat);
        lng = lng + kLng * (rawLng - lng);

        // Covariance Update
        pLat = (1 - kLat) * pLatPredicted;
        pLng = (1 - kLng) * pLngPredicted;

        return new Result(lat, lng);
    }

    public void reset() {
        lat = 0.0;
        lng = 0.0;
        pLat = 1.0;
        pLng = 1.0;
        initialized = false;
    }

    public boolean isInitialized() {
        return initialized;
    }
}
