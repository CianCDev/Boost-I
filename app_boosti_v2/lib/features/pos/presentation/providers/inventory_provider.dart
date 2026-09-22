// lib/features/pos/presentation/providers/inventory_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/producto_entity.dart';
import 'productos_provider.dart';

class InventoryState {
  final String filtroBusqueda;
  final String categoriaSeleccionadaNombre;
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
      productosSeleccionados:
          productosSeleccionados ?? this.productosSeleccionados,
      productosFiltrados: productosFiltrados ?? this.productosFiltrados,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  int get cantidadSeleccionados => productosSeleccionados.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryState &&
          other.filtroBusqueda == filtroBusqueda &&
          other.categoriaSeleccionadaNombre == categoriaSeleccionadaNombre &&
          other.soloStockBajo == soloStockBajo &&
          other.seleccionMultiple == seleccionMultiple &&
          other.isLoading == isLoading &&
          _mismoSet(other.productosSeleccionados, productosSeleccionados) &&
          _mismaL3istaProductos(other.productosFiltrados, productosFiltrados);

  @override
  int get hashCode => Object.hash(
        filtroBusqueda,
        categoriaSeleccionadaNombre,
        soloStockBajo,
        seleccionMultiple,
        isLoading,
        Object.hashAll(productosSeleccionados),
        Object.hashAll(productosFiltrados.map((p) => p.id)),
      );

  static bool _mismoSet(Set<int> a, Set<int> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    return a.containsAll(b);
  }

  static bool _mismaL3istaProductos(
    List<ProductoEntity> a,
    List<ProductoEntity> b,
  ) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
      if (a[i].stock != b[i].stock) return false;
      if (a[i].precioUnidad != b[i].precioUnidad) return false;
      if (a[i].nombre != b[i].nombre) return false;
    }
    return true;
  }

  @override
  String toString() => 'InventoryState('
      'filtro="$filtroBusqueda", '
      'cat="$categoriaSeleccionadaNombre", '
      'stockBajo=$soloStockBajo, '
      'sel=${productosSeleccionados.length}, '
      'filtrados=${productosFiltrados.length}, '
      'loading=$isLoading)';
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final Ref ref;

  InventoryNotifier(this.ref) : super(const InventoryState());

  // ══════════════════════════════════════════════════════════════
  // FILTRADO (invocado desde el provider, NO desde el constructor)
  // ══════════════════════════════════════════════════════════════

  void aplicarFiltros(ProductosState productosState) {
    final productos = productosState.items;
    final query = state.filtroBusqueda.toLowerCase().trim();
    final categoriaNombre = state.categoriaSeleccionadaNombre;
    final soloStockBajo = state.soloStockBajo;

    final filtrados = productos.where((p) {
      if (!p.activo) return false;

      final coincideTexto = query.isEmpty ||
          p.nombre.toLowerCase().contains(query) ||
          p.codigoBarras.toLowerCase().contains(query);

      final coincideCategoria = categoriaNombre == 'Todas' ||
          p.categoria.trim().toLowerCase() ==
              categoriaNombre.trim().toLowerCase();

      final coincideStockBajo =
          !soloStockBajo || (p.stock <= p.stockMinimo);

      return coincideTexto && coincideCategoria && coincideStockBajo;
    }).toList();

    // `==` estructural absorbe re-emisiones idénticas.
    state = state.copyWith(
      productosFiltrados: filtrados,
      isLoading: productosState.isLoading,
    );
  }
  

  // ══════════════════════════════════════════════════════════════
  // FILTROS (públicos)
  // ══════════════════════════════════════════════════════════════

  void setFiltroBusqueda(String query) {
    state = state.copyWith(filtroBusqueda: query);
    aplicarFiltros(ref.read(productosProvider));
  }

  void setCategoria(String categoriaNombre) {
    state = state.copyWith(categoriaSeleccionadaNombre: categoriaNombre);
    aplicarFiltros(ref.read(productosProvider));
  }

  void setSoloStockBajo(bool value) {
    state = state.copyWith(soloStockBajo: value);
    aplicarFiltros(ref.read(productosProvider));
  }

  

  // ══════════════════════════════════════════════════════════════
  // SELECCIÓN
  // ══════════════════════════════════════════════════════════════

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
    if (state.productosSeleccionados.isEmpty && !state.seleccionMultiple) {
      return;
    }
    state = state.copyWith(
      productosSeleccionados: const {},
      seleccionMultiple: false,
    );
  }
    

  Future<void> recargarDesdeSupabase() async {
    final notifier = ref.read(productosProvider.notifier);
    await notifier.recargarDesdeSupabase();
  }

  // ✅ NUEVO: valida que la categoría seleccionada siga existiendo.
  // Si no existe (fue eliminada), resetea el filtro a "Todas".
  void validarCategoriaSeleccionada(List<String> categoriasActivas) {
    final actual = state.categoriaSeleccionadaNombre;
    if (actual == 'Todas' || actual == 'Stock Bajo') return;
    if (!categoriasActivas.contains(actual)) {
      state = state.copyWith(categoriaSeleccionadaNombre: 'Todas');
      aplicarFiltros(ref.read(productosProvider));
    }
  }
}  

// ══════════════════════════════════════════════════════════════
// PROVIDER
// ══════════════════════════════════════════════════════════════
//
// El `ref.listen` vive AQUÍ, no dentro del notifier. Así el listener
// se registra en un scope válido después de que el notifier está
// completamente construido. `fireImmediately: true` sincroniza el
// primer valor cuando `productosProvider` ya tiene datos.

final inventoryProvider =
    StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  final notifier = InventoryNotifier(ref);

  ref.listen<ProductosState>(
    productosProvider,
    (_, next) => notifier.aplicarFiltros(next),
    fireImmediately: true,
  );

  return notifier;
});