import 'package:flutter/material.dart';
import '../stitch/stitch_theme.dart';
import '../stitch/stitch_typography.dart';

/// Trail progress bar with neon glow matching pandu_navigation_map_merbabu_2
class StitchProgressBar extends StatelessWidget {
  /// Completed distance in meters
  final double completedDistance;

  /// Total distance in meters
  final double totalDistance;

  /// Whether to show labels
  final bool showLabels;

  const StitchProgressBar({
    super.key,
    required this.completedDistance,
    required this.totalDistance,
    this.showLabels = true,
  });

  double get _progress => totalDistance > 0
      ? (completedDistance / totalDistance).clamp(0.0, 1.0)
      : 0.0;

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.toInt()} m';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showLabels)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDistance(completedDistance),
                      style: StitchTypography.hudValue.copyWith(fontSize: 18),
                    ),
                    Text(
                      'COMPLETED',
                      style: StitchTypography.labelMicro,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDistance(totalDistance - completedDistance),
                      style: StitchTypography.hudValue.copyWith(fontSize: 18),
                    ),
                    Text(
                      'REMAINING',
                      style: StitchTypography.labelMicro,
                    ),
                  ],
                ),
              ],
            ),
          ),
        // Progress bar
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: StitchTheme.borderLight,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              // Progress fill
              FractionallySizedBox(
                widthFactor: _progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: StitchTheme.primary,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: StitchTheme.primary.withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Compact progress indicator (just the bar)
class StitchProgressBarCompact extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final double height;

  const StitchProgressBarCompact({
    super.key,
    required this.progress,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: StitchTheme.borderLight,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: StitchTheme.primary,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: StitchTheme.primary.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
