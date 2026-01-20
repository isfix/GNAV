package com.example.pandu_navigation.logic;

public class KalmanFilter {
    private long timestamp; // millis
    private double lat;
    private double lng;
    private float variance; // P matrix. Initial estimate of error.

    public KalmanFilter(float variance) {
        this.variance = variance;
        this.timestamp = System.currentTimeMillis();
        this.lat = 0;
        this.lng = 0;
    }

    public void setState(double lat, double lng, long timestamp, float accuracy) {
        this.lat = lat;
        this.lng = lng;
        this.timestamp = timestamp;
        this.variance = accuracy * accuracy;
    }

    /**
     * Kalman filter processing for latitude and longitude (simplified).
     *
     * @param latMeasurement  New latitude measurement
     * @param lngMeasurement  New longitude measurement
     * @param accuracy        Accuracy of measurement in meters
     * @param timestampMillis Timestamp of measurement
     */
    public void process(double latMeasurement, double lngMeasurement, float accuracy, long timestampMillis) {
        if (accuracy < 1)
            accuracy = 1;
        if (variance < 0) {
            // Uninitialized
            setState(latMeasurement, lngMeasurement, timestampMillis, accuracy);
            return;
        }

        long timeInc = timestampMillis - this.timestamp;
        if (timeInc > 0) {
            // Apply process noise if time has passed (model uncertainty increases with
            // time)
            variance += timeInc * 0.001f /* Q_METERS_PER_SECOND */ * timeInc * 0.001f;
            this.timestamp = timestampMillis;
        }

        // Kalman gain K = P / (P + R)
        // R = accuracy * accuracy
        float k = variance / (variance + accuracy * accuracy);

        // Update state
        lat += k * (latMeasurement - lat);
        lng += k * (lngMeasurement - lng);

        // Update covariance
        // P = (1 - K) * P
        variance = (1 - k) * variance;
    }

    public double getLat() {
        return lat;
    }

    public double getLng() {
        return lng;
    }
}
