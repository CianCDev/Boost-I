// test/features/pos/feature_flags_retail_test.dart
//
// PASO 2.2 · P1 · Tests del gate por plan en modo retail.
//
// Estos tests son 100% puros: no tocan Isar, ni Supabase, ni widgets.
//
// ⚠️ HISTORIAL — el contrato de este archivo CAMBIÓ el 2026-10-15.
//
// La versión anterior blindaba P0-3, un arreglo que puso
// `defaultVisible: true` en 9 getters para "dejar de esconder 9 opciones
// de menú". Era el arreglo sintomático, aplicado antes de encontrar la
// causa real del menú vacío (`SuscripcionEntity.activa` comparaba
// contra `'activa'`, un valor que el CHECK de la base prohíbe, así que
// `planActivo` era `false` para todos los tenants).
//
// Con la causa ya corregida, `defaultVisible: true` sereve como lo que
// era: `planActivo && (contains(f) || true)` = `planActivo`. El gate no
// gateaba, y la columna ❌ de la tabla de planes no ocultaba nada.
//
// Ahora los 9 getters leen la clave real. Este archivo fija el
// contrato NUEVO. El complementario, con el catálogo real de cada plan
// leído de la base, está en `feature_flags_plan_test.dart`.
import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Catálogo REAL de `basico` en `public.planes`, leído el 2026-10-15.
  ///
  /// Antes este helper usaba `{offline, reports}`, que era el catálogo
  /// de `trial` — y por eso el test passing no significaba nada: un plan
  /// con 2 de 12 claves no representa a ningún plan que exista.
  const basico = <String>{
    'lotes',
    'offline',
    'reports',
    'dashboard',
    'departamentos',
    'historial_gastos',
    'historial_ventas',
    'monitor_empleados',
  };

  /// Catálogo real de `trial`, que tras `20261015000003` es idéntico a
  /// `basico`. Antes tenía `{offline, reports}` y dejaba el POS vacío.
  const catalogoMinimo = <String>{'offline', 'reports'};

  FeatureFlags retail({
    Set<String> features = basico,
    String planId = 'basico',
  }) =>
      FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: true,
        planId: planId,
        featuresHabilitadas: features,
      );

  group('P0-3 · Modo minorista (retail) con plan activo', () {
    test('las claves de infraestructura se leen bien', () {
      final f = retail();
      expect(f.modoOffline, isTrue, reason: 'lee la clave "offline"');
      expect(f.reportes, isTrue, reason: 'lee la clave "reports"');
    });

    test('multi_local NO se activa si la clave no viene (basico/pro)', () {
      // `basico` no trae multi_local, y no es huérfana:
      // debe quedar oculta. Este es el comportamiento correcto.
      expect(retail().multiLocal, isFalse);
      expect(
        retail(features: {...basico, 'multi_local'}).multiLocal,
        isTrue,
        reason: 'pro sí la trae y debe verse',
      );
    });

    test('priority_support activa soportePrioritario', () {
      final f = FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: true,
        planId: 'corporativo',
        featuresHabilitadas: const {'priority_support'},
      );
      expect(
        f.soportePrioritario,
        isTrue,
        reason: 'la clave en BD es "priority_support"; la versión vieja '
            'leía "soporte_prioritario" y nunca se activaba',
      );
    });

    test('las 6 features que basico contrata quedan visibles', () {
      final f = retail();
      expect(f.dashboard, isTrue);
      expect(f.historialVentas, isTrue);
      expect(f.historialGastos, isTrue);
      expect(f.lotes, isTrue);
      expect(f.mostrarLotes, isTrue);
      expect(f.monitorEmpleados, isTrue);
      expect(f.departamentos, isTrue);
    });

    test('las 4 que basico NO contrata quedan ocultas', () {
      // Este es el fix. Antes `defaultVisible: true` las dejaba
      // visibles igual y el gate era decorativo.
      final f = retail();
      expect(f.ventasAlMayor, isFalse, reason: 'basico: ventas_mayor=false');
      expect(f.pedidosProveedores, isFalse,
          reason: 'basico: pedidos_proveedores=false');
      expect(f.proveedores, isFalse,
          reason: 'basico: proveedores=false');
      expect(f.multiLocal, isFalse, reason: 'basico: multi_local=false');
    });

    test('un plan con catálogo mínimo NO ve el producto (por qué 20261015000003)', () {
      // Documenta el riesgo: `trial` tenía {offline, reports} y con el
      // gate efectivo le quedaba un POS vacío. Hay 4 tenants en trial.
      final f = retail(features: catalogoMinimo);
      expect(f.dashboard, isFalse);
      expect(f.lotes, isFalse);
      expect(f.departamentos, isFalse);
      expect(f.monitorEmpleados, isFalse);
      expect(f.modoOffline, isTrue, reason: 'offline sí está en el catálogo');
      expect(f.reportes, isTrue, reason: 'reports sí está en el catálogo');
    });

    test('telegram SIGUE visible (decisión de producto)', () {
      // No depende del plan: la clave `telegram` no existe en
      // `plans.features` y no se va a añadir. El único gate real es el rol
      // (Permissions.canManageTelegram, solo admin) en menu_config.dart.
      //
      // TODO(PASO-R.9): gatear por modo (ocultar en restaurante) cuando el
      // onboarding de token + chat_id por usuario esté listo.
      final conClave = FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: true,
        planId: 'corporativo',
        featuresHabilitadas: const {'telegram'},
      );
      expect(conClave.telegram, isTrue);

      // Tampoco con el jsonb real de los planes: sigue visible.
      final sinClave = FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: true,
        planId: 'corporativo',
        featuresHabilitadas: catalogoMinimo,
      );
      expect(sinClave.telegram, isTrue);

      // Sin plan activo también: es decisión de producto, no del plan.
      final sinPlan = FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: false,
      );
      expect(sinPlan.telegram, isTrue);
    });

    test('sin plan activo TODO queda cerrado, sin excepción', () {
      final f = const FeatureFlags(
        mode: BusinessMode.retail, planActivo: false);
      expect(f.ventasAlMayor, isFalse);
      expect(f.dashboard, isFalse);
      expect(f.lotes, isFalse);
      expect(f.mostrarLotes, isFalse);
    });
  });

  group('Derivados por modo (retail)', () {
    test('esRetail activa el código de barras y apaga el flujo de mesas', () {
      final f = retail();
      expect(f.esRetail, isTrue);
      expect(f.mostrarCodigoBarras, isTrue);
      expect(f.esRestaurante, isFalse);
      expect(f.requiereMesa, isFalse);
      expect(f.mostrarMesas, isFalse);
    });

    test('mostrarInventario va en retail pero no en servicios', () {
      expect(retail().mostrarInventario, isTrue);
      expect(
        FeatureFlags(
          mode: BusinessMode.servicios,
          planActivo: true,
          featuresHabilitadas: basico,
        ).mostrarInventario,
        isFalse,
      );
    });
  });

  group('P0-1 · Identificador persistido', () {
    test('BusinessMode.retail usa el id "retail" (valor de Supabase)', () {
      expect(BusinessMode.retail.id, 'retail');
    });

    test('la etiqueta visible sigue siendo "Mercado"', () {
      // Decisión D1: renombramos el identificador técnico, no el texto de UI.
      expect(BusinessMode.retail.label, 'Mercado');
    });

    test('fromId resuelve "retail"', () {
      expect(BusinessMode.fromId('retail'), BusinessMode.retail);
    });

    test('fromId coacciona el legacy "mercado" a retail', () {
      // Locales creados antes del renombrado guardan "mercado".
      expect(BusinessMode.fromId('mercado'), BusinessMode.retail);
    });

    test('fromId normaliza mayúsculas y espacios', () {
      expect(BusinessMode.fromId('  RETAIL '), BusinessMode.retail);
    });

    test('fromId cae a retail con un id desconocido', () {
      expect(BusinessMode.fromId('no_existe'), BusinessMode.retail);
      expect(BusinessMode.fromId(''), BusinessMode.retail);
    });

    test('los 3 modos tienen id único y no vacío', () {
      final ids = BusinessMode.values.map((m) => m.id).toSet();
      expect(ids.length, BusinessMode.values.length);
      expect(ids.every((id) => id.isNotEmpty), isTrue);
    });
  });
}