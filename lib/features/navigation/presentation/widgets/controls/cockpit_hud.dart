import 'package:flutter/material.dart';
import '../../../logic/deviation_engine.dart';
import '../atoms/glass_pill.dart';

class CockpitHud extends StatelessWidget {
  final double altitude;
  final double accuracy;
  final double bearing;
  final SafetyStatus status;
  final double? speed;

  const CockpitHud({
    super.key,
    required this.altitude,
    required this.accuracy,
    required this.bearing,
    required this.status,
    this.speed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GlassPill(
              icon: Icons.landscape,
              label: 'ALT',
              value: altitude.toStringAsFixed(0),
              unit: 'm'),
          // Compass / Speed toggle
          GlassPill(
              icon: speed != null && speed! > 1.0 ? Icons.speed : Icons.explore,
              label: speed != null && speed! > 1.0 ? 'SPEED' : 'HEAD',
              value: speed != null && speed! > 1.0
                  ? (speed! * 3.6).toStringAsFixed(1)
                  : bearing.toStringAsFixed(0),
              unit: speed != null && speed! > 1.0 ? 'km/h' : '°',
              isCenter: true),
          GlassPill(
              icon: Icons.my_location,
              label: 'GPS',
              value: '±${accuracy.toStringAsFixed(0)}',
              unit: 'm'),
        ],
      ),
    );
  }
}
