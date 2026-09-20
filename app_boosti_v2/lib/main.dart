// lib/main.dart
import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
import 'features/pos/presentation/screens/configuracion_empresa_screen.dart';
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

// ════════════════════════════════════════════════════════════════════
// MAIN
// ════════════════════════════════════════════════════════════════════

void main() async {
  if (kDebugMode) {
    debugPrint('🚀 BoostiPOS iniciando — ${DateTime.now()}');
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

  // ── 3. App ──
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (_) => ProviderScope(
        child: BoostiPOS(supabaseInitialized: supabaseInitialized),
      ),
    ),
  );
}

// ════════════════════════════════════════════════════════════════════
// HELPERS DE INICIALIZACIÓN
// ════════════════════════════════════════════════════════════════════

Future<bool> _inicializarSupabase(SharedPreferences prefs) async {
  String? url = prefs.getString('supabase_url');
  final anonKey = prefs.getString('supabase_anon_key');

  if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
    debugPrint('⚠️ Sin config Supabase → se mostrará ConfiguracionEmpresa');
    return false;
  }

  // Normalizar URL
  if (url.endsWith('/')) url = url.substring(0, url.length - 1);
  final uri = Uri.tryParse(url);
  if (uri != null) {
    url = '${uri.scheme}://${uri.host}';
  }

  try {
    // 🔥 IMPORTANTE: Se activa autoRefreshToken
    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
      ),
    );
    debugPrint('✅ Supabase inicializado');
    return true;
  } catch (e) {
    debugPrint('⚠️ Error inicializando Supabase: $e');
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

  /// Configura un listener para reaccionar a renovaciones automáticas del JWT.
  void _setupAuthStateListener() {
    if (!widget.supabaseInitialized) return;

    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      // ✅ Reaccionar a renovaciones de token
      if (event == AuthChangeEvent.tokenRefreshed && session != null) {
        debugPrint('🔄 JWT renovado automáticamente por Supabase Auth.');
        _actualizarTenantDesdeSesion(session);
        return;
      }

      // ✅ NUEVO: Limpiar tenant al cerrar sesión
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

    // ✅ Forzar inicialización del TenantNotifier (lee de prefs)
    ref.read(tenantActualProvider);

    // 1. Refrescar JWT y rehidratar tenant desde la sesión activa
    await _cargarTenantDesdeSesion();

    // 2. Sync en background
    if (widget.supabaseInitialized && !_syncStarted) {
      _syncStarted = true;
      _startBackgroundSync();
    }
  }

  /// ✅ CORREGIDO: Valida el tenant antes de aceptarlo.
  ///
  /// Reglas:
  ///   1. Si el JWT no trae tenant → no hace nada.
  ///   2. Si el tenant del JWT == tenant actual → no hace nada (idempotente).
  ///   3. Si el tenant del JWT es distinto → valida contra `locales`.
  ///      - Si existe (Isar o Supabase) → lo acepta.
  ///      - Si NO existe → fuerza logout para evitar RLS bloqueado.
  Future<void> _actualizarTenantDesdeSesion(Session session) async {
    final token = session.accessToken;
    final tenantJwt = JwtService.extraerTenantId(token);
    final rol = JwtService.extraerRol(token);

    if (tenantJwt == null || tenantJwt.isEmpty) {
      debugPrint('ℹ️ JWT sin tenant_id. No se actualiza.');
      return;
    }

    final tenantActual = ref.read(tenantActualProvider).tenantId;

    // ── Caso 1: mismo tenant → no-op ──
    if (tenantJwt == tenantActual) {
      return;
    }

    debugPrint(
        '🔍 JWT trae tenant $tenantJwt (actual: $tenantActual). Validando...');

    // ── Caso 2: validar que el tenant exista ──
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

      // No está en Isar local → verificar en Supabase
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

      // ── Caso 3: tenant fantasma → forzar logout ──
      debugPrint(
          '🚨 Tenant $tenantJwt NO existe en Isar ni en Supabase. '
          'Cerrando sesión huérfana para forzar re-login.');

      try {
        await Supabase.instance.client.auth.signOut();
      } catch (e) {
        debugPrint('⚠️ Error en signOut forzado: $e');
      }

      // Limpiar el tenant local (probablemente apunta a un fantasma)
      await ref.read(tenantActualProvider.notifier).limpiar();

      // Limpiar usuario actual para forzar LoginScreen
      ref.read(usuarioActualProvider.notifier).clearUsuario();
    } catch (e) {
      debugPrint('⚠️ Error validando tenant $tenantJwt: $e');
      // No forzamos logout si el error es de red — preferimos modo offline
    }
  }

  /// Refresca la sesión activa al inicio y rehidrata `tenant_id` del JWT.
  Future<void> _cargarTenantDesdeSesion() async {
    try {
      if (!widget.supabaseInitialized) return;

      // Intentar refrescar sesión manualmente al arrancar la app
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

      // Fallback: usar la sesión cacheada
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

    // Solo sincronizar si hay sesión activa
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

  /// Determina la pantalla inicial según configuración + sesión.
  Widget _homeInicial() {
    if (!widget.supabaseInitialized) {
      return const ConfiguracionEmpresaScreen();
    }

    final usuario = ref.watch(usuarioActualProvider);
    if (usuario != null) {
      final role = UserRole.fromString(usuario.rol);

      if (Permissions.isEmployeesOnlyRole(role)) {
        return const EmployeesScreen();
      }

      return const MainPosScreen();
    }

    // Sin usuario local → Splash valida y redirige
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
      home: _homeInicial(),
      routes: {
        '/configuracion': (_) => const ConfiguracionEmpresaScreen(),
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