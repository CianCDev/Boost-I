import 'package:app_boosti_v2/features/pos/presentation/providers/themes/theme.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/themes/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'features/pos/data/Local/entities/isar_service.dart';
import 'features/pos/presentation/screens/splash_screen.dart';
import 'features/pos/presentation/screens/configuracion_empresa_screen.dart';
import 'features/pos/presentation/screens/login_screen.dart';
import 'features/pos/presentation/screens/inventory_catalog_screen.dart';
import 'features/pos/presentation/providers/lock_provider.dart';
import 'features/pos/presentation/screens/rest_screen.dart';
import 'features/pos/presentation/widgets/idle_detector_widget.dart';
import 'features/pos/presentation/providers/sync_provider.dart';
// ✅ IMPORTACIÓN FALTANTE
import 'features/pos/presentation/services/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // 1. INICIALIZAR SUPABASE (de forma síncrona con await)
  // ============================================================
  final prefs = await SharedPreferences.getInstance();
  String? url = prefs.getString('supabase_url');
  final anonKey = prefs.getString('supabase_anon_key');
  bool supabaseInitialized = false;

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
    debugPrint('⚠️ No hay configuración de Supabase, se mostrará pantalla de configuración');
  }

  // ============================================================
  // 2. INICIALIZAR ISAR Y MIGRACIONES
  // ============================================================
  final isarService = IsarService();

  await isarService.inicializarUsuarioAdminPorDefecto();
  await isarService.migrarStockExistenteALotes();

  try {
    final actualizados = await isarService.asignarSupabaseIdsAFaltantes();
    debugPrint('✅ Migración de supabaseId: $actualizados productos actualizados.');
  } catch (e) {
    debugPrint('❌ Error en migración de supabaseId: $e');
  }

  // ============================================================
  // 3. EJECUTAR APP
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
        _ejecutarSincronizacionInicial(syncService);
      });
    }
  }

  Future<void> _ejecutarSincronizacionInicial(SyncService syncService) async {
    try {
      debugPrint('🚀 Ejecutando sincronización inicial desde main...');
      // 1. Primero sincronizar locales
      await syncService.descargarLocalesDesdeSupabase();
      // 2. Luego sincronizar usuarios
      await syncService.sincronizarUsuariosDesdeSupabase();
      // 3. Finalmente descargar pedidos
      await syncService.descargarPedidosDesdeSupabase();
      debugPrint('✅ Sincronización inicial completada desde main');
    } catch (e) {
      debugPrint('⚠️ Error en sincronización inicial desde main: $e');
    }
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
      home: widget.supabaseInitialized
          ? const SplashScreen()
          : const ConfiguracionEmpresaScreen(),
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