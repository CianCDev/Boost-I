// lib/features/pos/services/error_service.dart
import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Servicio centralizado para capturar errores usando SOLO Sentry.
/// Funciona en Windows, Android, iOS y Web.
class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  static bool _initialized = false;

  /// Cuelga los handlers de crash globales.
  ///
  /// ⚠️ NO inicializa Sentry. Eso lo hace `bootstrap()`, que es el único
  ///    que conoce el `release`, el `environment` y el `beforeSend` que
  ///    filtra los errores de red. Llamar a `SentryFlutter.init` desde acá
  ///    inicializaba Sentry DOS veces, con dos configuraciones distintas,
  ///    y ganaba la pobre.
  ///
  /// El DSN se lee de `env.json` vía `--dart-define-from-file` en
  /// `bootstrap.dart` §4. Ver la regla de secretos en `MEMORY.md` §11.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // ============================================================
    // CAPTURAR CRASHES NO MANEJADOS (todas las plataformas)
    // ============================================================
    FlutterError.onError = (errorDetails) {
      Sentry.captureException(
        errorDetails.exception,
        stackTrace: errorDetails.stack,
        hint: Hint.withMap({'context': 'FlutterError.onError'}),
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      return true;
    };

    debugPrint('✅ Handlers de crash registrados');
  }

  /// Captura un error controlado
  static void captureError(
    dynamic error, {
    StackTrace? stack,
    String? hint,
    Map<String, dynamic>? extras,
    bool fatal = false,
  }) {
    final stackTrace = stack ?? StackTrace.current;

    Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: Hint.withMap({
        'context': hint,
        'extras': extras,
      }),
    );

    debugPrint('🚨 [ERROR] $hint: $error');
    if (extras != null) {
      debugPrint('📦 Extras: $extras');
    }
  }

  /// Añadir contexto del usuario
  static void setUser(String userId, String? email, String? name) {
    Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: userId,
        email: email,
        username: name,
      ));
    });
  }

  /// Añadir breadcrumbs (registro de acciones)
  static void addBreadcrumb(String message, {Map<String, dynamic>? data}) {
    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      data: data,
      timestamp: DateTime.now(),
    ));
  }
}