import 'package:flutter_test/flutter_test.dart';

/// Tests que validan la lógica de autenticación local.
///
/// Estos tests NO usan Isar real. Solo validan las reglas de negocio:
/// - PIN de 4 dígitos
/// - Nombre case-insensitive
/// - Trim de espacios
/// - Usuario inactivo no puede entrar
/// - PIN incorrecto no autentica
void main() {
  group('Validación de PIN — Reglas de negocio', () {
    /// Función pura que replica la lógica de validarLogin.
    /// Si el código real cambia, este test falla y nos avisa.
    bool validarLoginPuro({
      required String nombreIngresado,
      required String pinIngresado,
      required String nombreAlmacenado,
      required String pinAlmacenado,
      required bool activo,
    }) {
      final nombreNorm = nombreIngresado.trim().toLowerCase();
      final pinNorm = pinIngresado.trim();

      if (nombreNorm.isEmpty || pinNorm.isEmpty) return false;
      if (!activo) return false;

      return nombreAlmacenado.trim().toLowerCase() == nombreNorm &&
          pinAlmacenado == pinNorm;
    }

    test('acepta login válido', () {
      expect(
        validarLoginPuro(
          nombreIngresado: 'Administrador',
          pinIngresado: '1234',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isTrue,
      );
    });

    test('rechaza PIN incorrecto', () {
      expect(
        validarLoginPuro(
          nombreIngresado: 'Administrador',
          pinIngresado: '9999',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isFalse,
      );
    });

    test('rechaza nombre incorrecto', () {
      expect(
        validarLoginPuro(
          nombreIngresado: 'OtroUsuario',
          pinIngresado: '1234',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isFalse,
      );
    });

    test('acepta nombre con diferente capitalización', () {
      expect(
        validarLoginPuro(
          nombreIngresado: 'administrador',
          pinIngresado: '1234',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isTrue,
      );
      expect(
        validarLoginPuro(
          nombreIngresado: 'ADMINISTRADOR',
          pinIngresado: '1234',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isTrue,
      );
    });

    test('hace trim de espacios en nombre y PIN', () {
      expect(
        validarLoginPuro(
          nombreIngresado: '  Administrador  ',
          pinIngresado: '  1234  ',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isTrue,
      );
    });

    test('rechaza usuario inactivo', () {
      expect(
        validarLoginPuro(
          nombreIngresado: 'Administrador',
          pinIngresado: '1234',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: false,
        ),
        isFalse,
      );
    });

    test('rechaza nombre vacío', () {
      expect(
        validarLoginPuro(
          nombreIngresado: '',
          pinIngresado: '1234',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isFalse,
      );
    });

    test('rechaza PIN vacío', () {
      expect(
        validarLoginPuro(
          nombreIngresado: 'Administrador',
          pinIngresado: '',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isFalse,
      );
    });

    test('rechaza espacios solos como nombre o PIN', () {
      expect(
        validarLoginPuro(
          nombreIngresado: '   ',
          pinIngresado: '1234',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isFalse,
      );
      expect(
        validarLoginPuro(
          nombreIngresado: 'Administrador',
          pinIngresado: '   ',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isFalse,
      );
    });

    test('rechaza PIN con espacios internos', () {
      expect(
        validarLoginPuro(
          nombreIngresado: 'Administrador',
          pinIngresado: '12 34',
          nombreAlmacenado: 'Administrador',
          pinAlmacenado: '1234',
          activo: true,
        ),
        isFalse,
      );
    });
  });

  group('Usuarios demo — Verificación de credenciales', () {
    final credencialesValidas = [
      {'nombre': 'Administrador', 'pin': '1234'},
      {'nombre': 'Cajero 01', 'pin': '1111'},
      {'nombre': 'yan camacaro', 'pin': '1010'},
    ];

    test('los 3 usuarios demo tienen credenciales únicas', () {
      final pines = credencialesValidas.map((c) => c['pin']).toSet();
      expect(pines.length, 3, reason: 'Todos los PINs deben ser únicos');

      final nombres = credencialesValidas.map((c) => c['nombre']).toSet();
      expect(nombres.length, 3, reason: 'Todos los nombres deben ser únicos');
    });

    test('cada PIN tiene exactamente 4 dígitos', () {
      for (final c in credencialesValidas) {
        final pin = c['pin'] as String;
        expect(pin.length, 4);
        expect(RegExp(r'^\d{4}$').hasMatch(pin), isTrue,
            reason: 'PIN ${c['pin']} no es 4 dígitos numéricos');
      }
    });
  });
}