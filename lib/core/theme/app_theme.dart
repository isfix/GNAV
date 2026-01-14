import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData highContrastDark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.black, // True Black for OLED
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF00FF00), // Neon Green
      onPrimary: Colors.black,
      secondary: Color(0xFFFF0000), // Alert Red
      onSecondary: Colors.white,
      surface: Color(0xFF121212),
      onSurface: Colors.white,
      error: Color(0xFFCF6679),
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
      bodyLarge: TextStyle(fontSize: 18, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
    ),
    iconTheme: const IconThemeData(
      color: Color(0xFF00FF00),
      size: 28,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00FF00),
        foregroundColor: Colors.black,
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
  );
}
