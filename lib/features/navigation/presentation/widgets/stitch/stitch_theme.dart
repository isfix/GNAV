import 'package:flutter/material.dart';

class StitchTheme {
  static const Color primary = Color(0xFF0df259); // Neon Green
  static const Color backgroundDark = Color(0xFF000000); // Amoled Black
  static const Color glass = Color(0xBF121212); // rgba(18, 18, 18, 0.75)
  static const Color tacticalGray = Color(0xFF121212);

  static const List<BoxShadow> neonGlow = [
    BoxShadow(
      color: Color(0x660df259), // 0.4 opacity
      blurRadius: 15,
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
}
