import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Extrae el tenant_id del JWT de la sesión actual de Supabase.
/// Devuelve null si no hay sesión o el claim no existe.
String? getTenantIdFromJWT() {
  try {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    if (token == null) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final claims = json.decode(payload) as Map<String, dynamic>;

    return claims['tenant_id'] as String?;
  } catch (_) {
    return null;
  }
}