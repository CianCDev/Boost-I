import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/zona_entity.dart';

/// R.1b · Persistencia local de zonas y mesas.
///
/// Cubre lo que el sync necesita para no duplicar ni resucitar filas:
///  · `claveUnica` compuesta por local + nombre.
///  · Borrado lógico: la mesa sale del salón pero sigue pendiente de subir.
///  · El tombstone libera el nombre (sufijo `#del<id>`).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('isar_zonas_test_');
    testDirPath = tempDir.path;

    SharedPreferences.setMockInitialValues({
      'empresa_id': 'test_${DateTime.now().microsecondsSinceEpoch}',
    });

    await IsarService.resetForTesting();
    await IsarService().initForTesting(testDirPath);
  });

  tearDown(() async {
    await IsarService.resetForTesting();

    final dir = Directory(testDirPath);
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {
        // Ignorar errores de limpieza
      }
    }
  });

  group('Zonas — CRUD local', () {
    test('guarda con claveUnica y la deja pendiente de sync', () async {
      final isar = IsarService();
      final id = await isar.guardarZona(ZonaEntity()
        ..localId = 1
        ..nombre = 'Terraza'
        ..orden = 1);

      final zona = await isar.obtenerZonaPorId(id);
      expect(zona, isNotNull);
      expect(zona!.claveUnica, '1::Terraza');
      expect(zona.sincronizado, isFalse);

      final pendientes = await isar.obtenerZonasPendientesSync();
      expect(pendientes.map((z) => z.nombre), contains('Terraza'));
    });

    test('ordena por orden y luego por nombre', () async {
      final isar = IsarService();
      await isar.guardarZona(ZonaEntity()
        ..localId = 1
        ..nombre = 'Bar'
        ..orden = 2);
      await isar.guardarZona(ZonaEntity()
        ..localId = 1
        ..nombre = 'Salón'
        ..orden = 0);
      await isar.guardarZona(ZonaEntity()
        ..localId = 1
        ..nombre = 'Terraza'
        ..orden = 1);

      final zonas = await isar.obtenerZonasDelLocal(1);
      expect(zonas.map((z) => z.nombre), ['Salón', 'Terraza', 'Bar']);
    });

    test('el borrado lógico libera el nombre para reutilizarlo', () async {
      final isar = IsarService();
      final id = await isar.guardarZona(ZonaEntity()
        ..localId = 1
        ..nombre = 'Patio');

      expect(await isar.eliminarZona(id), isTrue);

      final tombstone = await isar.obtenerZonaPorId(id);
      expect(tombstone!.eliminado, isTrue);
      expect(tombstone.claveUnica, '1::Patio#del$id');
      expect(await isar.obtenerZonasDelLocal(1), isEmpty);

      // El nombre queda libre: se puede crear otra zona igual.
      expect(await isar.existeZonaConClave('1::Patio'), isFalse);
      final nuevoId = await isar.guardarZona(ZonaEntity()
        ..localId = 1
        ..nombre = 'Patio');
      expect(nuevoId, isNot(id));
    });
  });

  group('Mesas — CRUD local', () {
    test('guarda zonaNombre y zonaEfectiva la prefiere', () async {
      final isar = IsarService();
      final id = await isar.guardarMesa(MesaEntity()
        ..localId = 1
        ..nombre = 'Mesa 1'
        ..zona = MesaZona.salon
        ..zonaNombre = 'Patio'
        ..capacidad = 2);

      final mesa = await isar.obtenerMesaPorId(id);
      expect(mesa, isNotNull);
      expect(mesa!.zonaNombre, 'Patio');
      expect(mesa.zonaEfectiva, 'Patio');
      expect(mesa.sincronizado, isFalse);
    });

    test('zonaEfectiva cae al enum legacy si no hay nombre', () async {
      final isar = IsarService();
      final id = await isar.guardarMesa(MesaEntity()
        ..localId = 1
        ..nombre = 'Mesa 2'
        ..zona = MesaZona.terraza);

      final mesa = await isar.obtenerMesaPorId(id);
      expect(mesa!.zonaEfectiva, 'Terraza');
    });

    test('el borrado lógico la saca del salón y la deja pendiente',
        () async {
      final isar = IsarService();
      final id = await isar.guardarMesa(MesaEntity()
        ..localId = 1
        ..nombre = 'Mesa 3');

      expect(await isar.eliminarMesa(id), isTrue);

      expect(await isar.obtenerMesasDelLocal(1), isEmpty);
      final pendientes = await isar.obtenerMesasPendientesSync();
      final tombstone = pendientes.firstWhere((m) => m.id == id);
      expect(tombstone.eliminado, isTrue);
      expect(tombstone.claveUnica, '1::Mesa 3#del$id');
    });

    test('obtenerMesaPorNombre encuentra tombstones', () async {
      final isar = IsarService();
      final id = await isar.guardarMesa(MesaEntity()
        ..localId = 1
        ..nombre = 'Mesa 4');
      await isar.eliminarMesa(id);

      final encontrada = await isar.obtenerMesaPorNombre(1, 'Mesa 4');
      expect(encontrada, isNotNull);
      expect(encontrada!.id, id);
      expect(encontrada.eliminado, isTrue);
    });
  });

  group('MesaEntity — helpers de zona', () {
    test('mesaZonaDesdeNombre mapea las zonas históricas', () {
      expect(mesaZonaDesdeNombre('Salón'), MesaZona.salon);
      expect(mesaZonaDesdeNombre('Terraza'), MesaZona.terraza);
      expect(mesaZonaDesdeNombre('BAR'), MesaZona.bar);
      expect(mesaZonaDesdeNombre('Privado'), MesaZona.privado);
      expect(mesaZonaDesdeNombre('vip'), MesaZona.vip);
    });

    test('una zona nueva cae a salon sin perder el nombre', () {
      expect(mesaZonaDesdeNombre('Patio'), MesaZona.salon);
      final mesa = MesaEntity()
        ..zonaNombre = 'Patio'
        ..zona = mesaZonaDesdeNombre('Patio');
      expect(mesa.zonaEfectiva, 'Patio');
    });
  });
}
