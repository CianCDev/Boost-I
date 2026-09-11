// lib/features/pos/presentation/providers/lotes_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';

class LotesState {
  final List<LoteEntity> lotes;
  final Map<int, String> categoriasPorProducto;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final String estadoFiltro;
  final String categoriaFiltro;
  final int tabIndex;

  const LotesState({
    this.lotes = const [],
    this.categoriasPorProducto = const {},
    this.isLoading = true,
    this.error,
    this.searchQuery = '',
    this.estadoFiltro = 'todos',
    this.categoriaFiltro = 'Todas',
    this.tabIndex = 0,
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
    );
  }

  // Filtro base (común a todos los tabs)
  List<LoteEntity> get _baseFiltrados {
    var resultado = List<LoteEntity>.from(lotes);

    // Filtro por estado (si no es 'todos')
    if (estadoFiltro != 'todos') {
      resultado = resultado.where((l) => l.estado == estadoFiltro).toList();
    }

    // Filtro por categoría
    if (categoriaFiltro != 'Todas') {
      resultado = resultado.where((l) {
        final categoria = categoriasPorProducto[l.productoId] ?? '';
        return categoria == categoriaFiltro;
      }).toList();
    }

    // Filtro por búsqueda
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      resultado = resultado.where((l) {
        return l.id.toString().contains(q) ||
            (l.codigoBarrasLote?.toLowerCase().contains(q) ?? false);
      }).toList();
    }

    return resultado;
  }

  // Lotes pendientes
  List<LoteEntity> get lotesPendientes {
    return _baseFiltrados.where((l) => l.estado == 'pendiente').toList();
  }

  // Lotes activos (ordenados por fecha de ingreso, más antiguos primero)
  List<LoteEntity> get lotesActivos {
    final activos = _baseFiltrados.where((l) => l.estado == 'activo').toList();
    activos.sort((a, b) => a.fechaIngreso.compareTo(b.fechaIngreso));
    return activos;
  }

  // Lotes próximos a vencer (ordenados por fecha de vencimiento, más cercanos primero)
  List<LoteEntity> get lotesProximosAVencer {
    final proximos = _baseFiltrados.where((l) {
      return l.estado == 'activo' && l.fechaVencimiento != null;
    }).toList();

    // Ordenar por fecha de vencimiento (los más cercanos primero)
    proximos.sort((a, b) {
      return a.fechaVencimiento!.compareTo(b.fechaVencimiento!);
    });

    // Añadir los que no tienen fecha de vencimiento al final
    final sinVencimiento = _baseFiltrados.where((l) {
      return l.estado == 'activo' && l.fechaVencimiento == null;
    }).toList();

    return [...proximos, ...sinVencimiento];
  }

  // Historial (agotados + vencidos)
  List<LoteEntity> get lotesHistorial {
    return _baseFiltrados
        .where((l) => l.estado == 'agotado' || l.estado == 'vencido')
        .toList();
  }

  // Para usar en la vista del tab según el índice
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

  String get tabName {
    switch (tabIndex) {
      case 0:
        return 'Pendientes';
      case 1:
        return 'Activos';
      case 2:
        return 'Próximos a vencer';
      case 3:
        return 'Historial';
      default:
        return '';
    }
  }
}

class LotesNotifier extends StateNotifier<LotesState> {
  final IsarService _isar = IsarService();

  LotesNotifier() : super(const LotesState()) {
    cargarLotes();
  }

  Future<void> cargarLotes() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final todos = await _isar.obtenerTodosLosLotes();
      final productos = await _isar.obtenerProductos();
      final Map<int, String> categoriasMap = {};
      for (var p in productos) {
        categoriasMap[p.id] = p.categoria;
      }
      state = state.copyWith(
        lotes: todos,
        categoriasPorProducto: categoriasMap,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setTab(int index) => state = state.copyWith(tabIndex: index);
  void setFiltro(String filtro) => state = state.copyWith(estadoFiltro: filtro);
  void setCategoriaFiltro(String categoria) => state = state.copyWith(categoriaFiltro: categoria);
  void setSearch(String query) => state = state.copyWith(searchQuery: query);
  Future<void> refresh() async => await cargarLotes();
  Future<void> recargar() async => await cargarLotes();
}

final lotesProvider = StateNotifierProvider<LotesNotifier, LotesState>((ref) {
  return LotesNotifier();
});