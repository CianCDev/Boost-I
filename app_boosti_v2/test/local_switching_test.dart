// test/local_switching_test.dart
//
// PASO 2.3-R · Tests REALES del hot-switch de local.
//
// ⚠️ HISTORIAL: este archivo antes contenía placeholders que NO probaban
// nada:
//   - `expect(container.read(localActualProvider), isNotNull)` leía el
//     estado de forma síncrona, antes de que terminara la carga async, así
//     que fallaba siempre.
//   - otro test era literalmente `expect(true, isTrue)`.
//
// Los mocks de `IsarService` tampoco se inyectaban: el `ProviderContainer`
// se creaba con `overrides: []` mientras el notifier llamaba a
// `IsarService()` directamente (no pasaba por ningún provider).
//
// Para que esto sea testeable de verdad, `LocalActualNotifier` ahora acepta
// un `IsarService` inyectable por constructor, y `localActualProvider` se
// sobreescribe en el `ProviderContainer`.
import 'dart:io';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/auth_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/clientes/clientes_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/empleados/empleados_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/marca_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

const kTenantA = '9c7380a4-14be-41c2-88db-07606c2a6489';
const kTenantB = 'fd3dee41-54b0-40b7-b83b-5f9f1b3cc3f8';

class MockIsarService extends Mock implements IsarService {}

class MockAuthNotifier extends Mock implements AuthNotifier {}

LocalEntity local(int id, String nombre, String supabaseId) => LocalEntity()
  ..id = id
  ..nombre = nombre
  ..supabaseId = supabaseId
  ..activo = true
  ..sincronizado = true;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockIsarService mockIsar;
  late MockAuthNotifier mockAuth;
  late ProviderContainer container;
  late bool authCambiaOK;
  late String? tenantSolicitado;

  setUp(() {
    // ⚠️ Instalar el fake ANTES de cualquier cosa que construya IsarService.
    // Sin esto, el primer provider que pida `IsarService().db` crashea con
    // MissingPluginException y el test falla por una razón que no tiene nada
    // que ver con el hot-switch.
    //
    // Va en `setUp` y no en `main` a propósito: `PathProviderPlatform.instance`
    // es estado GLOBAL del proceso de test. Si un solo test lo tocara, el
    // contaminationaria a todos los que corren después en el mismo archivo.
    //
    // ⚠️ NO se restaura `MethodChannelPathProvider` en el `tearDown`. Su clase
    // vive en `path_provider_platform_interface/lib/src/`, y ese `src/` NO se
    // reexporta desde el entrypoint (solo `export 'src/enums.dart'`), así que
    // habría que importarlo por ruta interna: frágil y no recomendado.
    //
    // Y no hace falta: `PathProviderPlatform.instance` vale por defecto
    // `MethodChannelPathProvider()` (línea 25 de la interfaz), dejar el fake
    // puesto solo afecta a este archivo, y CADA test lo reasigna en su propio
    // `setUp` con un tempDir nuevo.
    final tempDir = Directory.systemTemp.createTempSync('ls_test_');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
    addTearDown(() {
      // ⚠️ NO se restaura `MethodChannelPathProvider` aquí. Su clase vive en
      // `path_provider_platform_interface/lib/src/`, y ese `src/` NO se
      // reexporta desde el entrypoint (solo `export 'src/enums.dart'`), así
      // que habría que importarlo por ruta interna: frágil y no recomendado.
      //
      // Y no hace falta. `PathProviderPlatform.instance` vale por defecto
      // `MethodChannelPathProvider()` (línea 25 de la interfaz), así que
      // dejar el fake puesto solo afecta a este archivo, y CADA test lo
      // reasigna en su propio `setUp` con un tempDir nuevo.
      try {
        tempDir.deleteSync(recursive: true);
      } catch (_) {
        // La limpieza del temp no debe romper la suite.
      }
    });

    SharedPreferences.setMockInitialValues({
      'localActualId': 1,
      'tenantId': kTenantA,
    });

    mockIsar = MockIsarService();
    mockAuth = MockAuthNotifier();
    authCambiaOK = true;
    tenantSolicitado = null;

    when(() => mockIsar.obtenerLocalPorId(any())).thenAnswer((inv) async {
      final id = inv.positionalArguments.first as int;
      return switch (id) {
        1 => local(1, 'JAHTLABS', kTenantA),
        2 => local(2, 'centro', kTenantB),
        _ => null,
      };
    });

    when(() => mockIsar.obtenerLocalPorSupabaseId(any()))
        .thenAnswer((inv) async {
      final supa = inv.positionalArguments.first as String;
      return supa == kTenantA
          ? local(1, 'JAHTLABS', kTenantA)
          : local(2, 'centro', kTenantB);
    });

    when(() => mockIsar.marcarLocalComoActivo(any())).thenAnswer((_) async {});

    when(() => mockIsar.obtenerLocales(soloActivos: any(named: 'soloActivos')))
        .thenAnswer((_) async => [local(1, 'JAHTLABS', kTenantA)]);

    // `clientesProvider` se monta durante el hot-switch (ver nota de abajo) y
    // su notifier pide clientes en el constructor. Sin este stub, Mocktail
    // lanza `MissingStubError` y el test falla por un motivo que no tiene
    // nada que ver con el hot-switch.
    when(() => mockIsar.obtenerClientes(
          soloActivos: any(named: 'soloActivos'),
          soloFrecuentes: any(named: 'soloFrecuentes'),
        )).thenAnswer((_) async => []);

    when(() => mockAuth.cambiarLocal(any())).thenAnswer((inv) async {
      tenantSolicitado = inv.positionalArguments.first as String;
      return authCambiaOK;
    });

    container = ProviderContainer(
      overrides: [
        // ⚠️ `overrideWith` SUSTITUYE al factory del provider real; no lo
        // augmenta. El provider de producción (`local_actual_provider.dart`
        // :263-264) construye el notifier Y llama a `cargarLocalActual()`.
        // Aquí hay que reproducir esa segunda línea: si no, el estado nunca
        // pasa de `null` y el test de carga inicial no probaría nada.
        localActualProvider.overrideWith((ref) {
          final notifier = LocalActualNotifier(ref, isar: mockIsar);
          notifier.cargarLocalActual();
          return notifier;
        }),
        authProvider.overrideWith((ref) => mockAuth),

        // ⚠️ `setLocalActual()` hace 21 `invalidate`
        // (`local_actual_provider.dart:224-248`). Riverpod monta el provider
        // invalidado para recorrer su grafo, así que todos los que quedan
        // con listener se construyen DE VERDAD durante el hot-switch.
        //
        // `MockIsarService` solo se inyecta en el `LocalActualNotifier` por
        // constructor. `IsarService()` es un singleton de proceso
        // (`isar_service.dart:79`), así que cualquier otro provider que lo
        // llame directo ignora el mock y pega contra la base real.
        //
        // Aislado no se nota: el proceso abre Isar y todo funciona. En la
        // suite completa, el `tearDown` del archivo anterior
        // (`test_helpers.dart:59-66`) cierra TODAS las instancias de Isar
        // del proceso de forma global, y entonces el primero que se monta
        // crashea con `IsarError: Isar instance has already been closed`.
        //
        // Por eso los tres que reachan Isar se sustituyen aquí:
        //
        // - `isarServiceProvider` alcanza a `clientesProvider`
        //   (`clientes_provider.dart:26`), que sí tiene punto de inyección.
        // - `marcasProvider` va directo a `IsarService().db`
        //   (`marca_provider.dart:38`), sin inyección posible.
        // - `empleadosProvider` idem (`empleados_provider.dart:17`).
        //
        // A `marcasProvider` hay que sustituirlo sí o sí: el `invalidate` de
        // la línea 227 aborta el resto del `setLocalActual`, así que
        // parche solo ese solo mueve el error al siguiente provider.
        isarServiceProvider.overrideWithValue(mockIsar),
        marcasProvider.overrideWith((ref) => Stream.value(const [])),
        empleadosProvider.overrideWith((ref) => Future.value(const [])),
      ],
    );
  });

  tearDown(() => container.dispose());

  group('Hot-switch · carga inicial', () {
    test('arranca en null y resuelve de forma asíncrona', () async {
      // Regresión directa del bug original: leer sin await daba siempre
      // null, porque la carga es async.
      expect(container.read(localActualProvider), isNull);

      await Future<void>.delayed(const Duration(milliseconds: 60));

      expect(container.read(localActualProvider), isNotNull);
      expect(container.read(localActualProvider), 1);
    });
  });

  group('Hot-switch · camino feliz', () {
    test('setLocalActual cambia el estado y sincroniza las fuentes',
        () async {
      final notifier = container.read(localActualProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      await notifier.setLocalActual(2);

      expect(
        container.read(localActualProvider),
        2,
        reason: 'el estado debe reflejar el local nuevo',
      );
      expect(
        tenantSolicitado,
        kTenantB,
        reason: 'Supabase debe cambiar tenant',
      );
      verify(() => mockIsar.marcarLocalComoActivo(2)).called(1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('localActualId'), 2);

      expect(notifier.ultimoError, isNull);
    });

    test('no se invalida a sí mismo: conserva el local nuevo', () async {
      final notifier = container.read(localActualProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      await notifier.setLocalActual(2);

      // Si `setLocalActual` se invalidara a sí mismo (el bug del diálogo),
      // el provider se recrearía y `cargarLocalActual()` volvería a leer
      // el local anterior. El estado debe seguir siendo 2.
      await Future<void>.delayed(const Duration(milliseconds: 60));
      expect(container.read(localActualProvider), 2);
    });

    test('un cambio encadenado A→B→A funciona', () async {
      final notifier = container.read(localActualProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      await notifier.setLocalActual(2);
      expect(container.read(localActualProvider), 2);

      await notifier.setLocalActual(1);
      expect(container.read(localActualProvider), 1);
      expect(notifier.ultimoError, isNull);
    });
  });

  group('Hot-switch · fallos reportados (nada silencioso)', () {
    test('local inexistente → ultimoError con mensaje claro', () async {
      final notifier = container.read(localActualProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      await notifier.setLocalActual(999);

      expect(notifier.ultimoError, isNotNull);
      expect(notifier.ultimoError, contains('no está disponible'));
      expect(container.read(localActualProvider), 1, reason: 'no debe moverse');
      verifyNever(() => mockIsar.marcarLocalComoActivo(any()));
    });

    test('local sin supabaseId → ultimoError, no cambia', () async {
      when(() => mockIsar.obtenerLocalPorId(3)).thenAnswer((_) async {
        return LocalEntity()
          ..id = 3
          ..nombre = 'sin nube'
          ..activo = true;
      });

      final notifier = container.read(localActualProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      await notifier.setLocalActual(3);

      expect(notifier.ultimoError, contains('no está sincronizado'));
      expect(container.read(localActualProvider), 1);
    });

    test('tenant change falla en Supabase → ultimoError, no cambia', () async {
      authCambiaOK = false;
      final notifier = container.read(localActualProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      await notifier.setLocalActual(2);

      expect(notifier.ultimoError, contains('tenant'));
      expect(container.read(localActualProvider), 1);
      verifyNever(() => mockIsar.marcarLocalComoActivo(any()));
    });

    test('un intento fallido no envenena el siguiente', () async {
      final notifier = container.read(localActualProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 60));

      await notifier.setLocalActual(999);
      expect(notifier.ultimoError, isNotNull);

      await notifier.setLocalActual(2);
      expect(notifier.ultimoError, isNull, reason: 'debe limpiarse al éxito');
      expect(container.read(localActualProvider), 2);
    });
  });
}

/// Fake de rutas para `flutter test`.
///
/// ⚠️ `IsarService._initIsar()` llama a `getApplicationDocumentsDirectory()`
/// (`isar_service.dart:114`), que enruta por el canal de plataforma. En
/// `flutter test` ese canal no tiene implementación y lanza
/// `MissingPluginException`. Ese exception revienta a los providers que
/// construyen `IsarService` cuando el test invalida la lista de providers
/// del hot-switch.
///
/// `PathProviderPlatform` (2.1.2) declara `getApplicationDocumentsPath()`,
/// que es la que `path_provider-2.1.6` invoca bajo el capó de
/// `getApplicationDocumentsDirectory()`. Solo se implementan los 3 métodos
/// que el código del proyecto puede invocar; el resto hereda
/// `UnimplementedError` de la clase base.
class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.raiz);

  final String raiz;

  @override
  Future<String?> getApplicationDocumentsPath() async => raiz;

  @override
  Future<String?> getTemporaryPath() async => raiz;

  @override
  Future<String?> getApplicationSupportPath() async => raiz;
}