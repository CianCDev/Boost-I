import 'package:flutter_test/flutter_test.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:app_boosti_v2/core/security/pii_scrubber.dart';

void main() {
  group('PiiScrubber.scrub · datos que NO deben salir', () {
    test('RIF con prefijo J', () {
      expect(
        PiiScrubber.scrub('Fallo al validar J-12345678-9 en local 9c7380a4'),
        'Fallo al validar [RIF] en local 9c7380a4',
      );
    });

    test('RIF con prefijo V', () {
      expect(PiiScrubber.scrub('cedula V-12345678901'), equals('cedula [RIF]'));
    });

    test('telefono venezolano con guion', () {
      expect(PiiScrubber.scrub('contacto 0412-1234567'),
          equals('contacto [TELEFONO]'));
    });

    test('telefono sin prefijo de pais, con todos los digitos iguales', () {
      // Regresion: el prefijo "+58" estaba escrito como `\+?58?`, que deja
      // el "5" como literal. El grupo entero fallaba en cuanto el numero no
      // empezaba por "+58", y "0412-1111111" se escapaba sin limpiar.
      expect(PiiScrubber.scrub('contacto 0412-1111111'),
          equals('contacto [TELEFONO]'));
    });

    test('telefono sin separadores', () {
      expect(PiiScrubber.scrub('04241234567'), equals('[TELEFONO]'));
    });

    test('telefono con espacios', () {
      expect(PiiScrubber.scrub('0412 123 4567'), equals('[TELEFONO]'));
    });

    test('un numero largo que NO es telefono no se toca como telefono', () {
      // El patron de telefono no debe comerse precios ni saldos.
      expect(PiiScrubber.scrub('precio 12345678'), equals('precio [NUMERO]'));
    });

    test('telefono con prefijo de pais', () {
      expect(PiiScrubber.scrub('+58 412 123 4567'), equals('[TELEFONO]'));
    });

    test('correo electronico', () {
      expect(PiiScrubber.scrub('correo juan.perez@tienda.com'),
          equals('correo [CORREO]'));
    });

    test('token JWT', () {
      const jwt = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
          '.eyJzdWIiOiIxMjM0NTY3ODkwIn0.dBjftJeZ4CVPmB92K27uhbUJU1p1r_wW1gFWFOEjXk';
      expect(PiiScrubber.scrub('token $jwt usado'), equals('token [JWT] usado'));
    });

    test('credencial nueva de Supabase', () {
      expect(PiiScrubber.scrub('sb_publishable_abc123def456xyz'),
          equals('[CREDENCIAL]'));
    });

    test('cadena de 16 digitos suelta', () {
      expect(PiiScrubber.scrub('tarjeta 4111111111111111 reventada'),
          equals('tarjeta [NUMERO] reventada'));
    });

    test('direccion IP', () {
      expect(PiiScrubber.scrub('conexion a 192.168.1.100:5432 caida'),
          equals('conexion a [IP]:5432 caida'));
    });

    test('password dentro de un JSON', () {
      expect(
        PiiScrubber.scrub('{"password": "hunter2", "user": "juan"}'),
        '{"password": "[REDACTADO]", "user": "juan"}',
      );
    });
  });

  group('PiiScrubber.scrub · datos que deben SOBREVIVIR', () {
    test('mensaje en espanol sin datos personales', () {
      const msg = 'No se encontro el producto seleccionado en el carrito';
      expect(PiiScrubber.scrub(msg), msg);
    });

    test('UUID de tenant intacto', () {
      // Sin esto ningun bug de aislamiento entre locales seria diagnosticable.
      const msg = 'RLS bloqueado en local 9c7380a4-1111-2222-3333-444455556666';
      expect(PiiScrubber.scrub(msg), msg);
    });

    test('un error de SocketException conserva su forma', () {
      const msg = 'Connection refused (OS Error: Connection refused)';
      expect(PiiScrubber.scrub(msg), msg);
    });

    test('numero corto de menos de siete digitos', () {
      expect(PiiScrubber.scrub('fila 1234567'), equals('fila [NUMERO]'));
      expect(PiiScrubber.scrub('fila 123'), equals('fila 123'));
      expect(PiiScrubber.scrub('linea 2024'), equals('linea 2024'));
    });

    test('cadena vacia', () {
      expect(PiiScrubber.scrub(''), '');
    });
  });

  group('PiiScrubber.scrubEvent', () {
    test('limpia el texto del throwable', () {
      final ev = SentryEvent(throwable: 'Error en J-12345678-9: pago rechazado');
      final out = PiiScrubber.scrubEvent(ev);
      expect(out.throwable, 'Error en [RIF]: pago rechazado');
    });

    test('limpia una excepcion real', () {
      final ev = SentryEvent(
        throwable: StateError('fallo al leer el RIF J-98765432-1'),
      );
      final out = PiiScrubber.scrubEvent(ev);
      expect(out.throwable.toString(), isNot(contains('J-98765432-1')));
      expect(out.throwable.toString(), contains('[RIF]'));
    });

    test('limpia los extras anidados', () {
      final ev = SentryEvent(extra: {
        'usuario': {'email': 'ana@tienda.com', 'rol': 'cajero'},
        'tokenSesion': 'abc123',
        'intento': 2,
      });
      final out = PiiScrubber.scrubEvent(ev);

      final usuario = out.extra!['usuario'] as Map;
      expect(usuario['email'], '[CORREO]');
      expect(usuario['rol'], 'cajero', reason: 'el rol no es dato personal');
      expect(out.extra!['tokenSesion'], '[REDACTADO]');
      expect(out.extra!['intento'], 2, reason: 'un entero no se limpia');
    });

    test('limpia listas de strings', () {
      final ev = SentryEvent(extra: {
        'contactos': ['0412-1111111', 'juan@tienda.com'],
      });
      final out = PiiScrubber.scrubEvent(ev);
      expect(out.extra!['contactos'], ['[TELEFONO]', '[CORREO]']);
    });

    test('no toca una lista de enteros', () {
      final ev = SentryEvent(extra: {'ids': [1, 2, 3]});
      final out = PiiScrubber.scrubEvent(ev);
      expect(out.extra!['ids'], [1, 2, 3]);
    });

    test('limpia el mensaje principal', () {
      final ev = SentryEvent(message: SentryMessage('fallo con RIF J-99999999-9'));
      final out = PiiScrubber.scrubEvent(ev);
      expect(out.message?.formatted, 'fallo con RIF [RIF]');
    });

    test('un evento ya limpio no cambia', () {
      final ev = SentryEvent(throwable: 'estado invalido en el enum del plan');
      final out = PiiScrubber.scrubEvent(ev);
      expect(out.throwable, 'estado invalido en el enum del plan');
    });

    test('un evento sin datos personales sobrevive intacto', () {
      final ev = SentryEvent(
        throwable: 'No se pudo abrir la caja 3',
        message: SentryMessage('fallo de disco'),
        extra: {'local': 'centro', 'caja': 3},
      );
      final out = PiiScrubber.scrubEvent(ev);
      expect(out.throwable, 'No se pudo abrir la caja 3');
      expect(out.message?.formatted, 'fallo de disco');
      expect(out.extra!['local'], 'centro');
    });
  });

  group('Idempotencia', () {
    test('limpiar dos veces no cambia el resultado', () {
      const original = 'error con J-12345678-9 y 0412-1234567';
      final una = PiiScrubber.scrub(original);
      final dos = PiiScrubber.scrub(una);
      expect(dos, una);
    });

    test('los marcadores no se re-limpian', () {
      final una = PiiScrubber.scrub('dato J-12345678-9');
      expect(una, 'dato [RIF]');
      expect(PiiScrubber.scrub(una), una);
    });
  });
}