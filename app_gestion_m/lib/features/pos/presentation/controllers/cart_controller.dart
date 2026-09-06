import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/product_item.dart';

/// Estado que maneja la lista de items y totales del POS
class CartState {
  final List<CartItem> items;
  final double porcentajeImpuesto; // ej. 0.16 para 16% IVA
  final bool preciosIncluyenImpuesto; // Indica si los precios de lista ya tienen el IVA incluido

  const CartState({
    this.items = const [],
    this.porcentajeImpuesto = 0.16,
    this.preciosIncluyenImpuesto = true,
  });

  /// Suma bruta de todos los ítems en el carrito (Precio * Cantidad)
  double get totalBrutoItems {
    final suma = items.fold(0.0, (sum, item) => sum + item.subtotal);
    return _redondearDosDecimales(suma);
  }

  /// Total a pagar final
  double get total {
    if (preciosIncluyenImpuesto) {
      return totalBrutoItems;
    } else {
      return _redondearDosDecimales(totalBrutoItems + impuesto);
    }
  }

  /// Subtotal (Base Imponible)
  double get subtotal {
    if (preciosIncluyenImpuesto) {
      if (porcentajeImpuesto <= 0) return totalBrutoItems;
      return _redondearDosDecimales(totalBrutoItems / (1.0 + porcentajeImpuesto));
    } else {
      return totalBrutoItems;
    }
  }

  /// Monto total del IVA
  double get impuesto {
    if (preciosIncluyenImpuesto) {
      return _redondearDosDecimales(total - subtotal);
    } else {
      return _redondearDosDecimales(subtotal * porcentajeImpuesto);
    }
  }

  /// Cantidad total de ítems/líneas en la orden
  int get cantidadItems => items.length;

  /// Función auxiliar interna para evitar descuadres de centavos por coma flotante
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

/// Notifier para manipular el estado del carrito de compras
class CartNotifier extends StateNotifier<CartState> {
  CartNotifier() : super(const CartState());

  /// Cambia dinámicamente si aplica IVA (16%) o exento (0%)
  void setAplicaIva(bool aplica) {
    state = state.copyWith(
      porcentajeImpuesto: aplica ? 0.16 : 0.0,
    );
  }

  /// Agrega un producto al carrito respetando stock y el tipo de medida (unidades o peso)
  void agregarProducto(
    ProductItem producto, {
    double cantidad = 1.0,
    double? stockMaximo,
  }) {
    if (cantidad <= 0) return;

    final indexExistente = state.items.indexWhere((item) => item.producto.id == producto.id);

    if (indexExistente != -1) {
      // Si el producto ya está en el carrito, acumulamos la cantidad
      final itemsActualizados = List<CartItem>.from(state.items);
      final itemExistente = itemsActualizados[indexExistente];
      double nuevaCantidad = itemExistente.cantidad + cantidad;

      // Validar límite de stock disponible si se proporcionó
      if (stockMaximo != null && nuevaCantidad > stockMaximo) {
        nuevaCantidad = stockMaximo;
      }

      // Redondear cantidad (3 decimales para pesaje, entero/2 para unid)
      nuevaCantidad = _redondearCantidad(nuevaCantidad, producto.esPesado);

      itemsActualizados[indexExistente] = itemExistente.copyWith(
        cantidad: nuevaCantidad,
      );

      state = state.copyWith(items: itemsActualizados);
    } else {
      // Si es un producto nuevo en la orden
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

  /// Actualiza directamente la cantidad de un ítem por su índice en la lista
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

  void establecerPrecioEspecial(int index, double? precio) {
    if (index < 0 || index >= state.items.length) return;
    final item = state.items[index];
    if (precio != null && (precio <= 0 || precio >= item.producto.precioUnidad)) {
      return;
    }
    final itemsActualizados = List<CartItem>.from(state.items);
    itemsActualizados[index] = item.copyWith(
      precioEspecial: precio,
      quitarPrecioEspecial: precio == null,
    );
    state = state.copyWith(items: itemsActualizados);
  }

  /// Elimina un ítem específico del carrito por su índice
  void eliminarItem(int index) {
    if (index < 0 || index >= state.items.length) return;
    final itemsActualizados = List<CartItem>.from(state.items)..removeAt(index);
    state = state.copyWith(items: itemsActualizados);
  }

  /// Limpia todos los productos del carrito y reinicia el IVA por defecto
  void limpiarCarrito() {
    state = state.copyWith(
      items: [],
      porcentajeImpuesto: 0.16,
    );
  }

  /// Auxiliar para redondear cantidades (3 decimales si es de balanza, de lo contrario normal)
  double _redondearCantidad(double valor, bool esPesado) {
    if (esPesado) {
      return double.parse(valor.toStringAsFixed(3));
    }
    return valor.roundToDouble();
  }
}

/// Provider global accesible desde cualquier Widget con Riverpod
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});