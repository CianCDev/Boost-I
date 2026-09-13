// lib/features/pos/presentation/widgets/common/glass_card.dart
import 'package:flutter/material.dart';

/// Card base con glassmorphism, hover y estado.
/// Todos los listados (locales, proveedores, clientes, etc.) deben usarlo.
class GlassCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  /// Si true, muestra la barra lateral de color (indicador de estado).
  final bool showStatusBar;
  final Color statusColor;

  /// Resalta la card con un borde de color (ej. "local actual").
  final bool isHighlighted;
  final Color highlightColor;

  /// Margin externo.
  final EdgeInsets margin;

  const GlassCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.showStatusBar = false,
    this.statusColor = const Color(0xFF10B981),
    this.isHighlighted = false,
    this.highlightColor = const Color(0xFF10B981),
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Superficie adaptable
    final baseColor = isDark
        ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.75);
    final hoverColor = isDark
        ? colorScheme.surfaceContainerHighest
        : Colors.white;

    final borderColor = widget.isHighlighted
        ? widget.highlightColor.withValues(alpha: 0.5)
        : (_hovered
            ? widget.statusColor.withValues(alpha: 0.4)
            : colorScheme.outlineVariant.withValues(alpha: 0.4));

    final borderWidth = widget.isHighlighted ? 2.0 : 1.5;

    return Padding(
      padding: widget.margin,
      child: MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _hovered ? hoverColor : baseColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark
                      ? (_hovered ? 0.4 : 0.25)
                      : (_hovered ? 0.12 : 0.06),
                ),
                blurRadius: _hovered ? 20 : 10,
                offset: Offset(0, _hovered ? 8 : 4),
              ),
              if (widget.showStatusBar)
                BoxShadow(
                  color: widget.statusColor
                      .withValues(alpha: _hovered ? 0.18 : 0.06),
                  blurRadius: _hovered ? 15 : 8,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: widget.padding,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.showStatusBar) ...[
                      Container(
                        width: 4,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.statusColor,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: widget.statusColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                    ],
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}