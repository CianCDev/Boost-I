// test/services/sync_service_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../helpers/test_helpers.dart';

void main() {
  // ✅ Necesario para poder usar SharedPreferences + Supabase.initialize
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  bool supabaseInitialized = false;

  /// Mock por defecto que responde OK a todo.
  MockClient defaultMock({void Function(http.Request req)? onRequest}) {
    return MockClient((req) async {
      onRequest?.call(req);
      if (req.method == 'POST') return http.Response('[]', 201);
      if (req.method == 'PATCH') return http.Response('[]', 200);
      if (req.method == 'DELETE') return http.Response('', 204);
      return http.Response('[]', 200);
    });
  }

  setUpAll(() async {
    tempDir = await setupIsarForTest();
  });

  tearDownAll(() async {
    await tearDownIsarForTest(tempDir);
  });

  setUp(() async {
    final db = await IsarService().db;
    await db.writeTxn(() async => db.clear());

    // Prefs mockeadas (lo pide Supabase.initialize)
    SharedPreferences.setMockInitialValues({});
  });

  /// Reemplaza el cliente HTTP del singleton Supabase.
  Future<void> reinitSupabase(MockClient mock) async {
    if (!supabaseInitialized) {
      await Supabase.initialize(
        url: 'https://test.supabase.co',
        publishableKey: 'test-anon-key',
        httpClient: mock,
      );
      supabaseInitialized = true;
    }
  }

  // ════════════════════════════════════════════════════════════
  // BUILDERS
  // ════════════════════════════════════════════════════════════

  VentaEntity buildVenta({
    int id = 1,
    String idSupabase = 'uuid-venta-1',
    double total = 100.0,
    String syncStatus = 'pending',
  }) {
    return VentaEntity()
      ..id = id
      ..idSupabase = idSupabase
      ..total = total
      ..subtotal = total
      ..impuesto = 0.0
      ..tasaBcv = 36.5
      ..totalBolivares = total * 36.5
      ..fecha = DateTime(2026, 1, 15, 10, 0)
      ..metodoPago = 'Efectivo'
      ..documento = 0
      ..empleado = 'Cajero'
      ..syncStatus = syncStatus;
  }

  LocalEntity buildLocal({
    int id = 1,
    String supabaseId = 'uuid-local-1',
  }) {
    return LocalEntity()
      ..id = id
      ..nombre = 'Local Test'
      ..supabaseId = supabaseId
      ..activo = true
      ..sincronizado = true;
  }

  SyncService buildSync() => SyncService();

  // ════════════════════════════════════════════════════════════
  // VENTAS PENDIENTES
  // ════════════════════════════════════════════════════════════

  group('SyncService — ventas pendientes', () {
    test('sin ventas pendientes: no hace requests y devuelve 0', () async {
      await reinitSupabase(
        MockClient((req) async {
          fail('No debería hacer HTTP: ${req.url}');
        }),
      );

      var requestCount = 0;
      final sync = buildSync();
      final enviadas = await sync.sincronizarVentasPendientes();

      expect(enviadas, 0);
      expect(requestCount, 0);
    });

    test('solo envía ventas con syncStatus="pending"', () async {
      final idsEnviados = <String>[];
      await reinitSupabase(MockClient((req) async {
        if (req.method == 'POST' && req.url.path.contains('/ventas')) {
          final decoded = jsonDecode(req.body);
          final rows = decoded is List ? decoded : [decoded];
          for (final r in rows) {
            final idStr = r['id'] as String?;
            if (idStr != null) idsEnviados.add(idStr);
          }
        }
        return http.Response('[]', 201);
      }));

      final db = await IsarService().db;
      await db.writeTxn(() async {
        await db.ventaEntitys.putAll([
          buildVenta(id: 1, idSupabase: 'uuid-1', syncStatus: 'pending'),
          buildVenta(id: 2, idSupabase: 'uuid-2', syncStatus: 'synced'),
          buildVenta(id: 3, idSupabase: 'uuid-3', syncStatus: 'pending'),
        ]);
      });

      final sync = buildSync();
      await sync.sincronizarVentasPendientes();

      expect(idsEnviados, containsAll(['uuid-1', 'uuid-3']));
      expect(idsEnviados, isNot(contains('uuid-2')));
    });

    test('marca syncStatus="synced" tras éxito', () async {
      await reinitSupabase(defaultMock());

      final db = await IsarService().db;
      await db.writeTxn(() async {
        await db.ventaEntitys.put(buildVenta(id: 1, idSupabase: 'uuid-1'));
      });

      final sync = buildSync();
      await sync.sincronizarVentasPendientes();

      final venta = await db.ventaEntitys.get(1);
      expect(venta!.syncStatus, 'synced');
    });

    test('marca syncStatus="failed" si el server responde 500', () async {
      await reinitSupabase(MockClient((_) async =>
          http.Response('boom', 500)));

      final db = await IsarService().db;
      await db.writeTxn(() async {
        await db.ventaEntitys.put(buildVenta(id: 1, idSupabase: 'uuid-1'));
      });

      final sync = buildSync();
      await sync.sincronizarVentasPendientes();

      final venta = await db.ventaEntitys.get(1);
      expect(venta!.syncStatus, 'failed');
    });

    test('si el server lanza excepción, marca "failed" sin crashear',
        () async {
      await reinitSupabase(MockClient((_) async {
        throw const SocketException('Sin conexión');
      }));

      final db = await IsarService().db;
      await db.writeTxn(() async {
        await db.ventaEntitys.put(buildVenta(id: 1, idSupabase: 'uuid-1'));
      });

      final sync = buildSync();
      await sync.sincronizarVentasPendientes();

      final venta = await db.ventaEntitys.get(1);
      expect(venta!.syncStatus, 'failed');
    });

    test('si una venta falla, las demás se siguen enviando', () async {
      await reinitSupabase(MockClient((req) async {
        if (req.method == 'POST' && req.url.path.contains('/ventas')) {
          final decoded = jsonDecode(req.body);
          final rows = decoded is List ? decoded : [decoded];
          if (rows.isNotEmpty && rows[0]['id'] == 'uuid-bad') {
            return http.Response('err', 500);
          }
        }
        return http.Response('[]', 201);
      }));

      final db = await IsarService().db;
      await db.writeTxn(() async {
        await db.ventaEntitys.putAll([
          buildVenta(id: 1, idSupabase: 'uuid-ok-1'),
          buildVenta(id: 2, idSupabase: 'uuid-bad'),
          buildVenta(id: 3, idSupabase: 'uuid-ok-2'),
        ]);
      });

      final sync = buildSync();
      await sync.sincronizarVentasPendientes();

      expect((await db.ventaEntitys.get(1))!.syncStatus, 'synced');
      expect((await db.ventaEntitys.get(2))!.syncStatus, 'failed');
      expect((await db.ventaEntitys.get(3))!.syncStatus, 'synced');
    });
  });

  // ════════════════════════════════════════════════════════════
  // IDEMPOTENCIA
  // ════════════════════════════════════════════════════════════

  group('SyncService — idempotencia', () {
    test('llamar dos veces no reenvía las ya sincronizadas', () async {
      var inserts = 0;
      final mock = MockClient((req) async {
        if (req.method == 'POST' && req.url.path.contains('/ventas')) {
          inserts++;
        }
        return http.Response('[]', 201);
      });

      await reinitSupabase(mock);

      final db = await IsarService().db;
      await db.writeTxn(() async {
        await db.ventaEntitys.put(buildVenta(id: 1, idSupabase: 'uuid-1'));
      });

      final sync = buildSync();
      await sync.sincronizarVentasPendientes();
      await sync.sincronizarVentasPendientes();

      expect(inserts, greaterThanOrEqualTo(1));
      final venta = await db.ventaEntitys.get(1);
      expect(venta!.syncStatus, 'synced');
    });
  });

  // ════════════════════════════════════════════════════════════
  // CONFIGURACIÓN DE TESTS
  // ════════════════════════════════════════════════════════════

  group('SyncService — configuración de tests', () {
    test('IsarService().db expone la base abierta', () async {
      final db = await IsarService().db;
      expect(db.isOpen, isTrue);
    });

    test('seed de LocalEntity activo queda disponible', () async {
      final db = await IsarService().db;
      await db.writeTxn(() async {
        await db.localEntitys.put(buildLocal());
      });

      final local = await IsarService().obtenerLocalActivo();
      expect(local, isNotNull);
      expect(local!.supabaseId, 'uuid-local-1');
    });
  });
}