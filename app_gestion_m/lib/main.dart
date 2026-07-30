import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_preview/device_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/pos/presentation/screens/login_screen.dart';
import 'features/pos/data/Local/entities/isar_service.dart';
import 'features/pos/presentation/providers/lock_provider.dart';
import 'features/pos/presentation/widgets/idle_detector_widget.dart';
import 'features/pos/presentation/screens/rest_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase con las credenciales de tu proyecto
  await Supabase.initialize(
    url: 'https://moeedweiombdnssjrgai.supabase.co',
    publishableKey: 'sb_publishable_3u_VXY6GnKj6i0z1eerteA_9dVsym2K',
  );

  final isarService = IsarService();
  await isarService.inicializarUsuarioAdminPorDefecto();

  // Ejecutar la app con Device Preview (solo en modo desarrollo)
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Solo se activa en modo debug
      tools: const [
        ...DevicePreview.defaultTools,
      ],
      builder: (context) => const ProviderScope(
        child: AppGestionM(),
      ),
    ),
  );
}

class AppGestionM extends ConsumerWidget {
  const AppGestionM({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocked = ref.watch(lockProvider);

    return MaterialApp(
      title: 'SmartMarket - JAH Lab',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
        useMaterial3: true,
      ),
      // La app arranca obligatoriamente en la pantalla de inicio de sesión
      home: const LoginScreen(),
      builder: (context, child) {
        // Envolver con DevicePreview para que funcione correctamente
        return DevicePreview.appBuilder(
          context,
          IdleDetector(
            child: Stack(
              children: [
                child!,

                // Si isLocked es true, la pantalla de descanso se sobrepone como un telón
                if (isLocked) const Positioned.fill(child: RestScreen()),
              ],
            ),
          ),
        );
      },
    );
  }
}