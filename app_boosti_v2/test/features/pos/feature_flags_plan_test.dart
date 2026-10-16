// test/features/pos/feature_flags_plan_test.dart
import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fija el contrato del gate por plan.
///
/// Incidente del 2026-10-15: 9 getters usaban `defaultVisible: true`, que
/// hace `|| defaultVisible` verdadero siempre y deja el gate inoperante.
/// El plan `basico` marcaba `proveedores`, `pedidos_proveedores`,
/// `multi_local` y `ventas_mayor` en `false` y los cuatro módulos le
/// aparecían igual.
///
/// Estos tests usan los valores REALES de `public.planes` leídos el
/// 2026-10-15. Si cambia el catálogo en la BD, hay que actualizarlos.
void main() {
  /// Construye los flags como los arma `featureFlagsProvider` para una
  /// suscripción activa.
  FeatureFlags flagsCon(Set<String> features) => FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: true,
        planId: 'test',
        featuresHabilitadas: features,
      );

  // ── planes.features reales (SELECT id, features FROM public.planes) ──

  final basico = <String>{
    'lotes',
    'offline',
    'reports',
    'dashboard',
    'departamentos',
    'historial_gastos',
    'historial_ventas',
    'monitor_empleados',
  };
  final pro = <String>{
    ...basico,
    'multi_local',
    'proveedores',
    'ventas_mayor',
    'pedidos_proveedores',
  };
  final corporativo = <String>{...pro, 'priority_support'};

  group('plan pro ve todo lo contratado', () {
    final f = flagsCon(pro);

    test('los 13 módulos del menú están habilitados', () {
      expect(f.dashboard, isTrue);
      expect(f.historialVentas, isTrue);
      expect(f.historialGastos, isTrue);
      expect(f.proveedores, isTrue);
      expect(f.pedidosProveedores, isTrue);
      expect(f.multiLocal, isTrue);
      expect(f.departamentos, isTrue);
      expect(f.lotes, isTrue);
      expect(f.mostrarLotes, isTrue);
      expect(f.monitorEmpleados, isTrue);
      expect(f.ventasAlMayor, isTrue);
      expect(f.modoPermiteVentasMayor, isTrue);
      expect(f.soportePrioritario, isFalse, reason: 'solo corporativo');
    });
  });

  group('plan basico NO ve lo que no contrató', () {
    final f = flagsCon(basico);

    test('proveedores / pedidos / multi-local / mayor están en false', () {
      expect(f.proveedores, isFalse);
      expect(f.pedidosProveedores, isFalse);
      expect(f.multiLocal, isFalse);
      expect(f.ventasAlMayor, isFalse);
    });

    test('pero SÍ ve dashboard, historial, gastos, depts, lotes, monitor', () {
      expect(f.dashboard, isTrue);
      expect(f.historialVentas, isTrue);
      expect(f.historialGastos, isTrue);
      expect(f.departamentos, isTrue);
      expect(f.lotes, isTrue);
      expect(f.mostrarLotes, isTrue);
      expect(f.monitorEmpleados, isTrue);
    });
  });

  group('plan corporativo', () {
    final f = flagsCon(corporativo);

    test('además de pro, habilita soporte prioritario', () {
      expect(f.soportePrioritario, isTrue);
      expect(f.proveedores, isTrue);
      expect(f.dashboard, isTrue);
    });
  });

  group('fail-closed', () {
    test('sin suscripción activa no se ve NADA', () {
      final f = FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: false,
        planId: null,
        featuresHabilitadas: pro,
      );
      // El `&&` cortocircuita aunque `featuresHabilitadas` esté completo.
      expect(f.dashboard, isFalse);
      expect(f.proveedores, isFalse);
      expect(f.multiLocal, isFalse);
      expect(f.lotes, isFalse);
      expect(f.ventasAlMayor, isFalse);
    });
  });

  group('peligro: plan con catálogo mínimo oculta el POS entero', () {
    // Este test documenta POR QUÉ la migración
    // `20261015000003_trial_hereda_basico.sql` es obligatoria y no
    // opcional.
    //
    // El plan `trial` tenía `{offline, reports}` y nada más. Con el
    // gate efectivo (que es el cambio del 2026-10-15) eso oculta TODOS
    // los módulos con plan. Hay 4 tenants en trial en producción
    // (`prueba 2`, `prueba 3`, `pruebapostdeploy`, otro): sin el
    // backfill que los suben al catálogo de `basico`, entrarían a un
    // POS vacío.
    //
    // Un test unitario no puede verificar que la migración se aplicó —
    // eso es un `SELECT features FROM planes WHERE id='trial'` en la
    // base. Lo que sí fija esto es el COMPORTAMIENTO del riesgo: si
    // alguien vuelve a tocar `_plan()` o el catálogo, esta aserción
    // sigue describiendo el chão firme.
    final f = flagsCon({'offline', 'reports'});

    test('con solo offline+reports NO queda ningún módulo de menú', () {
      expect(f.dashboard, isFalse);
      expect(f.historialVentas, isFalse);
      expect(f.historialGastos, isFalse);
      expect(f.proveedores, isFalse);
      expect(f.pedidosProveedores, isFalse);
      expect(f.multiLocal, isFalse);
      expect(f.departamentos, isFalse);
      expect(f.lotes, isFalse);
      expect(f.mostrarLotes, isFalse);
      expect(f.monitorEmpleados, isFalse);
      expect(f.ventasAlMayor, isFalse);
    });

    test('por eso `trial` debe ser idéntico a `basico` en la BD', () {
      // Si este test falla por un cambio futuro, la respuesta NO es
      // arreglar el getter: es revisar si `trial` volvió a quedar con
      // un catálogo parcial.
      expect(flagsCon(basico).dashboard, isTrue);
      expect(flagsCon(basico).proveedores, isFalse);
    });
  });

  group('el gate no es un OR de defaultVisible', () {
    // Esta es la regresión directa del bug: con `defaultVisible: true`
    // el getter devolvía `true` aun con `featuresHabilitadas` vacío.
    final soloReportes = flagsCon({'reports'});

    test('un plan con 1 sola clave NO habilita el resto', () {
      expect(soloReportes.dashboard, isFalse);
      expect(soloReportes.historialVentas, isFalse);
      expect(soloReportes.historialGastos, isFalse);
      expect(soloReportes.proveedores, isFalse);
      expect(soloReportes.pedidosProveedores, isFalse);
      expect(soloReportes.departamentos, isFalse);
      expect(soloReportes.lotes, isFalse);
      expect(soloReportes.monitorEmpleados, isFalse);
      expect(soloReportes.ventasAlMayor, isFalse);
    });
  });
}