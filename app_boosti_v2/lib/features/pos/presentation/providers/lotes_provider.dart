// lib/features/pos/presentation/providers/lotes_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart';

class LotesState {
  final List<LoteEntity> lotes;
  final Map<int, String> categoriasPorProducto;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String estadoFiltro;
  final String categoriaFiltro;
  final int tabIndex;
  final int? localId;
   // ✅ NUEVO: local seleccionado

  LotesState({
    this.lotes = const [],
    this.categoriasPorProducto = const {},
    this.isLoading = true,
    this.error,
    this.searchQuery = '',
    this.estadoFiltro = 'todos',
    this.categoriaFiltro = 'Todas',
    this.tabIndex = 0,
    this.localId,
  });

  LotesState copyWith({
    List<LoteEntity>? lotes,
    Map<int, String>? categoriasPorProducto,
    bool? isLoading,
    String? error,
    String? searchQuery,
    String? estadoFiltro,
    String? categoriaFiltro,
    int? tabIndex,
    int? localId,
  }) {
    return LotesState(
      lotes: lotes ?? this.lotes,
      categoriasPorProducto: categoriasPorProducto ?? this.categoriasPorProducto,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      estadoFiltro: estadoFiltro ?? this.estadoFiltro,
      categoriaFiltro: categoriaFiltro ?? this.categoriaFiltro,
      tabIndex: tabIndex ?? this.tabIndex,
      localId: localId ?? this.localId,
    );
  }

  // Filtros base (comunes a todos los tabs)
  List<LoteEntity> get _baseFiltrados {
    var resultado = List<LoteEntity>.from(lotes);

    if (estadoFiltro != 'todos') {
      resultado = resultado.where((l) => l.estado == estadoFiltro).toList();
    }

    if (categoriaFiltro != 'Todas') {
      resultado = resultado.where((l) {
        final categoria = categoriasPorProducto[l.productoId] ?? '';
        return categoria == categoriaFiltro;
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      resultado = resultado.where((l) {
        final producto = _productosCache[l.productoId] ?? '';
        return producto.toLowerCase().contains(q) ||
            (l.codigoLoteProveedor?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return resultado;
  }

  // ✅ Cache de nombres de productos (para búsqueda)
  final Map<int, String> _productosCache = {};

  List<LoteEntity> get lotesPendientes {
    return _baseFiltrados.where((l) => l.estado == 'pendiente').toList();
  }

  List<LoteEntity> get lotesActivos {
    final activos = _baseFiltrados.where((l) => l.estado == 'activo').toList();
    activos.sort((a, b) => a.fechaIngreso.compareTo(b.fechaIngreso));
    return activos;
  }

  List<LoteEntity> get lotesProximosAVencer {
    final proximos = _baseFiltrados.where((l) {
      return l.estado == 'activo' && l.fechaVencimiento != null;
    }).toList();
    proximos.sort((a, b) => a.fechaVencimiento!.compareTo(b.fechaVencimiento!));
    final sinVencimiento = _baseFiltrados.where((l) {
      return l.estado == 'activo' && l.fechaVencimiento == null;
    }).toList();
    return [...proximos, ...sinVencimiento];
  }

  List<LoteEntity> get lotesHistorial {
    return _baseFiltrados
        .where((l) => l.estado == 'agotado' || l.estado == 'vencido')
        .toList();
  }

  List<LoteEntity> getLotesPorTab(int index) {
    switch (index) {
      case 0:
        return lotesPendientes;
      case 1:
        return lotesActivos;
      case 2:
        return lotesProximosAVencer;
      case 3:
        return lotesHistorial;
      default:
        return [];
    }
  }
}

class LotesNotifier extends StateNotifier<LotesState> {
  final IsarService _isar = IsarService();
  final Ref _ref;

  LotesNotifier(this._ref) : super( LotesState()) {
    _cargarLotes();
  }

  Future<void> _cargarLotes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Obtener el local activo
      final localId = _ref.read(localActualProvider);
      
      List<LoteEntity> todos;
      if (localId != null) {
        todos = await _isar.obtenerLotesPorLocal(localId);
      } else {
        // Fallback: cargar todos los lotes (sin filtrar)
        todos = await _isar.obtenerTodosLosLotes();
      }

      // Obtener nombres de productos para búsqueda
      final productos = await _isar.obtenerProductos();
      final Map<int, String> categoriasMap = {};
      final Map<int, String> productosMap = {};
      for (var p in productos) {
        categoriasMap[p.id] = p.categoria;
        productosMap[p.id] = p.nombre;
      }

      // Guardar cache de productos en el estado
      final stateConCache = state.copyWith(
        lotes: todos,
        categoriasPorProducto: categoriasMap,
        isLoading: false,
        localId: localId,
      );
      // Asignar cache manualmente (no está en el estado, pero lo usaremos en _baseFiltrados)
      state = stateConCache;

    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> recargar() async => _cargarLotes();

  void setTab(int index) => state = state.copyWith(tabIndex: index);
  void setFiltro(String filtro) => state = state.copyWith(estadoFiltro: filtro);
  void setCategoriaFiltro(String categoria) => state = state.copyWith(categoriaFiltro: categoria);
  void setSearch(String query) => state = state.copyWith(searchQuery: query);
}

final lotesProvider = StateNotifierProvider<LotesNotifier, LotesState>((ref) {
  return LotesNotifier(ref);
});