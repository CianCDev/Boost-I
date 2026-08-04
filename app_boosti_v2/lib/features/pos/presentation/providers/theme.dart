import 'package:flutter/material.dart';

// Colores base
const Color primaryBlue = Color(0xFF3B82F6);
const Color primaryDark = Color(0xFF1E293B);
const Color grayLight = Color(0xFF64748B);
const Color grayDark = Color(0xFF94A3B8);
const Color bgLight = Color(0xFFF8FAFC);
const Color bgDark = Color(0xFF0F172A);
const Color cardLight = Colors.white;
const Color cardDark = Color(0xFF1E293B);

ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryBlue,
      surface: cardLight,
      onSurface: Color(0xFF0F172A),
    ),
    scaffoldBackgroundColor: bgLight,
    cardTheme: CardThemeData( // ← CAMBIADO DE CardTheme A CardThemeData
      color: cardLight,
      elevation: 2,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cardLight,
      foregroundColor: Color(0xFF0F172A),
      elevation: 1,
      centerTitle: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF0F172A)),
      bodyMedium: TextStyle(color: Color(0xFF0F172A)),
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
    ),
    scaffoldBackgroundColor: bgDark,
    cardTheme: CardThemeData( // ← CAMBIADO DE CardTheme A CardThemeData
      color: cardDark,
      elevation: 2,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: cardDark,
      foregroundColor: Colors.white,
      elevation: 1,
      centerTitle: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cardDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );
}