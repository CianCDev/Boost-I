// lib/features/pos/presentation/widgets/common/glass_search_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';

/// Barra de búsqueda con glassmorphism.
class GlassSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final IconData prefixIcon;

  const GlassSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.prefixIcon = Icons.search_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}