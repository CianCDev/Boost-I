// test/features/pos/suscripcion_entity_test.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/suscripcion_entity.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regresión del incidente del 2026-10-15.
///
/// `SuscripcionEntity.activa` comparaba `estado` solo contra `'activa'`
/// (femenino). El valor real de `suscripciones.estado` es `'activo'`
/// (masculino), así que TODA suscripción pagada caía en `return false`,
/// `planActivo` quedaba `false` y `FeatureFlags._plan()` cortaba en el
/// primer `&&`: el menú perdía todos los módulos con gate.
void main() {
  SuscripcionEntity build({
    required String estado,
    DateTime? periodoFin,
    DateTime? trialHasta,
  }) {
    return SuscripcionEntity()
      ..tenantId = '9c7380a4-14be-41c2-88db-07606c2a6489'
      ..planId = 'pro'
      ..estado = estado
      ..periodoFin = periodoFin
      ..trialHasta = trialHasta;
  }

  group('activa', () {
    test("'activo' (masculino, el valor real) da true sin periodoFin", () {
      // Este es el caso exacto del incidente: JAHTLABS con plan pro.
      expect(build(estado: 'activo').activa, isTrue);
    });

    test("'activa' (femenino, la grafía histórica) sigue dando true", () {
      expect(build(estado: 'activa').activa, isTrue);
    });

    test('normaliza mayúsculas y espacios', () {
      expect(build(estado: '  Activo ').activa, isTrue);
      expect(build(estado: 'ACTIVA').activa, isTrue);
      expect(build(estado: 'Trial').activa, isTrue);
    });

    test("'activo' con periodoFin futuro da true", () {
      final s = build(
        estado: 'activo',
        periodoFin: DateTime.now().add(const Duration(days: 30)),
      );
      expect(s.activa, isTrue);
    });

    test("'activo' con periodoFin vencido da false", () {
      final s = build(
        estado: 'activo',
        periodoFin: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(s.activa, isFalse);
    });

    test('trial sin trialHasta da true; con trialHasta vencido da false', () {
      expect(build(estado: 'trial').activa, isTrue);
      expect(
        build(
          estado: 'trial',
          trialHasta: DateTime.now().subtract(const Duration(days: 1)),
        ).activa,
        isFalse,
      );
    });

    test('suspendida / cancelada / desconocido dan false', () {
      for (final e in ['suspendida', 'cancelada', 'pendiente', '']) {
        expect(build(estado: e).activa, isFalse, reason: 'estado="$e"');
      }
    });
  });
}