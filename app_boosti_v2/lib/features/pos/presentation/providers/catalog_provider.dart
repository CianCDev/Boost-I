// lib/features/pos/presentation/providers/catalog_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/categoria_entity.dart';
import '../../data/Local/entities/producto_entity.dart';
import 'categorias_provider.dart';
import 'productos_provider.dart';

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogState &&
          other.busqueda == busqueda &&
          other.categoriaSeleccionada == categoriaSeleccionada &&
          other.isLoading == isLoading &&
          listEquals(other.categorias, categorias) &&
          _mismosProductos(other.productosFiltrados, productosFiltrados));

  @override
  int get hashCode => Object.hash(
        busqueda,
        categoriaSeleccionada,
        isLoading,
        Object.hashAll(categorias),
        Object.hashAll(productosFiltrados.map((p) => p.id)),
      );

  static bool _mismosProductos(List<ProductoEntity> a, List<ProductoEntity> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
      if (a[i].stock != b[i].stock) return false;
      if (a[i].precioUnidad != b[i].precioUnidad) return false;
      if (a[i].nombre != b[i].nombre) return false;
      if (a[i].imagenUrl != b[i].imagenUrl) return false;
      if (a[i].stockMinimo != b[i].stockMinimo) return false;
      if (a[i].categoria != b[i].categoria) return false;
      if (a[i].esPesado != b[i].esPesado) return false;
    }
    return true;
  }
}

class CatalogNotifier extends StateNotifier<CatalogState> {
  final Ref ref;

  CatalogNotifier(this.ref) : super(const CatalogState()) {
    // FIX 1: ref.listen devuelve void. El dispose manual es innecesario
    // porque Riverpod gestiona la destrucción de estos listeners junto con el Provider.
    ref.listen<ProductosState>(
      productosProvider,
      (_, next) => _aplicarFiltros(next.isLoading),
    );

    ref.listen<AsyncValue<List<CategoriaEntity>>>(
      categoriasProvider,
      (_, next) {
        next.whenData((categorias) => _actualizarCategorias(categorias));
      },
    );

    // Inicialización limpia
    final productosState = ref.read(productosProvider);
    final categoriasAsync = ref.read(categoriasProvider);
    
    if (categoriasAsync.hasValue) {
      _actualizarCategorias(categoriasAsync.value!);
    } else {
      _aplicarFiltros(productosState.isLoading);
    }
  }

  void _actualizarCategorias(List<CategoriaEntity> categoriasActivas) {
    final nombres = categoriasActivas
        .map((c) => c.nombre.trim())
        .where((c) => c.isNotEmpty)
        .toList()
      ..sort();

    final nuevaLista = ['Todas', ...nombres, 'Stock Bajo'];

    final seleccionActual = state.categoriaSeleccionada;
    final seleccionValida = seleccionActual == 'Todas' ||
        seleccionActual == 'Stock Bajo' ||
        nombres.contains(seleccionActual);
        
    final seleccionFinal = seleccionValida ? seleccionActual : 'Todas';

    if (listEquals(nuevaLista, state.categorias) &&
        seleccionFinal == state.categoriaSeleccionada) {
      return;
    }

    state = state.copyWith(
      categorias: nuevaLista,
      categoriaSeleccionada: seleccionFinal,
    );

    // FIX 2: Si la validación obligó a cambiar la selección (ej. de una categoría
    // borrada hacia 'Todas'), debemos forzar que los productos se re-filtren.
    if (seleccionActual != seleccionFinal) {
      _aplicarFiltros(state.isLoading);
    }
  }

  void _aplicarFiltros(bool isLoading) {
    final productos = ref.read(productosProvider).items;
    final query = state.busqueda.toLowerCase().trim();
    final categoria = state.categoriaSeleccionada;

    final filtrados = productos.where((p) {
      final coincideTexto = query.isEmpty ||
          p.nombre.toLowerCase().contains(query) ||
          p.codigoBarras.toLowerCase().contains(query);

      bool coincideCategoria;
      if (categoria == 'Stock Bajo') {
        coincideCategoria = p.stock <= p.stockMinimo;
      } else if (categoria == 'Todas') {
        coincideCategoria = true;
      } else {
        coincideCategoria =
            p.categoria.trim().toLowerCase() == categoria.toLowerCase();
      }

      return coincideTexto && coincideCategoria;
    }).toList();

    if (CatalogState._mismosProductos(filtrados, state.productosFiltrados) &&
        isLoading == state.isLoading) {
      return;
    }

    state = state.copyWith(
      productosFiltrados: filtrados,
      isLoading: isLoading,
    );
  }

  void setBusqueda(String busqueda) {
    if (busqueda == state.busqueda) return;
    state = state.copyWith(busqueda: busqueda);
    _aplicarFiltros(state.isLoading);
  }

  void setCategoria(String categoria) {
    if (categoria == state.categoriaSeleccionada) return;
    state = state.copyWith(categoriaSeleccionada: categoria);
    _aplicarFiltros(state.isLoading);
  }

  Future<void> recargarDesdeSupabase() async {
    final notifier = ref.read(productosProvider.notifier);
    await notifier.recargarDesdeSupabase();
    ref.invalidate(categoriasProvider);
  }

  Future<void> recargarEnSegundoPlano() async {
    final notifier = ref.read(productosProvider.notifier);
    if (ref.read(productosProvider).items.isEmpty) {
      await recargarDesdeSupabase();
      return;
    }
    await notifier.recargarDesdeSupabase();
  }
}

final catalogProvider =
    StateNotifierProvider<CatalogNotifier, CatalogState>((ref) {
  return CatalogNotifier(ref);
});

// FIX 3: Nuevo Provider reactivo para el conteo de stock bajo.
// Úsalo en tu UI con `ref.watch(lowStockCountProvider)` en lugar del getter obsoleto.
final lowStockCountProvider = Provider<int>((ref) {
  final productos = ref.watch(productosProvider).items;
  return productos.where((p) => p.stock <= p.stockMinimo).length;
});