import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../services/sync_service.dart';

// Estado del catálogo
class CatalogState {
  final List<ProductoEntity> productos;
  final List<String> categorias;
  final String categoriaSeleccionada;
  final String busqueda;
  final List<ProductoEntity> productosFiltrados;
  final bool isLoading;

  CatalogState({
    this.productos = const [],
    this.categorias = const ['Todas', 'Stock Bajo'],
    this.categoriaSeleccionada = 'Todas',
    this.busqueda = '',
    this.productosFiltrados = const [],
    this.isLoading = true,
  });

  CatalogState copyWith({
    List<ProductoEntity>? productos,
    List<String>? categorias,
    String? categoriaSeleccionada,
    String? busqueda,
    List<ProductoEntity>? productosFiltrados,
    bool? isLoading,
  }) {
    return CatalogState(
      productos: productos ?? this.productos,
      categorias: categorias ?? this.categorias,
      categoriaSeleccionada: categoriaSeleccionada ?? this.categoriaSeleccionada,
      busqueda: busqueda ?? this.busqueda,
      productosFiltrados: productosFiltrados ?? this.productosFiltrados,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CatalogNotifier extends StateNotifier<CatalogState> {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

  CatalogNotifier() : super(CatalogState()) {
    _cargarProductos();
  }

  // Cargar productos desde Isar y actualizar estado
  Future<void> _cargarProductos() async {
    try {
      state = state.copyWith(isLoading: true);
      final productos = await _isarService.obtenerProductos();
      final setCategorias = productos
          .map((p) => p.categoria.trim())
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      final categorias = ['Todas', ...setCategorias, 'Stock Bajo'];

      state = state.copyWith(
        productos: productos,
        categorias: categorias,
        isLoading: false,
      );
      _aplicarFiltros();
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  // Filtrar productos según búsqueda y categoría
  void _aplicarFiltros() {
    final query = state.busqueda.toLowerCase().trim();
    final filtrados = state.productos.where((prod) {
      final coincideNombre = prod.nombre.toLowerCase().contains(query);
      final coincideCodigo = prod.codigoBarras.toLowerCase().contains(query);
      bool coincideCategoria = true;
      if (state.categoriaSeleccionada == 'Stock Bajo') {
        coincideCategoria = prod.stock <= prod.stockMinimo;
      } else if (state.categoriaSeleccionada != 'Todas') {
        coincideCategoria = prod.categoria.trim().toLowerCase() ==
            state.categoriaSeleccionada.toLowerCase();
      }
      return (coincideNombre || coincideCodigo) && coincideCategoria;
    }).toList();

    state = state.copyWith(productosFiltrados: filtrados);
  }

  // Cambiar categoría
  void setCategoria(String categoria) {
    if (state.categoriaSeleccionada == categoria) return;
    state = state.copyWith(categoriaSeleccionada: categoria);
    _aplicarFiltros();
  }

  // Cambiar búsqueda
  void setBusqueda(String busqueda) {
    state = state.copyWith(busqueda: busqueda);
    _aplicarFiltros();
  }

  // Recargar desde Supabase (polling)
  Future<void> recargarDesdeSupabase() async {
    try {
      await _syncService.descargarProductosDesdeSupabase();
      await _cargarProductos();
    } catch (e) {
      rethrow;
    }
  }

  // Obtener conteo de stock bajo
  int get lowStockCount {
    return state.productos.where((p) => p.stock <= p.stockMinimo).length;
  }
}

// Provider final
final catalogProvider = StateNotifierProvider<CatalogNotifier, CatalogState>((ref) {
  return CatalogNotifier();
});