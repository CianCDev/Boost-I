import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';

class DetalleProductoCard extends StatelessWidget {
  final DetallePedidoEntity detalle;
  final VoidCallback onEliminar;

  const DetalleProductoCard({
    super.key,
    required this.detalle,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.shopping_cart_rounded, color: const Color(0xFF8B5CF6), size: 20),
        ),
        title: Text(
          detalle.nombreProducto,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${detalle.cantidad} x Bs ${detalle.precioUnidad.toStringAsFixed(2)}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bs ${detalle.subtotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline_rounded, color: Colors.red),
              onPressed: onEliminar,
              tooltip: 'Eliminar producto',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}