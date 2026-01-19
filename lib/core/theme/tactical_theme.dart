import 'package:flutter/material.dart';

class TacticalTheme {
  static const Color primary = Color(0xFF0DF259);
  static const Color danger = Color(0xFFFF3B30);
  static const Color backgroundDark = Color(0xFF050505);
  static const Color surfaceDark = Color(0xFF121212);
  static const String fontDisplay = "Space Grotesk";

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: backgroundDark,
    fontFamily: fontDisplay,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.black,
      secondary: danger,
      onSecondary: Colors.white,
      surface: surfaceDark,
      onSurface: Colors.white,
      error: danger,
      onError: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontFamily: fontDisplay, fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      displayMedium: TextStyle(fontFamily: fontDisplay, fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      displaySmall: TextStyle(fontFamily: fontDisplay, fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontFamily: fontDisplay, fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontFamily: fontDisplay, fontSize: 14, color: Colors.white70),
      bodySmall: TextStyle(fontFamily: fontDisplay, fontSize: 12, color: Colors.white54),
    ),
    iconTheme: const IconThemeData(
      color: primary,
      size: 24,
    ),
  );
}
