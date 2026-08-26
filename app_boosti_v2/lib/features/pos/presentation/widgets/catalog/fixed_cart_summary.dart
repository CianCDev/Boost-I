import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/bcv_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../providers/themes/app_colors.dart';

class FixedCartSummary extends ConsumerWidget {
  final VoidCallback onCobrar;

  const FixedCartSummary({super.key, required this.onCobrar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final bcvTasa = ref.watch(bcvProvider).tasa;
    final isTablet = ResponsiveHelper.isTablet(context);
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: isTablet ? 120.0 : 100.0,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? deepSpaceBlue : deepSpaceBlue,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : deepSpaceBlue.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Totales
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        'Total: ',
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        '\$${cartState.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 22 : 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Bs. ${(cartState.total * (bcvTasa > 0 ? bcvTasa : 1)).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 13,
                      color: mintLeaf,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Contador de items
            if (cartState.items.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pumpkinSpice,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${cartState.items.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 14,
                    color: Colors.white,
                  ),
                ),
              ),
            // Botón "Ver Carrito"
            SizedBox(
              height: isTablet ? 56 : 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mintLeaf,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24 : 16,
                    vertical: 12,
                  ),
                  elevation: 0,
                ),
                onPressed: cartState.items.isEmpty
                    ? null
                    : () => _openCartBottomSheet(context, ref, onCobrar),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: isTablet ? 20 : 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isTablet ? 'Ver Carrito' : 'Carrito',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 18 : 14,
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
                    // Header
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
                                icon: Icon(
                                  Icons.refresh_outlined,
                                  color: redError,
                                  size: isTablet ? 28 : 24,
                                ),
                                tooltip: 'Limpiar carrito',
                                onPressed: () {
                                  ref.read(cartProvider.notifier).limpiarCarrito();
                                  Navigator.of(context).pop();
                                },
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.close_rounded,
                                size: isTablet ? 28 : 24,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(thickness: 1, color: colorScheme.outlineVariant),
                    const SizedBox(height: 16),
                    // Lista de items
                    Expanded(
                      child: currentCartState.items.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    size: 60,
                                    color: colorScheme.outline,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'El carrito está vacío',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              itemCount: currentCartState.items.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = currentCartState.items[index];
                                final subtotal = item.producto.precioUnidad * item.cantidad;
                                final String key = '${item.producto.id}_$index';

                                return Dismissible(
                                  key: Key(key),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: redError,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: isTablet ? 32 : 24,
                                    ),
                                  ),
                                  onDismissed: (direction) {
                                    ref.read(cartProvider.notifier).eliminarItem(index);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(isTablet ? 20 : 16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: colorScheme.outlineVariant,
                                        width: 1,
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
                                              const SizedBox(height: 4),
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
                                            color: mintLeaf,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: Icon(
                                            Icons.close_rounded,
                                            color: redError,
                                            size: isTablet ? 28 : 22,
                                          ),
                                          onPressed: () {
                                            ref.read(cartProvider.notifier).eliminarItem(index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    Divider(thickness: 1, color: colorScheme.outlineVariant),
                    const SizedBox(height: 12),
                    // Totales y botón pagar
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
                                color: mintLeaf,
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
                                color: mintLeaf,
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
                              backgroundColor: mintLeaf,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
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