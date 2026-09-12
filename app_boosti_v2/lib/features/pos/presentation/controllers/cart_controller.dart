// lib/features/pos/presentation/controllers/cart_controller.dart
// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/product_item.dart';

// ============================================================
// CONFIGURACIÓN DE IVA POR PAÍS
// ============================================================
// TODO(multi-pais): Migrar a entidad `ConfiguracionPais` cuando
// se implemente la configuración inicial post-empresa.

class ConfiguracionIva {
  final String codigoPais;
  final double porcentajeIva;
  final bool preciosIncluyenIva;

  const ConfiguracionIva({
    required this.codigoPais,
    required this.porcentajeIva,
    this.preciosIncluyenIva = true,
  });

  static const Map<String, ConfiguracionIva> porPais = {
    'VE': ConfiguracionIva(codigoPais: 'VE', porcentajeIva: 0.16),
    'CO': ConfiguracionIva(codigoPais: 'CO', porcentajeIva: 0.19),
    'CL': ConfiguracionIva(codigoPais: 'CL', porcentajeIva: 0.19),
    'AR': ConfiguracionIva(codigoPais: 'AR', porcentajeIva: 0.21),
  };

  static ConfiguracionIva porDefecto() => porPais['VE']!;
}

// ============================================================
// ESTADO DEL CARRITO
// ============================================================

class CartState {
  final List<CartItem> items;
  final ConfiguracionIva configIva;
  final bool ivaHabilitado;

  const CartState({
    this.items = const [],
    this.configIva = const ConfiguracionIva(
      codigoPais: 'VE',
      porcentajeIva: 0.16,
    ),
    this.ivaHabilitado = true,
  });

  double get totalBrutoItems {
    final suma = items.fold(0.0, (sum, item) => sum + item.subtotal);
    return _redondearDosDecimales(suma);
  }

  double get total {
    if (configIva.preciosIncluyenIva) {
      return totalBrutoItems;
    }
    return _redondearDosDecimales(totalBrutoItems + impuesto);
  }

  double get subtotal {
    if (!ivaHabilitado) return totalBrutoItems;
    if (!configIva.preciosIncluyenIva) return totalBrutoItems;
    if (configIva.porcentajeIva <= 0) return totalBrutoItems;
    return _redondearDosDecimales(
      totalBrutoItems / (1.0 + configIva.porcentajeIva),
    );
  }

  double get impuesto {
    if (!ivaHabilitado) return 0.0;
    if (configIva.preciosIncluyenIva) {
      return _redondearDosDecimales(total - subtotal);
    }
    return _redondearDosDecimales(subtotal * configIva.porcentajeIva);
  }

  double get porcentajeIvaEfectivo {
    if (!ivaHabilitado) return 0.0;
    return configIva.porcentajeIva;
  }

  int get cantidadItems => items.length;

  static double _redondearDosDecimales(double valor) {
    return double.parse(valor.toStringAsFixed(2));
  }

  CartState copyWith({
    List<CartItem>? items,
    ConfiguracionIva? configIva,
    bool? ivaHabilitado,
  }) {
    return CartState(
      items: items ?? this.items,
      configIva: configIva ?? this.configIva,
      ivaHabilitado: ivaHabilitado ?? this.ivaHabilitado,
    );
  }
}

// ============================================================
// NOTIFIER
// ============================================================

class CartNotifier extends StateNotifier<CartState> {
  CartNotifier({ConfiguracionIva? configIva})
      : super(CartState(configIva: configIva ?? ConfiguracionIva.porDefecto()));

  void setIvaHabilitado(bool habilitado) {
    state = state.copyWith(ivaHabilitado: habilitado);
  }

  void toggleIva() {
    state = state.copyWith(ivaHabilitado: !state.ivaHabilitado);
  }

  void setConfigIva(ConfiguracionIva config) {
    state = state.copyWith(configIva: config);
  }

  void agregarProducto(
    ProductItem producto, {
    double cantidad = 1.0,
    double? stockMaximo,
  }) {
    if (cantidad <= 0) return;

    final indexExistente =
        state.items.indexWhere((item) => item.producto.id == producto.id);

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
        precioOriginal: producto.precioUnidad,
        esDescuentoEspecial: false,
      );
      state = state.copyWith(items: [...state.items, nuevoItem]);
    }
  }

  void agregarItem(ProductItem producto, double cantidad,
      {double? stockMaximo}) {
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

  void actualizarCantidad(int index, double nuevaCantidad,
      {double? stockMaximo}) {
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

    cantidadAjustada =
        _redondearCantidad(cantidadAjustada, itemActual.producto.esPesado);

    final itemsActualizados = List<CartItem>.from(state.items);
    itemsActualizados[index] = itemActual.copyWith(cantidad: cantidadAjustada);

    state = state.copyWith(items: itemsActualizados);
  }

  void eliminarItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final itemsActualizados = List<CartItem>.from(state.items)..removeAt(index);
    state = state.copyWith(items: itemsActualizados);
  }

  void eliminarItemPorId(dynamic productoId) {
    final idStr = productoId.toString();
    state = state.copyWith(
      items: state.items
          .where((item) => item.producto.id.toString() != idStr)
          .toList(),
    );
  }

  void aplicarDescuentoEspecial(String productoId, double nuevoPrecio) {
    if (nuevoPrecio <= 0) return;

    final index =
        state.items.indexWhere((item) => item.producto.id == productoId);
    if (index == -1) return;

    final item = state.items[index];
    final productoModificado =
        item.producto.copyWith(precioUnidad: nuevoPrecio);

    final itemsActualizados = List<CartItem>.from(state.items);
    itemsActualizados[index] = item.copyWith(
      producto: productoModificado,
      esDescuentoEspecial: true,
    );

    state = state.copyWith(items: itemsActualizados);
  }

  void restaurarPrecioOriginal(String productoId) {
    final index =
        state.items.indexWhere((item) => item.producto.id == productoId);
    if (index == -1) return;

    final item = state.items[index];
    if (!item.esDescuentoEspecial) return;

    final productoOriginal =
        item.producto.copyWith(precioUnidad: item.precioOriginal);

    final itemsActualizados = List<CartItem>.from(state.items);
    itemsActualizados[index] = item.copyWith(
      producto: productoOriginal,
      esDescuentoEspecial: false,
    );

    state = state.copyWith(items: itemsActualizados);
  }

  void limpiarCarrito() {
    state = state.copyWith(items: []);
  }

  void resetearTodo() {
    state = CartState(configIva: state.configIva);
  }

  double _redondearCantidad(double valor, bool esPesado) {
    if (esPesado) {
      return double.parse(valor.toStringAsFixed(3));
    }
    return valor.roundToDouble();
  }
}

// ============================================================
// PROVIDER
// ============================================================

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});