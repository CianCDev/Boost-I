// lib/features/pos/presentation/screens/login_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ✅ FIX: `hide AuthState` para evitar ambigüedad con el AuthState local
//    de `auth_provider.dart` (gotrue también exporta un `AuthState`).
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/permissions/roles.dart';
import '../providers/auth_provider.dart';
import '../providers/tenant_provider.dart';
import '../providers/usuario_provider.dart';
import '../services/sync_service.dart';
import '../services/error_service.dart';
import '../utils/responsive_helper.dart';
import 'email_login_screen.dart';
import 'empleados/employees_screen.dart';
import 'main_pos_screen.dart';
// ignore: unused_import
import 'inventory_catalog_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  // ══════════════════════════════════════════════════════════════
  // PALETA DE COLORES DEL LOGIN
  // ══════════════════════════════════════════════════════════════
  static const Color _bgDeep = Color(0xFF050816);
  static const Color _bgNavy = Color(0xFF0A0E27);
  static const Color _bgIndigo = Color(0xFF1A1A4E);
  static const Color _bgPurple = Color(0xFF2D1B69);
  static const Color _bgViolet = Color(0xFF4C2B8C);
  static const Color _accent = Color(0xFF10B981);
  static const Color _accentDeep = Color(0xFF059669);

  final TextEditingController _pinController = TextEditingController();
  bool _obscurePin = true;
  int? _selectedUserId;
  bool _isLoading = false;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ============================================================
  // INIT
  // ============================================================
  @override
  void initState() {
    super.initState();
    _loadSelectedUser();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Cargar usuarios desde Isar local
      await ref.read(authProvider.notifier).loadUsuarios();
      final usuariosActualizados = await ref.refresh(usuariosProvider.future);
      if (usuariosActualizados.isNotEmpty) {
        debugPrint(
            '✅ Usuarios recargados en login: ${usuariosActualizados.length}');
      }

      // 2. Validar selección guardada y sincronizar en background
      _validateSelectedUser();
      _sincronizarUsuarios(showFeedback: false, isInitialLoad: true);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARGA DE USUARIO SELECCIONADO
  // ============================================================
  Future<void> _loadSelectedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedId = prefs.getInt('selected_user_id');
      if (savedId != null && mounted) {
        setState(() => _selectedUserId = savedId);
      }
    } catch (e) {
      debugPrint('Error cargando el usuario guardado: $e');
    }
  }

  Future<void> _saveSelectedUser(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('selected_user_id', userId);
    } catch (e) {
      debugPrint('Error guardando el usuario seleccionado: $e');
    }
  }

  void _validateSelectedUser() {
    final authState = ref.read(authProvider);
    if (_selectedUserId != null) {
      final exists = authState.usuarios.any((u) => u.id == _selectedUserId);
      if (!exists && authState.usuarios.isNotEmpty) {
        setState(() => _selectedUserId = authState.usuarios.first.id);
        _saveSelectedUser(_selectedUserId!);
      }
    } else if (authState.usuarios.isNotEmpty) {
      setState(() => _selectedUserId = authState.usuarios.first.id);
      _saveSelectedUser(_selectedUserId!);
    }
  }

  // ============================================================
  // SINCRONIZACIÓN
  // ============================================================
  Future<void> _sincronizarUsuarios({
    bool showFeedback = true,
    bool isInitialLoad = false,
  }) async {
    if (!mounted) return;
    if (!isInitialLoad) setState(() => _isLoading = true);

    try {
      await SyncService().sincronizarUsuariosASupabase();
      if (showFeedback && mounted) {
        _showSnackbar('✅ Usuarios sincronizados', Colors.green);
      }
    } catch (e) {
      if (showFeedback && mounted) {
        _showSnackbar('⚠️ Error sincronizando: $e', Colors.red);
      }
    } finally {
      await ref.read(authProvider.notifier).loadUsuarios();
      _validateSelectedUser();
      if (mounted && !isInitialLoad) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      ),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================
  Future<void> _loginWithPin() async {
    final authState = ref.read(authProvider);
    if (authState.usuarios.isEmpty) {
      _showSnackbar('No hay usuarios disponibles', Colors.orange);
      return;
    }

    UsuarioEntity? usuarioSeleccionado;
    if (_selectedUserId != null) {
      try {
        usuarioSeleccionado = authState.usuarios.firstWhere(
          (u) => u.id == _selectedUserId,
        );
      } catch (_) {
        usuarioSeleccionado = null;
      }
    }
    usuarioSeleccionado ??= authState.usuarios.first;

    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa tu PIN.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await ref
        .read(authProvider.notifier)
        .loginWithPin(usuarioSeleccionado, pin);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      setState(() => _errorMessage = 'PIN incorrecto. Intenta de nuevo.');
      return;
    }

    final user = ref.read(authProvider).currentUser;
    if (user == null) return;

    // Registrar en monitoreo y guardar preferencia
    ref.read(usuarioActualProvider.notifier).setUsuario(user);
    ErrorService.setUser(user.id.toString(), user.email, user.nombre);
    await _saveSelectedUser(user.id);

    final tenantState = ref.read(tenantActualProvider);
    if (!tenantState.tieneTenant) {
      debugPrint('⚠️ Login PIN sin tenant en prefs. La sincronización fallará.');
    }

    // 🔥 Sincronización inicial en background para este dispositivo
    try {
      final syncService = SyncService();
      await syncService.descargarLocalesDesdeSupabase();
      await syncService.descargarPedidosDesdeSupabase();
      debugPrint('✅ Sincronización inicial completada después del login');
    } catch (e) {
      debugPrint('⚠️ Error en sincronización inicial: $e');
      // No bloqueamos el login si falla
    }

    if (!mounted) return;
    redirigirSegunRol(user);
  }

  /// Navega a la pantalla correspondiente según el rol del usuario.
  void redirigirSegunRol(UsuarioEntity usuario) {
    final role = UserRole.fromString(usuario.rol);

    if (Permissions.isEmployeesOnlyRole(role)) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const EmployeesScreen()),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainPosScreen()),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenSize = MediaQuery.of(context).size;

    double containerWidth;
    if (isMobile) {
      containerWidth = screenSize.width * 0.9;
    } else {
      containerWidth = 600.0;
      if (containerWidth > screenSize.width * 0.9) {
        containerWidth = screenSize.width * 0.9;
      }
    }

    final paddingSize = isMobile ? 24.0 : 42.0;
    final buttonHeight = isMobile ? 50.0 : 62.0;
    final logoSize = isMobile ? 80.0 : 120.0;

    final usuariosOrdenados = List<UsuarioEntity>.from(authState.usuarios)
      ..sort((a, b) => a.nombre.compareTo(b.nombre));

    if (_selectedUserId == null && usuariosOrdenados.isNotEmpty) {
      _selectedUserId = usuariosOrdenados.first.id;
    }

    String ejemploPins = '';
    for (var u in usuariosOrdenados) {
      if (u.rol == 'admin') {
        ejemploPins += 'Admin (${u.nombre}): ${u.pin}';
      } else {
        ejemploPins += ' | ${u.nombre}: ${u.pin}';
      }
    }

    return Scaffold(
      backgroundColor: _bgDeep,
      body: Stack(
        children: [
          // Fondo gradiente profundo
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_bgDeep, _bgNavy, _bgPurple, _bgViolet],
                stops: [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),

          // Blob verde esmeralda (arriba izquierda)
          Positioned(
            top: -150,
            left: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Blob púrpura intenso (abajo derecha)
          Positioned(
            bottom: -150,
            right: -100,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 450,
                height: 450,
                decoration: BoxDecoration(
                  color: _bgViolet.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: authState.isLoading && authState.usuarios.isEmpty
                  ? const CircularProgressIndicator(color: _accent)
                  : FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Container(
                            width: containerWidth,
                            margin: isMobile
                                ? const EdgeInsets.symmetric(horizontal: 16)
                                : EdgeInsets.zero,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 50,
                                  spreadRadius: -5,
                                  offset: const Offset(0, 25),
                                ),
                                BoxShadow(
                                  color: _accent.withValues(alpha: 0.15),
                                  blurRadius: 60,
                                  spreadRadius: -10,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                                child: Container(
                                  padding: EdgeInsets.all(paddingSize),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(32),
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.12),
                                      width: 1.2,
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        _bgIndigo.withValues(alpha: 0.65),
                                        _bgNavy.withValues(alpha: 0.55),
                                      ],
                                      stops: const [0.0, 1.0],
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      // ═══════════════════════════════
                                      // Badge de estado de nube
                                      // ═══════════════════════════════
                                      const _CloudStatusBanner(),
                                      const SizedBox(height: 16),

                                      buildLogo(logoSize, isMobile),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: Text(
                                          'Inicia sesión para acceder al POS',
                                          style: TextStyle(
                                            color: Colors.white
                                                .withValues(alpha: 0.75),
                                            fontSize: isMobile ? 13 : 15,
                                            fontWeight: FontWeight.w400,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      buildPinMode(
                                          isMobile, isTablet, usuariosOrdenados),
                                      if (_errorMessage != null) ...[
                                        const SizedBox(height: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.red
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.red
                                                  .withValues(alpha: 0.35),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.error_outline,
                                                color: Colors.red.shade300,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  _errorMessage!,
                                                  style: TextStyle(
                                                    color:
                                                        Colors.red.shade300,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 32),
                                      buildLoginButton(buttonHeight, isMobile),
                                      const SizedBox(height: 20),
                                      Center(
                                        child: Text(
                                          'PIN de ejemplo: $ejemploPins',
                                          style: TextStyle(
                                            fontSize: isMobile ? 11 : 12,
                                            color: Colors.white
                                                .withValues(alpha: 0.35),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // ── Botón de sincronización manual ──
                                      Center(
                                        child: TextButton(
                                          onPressed: _isLoading
                                              ? null
                                              : () => _sincronizarUsuarios(
                                                  showFeedback: true),
                                          style: TextButton.styleFrom(
                                            foregroundColor: Colors.white
                                                .withValues(alpha: 0.7),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _isLoading
                                                    ? Icons.sync_rounded
                                                    : Icons
                                                        .cloud_sync_rounded,
                                                size: 18,
                                                color: Colors.white
                                                    .withValues(alpha: 0.7),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Sincronizar usuarios',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.white
                                                      .withValues(alpha: 0.7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      TextButton(
                                  onPressed: () async {
                                    final isar = IsarService();
                                    final usuarios = await isar.obtenerUsuarios();
                                    if (usuarios.isEmpty) return;

                                    final u = usuarios.first;
                                    final ok = await isar.forzarPinLegacyParaTest(u.id, '1234');
                                    debugPrint(ok
                                        ? '🧪 PIN legacy "1234" inyectado en "${u.nombre}" (ID: ${u.id})'
                                        : '⚠️ No se pudo inyectar');
                                  },
                                  child: const Text('🧪 Forzar PIN legacy'),
                                ),

                                      // ── Hint para tablets nuevas ──
                                      const SizedBox(height: 6),
                                      Center(
                                        child: Text(
                                          '¿Tablet nueva? Pide al admin que la configure.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.white
                                                .withValues(alpha: 0.4),
                                            fontWeight: FontWeight.w400,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================
  Widget buildLogo(double size, bool isMobile) {
    final double iconSize = size * 0.5;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_accent, _accentDeep],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _accent.withValues(alpha: 0.45),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/logoboosti300px.svg',
              width: iconSize,
              height: iconSize,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Color(0xFF6EE7B7)],
          ).createShader(bounds),
          child: Text(
            'BoostI POS',
            style: TextStyle(
              fontSize: isMobile ? 28 : 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PIN MODE
  // ============================================================
  Widget buildPinMode(
    bool isMobile,
    bool isTablet,
    List<UsuarioEntity> usuarios,
  ) {
    final fontSizeLabel = isMobile ? 13.0 : 15.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar Usuario',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSizeLabel,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _bgNavy.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Theme(
            data: Theme.of(context).copyWith(
              hoverColor: Colors.white.withValues(alpha: 0.08),
              focusColor: Colors.white.withValues(alpha: 0.08),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _selectedUserId,
                isExpanded: true,
                borderRadius: BorderRadius.circular(16),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                style: TextStyle(
                  fontSize: isMobile ? 16 : 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                dropdownColor: _bgIndigo,
                itemHeight: 64,
                menuMaxHeight: 350,
                items: usuarios.map((u) {
                  final role = UserRole.fromString(u.rol);
                  final isAdmin = role == UserRole.admin;
                  final isRrhh = role == UserRole.rrhh;
                  final isSupervisor = role == UserRole.supervisor;

                  Color chipColor;
                  IconData chipIcon;

                  if (isAdmin) {
                    chipColor = const Color(0xFF3B82F6);
                    chipIcon = Icons.admin_panel_settings_rounded;
                  } else if (isRrhh) {
                    chipColor = const Color(0xFF8B5CF6);
                    chipIcon = Icons.badge_rounded;
                  } else if (isSupervisor) {
                    chipColor = const Color(0xFFF59E0B);
                    chipIcon = Icons.supervisor_account_rounded;
                  } else {
                    chipColor = _accent;
                    chipIcon = Icons.person_rounded;
                  }

                  return DropdownMenuItem<int>(
                    value: u.id,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: chipColor.withValues(alpha: 0.2),
                          child: Icon(
                            chipIcon,
                            size: 18,
                            color: chipColor,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                u.nombre,
                                style: TextStyle(
                                  fontWeight: isAdmin
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontSize: isMobile ? 15 : 16,
                                  color: Colors.white,
                                ),
                              ),
                              if (isAdmin || isRrhh || isSupervisor)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    role.label.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                      color: chipColor.withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedUserId = val;
                    _errorMessage = null;
                  });
                  if (val != null) _saveSelectedUser(val);
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'PIN de Acceso',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSizeLabel,
            color: Colors.white.withValues(alpha: 0.8),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _pinController,
          obscureText: _obscurePin,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            letterSpacing: 8,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: '••••••',
            hintStyle: TextStyle(
              fontSize: isMobile ? 18 : 20,
              color: Colors.white.withValues(alpha: 0.3),
              letterSpacing: 8,
            ),
            counterText: '',
            filled: true,
            fillColor: _bgNavy.withValues(alpha: 0.65),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 12.0),
              child: Icon(
                Icons.lock_outline_rounded,
                color: Colors.white.withValues(alpha: 0.5),
                size: 22,
              ),
            ),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(
                  _obscurePin
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withValues(alpha: 0.5),
                  size: 22,
                ),
                onPressed: () => setState(() => _obscurePin = !_obscurePin),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isTablet ? 22 : 18,
            ),
          ),
          onFieldSubmitted: (_) => _loginWithPin(),
        ),
      ],
    );
  }

  // ============================================================
  // BOTÓN LOGIN
  // ============================================================
  Widget buildLoginButton(double height, bool isMobile) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: _accent.withValues(alpha: 0.4),
        ),
        onPressed: _isLoading || _selectedUserId == null ? null : _loginWithPin,
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isMobile ? 'Ingresar' : 'Ingresar al Sistema',
                    style: TextStyle(
                      fontSize: isMobile ? 15 : 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: isMobile ? 20 : 24,
                  ),
                ],
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// CLOUD STATUS BANNER — versión robusta
//
// Detecta en vivo el estado de la sesión de Supabase:
//   · Verde   → sesión válida + token no expirado
//   · Ámbar   → offline (sin sesión) o sesión expirada sin posibilidad
//               de refrescar
//
// Acciones:
//   · Tocarlo offline → navega a EmailLoginScreen
//   · Tocarlo online  → bottom sheet con opción de desconectar
//
// Offline-first: si no hay sesión, el login por PIN sigue funcionando.
// ═══════════════════════════════════════════════════════════════════════

class _CloudStatusBanner extends StatefulWidget {
  const _CloudStatusBanner();

  @override
  State<_CloudStatusBanner> createState() => _CloudStatusBannerState();
}

class _CloudStatusBannerState extends State<_CloudStatusBanner> {
   // ✅ StreamSubscription SIN genérico:
  //    con `hide AuthState` en el import, `StreamSubscription<AuthState>`
  //    se resuelve a tu AuthState local, pero onAuthStateChange emite
  //    Stream<gotrue.AuthState>. Sin genérico, ambos encajan.
  StreamSubscription? _authSub;   // ← ya NO dice <AuthState>
  bool _conectado = false;
  bool _cargando = true;
  bool _procesando = false;
  String? _emailConectado;
  DateTime? _expiraSesion;
  Timer? _debounce;

  static const Color _verde = Color(0xFF10B981);
  static const Color _ambar = Color(0xFFF59E0B);
  static const Color _bgIndigo = Color(0xFF1A1A4E);

  /// Debounce para evitar re-renders en ráfaga cuando el stream emite
  /// varios eventos seguidos (p.ej. `signedIn` seguido de `tokenRefreshed`).

  @override
  void initState() {
    super.initState();
    _checkStatus(motivo: 'init');
    _suscribirAuthStream();
  }

 void _suscribirAuthStream() {
  try {
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen(
      (event) {
        debugPrint('☁️ Auth event: ${event.event.name}');
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 200), () {
          if (mounted) _checkStatus(motivo: 'stream:${event.event.name}');
        });
      },
      onError: (e) {
        debugPrint('⚠️ auth stream error: $e');
      },
    );
  } catch (e) {
    debugPrint('⚠️ No se pudo suscribir a auth stream: $e');
    if (mounted) {
      setState(() {
        _conectado = false;
        _cargando = false;
      });
    }
  }
}

  @override
  void dispose() {
    _debounce?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════════
  // DETECCIÓN REAL DE SESIÓN
  //
  // Estrategia:
  //   1. Leer `currentSession` del cliente Supabase.
  //   2. Si está expirada → intentar `refreshSession()` proactivamente.
  //   3. Si el refresh falla → tratar como offline.
  //   4. Loguear todo con prefijo `☁️` para diagnóstico transparente.
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _checkStatus({required String motivo}) async {
    try {
      final auth = Supabase.instance.client.auth;
      Session? session = auth.currentSession;

      // ── Auto-refresh proactivo si está expirada ──
      if (session != null && session.isExpired) {
        debugPrint('☁️ [$motivo] Sesión expirada, intentando refresh...');
        try {
          final refreshed = await auth.refreshSession();
          session = refreshed.session;
          debugPrint('☁️ [$motivo] Refresh OK');
        } catch (e) {
          debugPrint('☁️ [$motivo] Refresh falló: $e → tratado como offline');
          session = null;
        }
      }

      final activa = session != null;

      if (activa) {
        _emailConectado = session.user.email;
        _expiraSesion = session.expiresAt != null
            ? DateTime.fromMillisecondsSinceEpoch(
                session.expiresAt! * 1000,
              )
            : null;

        final uidShort = session.user.id.length >= 8
            ? session.user.id.substring(0, 8)
            : session.user.id;

        debugPrint(
          '☁️ [$motivo] CONECTADO · '
          'email: ${_emailConectado ?? "?"} · '
          'uid: $uidShort… · '
          'expira: ${_expiraSesion?.toIso8601String() ?? "?"}',
        );
      } else {
        _emailConectado = null;
        _expiraSesion = null;
        debugPrint('☁️ [$motivo] OFFLINE (sin sesión Supabase)');
      }

      if (!mounted) return;
      setState(() {
        _conectado = activa;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('⚠️ [$motivo] Error chequeando sesión: $e');
      if (!mounted) return;
      setState(() {
        _conectado = false;
        _cargando = false;
        _emailConectado = null;
        _expiraSesion = null;
      });
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // ACCIONES
  // ═══════════════════════════════════════════════════════════════════

  Future<void> _onTap() async {
    if (_cargando || _procesando) return;
    if (_conectado) {
      await _mostrarOpcionesConectado();
    } else {
      _irALoginSupabase();
    }
  }

  void _irALoginSupabase() {
    debugPrint('☁️ Navegando a EmailLoginScreen para reconexión');
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const EmailLoginScreen()),
    );
  }

  Future<void> _mostrarOpcionesConectado() async {
    final email = _emailConectado ?? 'Desconocido';
    final expira = _expiraSesion;
    final minutosRestantes = expira?.difference(DateTime.now()).inMinutes;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _bgIndigo.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _verde.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.cloud_done_rounded,
                        color: _verde,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sesión de nube activa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 12.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (minutosRestantes != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              minutosRestantes > 0
                                  ? 'Token expira en ${minutosRestantes}min'
                                  : 'Token a punto de expirar',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── Botón: cerrar sesión nube ──
                _sheetAction(
                  icon: Icons.logout_rounded,
                  color: _ambar,
                  title: 'Desconectar de la nube',
                  subtitle:
                      'El login local por PIN sigue funcionando. No perderás datos.',
                  onTap: () async {
                    Navigator.pop(sheetContext);
                    await _desconectarNube();
                  },
                ),
                const SizedBox(height: 10),

                // ── Botón: cancelar ──
                _sheetAction(
                  icon: Icons.close_rounded,
                  color: Colors.white70,
                  title: 'Cancelar',
                  subtitle: 'Mantener sesión activa',
                  onTap: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sheetAction({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // DESCONEXIÓN ROBUSTA
  //
  // 1. `signOut()` de Supabase (limpia tokens locales + server).
  // 2. Si falla por red → forzar limpieza local invocando `signOut` de
  //    nuevo (Supabase limpia local en el primer intento de todos modos).
  // 3. NUNCA toca Isar ni SharedPreferences → PIN sigue funcionando.
  // ═══════════════════════════════════════════════════════════════════
  Future<void> _desconectarNube() async {
    setState(() => _procesando = true);
    try {
      debugPrint('☁️ Desconectando de Supabase...');
      await Supabase.instance.client.auth.signOut();
      debugPrint('☁️ signOut OK');

      // Forzar un check inmediato para actualizar el badge sin esperar
      // al evento del stream (que también llegará, pero por debounce).
      await _checkStatus(motivo: 'post-signOut');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '☁️ Desconectado de la nube. Modo offline activo.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Error en signOut: $e');
      // Aunque signOut falle por red, la sesión local normalmente ya se
      // limpió en el primer intento. Verificamos y avisamos.
      await _checkStatus(motivo: 'post-signOut-error');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _conectado
                ? '⚠️ No se pudo desconectar: $e'
                : '☁️ Sesión local limpiada (falló la notificación al servidor).',
          ),
          backgroundColor: _conectado ? Colors.red : const Color(0xFFF59E0B),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _procesando = false);
    }
  }

  // ═══════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════



  @override
  Widget build(BuildContext context) {
    final color = _conectado ? _verde : _ambar;
    final icon = _conectado
        ? Icons.cloud_done_rounded
        : Icons.cloud_off_rounded;

    // Texto dinámico: mostramos email si está conectado
    final String label;
    if (_conectado && _emailConectado != null) {
      label = 'Conectado · $_emailConectado';
    } else if (_conectado) {
      label = 'Conectado a la nube';
    } else {
      label = 'Modo offline · Toca para conectar';
    }

    final bgAlpha = _conectado ? 0.12 : 0.10;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: bgAlpha),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              if (_cargando || _procesando)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              else
                Icon(icon, color: color, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (!_cargando && !_procesando)
                Icon(
                  _conectado
                      ? Icons.expand_more_rounded
                      : Icons.arrow_forward_rounded,
                  color: color.withValues(alpha: 0.7),
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }
}