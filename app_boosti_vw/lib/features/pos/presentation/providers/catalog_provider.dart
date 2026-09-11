// lib/features/pos/presentation/providers/catalog_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'productos_provider.dart';
import '../../data/Local/entities/producto_entity.dart';

class CatalogState {
  final String busqueda;
  final String categoriaSeleccionada;
  final List<ProductoEntity> productosFiltrados;
  final List<String> categorias;
  final bool isLoading;

  const CatalogState({
    this.busqueda = '',
    this.categoriaSeleccionada = 'Todas',
    this.productosFiltrados = const [],
    this.categorias = const ['Todas', 'Stock Bajo'],
    this.isLoading = true,
  });

  CatalogState copyWith({
    String? busqueda,
    String? categoriaSeleccionada,
    List<ProductoEntity>? productosFiltrados,
    List<String>? categorias,
    bool? isLoading,
  }) {
    return CatalogState(
      busqueda: busqueda ?? this.busqueda,
      categoriaSeleccionada: categoriaSeleccionada ?? this.categoriaSeleccionada,
      productosFiltrados: productosFiltrados ?? this.productosFiltrados,
      categorias: categorias ?? this.categorias,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CatalogNotifier extends StateNotifier<CatalogState> {
  final Ref ref;
  
  CatalogNotifier(this.ref) : super(const CatalogState()) {
    // Reactivo: escucha los cambios en los productos
    ref.listen(productosProvider, (_, next) {
      _actualizarCategorias(next.items);
      _aplicarFiltros(next.isLoading);
    });

    // Carga inicial
    _actualizarCategorias(ref.read(productosProvider).items);
    _aplicarFiltros(ref.read(productosProvider).isLoading);
  }

  void _actualizarCategorias(List<ProductoEntity> productos) {
    final setCategorias = productos
        .map((p) => p.categoria.trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    state = state.copyWith(categorias: ['Todas', ...setCategorias, 'Stock Bajo']);
  }

  void _aplicarFiltros(bool isLoading) {
    final productos = ref.read(productosProvider).items;
    final query = state.busqueda.toLowerCase().trim();
    final categoria = state.categoriaSeleccionada;

    final filtrados = productos.where((p) {
      final coincideTexto = p.nombre.toLowerCase().contains(query) ||
          p.codigoBarras.toLowerCase().contains(query);

      bool coincideCategoria;
      if (categoria == 'Stock Bajo') {
        coincideCategoria = p.stock <= p.stockMinimo;
      } else if (categoria == 'Todas') {
        coincideCategoria = true;
      } else {
        coincideCategoria = p.categoria.trim().toLowerCase() == categoria.toLowerCase();
      }

      return coincideTexto && coincideCategoria;
    }).toList();

    state = state.copyWith(
      productosFiltrados: filtrados,
      isLoading: isLoading,
    );
  }

  void setBusqueda(String busqueda) {
    state = state.copyWith(busqueda: busqueda);
    _aplicarFiltros(state.isLoading);
  }

  void setCategoria(String categoria) {
    state = state.copyWith(categoriaSeleccionada: categoria);
    _aplicarFiltros(state.isLoading);
  }

  Future<void> recargarDesdeSupabase() async {
    final notifier = ref.read(productosProvider.notifier);
    await notifier.recargarDesdeSupabase();
  }

  Future<void> recargarEnSegundoPlano() async {
    final notifier = ref.read(productosProvider.notifier);
    if (ref.read(productosProvider).items.isEmpty) {
      await recargarDesdeSupabase();
      return;
    }
    await notifier.recargarDesdeSupabase();
  }

  int get lowStockCount =>
      ref.read(productosProvider).items.where((p) => p.stock <= p.stockMinimo).length;
}

final catalogProvider = StateNotifierProvider.autoDispose<CatalogNotifier, CatalogState>((ref) {
  return CatalogNotifier(ref);
});