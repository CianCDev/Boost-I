// test/controllers/cart_sessions_controller_test.dart
import 'dart:io';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  Directory? tempDir;
  late IsarService isar;

  setUpAll(() async {
    tempDir = await setupIsarForTest();
    isar = IsarService();
  });

  // ✅ Limpieza entre tests: cada uno arranca con la BD limpia.
  setUp(() async {
    final db = await isar.db;
    await db.writeTxn(() async {
      await db.cartSessionEntitys.clear();
    });
  });

  tearDownAll(() async {
    await tearDownIsarForTest(tempDir);
  });

  group('IsarService — sesiones de carrito', () {
    test('guarda y obtiene una sesión con items y total', () async {
      final sesion = CartSessionEntity()
        ..sessionId = 'test-1'
        ..usuarioId = 42
        ..nombre = 'Mesa 3'
        ..items = [
          CartSessionItem()
            ..productoId = '1'
            ..productoNombre = 'Coca-Cola'
            ..precioUnidad = 2.0
            ..cantidad = 3.0,
          CartSessionItem()
            ..productoId = '2'
            ..productoNombre = 'Pan'
            ..precioUnidad = 1.5
            ..cantidad = 2.0,
        ];

      await isar.guardarSesion(sesion);

      final resultado = await isar.obtenerSesionesDeUsuario(42);
      expect(resultado.length, 1);

      final s = resultado.first;
      expect(s.nombre, 'Mesa 3');
      expect(s.items.length, 2);
      expect(s.total, 9.0);
      expect(s.cantidadItems, 2);
    });

    test('respeta el aislamiento por usuarioId', () async {
      await isar.guardarSesion(CartSessionEntity()
        ..sessionId = 'userA-1'
        ..usuarioId = 100
        ..nombre = 'A1');
      await isar.guardarSesion(CartSessionEntity()
        ..sessionId = 'userA-2'
        ..usuarioId = 100
        ..nombre = 'A2');
      await isar.guardarSesion(CartSessionEntity()
        ..sessionId = 'userB-1'
        ..usuarioId = 200
        ..nombre = 'B1');

      expect(await isar.contarSesionesDeUsuario(100), 2);
      expect(await isar.contarSesionesDeUsuario(200), 1);
      expect(await isar.contarSesionesDeUsuario(999), 0);
    });

    test('elimina una sesión específica por sessionId', () async {
      await isar.guardarSesion(CartSessionEntity()
        ..sessionId = 'to-delete'
        ..usuarioId = 42
        ..nombre = 'X');

      final ok = await isar.eliminarSesion('to-delete');
      expect(ok, isTrue);

      final resto = await isar.obtenerSesionesDeUsuario(42);
      expect(resto.any((s) => s.sessionId == 'to-delete'), isFalse);
    });

    test('elimina todas las sesiones de un usuario', () async {
      await isar.guardarSesion(CartSessionEntity()
        ..sessionId = 'u42-1'
        ..usuarioId = 42
        ..nombre = 'A');
      await isar.guardarSesion(CartSessionEntity()
        ..sessionId = 'u42-2'
        ..usuarioId = 42
        ..nombre = 'B');

      final eliminadas = await isar.eliminarSesionesDeUsuario(42);
      expect(eliminadas, 2);
      expect(await isar.contarSesionesDeUsuario(42), 0);
    });

    test('marca como abandonada una sesión con más de 24h', () async {
      final viejo = CartSessionEntity()
        ..sessionId = 'viejo-1'
        ..usuarioId = 42
        ..nombre = 'Antiguo'
        ..createdAt = DateTime.now().subtract(const Duration(hours: 25))
        ..status = CartSessionStatus.enEspera;
      await isar.guardarSesion(viejo);

      final actualizadas = await isar.marcarSesionesAbandonadas(42);
      expect(actualizadas, greaterThanOrEqualTo(1));

      final sesiones = await isar.obtenerSesionesDeUsuario(42);
      final viejoDespues = sesiones.firstWhere((s) => s.sessionId == 'viejo-1');
      expect(viejoDespues.status, CartSessionStatus.abandonado);
    });

    test('NO marca abandonada una sesión reciente', () async {
      await isar.guardarSesion(CartSessionEntity()
        ..sessionId = 'nuevo-1'
        ..usuarioId = 42
        ..nombre = 'Nuevo'
        ..createdAt = DateTime.now().subtract(const Duration(hours: 1))
        ..status = CartSessionStatus.enEspera);

      await isar.marcarSesionesAbandonadas(42);

      final sesiones = await isar.obtenerSesionesDeUsuario(42);
      final nuevo = sesiones.firstWhere((s) => s.sessionId == 'nuevo-1');
      expect(nuevo.status, CartSessionStatus.enEspera);
    });

    test('getter esAbandonado funciona con timestamps viejos', () {
      final s = CartSessionEntity()
        ..createdAt = DateTime.now().subtract(const Duration(hours: 25));
      expect(s.esAbandonado, isTrue);

      final s2 = CartSessionEntity()
        ..createdAt = DateTime.now().subtract(const Duration(hours: 1));
      expect(s2.esAbandonado, isFalse);
    });
  });
}