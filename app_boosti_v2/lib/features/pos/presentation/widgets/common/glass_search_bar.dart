// lib/features/pos/presentation/widgets/common/glass_search_bar.dart
import 'dart:ui';
import 'package:flutter/material.dart';

/// Barra de búsqueda con glassmorphism.
class GlassSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final IconData prefixIcon;

  /// Radio del borde. Ajustable por si se usa dentro de contenedores
  /// con radios distintos (ej. 16 para diálogos, 12 para cards).
  final double borderRadius;

  /// Padding vertical interno. Ajustable para tamaños compactos.
  final double verticalPadding;

  const GlassSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    this.controller,
    this.prefixIcon = Icons.search_rounded,
    this.borderRadius = 16,
    this.verticalPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        // ✅ Blur más fuerte: así el fondo (productos/sidebar) se difumina
        //    visiblemente a través del cristal.
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            // ✅ Alpha mucho más bajo: 0.7 → 0.45 en light,
            //    0.06 → 0.05 en dark. Antes quedaba blanca sólida.
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.65),
              width: 1.2,
            ),
            boxShadow: [
              // Sombra sutil para dar profundidad al vidrio
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: isDark ? 0.20 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF111827),
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: verticalPadding,
              ),
            ),
          ),
        ),
      ),
    );
  }
}