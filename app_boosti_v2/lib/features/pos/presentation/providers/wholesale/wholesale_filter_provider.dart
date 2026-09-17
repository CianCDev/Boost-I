// lib/features/pos/presentation/providers/wholesale/wholesale_filter_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/producto_entity.dart';
import '../../providers/productos_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// ENUMS DE FILTRO
// ═══════════════════════════════════════════════════════════════════

enum WholesaleStockFilter {
  todos,
  conStock,
  stockBajo,
  sinStock,
}

extension WholesaleStockFilterX on WholesaleStockFilter {
  String get label {
    switch (this) {
      case WholesaleStockFilter.todos:
        return 'Todos';
      case WholesaleStockFilter.conStock:
        return 'Con stock';
      case WholesaleStockFilter.stockBajo:
        return 'Stock bajo';
      case WholesaleStockFilter.sinStock:
        return 'Sin stock';
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════════

@immutable
class WholesaleFilterState {
  final String searchQuery;
  final String? categoriaSeleccionada;
  final WholesaleStockFilter stockFilter;

  /// Si `true`, sólo muestra productos con `permiteVentaMayor == true`.
  final bool soloPrecioMayor;

  /// Vista grid o lista.
  final bool esGrid;

  const WholesaleFilterState({
    this.searchQuery = '',
    this.categoriaSeleccionada,
    this.stockFilter = WholesaleStockFilter.todos,
    this.soloPrecioMayor = true,
    this.esGrid = true,
  });

  WholesaleFilterState copyWith({
    String? searchQuery,
    String? categoriaSeleccionada,
    bool clearCategoria = false,
    WholesaleStockFilter? stockFilter,
    bool? soloPrecioMayor,
    bool? esGrid,
  }) {
    return WholesaleFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      categoriaSeleccionada: clearCategoria
          ? null
          : (categoriaSeleccionada ?? this.categoriaSeleccionada),
      stockFilter: stockFilter ?? this.stockFilter,
      soloPrecioMayor: soloPrecioMayor ?? this.soloPrecioMayor,
      esGrid: esGrid ?? this.esGrid,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════════

class WholesaleFilterNotifier extends StateNotifier<WholesaleFilterState> {
  WholesaleFilterNotifier() : super(const WholesaleFilterState());

  void setSearch(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategoria(String? categoria) {
    if (categoria == null || categoria.isEmpty) {
      state = state.copyWith(clearCategoria: true);
    } else {
      state = state.copyWith(categoriaSeleccionada: categoria);
    }
  }

  void setStockFilter(WholesaleStockFilter filter) {
    state = state.copyWith(stockFilter: filter);
  }

  void setSoloPrecioMayor(bool valor) {
    state = state.copyWith(soloPrecioMayor: valor);
  }

  void setEsGrid(bool valor) {
    state = state.copyWith(esGrid: valor);
  }

  void reset() {
    state = const WholesaleFilterState();
  }
}

// ═══════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════

final wholesaleFilterProvider =
    StateNotifierProvider<WholesaleFilterNotifier, WholesaleFilterState>(
        (ref) => WholesaleFilterNotifier());

/// Lista completa de productos que **pueden** venderse al mayor.
///
/// Filtra por `permiteVentaMayor == true` y `activo == true`.
final wholesaleBaseProductsProvider = Provider<List<ProductoEntity>>((ref) {
  final productosState = ref.watch(productosProvider);
  return productosState.items
      .where((p) => p.activo && p.permiteVentaMayor)
      .toList();
});

/// Lista **filtrada** aplicando búsqueda + filtros del state.
final wholesaleFilteredProductsProvider = Provider<List<ProductoEntity>>((ref) {
  final base = ref.watch(wholesaleBaseProductsProvider);
  final filter = ref.watch(wholesaleFilterProvider);

  final q = filter.searchQuery.trim().toLowerCase();

  return base.where((p) {
    // ── Búsqueda ──
    if (q.isNotEmpty) {
      final coincide = p.nombre.toLowerCase().contains(q) ||
          p.codigoBarras.toLowerCase().contains(q) ||
          p.marca.toLowerCase().contains(q) ||
          p.categoria.toLowerCase().contains(q);
      if (!coincide) return false;
    }

    // ── Filtro de categoría ──
    if (filter.categoriaSeleccionada != null &&
        filter.categoriaSeleccionada!.isNotEmpty &&
        p.categoria != filter.categoriaSeleccionada) {
      return false;
    }

    // ── Filtro de stock ──
    switch (filter.stockFilter) {
      case WholesaleStockFilter.todos:
        break;
      case WholesaleStockFilter.conStock:
        if (p.stock <= 0) return false;
      case WholesaleStockFilter.stockBajo:
        if (p.stock > p.stockMinimo || p.stock <= 0) return false;
      case WholesaleStockFilter.sinStock:
        if (p.stock > 0) return false;
    }

    // ── Filtro "solo precio mayor" ──
    if (filter.soloPrecioMayor) {
      final tieneMayor = (p.precioMayor != null && p.precioMayor! > 0) ||
          (p.precioMedioMayor != null && p.precioMedioMayor! > 0);
      if (!tieneMayor) return false;
    }

    return true;
  }).toList();
});

/// Lista de categorías únicas de los productos base.
/// Ordenadas alfabéticamente.
final wholesaleCategoriesProvider = Provider<List<String>>((ref) {
  final base = ref.watch(wholesaleBaseProductsProvider);
  final set = base
      .map((p) => p.categoria)
      .where((c) => c.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return set;
});

/// Contador: productos con stock bajo entre los mayoristas.
final wholesaleLowStockCountProvider = Provider<int>((ref) {
  final base = ref.watch(wholesaleBaseProductsProvider);
  return base.where((p) => p.stock > 0 && p.stock <= p.stockMinimo).length;
});

/// Contador: productos sin stock entre los mayoristas.
final wholesaleOutOfStockCountProvider = Provider<int>((ref) {
  final base = ref.watch(wholesaleBaseProductsProvider);
  return base.where((p) => p.stock <= 0).length;
});