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
import 'features/pos/presentation/services/telegram/telegram_service.dart';
import 'features/pos/presentation/widgets/idle_detector_widget.dart';
import 'features/pos/presentation/providers/sync_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // 1. INICIALIZAR SUPABASE
  // ============================================================
  final prefs = await SharedPreferences.getInstance();
  String? url = prefs.getString('supabase_url');
  final anonKey = prefs.getString('supabase_anon_key');

  if (url != null && url.isNotEmpty) {
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    final uri = Uri.tryParse(url);
    if (uri != null) {
      url = '${uri.scheme}://${uri.host}';
    }
  }

  if (url != null && anonKey != null && url.isNotEmpty && anonKey.isNotEmpty) {
    try {
      await Supabase.initialize(url: url, publishableKey: anonKey);
      debugPrint('✅ Supabase inicializado');
    } catch (e) {
      debugPrint('⚠️ Error inicializando Supabase: $e');
    }
  } else {
    debugPrint('⚠️ No hay configuración de Supabase, esperando configuración');
  }



  // ============================================================
  // 2. INICIALIZAR ISAR Y MIGRACIONES
  // ============================================================
  final isarService = IsarService();

  // 2.1. Usuario admin por defecto
  await isarService.inicializarUsuarioAdminPorDefecto();

  // 2.2. Migración de stock a lotes
  await isarService.migrarStockExistenteALotes();

  // 2.3. Telegram NO se inicializa aquí porque aún no hay usuario logueado
  // Se inicializará después del login en el authProvider o en el pos_menu_screen

  // 2.4. Asignar supabaseId a productos faltantes
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
      builder: (context) => const ProviderScope(child: BoostiPOS()),
    ),
  );
}

class BoostiPOS extends ConsumerWidget {
  const BoostiPOS({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = ref.watch(lockProvider);
    final themeMode = ref.watch(themeProvider);

    // 🔥 Iniciar Realtime y monitoreo UNA SOLA VEZ
    final syncService = ref.watch(syncServiceProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      syncService.iniciarSuscripcionesRealtime();
      syncService.iniciarMonitoreo();
    });

    return MaterialApp(
      title: 'BoostI POS - JAH Lab',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: themeMode,
      home: const SplashScreen(),
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