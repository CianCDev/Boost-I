import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class DetallesList extends StatelessWidget {
  final List<DetallePedidoEntity> detalles;

  const DetallesList({super.key, required this.detalles});

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardDecoration = BoxDecoration(
      color: isDark
          ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.75),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        width: 1.5,
      ),
    );

    if (detalles.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration,
        child: Center(
          child: Text(
            'No hay productos',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final total = detalles.fold(0.0, (sum, d) => sum + d.subtotal);

    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Productos',
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          ...detalles.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _colorPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.shopping_cart_rounded,
                        color: _colorPrimary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d.nombreProducto,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 13 : 14,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          '${d.cantidad} x \$${d.precioUnidad.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${d.subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 13 : 14,
                      color: _colorPrimary,
                    ),
                  ),
                ],
              ),
            );
          }),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: _colorSuccess,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}