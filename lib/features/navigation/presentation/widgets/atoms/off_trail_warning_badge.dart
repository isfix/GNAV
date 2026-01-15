import 'package:flutter/material.dart';
import 'dart:ui';

class OffTrailWarningBadge extends StatelessWidget {
  const OffTrailWarningBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFff3b30).withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFff3b30).withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFFff3b30).withOpacity(0.4),
                  blurRadius: 20)
            ],
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('OFF TRAIL DETECTED',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
            ],
          ),
        ),
      ),
    );
  }
}
