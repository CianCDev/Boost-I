import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/bcv_provider.dart';
import '../../utils/responsive_helper.dart';

class FixedCartSummary extends ConsumerWidget {
  final VoidCallback onCobrar;

  const FixedCartSummary({super.key, required this.onCobrar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final bcvTasa = ref.watch(bcvProvider).tasa;
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: isTablet ? 140.0 : 120.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total: \$${cartState.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 28 : 17,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bs. ${(cartState.total * (bcvTasa > 0 ? bcvTasa : 1)).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (cartState.items.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.error,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${cartState.items.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.error,
                  ),
                ),
              ),
            SizedBox(
              height: isTablet ? 66 : 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 12, vertical: 12),
                  elevation: 0,
                ),
                onPressed: cartState.items.isEmpty ? null : () => _openCartBottomSheet(context, ref, onCobrar),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 18, color: colorScheme.onPrimary),
                    const SizedBox(width: 6),
                    Text(
                      'Ver Carrito',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 20 : 14,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCartBottomSheet(BuildContext context, WidgetRef ref, VoidCallback onCobrar) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Consumer(
              builder: (context, ref, child) {
                final currentCartState = ref.watch(cartProvider);
                final bcvTasa = ref.watch(bcvProvider).tasa;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mi Carrito',
                          style: TextStyle(
                            fontSize: isTablet ? 28 : 22,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Row(
                          children: [
                            if (currentCartState.items.isNotEmpty)
                              IconButton(
                                icon: Icon(Icons.refresh_outlined, color: colorScheme.error, size: 28),
                                tooltip: 'Reiniciar Venta',
                                splashRadius: 28,
                                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                                onPressed: () {
                                  ref.read(cartProvider.notifier).limpiarCarrito();
                                  Navigator.of(context).pop();
                                },
                              ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(Icons.close_rounded, size: 28, color: colorScheme.onSurfaceVariant),
                              splashRadius: 28,
                              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(thickness: 1, color: colorScheme.outlineVariant),
                    const SizedBox(height: 16),
                    Expanded(
                      child: currentCartState.items.isEmpty
                          ? Center(
                              child: Text(
                                'El carrito está vacío',
                                style: TextStyle(fontSize: 18, color: colorScheme.onSurfaceVariant),
                              ),
                            )
                          : ListView.separated(
                              itemCount: currentCartState.items.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = currentCartState.items[index];
                                final subtotal = item.producto.precioUnidad * item.cantidad;
                                final String key = '${item.producto.id}_$index';

                                // Envolver en ClipRect para evitar que se salga del contenedor
                                return ClipRect(
                                  child: Dismissible(
                                    key: Key(key),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20),
                                      decoration: BoxDecoration(
                                        color: colorScheme.error,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Icon(
                                        Icons.delete_outline,
                                        color: colorScheme.onError,
                                        size: isTablet ? 32 : 24,
                                      ),
                                    ),
                                    onDismissed: (direction) {
                                      ref.read(cartProvider.notifier).eliminarItem(index);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(isTablet ? 20 : 16),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(16),
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
                                                Text(
                                                  item.producto.nombre,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: isTablet ? 20 : 16,
                                                    color: colorScheme.onSurface,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  '${item.cantidad.toStringAsFixed(item.producto.esPesado ? 3 : 0)} x \$${item.producto.precioUnidad.toStringAsFixed(2)}',
                                                  style: TextStyle(
                                                    color: colorScheme.onSurfaceVariant,
                                                    fontSize: isTablet ? 16 : 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '\$${subtotal.toStringAsFixed(2)}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: isTablet ? 20 : 17,
                                              color: colorScheme.primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close_rounded,
                                              color: colorScheme.error,
                                              size: isTablet ? 28 : 22,
                                            ),
                                            onPressed: () {
                                              ref.read(cartProvider.notifier).eliminarItem(index);
                                            },
                                            splashRadius: isTablet ? 28 : 20,
                                            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Divider(thickness: 1, color: colorScheme.outlineVariant),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL USD',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 20 : 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '\$${currentCartState.total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 30 : 20,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'TOTAL BOLÍVARES',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 18 : 12,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'Bs. ${(currentCartState.total * (bcvTasa > 0 ? bcvTasa : 1)).toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 22 : 14,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 76 : 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            onPressed: currentCartState.items.isEmpty
                                ? null
                                : () {
                                    Navigator.of(context).pop();
                                    onCobrar();
                                  },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.payments_outlined, size: isTablet ? 32 : 24),
                                const SizedBox(width: 16),
                                Text(
                                  'COBRAR ORDEN',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet ? 24 : 18,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}