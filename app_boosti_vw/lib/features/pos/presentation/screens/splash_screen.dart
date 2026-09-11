import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:app_boosti_v2/main.dart'; // Para usar el appInitializationProvider
import '../../data/Local/entities/isar_service.dart';
import 'login_screen.dart';
// import '../../data/Local/entities/isar_service.dart'; // Ya no es necesario importarlo directamente aquí

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _inicializarApp();
  }

  Future<void> _inicializarApp() async {
    // ✅ ESPERAR LA INICIALIZACIÓN GLOBAL DEL PROVIDER (Sembast + Supabase)
    // Esto no bloquea el primer frame del logo, solo espera en segundo plano.
    try {
      await ref.read(appInitializationProvider.future);
    } catch (e) {
      debugPrint('❌ Error en la inicialización global: $e');
      // Si falla, dejamos de cargar y mostramos el mensaje (opcional)
    }

    // ✅ Ejecutar la lógica interna (diagnóstico y navegación)
    await _diagnosticarLogin();
    await _verificarConfiguracion();
  }

  // ============================================================
  // DIAGNÓSTICO (Optimizado para no saturar el log)
  // ============================================================
  Future<void> _diagnosticarLogin() async {
    try {
      final isar = IsarService();
      final todos = await isar.obtenerUsuarios();

      debugPrint('🔍 DIAGNÓSTICO DE USUARIOS:');
      for (final u in todos) {
        debugPrint('  - Nombre: "${u.nombre}" | PIN: "${u.pin}" | Activo: ${u.activo} | ID: ${u.id}');
      }

      final admin = await isar.validarLogin('Administrador', '1234');
      debugPrint('🔍 Validación Administrador: ${admin != null ? "✅ OK" : "❌ FALLÓ"}');

      final yan = await isar.validarLogin('yan camacaro', '1010');
      debugPrint('🔍 Validación yan camacaro: ${yan != null ? "✅ OK" : "❌ FALLÓ"}');
    } catch (e) {
      debugPrint('⚠️ Error en diagnóstico: $e');
    }
  }

  // ============================================================
  // VERIFICACIÓN (Sin el delay de 500ms)
  // ============================================================
  Future<void> _verificarConfiguracion() async {
    if (mounted) {
      setState(() => _isLoading = false);
      
      // ✅ Navegación directa y rápida
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
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
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                'assets/logo.svg',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
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