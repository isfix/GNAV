import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/stitch/stitch_theme.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/stitch/stitch_glass_panel.dart';
import 'package:pandu_navigation/features/navigation/presentation/widgets/stitch/stitch_typography.dart';
import 'package:pandu_navigation/features/navigation/presentation/offline_map_screen.dart';
import 'package:pandu_navigation/features/navigation/logic/native_bridge.dart';

class StitchMapScreen extends ConsumerStatefulWidget {
  const StitchMapScreen({super.key});

  @override
  ConsumerState<StitchMapScreen> createState() => _StitchMapScreenState();
}

class _StitchMapScreenState extends ConsumerState<StitchMapScreen> {
  // Reuse existing map controller logic from OfflineMapScreen ideally
  // For now, we focus on the UI Shell implementation

  // Unused for now, but good for future state
  // bool _isMenuOpen = true;

  @override
  void initState() {
    super.initState();
    // Start native tracking service when screen opens
    NativeBridge.startService();
  }

  @override
  Widget build(BuildContext context) {
    // Watchers for HUD (Native Bridge)
    final navState = ref.watch(nativeNavigationProvider).valueOrNull ?? {};

    final double lat = navState['lat'] ?? 0.0;
    final double lng = navState['lng'] ?? 0.0;
    final double altitude =
        0.0; // Native service not sending altitude in JSON yet, placeholder
    final double accuracy = 0.0; // Placeholder
    final double? compassHeading = null; // Still need stream for this?

    // Status
    final String statusRaw =
        navState['status'] ?? 'SAFE'; // SAFE, WARNING, DANGER
    final bool isDanger = statusRaw == 'DANGER';
    final double deviationDist =
        (navState['distance'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      /// Use extendBodyBehindAppBar to allow map to be full screen
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Underlying Map Layer
          // We can eventually replace this with the actual MapLibre widget
          // For now, we put a placeholder or the actual widget if ready.
          Positioned.fill(
            child: _buildMapLayer(), // This constructs the actual MapLibre map
          ),

          if (isDanger) ...[
            // Red Overlay Flash could go here
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.red.withOpacity(0.5), width: 8),
                ),
              ),
            ),
          ],

          // 2. Top Bar (Gradient + Search)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
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
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              style: StitchTypography.displayMedium
                                  .copyWith(fontSize: 18),
                            ),
                          ],
                        ),
                        // Top Buttons
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
                      borderRadius: BorderRadius.circular(8),
                      child: const SizedBox(
                        height: 44,
                        child: Row(
                          children: [
                            SizedBox(width: 12),
                            Icon(Icons.search, color: StitchTheme.primary),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Search Mount Merbabu peaks...',
                                style: TextStyle(
                                    color: Colors.white54, fontSize: 13),
                              ),
                            ),
                            Icon(Icons.mic, color: Colors.white38),
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

          // 3. Cockpit HUD (Floating)
          Positioned(
            top: 140, // Adjust based on layout
            left: 16,
            right: 16,
            child: StitchGlassPanel(
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Row(
                children: [
                  _buildHudItem('DIST. TRAIL', deviationDist.toStringAsFixed(0),
                      unit: 'm', isHighlight: isDanger),
                  Container(width: 1, height: 40, color: Colors.white10),
                  _buildHudItem('STATUS', statusRaw,
                      unit: '', isHighlight: !isDanger),
                  Container(width: 1, height: 40, color: Colors.white10),
                  _buildHudItem('LAT/LNG',
                      '${lat.toStringAsFixed(4)}\n${lng.toStringAsFixed(4)}',
                      unit: ''),
                ],
              ),
            ),
          ),

          // 4. Center Peak Marker (Simulation)
          // Just for visual parity with design
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flag, color: StitchTheme.primary, size: 32),
                SizedBox(height: 8),
                StitchGlassPanel(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text('THE PEAK\n3,142m',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 10)),
                ),
              ],
            ),
          ),

          // 5. Right Side Controls
          Positioned(
            bottom: 300,
            right: 16,
            child: Column(
              children: [
                // Zoom
                StitchGlassPanel(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    children: [
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.add, color: Colors.white)),
                      Container(height: 1, width: 32, color: Colors.white10),
                      IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.remove, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Recenter
                StitchGlassPanel(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(8),
                  child: const Icon(Icons.near_me, color: StitchTheme.primary),
                ),
                const SizedBox(height: 12),
                // 3D
                StitchGlassPanel(
                  padding: const EdgeInsets.all(12),
                  borderRadius: BorderRadius.circular(8),
                  child: const Icon(Icons.threed_rotation, color: Colors.white),
                ),
              ],
            ),
          ),

          // 6. Bottom Sheet (Track Management)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 320,
              decoration: const BoxDecoration(
                color: StitchTheme.tacticalGray,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Colors.white10)),
                boxShadow: [BoxShadow(color: Colors.black, blurRadius: 20)],
              ),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        color: Colors.white24,
                        margin: const EdgeInsets.only(bottom: 20)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('TRACK MANAGEMENT',
                          style: StitchTypography.displayMedium
                              .copyWith(fontSize: 16)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white10),
                            borderRadius: BorderRadius.circular(4)),
                        child: const Text('OPTIONS',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  _buildTrackButton(
                    icon: Icons.grid_view,
                    title: 'Main Menu',
                    subtitle: 'Return to dashboard',
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(height: 12),
                  _buildTrackButton(
                    icon: Icons.stop_circle,
                    title: 'Stop Tracking',
                    subtitle: 'End current session',
                    color: Colors.red,
                    isDanger: true,
                    onTap: () {
                      NativeBridge.stopService();
                      context.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBtn(IconData icon) {
    return StitchGlassPanel(
      padding: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }

  Widget _buildHudItem(String label, String value,
      {String? unit, bool isHighlight = false}) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style:
                  StitchTypography.labelSmall.copyWith(color: Colors.white54)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: StitchTypography.hudValue.copyWith(
                  color: isHighlight ? StitchTheme.primary : Colors.white,
                  shadows: isHighlight ? StitchTheme.neonTextGlow : null,
                ),
              ),
              if (unit != null)
                Text(unit,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackButton({
    required IconData icon,
    required String title,
    required String subtitle,
    Color color = Colors.white,
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    final bgColor =
        isDanger ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05);

    return GestureDetector(
      onTap: onTap,
      child: StitchGlassPanel(
        padding: const EdgeInsets.all(16),
        backgroundColor: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDanger ? Colors.red.withOpacity(0.2) : Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                          TextStyle(color: color, fontWeight: FontWeight.bold)),
                  Text(subtitle,
                      style: TextStyle(
                          color: color.withOpacity(0.6), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  // Embed the headless map widget
  Widget _buildMapLayer() {
    return const OfflineMapScreen(
      isHeadless: true,
      mountainId: 'merbabu', // Default to Merbabu for now or pass arg
    );
  }
}
