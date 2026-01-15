import 'package:flutter/material.dart';
import 'dart:ui';

class GlassPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final bool isCenter;

  const GlassPill(
      {super.key,
      required this.icon,
      required this.label,
      required this.value,
      required this.unit,
      this.isCenter = false});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: isCenter ? 24 : 16),
          decoration: BoxDecoration(
            color: const Color(0xFF141414).withOpacity(0.6),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: const Color(0xFF0df259), size: 20),
              const SizedBox(width: 8),
              if (!isCenter)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2)),
                    RichText(
                        text: TextSpan(children: [
                      TextSpan(
                          text: value,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: unit,
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 10))
                    ]))
                  ],
                )
              else
                Text('$value$unit',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
