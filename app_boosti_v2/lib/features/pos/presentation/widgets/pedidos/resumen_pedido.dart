import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalle_producto_card.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';

class ResumenPedido extends StatelessWidget {
  final List<DetallePedidoEntity> detalles;
  final Function(DetallePedidoEntity) onEliminar; // ← NUEVO

  const ResumenPedido({
    super.key, 
    required this.detalles,
    required this.onEliminar, // ← NUEVO
  });

  @override
  Widget build(BuildContext context) {
    if (detalles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Productos Agregados:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...detalles.map(
          (d) => DetalleProductoCard(
            detalle: d,
            onEliminar: () => onEliminar(d), // ← PROPAGA LA ELIMINACIÓN
          ),
        ),
        const Divider(),
        Text(
          'Total: Bs ${detalles.fold(0.0, (sum, d) => sum + d.subtotal).toStringAsFixed(2)}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}