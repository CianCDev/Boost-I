// lib/features/pos/presentation/widgets/catalog/cart_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/bcv_provider.dart';
import '../../providers/themes/app_colors.dart';
import '../../utils/responsive_helper.dart';

class CartBottomSheet extends ConsumerWidget {
  final VoidCallback onCobrar;

  const CartBottomSheet({
    super.key,
    required this.onCobrar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartState = ref.watch(cartProvider);
    final bcvTasa = ref.watch(bcvProvider).tasa;
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;
    final hasItems = cartState.items.isNotEmpty;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
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
                      if (hasItems)
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: IconButton(
                            icon: Icon(
                              Icons.refresh_outlined,
                              color: redError,
                              size: isTablet ? 28 : 24,
                            ),
                            tooltip: 'Limpiar carrito',
                            onPressed: () => _confirmarLimpiar(context, ref),
                          ),
                        ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: isTablet ? 28 : 24,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Divider(thickness: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 12),

              // Lista de items con Scrollbar
              Expanded(
                child: cartState.items.isEmpty
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
                    : Scrollbar(
                        thumbVisibility: true,
                        child: ListView.separated(
                          itemCount: cartState.items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = cartState.items[index];
                            final subtotal = item.producto.precioUnidad * item.cantidad;
                            final key = '${item.producto.id}_$index';
                            final radius = 16.0;

                            return Dismissible(
                              key: ValueKey(key),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: redError,
                                  borderRadius: BorderRadius.circular(radius),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: isTablet ? 32 : 24,
                                ),
                              ),
                              onDismissed: (direction) {
                                HapticFeedback.lightImpact();
                                // Mostrar SnackBar de feedback
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${item.producto.nombre} eliminado'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: redError,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                                ref.read(cartProvider.notifier).eliminarItem(index);
                              },
                              child: Container(
                                padding: EdgeInsets.all(isTablet ? 20 : 14),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(radius),
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
                                              fontSize: isTablet ? 20 : 15,
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
                                              fontSize: isTablet ? 16 : 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '\$${subtotal.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isTablet ? 20 : 16,
                                        color: primaryGreen,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.close_rounded,
                                          color: redError,
                                          size: isTablet ? 28 : 22,
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        constraints: const BoxConstraints(
                                          minWidth: 40,
                                          minHeight: 40,
                                        ),
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          // Mostrar feedback visual
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('${item.producto.nombre} eliminado'),
                                              duration: const Duration(seconds: 2),
                                              backgroundColor: redError,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                          ref.read(cartProvider.notifier).eliminarItem(index);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              Divider(thickness: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: 8),

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
                        '\$${cartState.total.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 30 : 20,
                          color: primaryGreen,
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
                        'Bs. ${(cartState.total * (bcvTasa > 0 ? bcvTasa : 1)).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isTablet ? 22 : 14,
                          color: primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  MouseRegion(
                    cursor: hasItems ? SystemMouseCursors.click : SystemMouseCursors.basic,
                    child: SizedBox(
                      width: double.infinity,
                      height: isTablet ? 76 : 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: hasItems
                            ? () {
                                Navigator.of(context).pop();
                                onCobrar();
                              }
                            : null,
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarLimpiar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Limpiar carrito'),
          content: const Text('¿Seguro que deseas eliminar todos los productos?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                ref.read(cartProvider.notifier).limpiarCarrito();
                Navigator.of(context).pop(); // cierra el diálogo
                Navigator.of(context).pop(); // cierra el bottom sheet
              },
              style: TextButton.styleFrom(foregroundColor: redError),
              child: const Text('Limpiar'),
            ),
          ],
        );
      },
    );
  }
}