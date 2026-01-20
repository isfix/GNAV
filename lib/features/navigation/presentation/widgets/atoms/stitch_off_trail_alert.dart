import 'package:flutter/material.dart';
import '../stitch/stitch_theme.dart';
import '../stitch/stitch_typography.dart';

/// Off-trail warning alert matching pandu_navigation_map_merbabu_3
class StitchOffTrailAlert extends StatelessWidget {
  /// Deviation distance in meters
  final double deviationMeters;

  /// Callback when backtrack button is pressed
  final VoidCallback? onBacktrack;

  const StitchOffTrailAlert({
    super.key,
    required this.deviationMeters,
    this.onBacktrack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: StitchTheme.danger,
        boxShadow: [
          BoxShadow(
            color: StitchTheme.danger.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'OFF TRAIL ALERT  DEVIATED ${deviationMeters.toInt()}m FROM PATH',
              style: StitchTypography.labelSmall.copyWith(
                color: Colors.white,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Danger overlay border for the screen
class StitchDangerOverlay extends StatefulWidget {
  final bool isActive;
  final Widget child;

  const StitchDangerOverlay({
    super.key,
    required this.isActive,
    required this.child,
  });

  @override
  State<StitchDangerOverlay> createState() => _StitchDangerOverlayState();
}

class _StitchDangerOverlayState extends State<StitchDangerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StitchDangerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: StitchTheme.danger.withOpacity(_animation.value),
                        width: 4,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

/// Warning status HUD item
class StitchStatusIndicator extends StatelessWidget {
  final String status; // 'SAFE', 'WARNING', 'DANGER'
  final double? deviationMeters;

  const StitchStatusIndicator({
    super.key,
    required this.status,
    this.deviationMeters,
  });

  Color get _color {
    switch (status.toUpperCase()) {
      case 'DANGER':
        return StitchTheme.danger;
      case 'WARNING':
        return StitchTheme.warning;
      default:
        return StitchTheme.primary;
    }
  }

  List<BoxShadow>? get _glow {
    switch (status.toUpperCase()) {
      case 'DANGER':
        return StitchTheme.dangerTextGlow;
      case 'WARNING':
        return StitchTheme.warningTextGlow;
      default:
        return StitchTheme.neonTextGlow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          deviationMeters != null ? 'DIST. DEVIATION' : 'STATUS',
          style: StitchTypography.labelMicro,
        ),
        const SizedBox(height: 4),
        Text(
          deviationMeters != null ? '${deviationMeters!.toInt()}m' : status,
          style: StitchTypography.hudValue.copyWith(
            color: _color,
            shadows: _glow,
          ),
        ),
      ],
    );
  }
}

/// Backtrack button
class StitchBacktrackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const StitchBacktrackButton({
    super.key,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: StitchTheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: StitchTheme.neonGlow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.undo_rounded,
              color: Colors.black,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'BACKTRACK',
              style: StitchTypography.buttonSmall.copyWith(
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
