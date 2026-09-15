// test/helpers/test_helpers.dart
import 'dart:io';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart'; // ✅ IMPORTANTE: Añade esta importación
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake de PathProvider para que Isar use un directorio temporal
/// cuando se inicializa en tests.
class FakePathProvider extends PathProviderPlatform {
  final String path;
  FakePathProvider(this.path);

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
  @override
  Future<String?> getTemporaryPath() async => path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

/// Prepara Isar para tests: path fake + reset singleton + init en temp dir.
///
/// Configura `SharedPreferences` con valores mock para que `IsarService`
/// no intente llamar al plugin nativo (que no existe en tests).
Future<Directory> setupIsarForTest() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock SharedPreferences — sin esto, IsarService falla al arrancar
  // porque intenta leer la empresa_id desde el plugin nativo.
  SharedPreferences.setMockInitialValues({
    'empresa_id': 'test_empresa',
  });

  final dir = await Directory.systemTemp.createTemp('isar_test_');
  PathProviderPlatform.instance = FakePathProvider(dir.path);

  await IsarService.resetForTesting();
  await IsarService().initForTesting(dir.path);

  return dir;
}

/// Limpia Isar al terminar los tests con un enfoque anti-bloqueos.
Future<void> tearDownIsarForTest(Directory? dir) async {
  // 1. Intentamos el reset de tu servicio con un límite de tiempo.
  // Si un stream está bloqueando Isar, saltará el timeout y el test continuará.
  try {
    await IsarService.resetForTesting().timeout(const Duration(seconds: 2));
  } catch (e) {
    debugPrint('Aviso: resetForTesting() tardó demasiado (posible stream abierto): $e');
  }

  // 2. Cierre de emergencia directamente desde el core de Isar
  try {
    // Cerramos cualquier instancia de Isar que siga viva a la fuerza
    for (final instanceName in Isar.instanceNames) {
      final isar = Isar.getInstance(instanceName);
      if (isar != null && isar.isOpen) {
        await isar.close().timeout(const Duration(seconds: 1));
      }
    }
  } catch (e) {
    debugPrint('Aviso: Fallo al forzar el cierre de las instancias de Isar: $e');
  }
  
  // 3. Damos un breve respiro al sistema operativo.
  await Future.delayed(const Duration(milliseconds: 200));

  // 4. Intentamos borrar la carpeta, ignorando el error si Windows sigue terco.
  if (dir != null && dir.existsSync()) {
    try {
      dir.deleteSync(recursive: true);
    } catch (e) {
      debugPrint('Aviso: Se ignoró el borrado del directorio temporal por bloqueo del OS: $e');
    }
  }
}

/// Envuelve un widget con ProviderScope + MaterialApp para tests.
Widget wrapWithProviders(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}