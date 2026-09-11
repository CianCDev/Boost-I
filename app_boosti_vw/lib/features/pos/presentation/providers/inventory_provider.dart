// lib/features/pos/presentation/providers/inventory_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'productos_provider.dart';
import '../../data/Local/entities/producto_entity.dart';
import 'package:flutter/foundation.dart';

class InventoryState {
  final String filtroBusqueda;
  final String categoriaSeleccionadaNombre; // "Todas" por defecto
  final bool soloStockBajo;
  final bool seleccionMultiple;
  final Set<int> productosSeleccionados;
  final List<ProductoEntity> productosFiltrados;
  final bool isLoading;

  const InventoryState({
    this.filtroBusqueda = '',
    this.categoriaSeleccionadaNombre = 'Todas',
    this.soloStockBajo = false,
    this.seleccionMultiple = false,
    this.productosSeleccionados = const {},
    this.productosFiltrados = const [],
    this.isLoading = true,
  });

  InventoryState copyWith({
    String? filtroBusqueda,
    String? categoriaSeleccionadaNombre,
    bool? soloStockBajo,
    bool? seleccionMultiple,
    Set<int>? productosSeleccionados,
    List<ProductoEntity>? productosFiltrados,
    bool? isLoading,
  }) {
    return InventoryState(
      filtroBusqueda: filtroBusqueda ?? this.filtroBusqueda,
      categoriaSeleccionadaNombre:
          categoriaSeleccionadaNombre ?? this.categoriaSeleccionadaNombre,
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

  InventoryNotifier(this.ref) : super(const InventoryState()) {
    // 🔥 Inicialización con datos actuales
    final productos = ref.read(productosProvider).items;
    final isLoading = ref.read(productosProvider).isLoading;
    _aplicarFiltros(productos, isLoading);

    // 🔥 OPTIMIZACIÓN CLAVE: Escuchar cambios en los productos
    // Usamos .select para no escuchar todo el estado, solo la lista de items
    ref.listen(productosProvider.select((state) => state.items), (_, next) {
      // Actualizamos los filtros sin tocar el isLoading
      _aplicarFiltros(next, state.isLoading);
    });

    // Escuchar cuando cambia el estado de carga
    ref.listen(productosProvider.select((state) => state.isLoading), (_, next) {
      _aplicarFiltros(state.productosFiltrados, next);
    });
  }

  void _aplicarFiltros(List<ProductoEntity> productos, bool isLoading) {
    final query = state.filtroBusqueda.toLowerCase().trim();
    final categoriaNombre = state.categoriaSeleccionadaNombre;
    final soloStockBajo = state.soloStockBajo;

    final filtrados = productos.where((p) {
      // 🔥 Filtrar solo productos activos
      if (!p.activo) return false;

      final coincideTexto = p.nombre.toLowerCase().contains(query) ||
          p.codigoBarras.toLowerCase().contains(query);

      bool coincideCategoria;
      if (categoriaNombre == 'Todas') {
        coincideCategoria = true;
      } else {
        coincideCategoria = p.categoria.trim().toLowerCase() ==
            categoriaNombre.trim().toLowerCase();
      }

      final coincideStockBajo = !soloStockBajo || (p.stock <= p.stockMinimo);

      return coincideTexto && coincideCategoria && coincideStockBajo;
    }).toList();

    // Solo actualizamos si cambió la lista o la carga
    if (state.productosFiltrados.length != filtrados.length || state.isLoading != isLoading) {
      debugPrint('🔄 [InventoryNotifier] Filtros aplicados: ${filtrados.length} productos');
      state = state.copyWith(
        productosFiltrados: filtrados,
        isLoading: isLoading,
      );
    }
  }

  void setFiltroBusqueda(String query) {
    state = state.copyWith(filtroBusqueda: query);
    _aplicarFiltros(ref.read(productosProvider).items, state.isLoading);
  }

  void setCategoria(String categoriaNombre) {
    state = state.copyWith(categoriaSeleccionadaNombre: categoriaNombre);
    _aplicarFiltros(ref.read(productosProvider).items, state.isLoading);
  }

  void setSoloStockBajo(bool value) {
    state = state.copyWith(soloStockBajo: value);
    _aplicarFiltros(ref.read(productosProvider).items, state.isLoading);
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