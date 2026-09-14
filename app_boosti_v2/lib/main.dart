import 'package:app_boosti_v2/features/pos/presentation/providers/themes/theme.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/themes/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/supabase_config.dart';

import 'features/pos/data/Local/entities/isar_service.dart';
import 'features/pos/presentation/screens/splash_screen.dart';
import 'features/pos/presentation/screens/configuracion_empresa_screen.dart';
import 'features/pos/presentation/screens/login_screen.dart';
import 'features/pos/presentation/screens/inventory_catalog_screen.dart';
import 'features/pos/presentation/providers/lock_provider.dart';
import 'features/pos/presentation/screens/rest_screen.dart';
import 'features/pos/presentation/widgets/idle_detector_widget.dart';
import 'features/pos/presentation/providers/sync_provider.dart';


// ✅ NUEVAS IMPORTACIONES PARA MONITOREO Y BACKUP
import 'features/pos/presentation/services/error_service.dart';
import 'features/pos/presentation/services/backup_service.dart';
import 'features/pos/presentation/services/ota_update_service.dart';

void main() async {
  // ✅ Solo imprime en debug (no ensucia logs de producción)
  if (kDebugMode) {
    debugPrint('🚀 OTA TEST - VERSION 2 - ${DateTime.now()}');
  }

  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // ✅ 0. INICIALIZAR MONITOREO Y BACKUP
  // ============================================================
  await ErrorService.init(); // Inicializa Sentry + Crashlytics
  BackupService.register(); // Programa el backup cada 12h

  // ============================================================
  // 1. INICIALIZAR SUPABASE (de forma síncrona con await)
  // ============================================================
  final prefs = await SharedPreferences.getInstance();
  String? url;
  String? anonKey;
  bool supabaseInitialized = false;

  // 1a. Producción: credenciales embebidas en SupabaseConfig
  if (SupabaseConfig.estaConfigurado) {
    url = SupabaseConfig.url;
    anonKey = SupabaseConfig.publishableKey;
    debugPrint('✅ Usando credenciales embebidas de SupabaseConfig');
  }
  // 1b. Debug: fallback a SharedPreferences (útil para cambiar de proyecto sin recompilar)
  else if (kDebugMode) {
    url = prefs.getString('supabase_url');
    anonKey = prefs.getString('supabase_anon_key');
    debugPrint('⚠️ Debug: usando credenciales de SharedPreferences');
  }

  if (url != null && url.isNotEmpty && anonKey != null && anonKey.isNotEmpty) {
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    final uri = Uri.tryParse(url);
    if (uri != null) {
      url = '${uri.scheme}://${uri.host}';
    }

    try {
      await Supabase.initialize(url: url, publishableKey: anonKey);
      supabaseInitialized = true;
      debugPrint('✅ Supabase inicializado correctamente');
    } catch (e) {
      debugPrint('⚠️ Error inicializando Supabase: $e');
      supabaseInitialized = false;
    }
  } else {
    debugPrint('⚠️ No hay configuración de Supabase disponible');
  }

  // ============================================================
  // 2. INICIALIZAR ISAR Y MIGRACIONES
  // ============================================================
  final isarService = IsarService();

  await isarService.inicializarUsuarioAdminPorDefecto();
  await isarService.migrarStockExistenteALotes();

  try {
    final actualizados = await isarService.asignarSupabaseIdsAFaltantes();
    debugPrint(
        '✅ Migración de supabaseId: $actualizados productos actualizados.');
  } catch (e) {
    debugPrint('❌ Error en migración de supabaseId: $e');
  }

  // ============================================================
  // 3. ARRANCAR COMPROBACIÓN SILENCIOSA DE OTA
  // ============================================================
  try {
    OtaUpdateService.checkForUpdateSilently();
  } catch (_) {
    // Nunca bloquear el arranque.
  }

  // ============================================================
  // 4. EJECUTAR APP
  // ============================================================
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => ProviderScope(
        child: BoostiPOS(
          supabaseInitialized: supabaseInitialized,
        ),
      ),
    ),
  );
}

class BoostiPOS extends ConsumerStatefulWidget {
  final bool supabaseInitialized;

  const BoostiPOS({super.key, required this.supabaseInitialized});

  @override
  ConsumerState<BoostiPOS> createState() => _BoostiPOSState();
}

class _BoostiPOSState extends ConsumerState<BoostiPOS> {
  @override
  void initState() {
    super.initState();
    if (widget.supabaseInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final syncService = ref.read(syncServiceProvider);
        syncService.iniciarSuscripcionesRealtime();
        syncService.iniciarMonitoreo();
      });
    }
  }


  /// Determina la pantalla inicial según el estado de Supabase.
  ///
  /// - Producción con Supabase OK → SplashScreen.
  /// - Debug sin Supabase → ConfiguracionEmpresaScreen (para configurar a mano).
  /// - Producción sin Supabase → error crítico.
  Widget _buildHomeScreen() {
    if (widget.supabaseInitialized) {
      return const SplashScreen();
    }

    // Debug: permitir configurar credenciales a mano
    if (kDebugMode) {
      return const ConfiguracionEmpresaScreen();
    }

    // Producción sin credenciales → error crítico (no debería pasar)
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Error de configuración.\nContacte al soporte técnico.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
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
      home: _buildHomeScreen(),
      routes: {
        '/configuracion': (context) => const ConfiguracionEmpresaScreen(),
        '/login': (context) => const LoginScreen(),
        '/catalogo': (context) => const InventoryCatalogScreen(),
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