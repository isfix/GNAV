import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/stitch/stitch_theme.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/stitch/stitch_glass_panel.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/stitch/stitch_typography.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/atoms/stitch_off_trail_alert.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/atoms/stitch_compass.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/atoms/stitch_tracking_panel.dart';
import 'package:pandu_navigation/features/navigation/presentation/offline_map_screen.dart';
import 'package:pandu_navigation/features/navigation/logic/native_bridge.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

class StitchMapScreen extends ConsumerStatefulWidget {
  final Trail? trail;
  const StitchMapScreen({super.key, this.trail});

  @override
  ConsumerState<StitchMapScreen> createState() => _StitchMapScreenState();
}

class _StitchMapScreenState extends ConsumerState<StitchMapScreen> {
  MapLibreMapController? _mapController;
  int _elapsedSeconds = 0;
  bool _isTracking = true;

  // Real compass data
  double _compassHeading = 0.0;
  StreamSubscription<CompassEvent>? _compassSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndStartService();
    });
    _startTimer();
    _initCompass();
  }

  void _initCompass() {
    _compassSubscription = FlutterCompass.events?.listen((event) {
      if (mounted && event.heading != null) {
        setState(() {
          _compassHeading = event.heading!;
        });
      }
    });
  }

  @override
  void dispose() {
    _compassSubscription?.cancel();
    super.dispose();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _isTracking) {
        setState(() => _elapsedSeconds++);
        return true;
      }
      return mounted;
    });
  }

  Future<void> _checkPermissionsAndStartService() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      NativeBridge.startService(trailId: widget.trail?.id);
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: StitchTheme.tacticalGray,
            title: Text('Permission Required',
                style: StitchTypography.displaySmall),
            content: Text(
              'Location permission is required for navigation and safety tracking. Please enable it in settings.',
              style: StitchTypography.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  openAppSettings();
                },
                child: Text('Open Settings',
                    style: TextStyle(color: StitchTheme.primary)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Cancel',
                    style: TextStyle(color: StitchTheme.textDim)),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(nativeNavigationProvider).valueOrNull ?? {};

    // Extract REAL navigation data from native bridge (show '--' if unavailable)
    final double? altitude = (navState['altitude'] as num?)?.toDouble();
    final double? accuracy = (navState['accuracy'] as num?)?.toDouble();
    final double bearing = _compassHeading; // Use real compass

    final String statusRaw = navState['status'] ?? 'SAFE';
    final bool isDanger = statusRaw == 'DANGER';
    final bool isWarning = statusRaw == 'WARNING';
    final double deviationDist =
        (navState['distance'] as num?)?.toDouble() ?? 0.0;

    // Trail info
    final String trailName = widget.trail?.name ?? 'Unknown Trail';
    final String mountainId = widget.trail?.mountainId ?? 'unknown';

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: StitchDangerOverlay(
        isActive: isDanger,
        child: Stack(
          children: [
            // 1. Map Layer (Full Screen)
            Positioned.fill(
              child: _buildMapLayer(),
            ),

            // 2. Header Bar (Brand + Back Button)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: StitchGlassPanel(
                          padding: const EdgeInsets.all(10),
                          borderRadius: BorderRadius.circular(10),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 20),
                        ),
                      ),
                      // Trail info
                      Column(
                        children: [
                          Text(
                            trailName.toUpperCase(),
                            style: StitchTypography.labelMicro.copyWith(
                              letterSpacing: 2,
                              color: StitchTheme.primary,
                            ),
                          ),
                          Text(
                            mountainId.toUpperCase(),
                            style: StitchTypography.labelMicro.copyWith(
                              color: StitchTheme.textDim,
                            ),
                          ),
                        ],
                      ),
                      // Settings
                      _buildTopBtn(Icons.settings),
                    ],
                  ),
                ),
              ),
            ),

            // 3. HUD Panel (Altitude, GPS, Compass) - Shows real data or '--'
            Positioned(
              top: 120,
              left: 16,
              right: 16,
              child: StitchGlassPanel(
                borderRadius: BorderRadius.circular(16),
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                child: Row(
                  children: [
                    _buildHudItem(
                      'ALTITUDE',
                      altitude != null ? '${altitude.toInt()}' : '--',
                      unit: 'm',
                    ),
                    Container(
                        width: 1, height: 40, color: StitchTheme.borderSubtle),
                    _buildHudItem(
                      isWarning || isDanger ? 'DEVIATION' : 'GPS ACC.',
                      isWarning || isDanger
                          ? '${deviationDist.toInt()}'
                          : (accuracy != null ? '${accuracy.toInt()}' : '--'),
                      unit: 'm',
                      isHighlight: true,
                      status: isWarning || isDanger ? statusRaw : null,
                    ),
                    Container(
                        width: 1, height: 40, color: StitchTheme.borderSubtle),
                    _buildHudItem(
                      'HEADING',
                      '${bearing.toInt()}°',
                      unit: _getBearingDirection(bearing),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Off-trail alert (when in danger)
            if (isDanger)
              Positioned(
                top: 200,
                left: 0,
                right: 0,
                child: StitchOffTrailAlert(
                  deviationMeters: deviationDist,
                ),
              ),

            // 5. Right Side Controls (Zoom, Location, 3D)
            Positioned(
              bottom: 320,
              right: 16,
              child: Column(
                children: [
                  StitchGlassPanel(
                    padding: EdgeInsets.zero,
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        _buildMapControlBtn(Icons.add, _onZoomIn),
                        Container(
                            height: 1,
                            width: 36,
                            color: StitchTheme.borderSubtle),
                        _buildMapControlBtn(Icons.remove, _onZoomOut),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _onCenterLocation,
                    child: StitchGlassPanel(
                      padding: const EdgeInsets.all(12),
                      borderRadius: BorderRadius.circular(12),
                      child: const Icon(Icons.my_location,
                          color: StitchTheme.primary),
                    ),
                  ),
                ],
              ),
            ),

            // 6. Bottom Sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomSheet(
                bearing: bearing,
                accuracy: accuracy,
                isDanger: isDanger,
                deviationDist: deviationDist,
                trailName: trailName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Map Control Callbacks ---
  void _onZoomIn() {
    _mapController?.animateCamera(CameraUpdate.zoomBy(1.0));
    debugPrint('[StitchMapScreen] Zoom In tapped');
  }

  void _onZoomOut() {
    _mapController?.animateCamera(CameraUpdate.zoomBy(-1.0));
    debugPrint('[StitchMapScreen] Zoom Out tapped');
  }

  void _onCenterLocation() {
    final navState = ref.read(nativeNavigationProvider).valueOrNull;
    if (navState != null) {
      final double? lat = (navState['lat'] as num?)?.toDouble();
      final double? lng = (navState['lng'] as num?)?.toDouble();

      if (lat != null && lng != null) {
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(LatLng(lat, lng), 16.0),
        );
      } else {
        debugPrint('[StitchMapScreen] Location not available to center');
      }
    }
    debugPrint('[StitchMapScreen] Center Location tapped');
  }

  Widget _buildTopBtn(IconData icon) {
    return StitchGlassPanel(
      padding: const EdgeInsets.all(10),
      borderRadius: BorderRadius.circular(10),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildMapControlBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  Widget _buildHudItem(
    String label,
    String value, {
    String? unit,
    bool isHighlight = false,
    String? status,
  }) {
    Color valueColor = Colors.white;
    List<Shadow>? shadows;

    if (status == 'DANGER') {
      valueColor = StitchTheme.danger;
      shadows = StitchTheme.dangerTextGlow
          .map((s) => Shadow(
                color: s.color,
                blurRadius: s.blurRadius,
              ))
          .toList();
    } else if (status == 'WARNING') {
      valueColor = StitchTheme.warning;
      shadows = StitchTheme.warningTextGlow
          .map((s) => Shadow(
                color: s.color,
                blurRadius: s.blurRadius,
              ))
          .toList();
    } else if (isHighlight) {
      valueColor = StitchTheme.primary;
      shadows = StitchTheme.neonTextGlow
          .map((s) => Shadow(
                color: s.color,
                blurRadius: s.blurRadius,
              ))
          .toList();
    }

    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: StitchTypography.labelMicro,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: StitchTypography.hudValue.copyWith(
                  color: valueColor,
                  shadows: shadows,
                ),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: StitchTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _getBearingDirection(double bearing) {
    final normalized = bearing % 360;
    if (normalized >= 337.5 || normalized < 22.5) return 'N';
    if (normalized >= 22.5 && normalized < 67.5) return 'NE';
    if (normalized >= 67.5 && normalized < 112.5) return 'E';
    if (normalized >= 112.5 && normalized < 157.5) return 'SE';
    if (normalized >= 157.5 && normalized < 202.5) return 'S';
    if (normalized >= 202.5 && normalized < 247.5) return 'SW';
    if (normalized >= 247.5 && normalized < 292.5) return 'W';
    return 'NW';
  }

  Widget _buildBottomSheet({
    required double bearing,
    required double? accuracy,
    required bool isDanger,
    required double deviationDist,
    required String trailName,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: StitchTheme.tacticalGray,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(top: BorderSide(color: StitchTheme.borderSubtle)),
        boxShadow: const [
          BoxShadow(
              color: Colors.black, blurRadius: 30, offset: Offset(0, -10)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: StitchTheme.textSubtle,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Content based on state
          if (isDanger)
            _buildDangerSheetContent(deviationDist, trailName)
          else
            _buildNormalSheetContent(bearing, accuracy),

          // Safe padding for home indicator
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNormalSheetContent(
    double bearing,
    double? accuracy,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        children: [
          // Compass row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Bearing display
              StitchBearingDisplay(bearing: bearing),
              // Compass (uses real heading from state)
              StitchCompass(bearing: bearing, size: 140),
              // GPS accuracy
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text('GPS ACC', style: StitchTypography.labelMicro),
                      const SizedBox(width: 4),
                      Icon(Icons.satellite_alt,
                          size: 12, color: StitchTheme.textDim),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        accuracy != null ? '${accuracy.toInt()}' : '--',
                        style: StitchTypography.monoLarge,
                      ),
                      Text(
                        'm',
                        style: TextStyle(
                          fontSize: 16,
                          color: StitchTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _getAccuracyLabel(accuracy),
                    style: StitchTypography.labelMicro.copyWith(
                      color: _getAccuracyColor(accuracy),
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tracking panel
          StitchTrackingPanel(
            elapsedSeconds: _elapsedSeconds,
            isActive: _isTracking,
            onPause: () => setState(() => _isTracking = false),
            onResume: () => setState(() => _isTracking = true),
          ),
        ],
      ),
    );
  }

  String _getAccuracyLabel(double? accuracy) {
    if (accuracy == null) return 'NO SIGNAL';
    if (accuracy <= 5) return 'EXCELLENT';
    if (accuracy <= 10) return 'GOOD';
    if (accuracy <= 20) return 'FAIR';
    return 'POOR';
  }

  Color _getAccuracyColor(double? accuracy) {
    if (accuracy == null) return StitchTheme.danger;
    if (accuracy <= 5) return StitchTheme.primary;
    if (accuracy <= 10) return StitchTheme.primary.withOpacity(0.8);
    if (accuracy <= 20) return StitchTheme.warning;
    return StitchTheme.danger;
  }

  Widget _buildDangerSheetContent(double deviationDist, String trailName) {
    // Format elapsed time
    final hours = _elapsedSeconds ~/ 3600;
    final minutes = (_elapsedSeconds % 3600) ~/ 60;
    final timeStr = '${hours}h ${minutes}m';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Column(
        children: [
          // Trail info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trailName,
                    style: StitchTypography.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: StitchTheme.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'OFF TRAIL - ${deviationDist.toInt()}m',
                        style: StitchTypography.labelMicro.copyWith(
                          color: StitchTheme.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeStr,
                    style: StitchTypography.hudValue.copyWith(fontSize: 16),
                  ),
                  Text(
                    'ELAPSED',
                    style: StitchTypography.labelMicro,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Backtrack button
          StitchBacktrackButton(
            onPressed: () {
              debugPrint('[StitchMapScreen] Backtrack button pressed');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMapLayer() {
    return OfflineMapScreen(
      isHeadless: true,
      mountainId: widget.trail?.mountainId ?? 'merbabu',
      trailId: widget.trail?.id,
      onMapCreated: (controller) => _mapController = controller,
    );
  }
}
