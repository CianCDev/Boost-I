// test/features/pos/kds_envio_test.dart
//
// Regresión de "envío a cocina pero el KDS sigue vacío" (2026-10-23).
//
// El bug real: `ComandasNotifier.enviarACocina` primero marcaba los items
// como `enCola` con `IsarService.marcarPendientesComoEnCola` (que trabaja
// sobre SU propia instancia leída dentro de la transacción) y después
// guardaba la copia del estado —todavía con los items en `pendiente`—.
// El segundo `put` pisaba el primero, así que el plato nunca aparecía en
// cocina aunque el ticket de papel sí se imprimiera.
//
// Estos tests corren contra Isar REAL (como `comanda_edicion_test.dart`)
// porque el bug es de secuencia lectura/escritura: un doble de `IsarService`
// que devolviera la misma instancia no lo habría detectado nunca.
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
  double cantidad = 1,
}) {
  return CartSessionItem()
    ..productoId = nombre
    ..productoNombre = nombre
    ..precioUnidad = 10.0
    ..cantidad = cantidad
    ..estadoPlato = estado;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('kds_envio_');
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
        ..nombre = 'Mesa Envío'
        ..estado = MesaEstado.ocupada,
    );
    return isar.guardarComanda(
      CartSessionEntity()
        ..sessionId = 'mesa:$mesaId'
        ..nombre = 'Comanda Envío'
        ..usuarioId = 1
        ..mesaId = mesaId
        ..comandaEstado = ComandaEstado.abierta
        ..items = items
        ..itemsNombres = items.map((i) => i.productoNombre).toList(),
    );
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

  test('enviarACocina deja los platos en enCola y la comanda enviada',
      () async {
    final id = await comandaCon([item(nombre: 'Pabellón')]);

    await conNotifier((n) async {
      n.seleccionarComanda(id);
      final enviados = await n.enviarACocina();
      expect(enviados, isNotNull, reason: 'había 1 plato pendiente');
      expect(enviados!.single.estadoPlato, EstadoPlato.pendiente,
          reason: 'la copia devuelta es la de ANTES de marcar');
    });

    final c = await IsarService().obtenerComandaPorId(id);
    expect(c, isNotNull);
    expect(c!.comandaEstado, ComandaEstado.enviada);
    expect(c.items.single.estadoPlato, EstadoPlato.enCola,
        reason: 'el put final no debe pisar el enCola');
    expect(c.items.single.enviadoACocinaAt, isNotNull);
  });

  test('tras enviar, ticketsEnCola del KDS tiene el ticket', () async {
    final id = await comandaCon([item(nombre: 'Pabellón')]);

    await conNotifier((n) async {
      n.seleccionarComanda(id);
      await n.enviarACocina();
      expect(n.state.ticketsEnCola, hasLength(1));
      expect(n.state.ticketsEnCola.single.items.single.item.estadoPlato,
          EstadoPlato.enCola);
      expect(n.state.totalItemsEnKds, 1);
    });
  });

  test('re-volcar el carrito NO devuelve a pendiente lo ya enviado', () async {
    final id = await comandaCon([
      item(nombre: 'Pabellón', estado: EstadoPlato.enCola),
    ]);

    await conNotifier((n) async {
      n.seleccionarComanda(id);
      final nuevo = item(nombre: 'Pabellón', cantidad: 2);
      expect(
        await n.guardarDesdeCarrito(items: [nuevo], silencioso: true),
        isTrue,
      );
    });

    final c = await IsarService().obtenerComandaPorId(id);
    expect(c!.items.single.cantidad, 2.0,
        reason: 'la cantidad sí manda desde el carrito');
    expect(c.items.single.estadoPlato, EstadoPlato.enCola,
        reason: 'la trazabilidad de cocina sobrevive al volcado');
  });
}
