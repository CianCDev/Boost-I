// lib/features/pos/presentation/screens/login_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      await ref.read(authProvider.notifier).loadUsuarios();
      final usuariosActualizados = await ref.refresh(usuariosProvider.future);
      if (usuariosActualizados.isNotEmpty) {
        debugPrint(
            '✅ Usuarios recargados en login: ${usuariosActualizados.length}');
      }

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
  // SINCRONIZACIÓN (manual desde botón)
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
  // LOGIN CON PIN
  // ============================================================

  /// Diálogo de carga que se muestra mientras se procesa el login.
  ///
  /// Es no-dismissible y se cierra programáticamente antes de navegar.
  void _mostrarLoadingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => const _LoginLoadingDialog(),
    );
  }

  void _cerrarLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _loginWithPin() async {
    final authState = ref.read(authProvider);
    if (authState.usuarios.isEmpty) {
      _showSnackbar('No hay usuarios disponibles', Colors.orange);
      return;
    }

    // Resolver usuario seleccionado
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

    // Marcar loading y limpiar error
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Mostrar diálogo modal de carga
    _mostrarLoadingDialog();

    try {
      // 1️⃣ Validar PIN (rápido, solo hashing local)
      final success = await ref
          .read(authProvider.notifier)
          .loginWithPin(usuarioSeleccionado, pin);

      if (!mounted) return;

      if (!success) {
        // Cerrar dialog y mostrar error
        _cerrarLoadingDialog();
        setState(() {
          _isLoading = false;
          _errorMessage = 'PIN incorrecto. Intenta de nuevo.';
        });
        return;
      }

      final user = ref.read(authProvider).currentUser;
      if (user == null) {
        _cerrarLoadingDialog();
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al cargar el usuario.';
        });
        return;
      }

      // 2️⃣ Persistir estado (operaciones rápidas locales)
      ref.read(usuarioActualProvider.notifier).setUsuario(user);
      ErrorService.setUser(user.id.toString(), user.email, user.nombre);
      await _saveSelectedUser(user.id);

      // 3️⃣ Verificar tenant (en memoria, instantáneo)
      final tenantState = ref.read(tenantActualProvider);
      if (!tenantState.tieneTenant) {
        debugPrint(
            '⚠️ Login PIN sin tenant en prefs. La sincronización fallará.');
      }

      if (!mounted) return;

      // 4️⃣ Cerrar loading dialog
      _cerrarLoadingDialog();

      // 5️⃣ Navegar INMEDIATAMENTE (sin esperar sync)
      redirigirSegunRol(user);

      // 6️⃣ Sync inicial en background (fire-and-forget)
      _sincronizarEnBackground();
    } catch (e) {
      if (!mounted) return;
      _cerrarLoadingDialog();
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error inesperado: $e';
      });
    }
  }

  /// Redirige según el rol del usuario autenticado.
  ///
  /// - Roles RRHH → EmployeesScreen
  /// - Resto → MainPosScreen
  void redirigirSegunRol(UsuarioEntity usuario) {
    if (!mounted) return;

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

  /// Sync inicial en background post-login.
  ///
  /// Corre en un microtask separado con timeout corto para no bloquear
  /// ni colgar la app si el dispositivo está offline.
  void _sincronizarEnBackground() {
    Future.microtask(() async {
      try {
        final syncService = SyncService();
        await syncService
            .descargarLocalesDesdeSupabase()
            .timeout(const Duration(seconds: 5));
        await syncService
            .descargarPedidosDesdeSupabase()
            .timeout(const Duration(seconds: 5));
        debugPrint('✅ Sync inicial post-login completada');
      } catch (e) {
        debugPrint('⚠️ Sync inicial post-login falló (offline?): $e');
      }
    });
  }

  // ============================================================
  // SELECTOR DE USUARIO (BOTTOM SHEET)
  // ============================================================
  void _openUserSelector(List<UsuarioEntity> usuarios) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _UserSelectionBottomSheet(
        usuarios: usuarios,
        selectedUserId: _selectedUserId,
        onUserSelected: (user) {
          setState(() {
            _selectedUserId = user.id;
            _errorMessage = null;
          });
          _saveSelectedUser(user.id);
          Navigator.pop(context);
        },
      ),
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

    String nombreSeleccionado = 'Seleccionar Usuario';
    if (_selectedUserId != null) {
      try {
        final u = usuariosOrdenados.firstWhere((u) => u.id == _selectedUserId);
        nombreSeleccionado = u.nombre;
      } catch (_) {}
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

          // Blob verde esmeralda
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

          // Blob púrpura intenso
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

                                      // Selector de usuario
                                      Text(
                                        'Seleccionar Usuario',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: isMobile ? 13.0 : 15.0,
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      InkWell(
                                        onTap: () =>
                                            _openUserSelector(usuariosOrdenados),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _bgNavy
                                                .withValues(alpha: 0.65),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.12),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.person_search_rounded,
                                                color: _accent,
                                                size: 22,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  nombreSeleccionado,
                                                  style: TextStyle(
                                                    fontSize:
                                                        isMobile ? 15 : 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.white,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Icon(
                                                Icons
                                                    .keyboard_arrow_down_rounded,
                                                color: Colors.white
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 24),
                                      Text(
                                        'PIN de Acceso',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: isMobile ? 13.0 : 15.0,
                                          color: Colors.white
                                              .withValues(alpha: 0.8),
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextFormField(
                                        controller: _pinController,
                                        obscureText: _obscurePin,
                                        keyboardType: TextInputType.number,
                                        maxLength: 6,
                                        enabled: !_isLoading,
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
                                            color: Colors.white
                                                .withValues(alpha: 0.3),
                                            letterSpacing: 8,
                                          ),
                                          counterText: '',
                                          filled: true,
                                          fillColor:
                                              _bgNavy.withValues(alpha: 0.65),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.white
                                                  .withValues(alpha: 0.12),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                                color: _accent, width: 2.0),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                              color: Colors.white
                                                  .withValues(alpha: 0.12),
                                            ),
                                          ),
                                          prefixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0, right: 12.0),
                                            child: Icon(
                                              Icons.lock_outline_rounded,
                                              color: Colors.white
                                                  .withValues(alpha: 0.5),
                                              size: 22,
                                            ),
                                          ),
                                          suffixIcon: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 8.0),
                                            child: IconButton(
                                              icon: Icon(
                                                _obscurePin
                                                    ? Icons
                                                        .visibility_off_outlined
                                                    : Icons.visibility_outlined,
                                                color: Colors.white
                                                    .withValues(alpha: 0.5),
                                                size: 22,
                                              ),
                                              onPressed: () => setState(() =>
                                                  _obscurePin = !_obscurePin),
                                            ),
                                          ),
                                          contentPadding:
                                              EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: isTablet ? 22 : 18,
                                          ),
                                        ),
                                        onFieldSubmitted: (_) =>
                                            _isLoading ? null : _loginWithPin(),
                                      ),

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

                                      // Botón de sincronización manual
                                      const SizedBox(height: 16),
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
  // BOTÓN LOGIN
  // ============================================================
  Widget buildLoginButton(double height, bool isMobile) {
    final habilitado = !_isLoading && _selectedUserId != null;

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
        onPressed: habilitado ? _loginWithPin : null,
        child: _isLoading
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Verificando...',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
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
// LOGIN LOADING DIALOG
//
// Diálogo no-dismissible que aparece mientras se procesa el login.
// Se cierra programáticamente antes de navegar.
// ═══════════════════════════════════════════════════════════════════════

class _LoginLoadingDialog extends StatefulWidget {
  const _LoginLoadingDialog();

  @override
  State<_LoginLoadingDialog> createState() => _LoginLoadingDialogState();
}

class _LoginLoadingDialogState extends State<_LoginLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  int _mensajeIndex = 0;

  static const List<String> _mensajes = [
    'Verificando PIN...',
    'Preparando sesión...',
    'Iniciando app...',
  ];

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();

    // Rotar mensajes cada 1.2s
    _timer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (mounted && _mensajeIndex < _mensajes.length - 1) {
        setState(() => _mensajeIndex++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A4E).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  blurRadius: 40,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spinner
                const SizedBox(
                  width: 48,
                  height: 48,
                  child: CircularProgressIndicator(
                    color: Color(0xFF10B981),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),

                // Mensaje dinámico
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: Text(
                    _mensajes[_mensajeIndex],
                    key: ValueKey(_mensajeIndex),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Esto puede tardar unos segundos si estás offline',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// USER SELECTION BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════════

class _UserSelectionBottomSheet extends StatefulWidget {
  final List<UsuarioEntity> usuarios;
  final int? selectedUserId;
  final ValueChanged<UsuarioEntity> onUserSelected;

  const _UserSelectionBottomSheet({
    required this.usuarios,
    required this.selectedUserId,
    required this.onUserSelected,
  });

  @override
  State<_UserSelectionBottomSheet> createState() =>
      _UserSelectionBottomSheetState();
}

class _UserSelectionBottomSheetState extends State<_UserSelectionBottomSheet> {
  late TextEditingController _searchController;
  late List<UsuarioEntity> _filteredUsuarios;

  static const Color _bgIndigo = Color(0xFF1A1A4E);
  static const Color _bgNavy = Color(0xFF0A0E27);
  static const Color _accent = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredUsuarios = widget.usuarios;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filtrarUsuarios(String query) {
    if (query.isEmpty) {
      setState(() => _filteredUsuarios = widget.usuarios);
      return;
    }
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredUsuarios = widget.usuarios
          .where((u) => u.nombre.toLowerCase().contains(lowerQuery))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: _bgNavy,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Seleccionar Usuario',
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: _filtrarUsuarios,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                prefixIcon: Icon(Icons.search_rounded,
                    color: Colors.white.withValues(alpha: 0.5)),
                filled: true,
                fillColor: _bgIndigo.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _filteredUsuarios.isEmpty
                ? Center(
                    child: Text(
                      'No se encontraron usuarios',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                      left: 12,
                      right: 12,
                      bottom: 20 + bottomPadding,
                    ),
                    itemCount: _filteredUsuarios.length,
                    itemBuilder: (context, index) {
                      final u = _filteredUsuarios[index];
                      final isSelected = u.id == widget.selectedUserId;
                      final role = UserRole.fromString(u.rol);

                      Color chipColor;
                      IconData chipIcon;
                      if (role == UserRole.admin) {
                        chipColor = const Color(0xFF3B82F6);
                        chipIcon = Icons.admin_panel_settings_rounded;
                      } else if (role == UserRole.rrhh) {
                        chipColor = const Color(0xFF8B5CF6);
                        chipIcon = Icons.badge_rounded;
                      } else if (role == UserRole.supervisor) {
                        chipColor = const Color(0xFFF59E0B);
                        chipIcon = Icons.supervisor_account_rounded;
                      } else {
                        chipColor = _accent;
                        chipIcon = Icons.person_rounded;
                      }

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Material(
                          color: isSelected
                              ? _accent.withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            onTap: () => widget.onUserSelected(u),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? _accent.withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.08),
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        chipColor.withValues(alpha: 0.2),
                                    child: Icon(chipIcon,
                                        size: 20, color: chipColor),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          u.nombre,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: u.activo
                                                ? Colors.white
                                                : Colors.white
                                                    .withValues(alpha: 0.4),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        if (!u.activo)
                                          Text(
                                            'INACTIVO',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.orange
                                                  .withValues(alpha: 0.8),
                                            ),
                                          )
                                        else
                                          Text(
                                            role.label.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: chipColor
                                                  .withValues(alpha: 0.9),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded,
                                        color: _accent, size: 22),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// CLOUD STATUS BANNER
// ═══════════════════════════════════════════════════════════════════════

class _CloudStatusBanner extends StatefulWidget {
  const _CloudStatusBanner();

  @override
  State<_CloudStatusBanner> createState() => _CloudStatusBannerState();
}

class _CloudStatusBannerState extends State<_CloudStatusBanner> {
  StreamSubscription? _authSub;
  bool _conectado = false;
  bool _cargando = true;
  bool _procesando = false;
  String? _emailConectado;
  DateTime? _expiraSesion;
  Timer? _debounce;

  static const Color _verde = Color(0xFF10B981);
  static const Color _ambar = Color(0xFFF59E0B);
  static const Color _bgIndigo = Color(0xFF1A1A4E);

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

  Future<void> _checkStatus({required String motivo}) async {
    try {
      final auth = Supabase.instance.client.auth;
      Session? session = auth.currentSession;

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
            ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
            : null;
        final uidShort = session.user.id.length >= 8
            ? session.user.id.substring(0, 8)
            : session.user.id;
        debugPrint(
          '☁️ [$motivo] CONECTADO · email: ${_emailConectado ?? "?"} · uid: $uidShort… · expira: ${_expiraSesion?.toIso8601String() ?? "?"}',
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

  Future<void> _desconectarNube() async {
    setState(() => _procesando = true);
    try {
      debugPrint('☁️ Desconectando de Supabase...');
      await Supabase.instance.client.auth.signOut();
      debugPrint('☁️ signOut OK');

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

  @override
  Widget build(BuildContext context) {
    final color = _conectado ? _verde : _ambar;
    final icon = _conectado
        ? Icons.cloud_done_rounded
        : Icons.cloud_off_rounded;

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