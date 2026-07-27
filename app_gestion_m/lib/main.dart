import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/pos/presentation/screens/login_screen.dart'; // Asegúrate de que la ruta sea correcta
import 'features/pos/data/Local/entities/isar_service.dart'; // Asegúrate de que la ruta sea correcta
import 'package:supabase_flutter/supabase_flutter.dart'; // Importa Supabase

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializaciones de Isar si las tienes aquí...
  
final isarService = IsarService();
await isarService.inicializarUsuarioAdminPorDefecto();

// Inicializar Supabase con las credenciales de tu proyecto
  await Supabase.initialize(
    url: 'https://moeedweiombdnssjrgai.supabase.co/rest/v1/', // URL Supabase
    publishableKey: 'sb_publishable_3u_VXY6GnKj6i0z1eerteA_9dVsym2K', // Clave pública de Supabase
  );
//
  runApp(
    const ProviderScope(
      child: AppGestionM(),
    ),
  );
}


class AppGestionM extends StatelessWidget {
  const AppGestionM({super.key});

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'app Desktop — POS Caja 00',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF10B981)),
        useMaterial3: true,
      ),
      // La app arranca obligatoriamente en la pantalla de inicio de sesión
      home: const LoginScreen(),
      
    );
  }
}