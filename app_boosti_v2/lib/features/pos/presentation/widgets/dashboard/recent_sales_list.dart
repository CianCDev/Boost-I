import 'package:flutter/material.dart';
import '../../../data/Local/entities/venta_entity.dart';

class RecentSalesList extends StatelessWidget {
  final List<VentaEntity> ventas;

  const RecentSalesList({super.key, required this.ventas});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final mostrar = ventas.take(isMobile ? 3 : 5).toList();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
      opacity: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_rounded, size: 20, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Últimas ventas',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ventas.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay ventas recientes',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ] else ...[
              for (int i = 0; i < mostrar.length; i++) ...[
                _buildItem(mostrar[i], i, isMobile),
                if (i < mostrar.length - 1) const SizedBox(height: 8),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(VentaEntity venta, int index, bool isMobile) {
    final color = _getMetodoPagoColor(venta.metodoPago);
    final icon = _getMetodoPagoIcon(venta.metodoPago);
    final hora = '${venta.fecha.hour.toString().padLeft(2, '0')}:${venta.fecha.minute.toString().padLeft(2, '0')}';

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
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 4),
                  Text(
                    '#${venta.ventaIdString}',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
              Text(
                '${venta.empleado} • $hora',
                style: TextStyle(
                  fontSize: isMobile ? 9 : 11,
                  color: Colors.grey.shade500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
          const Spacer(),
          Text(
            '\$${venta.total.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
        ],
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