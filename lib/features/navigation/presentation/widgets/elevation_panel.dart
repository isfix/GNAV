import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:latlong2/latlong.dart';
import '../../logic/eta_engine.dart';

class ElevationPanel extends StatelessWidget {
  final List<LatLng> trailPoints;
  // We assume Z is passed separately or part of logic, but LatLng doesn't store Z by default in all versions.
  // For this mock, we accept explicit Altitudes list matching logic.
  final List<double> altitudes;
  final double currentProgress; // 0.0 to 1.0
  final Duration? etaToNextPos;
  final String? nextPosName;

  const ElevationPanel({
    super.key,
    required this.trailPoints,
    required this.altitudes,
    required this.currentProgress,
    this.etaToNextPos,
    this.nextPosName,
  });

  @override
  Widget build(BuildContext context) {
    if (altitudes.isEmpty) return const SizedBox.shrink();

    // Map altitudes to FL Spots
    final spots = <FlSpot>[];
    for (int i = 0; i < altitudes.length; i++) {
      // X = Index (or distance ratio), Y = Altitude
      spots.add(FlSpot(i.toDouble(), altitudes[i]));
    }

    final maxAlt = altitudes.reduce((a, b) => a > b ? a : b);
    final minAlt = altitudes.reduce((a, b) => a < b ? a : b);

    // Current Position Indicator
    final currentX = (altitudes.length - 1) * currentProgress;
    // Simple linear interpolation for Y
    final indexFloor = currentX.floor();
    final indexCeil = currentX.ceil();
    final t = currentX - indexFloor;
    final currentY = (altitudes[indexFloor] * (1 - t)) +
        (altitudes[min(indexCeil, altitudes.length - 1)] * t);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E).withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: ETA
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("ELEVATION PROFILE",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 4),
                  if (nextPosName != null)
                    Text("Next: $nextPosName",
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))
                  else
                    const Text("Track Selection",
                        style: TextStyle(color: Colors.white)),
                ],
              ),
              if (etaToNextPos != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0df259).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF0df259)),
                  ),
                  child: Text("ETA ${EtaEngine.formatDuration(etaToNextPos!)}",
                      style: const TextStyle(
                          color: Color(0xFF0df259),
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Chart
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                minY: minAlt - 50,
                maxY: maxAlt + 50,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: const Color(0xFF0df259),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                        show: true,
                        color: const Color(0xFF0df259).withOpacity(0.1)),
                  ),
                ],
                extraLinesData: ExtraLinesData(verticalLines: [
                  VerticalLine(
                    x: currentX,
                    color: Colors.white,
                    strokeWidth: 2,
                    dashArray: [5, 5],
                  ),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int min(int a, int b) => a < b ? a : b;
}
