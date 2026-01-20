import 'package:flutter/material.dart';

class StitchTheme {
  // Primary Colors
  static const Color primary = Color(0xFF0df259); // Neon Green
  static const Color primaryAlt = Color(0xFF00FF66); // Alternate Green
  static const Color backgroundDark = Color(0xFF000000); // Amoled Black
  static const Color glass = Color(0xBF121212); // rgba(18, 18, 18, 0.75)
  static const Color glassLight =
      Color(0x08FFFFFF); // rgba(255, 255, 255, 0.03)
  static const Color tacticalGray = Color(0xFF121212);
  static const Color cardDark = Color(0xFF141414);

  // Status Colors
  static const Color warning = Color(0xFFFFAA00); // Orange warning
  static const Color danger = Color(0xFFFF3B30); // Red danger
  static const Color safe = primary;

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0x99FFFFFF); // 60% white
  static const Color textDim = Color(0x66FFFFFF); // 40% white
  static const Color textSubtle = Color(0x3DFFFFFF); // 24% white

  // Border Colors
  static const Color borderSubtle = Color(0x1AFFFFFF); // 10% white
  static const Color borderLight = Color(0x14FFFFFF); // 8% white
  static const Color borderPrimary = Color(0x4D0df259); // 30% primary

  // Primary Glow
  static const List<BoxShadow> neonGlow = [
    BoxShadow(
      color: Color(0x660df259), // 0.4 opacity
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> neonGlowStrong = [
    BoxShadow(
      color: Color(0x990df259), // 0.6 opacity
      blurRadius: 20,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> neonTextGlow = [
    BoxShadow(
      color: Color(0x990df259), // 0.6 opacity
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Warning Glow
  static const List<BoxShadow> warningGlow = [
    BoxShadow(
      color: Color(0x66FFAA00), // 0.4 opacity
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> warningTextGlow = [
    BoxShadow(
      color: Color(0x99FFAA00), // 0.6 opacity
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Danger Glow
  static const List<BoxShadow> dangerGlow = [
    BoxShadow(
      color: Color(0x66FF3B30), // 0.4 opacity
      blurRadius: 15,
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> dangerTextGlow = [
    BoxShadow(
      color: Color(0x99FF3B30), // 0.6 opacity
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  // Logo Glow (smaller for dot)
  static const List<BoxShadow> logoGlow = [
    BoxShadow(
      color: Color(0x990df259), // 0.6 opacity
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  // Card Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x80000000),
      blurRadius: 20,
      offset: Offset(0, -10),
    ),
  ];

  // Decorations
  static BoxDecoration get glassDecoration => BoxDecoration(
        color: glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderSubtle, width: 1),
      );

  static BoxDecoration get glassLightDecoration => BoxDecoration(
        color: glassLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderLight, width: 1),
      );
}
