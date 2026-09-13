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
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: screen.height * maxHeightFactor,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
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