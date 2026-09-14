import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/domain/services/jwt_service.dart';

String _crearJwtFalso(Map<String, dynamic> payload) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final body = base64Url.encode(utf8.encode(jsonEncode(payload)));
  return '$header.$body.firma_falsa';
}

void main() {
  group('JwtService — extraerTenantId', () {
    test('JWT válido con tenant_id devuelve el valor correcto', () {
      final jwt = _crearJwtFalso({
        'tenant_id': '6471bc93-38df-4bcb-81ea-4e4baf1a5287',
      });

      final tenantId = JwtService.extraerTenantId(jwt);

      expect(tenantId, '6471bc93-38df-4bcb-81ea-4e4baf1a5287');
    });

    test('JWT sin tenant_id devuelve null', () {
      final jwt = _crearJwtFalso({
        'user_rol': 'admin',
      });

      final tenantId = JwtService.extraerTenantId(jwt);

      expect(tenantId, isNull);
    });

    test('JWT vacío devuelve null', () {
      expect(JwtService.extraerTenantId(''), isNull);
    });

    test('JWT malformado devuelve null', () {
      expect(JwtService.extraerTenantId('cabecera.payload'), isNull);
    });
  });

  group('JwtService — extraerRol', () {
    test('JWT válido con user_rol devuelve el valor', () {
      final jwt = _crearJwtFalso({
        'user_rol': 'admin',
      });

      final rol = JwtService.extraerRol(jwt);

      expect(rol, 'admin');
    });

    test('JWT sin user_rol devuelve null', () {
      final jwt = _crearJwtFalso({
        'tenant_id': '6471bc93-38df-4bcb-81ea-4e4baf1a5287',
      });

      final rol = JwtService.extraerRol(jwt);

      expect(rol, isNull);
    });
  });

  group('JwtService — estaExpirado', () {
    test('JWT con exp en el futuro devuelve false', () {
      final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 + 60;
      final jwt = _crearJwtFalso({
        'exp': exp,
      });

      expect(JwtService.estaExpirado(jwt), isFalse);
    });

    test('JWT con exp en el pasado devuelve true', () {
      final exp = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 60;
      final jwt = _crearJwtFalso({
        'exp': exp,
      });

      expect(JwtService.estaExpirado(jwt), isTrue);
    });

    test('JWT sin exp devuelve true', () {
      final jwt = _crearJwtFalso({
        'tenant_id': '6471bc93-38df-4bcb-81ea-4e4baf1a5287',
      });

      expect(JwtService.estaExpirado(jwt), isTrue);
    });

    test('JWT malformado devuelve true', () {
      expect(JwtService.estaExpirado('cabecera.payload'), isTrue);
    });
  });

  group('JwtService — extraerPayload', () {
    test('JWT válido devuelve un Map con los claims', () {
      final payload = {
        'sub': 'uuid-del-usuario',
        'email': 'admin@empresa.com',
        'tenant_id': '6471bc93-38df-4bcb-81ea-4e4baf1a5287',
        'user_rol': 'admin',
        'exp': 1737000000,
        'iat': 1736996400,
      };

      final jwt = _crearJwtFalso(payload);

      final result = JwtService.extraerPayload(jwt);

      expect(result, isNotNull);
      expect(result, isA<Map<String, dynamic>>());
      expect(result!['tenant_id'], '6471bc93-38df-4bcb-81ea-4e4baf1a5287');
      expect(result['user_rol'], 'admin');
      expect(result['exp'], 1737000000);
    });

    test('JWT con 2 partes devuelve null', () {
      expect(JwtService.extraerPayload('header.payload'), isNull);
    });

    test('JWT con 4 partes devuelve null', () {
      expect(
          JwtService.extraerPayload('header.payload.signature.extra'), isNull);
    });

    test('JWT con base64 inválido devuelve null', () {
      final jwt = 'header.\$\$\$\$\$.firma_falsa';
      expect(JwtService.extraerPayload(jwt), isNull);
    });

    test('JWT con JSON inválido devuelve null', () {
      final header =
          base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
      final body = base64Url.encode(utf8.encode('{no es json valido}'));
      final jwt = '$header.$body.firma_falsa';

      expect(JwtService.extraerPayload(jwt), isNull);
    });
  });
}
