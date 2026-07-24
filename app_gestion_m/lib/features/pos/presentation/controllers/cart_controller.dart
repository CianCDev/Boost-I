import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/product_item.dart';

// Estado que maneja la lista de items y totales
class CartState {
  final List<CartItem> items;
  final double porcentajeImpuesto; // ej. 0.16 para 16% IVA

  const CartState({
    this.items = const [],
    this.porcentajeImpuesto = 0.16,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get impuesto => subtotal * porcentajeImpuesto;
  double get total => subtotal + impuesto;
  int get cantidadItems => items.length;

  CartState copyWith({
    List<CartItem>? items,
    double? porcentajeImpuesto,
  }) {
    return CartState(
      items: items ?? this.items,
      porcentajeImpuesto: porcentajeImpuesto ?? this.porcentajeImpuesto,
    );
  }
}

// Notifier para manipular el estado del carrito
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  // Agregar un producto al carrito
  void agregarProducto(ProductItem producto, {double cantidad = 1.0}) {
    final indexExistente = state.items.indexWhere((item) => item.producto.id == producto.id);

    if (indexExistente != -1) {
      // Si ya existe, actualizamos la cantidad
      final itemsActualizados = List<CartItem>.from(state.items);
      final itemExistente = itemsActualizados[indexExistente];
      
      itemsActualizados[indexExistente] = itemExistente.copyWith(
        cantidad: itemExistente.cantidad + cantidad,
      );

      state = state.copyWith(items: itemsActualizados);
    } else {
      // Si es nuevo, lo agregamos a la lista
      final nuevoItem = CartItem(producto: producto, cantidad: cantidad);
      state = state.copyWith(items: [...state.items, nuevoItem]);
    }
  }

  // Actualizar cantidad de un item por índice
  void actualizarCantidad(int index, double nuevaCantidad) {
    if (index < 0 || index >= state.items.length) return;

    if (nuevaCantidad <= 0) {
      eliminarItem(index);
      return;
    }

    final itemsActualizados = List<CartItem>.from(state.items);
    itemsActualizados[index] = itemsActualizados[index].copyWith(cantidad: nuevaCantidad);
    state = state.copyWith(items: itemsActualizados);
  }

  // Eliminar un item por su índice
  void eliminarItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final itemsActualizados = List<CartItem>.from(state.items)..removeAt(index);
    state = state.copyWith(items: itemsActualizados);
  }

  // Limpiar toda la compra (ej. tras finalizar cobranza o cancelar)
  void limpiarCarrito() {
    state = state.copyWith(items: []);
  }
}

// Provider global accesible desde cualquier Widget
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});