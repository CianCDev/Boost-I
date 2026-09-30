// lib/core/security/telegram_crypto.dart
//
// Encriptación simétrica para tokens de Telegram usando AES-256-CBC.
// Reemplaza la encriptación del lado de Supabase (pgcrypto + Vault)
// para evitar problemas de permisos con funciones criptográficas.
//
// La clave se deriva de un secreto almacenado en SharedPreferences
// y se rota manualmente si es necesario.

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio de encriptación para tokens de Telegram.
///
/// Usa AES-256-CBC con una clave derivada de un secreto local.
/// NO usa Supabase Vault ni pgcrypto.
class TelegramCrypto {
  TelegramCrypto._();

  static const String _keyStorage = 'telegram_encryption_key';

  /// Genera una clave AES-256 aleatoria (32 bytes) en base64.
  static String generateKey() {
    final random = Random.secure();
    final bytes = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      bytes[i] = random.nextInt(256);
    }
    return base64Encode(bytes);
  }

  /// Obtiene la clave de encriptación de SharedPreferences.
  /// Si no existe, genera una nueva y la guarda.
  static Future<encrypt.Key> _getKey() async {
    final prefs = await SharedPreferences.getInstance();
    var keyString = prefs.getString(_keyStorage);

    if (keyString == null || keyString.isEmpty) {
      keyString = generateKey();
      await prefs.setString(_keyStorage, keyString);
    }

    return encrypt.Key(base64Decode(keyString));
  }

  /// Encripta un token de Telegram.
  ///
  /// Retorna un string base64 con el formato: `iv:ciphertext`.
  /// Si el token es null o vacío, retorna null.
  static Future<String?> encryptToken(String? token) async {
    if (token == null || token.isEmpty) return null;

    final key = await _getKey();
    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.cbc),
    );

    final encrypted = encrypter.encrypt(token, iv: iv);
    return '${base64Encode(iv.bytes)}:${encrypted.base64}';
  }

  /// Desencripta un token de Telegram.
  ///
  /// Espera el formato `iv:ciphertext` (base64).
  /// Si el token es null o vacío, retorna null.
  /// Si falla la desencriptación, retorna null.
  static Future<String?> decryptToken(String? encryptedToken) async {
    if (encryptedToken == null || encryptedToken.isEmpty) return null;

    try {
      final parts = encryptedToken.split(':');
      if (parts.length != 2) return null;

      final ivBytes = base64Decode(parts[0]);
      final cipherBytes = base64Decode(parts[1]);

      final key = await _getKey();
      final iv = encrypt.IV(ivBytes);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      final decrypted = encrypter.decrypt64(
        base64Encode(cipherBytes),
        iv: iv,
      );
      return decrypted;
    } catch (e) {
      // Si falla la desencriptación (clave incorrecta, datos corruptos)
      return null;
    }
  }

  /// Verifica si un token parece estar encriptado (formato iv:ciphertext).
  static bool isEncrypted(String? token) {
    if (token == null || token.isEmpty) return false;
    final parts = token.split(':');
    if (parts.length != 2) return false;
    // Verificar que ambas partes son base64 válido
    try {
      base64Decode(parts[0]);
      base64Decode(parts[1]);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Hash SHA-256 del token (para logs de auditoría, nunca guardar el token).
  static String hashForAudit(String token) {
    final bytes = utf8.encode(token);
    return sha256.convert(bytes).toString();
  }
}
