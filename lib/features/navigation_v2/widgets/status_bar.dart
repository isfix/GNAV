import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '09:41',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontFamily: 'Space Grotesk',
              ),
            ),
            Row(
              children: [
                Icon(Icons.signal_cellular_alt, color: Colors.white70, size: 18),
                SizedBox(width: 4),
                Icon(Icons.wifi, color: Colors.white70, size: 18),
                SizedBox(width: 4),
                Icon(Icons.battery_5_bar, color: Colors.white70, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
