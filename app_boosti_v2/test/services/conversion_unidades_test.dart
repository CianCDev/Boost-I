// test/services/conversion_unidades_test.dart
//
// R.4 · Conversión de unidades receta → inventario.
//
// Puro Dart: no abre Isar ni monta widgets.
import 'package:app_boosti_v2/features/pos/presentation/services/conversion_unidades.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('factor · misma unidad', () {
    test('misma unidad devuelve 1', () {
      expect(ConversionUnidades.factor('kg', 'kg'), 1.0);
      expect(ConversionUnidades.factor('g', 'g'), 1.0);
      expect(ConversionUnidades.factor('unidad', 'unidad'), 1.0);
    });

    test('los sinónimos cuentan como la misma unidad', () {
      expect(ConversionUnidades.factor('kilos', 'kg'), 1.0);
      expect(ConversionUnidades.factor('gramos', 'g'), 1.0);
      expect(ConversionUnidades.factor('lt', 'litros'), 1.0);
      expect(ConversionUnidades.factor('und', 'unidad'), 1.0);
    });
  });

  group('factor · conversiones reales', () {
    test('gramos a kilos', () {
      expect(ConversionUnidades.factor('g', 'kg'), closeTo(0.001, 1e-12));
    });

    test('kilos a gramos', () {
      expect(ConversionUnidades.factor('kg', 'g'), closeTo(1000, 1e-9));
    });

    test('mililitros a litros y viceversa', () {
      expect(ConversionUnidades.factor('ml', 'lt'), closeTo(0.001, 1e-12));
      expect(ConversionUnidades.factor('lt', 'ml'), closeTo(1000, 1e-9));
    });

    test('acepta mayúsculas y espacios', () {
      expect(ConversionUnidades.factor(' G ', 'Kg'), closeTo(0.001, 1e-12));
    });
  });

  group('factor · dimensiones incompatibles', () {
    test('masa contra conteo no se convierte', () {
      expect(ConversionUnidades.factor('kg', 'unidad'), isNull);
      expect(ConversionUnidades.factor('g', 'unidad'), isNull);
    });

    test('masa contra volumen no se convierte', () {
      expect(ConversionUnidades.factor('kg', 'lt'), isNull);
      expect(ConversionUnidades.factor('ml', 'g'), isNull);
    });

    test('volumen contra conteo no se convierte', () {
      expect(ConversionUnidades.factor('lt', 'unidad'), isNull);
    });
  });

  group('normalizar', () {
    test('vacío o null cae a unidad', () {
      expect(ConversionUnidades.normalizar(null), 'unidad');
      expect(ConversionUnidades.normalizar('   '), 'unidad');
    });

    test('una unidad desconocida cae a unidad, no rompe', () {
      // Preferimos un 1:1 silencioso a reventar el descuento de un plato
      // ya entregado.
      expect(ConversionUnidades.normalizar('docena'), 'unidad');
      expect(ConversionUnidades.factor('docena', 'unidad'), 1.0);
    });
  });

  group('convertir', () {
    test('aplica el factor', () {
      expect(
        ConversionUnidades.convertir(150, desde: 'g', hasta: 'kg'),
        closeTo(0.15, 1e-12),
      );
      expect(
        ConversionUnidades.convertir(0.75, desde: 'lt', hasta: 'ml'),
        closeTo(750, 1e-9),
      );
    });

    test('devuelve null si no se puede convertir', () {
      expect(
        ConversionUnidades.convertir(3, desde: 'unidad', hasta: 'kg'),
        isNull,
      );
    });
  });
}
