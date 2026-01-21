import 'dart:ui';
import 'package:flutter/material.dart';

/// A reusable Glassmorphic container with blur and gradient border
class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 16.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: (color ?? Colors.black).withOpacity(0.4),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

// CockpitHud moved to widgets/controls/cockpit_hud.dart to avoid duplication

/// Floating action button in glass style
class GlassFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;

  const GlassFab({
    super.key,
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        width: 48,
        height: 48,
        borderRadius: 24,
        padding: EdgeInsets.zero,
        color: active ? const Color(0xFF0df259).withOpacity(0.2) : null,
        child: Center(
          child: Icon(
            icon,
            color: active ? const Color(0xFF0df259) : Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }
}
