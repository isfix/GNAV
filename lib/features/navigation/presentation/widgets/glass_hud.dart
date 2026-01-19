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

/// The top cockpit HUD showing telemetry
class CockpitHud extends StatelessWidget {
  final double altitude;
  final double bearing;
  // TODO: Add speed or other stats

  const CockpitHud({
    super.key,
    required this.altitude,
    required this.bearing,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: GlassContainer(
          borderRadius: 24,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStat(Icons.height, "${altitude.toStringAsFixed(0)} m"),
              const SizedBox(width: 24),
              _buildStat(
                  Icons.explore_outlined, "${bearing.toStringAsFixed(0)}°"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon,
            size: 16,
            color: const Color(0xFF0df259)), // Keep neon accent for data
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
            fontFamily: 'monospace', // Tech feel
          ),
        ),
      ],
    );
  }
}

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
