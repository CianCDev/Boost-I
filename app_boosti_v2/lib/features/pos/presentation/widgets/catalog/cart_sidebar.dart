// lib/features/pos/presentation/widgets/catalog/cart_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/cart_controller.dart';
import '../../providers/bcv_provider.dart';
import '../../providers/themes/app_colors.dart';
import '../../utils/responsive_helper.dart';

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
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = isDark ? darkBlue : cardLight;
    final textColor = isDark ? Colors.white : textDark;
    final textSecondaryColor = isDark ? Colors.white70 : textMuted;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : primaryGreen.withValues(alpha: 0.30);
    final itemBgColor = isDark ? Colors.white.withValues(alpha: 0.05) : textMuted.withValues(alpha: 0.05);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: isDark ? 1 : 1.5,
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(-4, 0),
                ),
              ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: borderColor,
                  width: isDark ? 1 : 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  color: textSecondaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Carrito',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 18 : 16,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                if (cartState.items.isNotEmpty)
                  TextButton.icon(
                    onPressed: onLimpiar,
                    icon: const Icon(Icons.delete_outline, size: 16, color: redError),
                    label: const Text(
                      'Limpiar',
                      style: TextStyle(
                        fontSize: 12,
                        color: redError,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),

          // Lista de items con Dismissible y mayor separación en el precio
          Expanded(
            child: cartState.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 48,
                          color: textSecondaryColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Carrito vacío',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondaryColor.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: cartState.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = cartState.items[index];
                      final subtotal = item.producto.precioUnidad * item.cantidad;
                      final key = '${item.producto.id}_$index';

                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: borderColor,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Dismissible(
                            key: ValueKey(key),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              color: redError,
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              HapticFeedback.lightImpact();
                              return await _confirmarEliminarProducto(
                                context,
                                item.producto.nombre,
                              );
                            },
                            onDismissed: (direction) {
                              ref.read(cartProvider.notifier).eliminarItem(index);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              color: itemBgColor,
                              child: Row(
                                children: [
                                  // Nombre y cantidad
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.producto.nombre,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: isTablet ? 15 : 13,
                                            color: textColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.cantidad.toStringAsFixed(item.producto.esPesado ? 3 : 0)} x \$${item.producto.precioUnidad.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: textSecondaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Precio Subtotal
                                  Text(
                                    '\$${subtotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 16 : 14,
                                      color: primaryGreen,
                                    ),
                                  ),
                                  // Espaciado directo entre el precio y el botón eliminar
                                  const SizedBox(width: 12),
                                  // Botón eliminar
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: redError,
                                      size: 18,
                                    ),
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();
                                      final confirmado = await _confirmarEliminarProducto(
                                        context,
                                        item.producto.nombre,
                                      );
                                      if (confirmado == true) {
                                        ref.read(cartProvider.notifier).eliminarItem(index);
                                      }
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Totales y botón pagar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: borderColor,
                  width: isDark ? 1 : 1,
                ),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total USD',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: textSecondaryColor,
                      ),
                    ),
                    Text(
                      '\$${cartState.total.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 18 : 16,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Bs.',
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 12,
                        color: textSecondaryColor,
                      ),
                    ),
                    Text(
                      'Bs. ${(cartState.total * (bcvTasa > 0 ? bcvTasa : 1)).toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 16 : 14,
                        color: primaryGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: isTablet ? 48 : 40,
                  child: ElevatedButton(
                    onPressed: cartState.items.isEmpty ? null : onCobrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.payments_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'COBRAR ORDEN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 16 : 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- DIÁLOGO: CONFIRMAR ELIMINAR PRODUCTO ----------
  Future<bool?> _confirmarEliminarProducto(BuildContext context, String nombre) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar producto'),
          content: Text('¿Seguro que deseas eliminar "$nombre" del carrito?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
              ),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: redError,
              ),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }
}