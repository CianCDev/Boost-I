import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../../domain/models/product_item.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/top_products_provider.dart';

class TopProductsWidget extends ConsumerWidget {
  final VoidCallback onClose;

  const TopProductsWidget({super.key, required this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productos = ref.watch(topProductosProvider);
    final theme = Theme.of(context);
    final panelWidth =
        (MediaQuery.sizeOf(context).width - 32).clamp(0.0, 420.0).toDouble();

    return Material(
      color: Colors.black45,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Container(
            width: panelWidth,
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6)),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.trending_up_rounded, color: theme.colorScheme.primary),
                  title: const Text('Productos destacados'),
                  subtitle: const Text('Más vendidos acumulados'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Cerrar',
                    onPressed: onClose,
                  ),
                ),
                const Divider(height: 1),
                if (productos.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No hay productos destacados aún'),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(12),
                      itemCount: productos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final producto = productos[index];
                        return _TopProductCard(
                          producto: producto,
                          rank: index + 1,
                          onAdd: () => _agregarAlCarrito(context, ref, producto),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _agregarAlCarrito(
    BuildContext context,
    WidgetRef ref,
    ProductoEntity producto,
  ) {
    if (producto.stock <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este producto no tiene stock disponible')),
      );
      return;
    }

    final item = ProductItem(
      id: producto.id.toString(),
      codigoBarras: producto.codigoBarras,
      nombre: producto.nombre,
      precioUnidad: producto.precioUnidad,
      esPesado: producto.esPesado,
      categoria: producto.categoria,
    );
    ref.read(cartProvider.notifier).agregarProducto(
          item,
          stockMaximo: producto.stock,
        );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} agregado al carrito'),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }
}

class _TopProductCard extends StatelessWidget {
  final ProductoEntity producto;
  final int rank;
  final VoidCallback onAdd;

  const _TopProductCard({
    required this.producto,
    required this.rank,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          child: Text('$rank'),
        ),
        title: Text(producto.nombre, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${producto.ventasAcumuladas.toStringAsFixed(0)} uds vendidas',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.add_shopping_cart),
          color: theme.colorScheme.primary,
          tooltip: 'Agregar al carrito',
          onPressed: onAdd,
        ),
      ),
    );
  }
}
