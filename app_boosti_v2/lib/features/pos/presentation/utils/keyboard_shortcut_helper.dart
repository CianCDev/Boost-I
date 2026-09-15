// lib/features/pos/presentation/utils/keyboard_shortcut_helper.dart
import 'package:flutter/services.dart';

/// Utilidades puras para el manejo de atajos de teclado.
///
/// Sin dependencias de widgets ni Riverpod → 100% testeable.
class KeyboardShortcutHelper {
  KeyboardShortcutHelper._();

  /// Convierte una tecla en un número 1-9.
  ///
  /// Soporta dígitos del teclado principal y del numpad.
  /// Devuelve `null` si la tecla no es un dígito 1-9.
  static int? keyToDigit(LogicalKeyboardKey key) {
    return switch (key) {
      LogicalKeyboardKey.digit1 || LogicalKeyboardKey.numpad1 => 1,
      LogicalKeyboardKey.digit2 || LogicalKeyboardKey.numpad2 => 2,
      LogicalKeyboardKey.digit3 || LogicalKeyboardKey.numpad3 => 3,
      LogicalKeyboardKey.digit4 || LogicalKeyboardKey.numpad4 => 4,
      LogicalKeyboardKey.digit5 || LogicalKeyboardKey.numpad5 => 5,
      LogicalKeyboardKey.digit6 || LogicalKeyboardKey.numpad6 => 6,
      LogicalKeyboardKey.digit7 || LogicalKeyboardKey.numpad7 => 7,
      LogicalKeyboardKey.digit8 || LogicalKeyboardKey.numpad8 => 8,
      LogicalKeyboardKey.digit9 || LogicalKeyboardKey.numpad9 => 9,
      _ => null,
    };
  }
}