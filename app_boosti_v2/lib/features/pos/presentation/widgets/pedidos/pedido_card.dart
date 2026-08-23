import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/estado_chip.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

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

  @override
  Widget build(BuildContext context) {
    final color = _getColor(pedido.estado);
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200), // ✅ AGREGADO
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Indicador de estado (barra lateral)
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              // Contenido principal
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pedido.proveedorNombre,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        EstadoChip(estado: pedido.estado),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.business_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          pedido.proveedorEmpresa ?? 'Sin empresa',
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                        ),
                        const Spacer(),
                        Icon(Icons.calendar_today_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd/MM/yyyy').format(pedido.fechaPedido),
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.shopping_bag_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        // ✅ CONSULTA ASÍNCRONA PARA EL CONTADOR DE PRODUCTOS
                        Expanded(
                          child: FutureBuilder<int>(
                            future: _getCantidadProductos(),
                            initialData: 0,
                            builder: (context, snapshot) {
                              final cantidad = snapshot.data ?? 0;
                              return Text(
                                '$cantidad productos',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Bs ${pedido.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
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
    );
  }
}