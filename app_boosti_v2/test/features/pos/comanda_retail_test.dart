// test/features/pos/comanda_retail_test.dart
//
// R.2 Fase 1 · Blindaje del invariante "retail funciona SIN mesa".
//
// El rediseño de R.2 invirtió el flujo: el carrito es la fuente de verdad y
// la mesa pasa a ser un chip asignable. El riesgo máximo de este cambio es
// que una sesión de retail normal (sin mesa, sin comanda) empiece a
// depender de la lógica de restaurante.
//
// Estos tests son puros: no tocan Isar, ni Supabase, ni widgets. Verifican
// las 3 piezas que deciden si el chip se dibuja y si una comanda admite
// cambios.
import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  FeatureFlags flags(BusinessMode modo) => FeatureFlags(
        mode: modo,
        planActivo: true,
        planId: 'basico',
      );

  group('R.2 Fase 1 · el chip de mesa solo existe en restaurante', () {
    test('retail NO requiere mesa', () {
      expect(flags(BusinessMode.retail).requiereMesa, isFalse);
    });

    test('restaurante SÍ requiere mesa', () {
      expect(flags(BusinessMode.restaurante).requiereMesa, isTrue);
    });

    test('`requiereMesa` no depende del plan ni de las features', () {
      // El chip se decide SOLO por modo de negocio. Si alguien lo cuelga
      // de `featuresHabilitadas`, el restaurante básico perdería la mesa.
      final basico = FeatureFlags(
        mode: BusinessMode.restaurante,
        planActivo: true,
        planId: 'basico',
        featuresHabilitadas: const {'offline', 'reports'},
      );
      expect(basico.requiereMesa, isTrue);
    });
  });

  group('R.2 Fase 1 · una sesión retail nunca es comanda', () {
    test('sin mesa NO es comanda (retail funciona igual)', () {
      final sesion = CartSessionEntity();
      expect(sesion.mesaId, isNull);
      expect(sesion.esComanda, isFalse);
    });

    test('con mesa SÍ es comanda', () {
      final sesion = CartSessionEntity()..mesaId = 7;
      expect(sesion.esComanda, isTrue);
    });

    test('mesaId == 0 SÍ cuenta como comanda', () {
      // Documenta el límite: `esComanda` solo mira != null. El centinela 0
      // está en `MesaEntity.localId`, nunca en `CartSessionEntity.mesaId`
      // (esa id la genera Isar y arranca en 1).
      final sesion = CartSessionEntity()..mesaId = 0;
      expect(sesion.esComanda, isTrue);
    });
  });

  group('R.2 Fase 1 · matriz de estados de comanda', () {
    bool editable(ComandaEstado e) =>
        (CartSessionEntity()..comandaEstado = e).comandaEditable;

    test('abierta y enviada admiten cambios', () {
      expect(editable(ComandaEstado.abierta), isTrue);
      expect(editable(ComandaEstado.enviada), isTrue);
    });

    test('cerrada y cancelada NO admiten cambios', () {
      // El append de UX-1 se apoya en este guard: si una comanda ya fue
      // cobrada o cancelada, el carrito NO debe poder reescribirla.
      expect(editable(ComandaEstado.cerrada), isFalse);
      expect(editable(ComandaEstado.cancelada), isFalse);
    });

    test('enPreparacion y entregada NO admiten cambios (KDS R.3)', () {
      // Hoy no las usa ningún flujo, pero el guard debe incluirlas para
      // que el KDS no encuentre un cambio sobre una comanda ya en marcha.
      expect(editable(ComandaEstado.enPreparacion), isFalse);
      expect(editable(ComandaEstado.entregada), isFalse);
    });
  });

  group('R.2 Fase 1 · total de la comanda', () {
    test('suma precio × cantidad de todos los items', () {
      final comanda = CartSessionEntity()
        ..items = [
          CartSessionItem()..precioUnidad = 10.0..cantidad = 2.0,
          CartSessionItem()..precioUnidad = 3.5..cantidad = 4.0,
        ];
      expect(comanda.total, closeTo(34.0, 0.001));
    });

    // OJO: el `\$` es necesario. Sin escape, Dart lee `$0` como el inicio de
    // una interpolación y falla con `missing_identifier`.
    test('comanda vacía vale 0 (chip "Mesa 1 · \$0.00")', () {
      expect(CartSessionEntity().total, 0.0);
    });
  });
}
