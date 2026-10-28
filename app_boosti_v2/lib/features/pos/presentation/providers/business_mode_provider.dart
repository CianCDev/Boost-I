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
  /// Minorista, abarrotes, farmacia, bodega.
  ///
  /// El identificador técnico es `retail` porque es el valor persistido en
  /// `locales.business_mode` (Supabase) y en `LocalEntity.businessMode`
  /// (Isar). Antes era `mercado`, valor que ya no existe en ningún plan
  /// de la base de datos. La etiqueta visible sigue siendo "Mercado".
  retail(
    id: 'retail',
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

  /// Resuelve un identificador persistido a su valor del enum.
  ///
  /// Acepta también el valor legacy `'mercado'` por locales creados antes
  /// del renombrado a `retail`.
  static BusinessMode fromId(String id) {
    final normalizado = id.trim().toLowerCase();
    if (normalizado == 'mercado') return BusinessMode.retail;
    return BusinessMode.values.firstWhere(
      (m) => m.id == normalizado,
      orElse: () => BusinessMode.retail,
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

  BusinessModeNotifier(this.ref) : super(BusinessMode.retail) {
    _cargarModoDelLocalActivo();
  }

  /// Lee el modo del local activo desde Isar.
  Future<void> _cargarModoDelLocalActivo() async {
    try {
      final local = await IsarService().obtenerLocalActivo();
      if (local == null) {
        debugPrint('ℹ️ [BusinessMode] Sin local activo → retail por default');
        // Guarda estándar: el notifier puede haberse dispuesto durante el
        // await.
        if (!mounted) return;
        state = BusinessMode.retail;
        return;
      }

      // TODO(R.0): migración legacy `mercado` → `retail`.
      // Los locales creados antes del renombrado guardan 'mercado' en Isar,
      // valor que ya no existe en ningún plan de Supabase. Se coacciona en
      // memoria y se marca `sincronizado = false` para que `SyncService`
      // suba el valor correcto a `locales.business_mode`.
      // Eliminar este bloque en R.2, cuando ya ningún local tenga 'mercado'.
      if (local.businessMode == 'mercado') {
        debugPrint('⚠️ [BusinessMode] Migrando legacy mercado → retail');
        local.businessMode = 'retail';
        local.sincronizado = false;
        final isar = await IsarService().db;
        await isar.writeTxn(() async {
          await isar.localEntitys.put(local);
        });
      }

      if (!mounted) return;
      state = BusinessMode.fromId(local.businessMode);
      debugPrint('✅ [BusinessMode] Modo cargado: ${state.id}');
    } catch (e) {
      debugPrint('⚠️ [BusinessMode] Error cargando modo: $e');
      if (!mounted) return;
      state = BusinessMode.retail;
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

  /// Evalúa una feature del plan.
  ///
  /// 🔴 `defaultVisible` está en `false` en TODOS los getters (2026-10-15)
  ///
  /// Antes cada feature usaba `defaultVisible: true` salvo cuatro, con la
  /// idea de no esconder pantallas que ya funcionan. El problema es que
  /// `|| defaultVisible` hace el gate INOPERANTE: con `true`, la
  /// expresión queda `planActivo && (...)` y da lo mismo el plan que
  /// contrate o no la feature. Los 9 getters que la usaban eran
  /// dashboard, historial de ventas, historial de gastos, proveedores,
  /// pedidos a proveedores, departamentos, lotes, monitor de empleados y
  /// ventas al mayor.
  ///
  /// El `defaultVisible: true` se justifiqué porque las claves no
  /// existían en `planes.features`. Ya existen (migración
  /// `20261015000002`), así que el gate tiene que valer de verdad: el
  /// plan `basico` tiene `proveedores`, `pedidos_proveedores`,
  /// `multi_local` y `ventas_mayor` en `false` y esos cuatro módulos
  /// tienen que desaparecerle del menú.
  ///
  /// El parámetro se conserva para que una feature realmente huérfana
  /// —sin clave posible en `planes.features`— pueda declararse visible
  /// de forma explícita.Hoy no lo usa ningún getter, y esa es la
  /// intención: cada línea dice qué contrató el plan.
  ///
  /// ⚠️ `planActivo &&` sigue siendo cortocircuito: sin suscripción
  /// activa no se ve NADA, ni siquiera una feature que marcase
  /// `defaultVisible: true`. Es fail-closed a propósito (AGENTS.MD §7.3).
  bool _plan(String feature, {bool defaultVisible = false}) =>
      planActivo && (featuresHabilitadas.contains(feature) || defaultVisible);

  // ── Modos ──

  bool get esRetail => mode == BusinessMode.retail;
  bool get esRestaurante => mode == BusinessMode.restaurante;
  bool get esServicios => mode == BusinessMode.servicios;

  /// ¿El modo actual permite ventas al mayor (B2B)?
  ///
  /// Retail sí: es su caso de uso central (precios por volumen, lista de
  /// clientes mayoristas). Restaurante y servicios no: la venta es por
  /// mesa/comanda o por servicio, y no hay lista de precios por cliente
  /// mayorista que aplicar.
  ///
  /// ⚠️ Vive AQUÍ y no como condición compuesta en `menu_config.dart` a
  /// propósito: el día que restaurante acepte mayor, o que servicios lo
  /// quiera, se cambia esta línea y el menú se entera solo.
  bool get modoPermiteVentasMayor => esRetail;

  // ── POS ──

  // `ventas_mayor` figura en `basico: false`. El gate es real desde
  // 2026-10-15: el básico no ve Ventas al Mayor.
  bool get ventasAlMayor => _plan('ventas_mayor');

  // Sin uso en la UI. Se mantiene oculta hasta que exista la pantalla de
  // carritos múltiples (fuera del alcance de Modo Restaurante).
  bool get multicarrito => _plan('multicarrito');

  // ── Inventario ──

  // Claves reales en `planes.features` desde 2026-10-15
  // (migración 20261015000002_plan_features.sql).
  bool get lotes => _plan('lotes');
  bool get pedidosProveedores => _plan('pedidos_proveedores');

  /// Antes esta pantalla no consultaba NINGÚN flag de plan: el gate era
  /// solo `!esServicios`, así que el plan básico veía Proveedores.
  /// Producto (2026-10-15): básico NO ve proveedores.
  bool get proveedores => _plan('proveedores');

  // ── Organización ──

  // `DepartamentosScreen` y el selector de local ya funcionan.
  bool get departamentos => _plan('departamentos');

  /// Única feature de organización con clave REAL en `plans.features`.
  bool get multiLocal => _plan('multi_local');

  bool get monitorEmpleados => _plan('monitor_empleados');

  // ── Reportes ──

  // Claves reales en `planes.features` desde 2026-10-15
  // (20261015000002_plan_features.sql). Antes no existían y con
  // `planActivo = false` estos tres módulos desaparecían del menú.
  // `DashboardScreen`, `SalesHistoryScreen` y `GastosScreen` funcionan.
  bool get dashboard => _plan('dashboard');
  bool get historialVentas => _plan('historial_ventas');
  bool get historialGastos => _plan('historial_gastos');

  // Sin uso en la UI.
  bool get estadisticasAdmin => _plan('estadisticas_admin');

  // ── Configuración ──

  /// Telegram: decisión de producto. Hoy visible para todos los planes
  /// porque se usa activamente en retail.
  ///
  /// No es una feature del plan: la clave `telegram` no existe en
  /// `plans.features` y no se va a añadir. El único gate real es el rol
  /// (`Permissions.canManageTelegram`, solo admin) vía `menu_config.dart`.
  ///
  /// TODO(PASO-R.9): gatear por modo (ocultar en restaurante) cuando el
  /// onboarding de token + chat_id por usuario esté listo.
  bool get telegram => true;

  // Sin uso en la UI.
  bool get personalizacionTickets => _plan('personalizacion_tickets');
  bool get modulosCustom => _plan('modulos_custom');
  bool get betaChannel => _plan('beta_channel');

  /// Lee la clave REAL `priority_support` de `plans.features`.
  ///
  /// Antes leía el nombre en español con guiones bajos, clave que no
  /// existe en la base de datos: el flag nunca se activaba.
  bool get soportePrioritario => _plan('priority_support');

  /// Lee la clave REAL `offline` de `plans.features`.
  bool get modoOffline => _plan('offline');

  /// Lee la clave REAL `reports` de `plans.features`.
  bool get reportes => _plan('reports');

  // ── Combinaciones modo+plan ──

  bool get mostrarMesas => esRestaurante;
  bool get mostrarComandas => esRestaurante;

  /// G.2 · Receta: la ficha de preparación del plato (KDS) es una cosa
  /// de restaurante. En retail el producto es una unidad que se vende tal
  /// cual (TODO:891) y en servicios no hay catálogo de inventario.
  /// El gate vive en `ProductDataTab`, NO dentro del editor de receta
  /// (decisión registrada en TODO:897-899: el editor no conoce flags).
  bool get mostrarRecetas => esRestaurante;
  bool get mostrarKDS => esRestaurante;
  bool get mostrarAgenda => esServicios;
  bool get mostrarProfesionales => esServicios;
  bool get mostrarInventario => !esServicios;
  bool get mostrarLotes => !esServicios && lotes;
  bool get mostrarCodigoBarras => esRetail;
  bool get requiereMesa => esRestaurante;
  bool get usaCitas => esServicios;
}

/// Provider derivado que combina modo + suscripción + features del plan.
final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  final mode = ref.watch(businessModeProvider);
  final suscripcionAsync = ref.watch(suscripcionProvider);
  final cachePlanActivo = ref.watch(planActivoCacheProvider);

  final suscripcion = suscripcionAsync.valueOrNull;

  // ⚠️ Mientras el fetch no terminó (`valueOrNull == null` y sigue
  // cargando) NO aplicamos el fallback. `planActivoCacheProvider` puede
  // no estar hidratado todavía, y gatear con un `false` provisional
  // haría parpadear los módulos.
  if (suscripcionAsync.isLoading) {
    return FeatureFlags(
      mode: mode,
      planActivo: false,
      planId: null,
      featuresHabilitadas: const {},
    );
  }

  if (suscripcion == null || !suscripcion.activa) {
    // Fallback ante fallo de red: `suscripcionProvider` deja
    // `planActivoCacheProvider` con el último valor conocido cuando el
    // fetch falla (timeout/error). `null` = nunca se pudo determinar, y
    // ahí se deniega (fail-closed), igual que antes de este cambio.
    final planActivo = cachePlanActivo ?? false;
    // 🔎 DIAGNÓSTICO (2026-10-15): esta rama era la única SIN log.
    // Con `suscripcion == null` y `cachePlanActivo == null` el menú
    // quedaba entero oculto y no había forma de saber por qué.
    debugPrint(
      '🔎 [featureFlags] DENEGADO · suscripcion=${suscripcion?.planId}'
      '(${suscripcion?.estado}) activa=${suscripcion?.activa} '
      'cache=$cachePlanActivo → planActivo=$planActivo',
    );
    if (suscripcion == null && cachePlanActivo != null) {
      debugPrint(
        '📦 [featureFlags] Suscripción no disponible. Usando cache: '
        'planActivo=$planActivo',
      );
    }
    return FeatureFlags(
      mode: mode,
      planActivo: planActivo,
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

  // 🔎 DIAGNÓSTICO (2026-10-15): sin esto no se distinguía "el plan no
  // trae la clave" de "el plan no se pudo cargar" — ambos dan `features`
  // vacío y el mismo menú mudo.
  debugPrint(
    '🔎 [featureFlags] planActivo=true plan=${suscripcion.planId} '
    'planCargado=${plan != null} features=${features.length}',
  );

  return FeatureFlags(
    mode: mode,
    planActivo: true,
    planId: suscripcion.planId,
    featuresHabilitadas: features,
  );
});