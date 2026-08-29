import 'package:flutter/material.dart';
import '../../../data/Local/entities/gasto_entity.dart';

class GastosItem extends StatefulWidget {
  final GastoEntity gasto;
  final bool isMobile;
  final bool isTablet;
  final VoidCallback onTap;

  const GastosItem({
    super.key,
    required this.gasto,
    required this.isMobile,
    required this.isTablet,
    required this.onTap,
  });

  @override
  State<GastosItem> createState() => _GastosItemState();
}

class _GastosItemState extends State<GastosItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gasto = widget.gasto;
    final fechaLocal = gasto.fecha.toLocal();
    final String fechaStr =
        '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year} ${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';
    final String montoStr = gasto.moneda == 'USD'
        ? '\$${gasto.monto.toStringAsFixed(2)}'
        : 'Bs. ${gasto.monto.toStringAsFixed(2)}';

    final Color colorMonto = const Color(0xFFEF4444);

    final double horizontalPadding = widget.isTablet ? 28 : 14;
    final double verticalPadding = widget.isTablet ? 20 : 14;
    final double iconSize = widget.isTablet ? 56 : 40;
    final double iconInnerSize = widget.isTablet ? 32 : 20;
    final double fontSizeDesc = widget.isTablet ? 18 : 14;
    final double fontSizeFecha = widget.isTablet ? 15 : 11;
    final double fontSizeMonto = widget.isTablet ? 22 : 16;
    final double chevronSize = widget.isTablet ? 36 : 20;
    final double categoryIconSize = widget.isTablet ? 18 : 14;

    IconData categoryIcon;
    switch (gasto.categoria.toLowerCase()) {
      case 'alimentación':
        categoryIcon = Icons.restaurant_rounded;
        break;
      case 'transporte':
        categoryIcon = Icons.directions_car_rounded;
        break;
      case 'servicios':
        categoryIcon = Icons.construction_rounded;
        break;
      default:
        categoryIcon = Icons.category_rounded;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovering
              ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
              : Matrix4.identity(),
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovering
                  ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: _isHovering ? 2.0 : 1.0,
            ),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.money_off_rounded,
                  color: const Color(0xFFEF4444),
                  size: iconInnerSize,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      gasto.descripcion,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: fontSizeDesc,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          fechaStr,
                          style: TextStyle(
                            fontSize: fontSizeFecha,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '•',
                          style: TextStyle(
                            fontSize: fontSizeFecha,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (widget.isTablet) ...[
                          Icon(
                            categoryIcon,
                            size: categoryIconSize,
                            color: const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            gasto.categoria,
                            style: TextStyle(
                              fontSize: fontSizeFecha,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            categoryIcon,
                            size: categoryIconSize,
                            color: const Color(0xFFEF4444),
                          ),
                        ],
                        if (gasto.usuarioNombre.isNotEmpty) ...[
                          Text(
                            '•',
                            style: TextStyle(
                              fontSize: fontSizeFecha,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            gasto.usuarioNombre,
                            style: TextStyle(
                              fontSize: fontSizeFecha,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    montoStr,
                    style: TextStyle(
                      fontSize: fontSizeMonto,
                      fontWeight: FontWeight.w800,
                      color: colorMonto,
                    ),
                  ),
                  Text(
                    gasto.moneda == 'USD' ? 'USD' : 'Bs.',
                    style: TextStyle(
                      fontSize: widget.isTablet ? 14 : 10,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: chevronSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}