// lib/core/security/secure_credentials.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Manejo centralizado de credenciales sensibles: Supabase, tokens,
/// contraseñas y PINs.
///
/// **Importante**: este archivo NO cifra datos. Almacena en
/// `SharedPreferences` (texto plano) con validaciones estrictas. Para
/// producción con clientes enterprise, migrar a `flutter_secure_storage`
/// (Keychain en iOS, Keystore en Android, DPAPI en Windows).
///
/// La API pública está pensada para ser drop-in compatible con esa
/// migración futura: solo se cambiaría la implementación interna.
class SecureCredentials {
  SecureCredentials._();

  // ══════════════════════════════════════════════════════════════
  // CLAVES DE ALMACENAMIENTO
  // ══════════════════════════════════════════════════════════════

  static const String _keySupabaseUrl = 'https://moeedweiombdnssjrgai.supabase.co';
  static const String _keySupabaseAnonKey = 'sb_publishable_3u_VXY6GnKj6i0z1eerteA_9dVsym2K';
  static const String _keyEmpresaId = 'empresa_id';
  static const String _keySyncServerUrl = 'sync_server_url';
  static const String _keySyncApiKey = 'sync_api_key';
  static const String _keyTelegramBotToken = 'telegram_bot_token';
  static const String _keyTelegramChatId = 'telegram_chat_id';

  // ══════════════════════════════════════════════════════════════
  // VALIDADORES
  // ══════════════════════════════════════════════════════════════

  /// Valida que una URL sea HTTPS y no esté vacía.
  ///
  /// Reglas:
  /// - Debe empezar con `https://` (bloquea HTTP en claro).
  /// - Debe tener un host válido (con o sin puerto).
  /// - No puede contener espacios.
  ///
  /// Acepta URLs sin path: `https://abc.supabase.co` es válido.
  static bool isValidSupabaseUrl(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final trimmed = url.trim();

    if (trimmed.contains(' ')) return false;

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return false;

    if (uri.scheme.toLowerCase() != 'https') return false;
    if (uri.host.isEmpty) return false;

    // Aceptamos dominios con al menos un punto (ej: abc.supabase.co)
    // y también localhost para desarrollo (localhost:54321).
    final host = uri.host.toLowerCase();
    if (host == 'localhost' || host == '127.0.0.1') return true;
    if (!host.contains('.')) return false;

    return true;
  }

  /// Valida el formato de la Anon Key de Supabase.
  ///
  /// Supabase emite dos formatos:
  /// - Legacy JWT: 3 segmentos base64 separados por punto, >100 chars.
  /// - Nuevo publishableKey: `sb_publishable_...` (~40 chars).
  /// - Nuevo secretKey: `sb_secret_...` (NO debe usarse en cliente).
  static bool isValidSupabaseKey(String? key) {
    if (key == null || key.trim().isEmpty) return false;
    final trimmed = key.trim();

    if (trimmed.contains(' ')) return false;

    // Formato legacy JWT
    if (trimmed.split('.').length == 3 && trimmed.length > 100) {
      return true;
    }

    // Nuevo formato publishable
    if (trimmed.startsWith('sb_publishable_') && trimmed.length >= 30) {
      return true;
    }

    // Rechazar claves secretas explícitamente
    if (trimmed.startsWith('sb_secret_')) {
      if (kDebugMode) {
        debugPrint(
          '⛔ Rechazada: `sb_secret_*` no debe usarse en cliente. '
          'Esto expone tu base de datos completa.',
        );
      }
      return false;
    }

    return false;
  }

  /// Valida la empresa ID (UUID v4) o string alfanumérico razonable.
  static bool isValidEmpresaId(String? id) {
    if (id == null || id.trim().isEmpty) return false;
    final trimmed = id.trim();
    if (trimmed.length < 4 || trimmed.length > 64) return false;
    return RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(trimmed);
  }

  /// Fuerza de PIN: 4-6 dígitos numéricos.
  ///
  /// Rechaza PINs triviales:
  /// - 0000, 1111, ..., 9999 (repetidos)
  /// - 1234, 4321, 0123 (secuenciales)
  /// - Misma cifra que el año actual (ej: 2026)
  static PinValidation validatePin(String? pin) {
    if (pin == null || pin.isEmpty) {
      return const PinValidation(false, 'El PIN no puede estar vacío');
    }
    final trimmed = pin.trim();

    if (!RegExp(r'^\d+$').hasMatch(trimmed)) {
      return const PinValidation(false, 'El PIN debe contener solo números');
    }

    if (trimmed.length < 4) {
      return const PinValidation(false, 'El PIN debe tener al menos 4 dígitos');
    }
    if (trimmed.length > 6) {
      return const PinValidation(false, 'El PIN no puede tener más de 6 dígitos');
    }

    // Repetidos
    if (RegExp(r'^(\d)\1+$').hasMatch(trimmed)) {
      return const PinValidation(
        false,
        'El PIN no puede tener todos los dígitos iguales',
      );
    }

    // Secuenciales ascendentes/descendentes
    const secuencias = ['0123', '1234', '2345', '3456', '4567', '5678',
                        '6789', '9876', '8765', '7654', '6543', '5432',
                        '4321', '3210'];
    if (secuencias.contains(trimmed)) {
      return const PinValidation(
        false,
        'El PIN no puede ser una secuencia obvia',
      );
    }

    // Año actual
    final anioActual = DateTime.now().year.toString();
    if (trimmed == anioActual) {
      return const PinValidation(false, 'El PIN no puede ser el año actual');
    }

    return const PinValidation(true, null);
  }

  /// Fuerza de contraseña (para cuentas de admin en Supabase Auth).
  ///
  /// Requisitos mínimos:
  /// - 8 caracteres
  /// - Al menos 1 mayúscula
  /// - Al menos 1 minúscula
  /// - Al menos 1 número
  /// - Recomendado: 1 símbolo (bonus, no obligatorio)
  static PasswordStrength evaluatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return PasswordStrength.none;
    }
    if (password.length < 8) return PasswordStrength.weak;

    final tieneMayus = RegExp(r'[A-Z]').hasMatch(password);
    final tieneMinus = RegExp(r'[a-z]').hasMatch(password);
    final tieneNumero = RegExp(r'[0-9]').hasMatch(password);
    final tieneSimbolo = RegExp(r'[^A-Za-z0-9]').hasMatch(password);
    final tieneLargo = password.length >= 12;

    final puntos = [
      tieneMayus,
      tieneMinus,
      tieneNumero,
      tieneSimbolo,
      tieneLargo,
    ].where((e) => e).length;

    if (puntos <= 2) return PasswordStrength.weak;
    if (puntos == 3) return PasswordStrength.fair;
    if (puntos == 4) return PasswordStrength.strong;
    return PasswordStrength.excellent;
  }

  /// Valida el token de Telegram Bot.
  ///
  /// Formato: `<digits>:<base64url>` (ej: `123456789:ABCdef...`).
  static bool isValidTelegramToken(String? token) {
    if (token == null || token.trim().isEmpty) return false;
    return RegExp(r'^\d{6,12}:[A-Za-z0-9_-]{30,}$').hasMatch(token.trim());
  }

  /// Valida el Chat ID de Telegram (numérico, puede ser negativo para grupos).
  static bool isValidTelegramChatId(String? chatId) {
    if (chatId == null || chatId.trim().isEmpty) return false;
    return RegExp(r'^-?\d{5,20}$').hasMatch(chatId.trim());
  }

  // ══════════════════════════════════════════════════════════════
  // LECTURA / ESCRITURA DE SUPABASE
  // ══════════════════════════════════════════════════════════════

  /// Guarda la configuración de Supabase si pasa validaciones.
  /// Devuelve `null` si todo ok, o el mensaje de error si falla.
  static Future<String?> saveSupabaseConfig({
    required String url,
    required String anonKey,
    required String empresaId,
  }) async {
    if (!isValidSupabaseUrl(url)) {
      return 'URL inválida. Debe ser HTTPS y tener un host válido.';
    }
    if (!isValidSupabaseKey(anonKey)) {
      return 'Anon Key inválida. Verifica que no sea una clave secreta.';
    }
    if (!isValidEmpresaId(empresaId)) {
      return 'ID de empresa inválido.';
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySupabaseUrl, _normalizarUrl(url));
    await prefs.setString(_keySupabaseAnonKey, anonKey.trim());
    await prefs.setString(_keyEmpresaId, empresaId.trim());

    return null;
  }

  /// Lee la configuración de Supabase. Devuelve `null` si no está completa
  /// o es inválida.
  static Future<SupabaseConfig?> readSupabaseConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(_keySupabaseUrl);
    final anonKey = prefs.getString(_keySupabaseAnonKey);
    final empresaId = prefs.getString(_keyEmpresaId);

    if (!isValidSupabaseUrl(url)) return null;
    if (!isValidSupabaseKey(anonKey)) return null;
    if (!isValidEmpresaId(empresaId)) return null;

    return SupabaseConfig(
      url: _normalizarUrl(url!),
      anonKey: anonKey!,
      empresaId: empresaId!,
    );
  }

  /// Elimina credenciales de Supabase (para desconectar la empresa).
  static Future<void> clearSupabaseConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySupabaseUrl);
    await prefs.remove(_keySupabaseAnonKey);
    await prefs.remove(_keyEmpresaId);
  }

  // ══════════════════════════════════════════════════════════════
  // SYNC SERVICE
  // ══════════════════════════════════════════════════════════════

  static Future<String?> saveSyncConfig({
    required String serverUrl,
    required String apiKey,
  }) async {
    if (!isValidSupabaseUrl(serverUrl)) {
      return 'URL del servidor de sync inválida.';
    }
    if (apiKey.trim().length < 16) {
      return 'API Key de sync demasiado corta (mínimo 16 caracteres).';
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySyncServerUrl, _normalizarUrl(serverUrl));
    await prefs.setString(_keySyncApiKey, apiKey.trim());
    return null;
  }

  static Future<String?> getSyncServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySyncServerUrl);
  }

  static Future<String?> getSyncApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySyncApiKey);
  }

  // ══════════════════════════════════════════════════════════════
  // TELEGRAM
  // ══════════════════════════════════════════════════════════════

  static Future<String?> saveTelegramConfig({
    required String botToken,
    required String chatId,
  }) async {
    if (!isValidTelegramToken(botToken)) {
      return 'Token de bot inválido. Formato esperado: 123:ABC...';
    }
    if (!isValidTelegramChatId(chatId)) {
      return 'Chat ID inválido. Debe ser numérico.';
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyTelegramBotToken, botToken.trim());
    await prefs.setString(_keyTelegramChatId, chatId.trim());
    return null;
  }

  static Future<({String? token, String? chatId})> readTelegramConfig() async {
    final prefs = await SharedPreferences.getInstance();
    return (
      token: prefs.getString(_keyTelegramBotToken),
      chatId: prefs.getString(_keyTelegramChatId),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS INTERNOS
  // ══════════════════════════════════════════════════════════════

  /// Normaliza URL: quita espacios, barra final, y reduce a esquema + host.
  static String _normalizarUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return trimmed;
    // Mantenemos puerto si existe (dev local: localhost:54321)
    if (uri.hasPort) {
      return '${uri.scheme}://${uri.host}:${uri.port}';
    }
    return '${uri.scheme}://${uri.host}';
  }

  // ══════════════════════════════════════════════════════════════
  // HASHING (para logs de auditoría, no para passwords)
  // ══════════════════════════════════════════════════════════════

  /// Hash SHA-256 de un string. Útil para guardar huellas de credenciales
  /// en logs de auditoría sin exponerlas.
  ///
  /// Ejemplo: registrar `hash(apiKey)` cuando se rota, para poder
  /// auditar "qué clave estaba activa en tal fecha" sin ver el valor.
  static String hashForAudit(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  /// Compara dos hashes en tiempo constante (evita timing attacks).
  static bool compareHashes(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}

// ══════════════════════════════════════════════════════════════════
// MODELOS AUXILIARES
// ══════════════════════════════════════════════════════════════════

class SupabaseConfig {
  final String url;
  final String anonKey;
  final String empresaId;

  const SupabaseConfig({
    required this.url,
    required this.anonKey,
    required this.empresaId,
  });

  @override
  String toString() => 'SupabaseConfig(url=$url, empresa=$empresaId)';
}

class PinValidation {
  final bool isValid;
  final String? error;

  const PinValidation(this.isValid, this.error);
}

enum PasswordStrength {
  none('Sin contraseña', 0),
  weak('Débil', 1),
  fair('Aceptable', 2),
  strong('Fuerte', 3),
  excellent('Excelente', 4);

  final String label;
  final int score;
  const PasswordStrength(this.label, this.score);
}