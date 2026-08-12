import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../services/sync_service.dart';

class InventoryState {
  final List<ProductoEntity> productos;
  final String filtroBusqueda;
  final String categoriaSeleccionada; // ✅ Ahora es String no nulo
  final bool soloStockBajo;
  final bool seleccionMultiple;
  final Set<int> productosSeleccionados;
  final bool isLoading;

  const InventoryState({
    this.productos = const [],
    this.filtroBusqueda = '',
    this.categoriaSeleccionada = 'Todas', // Valor por defecto
    this.soloStockBajo = false,
    this.seleccionMultiple = false,
    this.productosSeleccionados = const {},
    this.isLoading = true,
  }) : assert(categoriaSeleccionada != null, 'categoriaSeleccionada no puede ser null');

  InventoryState copyWith({
    List<ProductoEntity>? productos,
    String? filtroBusqueda,
    String? categoriaSeleccionada,
    bool? soloStockBajo,
    bool? seleccionMultiple,
    Set<int>? productosSeleccionados,
    bool? isLoading,
  }) {
    return InventoryState(
      productos: productos ?? this.productos,
      filtroBusqueda: filtroBusqueda ?? this.filtroBusqueda,
      // ✅ Forzamos 'Todas' si se pasa null
      categoriaSeleccionada: categoriaSeleccionada ?? this.categoriaSeleccionada,
      soloStockBajo: soloStockBajo ?? this.soloStockBajo,
      seleccionMultiple: seleccionMultiple ?? this.seleccionMultiple,
      productosSeleccionados: productosSeleccionados ?? this.productosSeleccionados,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<String> get categorias {
    final setCategorias = productos
        .map((p) => (p.categoria ?? '').trim())
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    return ['Todas', ...setCategorias, 'Stock Bajo'];
  }

  List<ProductoEntity> get productosFiltrados {
    // ✅ categoriaSeleccionada nunca es null, pero por seguridad usamos 'Todas' si acaso
    final categoriaActual = categoriaSeleccionada;

    return productos.where((p) {
      final nombre = (p.nombre ?? '').toLowerCase();
      final codigo = (p.codigoBarras ?? '').toLowerCase();
      final busqueda = filtroBusqueda.toLowerCase().trim();
      final coincideTexto = nombre.contains(busqueda) || codigo.contains(busqueda);

      final categoriaProducto = (p.categoria ?? '').trim();
      final coincideCategoria = categoriaActual == 'Todas' ||
          (categoriaActual == 'Stock Bajo' && p.stock <= p.stockMinimo) ||
          (categoriaActual != 'Stock Bajo' && categoriaProducto == categoriaActual);

      final coincideStockBajo = !soloStockBajo || (p.stock <= p.stockMinimo);

      return coincideTexto && coincideCategoria && coincideStockBajo;
    }).toList();
  }

  int get cantidadSeleccionados => productosSeleccionados.length;
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

  InventoryNotifier() : super(const InventoryState()) {
    cargarInventario();
  }

  Future<void> cargarInventario() async {
    state = state.copyWith(isLoading: true);
    try {
      final productos = await _isarService.obtenerProductos();
      state = state.copyWith(
        productos: productos,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void setFiltroBusqueda(String filtro) {
    state = state.copyWith(filtroBusqueda: filtro);
  }

  void setCategoria(String categoria) {
    // ✅ Aseguramos que nunca sea null o vacío
    state = state.copyWith(
      categoriaSeleccionada: (categoria ?? 'Todas').trim().isEmpty ? 'Todas' : categoria.trim(),
    );
  }

  void setSoloStockBajo(bool valor) {
    state = state.copyWith(soloStockBajo: valor);
  }

  void toggleSeleccionProducto(int productoId) {
    final nuevos = Set<int>.from(state.productosSeleccionados);
    if (nuevos.contains(productoId)) {
      nuevos.remove(productoId);
    } else {
      nuevos.add(productoId);
    }
    state = state.copyWith(
      productosSeleccionados: nuevos,
      seleccionMultiple: nuevos.isNotEmpty,
    );
  }

  void limpiarSeleccion() {
    state = state.copyWith(
      productosSeleccionados: {},
      seleccionMultiple: false,
    );
  }

  Future<void> recargarDesdeSupabase() async {
    try {
      await _syncService.descargarProductosDesdeSupabase();
      await cargarInventario();
    } catch (e) {
      rethrow;
    }
  }

  List<ProductoEntity> getProductosSeleccionados() {
    return state.productos.where((p) => state.productosSeleccionados.contains(p.id)).toList();
  }
}

final inventoryProvider = StateNotifierProvider<InventoryNotifier, InventoryState>((ref) {
  return InventoryNotifier();
});