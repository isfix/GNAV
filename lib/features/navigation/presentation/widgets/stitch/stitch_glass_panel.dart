import 'dart:ui';
import 'package:flutter/material.dart';
import 'stitch_theme.dart';

class StitchGlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool hasGlow;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StitchGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.hasGlow = false,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    Widget content = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? StitchTheme.glass,
        borderRadius: radius,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: hasGlow ? StitchTheme.neonGlow : null,
      ),
      padding: padding,
      child: child,
    );

    // Apply Blur
    content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: content,
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
