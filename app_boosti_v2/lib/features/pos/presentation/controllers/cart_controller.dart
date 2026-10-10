// lib/features/pos/presentation/controllers/cart_controller.dart
// ignore_for_file: unrelated_type_equality_checks

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/product_item.dart';

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

  // ═══════════════════════════════════════════════════════════════════
  // 🎯 ¿Hay algún item que no se pueda vender?
  //
  //   Un item es invendible si:
  //     1. su cantidad es <= 0, o
  //     2. el producto ya no existe en el catálogo, o
  //     3. pide MÁS cantidad que el stock disponible.
  //
  //   El caso 3 es el que faltaba antes: el getter antiguo solo miraba
  //   `cantidad <= 0`, así que un item con cantidad 5 y stock 2 pasaba
  //   el filtro y el cobro fallaba más tarde, en `procesarVenta`.
  //
  //   ⚠️ Disponible = `producto.stock`, sin restar la cantidad ya
  //   reservada en el carrito. Es correcto porque el carrito NO
  //   descuenta stock (rediseño Fase 1): el stock físico baja recién al
  //   confirmar el cobro, en `VentaService.procesarVenta`.
  //
  //   Recibe la lista de productos para no acoplar este controlador a
  //   Riverpod ni a `productosProvider`. El caller debe pasarla.
  // ═══════════════════════════════════════════════════════════════════
  bool hayItemsSinStock(List<ProductoEntity> productos) {
    for (final item in items) {
      if (item.cantidad <= 0) return true;
      final producto = productos
          .firstWhereOrNull((p) => p.id.toString() == item.producto.id);
      if (producto == null) return true;
      if (item.cantidad > producto.stock) return true;
    }
    return false;
  }

  /// Lista de items invendibles, con el mismo criterio que
  /// [hayItemsSinStock]. Alimenta el diálogo de problemas del carrito,
  /// para que muestre la lista real y no una vacía.
  List<CartItem> itemsSinStock(List<ProductoEntity> productos) {
    return items.where((item) {
      if (item.cantidad <= 0) return true;
      final producto = productos
          .firstWhereOrNull((p) => p.id.toString() == item.producto.id);
      if (producto == null) return true;
      return item.cantidad > producto.stock;
    }).toList();
  }

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

  // ════════════════════════════════════════════════════════════
  // 🆕 NUEVO: Reemplazar TODOS los items de una sola vez.
  // Usado al retomar un carrito parkeado.
  // ════════════════════════════════════════════════════════════
  void reemplazarItems(
    List<CartItem> nuevosItems, {
    ConfiguracionIva? configIva,
    bool? ivaHabilitado,
  }) {
    state = CartState(
      items: nuevosItems,
      configIva: configIva ?? state.configIva,
      ivaHabilitado: ivaHabilitado ?? state.ivaHabilitado,
    );
  }

  /// R.3 · `estacionId` es ADITIVO a propósito.
  ///
  /// `ProductItem` (el dominio) tiene prohibido llevar `departamentoId`,
  /// así que la estación se pasa desde el caller, que sí tiene el
  /// `ProductoEntity`. Omitirlo deja la línea en `null` = venta directa,
  /// que es el comportamiento correcto en retail.
  void agregarProducto(
    ProductItem producto, {
    double cantidad = 1.0,
    double? stockMaximo,
    int? estacionId,
    String? imagenUrl,
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
        imagenUrl: imagenUrl,
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
        estacionId: estacionId,
        imagenUrl: imagenUrl,
      );
      state = state.copyWith(items: [...state.items, nuevoItem]);
    }
  }

  /// Alias de [agregarProducto] que existía desde antes de R.3.
  ///
  /// Reenvía `estacionId` e `imagenUrl` para que los callers que usan este
  /// atajo también propaguen la estación y la miniatura (KDS).
  void agregarItem(ProductItem producto, double cantidad,
      {double? stockMaximo, int? estacionId, String? imagenUrl}) {
    agregarProducto(
      producto,
      cantidad: cantidad,
      stockMaximo: stockMaximo,
      estacionId: estacionId,
      imagenUrl: imagenUrl,
    );
  }

  /// Busca el índice del item cuyo producto tiene ese `productoId`.
  ///
  /// ⚠️ `ProductItem.id` es `String` (`domain/models/product_item.dart`),
  /// así que el `productoId` entrante se convierte a String antes de
  /// comparar. Antes se comparaba `String == int`, lo que es siempre
  /// `false`: este método devolvía `-1` sin excepción y los callers
  /// (`inventory_catalog_screen.dart`) caían siempre en la rama de
  /// "agregar item nuevo" en vez de sumar al existente.
  int buscarItemIndex(int productoId) {
    final idStr = productoId.toString();
    return state.items.indexWhere((item) => item.producto.id == idStr);
  }

  /// Suma `cantidad` (positivo o negativo) al item en [index].
  ///
  /// Acepta deltas negativos para restar: el `−` del stepper de cantidad
  /// usa este método en lugar de llamar `actualizarCantidad` directo, de
  /// modo que la API es simétrica.
  ///
  /// Un delta de `0` se ignora por ser un no-op. Si el resultado queda
  /// en `<= 0` el item se elimina, y el clamp contra [stockMaximo]
  /// también los resuelve `actualizarCantidad`, así que no se duplica.
  void sumarCantidad(int index, double cantidad, {double? stockMaximo}) {
    if (index < 0 || index >= state.items.length) return;
    if (cantidad == 0) return;

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

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});