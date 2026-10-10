// test/features/pos/feature_flags_retail_test.dart
//
// PASO 2.2 · P1 · Tests de las 9 features reactivadas en P0-3 (PASO 1).
//
// Estos tests son 100% puros: no tocan Isar, ni Supabase, ni widgets.
// Blindan el cambio de P0-3, que fue el que dejó de esconder 9 opciones de
// menú. Si alguien vuelve a poner `defaultVisible: false` o cambia una clave,
// estos tests lo detectan sin necesidad de arrancar la app.
import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Las 4 claves que REALMENTE existen en `planes.features` (Supabase).
  const soloClavesReales = <String>{'offline', 'reports'};

  FeatureFlags retail() => FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: true,
        planId: 'basico',
        featuresHabilitadas: soloClavesReales,
      );

  group('P0-3 · Modo minorista (retail) con plan activo', () {
    test('las 4 claves reales de planes.features se leen bien', () {
      final f = retail();
      expect(f.modoOffline, isTrue, reason: 'lee la clave "offline"');
      expect(f.reportes, isTrue, reason: 'lee la clave "reports"');
    });

    test('multi_local NO se activa si la clave no viene (basico/pro)', () {
      // `soloClavesReales` no trae multi_local, y no es huérfana:
      // debe quedar oculta. Este es el comportamiento correcto.
      expect(retail().multiLocal, isFalse);
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

    test('las 8 features huérfanas quedan visibles sin depender del jsonb', () {
      final f = retail();
      expect(f.ventasAlMayor, isTrue);
      expect(f.dashboard, isTrue);
      expect(f.historialVentas, isTrue);
      expect(f.historialGastos, isTrue);
      expect(f.lotes, isTrue);
      expect(f.pedidosProveedores, isTrue);
      expect(f.monitorEmpleados, isTrue);
      expect(f.departamentos, isTrue);
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
        featuresHabilitadas: soloClavesReales,
      );
      expect(sinClave.telegram, isTrue);

      // Sin plan activo también: es decisión de producto, no del plan.
      final sinPlan = FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: false,
      );
      expect(sinPlan.telegram, isTrue);
    });

    test('sin plan activo TODO queda cerrado, incluidas las huérfanas', () {
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
          featuresHabilitadas: soloClavesReales,
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