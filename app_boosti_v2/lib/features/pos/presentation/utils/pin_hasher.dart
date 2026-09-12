import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

/// Utilidad para hashear y verificar PINs de usuarios.
///
/// Formato almacenado: `sha256:<hash_hex>:<salt_hex>`
/// - El hash es SHA-256 de `${salt}:${pin}`.
/// - El salt es de 16 bytes generados con `Random.secure()`.
///
/// Es idempotente: `isHashed` detecta si un valor ya está en formato hash
/// para evitar doble hasheo.
class PinHasher {
  PinHasher._(); // Constructor privado: clase solo-utilidades.

  static const _prefix = 'sha256:';

  /// Retorna `true` si el valor ya está en formato hash (`sha256:...`).
  static bool isHashed(String value) => value.startsWith(_prefix);

  /// Genera un salt aleatorio de 16 bytes en hex (32 caracteres).
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Hashea un PIN con un salt dado.
  ///
  /// Retorna el string en formato `sha256:<hash>:<salt>`.
  static String hash(String pin, String saltHex) {
    final bytes = utf8.encode('$saltHex:$pin');
    final digest = sha256.convert(bytes);
    return '$_prefix${digest.toString()}:$saltHex';
  }

  /// Hashea un PIN generando un salt nuevo.
  static String hashWithNewSalt(String pin) {
    return hash(pin, generateSalt());
  }

  /// Verifica un PIN contra un valor almacenado.
  ///
  /// Retorna `false` si el valor almacenado no está hasheado o si el
  /// formato es inválido. La comparación en plano la maneja el caller
  /// (para permitir migración en caliente).
  static bool verify(String pin, String stored) {
    if (!isHashed(stored)) return false;
    final parts = stored.split(':');
    if (parts.length != 3) return false;
    final salt = parts[2];
    return hash(pin, salt) == stored;
  }
}