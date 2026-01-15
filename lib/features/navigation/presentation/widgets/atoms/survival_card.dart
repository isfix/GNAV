import 'package:flutter/material.dart';

class SurvivalCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const SurvivalCard(
      {super.key,
      required this.icon,
      required this.color,
      required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        String message = "Advice: Stay calm.";
        if (label == "Find Water") {
          message = "Look for valleys, animal tracks, or morning dew.";
        }
        if (label == "Build Shelter") {
          message = "Find a wind-blocked area, insulate from ground.";
        }
        if (label == "Start Fire") {
          message = "Gather dry tinder, shield from wind, use sparks.";
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(message),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
