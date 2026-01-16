import 'package:flutter/material.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'dart:ui';
import 'dart:math' as math;
import '../../../logic/deviation_engine.dart';
import '../../../logic/eta_engine.dart';
import '../../../../../data/local/db/app_database.dart';
import '../../../../../data/local/db/converters.dart';
import '../../../../../core/utils/geo_math.dart';
import '../elevation_panel.dart';
import '../atoms/stat_card.dart';
import '../atoms/survival_card.dart';
import '../atoms/sonic_beacon_button.dart';

// Note: Ensure ElevationPanel is actually exported or accessible.
// Based on file structure: features/navigation/presentation/widgets/elevation_panel.dart
// Since we are in features/navigation/presentation/widgets/sheets/
// The import should be '../elevation_panel.dart'

class NavigationSheet extends StatefulWidget {
  final SafetyStatus status;
  final UserBreadcrumb? userLoc;
  final double heading;
  final Trail? trail;
  final VoidCallback onBacktrack;
  final VoidCallback onSimulateMenu;

  const NavigationSheet({
    super.key,
    required this.status,
    required this.userLoc,
    required this.heading,
    this.trail,
    required this.onBacktrack,
    required this.onSimulateMenu,
  });

  @override
  State<NavigationSheet> createState() => _NavigationSheetState();
}

class _NavigationSheetState extends State<NavigationSheet> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 1); // Start at Main Dashboard
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.40,
      minChildSize: 0.15,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF121212).withOpacity(0.95),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2))),

                  // Pager
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      children: [
                        _buildCompassPage(),
                        _buildDashboardPage(scrollController),
                        _buildSurvivalPage(scrollController),
                      ],
                    ),
                  ),

                  // Indicators
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        // Simple indicator logic if we had state listening,
                        // but for now simple dots or just skip
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2)),
                        );
                      }),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // PAGE 0: Compass & Altitude
  Widget _buildCompassPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.rotate(
            angle: (widget.heading * (math.pi / 180) * -1),
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF0df259), width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: const Color(0xFF0df259).withOpacity(0.2),
                        blurRadius: 20)
                  ]),
              child: Stack(
                children: [
                  const Center(
                      child: Icon(Icons.navigation,
                          size: 60, color: Colors.white)),
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(width: 4, height: 20, color: Colors.red),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text("${widget.heading.toStringAsFixed(0)}°",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text("ALT: ${widget.userLoc?.altitude?.toStringAsFixed(0) ?? '--'}m",
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // PAGE 1: Main Dashboard
  Widget _buildDashboardPage(ScrollController controller) {
    // Calculate Elevation Data
    Widget elevationGraph = const Center(
        child: Text("No Active Trail", style: TextStyle(color: Colors.grey)));
    Duration? eta;

    if (widget.trail != null && widget.userLoc != null) {
      // Cast to dynamic then List<TrailPoint> to handle potential stale generated code
      final points = (widget.trail!.geometryJson as List).cast<TrailPoint>();
      final altitudes = points.map((p) => p.elevation).toList();

      int closestIndex = 0;
      double minD = double.infinity;
      final u = LatLng(widget.userLoc!.lat, widget.userLoc!.lng);

      for (int i = 0; i < points.length; i++) {
        final p = points[i];
        final d = GeoMath.distanceMeters(u, LatLng(p.lat, p.lng));
        if (d < minD) {
          minD = d;
          closestIndex = i;
        }
      }

      final progress = closestIndex / points.length;

      // Target Summit (Apex) instead of Parking Lot
      int targetIdx = widget.trail!.summitIndex;
      if (targetIdx < 0 || targetIdx >= points.length) {
        targetIdx = points.length - 1;
      }

      final endPt = points[targetIdx].toLatLng();
      final endAlt = altitudes[targetIdx];

      final uAlt = widget.userLoc!.altitude ?? altitudes[closestIndex];
      eta = EtaEngine.calculateEta(u, uAlt, endPt, endAlt);

      elevationGraph = ElevationPanel(
        trailPoints: points.map((p) => p.toLatLng()).toList(),
        altitudes: altitudes,
        currentProgress: progress,
        etaToNextPos: eta,
        nextPosName: "Summit",
      );
    }

    return SingleChildScrollView(
      controller: controller,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Stats Row
            Row(
              children: [
                Expanded(
                    child: StatCard(
                        label: "ALTITUDE",
                        value:
                            "${widget.userLoc?.altitude?.toStringAsFixed(0) ?? '-'}m",
                        isHighlight: true)),
                const SizedBox(width: 12),
                Expanded(
                    child: StatCard(
                        label: "ETA",
                        value: eta != null
                            ? EtaEngine.formatDuration(eta)
                            : "--")),
                const SizedBox(width: 12),
                const Expanded(
                    child: StatCard(label: "SUNSET", value: "18:42")),
              ],
            ),
            const SizedBox(height: 24),

            // Elevation Graph
            SizedBox(height: 180, child: elevationGraph),
            const SizedBox(height: 24),

            // Button
            GestureDetector(
              onTap: widget.status == SafetyStatus.danger
                  ? widget.onBacktrack
                  : null,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                    color: widget.status == SafetyStatus.danger
                        ? const Color(0xFFff3b30)
                        : Colors.grey[800],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      if (widget.status == SafetyStatus.danger)
                        BoxShadow(
                            color: const Color(0xFFff3b30).withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4))
                    ]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        widget.status == SafetyStatus.danger
                            ? Icons.u_turn_left
                            : Icons.check,
                        color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                        widget.status == SafetyStatus.danger
                            ? "INITIATE BACKTRACK"
                            : "SYSTEM OPTIMAL",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2))
                  ],
                ),
              ),
            ),

            TextButton(
                onPressed: widget.onSimulateMenu,
                child: Text("DEV TOOLS",
                    style: TextStyle(
                        color: Colors.grey.withOpacity(0.5), fontSize: 10)))
          ],
        ),
      ),
    );
  }

  // PAGE 2: Survival
  Widget _buildSurvivalPage(ScrollController controller) {
    return SingleChildScrollView(
      controller: controller,
      child: const Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("SURVIVAL GUIDE",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18)),
            SizedBox(height: 16),
            SurvivalCard(
                icon: Icons.water_drop,
                color: Colors.blue,
                label: "Find Water"),
            SizedBox(height: 12),
            SurvivalCard(
                icon: Icons.roofing,
                color: Colors.amber,
                label: "Build Shelter"),
            SizedBox(height: 12),
            SurvivalCard(
                icon: Icons.local_fire_department,
                color: Colors.red,
                label: "Start Fire"),
            SizedBox(height: 24),
            SonicBeaconButton(),
          ],
        ),
      ),
    );
  }
}
