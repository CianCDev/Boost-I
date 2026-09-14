/// Configuración embebida de Supabase.
///
/// Las credenciales se compilan con la app. El usuario final NO las
/// configura manualmente.
///
/// ⚠️ NOTA DE SEGURIDAD:
/// La `publishableKey` (anon key) es pública por diseño. Puede ir en el
/// cliente sin riesgo porque RLS protege los datos en el backend.
/// NUNCA poner la `service_role` key aquí.
class SupabaseConfig {
  /// URL del proyecto Supabase.
  static const String url = 'https://moeedweiombdnssjrgai.supabase.co';

  /// Publishable (anon) key de Supabase.
  static const String publishableKey = 'sb_publishable_3u_VXY6GnKj6i0z1eerteA_9dVsym2K';

  /// Verifica si las credenciales están configuradas.
  ///
  /// Retorna false si los valores siguen siendo placeholders.
  static bool get estaConfigurado {
    return url.isNotEmpty &&
        url != 'TU_URL_AQUI' &&
        publishableKey.isNotEmpty &&
        publishableKey != 'TU_KEY_AQUI';
  }
}