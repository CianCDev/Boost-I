// test/features/pos/descuento_receta_test.dart
//
// R.4 · G.3 · Descuento de ingredientes por receta al marcar un plato
// como entregado.
//
// ⚠️ POR QUÉ `test()` Y NO `testWidgets()`
//
// `testWidgets` corre dentro de un `FakeAsync`: el reloj y las colas de
// microtasks están controladas. Isar habla con un isolate REAL, y todo `await`
// a su I/O se queda colgado para siempre. Por eso TODOS los tests de este
// archivo son planos, con `ProviderContainer` en vez de `tester.pumpWidget`.
// Patrón copiado de `kds_fase_a_test.dart`.
//
// ⚠️ `_descontarRecetaDeItem` ES PRIVADA
//
// No se sube a `@visibleForTesting`: se alcanza por la vía PÚBLICA
// `marcarEntregado(comandaId, itemIndex)`, que es como la llama el KDS. Probar
// por la puerta pública es además lo que verifica de verdad el contrato real
// (transición válida → escritura → descuento), no un detalle interno.
//
// ⚠️ PRECONDICIONES QUE NO SON OBVIAS
//
//   · Cada item debe estar en `listo`: la matriz de transiciones solo admite
//     `listo → entregado`.
//   · Cada lote necesita `estado = 'activo'`. El default de `LoteEntity.estado`
//     es `'pendiente'` y `obtenerLotesActivos` filtra por `'activo'`, así que
//     un lote sin eso es INVISIBLE para el FEFO y todo ingrediente caería en
//     `faltantes`.
//   · `productoIdLocal` hay que ponerlo a mano: el mapper async que lo rellena
//     solo corre al volcar el carrito, y aquí la comanda se crea directo.
//   · `localActualProvider` DEBE sobreescribirse a 1. Sin eso `cargar()` corta
//     en `:496` y `_descontarRecetaDeItem` devuelve `vacio` en su guarda de
//     local, y los tests pasarían sin comprobar nada.
//
// `usuarioActualProvider` NO se sobreescribe a propósito: `UsuariosNotifier`
// es `super(null)`, no hace I/O al construirse, y su `null` degrada el
// `usuarioId` del movimiento a 0 sin tocar nada.
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
// ⚠️ Este import NO es decorativo: `findAll()`, `count()` y `findFirst()` no
// son métodos de `QueryBuilder`, son de una EXTENSIÓN (`QueryExecute`, en
// `isar/src/query_builder_extensions.dart`). En Dart una extensión solo entra
// en ámbito si su biblioteca se importa DIRECTAMENTE: los `.g.dart` de las
// entidades sí la importan, pero las extensiones importadas de forma
// transitiva NO son visibles. Sin esta línea, `analyze` da "The method
// 'findAll' isn't defined for the type 'QueryBuilder<...>'".
// Mismo import que usa `ventas_service_test.dart:18`, que encadena
// `.where().findAll()` 4 veces.
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/estado_plato.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_inventario_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/receta_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/comanda_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart';

// ══════════════════════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════════════════════

/// Local de trabajo. Debe coincidir con el override de `localActualProvider`.
const int kLocal = 1;

/// Ojo de flotantes para comparar cantidades de stock.
const double kEpsilon = 0.0001;

/// Secuencia para dar un `codigoBarras` distinto a cada producto.
///
/// ⚠️ MONÓTONA GLOBAL, NO POR TEST. El `setUp` abre un Isar nuevo por test,
/// así que la unicidad solo hace falta DENTRO de un test, pero un contador
/// que se reinicia por test sería justo el tipo de valor que vuelve a
/// colisionar cuando alguien añade un segundo `setUp`. Incrementar y ya
/// está: nunca repite, en ningún test.
int _secuenciaProducto = 0;

/// Producto. `guardarProducto` es `Future<void>` pero MUTA la instancia:
/// devuelve el id por `autoIncrement` dentro del propio objeto, que es
/// exactamente lo que hace `productos_provider.dart:180`.
///
/// ⚠️ `codigoBarras` NO es opcional aquí aunque no lo use nadie en el test.
/// El constructor de `ProductoEntity` lo deja en `''`
/// (`producto_entity.dart:151`) y ese campo está indexado como
/// `@Index(unique: true, replace: true)` (`:10-11`). Con `replace: true`,
/// insertar un valor duplicado NO lanza: **borra el objeto que ya estaba**
/// (ver la doc de `Index.replace` en el SDK de Isar). Con todos los
/// productos en `''`, el segundo `put()` de un test se comía al primero sin
/// decir nada, y el fallo aflora mucho más tarde y en otro sitio: cuando
/// `_recalcularStockDe` hace `obtenerProductoPorId` y recibe `null`.
Future<ProductoEntity> crearProducto({
  required String nombre,
  double stock = 0,
  bool esIngrediente = true,
  String unidad = 'unidad',
}) async {
  final producto = ProductoEntity(
    codigoBarras: 'test-${_secuenciaProducto++}',
    nombre: nombre,
    stock: stock,
    esIngrediente: esIngrediente,
    unidad: unidad,
  );
  await IsarService().guardarProducto(producto);
  return producto;
}

/// Lote de inventario.
///
/// ⚠️ `estado = 'activo'` NO es opcional: es el valor que exige
/// `obtenerLotesActivos`. Sin esta línea el lote existe pero el FEFO no lo ve.
Future<LoteEntity> crearLote({
  required int productoId,
  required double cantidad,
  DateTime? vencimiento,
  DateTime? ingreso,
}) async {
  final lote = LoteEntity()
    ..productoId = productoId
    ..localId = kLocal
    ..cantidadInicial = cantidad
    ..cantidadRestante = cantidad
    ..fechaIngreso = ingreso ?? DateTime(2026, 1, 1)
    ..fechaVencimiento = vencimiento
    ..estado = 'activo';
  await IsarService().guardarLote(lote);
  return lote;
}

/// Un ingrediente dentro de la receta.
///
/// `unidad` se deja en `'unidad'` por defecto porque es el default de
/// `ProductoEntity.unidad`: así estos tests recorren la conversión normal
/// (1:1) y no el fallback de dimensiones incompatibles. El caso `g → kg`
/// tiene su propio test (2b).
RecetaItemEntity ingrediente(
  ProductoEntity producto, {
  required double cantidad,
  bool opcional = false,
  String? nombre,
  String unidad = 'unidad',
}) {
  return RecetaItemEntity()
    ..ingredienteId = producto.id
    ..ingredienteNombre = nombre ?? producto.nombre
    ..cantidad = cantidad
    ..unidad = unidad
    ..esOpcional = opcional;
}

/// Receta del plato. `rindePorciones = 1` = la cantidad es por plato.
Future<void> crearReceta({
  required ProductoEntity plato,
  required List<RecetaItemEntity> items,
  double rindePorciones = 1.0,
}) async {
  await IsarService().guardarReceta(
    RecetaEntity()
      ..localId = kLocal
      ..productoId = plato.id
      ..nombrePlato = plato.nombre
      ..rindePorciones = rindePorciones
      ..activo = true
      ..items = items,
  );
}

/// Item de comanda en estado `listo`, listo para entregar.
///
/// ⚠️ `productoIdLocal` es el que enlaza con `RecetaEntity.productoId`. Sin
/// él `_descontarRecetaDeItem` sale por su primera guarda.
CartSessionItem platoListo({
  required ProductoEntity plato,
  double cantidad = 1.0,
}) {
  return CartSessionItem()
    ..productoId = plato.nombre
    ..productoIdLocal = plato.id
    ..productoNombre = plato.nombre
    ..productoCategoria = 'Platos'
    ..precioUnidad = 10.0
    ..cantidad = cantidad
    ..estadoPlato = EstadoPlato.listo
    ..enviadoACocinaAt = DateTime(2026, 1, 1, 12);
}

/// Comanda con un único item, en estado `enviada`.
Future<int> crearComandaCon(CartSessionItem item) async {
  final isar = IsarService();
  final mesaId = await isar.guardarMesa(
    // El `nombre` no es único, así que se usa el id del item como semilla
    // para que dos tests del mismo archivo no choquen.
    MesaEntity()
      ..localId = kLocal
      ..nombre = 'Mesa ${item.productoIdLocal}'
      ..estado = MesaEstado.ocupada,
  );

  return isar.guardarComanda(
    CartSessionEntity()
      ..sessionId = 'mesa:$mesaId'
      ..nombre = 'Comanda $mesaId'
      ..usuarioId = 1
      ..mesaId = mesaId
      ..mesaNombre = 'Mesa $mesaId'
      ..comandaEstado = ComandaEstado.enviada
      ..items = [item]
      ..itemsNombres = [item.productoNombre],
  );
}

/// Movimientos de inventario leídos por debajo de `IsarService`.
///
/// ⚠️ `queryMovimientosVentaRecientes` NO sirve aquí: filtra por
/// `tipoMovimientoEqualTo('Venta')` y esto es `'Consumo receta'`. Siempre
/// devolvería vacío y el test pasaría sin verificar nada. `IsarService.db` es
/// público, así que se va a la colección directamente.
Future<List<MovimientoInventarioEntity>> leerMovimientos() async {
  final db = await IsarService().db;
  return await db.movimientoInventarioEntitys.where().findAll();
}

Future<double> stockTotal(int productoId) =>
    IsarService().obtenerStockTotalPorProducto(productoId);

// ══════════════════════════════════════════════════════════════
// TESTS
// ══════════════════════════════════════════════════════════════

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('g3_descuento_');
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

  /// Monta el notifier real contra la base temporal y ejecuta [cuerpo].
  ///
  /// ⚠️ El override de `localActualProvider` NO es opcional: sin él
  /// `LocalActualNotifier` arranca en `null`, `cargar()` corta y el estado
  /// queda VACÍO. Fijándolo en el propio factory, `cargar()` ve el valor de
  /// inmediato y desaparece la carrera.
  Future<void> conNotifier(
    Future<void> Function(ComandasNotifier notifier) cuerpo,
  ) async {
    final container = ProviderContainer(
      overrides: [
        localActualProvider.overrideWith((ref) {
          final notifier = LocalActualNotifier(ref, isar: IsarService())
            ..state = kLocal;
          return notifier;
        }),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(comandasProviderConIsar.notifier);
    // El constructor dispara `cargar()` sin await. Sin esto, el
    // `marcarEntregado` podría correr con la carga en vuelo y el
    // `container.dispose()` del tearDown ocurriría a mitad.
    await notifier.esperarCargaInicial;
    await cuerpo(notifier);
  }

  group('G.3 · sin receta', () {
    test('1 · item sin receta NO toca ningún lote', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 5);
      await crearLote(productoId: queso.id, cantidad: 5);

      final plato = await crearProducto(
        nombre: 'Pizza sin receta',
        esIngrediente: false,
      );
      final comandaId = await crearComandaCon(platoListo(plato: plato));

      await conNotifier((notifier) async {
        final ok = await notifier.marcarEntregado(comandaId, 0);
        expect(ok, isTrue, reason: 'la transición listo → entregado es válida');
      });

      expect(await stockTotal(queso.id), closeTo(5.0, kEpsilon));
      expect(await leerMovimientos(), isEmpty);
    });

    test('1b · sin productoIdLocal tampoco busca receta', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 5);
      await crearLote(productoId: queso.id, cantidad: 5);

      final plato = await crearProducto(
        nombre: 'Pizza huérfana',
        esIngrediente: false,
      );
      // A propósito SIN `productoIdLocal`: simula un producto que aún no
      // está en Isar cuando se volcó la comanda.
      final item = platoListo(plato: plato)..productoIdLocal = null;
      final comandaId = await crearComandaCon(item);

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      expect(await stockTotal(queso.id), closeTo(5.0, kEpsilon));
    });
  });

  group('G.3 · descuento exacto', () {
    test('2 · 1 ingrediente con stock suficiente descuenta la cantidad exacta',
        () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 5);
      await crearLote(productoId: queso.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.2)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      expect(await stockTotal(queso.id), closeTo(4.8, kEpsilon));
    });

    test('3 · 2 ingredientes se descuentan los dos', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 5);
      await crearLote(productoId: queso.id, cantidad: 5);
      final jamon = await crearProducto(nombre: 'Jamón', stock: 5);
      await crearLote(productoId: jamon.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [
          ingrediente(queso, cantidad: 0.2),
          ingrediente(jamon, cantidad: 0.1),
        ],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      expect(await stockTotal(queso.id), closeTo(4.8, kEpsilon));
      expect(await stockTotal(jamon.id), closeTo(4.9, kEpsilon));
    });

    test('2b · receta en gramos descuenta kilos del inventario', () async {
      // El bug original: 150 g se restaban como 150 kg porque la unidad de
      // la receta y la del stock nunca se convertían.
      final queso = await crearProducto(
        nombre: 'Queso',
        stock: 5,
        unidad: 'kg',
      );
      await crearLote(productoId: queso.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 150, unidad: 'g')],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      // 150 g = 0.15 kg, no 150 kg.
      expect(await stockTotal(queso.id), closeTo(4.85, kEpsilon));

      final movimientos = await leerMovimientos();
      expect(movimientos, hasLength(1));
      expect(movimientos.single.cantidad, closeTo(0.15, kEpsilon));
    });

    test('3b · la cantidad del item multiplica la de la receta', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 5);
      await crearLote(productoId: queso.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.2)],
      );

      // 3 pizzas × 0.2 = 0.6, no 0.2.
      final comandaId = await crearComandaCon(
        platoListo(plato: pizza, cantidad: 3),
      );

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      expect(await stockTotal(queso.id), closeTo(4.4, kEpsilon));
    });
  });

  group('G.3 · FEFO multi-lote', () {
    test('4 · consume el lote más viejo primero y luego el siguiente',
        () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      final viejo = await crearLote(
        productoId: queso.id,
        cantidad: 0.1,
        vencimiento: DateTime(2026, 10, 1),
      );
      final nuevo = await crearLote(
        productoId: queso.id,
        cantidad: 0.5,
        vencimiento: DateTime(2026, 10, 15),
      );

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.3)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      final isar = IsarService();
      // El viejo se agotó entero (0.1 de los 0.3 pedidos).
      final loteViejo = await isar.obtenerLotePorId(viejo.id);
      expect(loteViejo!.cantidadRestante, closeTo(0.0, kEpsilon));
      expect(loteViejo.estado, 'agotado');

      // Y los 0.2 restantes salieron del nuevo: 0.5 - 0.2 = 0.3.
      final loteNuevo = await isar.obtenerLotePorId(nuevo.id);
      expect(loteNuevo!.cantidadRestante, closeTo(0.3, kEpsilon));

      expect(await stockTotal(queso.id), closeTo(0.3, kEpsilon));
    });
  });

  group('G.3 · rindePorciones', () {
    test('5 · rinde 10 descuenta una décima parte', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      await crearLote(productoId: queso.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 1.0)],
        rindePorciones: 10.0,
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      // 1 × 1.0 ÷ 10 = 0.1, no 1.0.
      expect(await stockTotal(queso.id), closeTo(4.9, kEpsilon));
    });

    test('6 · rinde 0 usa divisor 1.0 y no cuelga', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      await crearLote(productoId: queso.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.2)],
        // Divisor 0 daría Infinity y el `while` del FEFO no terminaría.
        rindePorciones: 0,
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      expect(await stockTotal(queso.id), closeTo(4.8, kEpsilon));
    });

    test('6b · rinde negativo también cae al divisor 1.0', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      await crearLote(productoId: queso.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.2)],
        rindePorciones: -4,
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      // Sin la guarda `rinde > 0`, esto daría -0.2 (un INGRESO de stock).
      expect(await stockTotal(queso.id), closeTo(4.8, kEpsilon));
    });
  });

  group('G.3 · faltantes', () {
    test('7 · falta parcial: descuenta lo que hay y reporta el faltante',
        () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      await crearLote(productoId: queso.id, cantidad: 0.2);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.5)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        final ok = await notifier.marcarEntregado(comandaId, 0);
        // Q3: el plato se entrega IGUAL. El stock no bloquea.
        expect(ok, isTrue, reason: 'la falta de stock no puede bloquear');

        final aviso = notifier.state.avisoReceta;
        expect(aviso, isNotNull, reason: 'un faltante debe avisar');
        expect(aviso!.faltantes, contains('Queso'));
        // ⚠️ `descritos` cuenta "se le descontó ALGO", no "se cubrió todo":
        // el parcial de 0.2 SÍ cuenta como descrito.
        expect(aviso.descritos, 1);
        expect(aviso.completo, isFalse);
      });

      expect(await stockTotal(queso.id), closeTo(0.0, kEpsilon));
    });

    test('7b · sin ningún lote el faltante también se reporta', () async {
      // Producto sin lote: `obtenerLoteParaVenta` devuelve null.
      final queso = await crearProducto(nombre: 'Queso', stock: 0);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.5)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
        expect(notifier.state.avisoReceta!.faltantes, contains('Queso'));
      });

      expect(await stockTotal(queso.id), closeTo(0.0, kEpsilon));
    });
  });

  group('G.3 · opcionales', () {
    test('8 · un opcional no se descuenta', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      await crearLote(productoId: queso.id, cantidad: 5);
      final oregano = await crearProducto(nombre: 'Orégano', stock: 0);
      await crearLote(productoId: oregano.id, cantidad: 1);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [
          ingrediente(queso, cantidad: 0.2),
          ingrediente(oregano, cantidad: 0.05, opcional: true),
        ],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      expect(await stockTotal(queso.id), closeTo(4.8, kEpsilon));
      // El orégano ni se toca, pese a tener stock de sobra.
      expect(await stockTotal(oregano.id), closeTo(1.0, kEpsilon));
    });

    test('9 · receta con SOLO opcionales no hace nada', () async {
      final oregano = await crearProducto(nombre: 'Orégano', stock: 0);
      await crearLote(productoId: oregano.id, cantidad: 1);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        // `items` NO está vacío, pero `vacia` sí: por eso el código usa
        // `receta.vacia` y no `items.isEmpty`.
        items: [ingrediente(oregano, cantidad: 0.05, opcional: true)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
        expect(
          notifier.state.avisoReceta,
          isNull,
          reason: 'nada que descontar no es un aviso',
        );
      });

      expect(await stockTotal(oregano.id), closeTo(1.0, kEpsilon));
      expect(await leerMovimientos(), isEmpty);
    });
  });

  group('G.3 · auditoría', () {
    test('10 · deja un movimiento de tipo "Consumo receta"', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      await crearLote(productoId: queso.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.2)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      final movs = await leerMovimientos();
      expect(movs, hasLength(1));

      final mov = movs.single;
      expect(mov.tipoMovimiento, 'Consumo receta');
      expect(mov.productoId, queso.id);
      expect(mov.nombreProducto, 'Queso');
      expect(mov.cantidad, closeTo(0.2, kEpsilon));
      expect(mov.stockResultante, closeTo(4.8, kEpsilon));
      expect(mov.localId, kLocal);
      expect(mov.syncStatus, 'pending');
    });

    test('11 · NO deja movimiento cuando no se descontó nada', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      // Sin lote: no hay nada que descontar.
      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.5)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      // Un movimiento con `cantidad = 0` solo ensuciaría el histórico.
      expect(await leerMovimientos(), isEmpty);
    });

    test('11b · el movimiento registra el PARCIAL, no lo pedido', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      await crearLote(productoId: queso.id, cantidad: 0.2);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.5)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      final mov = (await leerMovimientos()).single;
      // Se descontaron 0.2, no 0.5: el movimiento dice lo que REALMENTE
      // salió del inventario, que es lo que hace falta para auditar.
      expect(mov.cantidad, closeTo(0.2, kEpsilon));
    });
  });

  group('G.3 · idempotencia y estado', () {
    test('12 · doble marcarEntregado solo descuenta una vez', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      await crearLote(productoId: queso.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.2)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        expect(await notifier.marcarEntregado(comandaId, 0), isTrue);
        // El segundo dies en la matriz de transiciones: `entregado` es
        // terminal y su conjunto de destinos está VACÍO.
        expect(await notifier.marcarEntregado(comandaId, 0), isFalse);
      });

      // 5 - 0.2 UNA vez. Si descontara dos, sería 4.6.
      expect(await stockTotal(queso.id), closeTo(4.8, kEpsilon));
      expect(await leerMovimientos(), hasLength(1));
    });

    test('13 · recalcula ProductoEntity.stock tras el descuento', () async {
      final queso = await crearProducto(
        nombre: 'Queso',
        // Stock mentiroso: los lotes son la verdad.
        stock: 99,
      );
      await crearLote(productoId: queso.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.2)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
      });

      final guardado = await IsarService().obtenerProductoPorId(queso.id);
      // Sin el recálculo seguiría en 99 y cualquier reporte del producto
      // mentiría respecto a los lotes.
      expect(guardado!.stock, closeTo(4.8, kEpsilon));
    });

    test('14 · con faltantes, avisoReceta queda publicado', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.5)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);

        final aviso = notifier.state.avisoReceta;
        expect(aviso, isNotNull);
        expect(aviso!.faltantes, isNotEmpty);
        expect(aviso.completo, isFalse);
      });
    });

    test('15 · sin faltantes, avisoReceta se queda null', () async {
      final queso = await crearProducto(nombre: 'Queso', stock: 0);
      await crearLote(productoId: queso.id, cantidad: 5);

      final pizza = await crearProducto(
        nombre: 'Pizza',
        esIngrediente: false,
      );
      await crearReceta(
        plato: pizza,
        items: [ingrediente(queso, cantidad: 0.2)],
      );

      final comandaId = await crearComandaCon(platoListo(plato: pizza));

      await conNotifier((notifier) async {
        await notifier.marcarEntregado(comandaId, 0);
        expect(
          notifier.state.avisoReceta,
          isNull,
          reason: 'un descuento completo no genera aviso que pintar',
        );
      });
    });
  });
}
