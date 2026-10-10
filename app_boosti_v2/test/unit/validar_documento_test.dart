// test/unit/validar_documento_test.dart
//
// Tests para los validadores de documento en persona_form_template.dart.
//
// Contrato:
// - validarNumeroDocumento(tipo, numero): valida longitud según tipo.
// - validarTipoDocumentoSiHayNumero(tipo, numero): tipo obligatorio si hay
//   número.
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/persona_form_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validarTipoDocumentoSiHayNumero', () {
    test('tipo vacío + número vacío → null (sin documento, permitido)', () {
      expect(validarTipoDocumentoSiHayNumero(null, null), isNull);
      expect(validarTipoDocumentoSiHayNumero(null, ''), isNull);
      expect(validarTipoDocumentoSiHayNumero('', ''), isNull);
      expect(validarTipoDocumentoSiHayNumero('', null), isNull);
    });

    test('tipo vacío + número presente → mensaje de error', () {
      expect(validarTipoDocumentoSiHayNumero(null, '12345678'),
          'Selecciona el tipo de documento');
      expect(validarTipoDocumentoSiHayNumero('', '12345678'),
          'Selecciona el tipo de documento');
      // '  ' se considera vacío.
      expect(validarTipoDocumentoSiHayNumero(null, '  '), isNull);
    });

    test('tipo presente + cualquier número → null', () {
      expect(validarTipoDocumentoSiHayNumero('V', '12345678'), isNull);
      expect(validarTipoDocumentoSiHayNumero('E', '12345678'), isNull);
      expect(validarTipoDocumentoSiHayNumero('J', '123456789'), isNull);
      expect(validarTipoDocumentoSiHayNumero('V', null), isNull);
      expect(validarTipoDocumentoSiHayNumero('V', ''), isNull);
    });
  });

  group('validarNumeroDocumento', () {
    test('V/E: 6-9 dígitos ok, resto rechazado', () {
      // Válidos.
      expect(validarNumeroDocumento('V', '123456'), isNull);
      expect(validarNumeroDocumento('V', '123456789'), isNull);
      expect(validarNumeroDocumento('E', '12345678'), isNull);
      // Inválidos por longitud.
      expect(validarNumeroDocumento('V', '12345'),
          'V/E: entre 6 y 9 dígitos');
      expect(validarNumeroDocumento('V', '1234567890'),
          'V/E: entre 6 y 9 dígitos');
    });

    test('J: 9-10 dígitos ok, resto rechazado', () {
      expect(validarNumeroDocumento('J', '123456789'), isNull);
      expect(validarNumeroDocumento('J', '1234567890'), isNull);
      expect(validarNumeroDocumento('J', '12345678'),
          'J: entre 9 y 10 dígitos');
      expect(validarNumeroDocumento('J', '12345678901'),
          'J: entre 9 y 10 dígitos');
    });

    test('tipo null/vacío → null (no valida)', () {
      expect(validarNumeroDocumento(null, '123'), isNull);
      expect(validarNumeroDocumento('', '123'), isNull);
    });

    test('número vacío → null (documento opcional)', () {
      expect(validarNumeroDocumento('V', null), isNull);
      expect(validarNumeroDocumento('V', ''), isNull);
      expect(validarNumeroDocumento('V', '  '), isNull);
    });

    test('no numérico → mensaje', () {
      expect(validarNumeroDocumento('V', 'ABC123'),
          'Solo se permiten números');
    });

    test('tipo desconocido → mensaje', () {
      expect(validarNumeroDocumento('X', '12345678'),
          'Tipo de documento no reconocido');
    });
  });
}