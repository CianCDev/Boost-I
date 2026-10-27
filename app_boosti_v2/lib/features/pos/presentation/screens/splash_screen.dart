// lib/features/pos/presentation/screens/splash_screen.dart
import 'dart:io' show Platform;

import 'package:app_boosti_v2/features/pos/data/Local/entities/plan_entity.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:isar/isar.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/config/supabase_config.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../providers/business_mode_provider.dart';
import '../providers/tenant_provider.dart';
import '../providers/usuario_provider.dart';
import '../utils/home_por_rol.dart';
import 'login_screen.dart';
import 'welcome_screen.dart';
import '../providers/suscripcion_provider.dart';
import 'seleccionar_modo_negocio_screen.dart';
import 'setup_pin_screen.dart';

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
    // 1. Permisos
    if (_esMobile) {
      await _pedirPermisos();
    }

    // 2. ✅ LIMPIEZA de usuarios duplicados
    await _limpiezaOneShot();

    // 3. 🔧 TEMPORAL: reparación one-shot de productos mayoristas
    // ⚠️ ELIMINAR después de verificar que funciona


    // 4. Diagnóstico (ya con datos limpios)
    if (kDebugMode) {
      await _diagnosticarUsuarios();
    }

    // 5. Pausa breve para branding
    if (mounted) {
      setState(() => _mensajeCarga = 'Iniciando...');
    }
    await Future.delayed(const Duration(milliseconds: 400));

    // 6. Decidir navegación
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
  // LIMPIEZA ONE-SHOT de usuarios duplicados
  // ════════════════════════════════════════════════════════════════

  Future<void> _limpiezaOneShot() async {
    const flagKey = 'cleanup_duplicates_v2';
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(flagKey) == true) return;

    try {
      final isar = IsarService();
      final db = await isar.db;

      // ── 1. Eliminar "yan camacaro" si aún existe ──
      final todos = await db.usuarioEntitys.where().findAll();
      final aEliminar = todos
          .where((u) => u.nombre.trim().toLowerCase() == 'yan camacaro')
          .toList();

      for (final u in aEliminar) {
        await db.writeTxn(() async {
          await db.usuarioEntitys.delete(u.id);
        });
        debugPrint('🧹 Eliminado duplicado: "${u.nombre}" (ID: ${u.id})');
      }

      // ── 2. Refetch DESPUÉS de borrar ──
      final restantes = await db.usuarioEntitys.where().findAll();

      // ── 3. Limpiar UUIDs duplicados SOLO entre vivos ──
      final porUuid = <String, List<UsuarioEntity>>{};
      for (final u in restantes) {
        final id = u.supabaseId;
        if (id == null || id.isEmpty) continue;
        porUuid.putIfAbsent(id, () => []).add(u);
      }

      for (final entry in porUuid.entries) {
        final lista = entry.value;
        if (lista.length <= 1) continue;
        lista.sort((a, b) => a.id.compareTo(b.id));
        final conservar = lista.first;
        for (final u in lista.skip(1)) {
          await db.writeTxn(() async {
            u.supabaseId = null;
            u.sincronizado = false;
            await db.usuarioEntitys.put(u);
          });
          debugPrint('🧹 UUID duplicado limpiado en "${u.nombre}" '
              '(conservado en "${conservar.nombre}")');
        }
      }

      // ── 4. Restaurar el UUID de ian si quedó en null ──
      final ian = restantes.firstWhere(
        (u) => u.nombre.trim().toLowerCase() == 'ian',
        orElse: () => UsuarioEntity(),
      );

      if (ian.id != 0 &&
          (ian.supabaseId == null || ian.supabaseId!.isEmpty)) {
        const ianUuid = '51123f01-0acf-49fb-9762-ff60a99ec685';
        await db.writeTxn(() async {
          ian.supabaseId = ianUuid;
          ian.sincronizado = false;
          await db.usuarioEntitys.put(ian);
        });
        debugPrint('✅ UUID de "ian" restaurado: $ianUuid');
      }

      await prefs.setBool(flagKey, true);
      debugPrint('✅ Limpieza one-shot v2 completada');
    } catch (e) {
      debugPrint('⚠️ Error en limpieza v2: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // 🔧 REPARACIÓN ONE-SHOT de productos (temporal)
  // ════════════════════════════════════════════════════════════════

  /// Fuerza reset de productos locales y re-descarga desde Supabase.
  /// Corre UNA SOLA VEZ por dispositivo (flag en SharedPreferences).
  ///
  /// ⚠️ ELIMINAR ESTE MÉTODO Y SU LLAMADA CUANDO SE CONFIRME.
 /* Future<void> _repararProductosMayoristas() async {
    const flagKey = 'repair_productos_mayoristas_v1';
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(flagKey) == true) {
      debugPrint('ℹ️ [REPARACIÓN] Ya se ejecutó antes. Saltando.');
      return;
    }

    debugPrint('🔧 [REPARACIÓN] Iniciando reparación de productos...');

    try {
      // Esperar a que haya sesión Supabase activa
      final supabase = Supabase.instance.client;
      if (supabase.auth.currentSession == null) {
        debugPrint('⚠️ [REPARACIÓN] Sin sesión Supabase. Omitiendo.');
        return;
      }

      // Ejecutar reparación
      await SyncService().resetProductosDesdeSupabase();

      // Marcar como hecho
      await prefs.setBool(flagKey, true);
      debugPrint('✅ [REPARACIÓN] Flag guardado. No volverá a correr.');
    } catch (e, stack) {
      debugPrint('⚠️ [REPARACIÓN] Error: $e');
      debugPrint('⚠️ [REPARACIÓN] Stack: $stack');
      // No marcamos el flag → reintentará en el próximo arranque
    }
  }*/

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
        (u) => u.rol == 'admin' && u.activo && u.pin.isNotEmpty,
      );
      debugPrint('🔍 Admin válido: ${adminValido ? "✅" : "❌"}');
    } catch (e) {
      debugPrint('❌ Error en diagnóstico: $e');
    }
  }

  // ════════════════════════════════════════════════════════════════
  // NAVEGACIÓN
  // ════════════════════════════════════════════════════════════════

 Future<void> _decidirNavegacion() async {
  // ── 1. Verificación defensiva de config ──
  if (!SupabaseConfig.estaConfigurado) {
    debugPrint('⚠️ SupabaseConfig no configurado → ConfiguracionEmpresa');
    if (!mounted) return;
    setState(() => _mensajeCarga = 'Configuración requerida');
    await Future.delayed(const Duration(milliseconds: 600));
    return;
  }

  // ── 2. ¿Hay sesión activa? ──
  final usuario = ref.read(usuarioActualProvider);
  if (usuario != null) {
    // 🎯 NUEVO: ¿El local activo necesita onboarding?
    //
    //    Reglas:
    //      - Sin local activo → no forzar (lo creará luego desde Welcome).
    //      - Local con `modoConfiguradoEn == null` → forzar onboarding.
    //      - Local ya configurado → continuar flujo normal.
    final necesitaOnboarding = await _necesitaOnboarding();

    if (necesitaOnboarding) {
      debugPrint('➡️ Local sin modo configurado → Onboarding');
      // Pre-cargar planes + suscripción para que el onboarding no
      // muestre loading largo al entrar.
      await _precargarDatosOnboarding();
      if (!mounted) return;
      _goTo(const SeleccionarModoNegocioScreen());
      return;
    }

    // El modo de negocio se carga de Isar en async, y este método puede
    // correr antes de que termine (arranque en frío). Sin esta recarga,
    // `flags.requiereMesa` sería `false` y el cajero aterrizaría en el
    // menú del POS en vez de en la caja.
    await ref.read(businessModeProvider.notifier).recargar();
    if (!mounted) return;

    // ── PIN obligatorio ──
    //
    // Va DESPUÉS del onboarding de modo de negocio y antes del check de
    // rol, para que el empleado de RRHH también quede con PIN: el lock
    // por inactividad (`UserActivityDetector`) lo cubre igual y sin PIN
    // se queda trabado en `RestScreen` sin salida.
    if (usuario.pin.isEmpty) {
      debugPrint('➡️ Usuario sin PIN configurado → SetupPinScreen');
      final destino = destinoInicialPorRol(
        usuario: usuario,
        flags: ref.read(featureFlagsProvider),
      );
      if (!mounted) return;
      _goTo(SetupPinScreen(destino: destino));
      return;
    }

    final destino = destinoInicialPorRol(
      usuario: usuario,
      flags: ref.read(featureFlagsProvider),
    );
    debugPrint('➡️ Sesión activa → ${destino.runtimeType}');
    _goTo(destino);
    return;
  }

  // ── 3. ¿El dispositivo ya está configurado con tenant? ──
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
    _goTo(const LoginScreen());
  }
}

// ════════════════════════════════════════════════════════════════
// ONBOARDING — CHEQUEO + PRE-CARGA
// ════════════════════════════════════════════════════════════════

/// Devuelve `true` si el local activo NO tiene modo de negocio
/// configurado (`modoConfiguradoEn == null`).
///
/// Reglas defensivas:
///   - Sin local activo → `false` (no forzamos onboarding sin contexto).
///   - Error de Isar → `false` (no bloqueamos el arranque).
Future<bool> _necesitaOnboarding() async {
  try {
    final local = await IsarService().obtenerLocalActivo();

    if (local == null) {
      debugPrint('🔍 [Onboarding] Sin local activo → no forzar');
      return false;
    }

    final necesita = local.modoConfiguradoEn == null;
    debugPrint(
      '🔍 [Onboarding] Local "${local.nombre}" '
      'modoConfiguradoEn=${local.modoConfiguradoEn} → necesita=$necesita',
    );
    return necesita;
  } catch (e) {
    debugPrint('⚠️ [Onboarding] Error chequeando: $e');
    return false;
  }
}

/// Pre-carga `planesProvider` y `suscripcionProvider` en paralelo con
/// un timeout corto. Si falla, el onboarding mostrará su propio
/// estado de loading + retry.
Future<void> _precargarDatosOnboarding() async {
  try {
    await Future.wait<void>([
      ref
          .read(planesProvider.future)
          .timeout(
            const Duration(seconds: 6),
            onTimeout: () => <PlanEntity>[],
          ),
      ref
          .read(suscripcionProvider.future)
          .timeout(
            const Duration(seconds: 6),
            onTimeout: () => null,
          ),
    ]);
    debugPrint('✅ [Onboarding] Datos pre-cargados');
  } catch (e) {
    debugPrint('⚠️ [Onboarding] Error pre-cargando: $e');
    // No bloqueamos; el onboarding tiene su propio loading/retry.
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
                'BoostiPos',
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