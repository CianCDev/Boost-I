import 'dart:convert';

/// Servicio de utilidad para leer y validar claims JWT emitidos por Supabase.
class JwtService {
  /// Extrae el claim `tenant_id` del payload del JWT, o retorna `null`
  /// cuando el token es inválido, malformado o el claim no existe.
  static String? extraerTenantId(String jwt) {
    final payload = extraerPayload(jwt);
    if (payload == null) return null;

    final tenantId = payload['tenant_id'];
    return tenantId is String ? tenantId : null;
  }

  /// Extrae el claim `user_rol` del payload del JWT, o retorna `null`
  /// cuando el token es inválido, malformado o el claim no existe.
  static String? extraerRol(String jwt) {
    final payload = extraerPayload(jwt);
    if (payload == null) return null;

    final rol = payload['user_rol'];
    return rol is String ? rol : null;
  }

  /// Indica si el JWT está expirado comparando el claim `exp`
  /// con la hora actual en segundos epoch.
  /// Si el JWT es inválido, el payload no tiene `exp` o el claim es inválido,
  /// retorna `true` para evitar aceptar un token no válido.
  static bool estaExpirado(String jwt) {
    final payload = extraerPayload(jwt);
    if (payload == null) return true;

    final exp = payload['exp'];
    if (exp is int || exp is double) {
      final ahora = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp < ahora;
    }

    return true;
  }

  /// Decodifica el payload del JWT en base64Url y retorna un mapa
  /// de claims, o `null` si el JWT está vacío, tiene otra cantidad de partes,
  /// está malformado, el base64 no se puede normalizar o decodificar,
  /// o el JSON no produce un mapa válido.
  static Map<String, dynamic>? extraerPayload(String jwt) {
    if (jwt.trim().isEmpty) return null;

    final partes = jwt.split('.');
    if (partes.length != 3) return null;

    final payloadBase64 = partes[1];
    if (payloadBase64.isEmpty) return null;

    try {
      final payloadNormalizado = _normalizarBase64Url(payloadBase64);
      final bytes = base64Url.decode(payloadNormalizado);
      final jsonString = utf8.decode(bytes);
      final json = jsonDecode(jsonString);

      if (json is! Map<String, dynamic>) {
        if (json is Map) {
          return Map<String, dynamic>.from(json);
        }
        return null;
      }

      return json;
    } catch (_) {
      return null;
    }
  }

  /// Normaliza un fragmento base64Url eliminando el padding requerido
  /// por la decodificación estándar y agregando el relleno justo cuando
  /// el tamaño del texto no es múltiplo de 4.
  static String _normalizarBase64Url(String valor) {
    final modulo = valor.length % 4;
    if (modulo == 0) return valor;

    final relleno = '=' * (4 - modulo);
    return '$valor$relleno';
  }
}
