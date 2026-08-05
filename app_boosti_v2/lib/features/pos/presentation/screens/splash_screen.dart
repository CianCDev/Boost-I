import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'configuracion_empresa_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarConfiguracion();
  }

  Future<void> _verificarConfiguracion() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('supabase_url');
    final anonKey = prefs.getString('supabase_anon_key');

    // Esperar un momento para mostrar el splash
    await Future.delayed(const Duration(milliseconds: 800));

    if (url != null && anonKey != null && url.isNotEmpty && anonKey.isNotEmpty) {
      // Configuración existe, ir al login
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } else {
      // No hay configuración, ir a la pantalla de configuración
      if (mounted) {
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
            ],
          ),
        ),
      ),
    );
  }
}