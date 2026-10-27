// test/features/pos/lotes_vencidos_test.dart
//
// Regresión de "Null check operator used on a null value" en el diálogo
// "Lotes vencidos con stock" (2026-10-26).
//
// El bug real: en Isar un `null` ordena como MENOR que cualquier valor, así
// que `fechaVencimientoLessThan(hoy)` devolvía también los lotes SIN fecha
// de vencimiento. El diálogo hacía `lote.fechaVencimiento!` y estallaba.
// La base real tenía 18 de 19 lotes sin fecha.
//
// Corre contra Isar REAL (no un doble) porque lo que se prueba es el
// comportamiento del filtro, no la lógica de Dart.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';

LoteEntity _lote({
  required double restante,
  DateTime? vence,
  int productoId = 1,
}) {
  return LoteEntity()
    ..productoId = productoId
    ..cantidadInicial = restante
    ..cantidadRestante = restante
    ..fechaVencimiento = vence
    ..estado = 'activo';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('lotes_vencidos_');
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
        // Windows puede retener el archivo; el SO limpia %TEMP% igual.
      }
    }
  });

  test('un lote sin fecha de vencimiento NO entra en la alerta', () async {
    final isar = IsarService();
    final haceDosDias = DateTime.now().subtract(const Duration(days: 2));

    // Vencido y con stock: el único que la alerta debe mostrar.
    await isar.guardarLote(_lote(restante: 5, vence: haceDosDias));
    // Sin fecha: no está vencido, no se controla por vencimiento.
    await isar.guardarLote(_lote(restante: 7));
    // Vencido pero sin stock: no es urgente.
    await isar.guardarLote(_lote(restante: 0, vence: haceDosDias));

    final vencidos = await isar.obtenerLotesVencidosConStock();

    expect(vencidos, hasLength(1));
    expect(vencidos.single.cantidadRestante, 5);
    expect(vencidos.single.fechaVencimiento, isNotNull);
  });

  test('con varios vencidos con stock devuelve todos y ninguno sin fecha',
      () async {
    final isar = IsarService();
    final ayer = DateTime.now().subtract(const Duration(days: 1));
    final mesPasado = DateTime.now().subtract(const Duration(days: 30));

    await isar.guardarLote(_lote(restante: 2, vence: ayer, productoId: 1));
    await isar.guardarLote(_lote(restante: 4, vence: mesPasado, productoId: 2));
    await isar.guardarLote(_lote(restante: 9, productoId: 3));
    await isar.guardarLote(_lote(restante: 9, productoId: 4));

    final vencidos = await isar.obtenerLotesVencidosConStock();

    expect(vencidos, hasLength(2));
    expect(
      vencidos.every((l) => l.fechaVencimiento != null),
      isTrue,
      reason: 'un lote sin fecha nunca debe llegar al diálogo de vencidos',
    );
  });
}
