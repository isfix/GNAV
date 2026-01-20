import 'package:flutter/material.dart';
import '../stitch/stitch_theme.dart';
import '../stitch/stitch_typography.dart';
import '../stitch/stitch_glass_panel.dart';

/// Tracking status panel matching pandu_navigation_map_merbabu_1/2 design
class StitchTrackingPanel extends StatelessWidget {
  /// Elapsed time in seconds
  final int elapsedSeconds;

  /// Whether tracking is currently active
  final bool isActive;

  /// Callback when pause button is pressed
  final VoidCallback? onPause;

  /// Callback when resume button is pressed
  final VoidCallback? onResume;

  const StitchTrackingPanel({
    super.key,
    required this.elapsedSeconds,
    this.isActive = true,
    this.onPause,
    this.onResume,
  });

  String get _formattedTime {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return StitchGlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          // Icon with pulse
          Stack(
            alignment: Alignment.center,
            children: [
              if (isActive)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: StitchTheme.primary.withOpacity(0.1),
                  ),
                ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: StitchTheme.primary.withOpacity(0.1),
                  border: Border.all(
                    color: StitchTheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  Icons.my_location,
                  color: StitchTheme.primary,
                  size: 24,
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // Status and timer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Row(
                  children: [
                    _PulsingDot(isActive: isActive),
                    const SizedBox(width: 8),
                    Text(
                      isActive ? 'TRACKING ACTIVE' : 'PAUSED',
                      style: StitchTypography.labelMicro.copyWith(
                        color: isActive
                            ? StitchTheme.primary
                            : StitchTheme.warning,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Timer
                Text(
                  _formattedTime,
                  style: StitchTypography.monoLarge.copyWith(
                    fontSize: 28,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Pause/Resume button
          GestureDetector(
            onTap: isActive ? onPause : onResume,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: StitchTheme.glassLight,
                border: Border.all(color: StitchTheme.borderLight),
              ),
              child: Icon(
                isActive ? Icons.pause : Icons.play_arrow,
                color: StitchTheme.textMuted,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated pulsing dot
class _PulsingDot extends StatefulWidget {
  final bool isActive;

  const _PulsingDot({required this.isActive});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_PulsingDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.isActive ? StitchTheme.primary : StitchTheme.warning,
            shape: BoxShape.circle,
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: StitchTheme.primary
                          .withOpacity(_animation.value * 0.6),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }
}
