import 'package:flutter/material.dart';
import 'dart:math' as math;

class CompassBearing extends StatelessWidget {
  final double heading;
  final Widget child;
  const CompassBearing({super.key, required this.heading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: (heading * (math.pi / 180)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.arrow_drop_up, color: Color(0xFFff3b30), size: 24),
          child,
        ],
      ),
    );
  }
}
