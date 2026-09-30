/// Configuración de Supabase.
///
/// Las credenciales se inyectan al compilar usando:
///
///   flutter run --dart-define-from-file=env.json
///   flutter build apk --release --dart-define-from-file=env.json
///
/// El archivo `env.json` está fuera del repositorio (.gitignore) y contiene:
///   {
///     "SUPABASE_URL": "https://xxxxx.supabase.co",
///     "SUPABASE_ANON_KEY": "sb_publishable_... o eyJ..."
///   }
///
/// Si la app se compila SIN esas variables, `estaConfigurado` devuelve false
/// y el Splash redirige a `ConfiguracionEmpresaScreen` para que el usuario
/// las introduzca manualmente.
///
/// ⚠️ SEGURIDAD:
/// La anon/publishable key es pública por diseño (RLS protege los datos).
/// NUNCA pongas aquí la `service_role` key.
class SupabaseConfig {
  /// URL del proyecto Supabase.
  /// Se inyecta vía --dart-define-from-file=env.json como SUPABASE_URL.
  static const String url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Publishable (anon) key de Supabase.
  /// Se inyecta vía --dart-define-from-file=env.json como SUPABASE_ANON_KEY.
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Verifica si las credenciales están configuradas.
  ///
  /// Devuelve false si:
  ///  - No se pasó `--dart-define-from-file=env.json` al compilar, o
  ///  - El JSON tenía los campos vacíos, o
  ///  - Alguien dejó los placeholders 'TU_URL_AQUI' / 'TU_KEY_AQUI'.
  static bool get estaConfigurado {
    final u = url.trim();
    final k = publishableKey.trim();
    return u.isNotEmpty &&
        u != 'TU_URL_AQUI' &&
        u.startsWith('http') &&
        k.isNotEmpty &&
        k != 'TU_KEY_AQUI';
  }
}