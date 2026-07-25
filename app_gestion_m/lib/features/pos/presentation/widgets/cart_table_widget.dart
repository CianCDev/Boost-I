import 'package:flutter/material.dart';
import '../../domain/models/cart_item.dart';

class CartTableWidget extends StatelessWidget {
  final List<CartItem> items;
  final Function(int index, double nuevaCantidad) onCantidadChanged;
  final Function(int index) onEliminarItem;

  const CartTableWidget({
    super.key,
    required this.items,
    required this.onCantidadChanged,
    required this.onEliminarItem,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 12),
            Text(
              'No hay productos en el carrito',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          final esPesado = item.producto.esPesado;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              item.producto.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${item.producto.codigoBarras} • \$${item.producto.precioUnidad.toStringAsFixed(2)} / ${esPesado ? 'KG' : 'Unid'}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${item.cantidad.toStringAsFixed(esPesado ? 3 : 0)} ${esPesado ? 'KG' : 'u'}',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const SizedBox(width: 16),
                Text(
                  '\$${item.subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => onEliminarItem(index),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}