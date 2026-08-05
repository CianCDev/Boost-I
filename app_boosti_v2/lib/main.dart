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
// ignore: unused_import
import 'features/pos/presentation/services/telegram/telegram_service.dart';
import 'features/pos/presentation/services/telegram/telegram_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargar configuración de empresa
  final prefs = await SharedPreferences.getInstance();
  String? url = prefs.getString('supabase_url');
  final anonKey = prefs.getString('supabase_anon_key');

  // ✅ Limpiar URL si contiene "/rest/v1"
  if (url != null && url.isNotEmpty) {
    // Eliminar trailing slash
    if (url.endsWith('/')) url = url.substring(0, url.length - 1);
    // Eliminar cualquier ruta después del dominio
    final uri = Uri.tryParse(url);
    if (uri != null) {
      url = '${uri.scheme}://${uri.host}';
    }
  }

  // 2. Inicializar Supabase si hay configuración
  if (url != null && anonKey != null && url.isNotEmpty && anonKey.isNotEmpty) {
    try {
      await Supabase.initialize(
        url: url,
        publishableKey: anonKey,
      );
      debugPrint('✅ Supabase inicializado para la empresa');
    } catch (e) {
      debugPrint('⚠️ Error inicializando Supabase (quizás ya estaba inicializado): $e');
    }
  } else {
    debugPrint('⚠️ No hay configuración de Supabase, esperando configuración');
  }

  // 3. Inicializar Isar (independiente de Supabase)
  final isarService = IsarService();
  await isarService.inicializarUsuarioAdminPorDefecto();


  try {
    final configJson = await rootBundle.loadString('assets/config.json');
    final configMap = jsonDecode(configJson) as Map<String, dynamic>;
    final config = TelegramConfig.fromJson(configMap);
    if (config.isValid) {
    }
  } catch (e) {
    debugPrint('⚠️ Bot de Telegram desactivado: $e');
  }

  // 4. Ejecutar la aplicación
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const ProviderScope(
        child: BoostiPOS(),
      ),
    ),
  );
}

class BoostiPOS extends ConsumerWidget {
  const BoostiPOS({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = ref.watch(lockProvider);

    return MaterialApp(
      title: 'BoostI POS - JAH Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
        useMaterial3: true,
      ),
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