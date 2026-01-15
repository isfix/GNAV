import 'package:flutter/material.dart';
import 'dart:ui';

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const GlassIconButton(
      {super.key,
      required this.icon,
      required this.onTap,
      this.isPrimary = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF141414).withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isPrimary
                      ? const Color(0xFF0df259).withOpacity(0.3)
                      : Colors.white.withOpacity(0.1)),
            ),
            child: Icon(icon,
                color: isPrimary ? const Color(0xFF0df259) : Colors.white,
                size: 24),
          ),
        ),
      ),
    );
  }
}
