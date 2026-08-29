// lib/features/pos/presentation/providers/inventory_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'productos_provider.dart';
import '../../data/Local/entities/producto_entity.dart';
import 'package:flutter/foundation.dart';

class InventoryState {
  final String filtroBusqueda;
  final int? categoriaSeleccionadaId; // ✅ int? (coherente con ProductoEntity.categoriaId)
  final bool soloStockBajo;
  final bool seleccionMultiple;
  final Set<int> productosSeleccionados;
  final List<ProductoEntity> productosFiltrados;
  final bool isLoading;

  const InventoryState({
    this.filtroBusqueda = '',
    this.categoriaSeleccionadaId,
    this.soloStockBajo = false,
    this.seleccionMultiple = false,
    this.productosSeleccionados = const {},
    this.productosFiltrados = const [],
    this.isLoading = true,
  });

  InventoryState copyWith({
    String? filtroBusqueda,
    int? categoriaSeleccionadaId, // ✅ int?
    bool? soloStockBajo,
    bool? seleccionMultiple,
    Set<int>? productosSeleccionados,
    List<ProductoEntity>? productosFiltrados,
    bool? isLoading,
  }) {
    return InventoryState(
      filtroBusqueda: filtroBusqueda ?? this.filtroBusqueda,
      categoriaSeleccionadaId: categoriaSeleccionadaId ?? this.categoriaSeleccionadaId,
      soloStockBajo: soloStockBajo ?? this.soloStockBajo,
      seleccionMultiple: seleccionMultiple ?? this.seleccionMultiple,
      productosSeleccionados: productosSeleccionados ?? this.productosSeleccionados,
      productosFiltrados: productosFiltrados ?? this.productosFiltrados,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get cantidadSeleccionados => productosSeleccionados.length;
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final Ref ref;
  late final ProviderSubscription _subscription;

  InventoryNotifier(this.ref) : super(const InventoryState()) {
    _subscription = ref.listen(productosProvider, (_, next) {
      debugPrint('📢 [InventoryNotifier] ProductosProvider cambió');
      _aplicarFiltros(next.isLoading);
    });
    final productosState = ref.read(productosProvider);
    _aplicarFiltros(productosState.isLoading);
  }

  void _aplicarFiltros(bool isLoading) {
    final productos = ref.read(productosProvider).items;
    final query = state.filtroBusqueda.toLowerCase().trim();
    final categoriaId = state.categoriaSeleccionadaId;
    final soloStockBajo = state.soloStockBajo;

    final filtrados = productos.where((p) {
      final coincideTexto = p.nombre.toLowerCase().contains(query) ||
          p.codigoBarras.toLowerCase().contains(query);

      bool coincideCategoria;
      if (categoriaId == null) {
        coincideCategoria = true;
      } else {
        coincideCategoria = p.categoriaId == categoriaId;
      }

      final coincideStockBajo = !soloStockBajo || (p.stock <= p.stockMinimo);

      return coincideTexto && coincideCategoria && coincideStockBajo;
    }).toList();

    if (state.productosFiltrados.length != filtrados.length) {
      debugPrint('🔄 [InventoryNotifier] Filtros aplicados: ${filtrados.length} productos');
    }

    state = state.copyWith(
      productosFiltrados: filtrados,
      isLoading: isLoading,
    );
  }

  void setFiltroBusqueda(String query) {
    state = state.copyWith(filtroBusqueda: query);
    _aplicarFiltros(state.isLoading);
  }

  void setCategoria(int? categoriaId) {
    state = state.copyWith(categoriaSeleccionadaId: categoriaId);
    _aplicarFiltros(state.isLoading);
  }

  void setSoloStockBajo(bool value) {
    state = state.copyWith(soloStockBajo: value);
    _aplicarFiltros(state.isLoading);
  }

  void toggleSeleccionProducto(int id) {
    final nuevos = Set<int>.from(state.productosSeleccionados);
    if (nuevos.contains(id)) {
      nuevos.remove(id);
    } else {
      nuevos.add(id);
    }
    state = state.copyWith(
      productosSeleccionados: nuevos,
      seleccionMultiple: nuevos.isNotEmpty,
    );
  }

  void limpiarSeleccion() {
    state = state.copyWith(productosSeleccionados: {}, seleccionMultiple: false);
  }

  Future<void> recargarDesdeSupabase() async {
    final notifier = ref.read(productosProvider.notifier);
    await notifier.recargarDesdeSupabase();
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  return InventoryNotifier(ref);
});