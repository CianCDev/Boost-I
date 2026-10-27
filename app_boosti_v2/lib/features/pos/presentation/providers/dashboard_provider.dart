import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/producto_entity.dart';

// ============================================================
// PROVIDER
// ============================================================
final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});

// ============================================================
// ESTADO
// ============================================================
class DashboardState {
  final bool isLoading;
  final String? error;
  final double totalHoy;
  final double totalSemana;
  final double totalMes;
  final double totalGastosMes;
  final double variacion; // vs ayer (general)
  final int ventasHoy;
  final List<VentaEntity> ultimasVentas;
  final List<Map<String, dynamic>> topProductos;
  final List<ProductoEntity> stockBajo;
  final Map<String, double> ventasPorEmpleado;
  final List<Map<String, dynamic>> ventasPorDia;
  final DateTime ultimaActualizacion;

  // ── Comparativas (para variaciones reales) ──
  final double totalAyer;
  final double totalSemanaAnterior;
  final double totalMesAnterior;
  final double gastosHoy;

  // ── Tickets ──
  final int ventasMes;
  final double ticketPromedioHoy;
  final double ticketPromedioMes;

  // ── Distribuciones ──
  final List<Map<String, dynamic>> ventasPorHora;
  final Map<String, Map<String, double>> ventasPorMetodoPago;

  // ── Calidad de la operación ──
  final List<ProductoEntity> productosSinRotacion;
  final int anulacionesMes;
  final double montoAnuladoMes;

  // ── Salón (modo restaurante) ──
  final int mesasTotales;
  final int mesasOcupadas;
  final int comandasAbiertas;

  DashboardState({
    this.isLoading = false,
    this.error,
    this.totalHoy = 0,
    this.totalSemana = 0,
    this.totalMes = 0,
    this.totalGastosMes = 0,
    this.variacion = 0,
    this.ventasHoy = 0,
    this.ultimasVentas = const [],
    this.topProductos = const [],
    this.stockBajo = const [],
    this.ventasPorEmpleado = const {},
    this.ventasPorDia = const [],
    this.totalAyer = 0,
    this.totalSemanaAnterior = 0,
    this.totalMesAnterior = 0,
    this.gastosHoy = 0,
    this.ventasMes = 0,
    this.ticketPromedioHoy = 0,
    this.ticketPromedioMes = 0,
    this.ventasPorHora = const [],
    this.ventasPorMetodoPago = const {},
    this.productosSinRotacion = const [],
    this.anulacionesMes = 0,
    this.montoAnuladoMes = 0,
    this.mesasTotales = 0,
    this.mesasOcupadas = 0,
    this.comandasAbiertas = 0,
    DateTime? ultimaActualizacion,
  }) : ultimaActualizacion = ultimaActualizacion ?? DateTime.now();

  DashboardState copyWith({
    bool? isLoading,
    String? error,
    double? totalHoy,
    double? totalSemana,
    double? totalMes,
    double? totalGastosMes,
    double? variacion,
    int? ventasHoy,
    List<VentaEntity>? ultimasVentas,
    List<Map<String, dynamic>>? topProductos,
    List<ProductoEntity>? stockBajo,
    Map<String, double>? ventasPorEmpleado,
    List<Map<String, dynamic>>? ventasPorDia,
    double? totalAyer,
    double? totalSemanaAnterior,
    double? totalMesAnterior,
    double? gastosHoy,
    int? ventasMes,
    double? ticketPromedioHoy,
    double? ticketPromedioMes,
    List<Map<String, dynamic>>? ventasPorHora,
    Map<String, Map<String, double>>? ventasPorMetodoPago,
    List<ProductoEntity>? productosSinRotacion,
    int? anulacionesMes,
    double? montoAnuladoMes,
    int? mesasTotales,
    int? mesasOcupadas,
    int? comandasAbiertas,
    DateTime? ultimaActualizacion,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      totalHoy: totalHoy ?? this.totalHoy,
      totalSemana: totalSemana ?? this.totalSemana,
      totalMes: totalMes ?? this.totalMes,
      totalGastosMes: totalGastosMes ?? this.totalGastosMes,
      variacion: variacion ?? this.variacion,
      ventasHoy: ventasHoy ?? this.ventasHoy,
      ultimasVentas: ultimasVentas ?? this.ultimasVentas,
      topProductos: topProductos ?? this.topProductos,
      stockBajo: stockBajo ?? this.stockBajo,
      ventasPorEmpleado: ventasPorEmpleado ?? this.ventasPorEmpleado,
      ventasPorDia: ventasPorDia ?? this.ventasPorDia,
      totalAyer: totalAyer ?? this.totalAyer,
      totalSemanaAnterior: totalSemanaAnterior ?? this.totalSemanaAnterior,
      totalMesAnterior: totalMesAnterior ?? this.totalMesAnterior,
      gastosHoy: gastosHoy ?? this.gastosHoy,
      ventasMes: ventasMes ?? this.ventasMes,
      ticketPromedioHoy: ticketPromedioHoy ?? this.ticketPromedioHoy,
      ticketPromedioMes: ticketPromedioMes ?? this.ticketPromedioMes,
      ventasPorHora: ventasPorHora ?? this.ventasPorHora,
      ventasPorMetodoPago:
          ventasPorMetodoPago ?? this.ventasPorMetodoPago,
      productosSinRotacion:
          productosSinRotacion ?? this.productosSinRotacion,
      anulacionesMes: anulacionesMes ?? this.anulacionesMes,
      montoAnuladoMes: montoAnuladoMes ?? this.montoAnuladoMes,
      mesasTotales: mesasTotales ?? this.mesasTotales,
      mesasOcupadas: mesasOcupadas ?? this.mesasOcupadas,
      comandasAbiertas: comandasAbiertas ?? this.comandasAbiertas,
      ultimaActualizacion: ultimaActualizacion ?? DateTime.now(),
    );
  }
}

// ============================================================
// NOTIFIER
// ============================================================
class DashboardNotifier extends StateNotifier<DashboardState> {
  final IsarService _isar = IsarService();

  DashboardNotifier() : super(DashboardState());

  // ============================================================
  // GETTERS PARA FORMATEO DE MONEDA
  // ============================================================

  String get totalHoyFormateado => _formatearMoneda(state.totalHoy);
  String get totalSemanaFormateado => _formatearMoneda(state.totalSemana);
  String get totalMesFormateado => _formatearMoneda(state.totalMes);
  String get totalGastosMesFormateado => _formatearMoneda(state.totalGastosMes);
  String get gastosHoyFormateado => _formatearMoneda(state.gastosHoy);
  String get ticketPromedioHoyFormateado =>
      _formatearMoneda(state.ticketPromedioHoy);
  String get ticketPromedioMesFormateado =>
      _formatearMoneda(state.ticketPromedioMes);
  String get montoAnuladoMesFormateado =>
      _formatearMoneda(state.montoAnuladoMes);

  // ============================================================
  // VARIACIONES
  // ============================================================

  /// Variación de Ventas Hoy vs Ayer.
  double get variacionHoy => _pct(state.totalHoy, state.totalAyer);

  /// Variación de la semana actual vs la semana anterior.
  double get variacionSemana =>
      _pct(state.totalSemana, state.totalSemanaAnterior);

  /// Variación del mes actual vs el mes anterior.
  double get variacionMes => _pct(state.totalMes, state.totalMesAnterior);

  /// Porcentaje de cambio. Contra base 0 no hay porcentaje posible:
  /// si hubo ventas hoy y ayer no, se informa +100% (no 0%, que mentiría
  /// diciendo "sin cambios").
  double _pct(double actual, double anterior) {
    if (anterior <= 0) return actual > 0 ? 100.0 : 0.0;
    return ((actual - anterior) / anterior) * 100;
  }

  // ============================================================
  // GETTERS PARA ICONOS Y COLORES DE VARIACIÓN
  // ============================================================

  String get variacionFormateada {
    final v = state.variacion;
    if (v == 0) return '0%';
    return '${v > 0 ? '+' : ''}${v.toStringAsFixed(1)}%';
  }

  IconData get variacionIcon {
    final v = state.variacion;
    if (v > 0) return Icons.trending_up_rounded;
    if (v < 0) return Icons.trending_down_rounded;
    return Icons.trending_flat_rounded;
  }

  Color get variacionColor {
    final v = state.variacion;
    if (v > 0) return Colors.green;
    if (v < 0) return Colors.red;
    return Colors.grey;
  }

  // ============================================================
  // INDICADORES DERIVADOS
  // ============================================================

  /// Hora del día con mayor facturación (0-23), o null si no hubo ventas.
  int? get horaPico {
    int? mejorHora;
    double mejorTotal = 0;
    for (final fila in state.ventasPorHora) {
      final total = (fila['total'] as num?)?.toDouble() ?? 0;
      final hora = fila['hora'] as int?;
      if (hora != null && total > mejorTotal) {
        mejorTotal = total;
        mejorHora = hora;
      }
    }
    return mejorHora;
  }

  /// "14:00 – 15:00" o "Sin ventas todavía".
  String get horaPicoFormateada {
    final h = horaPico;
    if (h == null) return 'Sin ventas todavía';
    return '${h.toString().padLeft(2, '0')}:00 – '
        '${(h + 1).toString().padLeft(2, '0')}:00';
  }

  /// Método de pago con mayor facturación del mes, o null.
  String? get metodoPagoTop {
    String? mejor;
    double mejorTotal = 0;
    state.ventasPorMetodoPago.forEach((nombre, datos) {
      final total = (datos['total'] ?? 0).toDouble();
      if (total > mejorTotal) {
        mejorTotal = total;
        mejor = nombre;
      }
    });
    return mejor;
  }

  /// Ocupación del salón en porcentaje (0-100).
  double get ocupacionSalon {
    if (state.mesasTotales <= 0) return 0;
    return (state.mesasOcupadas / state.mesasTotales) * 100;
  }

  bool get haySalon => state.mesasTotales > 0;

  // ============================================================
  // MÉTODOS PÚBLICOS
  // ============================================================

  Future<void> cargarDatos() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final resumen = await _isar.obtenerResumenDashboard();

      state = state.copyWith(
        isLoading: false,
        totalHoy: resumen['totalHoy'] ?? 0,
        totalSemana: resumen['totalSemana'] ?? 0,
        totalMes: resumen['totalMes'] ?? 0,
        totalGastosMes: resumen['totalGastosMes'] ?? 0,
        variacion: resumen['variacion'] ?? 0,
        ventasHoy: resumen['ventasHoy'] ?? 0,
        ultimasVentas: resumen['ultimasVentas'] ?? [],
        topProductos: resumen['topProductos'] ?? [],
        stockBajo: resumen['stockBajo'] ?? [],
        ventasPorEmpleado: resumen['ventasPorEmpleado'] ?? {},
        ventasPorDia: resumen['ventasPorDia'] ?? [],
        totalAyer: resumen['totalAyer'] ?? 0,
        totalSemanaAnterior: resumen['totalSemanaAnterior'] ?? 0,
        totalMesAnterior: resumen['totalMesAnterior'] ?? 0,
        gastosHoy: resumen['gastosHoy'] ?? 0,
        ventasMes: resumen['ventasMes'] ?? 0,
        ticketPromedioHoy: resumen['ticketPromedioHoy'] ?? 0,
        ticketPromedioMes: resumen['ticketPromedioMes'] ?? 0,
        ventasPorHora: (resumen['ventasPorHora'] as List?)
                ?.cast<Map<String, dynamic>>() ??
            const [],
        ventasPorMetodoPago: (resumen['ventasPorMetodoPago'] as Map?)
                ?.cast<String, Map<String, double>>() ??
            const {},
        productosSinRotacion: (resumen['productosSinRotacion'] as List?)
                ?.cast<ProductoEntity>() ??
            const [],
        anulacionesMes: resumen['anulacionesMes'] ?? 0,
        montoAnuladoMes: resumen['montoAnuladoMes'] ?? 0,
        mesasTotales: resumen['mesasTotales'] ?? 0,
        mesasOcupadas: resumen['mesasOcupadas'] ?? 0,
        comandasAbiertas: resumen['comandasAbiertas'] ?? 0,
        ultimaActualizacion: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refrescar() async {
    await cargarDatos();
  }

  // ============================================================
  // MÉTODOS PRIVADOS
  // ============================================================

  String _formatearMoneda(double valor) {
    final formato = NumberFormat.currency(
      locale: 'es_US',
      symbol: '\$',
      decimalDigits: 2,
    );
    return formato.format(valor);
  }
}
