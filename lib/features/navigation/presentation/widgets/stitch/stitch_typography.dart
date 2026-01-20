import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StitchTypography {
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

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    color: Colors.white,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.5,
    color: Colors.white.withOpacity(0.7),
  );

  // Custom for HUD
  static TextStyle hudValue = GoogleFonts.spaceGrotesk(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
}
