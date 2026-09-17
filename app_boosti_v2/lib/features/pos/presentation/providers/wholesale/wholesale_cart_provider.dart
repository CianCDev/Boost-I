// lib/features/pos/presentation/providers/wholesale/wholesale_cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/cliente_entity.dart';
import '../../../data/Local/entities/config_descuento_mayorista_entity.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../../domain/permissions/roles.dart';
import '../../../domain/wholesale/wholesale_cart_item.dart';
import '../../providers/isar_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../services/mayoreo/wholesale_authorization_service.dart';
import '../../services/mayoreo/wholesale_pricing_service.dart';

// ═══════════════════════════════════════════════════════════════════
// ESTADO DEL CARRITO
// ═══════════════════════════════════════════════════════════════════

@immutable
class WholesaleCartState {
  final List<WholesaleCartItem> items;
  final ClienteEntity? cliente;

  /// % de descuento global aplicado al subtotal final.
  final double descuentoGlobalPorcentaje;

  /// `true` si el descuento global ya fue autorizado.
  final bool descuentoGlobalAutorizado;
  final String? autorizadoPorNombreGlobal;

  /// Método de pago principal (para mostrar en UI).
  final String metodoPagoPrincipal;

  /// Modalidad de pago.
  final bool esMultipago;

  /// Descuento mínimo requerido (%) — para validar multipago.
  final double minimoRequeridoPorcentaje;

  const WholesaleCartState({
    this.items = const [],
    this.cliente,
    this.descuentoGlobalPorcentaje = 0.0,
    this.descuentoGlobalAutorizado = false,
    this.autorizadoPorNombreGlobal,
    this.metodoPagoPrincipal = 'efectivo_usd',
    this.esMultipago = false,
    this.minimoRequeridoPorcentaje = 0.0,
  });

  // ──────────────── Cálculos ────────────────

  int get cantidadItems => items.length;

  /// Suma de las cantidades (unidades totales).
  int get cantidadUnidades =>
      items.fold<int>(0, (sum, item) => sum + item.cantidad);

  /// Subtotal antes de descuento global.
  double get subtotal => items.fold<double>(
        0.0,
        (sum, item) => sum + item.subtotalFinal,
      );

  /// Monto descontado por el descuento global.
  double get montoDescuentoGlobal =>
      subtotal * (descuentoGlobalPorcentaje / 100.0);

  /// Subtotal después de descuento global (antes de IVA).
  double get subtotalConDescuento => subtotal - montoDescuentoGlobal;

  /// IVA (16% por defecto). Cambiar si el negocio usa otra alícuota.
  static const double ivaPorcentaje = 16.0;
  double get impuesto => subtotalConDescuento * (ivaPorcentaje / 100.0);

  /// Total final en USD.
  double get total => subtotalConDescuento + impuesto;

  /// Ahorro total vs. precios detal.
  double get ahorroTotalVsDetal =>
      items.fold<double>(0.0, (sum, item) => sum + item.ahorroVsDetal);

  /// ¿Hay items en el carrito?
  bool get tieneItems => items.isNotEmpty;

  /// ¿Requiere autorización algún descuento (línea o global)?
  bool get requiereAutorizacion {
    final itemsRequieren = items.any((i) => i.requiereAutorizacionDescuento);
    final globalRequiere =
        descuentoGlobalPorcentaje > 0 && !descuentoGlobalAutorizado;
    return itemsRequieren || globalRequiere;
  }

  /// Suma de todos los descuentos autorizados pendientes de aprobación.
  List<WholesaleCartItem> get itemsConDescuentoPendiente => items
      .where((i) => i.requiereAutorizacionDescuento)
      .toList();

  // ──────────────── copyWith ────────────────

  WholesaleCartState copyWith({
    List<WholesaleCartItem>? items,
    ClienteEntity? cliente,
    bool clearCliente = false,
    double? descuentoGlobalPorcentaje,
    bool? descuentoGlobalAutorizado,
    String? autorizadoPorNombreGlobal,
    bool clearAutorizadoGlobal = false,
    String? metodoPagoPrincipal,
    bool? esMultipago,
    double? minimoRequeridoPorcentaje,
  }) {
    return WholesaleCartState(
      items: items ?? this.items,
      cliente: clearCliente ? null : (cliente ?? this.cliente),
      descuentoGlobalPorcentaje:
          descuentoGlobalPorcentaje ?? this.descuentoGlobalPorcentaje,
      descuentoGlobalAutorizado:
          descuentoGlobalAutorizado ?? this.descuentoGlobalAutorizado,
      autorizadoPorNombreGlobal: clearAutorizadoGlobal
          ? null
          : (autorizadoPorNombreGlobal ?? this.autorizadoPorNombreGlobal),
      metodoPagoPrincipal: metodoPagoPrincipal ?? this.metodoPagoPrincipal,
      esMultipago: esMultipago ?? this.esMultipago,
      minimoRequeridoPorcentaje:
          minimoRequeridoPorcentaje ?? this.minimoRequeridoPorcentaje,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════════

class WholesaleCartNotifier extends StateNotifier<WholesaleCartState> {
  final Ref _ref;

  WholesaleCartNotifier(this._ref) : super(const WholesaleCartState());

  // ──────────────── Helpers internos ────────────────

  UserRole get _rolActual {
    final usuario = _ref.read(usuarioActualProvider);
    if (usuario == null) return UserRole.cajero;
    return UserRole.fromString(usuario.rol);
  }

  /// Carga las reglas de descuento por volumen activas.
  Future<List<ConfigDescuentoMayoristaEntity>> _cargarReglasVolumen() async {
    try {
      final isar = _ref.read(isarServiceProvider);
      return await isar.obtenerConfigDescuentos(soloActivos: true);
    } catch (e) {
      debugPrint('⚠️ Error cargando reglas de volumen: $e');
      return [];
    }
  }

  // ──────────────── Agregar / actualizar ────────────────

  /// Agrega un producto al carrito.
  ///
  /// Resuelve automáticamente el precio (mayor / medio mayor / detal) y
  /// aplica descuentos automáticos por volumen.
  Future<void> agregarProducto({
    required ProductoEntity producto,
    required int cantidad,
    String unidadEmpaque = 'unidad',
    int? unidadesPorEmpaque,
  }) async {
    if (cantidad <= 0) return;

    final reglas = await _cargarReglasVolumen();

    final precio = WholesalePricingService.resolver(
      producto: producto,
      cantidad: cantidad,
      reglasVolumen: reglas,
    );

    final nuevoItem = WholesaleCartItem.desdePrecioResuelto(
      producto: producto,
      cantidad: cantidad,
      precio: precio,
      unidadEmpaque: unidadEmpaque,
      unidadesPorEmpaque: unidadesPorEmpaque,
    );

    final itemsActualizados = List<WholesaleCartItem>.from(state.items);
    final indexExistente =
        itemsActualizados.indexWhere((i) => i.lineId == nuevoItem.lineId);

    if (indexExistente >= 0) {
      // Ya existe → sumar cantidades y re-resolver precio
      final itemExistente = itemsActualizados[indexExistente];
      final nuevaCantidad = itemExistente.cantidad + cantidad;
      final precioActualizado = WholesalePricingService.resolver(
        producto: producto,
        cantidad: nuevaCantidad,
        reglasVolumen: reglas,
      );
      itemsActualizados[indexExistente] =
          WholesaleCartItem.desdePrecioResuelto(
        producto: producto,
        cantidad: nuevaCantidad,
        precio: precioActualizado,
        unidadEmpaque: unidadEmpaque,
        unidadesPorEmpaque: unidadesPorEmpaque,
      );
    } else {
      itemsActualizados.add(nuevoItem);
    }

    state = state.copyWith(items: itemsActualizados);
  }

  /// Actualiza la cantidad de una línea (recalcula precio).
  Future<void> actualizarCantidad(String lineId, int nuevaCantidad) async {
    if (nuevaCantidad <= 0) {
      eliminarItem(lineId);
      return;
    }

    final reglas = await _cargarReglasVolumen();
    final itemsActualizados = List<WholesaleCartItem>.from(state.items);
    final index = itemsActualizados.indexWhere((i) => i.lineId == lineId);
    if (index < 0) return;

    final item = itemsActualizados[index];
    final precioActualizado = WholesalePricingService.resolver(
      producto: item.producto,
      cantidad: nuevaCantidad,
      reglasVolumen: reglas,
    );

    itemsActualizados[index] = WholesaleCartItem.desdePrecioResuelto(
      producto: item.producto,
      cantidad: nuevaCantidad,
      precio: precioActualizado,
      unidadEmpaque: item.unidadEmpaque,
      unidadesPorEmpaque: item.unidadesPorEmpaque,
    );

    state = state.copyWith(items: itemsActualizados);
  }

  void eliminarItem(String lineId) {
    final itemsActualizados =
        state.items.where((i) => i.lineId != lineId).toList();
    state = state.copyWith(items: itemsActualizados);
  }

  // ──────────────── Cliente ────────────────

  void setCliente(ClienteEntity? cliente) {
    if (cliente == null) {
      state = state.copyWith(clearCliente: true);
    } else {
      state = state.copyWith(cliente: cliente);
    }
  }

  // ──────────────── Descuentos ────────────────

  /// Aplica un descuento manual a una línea.
  ///
  /// Devuelve `true` si requiere autorización pendiente, `false` si
  /// quedó aplicado sin autorización.
  bool aplicarDescuentoLinea({
    required String lineId,
    required double porcentaje,
  }) {
    final evaluacion = WholesaleAuthorizationService.evaluar(
      descuentoPorcentaje: porcentaje,
      rolSolicitante: _rolActual,
    );

    if (!evaluacion.esValido) {
      debugPrint('⚠️ Descuento inválido: ${evaluacion.motivoInvalidez}');
      return false;
    }

    final itemsActualizados = List<WholesaleCartItem>.from(state.items);
    final index = itemsActualizados.indexWhere((i) => i.lineId == lineId);
    if (index < 0) return false;

    itemsActualizados[index] = itemsActualizados[index].copyWith(
      descuentoManualPorcentaje: porcentaje,
      descuentoAutorizado: !evaluacion.requiereAutorizacion,
      clearAutorizadoPorNombre: evaluacion.requiereAutorizacion,
    );

    state = state.copyWith(items: itemsActualizados);
    return evaluacion.requiereAutorizacion;
  }

  /// Marca una línea como autorizada (tras validar admin).
  void autorizarDescuentoLinea({
    required String lineId,
    required String autorizadoPor,
  }) {
    final itemsActualizados = List<WholesaleCartItem>.from(state.items);
    final index = itemsActualizados.indexWhere((i) => i.lineId == lineId);
    if (index < 0) return;

    itemsActualizados[index] = itemsActualizados[index].copyWith(
      descuentoAutorizado: true,
      autorizadoPorNombre: autorizadoPor,
    );

    state = state.copyWith(items: itemsActualizados);
  }

  /// Aplica un descuento global.
  ///
  /// Devuelve `true` si requiere autorización.
  bool aplicarDescuentoGlobal(double porcentaje) {
    final evaluacion = WholesaleAuthorizationService.evaluar(
      descuentoPorcentaje: porcentaje,
      rolSolicitante: _rolActual,
    );

    if (!evaluacion.esValido) {
      debugPrint('⚠️ Descuento global inválido: ${evaluacion.motivoInvalidez}');
      return false;
    }

    state = state.copyWith(
      descuentoGlobalPorcentaje: porcentaje,
      descuentoGlobalAutorizado: !evaluacion.requiereAutorizacion,
      clearAutorizadoGlobal: evaluacion.requiereAutorizacion,
    );

    return evaluacion.requiereAutorizacion;
  }

  void autorizarDescuentoGlobal({required String autorizadoPor}) {
    state = state.copyWith(
      descuentoGlobalAutorizado: true,
      autorizadoPorNombreGlobal: autorizadoPor,
    );
  }

  void quitarDescuentoGlobal() {
    state = state.copyWith(
      descuentoGlobalPorcentaje: 0,
      descuentoGlobalAutorizado: false,
      clearAutorizadoGlobal: true,
    );
  }

  /// Acepta todos los descuentos pendientes con un mismo autorizador.
  ///
  /// Útil cuando se ingresa el PIN del admin una sola vez y se autorizan
  /// todos los descuentos de la venta.
  void autorizarTodosLosDescuentos({required String autorizadoPor}) {
    final itemsActualizados = state.items.map((item) {
      if (item.requiereAutorizacionDescuento) {
        return item.copyWith(
          descuentoAutorizado: true,
          autorizadoPorNombre: autorizadoPor,
        );
      }
      return item;
    }).toList();

    state = state.copyWith(
      items: itemsActualizados,
      descuentoGlobalAutorizado:
          state.descuentoGlobalPorcentaje > 0 ? true : state.descuentoGlobalAutorizado,
      autorizadoPorNombreGlobal:
          state.descuentoGlobalPorcentaje > 0 ? autorizadoPor : null,
    );
  }

  // ──────────────── Pago ────────────────

  void setMetodoPagoPrincipal(String metodo) {
    state = state.copyWith(metodoPagoPrincipal: metodo);
  }

  void setEsMultipago(bool valor) {
    state = state.copyWith(esMultipago: valor);
  }

  void setMinimoRequeridoPorcentaje(double pct) {
    state = state.copyWith(
      minimoRequeridoPorcentaje: pct.clamp(0.0, 100.0),
    );
  }

  // ──────────────── Reset ────────────────

  void limpiarCarrito() {
    state = const WholesaleCartState();
  }

  /// Crea un snapshot serializable del carrito (para cotizaciones).
  List<Map<String, dynamic>> serializarItems() {
    return state.items.map((item) {
      return {
        'productoId': item.producto.id,
        'productoSupabaseId': item.producto.supabaseId,
        'nombreProducto': item.producto.nombre,
        'cantidad': item.cantidad,
        'unidadEmpaque': item.unidadEmpaque,
        'unidadesPorEmpaque': item.unidadesPorEmpaque,
        'precioUnitario': item.precioUnitario,
        'precioDetalOriginal': item.precioDetalOriginal,
        'tipoPrecio': item.tipoPrecio.storageKey,
        'descuentoAutoPorcentaje': item.descuentoAutoPorcentaje,
        'descuentoManualPorcentaje': item.descuentoManualPorcentaje,
        'descuentoAutorizado': item.descuentoAutorizado,
        'autorizadoPorNombre': item.autorizadoPorNombre,
        'subtotalFinal': item.subtotalFinal,
      };
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════

final wholesaleCartProvider =
    StateNotifierProvider<WholesaleCartNotifier, WholesaleCartState>((ref) {
  return WholesaleCartNotifier(ref);
});

// ──────────────── Providers derivados (computed) ────────────────

/// Cantidad total de items.
final wholesaleCartItemCountProvider = Provider<int>((ref) {
  final state = ref.watch(wholesaleCartProvider);
  return state.cantidadItems;
});

/// Total en USD.
final wholesaleCartTotalProvider = Provider<double>((ref) {
  final state = ref.watch(wholesaleCartProvider);
  return state.total;
});

/// ¿Requiere autorización?
final wholesaleCartRequiereAutorizacionProvider = Provider<bool>((ref) {
  final state = ref.watch(wholesaleCartProvider);
  return state.requiereAutorizacion;
});