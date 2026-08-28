import 'package:app_boosti_v2/features/pos/presentation/providers/themes/theme.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/themes/theme_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:device_preview/device_preview.dart';
import 'features/pos/presentation/screens/splash_screen.dart';
import 'features/pos/presentation/screens/configuracion_empresa_screen.dart';
import 'features/pos/presentation/screens/login_screen.dart';
import 'features/pos/presentation/screens/inventory_catalog_screen.dart';
import 'features/pos/data/Local/entities/isar_service.dart';
import 'features/pos/presentation/providers/lock_provider.dart';
import 'features/pos/presentation/widgets/idle_detector_widget.dart';
import 'features/pos/presentation/screens/rest_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:app_boosti_v2/features/pos/presentation/services/telegram/telegram_service.dart';

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
      debugPrint('✅ Supabase inicializado para la empresa');
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

  // 2.2. Migración de stock a lotes (solo una vez)
  await isarService.migrarStockExistenteALotes();

  // 2.3. Inicializar Telegram (con manejo de errores)
  try {
    final telegramService = TelegramService();
    await telegramService.inicializar();
    debugPrint('✅ Servicio de Telegram inicializado');
  } catch (e) {
    debugPrint('⚠️ Error al inicializar Telegram: $e');
  }

  // 2.4. ASIGNAR SUPABASE ID A PRODUCTOS (con manejo de errores)
  try {
    final actualizados = await isarService.asignarSupabaseIdsAFaltantes();
    debugPrint('✅ Migración de supabaseId: $actualizados productos actualizados.');
    if (actualizados == 0) {
      debugPrint('⚠️ Ningún producto actualizado. Verifica la columna "id_isar" en Supabase.');
    }
  } catch (e) {
    debugPrint('❌ Error en migración de supabaseId: $e');
    debugPrint('⚠️ Los lotes no se sincronizarán hasta que los productos tengan supabaseId.');
  }

  // ============================================================
  // 3. CARGAR CONFIGURACIÓN ADICIONAL
  // ============================================================
  try {
    final configJson = await rootBundle.loadString('assets/config.json');
    jsonDecode(configJson);
    // Configuración adicional si es necesaria
  } catch (e) {
    debugPrint('⚠️ Error cargando config.json: $e');
  }

  // ============================================================
  // 4. EJECUTAR APP
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

    return MaterialApp(
      title: 'BoostI POS - JAH Lab',
      debugShowCheckedModeBanner: false, // ✅ CORREGIDO
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
        return IdleDetector(
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