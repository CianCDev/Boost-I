// lib/features/pos/presentation/providers/lotes_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart';

// ============================================================
// ESTADO
// ============================================================
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
      categoriasPorProducto:
          categoriasPorProducto ?? this.categoriasPorProducto,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      estadoFiltro: estadoFiltro ?? this.estadoFiltro,
      categoriaFiltro: categoriaFiltro ?? this.categoriaFiltro,
      tabIndex: tabIndex ?? this.tabIndex,
      localId: localId ?? this.localId,
    );
  }

  // Cache interno de nombres de productos (para búsqueda)
  final Map<int, String> _productosCache = {};

  // Filtros base
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

  List<LoteEntity> get lotesPendientes {
    return _baseFiltrados.where((l) => l.estado == 'pendiente').toList();
  }

  List<LoteEntity> get lotesActivos {
    final activos = _baseFiltrados.where((l) => l.estado == 'activo').toList();
    activos.sort((a, b) => a.fechaIngreso.compareTo(b.fechaIngreso));
    return activos;
  }

  /// Lotes activos con fecha de vencimiento, ordenados por fecha ASC.
  ///
  /// Filtra `cantidadRestante > 0`: un lote ya agotado que vence manana no
  /// es una urgencia, es ruido. Mismo criterio que
  /// `IsarService.obtenerLotesActivos` y que `vencimientosProvider`.
  List<LoteEntity> get lotesProximosAVencer {
    final proximos = _baseFiltrados.where((l) {
      return l.estado == 'activo' &&
          l.fechaVencimiento != null &&
          l.cantidadRestante > 0;
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
      case 0: return lotesPendientes;
      case 1: return lotesActivos;
      case 2: return lotesProximosAVencer;
      case 3: return lotesHistorial;
      default: return [];
    }
  }
}

// ============================================================
// NOTIFIER
// ============================================================
class LotesNotifier extends StateNotifier<LotesState> {
  final IsarService _isar = IsarService();
  final Ref _ref;

  // Listener para cambios de local
  late final ProviderSubscription<int?> _localSubscription;

  LotesNotifier(this._ref) : super(LotesState()) {
    debugPrint('🔄 LotesNotifier creado, escuchando cambios de local...');
    _localSubscription = _ref.listen(localActualProvider, (previous, next) {
      debugPrint('📍 Local cambiado de $previous a $next. Recargando lotes...');
      _cargarLotes();
    });
    _cargarLotes();
  }

  @override
  void dispose() {
    _localSubscription.close();
    super.dispose();
  }

  Future<void> _cargarLotes() async {
    if (!mounted) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final localId = _ref.read(localActualProvider);
      debugPrint('🔍 Cargando lotes para localId: $localId');

      List<LoteEntity> todos;
      if (localId != null) {
        todos = await _isar.obtenerLotesPorLocal(localId);
      } else {
        todos = await _isar.obtenerTodosLosLotes();
      }

      // ⚠️ Guard tras el primer await: `dispose()` puede haber corrido.
      // Escribir `state` después de destruirse lanza.
      if (!mounted) return;

      debugPrint('📦 Lotes obtenidos: ${todos.length}');

      // Obtener nombres y categorías de productos
      final productos = await _isar.obtenerProductos();

      // ⚠️ Segundo await: mismo riesgo.
      if (!mounted) return;

      final Map<int, String> categoriasMap = {};
      final Map<int, String> productosMap = {};
      for (var p in productos) {
        categoriasMap[p.id] = p.categoria;
        productosMap[p.id] = p.nombre;
      }

      // Construir el estado final
      state.copyWith(
        lotes: todos,
        categoriasPorProducto: categoriasMap,
        isLoading: false,
        localId: localId,
      );

      // Asignar el cache manualmente (se usa en _baseFiltrados)
      // Nota: el cache está en el estado pero no se serializa, así que lo asignamos directamente
      // Para que los getters funcionen, el estado debe tener el cache.
      // Pero el cache se usa en el getter _baseFiltrados, que usa _productosCache del estado.
      // Como _productosCache es una variable de instancia de LotesState, necesitamos que se actualice.
      // Podemos hacer un método en el estado para actualizar el cache, o simplemente asignar.
      // Lo más sencillo: reemplazar el estado completo.
      state = LotesState(
        lotes: todos,
        categoriasPorProducto: categoriasMap,
        isLoading: false,
        error: null,
        searchQuery: state.searchQuery,
        estadoFiltro: state.estadoFiltro,
        categoriaFiltro: state.categoriaFiltro,
        tabIndex: state.tabIndex,
        localId: localId,
      ).._productosCache.addAll(productosMap); // ✅ Asignamos el cache al nuevo estado

      debugPrint('✅ Estado actualizado con ${state.lotes.length} lotes.');
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ Error cargando lotes: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> recargar() async {
    if (!mounted) return;
    return _cargarLotes();
  }

  void setTab(int index) => state = state.copyWith(tabIndex: index);
  void setFiltro(String filtro) => state = state.copyWith(estadoFiltro: filtro);
  void setCategoriaFiltro(String categoria) => state = state.copyWith(categoriaFiltro: categoria);
  void setSearch(String query) => state = state.copyWith(searchQuery: query);
}

// ============================================================
// PROVIDER
// ============================================================
final lotesProvider = StateNotifierProvider<LotesNotifier, LotesState>((ref) {
  return LotesNotifier(ref);
});

/// Mapa `productoId → DateTime` con el vencimiento más próximo por producto,
/// derivado de `lotesProvider.state.lotes`.
///
/// ## Reglas de filtrado
/// - `estado == 'activo'`: excluye `agotado`, `vencido` y `pendiente`.
/// - `cantidadRestante > 0`: un lote con 0 unidades que vence mañana no es
///   una urgencia, es ruido. Mismo criterio que
///   `IsarService.obtenerLotesActivos` (`isar_service.dart:4139`).
/// - `fechaVencimiento != null`.
///
/// Si un producto tiene 3 lotes y solo 1 con fecha, se usa esa. Si ninguno
/// tiene fecha, el producto no aparece en el map.
///
/// ## Coste
/// Una sola pasada O(n) sobre los lotes, memoizada por Riverpod. Las N
/// cards del catálogo hacen N lookups O(1) sobre el mismo Map, asi que el
/// costo no crece con el tamano del catalogo visible.
///
/// ## ⚠️ Invalidación
/// Se invalida solo cuando `lotesProvider` emite estado, y eso ocurre
/// unicamente en `LotesNotifier.recargar()` o al cambiar de local
/// (vía `_localSubscription`).
///
/// `TraspasoLoteDialog` llama a `invalidationProvider.invalidarStock()` y
/// **no** a `lotesProvider.recargar()`, asi que despues de una baja de lote
/// este map queda viejo hasta que el usuario entre a la pantalla de lotes.
/// PENDIENTE: agregar el `recargar()` ahi o colgar este provider de
/// `invalidationProvider`.
final vencimientosProvider = Provider<Map<int, DateTime>>((ref) {
  final lotes = ref.watch(lotesProvider).lotes;
  final Map<int, DateTime> resultado = {};
  for (final lote in lotes) {
    if (lote.estado != 'activo') continue;
    if (lote.cantidadRestante <= 0) continue;
    final fecha = lote.fechaVencimiento;
    if (fecha == null) continue;

    final actual = resultado[lote.productoId];
    if (actual == null || fecha.isBefore(actual)) {
      resultado[lote.productoId] = fecha;
    }
  }
  return resultado;
});