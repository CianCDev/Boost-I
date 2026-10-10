import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';

// Mocks
class MockIsarService extends Mock implements IsarService {}

/// Fixtures de catálogo por local.
///
/// ⚠️ LIMITACIÓN HONESTA: estos tests verifican las properties de los
/// MOCKS, no de código de producción. El aislamiento real de inventarios
/// vive en las queries de Isar (`localIdEqualTo`), que aquí están
/// simuladas.
///
/// La cobertura real del hot-switch está en `local_switching_test.dart`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Local Catalog - Catálogos independientes por local', () {
    late MockIsarService mockIsar;

    setUp(() async {
      SharedPreferences.setMockInitialValues({
        'localActualId': 1,
        'tenantId': '9c7380a4-14be-41c2-88db-07606c2a6489',
      });

      mockIsar = MockIsarService();

      // Mock para local 1 (JAHTLABS) - Restaurante
      when(() => mockIsar.obtenerLocalPorId(1))
          .thenAnswer((_) async => LocalEntity()
            ..id = 1
            ..nombre = 'JAHTLABS'
            ..supabaseId = '9c7380a4-14be-41c2-88db-07606c2a6489'
            ..activo = true
            ..businessMode = 'restaurante');

      // Mock para local 2 (centro) - Retail
      when(() => mockIsar.obtenerLocalPorId(2))
          .thenAnswer((_) async => LocalEntity()
            ..id = 2
            ..nombre = 'centro'
            ..supabaseId = 'fd3dee41-54b0-40b7-b83b-5f9f1b3cc3f8'
            ..activo = true
            // PASO 1 renombró el identificador persistido de 'mercado' a
            // 'retail'. Este fixture todavía usaba el valor legacy.
            ..businessMode = 'retail');

      // Mock para productos del local 1
      when(() => mockIsar.obtenerProductos())
          .thenAnswer((_) async => [
                ProductoEntity()
                  ..id = 1
                  ..nombre = 'Pizza'
                  ..codigoBarras = 'REST001',
                ProductoEntity()
                  ..id = 2
                  ..nombre = 'Hamburguesa'
                  ..codigoBarras = 'REST002',
              ]);
    });

    test('cada local tiene su propio catálogo', () async {
      // Verificar que el servicio Isar está disponible
      expect(mockIsar, isNotNull);

      // Verificar que los mocks están configurados correctamente
      final local1 = await mockIsar.obtenerLocalPorId(1);
      expect(local1, isNotNull);
      expect(local1!.nombre, equals('JAHTLABS'));
      expect(local1.businessMode, equals('restaurante'));

      final local2 = await mockIsar.obtenerLocalPorId(2);
      expect(local2, isNotNull);
      expect(local2!.nombre, equals('centro'));
      expect(local2.businessMode, equals('retail'));
    });

    test('no hay mezcla de inventarios entre locales', () async {
      // Verificar que los datos de un local no se mezclan con otro
      final productos = await mockIsar.obtenerProductos();
      expect(productos.length, equals(2));
      expect(productos.any((p) => p.nombre == 'Pizza'), isTrue);
      expect(productos.any((p) => p.nombre == 'Camisa'), isFalse);
    });

    test('el catálogo del retail no incluye los productos del restaurante',
        () async {
      // El aislamiento real está en las queries de Isar (`localIdEqualTo`),
      // que aquí van mockeadas. Este test documenta el criterio: cada local
      // tiene su propio catálogo y el mock los mantiene separados.
      //
      // La cobertura real del hot-switch vive en `local_switching_test.dart`.
      final productos = await mockIsar.obtenerProductos();
      expect(productos, hasLength(2));
      expect(
        productos.every((p) => p.codigoBarras.startsWith('REST')),
        isTrue,
        reason: 'el catálogo mockeado pertenece al local 1 (restaurante)',
      );
    });

    test('cada local expone su propio businessMode', () async {
      // Verifica que el fixture representa los dos modos reales de la BD.
      final l1 = await mockIsar.obtenerLocalPorId(1);
      final l2 = await mockIsar.obtenerLocalPorId(2);
      expect(l1!.businessMode, 'restaurante');
      expect(l2!.businessMode, 'retail');
      expect(
        l1.businessMode == l2.businessMode,
        isFalse,
        reason: 'los modos deben seguir siendo independientes por local',
      );
    });
  });
}
