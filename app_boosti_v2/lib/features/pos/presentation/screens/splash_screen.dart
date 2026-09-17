// lib/features/pos/presentation/screens/splash_screen.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/config/supabase_config.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../domain/permissions/roles.dart';
import '../providers/tenant_provider.dart';
import '../providers/usuario_provider.dart';
import 'configuracion_empresa_screen.dart';
import 'empleados/employees_screen.dart';
import 'login_screen.dart';
import 'main_pos_screen.dart';
import 'welcome_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  String _mensajeCarga = 'Cargando...';

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

    // 3. Pausa breve para branding
    if (mounted) {
      setState(() => _mensajeCarga = 'Iniciando...');
    }
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    await _decidirNavegacion();
  }

  bool get _esMobile => Platform.isAndroid || Platform.isIOS;

  // ════════════════════════════════════════════════════════════════
  // PERMISOS
  // ════════════════════════════════════════════════════════════════

  Future<void> _pedirPermisos() async {
    try {
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
      debugPrint('🔍 Admin válido: ${adminValido ? "✅" : "❌"}');
    } catch (e) {
      debugPrint('❌ Error en diagnóstico: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // NAVEGACIÓN
  // ════════════════════════════════════════════════════════════════

  /// Prioridad:
  ///   1. Sin config Supabase → ConfiguracionEmpresaScreen (defensivo)
  ///   2. Con sesión RRHH → EmployeesScreen
  ///   3. Con sesión otros → MainPosScreen
  ///   4. Sin tenant configurado → WelcomeScreen (forzar setup)
  ///   5. Sin sesión + hay usuarios → LoginScreen
  ///   6. Sin sesión + sin usuarios → WelcomeScreen (primer uso)
  Future<void> _decidirNavegacion() async {
    // ── 1. Verificación defensiva de config ──
    if (!SupabaseConfig.estaConfigurado) {
      debugPrint('⚠️ SupabaseConfig no configurado → ConfiguracionEmpresa');
      if (!mounted) return;
      setState(() => _mensajeCarga = 'Configuración requerida');
      await Future.delayed(const Duration(milliseconds: 600));
      _goTo(const ConfiguracionEmpresaScreen());
      return;
    }

    // ── 2. ¿Hay sesión activa? ──
    final usuario = ref.read(usuarioActualProvider);
    if (usuario != null) {
      final role = UserRole.fromString(usuario.rol);

      if (Permissions.isEmployeesOnlyRole(role)) {
        debugPrint('➡️ Sesión RRHH → EmployeesScreen');
        _goTo(const EmployeesScreen());
        return;
      }

      debugPrint('➡️ Sesión activa → MainPosScreen');
      _goTo(const MainPosScreen());
      return;
    }

    // ── 3. ¿El dispositivo ya está configurado con tenant? ──
    // ✅ CRÍTICO: sin tenant, la app no puede sincronizar con Supabase.
    final tenantState = ref.read(tenantActualProvider);
    final tieneTenant = tenantState.tieneTenant;

    debugPrint('🔍 Tenant configurado: $tieneTenant (${tenantState.tenantId})');

    if (!tieneTenant) {
      debugPrint('➡️ Sin tenant configurado → WelcomeScreen (forzar setup)');
      _goTo(const WelcomeScreen());
      return;
    }

    // ── 4. Con tenant: verificar usuarios locales ──
    try {
      final isar = IsarService();
      final usuarios = await isar.obtenerUsuariosActivos();
      if (!mounted) return;

      if (usuarios.isEmpty) {
        debugPrint('➡️ Sin usuarios → WelcomeScreen');
        _goTo(const WelcomeScreen());
      } else {
        debugPrint('➡️ Con usuarios + tenant → LoginScreen');
        _goTo(const LoginScreen());
      }
    } catch (e) {
      debugPrint('❌ Error verificando usuarios: $e');
      // Fallback seguro: al Login (que maneja bien el caso vacío)
      _goTo(const LoginScreen());
    }
  }

  void _goTo(Widget screen) {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
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
                _mensajeCarga,
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