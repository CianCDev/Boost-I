// lib/features/pos/presentation/widgets/common/filtro_chip.dart
import 'package:flutter/material.dart';

/// Chip de filtro reutilizable, consistente en toda la app.
///
/// Uso:
/// ```dart
/// FiltroChip(
///   label: 'Hoy',
///   icon: Icons.today_rounded,
///   color: Colors.blue,
///   selected: _periodo == Periodo.hoy,
///   onTap: () => setState(() => _periodo = Periodo.hoy),
/// )
/// ```
class FiltroChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  /// Contador opcional a la derecha (ej: 12).
  final int? count;

  /// Tamaño del chip.
  final FiltroChipSize size;

  /// Estilo visual: `outlined` (borde + tintado), `solid` (fondo lleno).
  final FiltroChipStyle style;

  const FiltroChip({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
    this.count,
    this.size = FiltroChipSize.medium,
    this.style = FiltroChipStyle.solid,
  });

  @override
  State<FiltroChip> createState() => _FiltroChipState();
}

enum FiltroChipSize { small, medium, large }
enum FiltroChipStyle { outlined, solid }

class _FiltroChipState extends State<FiltroChip> {
  bool _hovered = false;

  _FiltroDims _dims() {
    switch (widget.size) {
      case FiltroChipSize.small:
        return const _FiltroDims(
          hPad: 12, vPad: 8, iconSize: 14, fontSize: 11, gap: 6, radius: 20,
        );
      case FiltroChipSize.medium:
        return const _FiltroDims(
          hPad: 16, vPad: 10, iconSize: 16, fontSize: 13, gap: 8, radius: 24,
        );
      case FiltroChipSize.large:
        return const _FiltroDims(
          hPad: 20, vPad: 12, iconSize: 18, fontSize: 14, gap: 8, radius: 28,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dims = _dims();
    final sel = widget.selected;
    final color = widget.color;

    // Colores según estado
    final Color bg;
    final Color border;
    final Color fg;

    if (sel) {
      bg = color;
      border = color;
      fg = Colors.white;
    } else if (_hovered) {
      bg = color.withValues(alpha: 0.14);
      border = color.withValues(alpha: 0.4);
      fg = color;
    } else {
      bg = color.withValues(alpha: 0.05);
      border = color.withValues(alpha: 0.25);
      fg = color;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: dims.hPad,
            vertical: dims.vPad,
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(dims.radius),
            border: Border.all(color: border, width: 1.4),
            boxShadow: sel
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, size: dims.iconSize, color: fg),
              SizedBox(width: dims.gap),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: dims.fontSize,
                  fontWeight: FontWeight.w700,
                  color: fg,
                  letterSpacing: 0.2,
                  height: 1.1,
                ),
              ),
              if (widget.count != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: (sel ? Colors.white : color)
                        .withValues(alpha: sel ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${widget.count}',
                    style: TextStyle(
                      fontSize: dims.fontSize - 2,
                      fontWeight: FontWeight.w800,
                      color: fg,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FiltroDims {
  final double hPad;
  final double vPad;
  final double iconSize;
  final double fontSize;
  final double gap;
  final double radius;
  const _FiltroDims({
    required this.hPad,
    required this.vPad,
    required this.iconSize,
    required this.fontSize,
    required this.gap,
    required this.radius,
  });
}