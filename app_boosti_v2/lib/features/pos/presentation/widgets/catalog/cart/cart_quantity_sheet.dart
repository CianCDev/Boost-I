// lib/features/pos/presentation/widgets/catalog/cart/cart_quantity_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/models/cart_item.dart';
import '../../../controllers/cart_controller.dart';
import '../../../providers/productos_provider.dart';
import '../../../providers/themes/app_colors.dart';
import 'cart_dialogs.dart';
import 'quantity_stepper.dart';

/// Bottom sheet para editar la cantidad de UN item del carrito.
///
/// ## Uso
/// ```dart
/// await CartQuantitySheet.mostrar(context, ref, item);
/// ```
///
/// ## No toca el stock
/// El carrito NO descuenta stock (rediseño Fase 1). El stock baja recién
/// al confirmar el cobro, en `VentaService.procesarVenta`. Acá solo se
/// lee `productosProvider` para mostrar el disponible y para clampear el
/// `+`.
class CartQuantitySheet extends ConsumerStatefulWidget {
  final CartItem item;

  const CartQuantitySheet({super.key, required this.item});

  /// Abre el sheet para el [item]. Cierra al terminar.
  ///
  /// [isScrollControlled] + el `Padding` de `viewInsets` son obligatorios:
  /// sin ellos el teclado tapa la fila de "Listo" en móvil (riesgo R7 del
  /// diseño).
  static Future<void> mostrar(
    BuildContext context,
    WidgetRef ref,
    CartItem item,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CartQuantitySheet(item: item),
      ),
    );
  }

  @override
  ConsumerState<CartQuantitySheet> createState() => _CartQuantitySheetState();
}

class _CartQuantitySheetState extends ConsumerState<CartQuantitySheet> {
  /// Localiza el item por **id de producto (String)**.
  ///
  /// `CartNotifier.buscarItemIndex` acepta un `int` y hace la conversión
  /// a String internamente, así que no se puede usar directamente con el
  /// id de `ProductItem`, que ya es String. La comparación va por
  /// `indexWhere` para no castear un id no numérico a 0.
  int _indiceDe(List<CartItem> items) {
    final id = widget.item.producto.id;
    return items.indexWhere((i) => i.producto.id == id);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // `watch`: si la cantidad cambia en el controller, el sheet se
    // reconstruye con el valor nuevo sin necesidad de setState.
    final cartState = ref.watch(cartProvider);
    final items = cartState.items;
    final indice = _indiceDe(items);

    // Si el item se borró desde afuera, el sheet ya no tiene sentido.
    if (indice < 0) {
      return const SizedBox.shrink();
    }
    final item = items[indice];

    // Disponible real. `productos.stock` es un cache derivado de los
    // lotes (fuente única de verdad), no un campo editable.
    final productos = ref.watch(productosProvider).items;
    double? stockDisponible;
    for (final p in productos) {
      if (p.id.toString() == item.producto.id) {
        stockDisponible = p.stock;
        break;
      }
    }

    final esPesado = item.producto.esPesado;
    final paso = esPesado ? 0.1 : 1.0;
    final subtotal = item.producto.precioUnidad * item.cantidad;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _header(context, cs, item),
              const SizedBox(height: 20),
              const Divider(height: 1),
              const SizedBox(height: 24),
              QuantityStepper(
                cantidad: item.cantidad,
                esPesado: esPesado,
                maximo: stockDisponible,
                onIncrement: () => _sumar(indice, paso, stockDisponible),
                onDecrement: () => _restar(indice, paso, stockDisponible),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 16),
              _infoRow(
                'Disponible',
                stockDisponible == null
                    ? '—'
                    : '${stockDisponible.toStringAsFixed(esPesado ? 1 : 0)}'
                        ' und',
                cs,
              ),
              const SizedBox(height: 8),
              _infoRow(
                'Subtotal',
                '\$${subtotal.toStringAsFixed(2)}',
                cs,
                emphasize: true,
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () => _eliminar(context, item),
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                label: const Text('Eliminar del carrito'),
                style: TextButton.styleFrom(
                  foregroundColor: redError,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cs.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Listo',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ColorScheme cs, CartItem item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.producto.nombre,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                '\$${item.producto.precioUnidad.toStringAsFixed(2)} / unidad',
                style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          color: cs.onSurfaceVariant,
          tooltip: 'Cerrar',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _infoRow(
    String label,
    String value,
    ColorScheme cs, {
    bool emphasize = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
        Text(
          value,
          style: TextStyle(
            fontSize: emphasize ? 16 : 13,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
            color: emphasize ? primaryGreen : cs.onSurface,
          ),
        ),
      ],
    );
  }

  /// `+` un paso. Delega en `CartNotifier.sumarCantidad`.
  void _sumar(int indice, double paso, double? maximo) {
    ref
        .read(cartProvider.notifier)
        .sumarCantidad(indice, paso, stockMaximo: maximo);
  }

  /// `−` un paso.
  ///
  /// Usa el delta negativo de `sumarCantidad`, que desde la corrección de
  /// `cart_controller.dart` acepta valores `< 0`. Si la cantidad llega a
  /// `<= 0`, `actualizarCantidad` elimina el item por su cuenta.
  void _restar(int indice, double paso, double? maximo) {
    ref
        .read(cartProvider.notifier)
        .sumarCantidad(indice, -paso, stockMaximo: maximo);
  }

  Future<void> _eliminar(BuildContext context, CartItem item) async {
    final confirmado = await confirmarEliminarProducto(
      context,
      item.producto.nombre,
    );
    if (confirmado != true) return;
    if (!context.mounted) return;
    ref.read(cartProvider.notifier).eliminarItemPorId(item.producto.id);
    Navigator.of(context).pop();
  }
}