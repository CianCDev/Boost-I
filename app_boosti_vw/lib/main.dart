import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// 👇 Importar dart:html para postMessage
import 'dart:html' as html;

// Imports locales (usamos Sembast)
import 'features/pos/data/Local/entities/isar_service.dart';

import 'features/pos/presentation/screens/splash_screen.dart';
import 'features/pos/presentation/screens/login_screen.dart';
import 'features/pos/presentation/screens/inventory_catalog_screen.dart';
import 'features/pos/presentation/providers/lock_provider.dart';
import 'features/pos/presentation/screens/rest_screen.dart';
import 'features/pos/presentation/widgets/idle_detector_widget.dart';
import 'features/pos/presentation/providers/themes/theme.dart';
import 'features/pos/presentation/providers/themes/theme_provider.dart';

// Provider para inicialización en segundo plano
final appInitializationProvider = FutureProvider<IsarService>((ref) async {
  try {
    await Supabase.initialize(
      url: 'https://placeholder.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBsYWNlaG9sZGVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE2MDAwMDAwMDAsImV4cCI6MTkzMDAwMDAwMH0.placeholder',
    );
  } catch (e) {
    debugPrint('⚠️ Supabase dummy falló: $e');
  }

  final isarService = IsarService();
  await isarService.init();
  return isarService;
});

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: BoostiPOS(),
    ),
  );
}

class BoostiPOS extends ConsumerStatefulWidget {
  const BoostiPOS({super.key});

  @override
  ConsumerState<BoostiPOS> createState() => _BoostiPOSState();
}

class _BoostiPOSState extends ConsumerState<BoostiPOS> {
  int _resetKey = 0;

  @override
  void initState() {
    super.initState();
    // Escuchar mensajes desde el iframe (Next.js)
    html.window.addEventListener('message', (event) {
      final data = event.path as Map?;
      if (data != null && data['type'] == 'RESET_DEMO') {
        _handleReset();
      }
    });
  }

  Future<void> _handleReset() async {
    final isar = IsarService();
    await isar.resetAllData();
    // Forzar rebuild completo del MaterialApp
    setState(() {
      _resetKey++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = ref.watch(lockProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      key: ValueKey(_resetKey), // ✅ Cambia al resetear, reinicia todo
      title: 'BoostI POS - JAH Lab',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: themeMode,
      home: const SplashScreen(),
      routes: {
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