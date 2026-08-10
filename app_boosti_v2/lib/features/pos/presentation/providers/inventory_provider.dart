import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../services/sync_service.dart';

class InventoryState {
  final List<ProductoEntity> productos;
  final String filtroBusqueda;
  final bool soloStockBajo;
  final bool seleccionMultiple;
  final Set<int> productosSeleccionados;
  final bool isLoading;

  InventoryState({
    this.productos = const [],
    this.filtroBusqueda = '',
    this.soloStockBajo = false,
    this.seleccionMultiple = false,
    this.productosSeleccionados = const {},
    this.isLoading = true,
  });

  InventoryState copyWith({
    List<ProductoEntity>? productos,
    String? filtroBusqueda,
    bool? soloStockBajo,
    bool? seleccionMultiple,
    Set<int>? productosSeleccionados,
    bool? isLoading,
  }) {
    return InventoryState(
      productos: productos ?? this.productos,
      filtroBusqueda: filtroBusqueda ?? this.filtroBusqueda,
      soloStockBajo: soloStockBajo ?? this.soloStockBajo,
      seleccionMultiple: seleccionMultiple ?? this.seleccionMultiple,
      productosSeleccionados: productosSeleccionados ?? this.productosSeleccionados,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<ProductoEntity> get productosFiltrados {
    return productos.where((p) {
      final coincideTexto = p.nombre.toLowerCase().contains(filtroBusqueda.toLowerCase()) ||
          p.codigoBarras.contains(filtroBusqueda);
      final coincideStockBajo = !soloStockBajo || (p.stock <= p.stockMinimo);
      return coincideTexto && coincideStockBajo;
    }).toList();
  }

  int get cantidadSeleccionados => productosSeleccionados.length;
}

class InventoryNotifier extends StateNotifier<InventoryState> {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

  InventoryNotifier() : super(InventoryState()) {
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