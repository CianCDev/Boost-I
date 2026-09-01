// lib/features/pos/presentation/providers/cash_closing_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/cash_register_service.dart';
import 'sync_provider.dart';

// ============================================================
// ESTADO
// ============================================================
class CashClosingState {
  final bool isLoading;
  final bool isSyncing;
  final String? error;
  final ResumenCorteCaja? resumen;
  final DateTime lastUpdated;

  CashClosingState({
    this.isLoading = false,
    this.isSyncing = false,
    this.error,
    this.resumen,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  CashClosingState copyWith({
    bool? isLoading,
    bool? isSyncing,
    String? error,
    ResumenCorteCaja? resumen,
    DateTime? lastUpdated,
  }) {
    return CashClosingState(
      isLoading: isLoading ?? this.isLoading,
      isSyncing: isSyncing ?? this.isSyncing,
      error: error,
      resumen: resumen ?? this.resumen,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // Getters útiles
  double get totalVentas => resumen?.totalVentas ?? 0.0;
  int get cantidadTransacciones => resumen?.cantidadTransacciones ?? 0;
  Map<String, double> get totalesPorMetodo => resumen?.totalesPorMetodo ?? {};
}

// ============================================================
// NOTIFIER
// ============================================================
class CashClosingNotifier extends StateNotifier<CashClosingState> {
  final Ref _ref;
  final CashRegisterService _cashService = CashRegisterService();

  CashClosingNotifier(this._ref) : super(CashClosingState()) {
    _cargarDatos();
  }

  // Cargar datos iniciales (con descarga previa)
  Future<void> _cargarDatos() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // 1. Sincronizar ventas desde Supabase
      final sync = _ref.read(syncServiceProvider);
      await sync.descargarVentasDesdeSupabase();

      // 2. Calcular resumen del día
      final resumen = await _cashService.calcularCorteDelDia();

      state = state.copyWith(
        isLoading: false,
        resumen: resumen,
        lastUpdated: DateTime.now(),
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Refrescar manualmente
  Future<void> refrescar() async {
    await _cargarDatos();
  }

  // Cerrar caja (acción principal)
  Future<void> cerrarCaja() async {
    if (state.resumen == null) return;

    state = state.copyWith(isSyncing: true, error: null);
    try {
      // Aquí puedes agregar lógica de cierre:
      // - Registrar el cierre en una tabla de cortes
      // - Marcar el turno como cerrado
      // - Sincronizar con Supabase
      final sync = _ref.read(syncServiceProvider);
      await sync.sincronizarTodo(); // Ejemplo: sincronizar todo

      // Refrescar datos después del cierre
      await _cargarDatos();

      state = state.copyWith(isSyncing: false);
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        error: e.toString(),
      );
    }
  }

  // Obtener color neón para cada método de pago
  static const Map<String, Color> neonColors = {
    'Efectivo': Color(0xFF00E676),   // Verde neón
    'Tarjeta': Color(0xFF00E5FF),    // Cian neón
    'Pago Móvil': Color(0xFFD500F9), // Púrpura neón
    'Divisas': Color(0xFFFF9100),    // Naranja neón
    'Pago Mixto': Color(0xFFFF4081), // Rosa neón
    'Otros': Color(0xFF94A3B8),      // Gris
  };

  Color getNeonColor(String metodo) {
    return neonColors[metodo] ?? neonColors['Otros']!;
  }

  // Obtener ícono para cada método
  static const Map<String, IconData> metodoIconos = {
    'Efectivo': Icons.money_rounded,
    'Tarjeta': Icons.credit_card_rounded,
    'Pago Móvil': Icons.phone_android_rounded,
    'Divisas': Icons.currency_exchange_rounded,
    'Pago Mixto': Icons.swap_horiz_rounded,
    'Otros': Icons.more_horiz_rounded,
  };

  IconData getMetodoIcono(String metodo) {
    return metodoIconos[metodo] ?? metodoIconos['Otros']!;
  }
}

// ============================================================
// PROVIDER
// ============================================================
final cashClosingProvider =
    StateNotifierProvider<CashClosingNotifier, CashClosingState>((ref) {
  return CashClosingNotifier(ref);
});