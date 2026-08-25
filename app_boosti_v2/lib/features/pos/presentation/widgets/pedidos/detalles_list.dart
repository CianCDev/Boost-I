import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';

class DetallesList extends StatelessWidget {
  final List<DetallePedidoEntity> detalles;

  const DetallesList({super.key, required this.detalles});

  @override
  Widget build(BuildContext context) {
    if (detalles.isEmpty) {
      return const Center(child: Text('No hay productos'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Productos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...detalles.map((d) => ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: Text(d.nombreProducto),
              subtitle: Text('${d.cantidad} x \$${d.precioUnidad.toStringAsFixed(2)}'), // ✅ USD
              trailing: Text(
                '\$${d.subtotal.toStringAsFixed(2)}', // ✅ USD
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )),
        const Divider(),
        Text(
          'Total: \$${detalles.fold(0.0, (sum, d) => sum + d.subtotal).toStringAsFixed(2)}', // ✅ USD
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}