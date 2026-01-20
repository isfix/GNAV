import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../stitch/stitch_theme.dart';
import '../stitch/stitch_typography.dart';

/// Premium SVG-style compass widget matching pandu_navigation_map_merbabu_1
class StitchCompass extends StatelessWidget {
  /// Current bearing in degrees (0-360, 0 = North)
  final double bearing;

  /// Size of the compass widget
  final double size;

  const StitchCompass({
    super.key,
    required this.bearing,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassPainter(bearing: bearing),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Empty center - painter handles the needle
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  final double bearing;

  _CompassPainter({required this.bearing});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer glow gradient
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          StitchTheme.primary.withOpacity(0.1),
          StitchTheme.primary.withOpacity(0.0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.88, glowPaint);

    // Outer ring
    final ringPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.85, ringPaint);

    // Tick marks ring (dashed)
    final tickPaint = Paint()
      ..color = const Color(0xFF444444)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14;
    canvas.drawCircle(center, radius * 0.73, tickPaint);

    // Cardinal direction ticks (N, E, S, W)
    final cardinalPaint = Paint()
      ..color = StitchTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 2;
      final innerPoint = Offset(
        center.dx + (radius * 0.6) * math.cos(angle),
        center.dy + (radius * 0.6) * math.sin(angle),
      );
      final outerPoint = Offset(
        center.dx + (radius * 0.82) * math.cos(angle),
        center.dy + (radius * 0.82) * math.sin(angle),
      );
      canvas.drawLine(innerPoint, outerPoint, cardinalPaint);
    }

    // Draw cardinal labels
    _drawCardinalLabel(canvas, center, radius, 'N', 0, true);
    _drawCardinalLabel(canvas, center, radius, 'E', 90, false);
    _drawCardinalLabel(canvas, center, radius, 'S', 180, false);
    _drawCardinalLabel(canvas, center, radius, 'W', 270, false);

    // Draw needle (rotated by bearing)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate((-bearing) * math.pi / 180);

    // Needle glow
    final needleGlowPaint = Paint()
      ..color = StitchTheme.primary.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset.zero, 6, needleGlowPaint);

    // North needle (green)
    final northNeedlePath = Path()
      ..moveTo(0, -radius * 0.55)
      ..lineTo(6, 0)
      ..lineTo(-6, 0)
      ..close();
    final northPaint = Paint()..color = StitchTheme.primary;
    canvas.drawPath(northNeedlePath, northPaint);

    // South needle (dark)
    final southNeedlePath = Path()
      ..moveTo(0, radius * 0.55)
      ..lineTo(6, 0)
      ..lineTo(-6, 0)
      ..close();
    final southPaint = Paint()..color = const Color(0xFF222222);
    canvas.drawPath(southNeedlePath, southPaint);

    // Center circle
    final centerBgPaint = Paint()..color = StitchTheme.tacticalGray;
    canvas.drawCircle(Offset.zero, 4, centerBgPaint);
    final centerRingPaint = Paint()
      ..color = StitchTheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset.zero, 4, centerRingPaint);

    canvas.restore();
  }

  void _drawCardinalLabel(
    Canvas canvas,
    Offset center,
    double radius,
    String label,
    double degrees,
    bool isPrimary,
  ) {
    final angle = (degrees - 90) * math.pi / 180;
    final labelRadius = radius * 0.92;
    final position = Offset(
      center.dx + labelRadius * math.cos(angle),
      center.dy + labelRadius * math.sin(angle),
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isPrimary ? StitchTheme.primary : const Color(0xFF555555),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) {
    return oldDelegate.bearing != bearing;
  }
}

/// Compact bearing display with direction label
class StitchBearingDisplay extends StatelessWidget {
  final double bearing;
  final bool showLabel;

  const StitchBearingDisplay({
    super.key,
    required this.bearing,
    this.showLabel = true,
  });

  String get _direction {
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

  String get _fullDirection {
    switch (_direction) {
      case 'N':
        return 'North';
      case 'NE':
        return 'North East';
      case 'E':
        return 'East';
      case 'SE':
        return 'South East';
      case 'S':
        return 'South';
      case 'SW':
        return 'South West';
      case 'W':
        return 'West';
      case 'NW':
        return 'North West';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: StitchTheme.primary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: StitchTheme.primary.withOpacity(0.5),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Text(
              'BEARING',
              style: StitchTypography.labelMicro.copyWith(
                color: StitchTheme.primary.withOpacity(0.8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        // Value
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '${bearing.toInt()}°',
              style: StitchTypography.monoLarge.copyWith(
                shadows: StitchTheme.neonTextGlow,
              ),
            ),
          ],
        ),
        if (showLabel)
          Text(
            _fullDirection.toUpperCase(),
            style: StitchTypography.labelMicro.copyWith(
              color: StitchTheme.textDim,
              letterSpacing: 2,
            ),
          ),
      ],
    );
  }
}
