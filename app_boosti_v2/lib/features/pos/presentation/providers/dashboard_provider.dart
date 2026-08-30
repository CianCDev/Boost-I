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

  // ============================================================
  // 🆕 GETTERS PARA VARIACIONES ESPECÍFICAS
  // ============================================================

  /// Variación de Ventas Hoy vs Ayer
  double get variacionHoy {
    final dias = state.ventasPorDia;
    if (dias.length < 2) return 0.0;
    final hoy = dias.last; // último día
    final ayer = dias[dias.length - 2]; // penúltimo día
    final totalHoy = (hoy['total'] as num).toDouble();
    final totalAyer = (ayer['total'] as num).toDouble();
    if (totalAyer == 0) return 0.0;
    return ((totalHoy - totalAyer) / totalAyer) * 100;
  }

  /// Variación de Ventas Semana vs Semana Anterior
  double get variacionSemana {
    final dias = state.ventasPorDia;
    if (dias.length < 14) return 0.0;
    final semanaActual = dias.sublist(dias.length - 7);
    final semanaAnterior = dias.sublist(dias.length - 14, dias.length - 7);
    final totalActual = semanaActual.fold(0.0, (sum, d) => sum + (d['total'] as num).toDouble());
    final totalAnterior = semanaAnterior.fold(0.0, (sum, d) => sum + (d['total'] as num).toDouble());
    if (totalAnterior == 0) return 0.0;
    return ((totalActual - totalAnterior) / totalAnterior) * 100;
  }

  /// Variación de Ventas Mes vs Mes Anterior
  double get variacionMes {
    // Para simplificar, usamos los datos disponibles (suponiendo 30 días)
    final dias = state.ventasPorDia;
    if (dias.length < 60) return 0.0;
    final mesActual = dias.sublist(dias.length - 30);
    final mesAnterior = dias.sublist(dias.length - 60, dias.length - 30);
    final totalActual = mesActual.fold(0.0, (sum, d) => sum + (d['total'] as num).toDouble());
    final totalAnterior = mesAnterior.fold(0.0, (sum, d) => sum + (d['total'] as num).toDouble());
    if (totalAnterior == 0) return 0.0;
    return ((totalActual - totalAnterior) / totalAnterior) * 100;
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