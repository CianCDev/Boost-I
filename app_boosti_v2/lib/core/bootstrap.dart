import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'config/supabase_config.dart';
import '../features/pos/data/Local/entities/isar_service.dart';
import '../features/pos/presentation/services/backup_service.dart';
import '../features/pos/presentation/services/error_service.dart';
import '../features/pos/presentation/services/ota_update_service.dart';

/// Estado de la inicialización.
class BootstrapResult {
  final bool supabaseInitialized;
  final String release;

  const BootstrapResult({
    required this.supabaseInitialized,
    required this.release,
  });
}

/// Indica si ya se ejecutó bootstrap.
bool _bootstrapped = false;

/// Inicializa todos los servicios de la app de forma idempotente.
///
/// Si se llama múltiples veces, solo ejecuta la inicialización una vez.
Future<BootstrapResult> bootstrap() async {
  if (_bootstrapped) {
    debugPrint('⚠️ [Bootstrap] Ya fue ejecutado. Retornando resultado cacheado.');
    return BootstrapResult(
      supabaseInitialized: Supabase.instance.isInitialized,
      release: 'cached',
    );
  }
  _bootstrapped = true;

  if (kDebugMode) {
    debugPrint('🚀 [Bootstrap] Iniciando — ${DateTime.now()}');
    debugPrint('🔍 SupabaseConfig.estaConfigurado: ${SupabaseConfig.estaConfigurado}');
  }

  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Inicializaciones en paralelo ──
  final prefs = await SharedPreferences.getInstance();

  final results = await Future.wait([
    ErrorService.init().catchError((e) {
      debugPrint('⚠️ ErrorService.init falló: $e');
    }),
    _inicializarSupabase(prefs),
    _inicializarIsar(),
  ]);

  final supabaseInitialized = results[1] as bool;

  // ── 2. Tareas en background ──
  try {
    BackupService.register();
  } catch (e) {
    debugPrint('⚠️ BackupService.register falló: $e');
  }

  try {
    OtaUpdateService.checkForUpdateSilently();
  } catch (e) {
    debugPrint('⚠️ OTA check falló: $e');
  }

  // ── 3. Metadatos de la app ──
  String release = 'unknown';
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    release = '${packageInfo.version}+${packageInfo.buildNumber}';
    debugPrint('📦 App release: $release');
  } catch (e) {
    debugPrint('⚠️ No se pudo obtener PackageInfo: $e');
  }

  // ── 4. Sentry ──
  //
  // El DSN viene de `env.json` vía `--dart-define-from-file`, igual que
  // `SUPABASE_URL` y `SUPABASE_ANON_KEY`. Antes estaba hardcodeado en esta
  // línea, lo que lo metía en el repositorio y en el diff de cada commit.
  //
  // `String.fromEnvironment` es de TIEMPO DE COMPILACIÓN: si se compila sin
  // `--dart-define-from-file=env.json`, el DSN queda vacío y Sentry queda
  // silenciosamente desactivado. No es un error: `SentryFlutter.init` con
  // un DSN vacío no inicializa nada. Es el mismo contrato que ya usan las
  // credenciales de Supabase.
  const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  if (sentryDsn.isEmpty) {
    debugPrint(
      '⚠️ SENTRY_DSN vacío: Sentry queda desactivado. Compilar con '
      '--dart-define-from-file=env.json para activarlo.',
    );
  }

  await SentryFlutter.init(
    (options) {
      options.dsn = sentryDsn;

      options.environment = kReleaseMode ? 'production' : 'development';
      options.release = release;
      options.tracesSampleRate = kReleaseMode ? 0.1 : 1.0;
      options.profilesSampleRate = kReleaseMode ? 0.1 : 1.0;
      options.attachStacktrace = true;
      options.attachScreenshot = false;

      options.beforeSend = (event, hint) {
        final throwable = event.throwable;

        if (throwable is SocketException) return null;
        if (throwable is TimeoutException) return null;

        final msg = throwable?.toString() ?? '';
        if (msg.contains('SocketException') ||
            msg.contains('Failed host lookup') ||
            msg.contains('Connection refused') ||
            msg.contains('Connection closed')) {
          return null;
        }

        return event;
      };

      if (kDebugMode) {
        options.debug = true;
      }
    },
  );

  debugPrint('✅ [Bootstrap] Completado. Supabase: $supabaseInitialized');

  return BootstrapResult(
    supabaseInitialized: supabaseInitialized,
    release: release,
  );
}

/// Inicializa Supabase usando credenciales compiladas vía env.json.
Future<bool> _inicializarSupabase(SharedPreferences prefs) async {
  if (!SupabaseConfig.estaConfigurado) {
    debugPrint(
      '🚨 SEGURIDAD: App compilada SIN env.json. '
      'No hay forma de conectarse a Supabase.',
    );
    return false;
  }

  var url = SupabaseConfig.url;
  final anonKey = SupabaseConfig.publishableKey;

  if (url.endsWith('/')) url = url.substring(0, url.length - 1);
  final uri = Uri.tryParse(url);
  if (uri != null) {
    url = '${uri.scheme}://${uri.host}';
  }

  try {
    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );

    await prefs.setString('supabase_url', url);
    await prefs.setString('supabase_anon_key', anonKey);

    debugPrint('✅ Supabase inicializado → $url');
    return true;
  } catch (e) {
    debugPrint('🚨 Error inicializando Supabase: $e');
    return false;
  }
}

/// Inicializa Isar y ejecuta migraciones.
Future<void> _inicializarIsar() async {
  try {
    final isarService = IsarService();
    await isarService.migrarStockExistenteALotes();

    final actualizados = await isarService.asignarSupabaseIdsAFaltantes();
    if (actualizados > 0) {
      debugPrint('✅ supabaseId asignados: $actualizados productos');
    }
  } catch (e) {
    debugPrint('❌ Error en inicialización de Isar: $e');
  }
}
