import 'package:flutter/material.dart';
import '../../../data/Local/entities/venta_entity.dart';
import 'sales_history_detail_dialog.dart';

class SalesHistoryItem extends StatefulWidget {
  final VentaEntity venta;
  final bool isMobile;
  final bool isTablet;

  const SalesHistoryItem({
    super.key,
    required this.venta,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  State<SalesHistoryItem> createState() => _SalesHistoryItemState();
}

class _SalesHistoryItemState extends State<SalesHistoryItem> {
  bool isHovering = false;

  void _showDetailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => SalesHistoryDetailDialog(venta: widget.venta),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final venta = widget.venta;
    final fechaLocal = venta.fecha.toLocal();
    final double tasaVentaValida =
        (venta.tasaBcv.isNaN || venta.tasaBcv <= 0) ? 0.0 : venta.tasaBcv;
    final double totalBsVentaValido =
        (venta.totalBolivares.isNaN || venta.totalBolivares <= 0)
            ? (venta.total * tasaVentaValida)
            : venta.totalBolivares;

    // Mapeo de colores e iconos por método de pago
    final Map<String, Color> coloresMetodo = {
      'Efectivo': const Color(0xFF10B981),
      'Tarjeta': const Color(0xFF3B82F6),
      'Pago Móvil': const Color(0xFF8B5CF6),
      'Divisas': const Color(0xFFF59E0B),
    };
    final Map<String, IconData> iconosMetodo = {
      'Efectivo': Icons.money_rounded,
      'Tarjeta': Icons.credit_card_rounded,
      'Pago Móvil': Icons.phone_android_rounded,
      'Divisas': Icons.currency_exchange_rounded,
    };
    final Color colorMetodo = coloresMetodo[venta.metodoPago] ?? Colors.grey;
    final IconData iconMetodo = iconosMetodo[venta.metodoPago] ?? Icons.more_horiz_rounded;

    // Tamaños adaptativos según dispositivo
    final double fontSizeId = widget.isTablet ? 22 : 15;
    final double fontSizeFecha = widget.isTablet ? 16 : 11;
    final double fontSizeTotalUSD = widget.isTablet ? 26 : 16;
    final double fontSizeTotalBs = widget.isTablet ? 16 : 11;
    final double iconSize = widget.isTablet ? 34 : 22;
    final double iconContainerSize = widget.isTablet ? 64 : 40;
    final double paddingHorizontal = widget.isTablet ? 32 : 16;
    final double paddingVertical = widget.isTablet ? 24 : 14;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _showDetailDialog(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isHovering
              ? Matrix4.diagonal3Values(1.02, 1.02, 1.0)
              : Matrix4.identity(),
          padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal,
            vertical: paddingVertical,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHovering
                  ? colorScheme.primary.withValues(alpha: 0.4)
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: isHovering ? 1.8 : 1.0,
            ),
            boxShadow: isHovering
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.2),
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
              // Icono de método de pago
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: colorMetodo.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconMetodo,
                  color: colorMetodo,
                  size: iconSize,
                ),
              ),
              const SizedBox(width: 16),

              // Información principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Venta #${venta.ventaIdString}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: fontSizeId,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge de tasa
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            'Bs. ${tasaVentaValida.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: widget.isTablet ? 13 : 9,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year} - ${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: fontSizeFecha,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Totales
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '\$${venta.total.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: fontSizeTotalUSD,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bs. ${totalBsVentaValido.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: fontSizeTotalBs,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 8),

              // Icono de navegación (más grande en tablet)
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
                size: widget.isTablet ? 36 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}