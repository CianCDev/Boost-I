// test/utils/keyboard_shortcut_helper_test.dart
import 'package:app_boosti_v2/features/pos/presentation/utils/keyboard_shortcut_helper.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KeyboardShortcutHelper.keyToDigit', () {
    test('mapea dígitos del teclado principal (1-9)', () {
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.digit1), 1);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.digit2), 2);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.digit3), 3);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.digit4), 4);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.digit5), 5);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.digit6), 6);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.digit7), 7);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.digit8), 8);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.digit9), 9);
    });

    test('mapea dígitos del numpad (1-9)', () {
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.numpad1), 1);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.numpad5), 5);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.numpad9), 9);
    });

    test('devuelve null para el 0 (digit y numpad)', () {
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.digit0), isNull);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.numpad0), isNull);
    });

    test('devuelve null para letras', () {
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.keyA), isNull);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.keyZ), isNull);
    });

    test('devuelve null para F-keys', () {
      for (final k in [
        LogicalKeyboardKey.f1,
        LogicalKeyboardKey.f2,
        LogicalKeyboardKey.f5,
        LogicalKeyboardKey.f12,
      ]) {
        expect(KeyboardShortcutHelper.keyToDigit(k), isNull);
      }
    });

    test('devuelve null para teclas de control', () {
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.escape), isNull);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.enter), isNull);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.delete), isNull);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.arrowUp), isNull);
      expect(KeyboardShortcutHelper.keyToDigit(LogicalKeyboardKey.space), isNull);
    });
  });
}