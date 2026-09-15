// lib/features/pos/presentation/widgets/common/glass_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';

/// Contenedor base para todos los diálogos con efecto glassmorphism.
/// Unifica: blur, borde, sombra, radius y colores adaptativos.
class GlassDialog extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final double maxHeightFactor;
  final EdgeInsets insetPadding;
  final Color accentColor;
  final bool scrollable;

  const GlassDialog({
    super.key,
    required this.child,
    this.maxWidth = 500,
    this.maxHeightFactor = 0.9,
    this.insetPadding =
        const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    this.accentColor = const Color(0xFF8B5CF6),
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screen = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: insetPadding,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: screen.height * maxHeightFactor,
            ),
            decoration: BoxDecoration(
              // ✅ Alpha baja para que el blur se perciba:
              // 0.95 → parecía opaco, el vidrio no se veía.
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.9),
                width: 1.5,
              ),
              boxShadow: [
                // Resplandor del acento
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.18),
                  blurRadius: 50,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
                // Sombra profunda
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                  blurRadius: 30,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: scrollable
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: child,
                  )
                : child,
          ),
        ),
      ),
    );
  }
}