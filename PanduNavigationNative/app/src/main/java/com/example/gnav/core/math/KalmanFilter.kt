package com.example.gnav.core.math

class KalmanFilter(initialVariance: Float) {
    var timestamp: Long = System.currentTimeMillis()
        private set
    var lat: Double = 0.0
        private set
    var lng: Double = 0.0
        private set
    private var variance: Float = initialVariance // P matrix

    fun setState(lat: Double, lng: Double, timestamp: Long, accuracy: Float) {
        this.lat = lat
        this.lng = lng
        this.timestamp = timestamp
        this.variance = accuracy * accuracy
    }

    /**
     * Kalman filter processing for latitude and longitude (simplified).
     */
    fun process(latMeasurement: Double, lngMeasurement: Double, accuracy: Float, timestampMillis: Long) {
        var acc = accuracy
        if (acc < 1) acc = 1f
        
        if (variance < 0) {
            // Uninitialized (though we init with constructor, explicit reset check)
            setState(latMeasurement, lngMeasurement, timestampMillis, acc)
            return
        }

        val timeInc = timestampMillis - this.timestamp
        if (timeInc > 0) {
            // Apply process noise. Q_METERS_PER_SECOND assumed 1m/s error growth? 
            // Original used 0.001f factor? 
            // variance += timeInc * 0.001f * timeInc * 0.001f;
            // Let's match the Java implementation exactly.
            val factor = timeInc * 0.001f
            variance += factor * factor
            this.timestamp = timestampMillis
        }

        // Kalman gain K = P / (P + R)
        val k = variance / (variance + acc * acc)

        // Update state
        lat += k * (latMeasurement - lat)
        lng += k * (lngMeasurement - lng)

        // Update covariance
        // P = (1 - K) * P
        variance = (1 - k) * variance
    }
}
