import 'dart:math';

/// 2D Kalman Filter for GPS position smoothing.
///
/// This filters out GPS noise which is especially bad under forest canopy
/// or in mountain terrain. Without smoothing, the safety engine may trigger
/// false alarms when GPS jumps 20+ meters instantly.
///
/// Tuning:
/// - Q (process noise): Low for hikers (they move slowly)
/// - R (measurement noise): High in forests/mountains (GPS is noisy)
class KalmanFilter {
  // State variables
  double _lat = 0.0;
  double _lng = 0.0;

  // Covariance (uncertainty)
  double _pLat = 1.0;
  double _pLng = 1.0;

  // Process noise (how much we expect position to change naturally)
  // Low value = we trust our prediction more
  final double q;

  // Measurement noise (how noisy we expect GPS readings to be)
  // High value = we trust GPS readings less
  final double r;

  // Has the filter been initialized with first reading?
  bool _initialized = false;

  /// Creates a Kalman filter for GPS smoothing.
  ///
  /// [q] Process noise - default 0.00001 is good for walking/hiking
  /// [r] Measurement noise - default 0.0001 is typical for GPS under canopy
  ///
  /// For mountain hiking with forest coverage:
  /// - Lower q (e.g., 0.000001) for slower movement
  /// - Higher r (e.g., 0.001) for noisier GPS
  KalmanFilter({
    this.q = 0.00001, // Low: hiker moves slowly
    this.r = 0.0001, // Default: moderate GPS noise
  });

  /// Creates a filter tuned for forest/mountain conditions
  factory KalmanFilter.forest() {
    return KalmanFilter(
      q: 0.000001, // Very low: slow movement in rough terrain
      r: 0.001, // High: GPS under tree canopy is very noisy
    );
  }

  /// Creates a filter tuned for open terrain
  factory KalmanFilter.openTerrain() {
    return KalmanFilter(
      q: 0.00005, // Slightly higher: faster movement in open
      r: 0.00005, // Low: GPS has clear sky view
    );
  }

  /// Processes a GPS reading and returns the smoothed position.
  ///
  /// Returns a record with (latitude, longitude)
  ({double lat, double lng}) process(double rawLat, double rawLng) {
    if (!_initialized) {
      // Initialize with first reading
      _lat = rawLat;
      _lng = rawLng;
      _initialized = true;
      return (lat: _lat, lng: _lng);
    }

    // Prediction step (position stays same, uncertainty grows)
    final pLatPredicted = _pLat + q;
    final pLngPredicted = _pLng + q;

    // Kalman gain (how much to trust the new measurement)
    final kLat = pLatPredicted / (pLatPredicted + r);
    final kLng = pLngPredicted / (pLngPredicted + r);

    // Update step (blend prediction with measurement)
    _lat = _lat + kLat * (rawLat - _lat);
    _lng = _lng + kLng * (rawLng - _lng);

    // Update covariance
    _pLat = (1 - kLat) * pLatPredicted;
    _pLng = (1 - kLng) * pLngPredicted;

    return (lat: _lat, lng: _lng);
  }

  /// Resets the filter state
  void reset() {
    _lat = 0.0;
    _lng = 0.0;
    _pLat = 1.0;
    _pLng = 1.0;
    _initialized = false;
  }

  /// Gets the current smoothed position
  ({double lat, double lng}) get currentPosition => (lat: _lat, lng: _lng);

  /// Whether the filter has been initialized with at least one reading
  bool get isInitialized => _initialized;

  /// Gets the current uncertainty estimate
  ({double lat, double lng}) get uncertainty =>
      (lat: sqrt(_pLat), lng: sqrt(_pLng));
}
