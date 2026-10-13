// lib/app.dart
//
// 🎯 Widget raíz de la aplicación.
// Los entry points oficiales son:
//   - lib/main_client.dart (flavor client)
//   - lib/main_admin.dart (flavor admin)
//
// La lógica de inicialización está en lib/core/bootstrap.dart.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, Session, AuthChangeEvent;

import 'core/config/app_mode.dart';
import 'features/pos/data/Local/entities/isar_service.dart';
import 'features/pos/domain/permissions/roles.dart';
import 'features/pos/domain/services/jwt_service.dart';
import 'features/pos/presentation/providers/lock_provider.dart';
import 'features/pos/presentation/providers/sync_provider.dart';
import 'features/pos/presentation/providers/tenant_provider.dart';
import 'features/pos/presentation/providers/themes/theme.dart';
import 'features/pos/presentation/providers/themes/theme_provider.dart';
import 'features/pos/presentation/providers/usuario_provider.dart';
import 'features/pos/presentation/screens/empleados/employees_screen.dart';
import 'features/pos/presentation/screens/login_screen.dart';
import 'features/pos/presentation/screens/main_pos_screen.dart';
import 'features/pos/presentation/screens/rest_screen.dart';
import 'features/pos/presentation/screens/setup_pin_screen.dart';
import 'features/pos/presentation/screens/splash_screen.dart';
import 'features/pos/presentation/utils/tenant_utils.dart';
import 'features/pos/presentation/widgets/idle_detector_widget.dart';

// ════════════════════════════════════════════════════════════════════
// APP ROOT
// ════════════════════════════════════════════════════════════════════

// appModeProvider está definido en core/config/app_mode.dart

class BoostiPOS extends ConsumerStatefulWidget {
  final bool supabaseInitialized;
  final AppMode mode;

  const BoostiPOS({
    super.key,
    required this.supabaseInitialized,
    this.mode = AppMode.client,
  });

  @override
  ConsumerState<BoostiPOS> createState() => _BoostiPOSState();
}

class _BoostiPOSState extends ConsumerState<BoostiPOS> {
  bool _syncStarted = false;
  bool _bootstrapDone = false;
  StreamSubscription<sb.AuthState>? _authStateSubscription;

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

    // 🎯 FIX: validar coherencia entre JWT y LocalEntity.activo al arrancar.
    try {
      final tenantJwt = getTenantIdFromJWT();
      if (tenantJwt != null && tenantJwt.isNotEmpty) {
        final isar = IsarService();
        final local = await isar.obtenerLocalPorSupabaseId(tenantJwt);

        if (local != null) {
          if (!local.activo) {
            debugPrint(
              '🔧 [Bootstrap] Local "${local.nombre}" del JWT estaba inactivo. '
              'Reactivando.',
            );
            await isar.marcarLocalComoActivo(local.id);
          }

          // ⚠️ NO forzar "dejar solo un local activo" aquí.
          //
          // El modelo es MULTI-LOCAL: varios locales de un mismo tenant
          // pueden estar activos a la vez. `activo` significa "este local
          // está habilitado", NO "es el actual".
          //
          // El local actual vive en `prefs['localActualId']` y en el estado
          // de `localActualProvider`. Esta rama se eliminó porque su
          // intención original (dejar uno solo) era incorrecta y, con la
          // semántica nueva, solo generaba un log engañoso en cada arranque.

          debugPrint(
            '✅ [Bootstrap] Local validado: "${local.nombre}" '
            '(supabaseId=$tenantJwt)',
          );
        } else {
          debugPrint(
            '⚠️ [Bootstrap] Sin LocalEntity para tenant $tenantJwt. '
            'La app usará el fallback de prefs.',
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ [Bootstrap] Error validando local activo: $e');
    }

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

  Widget _homeInicial() {
    if (!widget.supabaseInitialized) {
      return const _SupabaseNoConfiguradoScreen();
    }

    final usuario = ref.watch(usuarioActualProvider);
    if (usuario != null) {
      // ── PIN obligatorio ──
      //
      // Este es el arranque en frío: se entra directo al POS con la sesión
      // persistida, sin pasar por el login. Un usuario con `pin = ''` (alta
      // por `create-tenant`, o alta en el Panel de Personal sin PIN) llega
      // acá sin haber pasado nunca por `SetupPinScreen`, y queda con un
      // bloqueo blando sin salida: `IsarService.validarLogin` ignora los
      // usuarios con pin vacío y devuelve `null`, así que `RestScreen` le
      // responde "PIN incorrecto" para siempre.
      if (usuario.pin.isEmpty) {
        final role = UserRole.fromString(usuario.rol);
        final destino = Permissions.isEmployeesOnlyRole(role)
            ? const EmployeesScreen()
            : const MainPosScreen();
        return SetupPinScreen(destino: destino);
      }

      final role = UserRole.fromString(usuario.rol);

      if (Permissions.isEmployeesOnlyRole(role)) {
        return const EmployeesScreen();
      }

      return const MainPosScreen();
    }

    return const SplashScreen();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(lockProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: widget.mode.isAdmin ? 'TuApp Admin' : 'TuApp',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: themeMode,
      navigatorObservers: [_navigatorObserver],
      home: _homeInicial(),
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

