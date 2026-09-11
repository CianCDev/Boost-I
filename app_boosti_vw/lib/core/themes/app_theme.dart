import 'package:flutter/material.dart';

class AppTheme {
  // Colores principales de la interfaz de caja
  static const Color primaryDark = Color(0xFF0F172A);  // Slate 900
  static const Color accentGreen = Color(0xFF10B981);  // Emerald 500
  static const Color backgroundBg = Color(0xFFF8FAFC); // Slate 50
  static const Color surfaceWhite = Colors.white;

  static ThemeData get desktopTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        primary: primaryDark,
        secondary: accentGreen,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}