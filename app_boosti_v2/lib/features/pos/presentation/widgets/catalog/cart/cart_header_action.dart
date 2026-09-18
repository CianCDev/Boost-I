// lib/features/pos/presentation/widgets/common/cart_header_action.dart
import 'package:flutter/material.dart';

/// Botón pill reutilizable para la cabecera del carrito.
///
/// Modos:
/// - `compact: true` → solo icono (para el sidebar estrecho).
/// - `compact: false` → icono + label (para el bottom sheet).
///
/// Opcionalmente muestra un badge numérico en la esquina.
class CartHeaderAction extends StatefulWidget {
  final IconData icon;
  final String? label;
  final String tooltip;
  final Color color;
  final VoidCallback? onPressed;

  /// Contador a mostrar en el badge. `null` o `0` → sin badge.
  final int? badge;

  /// Fuerza el estilo "solo icono" (para cabeceras compactas).
  final bool compact;

  const CartHeaderAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.color,
    this.label,
    this.onPressed,
    this.badge,
    this.compact = false,
  });

  @override
  State<CartHeaderAction> createState() => _CartHeaderActionState();
}

class _CartHeaderActionState extends State<CartHeaderAction> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // ignore: unused_local_variable
    final isDark = theme.brightness == Brightness.dark;
    final disabled = widget.onPressed == null;

    final bg = disabled
        ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)
        : widget.color.withValues(alpha: _hovered ? 0.20 : 0.12);

    final border = disabled
        ? colorScheme.outlineVariant.withValues(alpha: 0.4)
        : widget.color.withValues(alpha: _hovered ? 0.55 : 0.35);

    final fg = disabled
        ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
        : widget.color;

    final showLabel = !widget.compact && widget.label != null;

    return Tooltip(
      message: widget.tooltip,
      waitDuration: const Duration(milliseconds: 400),
      child: MouseRegion(
        cursor: disabled
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              horizontal: showLabel ? 14 : 10,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: 1.3),
              boxShadow: _hovered && !disabled
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(widget.icon, size: 18, color: fg),
                    if ((widget.badge ?? 0) > 0)
                      Positioned(
                        right: -8,
                        top: -6,
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: widget.color,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: widget.color.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(minWidth: 16),
                          child: Text(
                            (widget.badge! > 9 ? '9+' : '${widget.badge}'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (showLabel) ...[
                  const SizedBox(width: 8),
                  Text(
                    widget.label!,
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}