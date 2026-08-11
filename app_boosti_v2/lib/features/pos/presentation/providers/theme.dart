import 'package:flutter/material.dart';

// Colores base
const Color primaryBlue = Color(0xFF3B82F6);
const Color primaryDark = Color(0xFF1E293B);
const Color bgLight = Color(0xFFF8FAFC);
const Color bgDark = Color(0xFF0F172A);
const Color cardLight = Colors.white;
const Color cardDark = Color(0xFF1E293B);
const Color textLight = Color(0xFF0F172A);
const Color textDark = Color(0xFFF1F5F9);
const Color textDarkMuted = Color(0xFF94A3B8);

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryBlue,
      surface: cardLight,
      onSurface: textLight,
    ),
    scaffoldBackgroundColor: bgLight,
    cardTheme: const CardThemeData(
      color: cardLight,
      elevation: 2,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textLight),
      bodyMedium: TextStyle(color: textLight),
      titleLarge: TextStyle(color: textLight),
      titleMedium: TextStyle(color: textLight),
    ),
  );
}

ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: primaryBlue,
      surface: cardDark,
      onSurface: Colors.white,
      onPrimary: Colors.white,
    ),
    scaffoldBackgroundColor: bgDark,
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.grey.shade800.withOpacity(0.3),
          width: 1,
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
    ),
  );
}