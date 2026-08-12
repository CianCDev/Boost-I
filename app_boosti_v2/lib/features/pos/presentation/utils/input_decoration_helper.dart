// lib/features/pos/presentation/utils/input_decoration_helper.dart
import 'package:flutter/material.dart';

class InputDecorationHelper {
  static InputDecoration build({
    required BuildContext context,
    required String label,
    IconData? prefixIcon,
    String? errorText,
    String? hintText,
    bool isDark = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    // Color del borde normal: más visible en modo claro
    final borderColor = isDarkMode
        ? colorScheme.outline.withValues(alpha: 0.3)
        : Colors.grey.shade400;

    // Color del label
    final labelColor = isDarkMode
        ? colorScheme.onSurfaceVariant
        : Colors.grey.shade700;

    return InputDecoration(
      labelText: label,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: colorScheme.primary)
          : null,
      filled: true,
      fillColor: isDarkMode
          ? colorScheme.surfaceContainerHighest
          : Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      labelStyle: TextStyle(
        color: labelColor,
        fontWeight: FontWeight.w500,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: borderColor,
          width: isDarkMode ? 1.0 : 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF10B981), // Verde fijo
          width: 2.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2.5,
        ),
      ),
    );
  }
}