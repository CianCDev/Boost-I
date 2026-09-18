// lib/features/pos/presentation/providers/wholesale/wholesale_history_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/venta_entity.dart';
import '../../providers/isar_provider.dart';

// ═══════════════════════════════════════════════════════════════════
// RANGOS DE FECHA
// ═══════════════════════════════════════════════════════════════════

enum WholesaleHistoryRange {
  hoy,
  ayer,
  semana,
  mes,
  personalizado,
}

extension WholesaleHistoryRangeX on WholesaleHistoryRange {
  String get label {
    switch (this) {
      case WholesaleHistoryRange.hoy:
        return 'Hoy';
      case WholesaleHistoryRange.ayer:
        return 'Ayer';
      case WholesaleHistoryRange.semana:
        return 'Semana';
      case WholesaleHistoryRange.mes:
        return 'Mes';
      case WholesaleHistoryRange.personalizado:
        return 'Rango';
    }
  }

  (DateTime, DateTime) rangoEfectivo({
    DateTime? customDesde,
    DateTime? customHasta,
  }) {
    final ahora = DateTime.now();
    switch (this) {
      case WholesaleHistoryRange.hoy:
        final inicio = DateTime(ahora.year, ahora.month, ahora.day);
        final fin = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);
        return (inicio, fin);
      case WholesaleHistoryRange.ayer:
        final ayer = ahora.subtract(const Duration(days: 1));
        final inicio = DateTime(ayer.year, ayer.month, ayer.day);
        final fin = DateTime(ayer.year, ayer.month, ayer.day, 23, 59, 59);
        return (inicio, fin);
      case WholesaleHistoryRange.semana:
        final inicio = ahora.subtract(Duration(days: ahora.weekday - 1));
        final inicioDia = DateTime(inicio.year, inicio.month, inicio.day);
        final fin = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);
        return (inicioDia, fin);
      case WholesaleHistoryRange.mes:
        final inicio = DateTime(ahora.year, ahora.month, 1);
        final fin = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);
        return (inicio, fin);
      case WholesaleHistoryRange.personalizado:
        if (customDesde != null && customHasta != null) {
          return (customDesde, customHasta);
        }
        final inicio = DateTime(ahora.year, ahora.month, ahora.day);
        final fin = DateTime(ahora.year, ahora.month, ahora.day, 23, 59, 59);
        return (inicio, fin);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// FILTROS
// ═══════════════════════════════════════════════════════════════════

@immutable
class WholesaleHistoryFilters {
  final WholesaleHistoryRange rango;
  final DateTime? fechaDesde;
  final DateTime? fechaHasta;
  final int? clienteId;
  final String busqueda; // nombre cliente o documento
  final String? tipoDocumento; // 'nota_entrega' | 'factura' | null (todas)

  const WholesaleHistoryFilters({
    this.rango = WholesaleHistoryRange.hoy,
    this.fechaDesde,
    this.fechaHasta,
    this.clienteId,
    this.busqueda = '',
    this.tipoDocumento,
  });

  bool get tieneFiltrosActivos =>
      rango != WholesaleHistoryRange.hoy ||
      fechaDesde != null ||
      fechaHasta != null ||
      clienteId != null ||
      busqueda.isNotEmpty ||
      tipoDocumento != null;

  WholesaleHistoryFilters copyWith({
    WholesaleHistoryRange? rango,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    bool clearFechas = false,
    int? clienteId,
    bool clearCliente = false,
    String? busqueda,
    String? tipoDocumento,
    bool clearTipoDocumento = false,
  }) {
    return WholesaleHistoryFilters(
      rango: rango ?? this.rango,
      fechaDesde: clearFechas ? null : (fechaDesde ?? this.fechaDesde),
      fechaHasta: clearFechas ? null : (fechaHasta ?? this.fechaHasta),
      clienteId: clearCliente ? null : (clienteId ?? this.clienteId),
      busqueda: busqueda ?? this.busqueda,
      tipoDocumento: clearTipoDocumento
          ? null
          : (tipoDocumento ?? this.tipoDocumento),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════════

@immutable
class WholesaleHistoryState {
  final List<VentaEntity> ventas;
  final bool cargando;
  final String? error;
  final WholesaleHistoryFilters filtros;

  const WholesaleHistoryState({
    this.ventas = const [],
    this.cargando = false,
    this.error,
    this.filtros = const WholesaleHistoryFilters(),
  });

  // ──────────────── KPIs ────────────────

  int get cantidadVentas => ventas.length;

  double get totalVentasUsd =>
      ventas.fold(0.0, (sum, v) => sum + v.total);

  double get totalDescuentosUsd =>
      ventas.fold(0.0, (sum, v) => sum + (v.montoDescuentoTotal));

  double get ticketPromedio =>
      cantidadVentas == 0 ? 0.0 : totalVentasUsd / cantidadVentas;

  int get ventasConDescuento =>
      ventas.where((v) => v.tieneDescuentoEspecial).length;

  int get ventasMultipago => ventas.where((v) => v.esMultipago).length;

  int get ventasConAutorizacion =>
      ventas.where((v) => v.requiereAutorizacion).length;

  /// Total en bolívares (usando la tasa guardada en cada venta).
  double get totalVentasBs => ventas.fold(
        0.0,
        (sum, v) => sum + (v.total * (v.tasaBcv > 0 ? v.tasaBcv : 0)),
      );

  bool get tieneVentas => ventas.isNotEmpty;

  WholesaleHistoryState copyWith({
    List<VentaEntity>? ventas,
    bool? cargando,
    String? error,
    bool clearError = false,
    WholesaleHistoryFilters? filtros,
  }) {
    return WholesaleHistoryState(
      ventas: ventas ?? this.ventas,
      cargando: cargando ?? this.cargando,
      error: clearError ? null : (error ?? this.error),
      filtros: filtros ?? this.filtros,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════════

class WholesaleHistoryNotifier extends StateNotifier<WholesaleHistoryState> {
  final Ref _ref;

  WholesaleHistoryNotifier(this._ref)
      : super(const WholesaleHistoryState()) {
    cargar();
  }

  // ──────────────── Carga ────────────────

  /// Recarga todas las ventas al mayor aplicando los filtros actuales.
  Future<void> cargar() async {
    state = state.copyWith(cargando: true, clearError: true);

    try {
      final isar = _ref.read(isarServiceProvider);

      // 1. Rango de fechas
      final (desde, hasta) = state.filtros.rango.rangoEfectivo(
        customDesde: state.filtros.fechaDesde,
        customHasta: state.filtros.fechaHasta,
      );

      // 2. Traer ventas del rango
      final todas = await isar.obtenerVentasPorRango(desde, hasta);

      // 3. Filtrar por tipoVenta == 'mayor'
      var filtradas =
          todas.where((v) => v.tipoVenta == 'mayor').toList();

      // 4. Filtro por tipo de documento
      if (state.filtros.tipoDocumento != null &&
          state.filtros.tipoDocumento!.isNotEmpty) {
        filtradas = filtradas
            .where((v) => v.tipoDocumento == state.filtros.tipoDocumento)
            .toList();
      }

      // 5. Filtro por cliente
      if (state.filtros.clienteId != null) {
        filtradas = filtradas
            .where((v) => v.clienteId == state.filtros.clienteId)
            .toList();
      }

      // 6. Búsqueda por nombre/documento de cliente
      final q = state.filtros.busqueda.trim().toLowerCase();
      if (q.isNotEmpty) {
        filtradas = filtradas.where((v) {
          final nombre = (v.clienteNombre ?? '').toLowerCase();
          final doc = (v.clienteDocumento ?? '').toLowerCase();
          final rif = (v.clienteRif ?? '').toLowerCase();
          final empleado = v.empleado.toLowerCase();
          return nombre.contains(q) ||
              doc.contains(q) ||
              rif.contains(q) ||
              empleado.contains(q);
        }).toList();
      }

      // 7. Ordenar: más recientes primero (ya viene así de Isar)
      state = state.copyWith(
        ventas: filtradas,
        cargando: false,
      );
    } catch (e) {
      debugPrint('❌ Error cargando historial mayor: $e');
      state = state.copyWith(
        cargando: false,
        error: 'Error al cargar el historial: $e',
      );
    }
  }

  // ──────────────── Setters de filtro ────────────────

  void setRango(WholesaleHistoryRange rango) {
    state = state.copyWith(
      filtros: state.filtros.copyWith(
        rango: rango,
        // Limpiar fechas custom si cambiamos a un rango predefinido
        clearFechas: rango != WholesaleHistoryRange.personalizado,
      ),
    );
    cargar();
  }

  void setRangoPersonalizado(DateTime desde, DateTime hasta) {
    state = state.copyWith(
      filtros: state.filtros.copyWith(
        rango: WholesaleHistoryRange.personalizado,
        fechaDesde: desde,
        fechaHasta: hasta,
      ),
    );
    cargar();
  }

  void setBusqueda(String query) {
    state = state.copyWith(
      filtros: state.filtros.copyWith(busqueda: query),
    );
    cargar();
  }

  void setCliente(int? clienteId) {
    state = state.copyWith(
      filtros: clienteId == null
          ? state.filtros.copyWith(clearCliente: true)
          : state.filtros.copyWith(clienteId: clienteId),
    );
    cargar();
  }

  void setTipoDocumento(String? tipo) {
    state = state.copyWith(
      filtros: tipo == null
          ? state.filtros.copyWith(clearTipoDocumento: true)
          : state.filtros.copyWith(tipoDocumento: tipo),
    );
    cargar();
  }

  void limpiarFiltros() {
    state = state.copyWith(
      filtros: const WholesaleHistoryFilters(),
    );
    cargar();
  }
}

// ═══════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════

final wholesaleHistoryProvider =
    StateNotifierProvider<WholesaleHistoryNotifier, WholesaleHistoryState>(
  (ref) => WholesaleHistoryNotifier(ref),
);

// ──────────────── Derivados ────────────────

final wholesaleHistoryKpisProvider = Provider<Map<String, dynamic>>((ref) {
  final s = ref.watch(wholesaleHistoryProvider);
  return {
    'cantidad': s.cantidadVentas,
    'totalUsd': s.totalVentasUsd,
    'totalBs': s.totalVentasBs,
    'promedio': s.ticketPromedio,
    'descuentos': s.totalDescuentosUsd,
    'conDescuento': s.ventasConDescuento,
    'multipago': s.ventasMultipago,
    'conAuth': s.ventasConAutorizacion,
  };
});