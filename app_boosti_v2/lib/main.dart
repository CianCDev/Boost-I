// lib/main.dart
import 'dart:async';
import 'dart:io';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🔥 Configuración de Supabase compilada
import 'core/config/supabase_config.dart';

// Entities & Services
import 'features/pos/data/Local/entities/isar_service.dart';
import 'features/pos/domain/permissions/roles.dart';
import 'features/pos/domain/services/jwt_service.dart';

// Providers
import 'features/pos/presentation/providers/lock_provider.dart';
import 'features/pos/presentation/providers/sync_provider.dart';
import 'features/pos/presentation/providers/tenant_provider.dart';
import 'features/pos/presentation/providers/themes/theme.dart';
import 'features/pos/presentation/providers/themes/theme_provider.dart';
import 'features/pos/presentation/providers/usuario_provider.dart';

// Screens
// 🎯 ELIMINADO: import de configuracion_empresa_screen.dart (ya no existe)
import 'features/pos/presentation/screens/empleados/employees_screen.dart';
import 'features/pos/presentation/screens/login_screen.dart';
import 'features/pos/presentation/screens/main_pos_screen.dart';
import 'features/pos/presentation/screens/rest_screen.dart';
import 'features/pos/presentation/screens/splash_screen.dart';

// Services
import 'features/pos/presentation/services/backup_service.dart';
import 'features/pos/presentation/services/error_service.dart';
import 'features/pos/presentation/services/ota_update_service.dart';

// Widgets
import 'features/pos/presentation/widgets/idle_detector_widget.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


// ════════════════════════════════════════════════════════════════════
// MAIN
// ════════════════════════════════════════════════════════════════════

void main() async {
  if (kDebugMode) {
    debugPrint('🚀 BoostiPOS iniciando — ${DateTime.now()}');
    debugPrint('🔍 SupabaseConfig.estaConfigurado: ${SupabaseConfig.estaConfigurado}');
    debugPrint('🔍 URL: "${SupabaseConfig.url}"');
    debugPrint('🔍 Key length: ${SupabaseConfig.publishableKey.length}');
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

  // ── 2. Tareas en background (no bloquean el arranque) ──
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

  // ── 3. Metadatos de la app (para Sentry release dinámico) ──
  String release = 'unknown';
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    release = '${packageInfo.version}+${packageInfo.buildNumber}';
    debugPrint('📦 App release: $release');
  } catch (e) {
    debugPrint('⚠️ No se pudo obtener PackageInfo: $e');
  }

  // ── 4. Sentry ──
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://d6ba391e37a1ea64b67002541041c94d@o4512161811922944.ingest.us.sentry.io/4512164794793984';

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
    appRunner: () => runApp(
      SentryWidget(
        child: DevicePreview(
          enabled: !kReleaseMode,
          builder: (_) => ProviderScope(
            child: BoostiPOS(supabaseInitialized: supabaseInitialized),
          ),
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════
// HELPERS DE INICIALIZACIÓN
// ════════════════════════════════════════════════════════════════════

/// Inicializa Supabase usando EXCLUSIVAMENTE las credenciales
/// compiladas vía `--dart-define-from-file=env.json`.
///
/// 🎯 SEGURIDAD: Se eliminó el fallback a SharedPreferences. La app
/// nunca acepta credenciales ingresadas por el usuario final.
/// Si `env.json` no se pasó al compilar, la app muestra una pantalla
/// de error en vez del formulario de configuración.
Future<bool> _inicializarSupabase(SharedPreferences prefs) async {
  // ── Única fuente de credenciales: env.json ──
  if (!SupabaseConfig.estaConfigurado) {
    debugPrint(
      '🚨 SEGURIDAD: App compilada SIN env.json. '
      'No hay forma de conectarse a Supabase. '
      'Compila con --dart-define-from-file=env.json',
    );
    return false;
  }

  var url = SupabaseConfig.url;
  final anonKey = SupabaseConfig.publishableKey;

  debugPrint('✅ Usando credenciales de env.json (hardcoded en el binario)');

  // Normalizar URL (quitar barra final, rutas extras)
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

    // Persistimos para que otros servicios que leen prefs sigan funcionando
    await prefs.setString('supabase_url', url);
    await prefs.setString('supabase_anon_key', anonKey);

    debugPrint('✅ Supabase inicializado → $url');
    return true;
  } catch (e) {
    debugPrint('🚨 Error inicializando Supabase: $e');
    return false;
  }
}

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

// ════════════════════════════════════════════════════════════════════
// APP ROOT
// ════════════════════════════════════════════════════════════════════

class BoostiPOS extends ConsumerStatefulWidget {
  final bool supabaseInitialized;

  const BoostiPOS({super.key, required this.supabaseInitialized});

  @override
  ConsumerState<BoostiPOS> createState() => _BoostiPOSState();
}

class _BoostiPOSState extends ConsumerState<BoostiPOS> {
  bool _syncStarted = false;
  bool _bootstrapDone = false;
  StreamSubscription<AuthState>? _authStateSubscription;

  final _navigatorObserver = SentryNavigatorObserver();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _bootstrap();
      _setupAuthStateListener();
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  void _setupAuthStateListener() {
    if (!widget.supabaseInitialized) return;

    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        debugPrint('🔄 JWT renovado automáticamente por Supabase Auth.');
        _actualizarTenantDesdeSesion(session);
        return;
      }

      if (event == AuthChangeEvent.signedOut) {
        debugPrint('🚪 Sesión Supabase cerrada → limpiando tenant');
        ref.read(tenantActualProvider.notifier).limpiar();
      }
    });
  }

  Future<void> _bootstrap() async {
    if (_bootstrapDone) return;
    _bootstrapDone = true;

    if (!mounted) return;

    ref.read(tenantActualProvider);
    await _cargarTenantDesdeSesion();

    if (widget.supabaseInitialized && !_syncStarted) {
      _syncStarted = true;
      _startBackgroundSync();
    }
  }

  Future<void> _actualizarTenantDesdeSesion(Session session) async {
    final token = session.accessToken;
    final tenantJwt = JwtService.extraerTenantId(token);
    final rol = JwtService.extraerRol(token);

    if (tenantJwt == null || tenantJwt.isEmpty) {
      debugPrint('ℹ️ JWT sin tenant_id. No se actualiza.');
      return;
    }

    final tenantActual = ref.read(tenantActualProvider).tenantId;

    if (tenantJwt == tenantActual) {
      return;
    }

    debugPrint(
        '🔍 JWT trae tenant $tenantJwt (actual: $tenantActual). Validando...');

    try {
      final isar = IsarService();
      final localIsar = await isar.obtenerLocalPorSupabaseId(tenantJwt);

      if (localIsar != null) {
        debugPrint('✅ Tenant $tenantJwt existe en Isar. Aceptado.');
        await ref
            .read(tenantActualProvider.notifier)
            .setTenant(tenantJwt, rol: rol);
        return;
      }

      final supaLocal = await Supabase.instance.client
          .from('locales')
          .select('id, nombre')
          .eq('id', tenantJwt)
          .maybeSingle();

      if (supaLocal != null) {
        debugPrint(
            '✅ Tenant $tenantJwt existe en Supabase ("${supaLocal['nombre']}"). Aceptado.');
        await ref
            .read(tenantActualProvider.notifier)
            .setTenant(tenantJwt, rol: rol);
        return;
      }

      debugPrint(
          '🚨 Tenant $tenantJwt NO existe en Isar ni en Supabase. '
          'Cerrando sesión huérfana para forzar re-login.');

      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('⚠️ Error en signOut forzado: $e');
      }

      await ref.read(tenantActualProvider.notifier).limpiar();
      ref.read(usuarioActualProvider.notifier).clearUsuario();
    } catch (e) {
      debugPrint('⚠️ Error validando tenant $tenantJwt: $e');
    }
  }

  Future<void> _cargarTenantDesdeSesion() async {
    try {
      if (!widget.supabaseInitialized) return;

      try {
        final res = await Supabase.instance.client.auth.refreshSession();
        if (res.session != null) {
          debugPrint('🔄 JWT refrescado manualmente al iniciar app');
          await _actualizarTenantDesdeSesion(res.session!);
          return;
        }
      } catch (e) {
        debugPrint(
            'ℹ️ No se pudo refrescar la sesión manualmente (modo offline): $e');
      }

      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        debugPrint('ℹ️ Sin sesión Supabase cacheada → tenant desde prefs');
        return;
      }

      await _actualizarTenantDesdeSesion(session);
    } catch (e) {
      debugPrint('⚠️ Error rehidratando tenant: $e');
    }
  }

  Future<void> _startBackgroundSync() async {
    final syncService = ref.read(syncServiceProvider);
    syncService.iniciarSuscripcionesRealtime();
    syncService.iniciarMonitoreo();

    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null) {
      debugPrint('ℹ️ Sin sesión → se omite sync inicial');
      return;
    }

    try {
      debugPrint('🚀 Sincronización inicial en background...');
      await syncService.descargarLocalesDesdeSupabase();
      await syncService.sincronizarUsuariosDesdeSupabase();
      await syncService.descargarPedidosDesdeSupabase();
      debugPrint('✅ Sincronización inicial completada');
    } catch (e) {
      debugPrint('⚠️ Sync inicial falló (no bloquea): $e');
    }
  }

  /// Determina la pantalla inicial.
  ///
  /// 🎯 SEGURIDAD: si Supabase no está configurado (falta env.json),
  /// mostramos una pantalla de error en vez del formulario de
  /// configuración. Esto evita que usuarios finales ingresen
  /// credenciales arbitrarias.
  Widget _homeInicial() {
    if (!widget.supabaseInitialized) {
      return const _SupabaseNoConfiguradoScreen();
    }

    final usuario = ref.watch(usuarioActualProvider);
    if (usuario != null) {
      final role = UserRole.fromString(usuario.rol);

      if (Permissions.isEmployeesOnlyRole(role)) {
        return const EmployeesScreen();
      }

      return const MainPosScreen();
    }

    // Sin usuario local → Splash valida y redirige a Welcome/Login
    return const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(lockProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'BoostI POS - JAH Lab',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: themeMode,
      navigatorObservers: [_navigatorObserver],
      home: _homeInicial(),
      // 🎯 ELIMINADA la ruta '/configuracion'
      routes: {
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainPosScreen(),
        '/employees': (_) => const EmployeesScreen(),
      },
      builder: (context, child) {
        return UserActivityDetector(
          child: Stack(
            children: [
              child!,
              if (isLocked) const Positioned.fill(child: RestScreen()),
            ],
          ),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════════
// PANTALLA DE ERROR: SUPABASE NO CONFIGURADO
// ════════════════════════════════════════════════════════════════════
//
// 🎯 SEGURIDAD: esta pantalla se muestra SOLO si la app se compiló
// sin el archivo env.json. No permite ninguna interacción con
// credenciales. El usuario final debe contactar al proveedor.

class _SupabaseNoConfiguradoScreen extends StatelessWidget {
  const _SupabaseNoConfiguradoScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 72,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 20),
              const Text(
                'Configuración no disponible',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Esta versión de la aplicación no fue compilada con las '
                'credenciales necesarias. Contacta a tu proveedor para '
                'obtener una versión válida.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}