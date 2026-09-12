import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/Local/entities/isar_service.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _inicializarApp();
    });
  }

  Future<void> _inicializarApp() async {
    await _pedirPermisos();

    // ⚠️ DESCOMENTAR PARA EJECUTAR EL SCRIPT DE MANTENIMIENTO
    // await _ejecutarScriptsMantenimiento();

    await _diagnosticarUsuarios();
    await _verificarConfiguracion();
  }

  // ============================================================
  // DIAGNÓSTICO DE USUARIOS (solo en debug, sin PINs)
  // ============================================================
  Future<void> _diagnosticarUsuarios() async {
    // ✅ Solo corre en modo debug. En release no se ejecuta.
    if (!kDebugMode) return;

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

      // ✅ Verificación genérica: al menos un admin activo con PIN de 4 dígitos
      final adminValido = usuarios.any(
        (u) => u.rol == 'admin' && u.activo && u.pin.length == 4,
      );
      debugPrint(
        '🔍 Admin válido detectado: ${adminValido ? "✅ OK" : "❌ FALLÓ"}',
      );

      // ✅ Todos los usuarios activos deben tener PIN de 4 dígitos
      final todosConPinValido = usuarios
          .where((u) => u.activo)
          .every((u) => u.pin.length == 4);
      debugPrint(
        '🔍 Todos los activos con PIN de 4 dígitos: '
        '${todosConPinValido ? "✅ OK" : "❌ FALLÓ"}',
      );
    } catch (e) {
      debugPrint('❌ Error en _diagnosticarUsuarios: $e');
    }
  }

  // ============================================================
  // 🔧 SCRIPT DE MANTENIMIENTO (versión final)
  // ============================================================
  /*Future<void> _ejecutarScriptsMantenimiento() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final flagKey = 'scripts_mantenimiento_v6';
      if (prefs.getBool(flagKey) == true) {
        debugPrint('⚠️ Scripts de mantenimiento ya ejecutados. Omitiendo.');
        return;
      }

      debugPrint('🛠️ Ejecutando script de corrección (ID 6)...');

      final isar = IsarService();

      final usuario = await isar.obtenerUsuarioPorId(6);
      if (usuario != null) {
        usuario.supabaseId = null;
        usuario.password = '101010';
        usuario.pin = '1010';
        await isar.guardarUsuario(usuario);
        debugPrint('✅ supabaseId limpiado para "yan camacaro" (ID 6)');
      } else {
        debugPrint('⚠️ Usuario ID 6 no encontrado');
      }

      final sync = SyncService();
      await sync.sincronizarUsuariosASupabase();
      debugPrint('✅ Sincronización completada');

      final verificado = await isar.obtenerUsuarioPorId(6);
      if (verificado != null &&
          verificado.supabaseId != null &&
          verificado.supabaseId!.isNotEmpty) {
        debugPrint('✅ Usuario ID 6 sincronizado correctamente (ID: ${verificado.supabaseId})');
      } else {
        debugPrint('⚠️ Usuario ID 6 aún sin supabaseId. Revisa logs y trigger.');
      }

      await prefs.setBool(flagKey, true);
      debugPrint('✅ Script de mantenimiento ejecutado correctamente.');
    } catch (e) {
      debugPrint('❌ Error en script de mantenimiento: $e');
    }
  }*/

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

  Future<void> _verificarConfiguracion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final url = prefs.getString('supabase_url');
      final anonKey = prefs.getString('supabase_anon_key');

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() => _isLoading = false);

        if (url != null &&
            anonKey != null &&
            url.isNotEmpty &&
            anonKey.isNotEmpty) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => const ConfiguracionEmpresaScreen()),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error en _verificarConfiguracion: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const ConfiguracionEmpresaScreen()),
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