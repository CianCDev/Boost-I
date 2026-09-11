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

  /// Inicializa Sentry (siempre, en todas las plataformas)
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = 'https://773c9f0fead4c95fbbf27aacd669cbd8@o4512050802524160.ingest.us.sentry.io/4512050844008448';
          options.tracesSampleRate = 0.1;
          options.environment = const String.fromEnvironment('ENV', defaultValue: 'production');
        },
        appRunner: () => {},
      );
      debugPrint('✅ Sentry inicializado correctamente');
    } catch (e) {
      debugPrint('⚠️ Error inicializando Sentry: $e');
    }

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