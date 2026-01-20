import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StitchTypography {
  // Display Styles (Space Grotesk)
  static TextStyle displayLarge = GoogleFonts.spaceGrotesk(
    fontSize: 38,
    fontWeight: FontWeight.bold,
    height: 1.1,
    letterSpacing: -1.0,
    color: Colors.white,
  );

  static TextStyle displayMedium = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle displaySmall = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  // Body Styles (Inter)
  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    color: Colors.white,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    color: Colors.white.withOpacity(0.7),
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    color: Colors.white.withOpacity(0.6),
  );

  // Label Styles
  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: Colors.white.withOpacity(0.7),
  );

  static TextStyle labelTiny = GoogleFonts.inter(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    letterSpacing: 2.0,
    color: Colors.white.withOpacity(0.4),
  );

  static TextStyle labelMicro = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: Colors.white.withOpacity(0.5),
  );

  // HUD Styles (Space Grotesk for values)
  static TextStyle hudValue = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle hudValueLarge = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
    color: Colors.white,
  );

  // Mono Styles (JetBrains Mono for data)
  static TextStyle monoLarge = GoogleFonts.jetBrainsMono(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle monoMedium = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.white,
  );

  static TextStyle monoSmall = GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.white.withOpacity(0.7),
  );

  // Navigation Specific
  static TextStyle titleLarge = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle subtitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white.withOpacity(0.5),
  );

  // Badge Text
  static TextStyle badge = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  // Button Text
  static TextStyle buttonSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
    color: Colors.black,
  );
}
