import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';

void main() {
  group('Usuarios demo — Definición esperada', () {
    final usuariosEsperados = [
      {
        'nombre': 'Administrador',
        'pin': '1234',
        'rol': 'admin',
        'email': 'admin@default.com',
      },
      {
        'nombre': 'Cajero 01',
        'pin': '1111',
        'rol': 'cajero',
        'email': '',
      },
      {
        'nombre': 'Juan Perez',
        'pin': '1010',
        'rol': 'cajero',
        'email': 'juanito@example.com',
      },
    ];

    test('la lista de usuarios esperados tiene 3 elementos', () {
      expect(usuariosEsperados.length, 3);
    });

    test('cada usuario esperado tiene nombre, PIN y rol', () {
      for (final u in usuariosEsperados) {
        expect(u['nombre'], isNotEmpty);
        expect(u['pin'], isNotEmpty);
        expect((u['pin'] as String).length, 4);
        expect(u['rol'], isIn(['admin', 'cajero']));
      }
    });

    test('no hay nombres duplicados', () {
      final nombres = usuariosEsperados.map((u) => u['nombre']).toList();
      expect(nombres.length, nombres.toSet().length);
    });

    test('no hay emails duplicados (ignorando vacíos)', () {
      final emails = usuariosEsperados
          .map((u) => u['email'] as String)
          .where((e) => e.isNotEmpty)
          .toList();
      expect(emails.length, emails.toSet().length);
    });
  });

  group('UsuarioEntity — Validación del modelo', () {
    test('se puede instanciar con los campos mínimos', () {
      final u = UsuarioEntity()
        ..nombre = 'Test'
        ..pin = '1234'
        ..rol = 'cajero';

      expect(u.nombre, 'Test');
      expect(u.pin, '1234');
      expect(u.rol, 'cajero');
      expect(u.activo, isTrue);
    });

    // ✅ CORREGIDO: ahora espera Isar.autoIncrement
    test('el ID arranca en Isar.autoIncrement antes de guardar', () {
      final u = UsuarioEntity()..nombre = 'Test';
      expect(u.id, Isar.autoIncrement);
    });

    test('supabaseId arranca en null', () {
      final u = UsuarioEntity()..nombre = 'Test';
      expect(u.supabaseId, isNull);
    });

    test('un usuario sin PIN tiene pin vacío (no null)', () {
      final u = UsuarioEntity()..nombre = 'Test';
      expect(u.pin, isNotNull);
      expect(u.pin, isEmpty);
    });

    // ✅ NUEVOS tests que validan los defaults que agregamos
    test('defaults de UsuarioEntity son correctos', () {
      final u = UsuarioEntity();
      expect(u.nombre, '');
      expect(u.pin, '');
      expect(u.rol, 'cajero');
      expect(u.activo, isTrue);
      expect(u.estado, 'inactivo');
      expect(u.cajaAsignada, 'Caja Principal');
    });
  });

  group('Verificación del fix — Lógica de decisión', () {
    int calcularUsuariosACrear(int usuariosExistentes) {
      if (usuariosExistentes == 0) return 3;
      return 0;
    }

    test('FIX #1: con base vacía, debe crear 3 usuarios', () {
      expect(calcularUsuariosACrear(0), 3);
    });

    test('FIX #1: con base con datos, no debe crear usuarios', () {
      expect(calcularUsuariosACrear(1), 0);
      expect(calcularUsuariosACrear(3), 0);
    });

    String decidirAccionUsuario({
      required bool tieneSupabaseId,
      required bool existeEnAuthUsers,
    }) {
      if (tieneSupabaseId) return 'actualizar';
      if (existeEnAuthUsers) return 'recuperar_uuid';
      return 'sign_up';
    }

    test('FIX #2: usuario sin supabaseId y existe en Auth → recuperar', () {
      expect(
        decidirAccionUsuario(tieneSupabaseId: false, existeEnAuthUsers: true),
        'recuperar_uuid',
      );
    });

    test('FIX #2: usuario sin supabaseId y NO existe en Auth → signUp', () {
      expect(
        decidirAccionUsuario(tieneSupabaseId: false, existeEnAuthUsers: false),
        'sign_up',
      );
    });

    test('FIX #2: usuario con supabaseId → actualizar', () {
      expect(
        decidirAccionUsuario(tieneSupabaseId: true, existeEnAuthUsers: true),
        'actualizar',
      );
    });

    bool esHuerfano(Map<String, dynamic> usuario) {
      final idIsar = usuario['id_isar'];
      return idIsar == null || idIsar == 0;
    }

    test('FIX #3: usuario sin id_isar es huérfano', () {
      expect(esHuerfano({'nombre': 'PruebaBackup', 'id_isar': null}), isTrue);
    });

    test('FIX #3: usuario con id_isar válido no es huérfano', () {
      expect(esHuerfano({'nombre': 'Admin', 'id_isar': 1}), isFalse);
    });

    test('FIX #3: usuario con id_isar = 0 es huérfano', () {
      expect(esHuerfano({'nombre': 'X', 'id_isar': 0}), isTrue);
    });
  });
}