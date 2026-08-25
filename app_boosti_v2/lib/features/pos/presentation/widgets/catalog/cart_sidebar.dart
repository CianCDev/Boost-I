import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/bcv_provider.dart';

class CartSidebar extends ConsumerWidget {
  final VoidCallback onCobrar;
  final VoidCallback onLimpiar;

  const CartSidebar({
    super.key,
    required this.onCobrar,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final bcvTasa = ref.watch(bcvProvider).tasa;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('🛒 Orden Activa',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface)),
                  if (cartState.items.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cartState.items.length} ítems',
                        style: TextStyle(color: colorScheme.onPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
              if (cartState.items.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.refresh_outlined, color: colorScheme.error, size: 24),
                  onPressed: onLimpiar,
                  tooltip: 'Reiniciar Venta',
                ),
            ],
          ),
        ),
        Expanded(
          child: cartState.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 48, color: colorScheme.outline),
                      SizedBox(height: 8),
                      Text('Carrito vacío', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartState.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = cartState.items[index];
                    final subtotal = item.producto.precioUnidad * item.cantidad;
                    final String key = '${item.producto.id}_$index';

                    return ClipRect(
                      child: Dismissible(
                        key: Key(key),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: colorScheme.onError,
                            size: 24,
                          ),
                        ),
                        onDismissed: (direction) {
                          ref.read(cartProvider.notifier).eliminarItem(index);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: colorScheme.error,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.producto.nombre,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.cantidad.toStringAsFixed(item.producto.esPesado ? 3 : 0)} x \$${item.producto.precioUnidad.toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '\$${subtotal.toStringAsFixed(2)}',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: colorScheme.primary),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: colorScheme.error,
                                  size: 20,
                                ),
                                onPressed: () => ref.read(cartProvider.notifier).eliminarItem(index),
                                splashRadius: 18,
                                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL USD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurfaceVariant)),
                  Text(
                    '\$${cartState.total.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('TOTAL BOLÍVARES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: colorScheme.onSurfaceVariant)),
                  Text(
                    'Bs. ${(cartState.total * (bcvTasa > 0 ? bcvTasa : 1)).toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cartState.items.isEmpty ? colorScheme.surfaceContainerHighest : colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: cartState.items.isEmpty ? null : onCobrar,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments_outlined, size: 24, color: colorScheme.onPrimary),
                      const SizedBox(width: 12),
                      Text('COBRAR ORDEN (F12)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}