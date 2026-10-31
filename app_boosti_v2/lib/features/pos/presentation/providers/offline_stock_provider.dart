import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/cart_controller.dart';
import 'productos_provider.dart';

/// Niveles de riesgo del colchón de stock offline.
enum NivelRiesgoStock { verde, ambar, naranja, rojo }

class OfflineStockState {
  final bool isOnline;
  final Map<int, NivelRiesgoStock> riesgoPorProducto;

  const OfflineStockState({
    this.isOnline = true,
    this.riesgoPorProducto = const {},
  });

  OfflineStockState copyWith({
    bool? isOnline,
    Map<int, NivelRiesgoStock>? riesgoPorProducto,
  }) {
    return OfflineStockState(
      isOnline: isOnline ?? this.isOnline,
      riesgoPorProducto: riesgoPorProducto ?? this.riesgoPorProducto,
    );
  }
}

class OfflineStockNotifier extends StateNotifier<OfflineStockState> {
  final Ref _ref;
  late final ProviderSubscription<AsyncValue<List<ConnectivityResult>>>
      _connectivitySub;
  late final ProviderSubscription<CartState> _cartSub;
  late final ProviderSubscription<ProductosState> _productosSub;

  OfflineStockNotifier(this._ref) : super(const OfflineStockState()) {
    // Escuchar cambios de conectividad
    _connectivitySub = _ref.listen(
      connectivityProvider,
      (previous, next) {
        final connectivity = next.when(
          data: (results) => results,
          loading: () => null,
          error: (error, stackTrace) {
            debugPrint('❌ Error leyendo conectividad: $error');
            return <ConnectivityResult>[];
          },
        );
        if (connectivity == null) return;

        final isOnline = connectivity.any((r) => r != ConnectivityResult.none);
        if (state.isOnline != isOnline) {
          state = state.copyWith(isOnline: isOnline);
        }
        _calcularRiesgos();
      },
      fireImmediately: true,
    );

    // Escuchar cambios en el carrito (comprometido)
    _cartSub = _ref.listen(cartProvider, (_, __) {
      _calcularRiesgos();
    });

    // Escuchar cambios en productos (stock local)
    _productosSub = _ref.listen(productosProvider, (_, __) {
      _calcularRiesgos();
    });
  }

  @override
  void dispose() {
    _connectivitySub.close();
    _cartSub.close();
    _productosSub.close();
    super.dispose();
  }

  /// Calcula el riesgo de cada producto basado en su stock local vs el stock
  /// comprometido en el carrito.
  void _calcularRiesgos() {
    if (state.isOnline) {
      if (state.riesgoPorProducto.isNotEmpty) {
        state = state.copyWith(riesgoPorProducto: {});
      }
      return;
    }

    final productosState = _ref.read(productosProvider);
    final cartState = _ref.read(cartProvider);

    if (productosState.items.isEmpty) {
      if (state.riesgoPorProducto.isNotEmpty) {
        state = state.copyWith(riesgoPorProducto: {});
      }
      return;
    }
    final Map<int, NivelRiesgoStock> nuevosRiesgos = {};
    for (final producto in productosState.items) {
      double enCarrito = 0;
      final idLocal = producto.id.toString();
      for (final item in cartState.items) {
        if (item.producto.id == idLocal ||
            item.producto.id == producto.supabaseId) {
          enCarrito += item.cantidad;
        }
      }
      final vendible = producto.stock - enCarrito;

      NivelRiesgoStock riesgo = NivelRiesgoStock.verde;

      if (vendible <= 0) {
        riesgo = NivelRiesgoStock.rojo;
      } else if (vendible <= producto.stockMinimo) {
        riesgo = NivelRiesgoStock.naranja;
      } else if (vendible <= producto.stockMinimo * 2) {
        riesgo = NivelRiesgoStock.ambar;
      }

      if (riesgo != NivelRiesgoStock.verde) {
        nuevosRiesgos[producto.id] = riesgo;
      }
    }

    if (nuevosRiesgos.length == state.riesgoPorProducto.length) {
      bool hayCambios = false;
      for (final entry in nuevosRiesgos.entries) {
        if (state.riesgoPorProducto[entry.key] != entry.value) {
          hayCambios = true;
          break;
        }
      }
      if (!hayCambios) return;
    }

    state = state.copyWith(riesgoPorProducto: nuevosRiesgos);
  }
}

// Provider de conectividad base (si no lo tenés ya en tu código)
final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

// Provider del colchón de stock
final offlineStockProvider =
    StateNotifierProvider<OfflineStockNotifier, OfflineStockState>((ref) {
  return OfflineStockNotifier(ref);
});
