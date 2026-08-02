import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para almacenar el ThemeMode (sistema, claro u oscuro)
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Valor inicial: seguir el sistema (o claro)
  return ThemeMode.system;
});

// Provider para acceder fácilmente al tema actual
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  // Si es sistema, detecta el modo del sistema
  if (themeMode == ThemeMode.system) {
    return WidgetsBinding.instance.window.platformBrightness == Brightness.dark;
  }
  return themeMode == ThemeMode.dark;
});

