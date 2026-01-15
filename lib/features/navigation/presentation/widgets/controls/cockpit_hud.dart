import 'package:flutter/material.dart';
import '../../../logic/deviation_engine.dart';
import '../atoms/glass_pill.dart';

class CockpitHud extends StatelessWidget {
  final double altitude;
  final double accuracy;
  final double bearing;
  final SafetyStatus status;

  const CockpitHud({
    super.key,
    required this.altitude,
    required this.accuracy,
    required this.bearing,
    required this.status,
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
          GlassPill(
              icon: Icons.explore,
              label: 'HEAD',
              value: bearing.toStringAsFixed(0),
              unit: '° NW',
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
