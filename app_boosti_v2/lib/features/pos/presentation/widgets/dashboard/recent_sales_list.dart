import 'package:flutter/material.dart';
import '../../../data/Local/entities/venta_entity.dart';

/// Lista compacta de las últimas ventas.
class RecentSalesList extends StatelessWidget {
  final List<VentaEntity> ventas;
  final VoidCallback? onVerTodas;

  const RecentSalesList({
    super.key,
    required this.ventas,
    this.onVerTodas,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mostrar = ventas.take(isMobile ? 3 : 5).toList();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
      opacity: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 20, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Últimas ventas',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                ),
                if (onVerTodas != null)
                  TextButton(
                    onPressed: onVerTodas,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Ver todas',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Lista
            if (ventas.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay ventas recientes',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ] else ...[
              for (int i = 0; i < mostrar.length; i++) ...[
                _buildItem(mostrar[i], i, isMobile, isDark),
                if (i < mostrar.length - 1) const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(VentaEntity venta, int index, bool isMobile, bool isDark) {
    final colorMetodo = _getMetodoPagoColor(venta.metodoPago);
    final iconMetodo = _getMetodoPagoIcon(venta.metodoPago);
    final hora =
        '${venta.fecha.hour.toString().padLeft(2, '0')}:${venta.fecha.minute.toString().padLeft(2, '0')}';

    int cantidadArticulos = 0;
    if (venta.items.isNotEmpty) {
      cantidadArticulos = venta.items.fold<int>(
          0, (sum, item) => sum + (item.cantidad.toInt()));
    }

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: colorMetodo,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(iconMetodo, size: 14, color: colorMetodo),
                    const SizedBox(width: 4),
                    Text(
                      '#${venta.ventaIdString}',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      venta.empleado,
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• $hora',
                      style: TextStyle(
                        fontSize: isMobile ? 10 : 12,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                      ),
                    ),
                    if (cantidadArticulos > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$cantidadArticulos items',
                          style: TextStyle(
                            fontSize: isMobile ? 9 : 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              '\$${venta.total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.cyan.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getMetodoPagoColor(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'efectivo':
        return Colors.green.shade500;
      case 'pago móvil':
      case 'transferencia':
        return Colors.blue.shade500;
      case 'punto':
        return Colors.orange.shade500;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getMetodoPagoIcon(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'efectivo':
        return Icons.money_rounded;
      case 'pago móvil':
        return Icons.phone_android_rounded;
      case 'transferencia':
        return Icons.account_balance_rounded;
      case 'punto':
        return Icons.credit_card_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }
}