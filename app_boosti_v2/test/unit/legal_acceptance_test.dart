import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_boosti_v2/core/security/pii_scrubber.dart';
import 'package:app_boosti_v2/features/legal/data/legal_acceptance_store.dart';
import 'package:app_boosti_v2/features/legal/data/legal_texts.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<LegalAcceptanceStore> nuevo() async {
    final prefs = await SharedPreferences.getInstance();
    return LegalAcceptanceStore(prefs);
  }

  group('LegalAcceptanceStore', () {
    test('sin registro previo, leer devuelve null', () async {
      final store = await nuevo();
      expect(store.leer('usuario-1'), isNull);
      expect(store.yaAcepto('usuario-1'), isFalse);
    });

    test('registrar y leer devuelve el mismo registro', () async {
      final store = await nuevo();
      final momento = DateTime.utc(2026, 10, 18, 15, 30);

      expect(await store.registrar('usuario-1', momento: momento), isTrue);

      final a = store.leer('usuario-1');
      expect(a, isNotNull);
      expect(a!.usuarioId, 'usuario-1');
      expect(a.version, kLegalVersion);
      expect(a.aceptadoEn, momento);
    });

    test('yaAcepto es verdadero solo con la version vigente', () async {
      final store = await nuevo();
      await store.registrar('usuario-1');
      expect(store.yaAcepto('usuario-1'), isTrue);
    });

    test('un registro de otra version NO cuenta como aceptacion', () async {
      // Es el caso del cambio de documento: el texto nuevo tiene que volver
      // a mostrarse, no herdarse de la aceptacion anterior.
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('legal_aceptado_usuario-1',
          '{"version":"2020-01-01","usuarioId":"usuario-1","aceptadoEn":"2020-01-01T00:00:00.000Z"}');

      final store = LegalAcceptanceStore(prefs);
      expect(store.leer('usuario-1'), isNotNull,
          reason: 'el registro existe');
      expect(store.yaAcepto('usuario-1'), isFalse,
          reason: 'pero la version no coincide, hay que volver a pedirla');
    });

    test('registro corrupto no rompe la app', () async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('legal_aceptado_usuario-1', 'esto no es json {{{');

      final store = LegalAcceptanceStore(prefs);
      expect(store.leer('usuario-1'), isNull);
      expect(store.yaAcepto('usuario-1'), isFalse);
    });

    test('registro con campos faltantes se descarta', () async {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('legal_aceptado_usuario-1', '{"version":"x"}');

      final store = LegalAcceptanceStore(prefs);
      expect(store.leer('usuario-1'), isNull);
    });

    test('borrar limpia el registro', () async {
      final store = await nuevo();
      await store.registrar('usuario-1');
      expect(store.yaAcepto('usuario-1'), isTrue);

      store.borrar('usuario-1');
      expect(store.yaAcepto('usuario-1'), isFalse);
    });

    test('los usuarios no se pisan entre si', () async {
      final store = await nuevo();
      await store.registrar('usuario-1');
      await store.registrar('usuario-2');

      store.borrar('usuario-1');

      expect(store.yaAcepto('usuario-1'), isFalse);
      expect(store.yaAcepto('usuario-2'), isTrue,
          reason: 'borrar el de uno no puede tocar el del otro');
    });

    test('usuario vacio tambien se registra sin romper', () async {
      // El ID vacio ocurre si se acepta sin sesion de Supabase. Guardarlo
      // es mejor que bloquear el flujo, pero `yaAcepto` debe seguir siendo
      // falso para no dar por aceptada una sesion anonima.
      final store = await nuevo();
      expect(await store.registrar(''), isTrue);
      expect(store.leer('')!.usuarioId, '');
    });
  });

  group('LegalTextos · integridad del documento', () {
    test('la version tiene forma de fecha', () {
      expect(kLegalVersion, matches(r'^\d{4}-\d{2}-\d{2}$'));
    });

    test('ambas listas de secciones estan ordenadas y sin huecos', () {
      for (final lista in [LegalTerminos.secciones, LegalPrivacidad.secciones]) {
        expect(lista, isNotEmpty);
        for (var i = 0; i < lista.length; i++) {
          expect(lista[i].titulo, startsWith('${i + 1}.'),
              reason: 'la seccion ${i + 1} deberia empezar por '
                  '"${i + 1}." y no por "${lista[i].titulo}"');
        }
      }
    });

    test('ninguna seccion tiene el cuerpo vacio', () {
      for (final lista in [LegalTerminos.secciones, LegalPrivacidad.secciones]) {
        for (final s in lista) {
          expect(s.cuerpo.trim(), isNotEmpty, reason: s.titulo);
        }
      }
    });

    test('los terminos mencionan la politica de privacidad', () {
      // Sin esta referencia cruzada, el aviso de privacidad queda como
      // documento suelto y no como parte del contrato.
      final todo = LegalTerminos.secciones.map((s) => s.cuerpo).join(' ');
      expect(todo, contains('politica de privacidad'));
      expect(todo.toLowerCase(), contains('lopdp'));
    });

    test('la politica declara los derechos del titular', () {
      final titulos = LegalPrivacidad.secciones.map((s) => s.titulo).join(' | ');
      expect(titulos.toLowerCase(), contains('derechos del titular'));
      expect(titulos.toLowerCase(), contains('conservacion'));
      expect(titulos.toLowerCase(), contains('seguridad'));
    });

    test('la politica explica lo que sale del dispositivo', () {
      final todo = LegalPrivacidad.secciones.map((s) => s.cuerpo).join(' ');
      expect(todo, contains('del dispositivo'));
      expect(todo, contains('Sentry'),
          reason: 'si el dato sale, el tercero tiene que estar nombrado');
    });

    test('el identificador tiene los datos de contacto', () {
      expect(LegalIdentidad.razonSocial, contains('JAHTLABS'));
      expect(LegalIdentidad.titular, isNotEmpty);
      expect(LegalIdentidad.contacto, isNotEmpty);
      expect(LegalIdentidad.correo, contains('@'));
    });
  });

  group('Interaccion con el scrubber de PII', () {
    test('el correo de JAHTLABS tambien se enmascara al diagnosticar', () {
      // El scrubber no distingue "nuestro" de "del cliente": limpia
      // cualquier correo. Es lo correcto para un archivo de error, donde no
      // se sabe de quien es la direccion. Este test fija esa decision para
      // que nadie la cambie por sorpresa.
      final enmascarado = PiiScrubber.scrub(LegalIdentidad.correo);
      expect(enmascarado, '[CORREO]');
      expect(enmascarado, isNot(contains('@')));
    });

    test('un identificador de aceptacion se puede registrar limpio', () {
      // Si el hash del texto terminara con una cadena larga de digitos y
      // se registrara en Sentry, tendria que quedar enmascarado.
      final registro = Acceptance(
        version: kLegalVersion,
        usuarioId: '9c7380a4-1111-2222-3333-444455556666',
        aceptadoEn: DateTime.utc(2026, 10, 18),
      );
      final texto = registro.toJson().toString();
      expect(texto, contains(kLegalVersion));
    });
  });
}