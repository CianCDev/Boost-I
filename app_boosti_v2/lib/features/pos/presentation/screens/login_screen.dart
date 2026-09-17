// lib/features/pos/presentation/screens/login_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/permissions/roles.dart';
import '../providers/auth_provider.dart';
import '../providers/usuario_provider.dart';
import '../services/sync_service.dart';
import '../services/error_service.dart';
import '../utils/responsive_helper.dart';
import 'empleados/employees_screen.dart';
import 'main_pos_screen.dart';
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

    ref.read(usuarioActualProvider.notifier).setUsuario(user);
    ErrorService.setUser(user.id.toString(), user.email, user.nombre);
    await _saveSelectedUser(user.id);

    // Sincronización inicial en background
    try {
      final syncService = SyncService();
      await syncService.descargarLocalesDesdeSupabase();
      await syncService.descargarPedidosDesdeSupabase();
      debugPrint('✅ Sincronización inicial completada después del login');
    } catch (e) {
      debugPrint('⚠️ Error en sincronización inicial: $e');
    }

    if (!mounted) return;
    _redirigirSegunRol(user);
  }

/// Navega a la pantalla correspondiente según el rol del usuario.
void _redirigirSegunRol(UsuarioEntity usuario) {
  final role = UserRole.fromString(usuario.rol);

  // Roles restringidos (RRHH por ahora) → van directo a su pantalla.
  if (Permissions.isEmployeesOnlyRole(role)) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const EmployeesScreen()),
    );
    return;
  }

  // ✅ CAMBIO: resto de roles → welcome screen (no directo al POS)
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
                                // Sombra profunda
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 50,
                                  spreadRadius: -5,
                                  offset: const Offset(0, 25),
                                ),
                                // Glow esmeralda sutil
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
                                    // Borde de vidrio sutil
                                    border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.12),
                                      width: 1.2,
                                    ),
                                    // ✅ Glass oscuro: misma paleta que el fondo
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
                                      _buildLogo(logoSize, isMobile),
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
                                      _buildPinMode(
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
                                      _buildLoginButton(
                                          buttonHeight, isMobile),
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
  Widget _buildLogo(double size, bool isMobile) {
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
  Widget _buildPinMode(
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
                // ✅ Dropdown en tono azul profundo consistente con la paleta
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
  Widget _buildLoginButton(double height, bool isMobile) {
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