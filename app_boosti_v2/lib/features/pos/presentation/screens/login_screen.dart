// lib/features/pos/presentation/screens/login_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/usuario_provider.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';
import 'inventory_catalog_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  bool _obscurePin = true;
  int? _selectedUserId;
  bool _isLoading = false;
  String? _errorMessage;
  final GlobalKey<ScaffoldMessengerState> _scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final usuariosActualizados = await ref.refresh(usuariosProvider.future);
      if (usuariosActualizados.isNotEmpty) {
        debugPrint('✅ Usuarios recargados en login: ${usuariosActualizados.length}');
      }
      _sincronizarUsuarios(showFeedback: false);
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
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt('selected_user_id');
    if (savedId != null) {
      final authState = ref.read(authProvider);
      final exists = authState.usuarios.any((u) => u.id == savedId);
      if (exists && mounted) {
        setState(() => _selectedUserId = savedId);
      }
    }
  }

  Future<void> _saveSelectedUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_user_id', userId);
  }

  // ============================================================
  // SINCRONIZACIÓN
  // ============================================================
  Future<void> _sincronizarUsuarios({bool showFeedback = true}) async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      await SyncService().sincronizarUsuariosASupabase();
      await ref.read(authProvider.notifier).loadUsuarios();
      if (showFeedback && mounted) {
        _showSnackbar('✅ Usuarios sincronizados', Colors.green);
      }
    } catch (e) {
      if (showFeedback && mounted) {
        _showSnackbar('⚠️ Error sincronizando: $e', Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================
  void _loginWithPin() async {
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

    setState(() => _isLoading = true);
    final success = await ref.read(authProvider.notifier).loginWithPin(
          usuarioSeleccionado,
          pin,
        );
    setState(() => _isLoading = false);

    if (success && mounted) {
      final user = ref.read(authProvider).currentUser;
      if (user != null) {
        ref.read(usuarioActualProvider.notifier).setUsuario(user);
        await _saveSelectedUser(user.id);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => InventoryCatalogScreen(usuarioLogueado: user),
          ),
        );
      }
    } else if (mounted) {
      setState(() => _errorMessage = 'PIN incorrecto. Intenta de nuevo.');
    }
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
      key: _scaffoldKey,
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E27),  // Azul oscuro profundo
              Color(0xFF1A1A4E),
              Color(0xFF2D1B69),
              Color(0xFF4C2B8C),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: authState.isLoading && authState.usuarios.isEmpty
                ? const CircularProgressIndicator(color: Color(0xFF10B981))
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
                          padding: EdgeInsets.all(paddingSize),
                          decoration: BoxDecoration(
                            // 🧊 Glassmorphism
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.25),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 50,
                                offset: const Offset(0, 30),
                              ),
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                blurRadius: 60,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Container(
                                padding: EdgeInsets.all(paddingSize),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _buildLogo(logoSize, isMobile),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Text(
                                        'Inicia sesión para acceder al POS',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontSize: isMobile ? 13 : 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    _buildPinMode(isMobile, isTablet, usuariosOrdenados),
                                    if (_errorMessage != null) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: Colors.red.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(Icons.error_outline,
                                                color: Colors.red.shade300, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                _errorMessage!,
                                                style: TextStyle(
                                                  color: Colors.red.shade300,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 24),
                                    _buildLoginButton(buttonHeight, isMobile),
                                    const SizedBox(height: 16),
                                    Center(
                                      child: Text(
                                        'PIN de ejemplo: $ejemploPins',
                                        style: TextStyle(
                                          fontSize: isMobile ? 10 : 12,
                                          color: Colors.white.withValues(alpha: 0.5),
                                          fontWeight: FontWeight.w400,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Center(
                                      child: TextButton(
                                        onPressed: _isLoading ? null : () => _sincronizarUsuarios(),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _isLoading
                                                  ? Icons.sync_rounded
                                                  : Icons.cloud_sync_rounded,
                                              size: 16,
                                              color: Colors.white.withValues(alpha: 0.6),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Sincronizar usuarios',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white.withValues(alpha: 0.6),
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
      ),
    );
  }

  // ============================================================
  // COMPONENTES UI
  // ============================================================

  Widget _buildLogo(double size, bool isMobile) {
    final double iconSize = isMobile ? 48 : 64;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF10B981),
                Color(0xFF059669),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            Icons.point_of_sale_rounded,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        const SizedBox(height: 18),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF10B981),
              Color(0xFF34D399),
            ],
          ).createShader(bounds),
          child: Text(
            'BoostI POS',
            style: TextStyle(
              fontSize: isMobile ? 26 : 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPinMode(bool isMobile, bool isTablet, List<UsuarioEntity> usuarios) {
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
          ),
        ),
        const SizedBox(height: 8),
        // 🔥 Dropdown con glassmorphism
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedUserId,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: Colors.white.withValues(alpha: 0.6)),
                    style: TextStyle(
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    dropdownColor: const Color(0xFF1A1A4E),
                    items: usuarios.map((u) {
                      final isAdmin = u.rol == 'admin';
                      return DropdownMenuItem<int>(
                        value: u.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: isAdmin
                                  ? const Color(0xFF3B82F6).withValues(alpha: 0.2)
                                  : const Color(0xFF10B981).withValues(alpha: 0.2),
                              child: Icon(
                                isAdmin ? Icons.admin_panel_settings_rounded : Icons.person_rounded,
                                size: 18,
                                color: isAdmin ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    u.nombre,
                                    style: TextStyle(
                                      fontWeight: isAdmin ? FontWeight.bold : FontWeight.normal,
                                      fontSize: isMobile ? 14 : 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (isAdmin)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3B82F6).withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'ADMIN',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF3B82F6),
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
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'PIN de Acceso',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSizeLabel,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 8),
        // 🔥 Campo PIN con glassmorphism
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextFormField(
              controller: _pinController,
              obscureText: _obscurePin,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                letterSpacing: 4,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Ingresa tu PIN',
                hintStyle: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w400,
                ),
                counterText: '',
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Icon(Icons.lock_outline_rounded,
                      color: Colors.white.withValues(alpha: 0.5), size: isTablet ? 28 : 24),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: isTablet ? 28 : 24,
                  ),
                  onPressed: () => setState(() => _obscurePin = !_obscurePin),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isTablet ? 22 : 18),
              ),
              onFieldSubmitted: (_) => _loginWithPin(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(double height, bool isMobile) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
          shadowColor: const Color(0xFF10B981).withValues(alpha: 0.3),
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
                      fontWeight: FontWeight.bold,
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