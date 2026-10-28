import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/exportacion_datos_service.dart';

/// R.5 · Exportación de datos a CSV.
///
/// Lo que se prueba es lo que puede romper en silencio:
///  · El ZIP se genera y contiene un CSV por tabla.
///  · El CSV lleva BOM y escapa comas, comillas y saltos de línea.
///  · NO se exportan credenciales (PIN / contraseña).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late String testDirPath;

  setUp(() async {
    final tempDir = Directory.systemTemp.createTempSync('exportacion_test_');
    testDirPath = tempDir.path;

    SharedPreferences.setMockInitialValues({
      'empresa_id': 'test_${DateTime.now().microsecondsSinceEpoch}',
    });

    await IsarService.resetForTesting();
    await IsarService().initForTesting('$testDirPath/db');
  });

  tearDown(() async {
    await IsarService.resetForTesting();

    final dir = Directory(testDirPath);
    if (dir.existsSync()) {
      try {
        dir.deleteSync(recursive: true);
      } catch (_) {
        // Windows puede dejar el archivo bloqueado un instante.
      }
    }
  });

  ExportacionDatosService servicio() => ExportacionDatosService(
        destino: Directory('$testDirPath/salida'),
      );

  Archive abrirZip(ResultadoExportacion resultado) {
    final bytes = resultado.archivo.readAsBytesSync();
    return ZipDecoder().decodeBytes(bytes);
  }

  ArchiveFile? buscar(Archive zip, String nombre) {
    for (final archivo in zip) {
      if (archivo.name == nombre) return archivo;
    }
    return null;
  }

  List<int> bytesDe(Archive zip, String nombre) {
    final archivo = buscar(zip, nombre);
    expect(archivo, isNotNull, reason: 'Falta $nombre en el ZIP');
    return archivo!.content as List<int>;
  }

  String contenido(Archive zip, String nombre) {
    return utf8.decode(bytesDe(zip, nombre));
  }

  test('genera un ZIP con un CSV por tabla y el manifiesto', () async {
    final isar = IsarService();
    await isar.guardarProducto(ProductoEntity()
      ..nombre = 'Harina PAN'
      ..codigoBarras = '7591234567890'
      ..precioUnidad = 1.5
      ..stock = 10);

    final resultado = await servicio().exportar();

    expect(resultado.archivo.existsSync(), isTrue);
    expect(resultado.nombreArchivo, endsWith('.zip'));
    expect(resultado.filasPorTabla['productos'], 1);
    expect(resultado.totalTablas, greaterThanOrEqualTo(20));
    expect(resultado.totalFilas, greaterThanOrEqualTo(1));

    final zip = abrirZip(resultado);
    expect(buscar(zip, 'productos.csv'), isNotNull);
    expect(buscar(zip, 'comandas.csv'), isNotNull);
    expect(buscar(zip, 'comandas_items.csv'), isNotNull);
    expect(buscar(zip, 'LEEME.txt'), isNotNull);
  });

  test('el CSV lleva BOM y escapa comas, comillas y saltos de línea',
      () async {
    final isar = IsarService();
    await isar.guardarProducto(ProductoEntity()
      ..nombre = 'Café "Especial", molido\n250 g'
      ..precioUnidad = 3.25
      ..stock = 4);

    final resultado = await servicio().exportar();
    final zip = abrirZip(resultado);
    final bytes = bytesDe(zip, 'productos.csv');
    final csv = utf8.decode(bytes);

    // ⚠️ `utf8.decode` de Dart se come el BOM al decodificar: hay que mirar
    // los bytes crudos para comprobarlo.
    expect(bytes.take(3).toList(), [0xEF, 0xBB, 0xBF],
        reason: 'Sin BOM, Excel rompe los acentos');
    expect(csv, contains('"nombre"'));
    // Comillas duplicadas y el salto de línea dentro de la misma celda.
    expect(csv, contains('"Café ""Especial"", molido\n250 g"'));
  });

  test('exporta los ítems de una comanda como filas propias', () async {
    final isar = IsarService();
    final item = CartSessionItem()
      ..productoId = 'uuid-producto'
      ..productoNombre = 'Pizza'
      ..cantidad = 2
      ..precioUnidad = 8.5;

    await isar.guardarComanda(
      CartSessionEntity()
        ..sessionId = CartSessionEntity.sessionIdDeMesa(1)
        ..usuarioId = 1
        ..nombre = 'Comanda Mesa 1'
        ..mesaId = 1
        ..mesaNombre = 'Mesa 1'
        ..comensales = 2
        ..items = [item],
    );

    final resultado = await servicio().exportar();
    final zip = abrirZip(resultado);

    expect(resultado.filasPorTabla['comandas'], 1);
    expect(resultado.filasPorTabla['comandas_items'], 1);

    final items = contenido(zip, 'comandas_items.csv');
    expect(items, contains('"Pizza"'));
    expect(items, contains('"17.0"'), reason: 'subtotal = 2 × 8.5');
  });

  test('usuarios.csv NO incluye el PIN ni la contraseña', () async {
    final isar = IsarService();
    await isar.guardarUsuario(UsuarioEntity()
      ..nombre = 'Cajero Demo'
      ..pin = '1234'
      ..rol = 'cajero'
      ..password = 'secreto-en-plano');

    final resultado = await servicio().exportar();
    final csv = contenido(abrirZip(resultado), 'usuarios.csv');
    final cabecera = csv.split('\r\n').first.toLowerCase();

    expect(cabecera, contains('"nombre"'));
    expect(cabecera, isNot(contains('"pin"')));
    expect(cabecera, isNot(contains('password')));
    // El hash real tampoco puede aparecer en el cuerpo.
    final guardado = (await isar.obtenerUsuarios()).first;
    expect(csv, isNot(contains(guardado.pin)));
    expect(csv, isNot(contains('secreto-en-plano')));
  });
}
