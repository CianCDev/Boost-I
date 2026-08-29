// lib/features/pos/presentation/controllers/cart_controller.dart
// ignore: unused_import
// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/product_item.dart';

class CartState {
  final List<CartItem> items;
  final double porcentajeImpuesto;
  final bool preciosIncluyenImpuesto;

  const CartState({
    this.items = const [],
    this.porcentajeImpuesto = 0.16,
    this.preciosIncluyenImpuesto = true,
  });

  double get totalBrutoItems {
    final suma = items.fold(0.0, (sum, item) => sum + item.subtotal);
    return _redondearDosDecimales(suma);
  }

  double get total {
    if (preciosIncluyenImpuesto) {
      return totalBrutoItems;
    } else {
      return _redondearDosDecimales(totalBrutoItems + impuesto);
    }
  }

  double get subtotal {
    if (preciosIncluyenImpuesto) {
      if (porcentajeImpuesto <= 0) return totalBrutoItems;
      return _redondearDosDecimales(totalBrutoItems / (1.0 + porcentajeImpuesto));
    } else {
      return totalBrutoItems;
    }
  }

  double get impuesto {
    if (preciosIncluyenImpuesto) {
      return _redondearDosDecimales(total - subtotal);
    } else {
      return _redondearDosDecimales(subtotal * porcentajeImpuesto);
    }
  }

  int get cantidadItems => items.length;

  static double _redondearDosDecimales(double valor) {
    return double.parse(valor.toStringAsFixed(2));
  }

  CartState copyWith({
    List<CartItem>? items,
    double? porcentajeImpuesto,
    bool? preciosIncluyenImpuesto,
  }) {
    return CartState(
      items: items ?? this.items,
      porcentajeImpuesto: porcentajeImpuesto ?? this.porcentajeImpuesto,
      preciosIncluyenImpuesto: preciosIncluyenImpuesto ?? this.preciosIncluyenImpuesto,
    );
  }
}

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  void setAplicaIva(bool aplica) {
    state = state.copyWith(
      porcentajeImpuesto: aplica ? 0.16 : 0.0,
    );
  }

  void agregarProducto(
    ProductItem producto, {
    double cantidad = 1.0,
    double? stockMaximo,
  }) {
    if (cantidad <= 0) return;

    final indexExistente = state.items.indexWhere((item) => item.producto.id == producto.id);

    if (indexExistente != -1) {
      final itemsActualizados = List<CartItem>.from(state.items);
      final itemExistente = itemsActualizados[indexExistente];
      double nuevaCantidad = itemExistente.cantidad + cantidad;

      if (stockMaximo != null && nuevaCantidad > stockMaximo) {
        nuevaCantidad = stockMaximo;
      }

      nuevaCantidad = _redondearCantidad(nuevaCantidad, producto.esPesado);

      itemsActualizados[indexExistente] = itemExistente.copyWith(
        cantidad: nuevaCantidad,
      );

      state = state.copyWith(items: itemsActualizados);
    } else {
      double cantidadInicial = cantidad;
      if (stockMaximo != null && cantidadInicial > stockMaximo) {
        cantidadInicial = stockMaximo;
      }

      cantidadInicial = _redondearCantidad(cantidadInicial, producto.esPesado);

      final nuevoItem = CartItem(
        producto: producto,
        cantidad: cantidadInicial,
      );
      state = state.copyWith(items: [...state.items, nuevoItem]);
    }
  }

  void agregarItem(ProductItem producto, double cantidad, {double? stockMaximo}) {
    agregarProducto(producto, cantidad: cantidad, stockMaximo: stockMaximo);
  }

  int buscarItemIndex(int productoId) {
    return state.items.indexWhere((item) => item.producto.id == productoId);
  }

  void sumarCantidad(int index, double cantidad, {double? stockMaximo}) {
    if (index < 0 || index >= state.items.length) return;
    if (cantidad <= 0) return;

    final itemActual = state.items[index];
    final double nuevaCantidad = itemActual.cantidad + cantidad;
    actualizarCantidad(index, nuevaCantidad, stockMaximo: stockMaximo);
  }

  void actualizarCantidad(int index, double nuevaCantidad, {double? stockMaximo}) {
    if (index < 0 || index >= state.items.length) return;

    if (nuevaCantidad <= 0) {
      eliminarItem(index);
      return;
    }

    final itemActual = state.items[index];
    double cantidadAjustada = nuevaCantidad;

    if (stockMaximo != null && cantidadAjustada > stockMaximo) {
      cantidadAjustada = stockMaximo;
    }

    cantidadAjustada = _redondearCantidad(cantidadAjustada, itemActual.producto.esPesado);

    final itemsActualizados = List<CartItem>.from(state.items);
    itemsActualizados[index] = itemActual.copyWith(cantidad: cantidadAjustada);

    state = state.copyWith(items: itemsActualizados);
  }

  void eliminarItem(int index) {
    if (index < 0 || index >= state.items.length) {
      return;
    }

    final itemsActualizados = List<CartItem>.from(state.items)..removeAt(index);
    state = state.copyWith(items: itemsActualizados);
  }

  /// ✅ Elimina un ítem del carrito comparando el ID como String (sin conversión a int)
  void eliminarItemPorId(dynamic productoId) {
    final idStr = productoId.toString();
    state = state.copyWith(
      items: state.items.where((item) => item.producto.id.toString() != idStr).toList(),
    );
  }

  void limpiarCarrito() {
    state = state.copyWith(
      items: [],
      porcentajeImpuesto: 0.16,
    );
  }

  double _redondearCantidad(double valor, bool esPesado) {
    if (esPesado) {
      return double.parse(valor.toStringAsFixed(3));
    }
    return valor.roundToDouble();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});