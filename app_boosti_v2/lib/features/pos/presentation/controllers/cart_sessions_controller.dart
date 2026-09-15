// lib/features/pos/presentation/controllers/cart_sessions_controller.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/Local/entities/cart_session_entity.dart';
import '../../data/Local/entities/cliente_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../domain/models/cart_item.dart';
import '../../domain/models/product_item.dart';
import 'cart_controller.dart';

/// Máximo de carritos en espera por usuario.
const int kMaxCarritosEnEspera = 10;

/// Umbral de abandono: más de N horas sin retomar → abandonado.
const Duration kUmbralAbandono = Duration(hours: 24);

class CartSessionsState {
  final List<CartSessionEntity> sessions;
  final bool isLoading;
  final String? error;

  const CartSessionsState({
    this.sessions = const [],
    this.isLoading = false,
    this.error,
  });

  int get count => sessions.length;
  bool get isEmpty => sessions.isEmpty;
  bool get canParkMore => sessions.length < kMaxCarritosEnEspera;

  CartSessionsState copyWith({
    List<CartSessionEntity>? sessions,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return CartSessionsState(
      sessions: sessions ?? this.sessions,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CartSessionsNotifier extends StateNotifier<CartSessionsState> {
  final Ref _ref;
  final IsarService _isar = IsarService();

  int? _usuarioId;

  CartSessionsNotifier(this._ref) : super(const CartSessionsState());

  // ============================================================
  // CARGA
  // ============================================================

  Future<void> cargarSesiones(int usuarioId) async {
    _usuarioId = usuarioId;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _isar.marcarSesionesAbandonadas(usuarioId);
      final sesiones = await _isar.obtenerSesionesDeUsuario(usuarioId);
      state = CartSessionsState(sessions: sesiones);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> recargar() async {
    if (_usuarioId == null) return;
    await cargarSesiones(_usuarioId!);
  }

  // ============================================================
  // PARKEAR CARRITO ACTUAL
  // ============================================================

  Future<String?> parkearCarritoActivo({
    required String nombre,
    ClienteEntity? cliente,
    String? clienteNombreLibre,
    String? notas,
  }) async {
    if (_usuarioId == null) return 'Usuario no autenticado';
    if (!state.canParkMore) {
      return 'Límite alcanzado: máximo $kMaxCarritosEnEspera carritos en espera';
    }

    final cartState = _ref.read(cartProvider);
    if (cartState.items.isEmpty) return 'El carrito está vacío';

    try {
      final nombreCliente =
          cliente != null ? cliente.nombre : clienteNombreLibre;

      // ✅ Mapear items UNA sola vez y reutilizar.
      final sessionItems =
          cartState.items.map(_cartItemToSessionItem).toList();

      final sesion = CartSessionEntity()
        ..sessionId = const Uuid().v4()
        ..usuarioId = _usuarioId!
        ..nombre = nombre.trim().isEmpty ? 'Carrito' : nombre.trim()
        ..clienteIsarId = cliente?.id
        ..clienteSupabaseId = cliente?.supabaseId
        ..clienteNombre = nombreCliente
        ..clienteDocumento = cliente?.documento
        ..notas = notas
        ..configIvaPais = cartState.configIva.codigoPais
        ..configIvaPorcentaje = cartState.configIva.porcentajeIva
        ..configIvaPreciosIncluyenIva =
            cartState.configIva.preciosIncluyenIva
        ..ivaHabilitado = cartState.ivaHabilitado
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now()
        ..status = CartSessionStatus.enEspera
        ..items = sessionItems
        // ✅ Sincronizamos itemsNombres desde los items mapeados
        //    para que la card pueda mostrar la vista previa.
        ..itemsNombres =
            sessionItems.map((i) => i.productoNombre).toList();

      await _isar.guardarSesion(sesion);
      _ref.read(cartProvider.notifier).limpiarCarrito();
      await recargar();
      return null;
    } catch (e) {
      return 'Error al parkear: $e';
    }
  }

  // ============================================================
  // RETOMAR CARRITO
  // ============================================================

  Future<String?> retomarSesion(
    String sessionId, {
    String nombreAutoPark = 'Carrito (auto)',
  }) async {
    try {
      final sesion = state.sessions.firstWhere(
        (s) => s.sessionId == sessionId,
      );

      // Si el carrito actual tiene items, se parkea automáticamente
      // antes de retomar el seleccionado.
      final cartState = _ref.read(cartProvider);
      if (cartState.items.isNotEmpty) {
        final error = await parkearCarritoActivo(nombre: nombreAutoPark);
        if (error != null) return error;
      }

      final items = sesion.items.map(_sessionItemToCartItem).toList();

      _ref.read(cartProvider.notifier).reemplazarItems(
            items,
            configIva: ConfiguracionIva(
              codigoPais: sesion.configIvaPais,
              porcentajeIva: sesion.configIvaPorcentaje,
              preciosIncluyenIva: sesion.configIvaPreciosIncluyenIva,
            ),
            ivaHabilitado: sesion.ivaHabilitado,
          );

      await _isar.eliminarSesion(sessionId);
      await recargar();
      return null;
    } catch (e) {
      return 'Error al retomar: $e';
    }
  }

  // ============================================================
  // ELIMINAR / RENOMBRAR
  // ============================================================

  Future<String?> eliminarSesion(String sessionId) async {
    try {
      await _isar.eliminarSesion(sessionId);
      await recargar();
      return null;
    } catch (e) {
      return 'Error al eliminar: $e';
    }
  }

  Future<String?> renombrarSesion(String sessionId, String nuevoNombre) async {
    try {
      final sesion = state.sessions.firstWhere(
        (s) => s.sessionId == sessionId,
      );
      sesion.nombre =
          nuevoNombre.trim().isEmpty ? 'Carrito' : nuevoNombre.trim();
      sesion.updatedAt = DateTime.now();
      await _isar.guardarSesion(sesion);
      await recargar();
      return null;
    } catch (e) {
      return 'Error al renombrar: $e';
    }
  }

  // ============================================================
  // LIMPIEZA
  // ============================================================

  Future<void> limpiarAlCerrarSesion() async {
    if (_usuarioId == null) return;
    await _isar.eliminarSesionesDeUsuario(_usuarioId!);
    state = const CartSessionsState();
    _usuarioId = null;
  }

  // ============================================================
  // MAPEO
  // ============================================================

  CartSessionItem _cartItemToSessionItem(CartItem item) {
    return CartSessionItem()
      ..productoId = item.producto.id
      ..productoNombre = item.producto.nombre
      ..productoCodigoBarras = item.producto.codigoBarras
      ..productoCategoria = item.producto.categoria
      ..precioUnidad = item.producto.precioUnidad
      ..precioOriginal = item.precioOriginal
      ..cantidad = item.cantidad
      ..esPesado = item.producto.esPesado
      ..esDescuentoEspecial = item.esDescuentoEspecial;
  }

  CartItem _sessionItemToCartItem(CartSessionItem s) {
    final producto = ProductItem(
      id: s.productoId,
      nombre: s.productoNombre,
      codigoBarras: s.productoCodigoBarras,
      categoria: s.productoCategoria,
      precioUnidad: s.precioUnidad,
      esPesado: s.esPesado,
    );

    return CartItem(
      producto: producto,
      cantidad: s.cantidad,
      precioOriginal: s.precioOriginal,
      esDescuentoEspecial: s.esDescuentoEspecial,
    );
  }
}

final cartSessionsProvider =
    StateNotifierProvider<CartSessionsNotifier, CartSessionsState>((ref) {
  return CartSessionsNotifier(ref);
});