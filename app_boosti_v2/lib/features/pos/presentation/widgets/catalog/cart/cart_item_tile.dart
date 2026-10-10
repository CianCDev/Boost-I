// lib/features/pos/presentation/widgets/catalog/cart/cart_item_tile.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../domain/models/cart_item.dart';
import '../../../providers/themes/app_colors.dart';
import 'cart_dialogs.dart';

/// Tile compartida de un item del carrito.
///
/// ## Presentación
/// - Nombre, precio unitario y cantidad en una línea.
/// - Chip "Dscto." y precio original tachado si aplica descuento.
/// - Swipe endToStart para eliminar (con confirmación).
/// - Botón ✕ para eliminar (con confirmación).
/// - Tap en la fila → `onTap` (abre el bottom sheet de cantidad).
///
/// ## Motivo de extracción
/// El markup del item estaba duplicado en `cart_sidebar.dart` y
/// `cart_bottom_sheet.dart`, con la misma lógica de borrado pero
/// distinta: `eliminarItem(index)` en uno y `eliminarItemPorId(...)` en
/// el otro. Un solo widget evita esa divergencia.
///
/// ## ⚠️ Por qué `onDelete` recibe el item, no un índice
/// El índice se corre en cada mutación de la lista. Si el caller
/// borrara por índice, un swipe concurrente con otro borrado dejaría
/// el item equivocado. `onDelete` se enlaza al item concreto y el
/// caller decide cómo resolverlo (preferentemente por id de producto).
class CartItemTile extends StatelessWidget {
  final CartItem item;
  final bool isTablet;
  final Color textColor;
  final Color textSecondaryColor;
  final Color borderColor;
  final Color itemBgColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CartItemTile({
    super.key,
    required this.item,
    required this.isTablet,
    required this.textColor,
    required this.textSecondaryColor,
    required this.borderColor,
    required this.itemBgColor,
    required this.onTap,
    required this.onDelete,
  });

  static const Color _amber = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final subtotal = item.producto.precioUnidad * item.cantidad;
    final tieneDescuento = item.esDescuentoEspecial;

    return Dismissible(
      key: ValueKey<String>('cart_item_${item.producto.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: redError,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 26,
        ),
      ),
      confirmDismiss: (_) async {
        HapticFeedback.lightImpact();
        return await confirmarEliminarProducto(
          context,
          item.producto.nombre,
        );
      },
      onDismissed: (_) => onDelete(),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              color: itemBgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.producto.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isTablet ? 15 : 13.5,
                                  color: textColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tieneDescuento) ...[
                              const SizedBox(width: 6),
                              const _ChipDescuento(),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            if (tieneDescuento) ...[
                              Text(
                                '\$${item.precioOriginal.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      textSecondaryColor.withValues(alpha: 0.5),
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              _lineaCantidad(item),
                              style: TextStyle(
                                fontSize: 12,
                                color: tieneDescuento
                                    ? _amber
                                    : textSecondaryColor,
                                fontWeight: tieneDescuento
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 16 : 14,
                      color: tieneDescuento ? _amber : primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: redError,
                      size: isTablet ? 22 : 18,
                    ),
                    splashRadius: 20,
                    tooltip: 'Eliminar producto',
                    onPressed: () async {
                      HapticFeedback.lightImpact();
                      final ok = await confirmarEliminarProducto(
                        context,
                        item.producto.nombre,
                      );
                      if (ok == true) onDelete();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// `cantidad` es `double`: 3 decimales para pesados, 0 para unitarios.
  String _lineaCantidad(CartItem i) {
    final q = i.producto.esPesado
        ? i.cantidad.toStringAsFixed(3)
        : i.cantidad.toStringAsFixed(0);
    return '$q x \$${i.producto.precioUnidad.toStringAsFixed(2)}';
  }
}

class _ChipDescuento extends StatelessWidget {
  const _ChipDescuento();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: CartItemTile._amber.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'Dscto.',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: CartItemTile._amber,
        ),
      ),
    );
  }
}