import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'configuracion_empresa_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Esperar a que el widget esté montado antes de pedir permisos y cargar configuración
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inicializarApp();
    });
  }

  Future<void> _inicializarApp() async {
    // 1. Pedir permisos (opcional, pero se hace después del primer frame)
    await _pedirPermisos();

    // 2. Verificar configuración
    await _verificarConfiguracion();
  }

  Future<void> _pedirPermisos() async {
    try {
      // Permisos que necesita la app (ajústalos según tus necesidades)
      final permisos = [
        Permission.camera,
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.storage,
      ];

      // Solo pedir permisos en Android 6.0+ (API 23+)
      final statuses = await permisos.request();
      
      // Verificar si algún permiso fue denegado permanentemente
      final deniedPermanently = statuses.entries
          .where((entry) => entry.value.isPermanentlyDenied)
          .map((entry) => entry.key)
          .toList();

      if (deniedPermanently.isNotEmpty) {
        // Opcional: mostrar un diálogo para que el usuario vaya a ajustes
        // Pero no bloqueamos la app
        print('⚠️ Permisos denegados permanentemente: $deniedPermanently');
      }
    } catch (e) {
      // Si falla la solicitud de permisos, continuar de todas formas
      print('⚠️ Error al pedir permisos: $e');
    }
  }

  Future<void> _verificarConfiguracion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString('supabase_url');
      final anonKey = prefs.getString('supabase_anon_key');

      // Esperar un momento para mostrar el splash (opcional)
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (url != null && anonKey != null && url.isNotEmpty && anonKey.isNotEmpty) {
          // Configuración existe, ir al login
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          // No hay configuración, ir a la pantalla de configuración
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ConfiguracionEmpresaScreen()),
          );
        }
      }
    } catch (e) {
      // Si hay error, ir a configuración por seguridad
      debugPrint('❌ Error en _verificarConfiguracion: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ConfiguracionEmpresaScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.storefront,
                size: 100,
                color: Color(0xFF10B981),
              ),
              const SizedBox(height: 20),
              const Text(
                'BoostI POS',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Punto de Venta Inteligente',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(height: 40),
              if (_isLoading) ...[
                const CircularProgressIndicator(
                  color: Color(0xFF10B981),
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Cargando configuración...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 24),
                Text(
                  'Iniciando...',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}