import 'dart:ui';

import 'package:flutter/material.dart';

class GlassItemCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Widget subtitle;
  final Color statusColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailingWidget;
  final EdgeInsets padding;

  const GlassItemCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.statusColor,
    this.onTap,
    this.onLongPress,
    this.trailingWidget,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  State<GlassItemCard> createState() => _GlassItemCardState();
}

class _GlassItemCardState extends State<GlassItemCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: MouseRegion(
          cursor: widget.onTap == null
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isDark
                  ? colors.surfaceContainerHigh.withValues(
                      alpha: _hovered ? 0.82 : 0.66,
                    )
                  : Colors.white.withValues(
                      alpha: _hovered ? 0.24 : 0.1,
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : widget.statusColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.statusColor.withValues(
                    alpha: _hovered ? 0.18 : 0.09,
                  ),
                  blurRadius: _hovered ? 20 : 12,
                  offset: Offset(0, _hovered ? 7 : 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: widget.padding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: widget.statusColor.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.statusColor,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                // Título oscuro sobre fondo claro para mejor
                                // contraste y legibilidad.
                                color: isDark ? colors.onSurface : Colors.black87,
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            DefaultTextStyle(
                              style: TextStyle(
                                // Texto secundario en gris oscuro legible
                                // sobre fondo claro (ej. "Capacidad: 4 pax",
                                // "Mesero: ...").
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.85)
                                    : Colors.black.withValues(alpha: 0.7),
                                fontSize: 13,
                              ),
                              child: widget.subtitle,
                            ),
                          ],
                        ),
                      ),
                      if (widget.trailingWidget != null) ...[
                        const SizedBox(width: 8),
                        widget.trailingWidget!,
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
