import 'package:flutter/material.dart';
import '../../../core/theme/tactical_theme.dart';
import 'glass_panel.dart';

class HeaderDisplay extends StatelessWidget {
  const HeaderDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildAltitudeIndicator(),
          _buildCompassIndicator(),
          _buildGpsIndicator(),
        ],
      ),
    );
  }

  Widget _buildAltitudeIndicator() {
    return const GlassPanel(
      child: Row(
        children: [
          Icon(Icons.landscape, color: TacticalTheme.primary, size: 20),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Alt', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('2,450m', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompassIndicator() {
    return const GlassPanel(
      child: Row(
        children: [
          Icon(Icons.explore, color: TacticalTheme.primary, size: 20),
          SizedBox(width: 8),
          Text('285° NW', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildGpsIndicator() {
    return const GlassPanel(
      child: Row(
        children: [
          Icon(Icons.my_location, color: TacticalTheme.primary, size: 20),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GPS', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
              Text('±3m', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
