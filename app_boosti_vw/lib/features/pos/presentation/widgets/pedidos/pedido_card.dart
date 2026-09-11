import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/estado_chip.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class PedidoCard extends StatelessWidget {
  final PedidoEntity pedido;
  final VoidCallback onTap;

  const PedidoCard({super.key, required this.pedido, required this.onTap});

  Future<int> _getCantidadProductos() async {
    try {
      final isar = IsarService();
      final detalles = await isar.obtenerDetallesPorPedido(pedido.id);
      return detalles.length;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _getColor(pedido.estado),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              pedido.proveedorNombre,
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          EstadoChip(estado: pedido.estado),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.business_rounded, size: isMobile ? 12 : 14, color: isDark ? Colors.white54 : Colors.black54),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pedido.proveedorEmpresa ?? 'Sin empresa',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 13,
                                color: isDark ? Colors.white54 : Colors.black54,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.calendar_today_rounded, size: isMobile ? 12 : 14, color: isDark ? Colors.white54 : Colors.black54),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(pedido.fechaPedido),
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 13,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.shopping_bag_rounded, size: isMobile ? 12 : 14, color: isDark ? Colors.white54 : Colors.black54),
                          const SizedBox(width: 4),
                          FutureBuilder<int>(
                            future: _getCantidadProductos(),
                            initialData: 0,
                            builder: (context, snapshot) {
                              final cantidad = snapshot.data ?? 0;
                              return Text(
                                '$cantidad productos',
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 13,
                                  color: isDark ? Colors.white54 : Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            },
                          ),
                          const Spacer(),
                          Text(
                            '\$${pedido.total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getColor(EstadoPedido estado) {
    switch (estado) {
      case EstadoPedido.pendiente:
        return Colors.orange.shade400;
      case EstadoPedido.recibido:
        return Colors.green.shade400;
      case EstadoPedido.cancelado:
        return Colors.red.shade400;
    }
  }
}