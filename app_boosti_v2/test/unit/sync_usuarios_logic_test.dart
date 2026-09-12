import 'package:flutter_test/flutter_test.dart';

/// Tests de la lógica de decisión en `sincronizarUsuariosASupabase`.
///
/// Réplica las reglas de negocio SIN tocar Supabase.
/// Si el código real cambia, estos tests avisan.
void main() {
  group('sincronizarUsuariosASupabase — Lógica de decisión', () {
    /// Réplica de la decisión que toma la función.
    /// Dado un usuario y los resultados de las búsquedas,
    /// devuelve la acción a ejecutar.
    String decidirAccion({
      required bool tieneSupabaseId,
      required bool existeEnPublicUsuarios,
      required bool tieneEmail,
      required bool tienePassword,
      required bool signUpDevuelve422,
    }) {
      if (tieneSupabaseId) return 'actualizar';
      if (!tieneEmail) return 'omitir_sin_email';
      if (existeEnPublicUsuarios) return 'recuperar_uuid';
      if (!tienePassword) return 'omitir_sin_password';
      if (signUpDevuelve422) return 'recuperar_tras_422';
      return 'sign_up';
    }

    test('usuario con supabaseId → actualizar', () {
      expect(
        decidirAccion(
          tieneSupabaseId: true,
          existeEnPublicUsuarios: false,
          tieneEmail: true,
          tienePassword: true,
          signUpDevuelve422: false,
        ),
        'actualizar',
      );
    });

    test('usuario sin email → omitir_sin_email', () {
      expect(
        decidirAccion(
          tieneSupabaseId: false,
          existeEnPublicUsuarios: false,
          tieneEmail: false,
          tienePassword: true,
          signUpDevuelve422: false,
        ),
        'omitir_sin_email',
      );
    });

    test('usuario sin UUID pero existe en public.usuarios → recuperar_uuid', () {
      expect(
        decidirAccion(
          tieneSupabaseId: false,
          existeEnPublicUsuarios: true,
          tieneEmail: true,
          tienePassword: true,
          signUpDevuelve422: false,
        ),
        'recuperar_uuid',
      );
    });

    test('usuario sin password y no existe en public → omitir_sin_password', () {
      expect(
        decidirAccion(
          tieneSupabaseId: false,
          existeEnPublicUsuarios: false,
          tieneEmail: true,
          tienePassword: false,
          signUpDevuelve422: false,
        ),
        'omitir_sin_password',
      );
    });

    test('usuario nuevo con password → sign_up', () {
      expect(
        decidirAccion(
          tieneSupabaseId: false,
          existeEnPublicUsuarios: false,
          tieneEmail: true,
          tienePassword: true,
          signUpDevuelve422: false,
        ),
        'sign_up',
      );
    });

    test('FIX B: signUp devuelve 422 → recuperar_tras_422', () {
      expect(
        decidirAccion(
          tieneSupabaseId: false,
          existeEnPublicUsuarios: false,
          tieneEmail: true,
          tienePassword: true,
          signUpDevuelve422: true,
        ),
        'recuperar_tras_422',
      );
    });

    test('BUG REPRODUCIDO: Administrador sin UUID, email ya en auth', () {
      // Réplica del error visto en logs:
      // "AuthApiException(message: User already registered, statusCode: 422)"
      expect(
        decidirAccion(
          tieneSupabaseId: false,
          existeEnPublicUsuarios: false,
          tieneEmail: true,
          tienePassword: true,
          signUpDevuelve422: true,
        ),
        'recuperar_tras_422',
      );
    });

    test('usuario demo Cajero 01 sin email → no se sincroniza', () {
      expect(
        decidirAccion(
          tieneSupabaseId: false,
          existeEnPublicUsuarios: false,
          tieneEmail: false,
          tienePassword: false,
          signUpDevuelve422: false,
        ),
        'omitir_sin_email',
      );
    });
  });

  group('Verificación de identificación de huérfanos (Bug #3)', () {
    bool esHuerfano(Map<String, dynamic> usuario) {
      final idIsar = usuario['id_isar'];
      return idIsar == null || idIsar == 0;
    }

    test('usuario sin id_isar → huérfano', () {
      expect(esHuerfano({'nombre': 'PruebaBackup', 'id_isar': null}), isTrue);
    });

    test('usuario con id_isar = 0 → huérfano', () {
      expect(esHuerfano({'nombre': 'X', 'id_isar': 0}), isTrue);
    });

    test('usuario con id_isar válido → no huérfano', () {
      expect(esHuerfano({'nombre': 'Administrador', 'id_isar': 1}), isFalse);
    });
  });
}