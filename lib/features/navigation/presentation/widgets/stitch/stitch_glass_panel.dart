import 'dart:ui';
import 'package:flutter/material.dart';
import 'stitch_theme.dart';

class StitchGlassPanel extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final bool hasGlow;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool enableTapAnimation;
  final double blurSigma;

  const StitchGlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.hasGlow = false,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.enableTapAnimation = true,
    this.blurSigma = 12,
  });

  @override
  State<StitchGlassPanel> createState() => _StitchGlassPanelState();
}

class _StitchGlassPanelState extends State<StitchGlassPanel> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? BorderRadius.circular(16);

    Widget content = Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? StitchTheme.glass,
        borderRadius: radius,
        border: Border.all(
          color: widget.borderColor ?? Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          if (widget.hasGlow) ...StitchTheme.neonGlow,
          // Subtle inner shadow effect
          BoxShadow(
            color: Colors.white.withOpacity(0.03),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: widget.padding,
      child: widget.child,
    );

    // Apply Blur
    content = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: widget.blurSigma,
          sigmaY: widget.blurSigma,
        ),
        child: content,
      ),
    );

    // Apply tap animation
    if (widget.onTap != null && widget.enableTapAnimation) {
      content = AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: content,
      );
    }

    if (widget.onTap != null) {
      return GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: content,
      );
    }

    return content;
  }
}

/// A simpler glass container without blur (for performance)
class StitchGlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const StitchGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(16);

    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? StitchTheme.glassLight,
        borderRadius: radius,
        border: Border.all(
          color: StitchTheme.borderLight,
          width: 1,
        ),
      ),
      padding: padding,
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
