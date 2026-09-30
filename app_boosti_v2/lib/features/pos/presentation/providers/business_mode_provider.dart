// lib/features/pos/presentation/providers/business_mode_provider.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/isar_service.dart';

import 'suscripcion_provider.dart';

// ══════════════════════════════════════════════════════════════════
// ENUM: MODOS DE NEGOCIO
// ══════════════════════════════════════════════════════════════════

enum BusinessMode {
  mercado(
    id: 'mercado',
    label: 'Mercado',
    description: 'Retail, abarrotes, farmacia, bodega',
    icon: Icons.storefront_rounded,
    color: Color(0xFF10B981),
  ),
  restaurante(
    id: 'restaurante',
    label: 'Restaurante',
    description: 'Mesas, comandas, cocina',
    icon: Icons.restaurant_rounded,
    color: Color(0xFFEF4444),
  ),
  servicios(
    id: 'servicios',
    label: 'Servicios',
    description: 'Citas, agenda, profesionales',
    icon: Icons.content_cut_rounded,
    color: Color(0xFF8B5CF6),
  );

  final String id;
  final String label;
  final String description;
  final IconData icon;
  final Color color;

  const BusinessMode({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });

  static BusinessMode fromId(String id) {
    return BusinessMode.values.firstWhere(
      (m) => m.id == id,
      orElse: () => BusinessMode.mercado,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// NOTIFIER: MODO DEL LOCAL ACTIVO
// ══════════════════════════════════════════════════════════════════

final businessModeProvider =
    StateNotifierProvider<BusinessModeNotifier, BusinessMode>(
  (ref) => BusinessModeNotifier(ref),
);

class BusinessModeNotifier extends StateNotifier<BusinessMode> {
  final Ref ref;

  BusinessModeNotifier(this.ref) : super(BusinessMode.mercado) {
    _cargarModoDelLocalActivo();
  }

  /// Lee el modo del local activo desde Isar.
  Future<void> _cargarModoDelLocalActivo() async {
    try {
      final local = await IsarService().obtenerLocalActivo();
      if (local == null) {
        debugPrint('ℹ️ [BusinessMode] Sin local activo → mercado por default');
        state = BusinessMode.mercado;
        return;
      }
      state = BusinessMode.fromId(local.businessMode);
      debugPrint('✅ [BusinessMode] Modo cargado: ${state.id}');
    } catch (e) {
      debugPrint('⚠️ [BusinessMode] Error cargando modo: $e');
      state = BusinessMode.mercado;
    }
  }

  /// Recarga el modo desde Isar. Útil cuando cambia el local activo.
  Future<void> recargar() => _cargarModoDelLocalActivo();

  /// Cambia el modo del local activo y lo persiste.
  ///
  /// NO actualiza Supabase — eso lo hace el `SyncService` cuando
  /// suba el local pendiente.
  Future<bool> cambiarModo(BusinessMode nuevo) async {
    try {
      final isar = await IsarService().db;
      final local = await IsarService().obtenerLocalActivo();
      if (local == null) {
        debugPrint('⚠️ [BusinessMode] No hay local activo para cambiar modo');
        return false;
      }

      local.businessMode = nuevo.id;
      local.modoConfiguradoEn = DateTime.now();
      local.sincronizado = false;
      local.updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.localEntitys.put(local);
      });

      state = nuevo;
      debugPrint('✅ [BusinessMode] Modo cambiado a ${nuevo.id}');

      // Refrescar la suscripción por si el nuevo modo depende del plan
      ref.invalidate(suscripcionProvider);
      return true;
    } catch (e) {
      debugPrint('❌ [BusinessMode] Error cambiando modo: $e');
      return false;
    }
  }
}

// ══════════════════════════════════════════════════════════════════
// FEATURE FLAGS (derivados)
// ══════════════════════════════════════════════════════════════════

/// Estado consolidado: modo + plan + features activas.
///
/// Se calcula combinando:
///   - `businessModeProvider` (modo del local)
///   - `suscripcionProvider` (estado del plan)
///   - `planPorIdProvider` (features del plan)
class FeatureFlags {
  final BusinessMode mode;

  /// El plan está vigente (activa o trial no vencido).
  final bool planActivo;

  /// ID del plan actual: 'basico' | 'pro' | 'corporativo' | null
  final String? planId;

  /// Set de features habilitadas por el plan.
  final Set<String> featuresHabilitadas;

  const FeatureFlags({
    required this.mode,
    required this.planActivo,
    this.planId,
    this.featuresHabilitadas = const {},
  });

  // ── Helpers privados ──

  bool _plan(String feature) =>
      planActivo && featuresHabilitadas.contains(feature);

  // ── Modos ──

  bool get esMercado => mode == BusinessMode.mercado;
  bool get esRestaurante => mode == BusinessMode.restaurante;
  bool get esServicios => mode == BusinessMode.servicios;

  // ── POS ──

  bool get ventasAlMayor => _plan('ventas_mayor');
  bool get multicarrito => _plan('multicarrito');

  // ── Inventario ──

  bool get lotes => _plan('lotes');
  bool get pedidosProveedores => _plan('pedidos_proveedores');

  // ── Organización ──

  bool get departamentos => _plan('departamentos');
  bool get multiLocal => _plan('multi_local');
  bool get monitorEmpleados => _plan('monitor_empleados');

  // ── Reportes ──

  bool get dashboard => _plan('dashboard');
  bool get historialVentas => _plan('historial_ventas');
  bool get historialGastos => _plan('historial_gastos');
  bool get estadisticasAdmin => _plan('estadisticas_admin');

  // ── Configuración ──

  bool get telegram => _plan('telegram');
  bool get personalizacionTickets => _plan('personalizacion_tickets');
  bool get modulosCustom => _plan('modulos_custom');
  bool get betaChannel => _plan('beta_channel');
  bool get soportePrioritario => _plan('soporte_prioritario');

  // ── Combinaciones modo+plan ──

  bool get mostrarMesas => esRestaurante;
  bool get mostrarComandas => esRestaurante;
  bool get mostrarKDS => esRestaurante;
  bool get mostrarAgenda => esServicios;
  bool get mostrarProfesionales => esServicios;
  bool get mostrarInventario => !esServicios;
  bool get mostrarLotes => !esServicios && lotes;
  bool get mostrarCodigoBarras => esMercado;
  bool get requiereMesa => esRestaurante;
  bool get usaCitas => esServicios;
}

/// Provider derivado que combina modo + suscripción + features del plan.
final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  final mode = ref.watch(businessModeProvider);
  final suscripcionAsync = ref.watch(suscripcionProvider);

  final suscripcion = suscripcionAsync.valueOrNull;

  if (suscripcion == null || !suscripcion.activa) {
    return FeatureFlags(
      mode: mode,
      planActivo: false,
      planId: null,
      featuresHabilitadas: const {},
    );
  }

  // Leer features del plan
  final planAsync = ref.watch(planPorIdProvider(suscripcion.planId));
  final plan = planAsync.valueOrNull;

  final features = <String>{};
  if (plan != null) {
    final map = plan.featuresMap;
    map.forEach((key, value) {
      if (value == true) features.add(key);
    });
  }

  return FeatureFlags(
    mode: mode,
    planActivo: true,
    planId: suscripcion.planId,
    featuresHabilitadas: features,
  );
});