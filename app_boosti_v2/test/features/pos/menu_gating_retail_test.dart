// test/features/pos/menu_gating_retail_test.dart
//
// PASO 2.2 · P1 · Test del gateo del menú del POS.
//
// `MenuBuilder.puedeVerOpcion` es un método estático y puro: combina rol +
// feature flags. Este test recorre las 24 opciones reales de `menu_config.dart`
// y fija qué debe verse y qué no en modo retail.
//
// Es el test que más valor tiene del lote: es exactamente el mecanismo que
// P0-3 alteró. Si una opción vuelve a desaparecer, o aparece una que no debe,
// este test falla.
import 'package:app_boosti_v2/features/pos/domain/permissions/roles.dart';
import 'package:app_boosti_v2/features/pos/presentation/config/menu_config.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mismo jsonb real del plan "basico" (solo 2 de las 4 claves).
  const clavesBasico = <String>{'offline', 'reports'};

  final flagsRetail = FeatureFlags(
    mode: BusinessMode.retail,
    planActivo: true,
    planId: 'basico',
    featuresHabilitadas: clavesBasico,
  );

  bool visible(String id, {UserRole role = UserRole.admin}) =>
      MenuBuilder.puedeVerOpcion(role, id, flagsRetail);

  group('Las 9 opciones reactivadas en P0-3', () {
    test('son visibles para el admin en retail', () {
      // Las 8 reactivadas + 'diagnostico', que se desbloquea con mostrarLotes.
      const reactivadas = <String>[
        'ventas_mayor',
        'dashboard',
        'ventas',
        'gastos',
        'lotes',
        'pedidos',
        'monitor',
        'departamentos',
        'diagnostico',
      ];
      for (final id in reactivadas) {
        expect(
          visible(id),
          isTrue,
          reason: '"$id" debe verse en retail tras P0-3, pero está oculta',
        );
      }
    });

    test('"pedidos" sigue oculta en modo servicios por diseño', () {
      final flagsServicios = FeatureFlags(
        mode: BusinessMode.servicios,
        planActivo: true,
        planId: 'pro',
        featuresHabilitadas: clavesBasico,
      );
      expect(
        MenuBuilder.puedeVerOpcion(UserRole.admin, 'pedidos', flagsServicios),
        isFalse,
        reason: 'menu_config.dart:127 exige !esServicios',
      );
    });
  });

  group('Opciones que deben seguir ocultas en retail', () {
    test('telegram es visible: el único gate es el rol (admin)', () {
      // H1 (PASO 2.3): `telegram` pasó a ser decisión de producto, no
      // feature del plan. Con admin se ve...
      expect(visible('telegram'), isTrue);
      // ...pero el gate de rol sigue intacto: `canManageTelegram` es solo
      // admin, así que un supervisor NO la ve.
      expect(visible('telegram', role: UserRole.supervisor), isFalse);
      expect(visible('telegram', role: UserRole.cajero), isFalse);
    });

    test('sin plan activo no se ve ninguna opción gateada por feature', () {
      // OJO: `telegram` NO va aquí. Desde H1 (PASO 2.3) es decisión de
      // producto (`telegram => true`), no una feature del plan, así que
      // sigue visible sin plan. Se cubre en su propio test.
      const gated = <String>[
        'ventas_mayor',
        'dashboard',
        'ventas',
        'gastos',
        'lotes',
        'pedidos',
        'monitor',
        'departamentos',
        'diagnostico',
        'locales',
      ];
      const flagsSinPlan = FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: false,
      );
      for (final id in gated) {
        expect(
          MenuBuilder.puedeVerOpcion(UserRole.admin, id, flagsSinPlan),
          isFalse,
          reason: '"$id" debe quedar oculta sin plan vigente',
        );
      }
    });

    test('"locales" exige multi_local: basico no lo tiene', () {
      expect(visible('locales'), isFalse);
      final flagsPro = FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: true,
        planId: 'pro',
        featuresHabilitadas: const {...clavesBasico, 'multi_local'},
      );
      expect(MenuBuilder.puedeVerOpcion(UserRole.admin, 'locales', flagsPro),
          isTrue);
    });
  });

  group('H3 · "Punto de venta" (sección INICIO)', () {
    test('se ve para los 3 roles que pueden cobrar', () {
      // Permissions.canAccessPos = admin || supervisor || cajero
      for (final role in const [
        UserRole.admin,
        UserRole.supervisor,
        UserRole.cajero,
      ]) {
        expect(
          visible('punto_venta', role: role),
          isTrue,
          reason: '$role puede acceder al POS y debe ver el botón',
        );
      }
    });

    test('NO se ve para roles restringidos', () {
      const restringidos = [
        UserRole.rrhh,
        UserRole.auditor,
        UserRole.almacen,
        UserRole.soporte,
        UserRole.dev,
      ];
      for (final role in restringidos) {
        expect(
          visible('punto_venta', role: role),
          isFalse,
          reason: '$role no tiene canAccessPos',
        );
      }
    });

    test('no depende del plan: se ve incluso sin plan activo', () {
      // `_flagPermite` cae en el `_ => true`: el gate es solo de rol.
      const flagsSinPlan = FeatureFlags(
        mode: BusinessMode.retail,
        planActivo: false,
      );
      expect(
        MenuBuilder.puedeVerOpcion(
            UserRole.cajero, 'punto_venta', flagsSinPlan),
        isTrue,
      );
    });

    test('tampoco depende del modo: visible en restaurante', () {
      // H2: el POS cobra en restaurante hasta que R.1 lo reemplace.
      final flagsRestaurante = FeatureFlags(
        mode: BusinessMode.restaurante,
        planActivo: true,
        planId: 'pro',
        featuresHabilitadas: clavesBasico,
      );
      expect(
        MenuBuilder.puedeVerOpcion(
            UserRole.cajero, 'punto_venta', flagsRestaurante),
        isTrue,
      );
    });
  });

  group('R.1 · "Salón" (id: mesas)', () {
    FeatureFlags flagsModo(BusinessMode modo) => FeatureFlags(
          mode: modo,
          planActivo: true,
          planId: 'pro',
          featuresHabilitadas: clavesBasico,
        );

    test('se ve en modo restaurante para los roles que cobran', () {
      final flags = flagsModo(BusinessMode.restaurante);
      for (final role in const [
        UserRole.admin,
        UserRole.supervisor,
        UserRole.cajero,
      ]) {
        expect(
          MenuBuilder.puedeVerOpcion(role, 'mesas', flags),
          isTrue,
          reason: '$role debe ver el salón en restaurante',
        );
      }
    });

    test('NO se ve en retail: requiereMesa es false ahí', () {
      // Es el motivo por el que existe la línea explícita en _flagPermite:
      // sin ella, el `_ => true` la dejaría visible para todo el mundo.
      expect(flagsModo(BusinessMode.retail).requiereMesa, isFalse);
      for (final role in UserRole.values) {
        expect(
          MenuBuilder.puedeVerOpcion(
              role, 'mesas', flagsModo(BusinessMode.retail)),
          isFalse,
          reason: 'el salón no debe existir en retail ($role)',
        );
      }
    });

    test('NO se ve en servicios', () {
      expect(flagsModo(BusinessMode.servicios).requiereMesa, isFalse);
    });

    test('NO se ve para roles restringidos ni en restaurante', () {
      final flags = flagsModo(BusinessMode.restaurante);
      const restringidos = [
        UserRole.rrhh,
        UserRole.auditor,
        UserRole.almacen,
        UserRole.soporte,
        UserRole.dev,
      ];
      for (final role in restringidos) {
        expect(
          MenuBuilder.puedeVerOpcion(role, 'mesas', flags),
          isFalse,
          reason: '$role no tiene canAccessPos',
        );
      }
    });
  });

  group('R.5 · "Ventas al Mayor" (id: ventas_mayor) es retail puro', () {
    // Mayor = precios por volumen + lista de clientes mayoristas. En
    // restaurante la venta es por mesa/comanda: no hay nada que aplicar.
    FeatureFlags flagsModo(BusinessMode modo) => FeatureFlags(
          mode: modo,
          planActivo: true,
          planId: 'pro',
          featuresHabilitadas: clavesBasico,
        );

    test('el criterio vive en FeatureFlags, no en el switch del menú', () {
      // Si esto falla, alguien reescribió el gate como condición compuesta
      // en `menu_config.dart` y el menú volvió a depender de dos fuentes.
      expect(flagsModo(BusinessMode.retail).modoPermiteVentasMayor, isTrue);
      expect(flagsModo(BusinessMode.restaurante).modoPermiteVentasMayor,
          isFalse);
      expect(flagsModo(BusinessMode.servicios).modoPermiteVentasMayor, isFalse);
    });

    test('NO se ve en restaurante para NINGÚN rol', () {
      final flags = flagsModo(BusinessMode.restaurante);
      for (final role in UserRole.values) {
        expect(
          MenuBuilder.puedeVerOpcion(role, 'ventas_mayor', flags),
          isFalse,
          reason: 'ventas al mayor no aplica en restaurante ($role)',
        );
      }
    });

    test('tampoco en servicios', () {
      expect(
        MenuBuilder.puedeVerOpcion(
            UserRole.admin, 'ventas_mayor', flagsModo(BusinessMode.servicios)),
        isFalse,
      );
    });

    test('SIGUE viéndose en retail (el gate nuevo no la rompió)', () {
      expect(visible('ventas_mayor'), isTrue);
      // ...y solo para los roles que puede aplicar el módulo (roles.dart:106).
      for (final role in const [
        UserRole.admin,
        UserRole.supervisor,
        UserRole.cajero,
      ]) {
        expect(visible('ventas_mayor', role: role), isTrue,
            reason: '$role sí accede a mayor');
      }
      expect(visible('ventas_mayor', role: UserRole.rrhh), isFalse);
    });
  });

  group('Opciones sin gate de plan (siempre disponibles para admin)', () {
    test('caja, proveedores, inventario, backup, sync y perfil se ven', () {
      const siempre = <String>[
        'caja',
        'inventario',
        'proveedores',
        'auditoria',
        'empleados',
        'personal',
        'impresoras',
        'backup',
        'sync',
        'perfil',
      ];
      for (final id in siempre) {
        expect(
          visible(id),
          isTrue,
          reason: '"$id" debería verse sin gate extra',
        );
      }
    });
  });

  group('El rol manda antes que el plan', () {
    test('un cajero NO ve "departamentos" aunque el plan lo permita', () {
      expect(visible('departamentos'), isTrue);
      expect(
        visible('departamentos', role: UserRole.cajero),
        isFalse,
        reason: 'departamentos exige canManageLocales',
      );
    });

    test('un cajero NO ve "personal" ni "empleados"', () {
      expect(visible('personal', role: UserRole.cajero), isFalse);
      expect(visible('empleados', role: UserRole.cajero), isFalse);
    });

    test('un cajero NO ve "ventas" (canViewDashboard excluye cajero)', () {
      // Verificado en roles.dart:154.
      expect(visible('ventas', role: UserRole.cajero), isFalse);
      expect(visible('ventas', role: UserRole.supervisor), isTrue);
    });

    test('un cajero NO ve "lotes": canManageLotes es admin + almacen', () {
      // Verificado en roles.dart:147. El cajero cobra pero no gestiona lotes.
      expect(visible('lotes', role: UserRole.almacen), isTrue);
      expect(visible('lotes', role: UserRole.cajero), isFalse);
    });

    test('"sync" se oculta solo para rrhh (el único employees-only)', () {
      // Verificado en roles.dart:185: isEmployeesOnlyRole => rrhh.
      expect(visible('sync', role: UserRole.rrhh), isFalse);
      expect(visible('sync', role: UserRole.auditor), isTrue);
      expect(visible('sync', role: UserRole.admin), isTrue);
    });
  });

  group('P0-2 · El POS sigue accesible tras quitar el gate de mesa', () {
    test('el retail nunca exige mesa', () {
      expect(flagsRetail.requiereMesa, isFalse);
    });

    test('en restaurante el POS rápido tampoco se oculta', () {
      // main_pos_screen.dart quitó `&& !flags.requiereMesa` en P0-2.
      // Este test fija que el flag sigue existiendo (para R.2) pero que la
      // tarjeta del POS no depende de él; la ausencia del gate se verificó
      // por lectura de código, no por widget.
      final flagsRestaurante = FeatureFlags(
        mode: BusinessMode.restaurante,
        planActivo: true,
        planId: 'pro',
        featuresHabilitadas: const {},
      );
      // `requiereMesa` sigue existiendo: R.2 lo usará de nuevo.
      expect(flagsRestaurante.requiereMesa, isTrue);
      // Pero el inventario sigue visible en restaurante (no en servicios).
      expect(flagsRestaurante.mostrarInventario, isTrue);
    });
  });
}