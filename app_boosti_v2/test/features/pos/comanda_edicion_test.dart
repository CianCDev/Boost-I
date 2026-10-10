// test/features/pos/comanda_edicion_test.dart
//
// R.3.2 PASO C · Edición del pedido desde ComandaScreen.
//
// Cubre las tres piezas nuevas del provider:
//
//   · `puedeEditarItem` (puro, estático) → matriz de los 6 estados.
//   · `cambiarCantidadItem` → clampeo y rechazo por estado.
//   · `actualizarNotaItem` → recorte y borrado.
//
// ⚠️ `cambiarCantidadItem` y `actualizarNotaItem` son métodos de
// `ComandasNotifier`, NO de `IsarService`. Hace falta `ProviderContainer` +
// `comandasProviderConIsar`, con el mismo override de `localActualProvider`
// que usa `kds_fase_a_test.dart` (sin él, `cargar()` corta por
// `localId == null` y `state.comandas` queda vacío).
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/comanda_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart';

CartSessionItem item({
  String nombre = 'Plato',
  EstadoPlato estado = EstadoPlato.pendiente,
  bool esPesado = false,
  double cantidad = 1,
  String? nota,
}) {
  return CartSessionItem()
    ..productoId = nombre
    ..productoNombre = nombre
    ..precioUnidad = 10.0
    ..cantidad = cantidad
    ..esPesado = esPesado
    ..estadoPlato = estado
    ..nota = nota;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ══════════════════════════════════════════════════════════════
  // 1 · Puro (no necesita Isar)
  // ══════════════════════════════════════════════════════════════

  group('puedeEditarItem · matriz de 6 estados', () {
    bool editable(EstadoPlato e) =>
        ComandasNotifier.puedeEditarItem(item(estado: e));

    test('pendiente, enCola y enPreparacion SÍ admiten cambios', () {
      expect(editable(EstadoPlato.pendiente), isTrue);
      expect(editable(EstadoPlato.enCola), isTrue);
      expect(editable(EstadoPlato.enPreparacion), isTrue);
    });

    test('listo, entregado y cancelado NO admiten cambios', () {
      expect(editable(EstadoPlato.listo), isFalse);
      expect(editable(EstadoPlato.entregado), isFalse);
      // `cancelado` no venía en la especificación original de P1, pero un
      // plato que el mesero quitó de la barra no puede seguir editándose.
      expect(editable(EstadoPlato.cancelado), isFalse);
    });

    test('solo 3 de los 6 estados son editables', () {
      final editables = EstadoPlato.values
          .where((e) => ComandasNotifier.puedeEditarItem(item(estado: e)))
          .toSet();
      expect(editables, {
        EstadoPlato.pendiente,
        EstadoPlato.enCola,
        EstadoPlato.enPreparacion,
      });
    });
  });

  group('constantes de edición', () {
    test('minimoCantidadItem: 1 normal, 0.001 pesado', () {
      expect(ComandasNotifier.minimoCantidadItem(false), 1.0);
      expect(ComandasNotifier.minimoCantidadItem(true), 0.001);
    });

    test('la nota (100) y la pausa (60) tienen topes distintos', () {
      expect(ComandasNotifier.maxCharsNotaItem, 100);
      expect(ComandasNotifier.maxCharsMotivoPausa, 60);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // 2 · Contra Isar real, a través del notifier
  // ══════════════════════════════════════════════════════════════

  group('cambiarCantidadItem', () {
    late String testDirPath;

    setUp(() async {
      final tempDir = Directory.systemTemp.createTempSync('comanda_ed_');
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
          // La limpieza del temp no debe romper la suite.
        }
      }
    });

    Future<int> comandaCon(List<CartSessionItem> items) async {
      final isar = IsarService();
      final mesaId = await isar.guardarMesa(
        MesaEntity()
          ..localId = 1
          ..nombre = 'Mesa Edit'
          ..estado = MesaEstado.ocupada,
      );
      return isar.guardarComanda(
        CartSessionEntity()
          ..sessionId = 'mesa:$mesaId'
          ..nombre = 'Comanda Edit'
          ..usuarioId = 1
          ..mesaId = mesaId
          ..comandaEstado = ComandaEstado.abierta
          ..items = items
          ..itemsNombres = items.map((i) => i.productoNombre).toList(),
      );
    }

    Future<CartSessionItem> releer(int comandaId, int index) async {
      final c = await IsarService().obtenerComandaPorId(comandaId);
      return c!.items[index];
    }

    /// Monta el notifier real contra el Isar de este test.
    Future<void> conNotifier(
      Future<void> Function(ComandasNotifier) cuerpo,
    ) async {
      final container = ProviderContainer(
        overrides: [
          localActualProvider.overrideWith((ref) {
            return LocalActualNotifier(ref, isar: IsarService())..state = 1;
          }),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(comandasProviderConIsar.notifier);
      await notifier.esperarCargaInicial;
      await cuerpo(notifier);
    }

    for (final estado in [
      EstadoPlato.pendiente,
      EstadoPlato.enCola,
      EstadoPlato.enPreparacion,
    ]) {
      test('OK en ${estado.name}', () async {
        final id = await comandaCon([item(estado: estado, cantidad: 2)]);

        await conNotifier((n) async {
          expect(await n.cambiarCantidadItem(id, 0, 1), isTrue);
        });
        expect((await releer(id, 0)).cantidad, 3.0);
      });
    }

    for (final estado in [
      EstadoPlato.listo,
      EstadoPlato.entregado,
      EstadoPlato.cancelado,
    ]) {
      test('RECHAZA en ${estado.name}', () async {
        final id = await comandaCon([item(estado: estado, cantidad: 2)]);

        await conNotifier((n) async {
          expect(await n.cambiarCantidadItem(id, 0, 1), isFalse);
        });
        expect((await releer(id, 0)).cantidad, 2.0,
            reason: 'no debe haberse tocado');
      });
    }

    test('resta hasta 1 y clampea, NO elimina la fila', () async {
      final id = await comandaCon([item(cantidad: 3)]);

      await conNotifier((n) async {
        expect(await n.cambiarCantidadItem(id, 0, -1), isTrue);
        expect((await releer(id, 0)).cantidad, 2.0);

        expect(await n.cambiarCantidadItem(id, 0, -1), isTrue);
        expect((await releer(id, 0)).cantidad, 1.0);

        // Sigue restando: clampea.
        expect(await n.cambiarCantidadItem(id, 0, -1), isTrue);
        final c = await IsarService().obtenerComandaPorId(id);
        expect(c!.items.length, 1, reason: 'la fila NO se elimina');
        expect(c.items.first.cantidad, 1.0);
      });
    });

    test('pesado clampea a 0.001, no a 0', () async {
      final id = await comandaCon([item(esPesado: true, cantidad: 0.5)]);

      await conNotifier((n) async {
        expect(await n.cambiarCantidadItem(id, 0, -1), isTrue);
      });
      expect((await releer(id, 0)).cantidad, 0.001);
    });

    test('un delta enorme clampea en vez de dar negativo', () async {
      final id = await comandaCon([item(cantidad: 2)]);

      await conNotifier((n) async {
        expect(await n.cambiarCantidadItem(id, 0, -999), isTrue);
      });
      expect((await releer(id, 0)).cantidad, 1.0);
    });

    test('un delta de 0 no rompe nada', () async {
      final id = await comandaCon([item(cantidad: 2)]);

      await conNotifier((n) async {
        expect(await n.cambiarCantidadItem(id, 0, 0), isTrue);
      });
      expect((await releer(id, 0)).cantidad, 2.0);
    });

    test('índice fuera de rango se rechaza', () async {
      final id = await comandaCon([item()]);

      await conNotifier((n) async {
        expect(await n.cambiarCantidadItem(id, 7, 1), isFalse);
        expect(await n.cambiarCantidadItem(id, -1, 1), isFalse);
        expect(await n.cambiarCantidadItem(999999, 0, 1), isFalse);
      });
    });

    test('NO toca los demás items (índice real, no posición filtrada)',
        () async {
      final id = await comandaCon([
        item(nombre: 'oculto-0', estado: EstadoPlato.listo, cantidad: 5),
        item(nombre: 'editable-1', estado: EstadoPlato.enCola, cantidad: 2),
        item(nombre: 'oculto-2', estado: EstadoPlato.entregado, cantidad: 7),
      ]);

      await conNotifier((n) async {
        expect(await n.cambiarCantidadItem(id, 1, 1), isTrue);
      });

      final c = (await IsarService().obtenerComandaPorId(id))!;
      expect(c.items[0].cantidad, 5.0, reason: 'listo intacto');
      expect(c.items[1].cantidad, 3.0, reason: 'este era el objetivo');
      expect(c.items[2].cantidad, 7.0, reason: 'entregado intacto');
    });

    test('cambiar la cantidad NO borra la nota', () async {
      final id = await comandaCon([item(nota: 'sin cebolla', cantidad: 1)]);

      await conNotifier((n) async {
        await n.cambiarCantidadItem(id, 0, 3);
      });

      final leida = await releer(id, 0);
      expect(leida.cantidad, 4.0);
      expect(leida.nota, 'sin cebolla');
    });
  });

  group('actualizarNotaItem', () {
    late String testDirPath;

    setUp(() async {
      final tempDir = Directory.systemTemp.createTempSync('comanda_nota_');
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
          // La limpieza del temp no debe romper la suite.
        }
      }
    });

    Future<int> comandaCon(List<CartSessionItem> items) async {
      final isar = IsarService();
      final mesaId = await isar.guardarMesa(
        MesaEntity()
          ..localId = 1
          ..nombre = 'Mesa Nota'
          ..estado = MesaEstado.ocupada,
      );
      return isar.guardarComanda(
        CartSessionEntity()
          ..sessionId = 'mesa:$mesaId'
          ..nombre = 'Comanda Nota'
          ..usuarioId = 1
          ..mesaId = mesaId
          ..comandaEstado = ComandaEstado.abierta
          ..items = items
          ..itemsNombres = items.map((i) => i.productoNombre).toList(),
      );
    }

    Future<CartSessionItem> releer(int comandaId, int index) async {
      final c = await IsarService().obtenerComandaPorId(comandaId);
      return c!.items[index];
    }

    Future<void> conNotifier(
      Future<void> Function(ComandasNotifier) cuerpo,
    ) async {
      final container = ProviderContainer(
        overrides: [
          localActualProvider.overrideWith((ref) {
            return LocalActualNotifier(ref, isar: IsarService())..state = 1;
          }),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(comandasProviderConIsar.notifier);
      await notifier.esperarCargaInicial;
      await cuerpo(notifier);
    }

    test('guarda el texto', () async {
      final id = await comandaCon([item()]);

      await conNotifier((n) async {
        expect(await n.actualizarNotaItem(id, 0, 'sin cebolla'), isTrue);
      });
      expect((await releer(id, 0)).nota, 'sin cebolla');
    });

    test('recorta a 100 caracteres', () async {
      final id = await comandaCon([item()]);

      await conNotifier((n) async {
        expect(await n.actualizarNotaItem(id, 0, 'a' * 250), isTrue);
      });
      expect((await releer(id, 0)).nota!.length, 100);
    });

    test('vacío o en blanco → null (borra la nota)', () async {
      final id = await comandaCon([item(nota: 'antes')]);

      await conNotifier((n) async {
        expect(await n.actualizarNotaItem(id, 0, ''), isTrue);
        expect((await releer(id, 0)).nota, isNull);

        await n.actualizarNotaItem(id, 0, 'otra vez');
        expect(await n.actualizarNotaItem(id, 0, '    '), isTrue);
      });
      expect((await releer(id, 0)).nota, isNull);
    });

    test('trim: quita espacios de los bordes', () async {
      final id = await comandaCon([item()]);

      await conNotifier((n) async {
        expect(await n.actualizarNotaItem(id, 0, '  extra queso  '), isTrue);
      });
      expect((await releer(id, 0)).nota, 'extra queso');
    });

    test('RECHAZA en un plato listo', () async {
      final id = await comandaCon([
        item(estado: EstadoPlato.listo, nota: 'original'),
      ]);

      await conNotifier((n) async {
        expect(await n.actualizarNotaItem(id, 0, 'otro'), isFalse);
      });
      expect((await releer(id, 0)).nota, 'original');
    });

    test('RECHAZA en una comanda cerrada', () async {
      final id = await comandaCon([item(nota: 'original')]);

      final c = await IsarService().obtenerComandaPorId(id);
      c!.comandaEstado = ComandaEstado.cerrada;
      await IsarService().guardarComanda(c);

      await conNotifier((n) async {
        expect(await n.actualizarNotaItem(id, 0, 'otro'), isFalse);
      });
      expect((await releer(id, 0)).nota, 'original');
    });

    test('indice fuera de rango se rechaza', () async {
      final id = await comandaCon([item()]);

      await conNotifier((n) async {
        expect(await n.actualizarNotaItem(id, 9, 'x'), isFalse);
        expect(await n.actualizarNotaItem(999999, 0, 'x'), isFalse);
      });
    });

    test('la nota y el snapshot de imagen sobreviven al round-trip',
        () async {
      final conImagen = item(nota: 'con foto')
        ..imagenUrl = 'https://ejemplo.com/plato.jpg';
      final id = await comandaCon([conImagen]);

      await conNotifier((n) async {
        expect(await n.actualizarNotaItem(id, 0, 'sin sal'), isTrue);
      });

      final leida = await releer(id, 0);
      expect(leida.nota, 'sin sal');
      expect(leida.imagenUrl, 'https://ejemplo.com/plato.jpg',
          reason: 'el snapshot de imagen no debe perderse al editar');
    });
  });
}
