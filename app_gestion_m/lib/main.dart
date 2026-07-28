import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/pos/presentation/screens/login_screen.dart'; // Asegúrate de que la ruta sea correcta
import 'features/pos/data/Local/entities/isar_service.dart'; // Asegúrate de que la ruta sea correcta
import 'package:supabase_flutter/supabase_flutter.dart'; // Importa Supabase
import 'features/pos/presentation/providers/lock_provider.dart';
import 'features/pos/presentation/widgets/idle_detector_widget.dart';
import 'features/pos/presentation/screens/rest_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializaciones de Isar si las tienes aquí...

  final isarService = IsarService();
  await isarService.inicializarUsuarioAdminPorDefecto();

  // Inicializar Supabase con las credenciales de tu proyecto
   await Supabase.initialize(
    url: 'https://moeedweiombdnssjrgai.supabase.co',
    publishableKey: 'sb_publishable_3u_VXY6GnKj6i0z1eerteA_9dVsym2K',
);
  //
  runApp(const ProviderScope(child: AppGestionM()));
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
        return IdleDetector(
          child: Stack(
            children: [
              if (child != null) child,

              // Si isLocked es true, la pantalla de descanso se sobrepone como un telón
              if (isLocked) const Positioned.fill(child: RestScreen()),
            ],
          ),
        );
      },
    );
  }
}
