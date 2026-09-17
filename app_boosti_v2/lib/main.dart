// lib/main.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/pos/data/Local/entities/isar_service.dart';
import 'features/pos/domain/permissions/roles.dart';
import 'features/pos/presentation/providers/lock_provider.dart';
import 'features/pos/presentation/providers/sync_provider.dart';
import 'features/pos/presentation/providers/themes/theme.dart';
import 'features/pos/presentation/providers/themes/theme_provider.dart';
import 'features/pos/presentation/providers/usuario_provider.dart';
import 'features/pos/presentation/screens/configuracion_empresa_screen.dart';
import 'features/pos/presentation/screens/empleados/employees_screen.dart';
import 'features/pos/presentation/screens/login_screen.dart';
import 'features/pos/presentation/screens/main_pos_screen.dart';
import 'features/pos/presentation/screens/rest_screen.dart';
import 'features/pos/presentation/screens/splash_screen.dart';
import 'features/pos/presentation/services/backup_service.dart';
import 'features/pos/presentation/services/error_service.dart';
import 'features/pos/presentation/services/ota_update_service.dart';
import 'features/pos/presentation/services/sync_service.dart';
import 'features/pos/presentation/widgets/idle_detector_widget.dart';

void main() async {
  if (kDebugMode) {
    debugPrint('🚀 BoostiPOS iniciando — ${DateTime.now()}');
  }

  WidgetsFlutterBinding.ensureInitialized();

  // ════════════════════════════════════════════════════════════════
  // 1. INICIALIZACIONES EN PARALELO (independientes entre sí)
  // ════════════════════════════════════════════════════════════════
  final prefs = await SharedPreferences.getInstance();

  // Estas 3 no dependen entre sí → corren en paralelo con Future.wait
  final results = await Future.wait([
    ErrorService.init().catchError((e) {
      debugPrint('⚠️ ErrorService.init falló: $e');
    }),
    _inicializarSupabase(prefs),
    _inicializarIsar(),
  ]);

  final supabaseInitialized = results[1] as bool;

  // 2. TAREAS EN BACKGROUND (no bloquean el arranque)
// Estos métodos son `void` (no Future), así que se llaman directo.
// Igual corren "en segundo plano" desde el punto de vista del usuario
// porque no bloquean `runApp`.
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

  // ════════════════════════════════════════════════════════════════
  // 3. APP
  // ════════════════════════════════════════════════════════════════
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
    await Supabase.initialize(url: url, publishableKey: anonKey);
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
    await isarService.inicializarUsuarioAdminPorDefecto();
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

  @override
  void initState() {
    super.initState();
    if (widget.supabaseInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _syncStarted) return;
        _syncStarted = true;
        _startBackgroundSync();
      });
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
  ///
  /// Prioridad:
  ///   1. Sin config Supabase → ConfiguracionEmpresaScreen
  ///   2. Con sesión RRHH → EmployeesScreen
  ///   3. Con sesión otro rol → MainPosScreen (welcome)
  ///   4. Sin sesión → SplashScreen (permisos + Login)
  Widget _homeInicial() {
    if (!widget.supabaseInitialized) {
      return const ConfiguracionEmpresaScreen();
    }

    final usuario = ref.watch(usuarioActualProvider);
    if (usuario != null) {
      final role = UserRole.fromString(usuario.rol);

      // RRHH: solo ve empleados
      if (Permissions.isEmployeesOnlyRole(role)) {
        return const EmployeesScreen();
      }

      // Resto: welcome screen
      return const MainPosScreen();
    }

    // Sin sesión → Splash hace chequeos y deriva a Login
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