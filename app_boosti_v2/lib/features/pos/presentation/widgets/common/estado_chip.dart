// lib/features/pos/presentation/widgets/pedidos/estado_chip.dart
import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

/// Chip de estado de pedido.
///
/// Se adapta al tamaño de pantalla y al tema (dark/light).
/// Ahora incluye hover, cursor pointer y un texto más descriptivo.
class EstadoChip extends StatefulWidget {
  final EstadoPedido estado;

  /// Modo compacto (solo primera letra + ícono). Útil en tablas densas.
  final bool compact;

  /// Tamaño del chip.
  final EstadoChipSize size;

  const EstadoChip({
    super.key,
    required this.estado,
    this.compact = false,
    this.size = EstadoChipSize.medium,
  });

  @override
  State<EstadoChip> createState() => _EstadoChipState();
}

enum EstadoChipSize { small, medium, large }

class _EstadoChipState extends State<EstadoChip> {
  bool _hovered = false;

  Color _color() {
    switch (widget.estado) {
      case EstadoPedido.pendiente:
        return const Color(0xFFF59E0B);
      case EstadoPedido.recibido:
        return const Color.fromARGB(255, 98, 233, 188);
      case EstadoPedido.cancelado:
        return const Color(0xFFEF4444);
    }
  }

  IconData _icon() {
    switch (widget.estado) {
      case EstadoPedido.pendiente:
        return Icons.hourglass_top_rounded;
      case EstadoPedido.recibido:
        return Icons.check_circle_rounded;
      case EstadoPedido.cancelado:
        return Icons.cancel_rounded;
    }
  }

  String _label(bool esMobile) {
    if (widget.compact && esMobile) {
      return widget.estado.name.substring(0, 1).toUpperCase();
    }
    switch (widget.estado) {
      case EstadoPedido.pendiente:
        return 'Pendiente';
      case EstadoPedido.recibido:
        return 'Recibido';
      case EstadoPedido.cancelado:
        return 'Cancelado';
    }
  }

  /// Dimensiones según el size seleccionado.
  _ChipDims _dims(bool esMobile) {
    switch (widget.size) {
      case EstadoChipSize.small:
        return _ChipDims(
          hPad: esMobile ? 8 : 10,
          vPad: 4,
          iconSize: 12,
          fontSize: 10,
          gap: 4,
          radius: 8,
        );
      case EstadoChipSize.medium:
        return _ChipDims(
          hPad: esMobile ? 10 : 12,
          vPad: 6,
          iconSize: esMobile ? 14 : 16,
          fontSize: esMobile ? 11 : 12,
          gap: 6,
          radius: 10,
        );
      case EstadoChipSize.large:
        return _ChipDims(
          hPad: esMobile ? 14 : 16,
          vPad: 8,
          iconSize: esMobile ? 16 : 18,
          fontSize: esMobile ? 12 : 13,
          gap: 8,
          radius: 12,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final color = _color();
    final icon = _icon();
    final dims = _dims(isMobile);

    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: dims.hPad,
          vertical: dims.vPad,
        ),
        decoration: BoxDecoration(
          color: color.withValues(
            alpha: _hovered ? 0.22 : 0.14,
          ),
          borderRadius: BorderRadius.circular(dims.radius),
          border: Border.all(
            color: color.withValues(alpha: _hovered ? 0.55 : 0.35),
            width: 1.2,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: dims.iconSize, color: color),
            SizedBox(width: dims.gap),
            Text(
              _label(isMobile),
              style: TextStyle(
                fontSize: dims.fontSize,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.2,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipDims {
  final double hPad;
  final double vPad;
  final double iconSize;
  final double fontSize;
  final double gap;
  final double radius;
  const _ChipDims({
    required this.hPad,
    required this.vPad,
    required this.iconSize,
    required this.fontSize,
    required this.gap,
    required this.radius,
  });
}