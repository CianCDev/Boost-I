import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Modo de ejecución de la app.
///
/// - [client]: App para dueños/empleados de locales (POS).
/// - [admin]: App para super admins (Control Center).
enum AppMode {
  client,
  admin;

  bool get isAdmin => this == AppMode.admin;
  bool get isClient => this == AppMode.client;
}

/// Provider global del modo de la app.
///
/// Debe ser sobreescrito en los entry points (main_client.dart / main_admin.dart)
/// usando `ProviderScope(overrides: [appModeProvider.overrideWithValue(mode)])`.
final appModeProvider = Provider<AppMode>((ref) {
  throw UnimplementedError('Debe sobreescribirse en main_*.dart');
});
