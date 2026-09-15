import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_svg/flutter_svg.dart';

import 'package:permission_handler/permission_handler.dart';

import '../../../../core/config/supabase_config.dart';
import '../../data/Local/entities/isar_service.dart';
import 'configuracion_empresa_screen.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;
  String _mensajeCarga = 'Cargando...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inicializarApp();
    });
  }

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================
  Future<void> _inicializarApp() async {
    await _pedirPermisos();

    if (kDebugMode) {
      await _diagnosticarUsuarios();
    }

    await _decidirNavegacion();
  }

  // ============================================================
  // DIAGNÓSTICO DE USUARIOS (solo debug)
  // ============================================================
  Future<void> _diagnosticarUsuarios() async {
    try {
      final isar = IsarService();
      final usuarios = await isar.obtenerUsuarios();

      debugPrint('🔍 Usuarios en Isar: ${usuarios.length}');
      for (final u in usuarios) {
        debugPrint(
          '  - ${u.nombre} (ID: ${u.id}, rol: ${u.rol}, activo: ${u.activo}, '
          'estado: ${u.estado}, email: ${u.email ?? "sin email"})',
        );
      }
    } catch (e) {
      debugPrint('❌ Error en _diagnosticarUsuarios: $e');
    }
  }

  // ============================================================
  // DECISIÓN DE NAVEGACIÓN
  // ============================================================
  Future<void> _decidirNavegacion() async {
    try {
      // 1. Verificar que SupabaseConfig esté configurado
      if (!SupabaseConfig.estaConfigurado) {
        debugPrint('⚠️ SupabaseConfig no está configurado');
        if (mounted) {
          setState(() {
            _isLoading = false;
            _mensajeCarga = 'Error de configuración';
          });
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const ConfiguracionEmpresaScreen(),
              ),
            );
          }
        }
        return;
      }

      // 2. Verificar si hay usuarios locales en Isar
      final isar = IsarService();
      final usuarios = await isar.obtenerUsuariosActivos();
      final hayUsuarios = usuarios.isNotEmpty;

      debugPrint('🔍 ¿Hay usuarios en Isar? $hayUsuarios');

      // 3. Pequeño delay para que se vea el splash
      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _mensajeCarga = 'Iniciando...';
      });

      // 4. Navegar según corresponda
      if (hayUsuarios) {
        // Uso diario: usuario ya configuró esta tablet
        debugPrint('➡️ Navegando a LoginScreen (usuarios existentes)');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        // Primer uso: dispositivo nuevo sin usuarios
        debugPrint('➡️ Navegando a WelcomeScreen (primer uso)');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
        );
      }
    } catch (e, stack) {
      debugPrint('❌ Error en _decidirNavegacion: $e');
      debugPrint('Stack: $stack');

      if (mounted) {
        setState(() {
          _isLoading = false;
          _mensajeCarga = 'Error al iniciar';
        });

        // Fallback: ir a WelcomeScreen para que el usuario pueda empezar
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          );
        }
      }
    }
  }

  // ============================================================
  // PERMISOS
  // ============================================================
  Future<void> _pedirPermisos() async {
    try {
      final permisos = [
        Permission.camera,
        Permission.bluetooth,
        Permission.bluetoothConnect,
        Permission.bluetoothScan,
        Permission.storage,
      ];
      await permisos.request();
    } catch (e) {
      debugPrint('⚠️ Error al pedir permisos: $e');
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
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
                'assets/logoboosti300px.svg',
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
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
                  _mensajeCarga,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 24),
                Text(
                  _mensajeCarga,
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