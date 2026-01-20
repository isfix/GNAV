import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/stitch/stitch_theme.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/stitch/stitch_glass_panel.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/stitch/stitch_typography.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/atoms/stitch_off_trail_alert.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/atoms/stitch_compass.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/atoms/stitch_tracking_panel.dart';
import 'package:pandu_navigation/features/navigation/presentation/offline_map_screen.dart';
import 'package:pandu_navigation/features/navigation/logic/native_bridge.dart';
import 'package:pandu_navigation/data/local/db/app_database.dart';

import 'package:permission_handler/permission_handler.dart';

class StitchMapScreen extends ConsumerStatefulWidget {
  final Trail? trail;
  const StitchMapScreen({super.key, this.trail});

  @override
  ConsumerState<StitchMapScreen> createState() => _StitchMapScreenState();
}

class _StitchMapScreenState extends ConsumerState<StitchMapScreen> {
  int _elapsedSeconds = 0;
  bool _isTracking = true;
  int _currentPage = 0; // For bottom sheet page indicator

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsAndStartService();
    });
    // Start timer for tracking
    _startTimer();
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

    // Extract navigation data from native bridge
    final double altitude = navState['altitude'] ?? 2450.0;
    final double accuracy = navState['accuracy'] ?? 3.0;
    final double bearing = navState['bearing'] ?? 285.0;

    final String statusRaw = navState['status'] ?? 'SAFE';
    final bool isDanger = statusRaw == 'DANGER';
    final bool isWarning = statusRaw == 'WARNING';
    final double deviationDist =
        (navState['distance'] as num?)?.toDouble() ?? 0.0;

    // Simulated progress
    final double completedKm = 2.4;
    final double totalKm = 4.2;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: StitchDangerOverlay(
        isActive: isDanger,
        child: Stack(
          children: [
            // 1. Map Layer
            Positioned.fill(
              child: _buildMapLayer(),
            ),

            // 2. Top Bar (Gradient + Header + Search)
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
                  child: Column(
                    children: [
                      // Brand + Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.explore,
                                  color: StitchTheme.primary, size: 28),
                              const SizedBox(width: 8),
                              Text.rich(
                                const TextSpan(
                                  children: [
                                    TextSpan(text: 'PANDU '),
                                    TextSpan(
                                      text: 'NAV',
                                      style: TextStyle(
                                        color: StitchTheme.primary,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                ),
                                style: StitchTypography.displaySmall
                                    .copyWith(fontSize: 18),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildTopBtn(Icons.layers),
                              const SizedBox(width: 8),
                              _buildTopBtn(Icons.settings),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Search Bar
                      StitchGlassPanel(
                        padding: EdgeInsets.zero,
                        borderRadius: BorderRadius.circular(12),
                        enableTapAnimation: false,
                        child: const SizedBox(
                          height: 44,
                          child: Row(
                            children: [
                              SizedBox(width: 14),
                              Icon(Icons.search, color: StitchTheme.primary),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Search Mount Merbabu peaks...',
                                  style: TextStyle(
                                      color: StitchTheme.textDim, fontSize: 14),
                                ),
                              ),
                              Icon(Icons.mic, color: StitchTheme.textDim),
                              SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // 3. HUD Panel (Altitude, GPS, Compass)
            Positioned(
              top: 140,
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
                      '${altitude.toInt()}',
                      unit: 'm',
                    ),
                    Container(
                        width: 1, height: 40, color: StitchTheme.borderSubtle),
                    _buildHudItem(
                      isWarning || isDanger ? 'DIST. DEVIATION' : 'GPS ACC.',
                      isWarning || isDanger
                          ? '${deviationDist.toInt()}'
                          : '${accuracy.toInt()}',
                      unit: 'm',
                      isHighlight: true,
                      status: isWarning || isDanger ? statusRaw : null,
                    ),
                    Container(
                        width: 1, height: 40, color: StitchTheme.borderSubtle),
                    _buildHudItem(
                      'COMPASS',
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
                top: 220,
                left: 0,
                right: 0,
                child: StitchOffTrailAlert(
                  deviationMeters: deviationDist,
                ),
              ),

            // 5. Peak Marker (center)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Pulse effect
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StitchTheme.primary.withOpacity(0.2),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: StitchTheme.primary,
                          boxShadow: StitchTheme.neonGlow,
                        ),
                        child: const Icon(
                          Icons.flag,
                          color: Colors.black,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  StitchGlassPanel(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    borderRadius: BorderRadius.circular(8),
                    borderColor: StitchTheme.primary.withOpacity(0.3),
                    child: Column(
                      children: [
                        Text(
                          'THE PEAK',
                          style: StitchTypography.labelMicro.copyWith(
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          '3,142m',
                          style: StitchTypography.hudValue.copyWith(
                            fontSize: 14,
                            color: StitchTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 6. Right Side Controls
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
                        _buildMapControlBtn(Icons.add, () {}),
                        Container(
                            height: 1,
                            width: 36,
                            color: StitchTheme.borderSubtle),
                        _buildMapControlBtn(Icons.remove, () {}),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  StitchGlassPanel(
                    padding: const EdgeInsets.all(12),
                    borderRadius: BorderRadius.circular(12),
                    child:
                        const Icon(Icons.near_me, color: StitchTheme.primary),
                  ),
                  const SizedBox(height: 12),
                  StitchGlassPanel(
                    padding: const EdgeInsets.all(12),
                    borderRadius: BorderRadius.circular(12),
                    child:
                        const Icon(Icons.threed_rotation, color: Colors.white),
                  ),
                ],
              ),
            ),

            // 7. Bottom Sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomSheet(
                bearing: bearing,
                accuracy: accuracy,
                completedKm: completedKm,
                totalKm: totalKm,
                isDanger: isDanger,
                deviationDist: deviationDist,
              ),
            ),
          ],
        ),
      ),
    );
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
    required double accuracy,
    required double completedKm,
    required double totalKm,
    required bool isDanger,
    required double deviationDist,
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
            _buildDangerSheetContent(deviationDist)
          else
            _buildNormalSheetContent(bearing, accuracy, completedKm, totalKm),

          // Page indicators
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final isActive = i == _currentPage;
                return Container(
                  width: isActive ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : StitchTheme.textSubtle,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.6),
                              blurRadius: 8,
                            )
                          ]
                        : null,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalSheetContent(
    double bearing,
    double accuracy,
    double completedKm,
    double totalKm,
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
              // Compass
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
                        '${accuracy.toInt()}',
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
                    'EXCELLENT',
                    style: StitchTypography.labelMicro.copyWith(
                      color: StitchTheme.primary.withOpacity(0.8),
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

  Widget _buildDangerSheetContent(double deviationDist) {
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
                    'Merbabu Selo Trail',
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
                        'ACTIVE NAVIGATION',
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
                    '2h 15m',
                    style: StitchTypography.hudValue.copyWith(fontSize: 16),
                  ),
                  Text(
                    'RECALCULATING...',
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
              // Activate backtrack
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
    );
  }
}
