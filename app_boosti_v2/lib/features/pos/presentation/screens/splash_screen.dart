// lib/features/pos/presentation/screens/splash_screen.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../domain/permissions/roles.dart';
import '../providers/usuario_provider.dart';
import 'empleados/employees_screen.dart';
import 'login_screen.dart';
import 'main_pos_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _inicializar());
  }

  // ════════════════════════════════════════════════════════════════
  // FLUJO DE INICIALIZACIÓN
  // ════════════════════════════════════════════════════════════════

  Future<void> _inicializar() async {
    // 1. Permisos (solo mobile — desktop no los necesita)
    if (_esMobile) {
      await _pedirPermisos();
    }

    // 2. Diagnóstico en debug
    if (kDebugMode) {
      await _diagnosticarUsuarios();
    }

    // 3. Pequeña pausa para que se vea el branding (opcional)
    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;
    _navegar();
  }

  bool get _esMobile => Platform.isAndroid || Platform.isIOS;

  Future<void> _pedirPermisos() async {
    try {
      // Solo permisos relevantes en mobile.
      final permisos = <Permission>[
        Permission.camera,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ];

      // Permission.storage solo en Android <33
      if (Platform.isAndroid) {
        permisos.add(Permission.storage);
      }

      await permisos.request();
    } catch (e) {
      debugPrint('⚠️ Error pidiendo permisos: $e');
    }
  }

  /// Decide a dónde ir. Como `main.dart` ya filtra el caso "sin config"
  /// y "con sesión", aquí solo pueden darse:
  ///   • Sin sesión → Login
  ///   • Con sesión (por si alguien navegó manual) → MainPosScreen / Employees
  void _navegar() {
    final usuario = ref.read(usuarioActualProvider);

    if (usuario == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }

    final role = UserRole.fromString(usuario.rol);

    if (Permissions.isEmployeesOnlyRole(role)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const EmployeesScreen()),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainPosScreen()),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // DIAGNÓSTICO (solo debug)
  // ════════════════════════════════════════════════════════════════

  Future<void> _diagnosticarUsuarios() async {
    try {
      final isar = IsarService();
      final usuarios = await isar.obtenerUsuarios();

      debugPrint('🔍 Usuarios en Isar: ${usuarios.length}');
      for (final u in usuarios) {
        debugPrint(
          '  - ${u.nombre} (ID: ${u.id}, rol: ${u.rol}, '
          'activo: ${u.activo}, estado: ${u.estado})',
        );
      }

      final adminValido = usuarios.any(
        (u) => u.rol == 'admin' && u.activo && u.pin.length == 4,
      );
      debugPrint(
        '🔍 Admin válido: ${adminValido ? "✅" : "❌"}',
      );
    } catch (e) {
      debugPrint('❌ Error en diagnóstico: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

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
              const CircularProgressIndicator(
                color: Color(0xFF10B981),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Cargando...',
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