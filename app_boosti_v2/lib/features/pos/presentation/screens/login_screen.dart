import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../presentation/providers/usuario_provider.dart';
import '../utils/responsive_helper.dart';
import 'inventory_catalog_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final IsarService _isarService = IsarService();

  // Controladores
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  List<UsuarioEntity> _usuarios = [];
  UsuarioEntity? _usuarioSeleccionado;

  bool _isEmailMode = false;
  bool _cargando = true;
  String _errorMessage = '';
  bool _obscurePin = true;
  bool _obscurePassword = true;

  // Animaciones
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _inicializarYCargarUsuarios();

    // Configurar animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
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

    // Iniciar animación al cargar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pinController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // MÉTODOS DE AUTENTICACIÓN
  // ============================================================

  Future<void> _inicializarYCargarUsuarios() async {
    await _isarService.inicializarUsuarioAdminPorDefecto();
    final usuarios = await _isarService.obtenerUsuariosActivos();
    setState(() {
      _usuarios = usuarios;
      if (usuarios.isNotEmpty) _usuarioSeleccionado = usuarios.first;
      _cargando = false;
    });
  }

  Future<void> _autenticarEnSupabase(UsuarioEntity usuario) async {
    try {
      final supabase = Supabase.instance.client;
      if (supabase.auth.currentSession != null) return;
      if (usuario.rol.toLowerCase() == 'admin') {
        await supabase.auth.signInWithPassword(
          email: 'admin@tuapp.com',
          password: 'Admin123456!',
        );
        debugPrint('✅ Sesión de Supabase iniciada correctamente como ADMIN');
      }
    } catch (e) {
      debugPrint('⚠️ No se pudo iniciar sesión en Supabase (modo offline): $e');
    }
  }

  Future<void> _intentarLoginPin() async {
    if (_usuarioSeleccionado == null) return;
    final pinIngresado = _pinController.text.trim();
    if (pinIngresado.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa tu PIN de acceso.');
      return;
    }
    setState(() {
      _cargando = true;
      _errorMessage = '';
    });
    if ((_usuarioSeleccionado!.email ?? '').isNotEmpty) {
      try {
        final email = _usuarioSeleccionado!.email!;
        final res = await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: pinIngresado,
        );
        if (res.user != null) {
          final usuarioValido =
              await _isarService.validarLogin(_usuarioSeleccionado!.nombre, pinIngresado);
          if (usuarioValido != null && mounted) {
            ref.read(usuarioActualProvider.notifier).setUsuario(usuarioValido);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => InventoryCatalogScreen(usuarioLogueado: usuarioValido)),
            );
            return;
          }
        }
      } catch (e) {
        debugPrint('Supabase login con PIN falló, intentando local: $e');
      }
    }
    final usuarioValido = await _isarService.validarLogin(
      _usuarioSeleccionado!.nombre,
      pinIngresado,
    );
    if (usuarioValido != null && mounted) {
      ref.read(usuarioActualProvider.notifier).setUsuario(usuarioValido);
      await _autenticarEnSupabase(usuarioValido);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => InventoryCatalogScreen(usuarioLogueado: usuarioValido)),
        );
      }
    } else {
      setState(() {
        _errorMessage = 'PIN incorrecto. Inténtalo de nuevo.';
        _pinController.clear();
        _cargando = false;
      });
    }
  }

  Future<void> _intentarLoginEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa tu correo y contraseña.');
      return;
    }
    setState(() {
      _cargando = true;
      _errorMessage = '';
    });
    try {
      final supabase = Supabase.instance.client;
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final User? authUser = response.user;
      if (authUser == null) {
        setState(() {
          _errorMessage = 'Credenciales inválidas.';
          _cargando = false;
        });
        return;
      }
      final Map<String, dynamic> dataUsuario = await supabase
          .from('usuarios')
          .select()
          .eq('id', authUser.id)
          .single();
      final usuarioValido = UsuarioEntity()
        ..id = 0
        ..supabaseUid = authUser.id
        ..nombre = dataUsuario['nombre'] ?? 'Sin Nombre'
        ..rol = dataUsuario['rol'] ?? 'cajero'
        ..pin = ''
        ..email = authUser.email
        ..activo = true;
      if (mounted) {
        ref.read(usuarioActualProvider.notifier).setUsuario(usuarioValido);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => InventoryCatalogScreen(usuarioLogueado: usuarioValido)),
        );
      }
    } catch (e) {
      debugPrint('Error en login con Supabase: $e');
      setState(() {
        _errorMessage = 'Correo o contraseña incorrectos.';
        _cargando = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

    @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenSize = MediaQuery.of(context).size;

    // --- CORRECCIÓN FINAL DE TAMAÑO PARA TABLETS ---
    double containerWidth;
    if (isMobile) {
      // Móviles: 90% del ancho de la pantalla
      containerWidth = screenSize.width * 0.9;
    } else {
      // Tablets y Escritorios: Un tamaño fijo y amplio (600px)
      // Esto asegura que en iPads grandes (con escala 2.0x) no se vea diminuto.
      containerWidth = 600.0;
      // Seguridad extra: Si la pantalla es muy pequeña, no sobrepasar el 90%
      if (containerWidth > screenSize.width * 0.9) {
        containerWidth = screenSize.width * 0.9;
      }
    }

    final paddingSize = isMobile ? 24.0 : 42.0; // Respiración amplia en tablet
    final buttonHeight = isMobile ? 50.0 : 62.0; // Botón táctil y grande
    final logoSize = isMobile ? 80.0 : 120.0;    // Logo grande para llenar el espacio

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 13, 9, 63),
              Color.fromARGB(255, 81, 61, 153),
              Color.fromARGB(255, 130, 97, 174),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Center(
          child: _cargando && _usuarios.isEmpty
              ? const CircularProgressIndicator(color: Color(0xFF10B981))
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Container(
                      width: containerWidth,
                      margin: isMobile
                          ? const EdgeInsets.symmetric(horizontal: 16)
                          : EdgeInsets.zero,
                      padding: EdgeInsets.all(paddingSize),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.98),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 40,
                            offset: const Offset(0, 20),
                          ),
                        ],
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLogo(logoSize, isMobile),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Inicia sesión para abrir tu turno',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: isMobile ? 13 : 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(height: isMobile ? 24 : 32),
                            _buildModeSelector(isMobile),
                            SizedBox(height: isMobile ? 20 : 28),
                            if (!_isEmailMode)
                              _buildPinMode(isMobile, isTablet)
                            else
                              _buildEmailMode(isMobile, isTablet),
                            if (_errorMessage.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage,
                                        style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            SizedBox(height: isMobile ? 24 : 32),
                            _buildLoginButton(buttonHeight, isMobile),
                            const SizedBox(height: 16),
                            Center(
                              child: Text(
                                'Admin PIN: 1234 | Cajero PIN: 0000',
                                style: TextStyle(
                                  fontSize: isMobile ? 10 : 12,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w400,
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
                Color.fromARGB(255, 67, 16, 185),
                Color.fromARGB(255, 36, 107, 219),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
                blurRadius: 30,
                offset: const Offset(0, 8),
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
              Color.fromARGB(255, 16, 83, 185),
              Color.fromARGB(255, 100, 59, 246),
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

  Widget _buildModeSelector(bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              icon: Icons.vpn_key_outlined,
              label: 'PIN',
              isSelected: !_isEmailMode,
              onTap: () {
                setState(() {
                  _isEmailMode = false;
                  _errorMessage = '';
                });
              },
              isMobile: isMobile,
            ),
          ),
          Expanded(
            child: _buildModeButton(
              icon: Icons.alternate_email_outlined,
              label: 'Correo',
              isSelected: _isEmailMode,
              onTap: () {
                setState(() {
                  _isEmailMode = true;
                  _errorMessage = '';
                });
              },
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isMobile,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? const Color(0xFF0F172A) : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: isMobile ? 13 : 15,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? const Color(0xFF0F172A) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinMode(bool isMobile, bool isTablet) {
    final double fontSizeLabel = isMobile ? 13.0 : 15.0;
    final double paddingVerticalInput = isTablet ? 22.0 : 18.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seleccionar Usuario',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSizeLabel,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: DropdownButtonFormField<UsuarioEntity>(
            initialValue: _usuarioSeleccionado,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isTablet ? 18.0 : 12.0),
            ),
            items: _usuarios.map((u) {
              return DropdownMenuItem(
                value: u,
                child: Text(
                  '${u.nombre} (${u.rol.toUpperCase()})',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                  ),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _usuarioSeleccionado = val;
                _errorMessage = '';
              });
            },
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        Text(
          'PIN de Acceso',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSizeLabel,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        // CAMPO DE PIN CON TIPOGRAFÍA MÁS LIMPIA Y ESPACIADO PERFECTO
        TextFormField(
          controller: _pinController,
          obscureText: _obscurePin,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: TextStyle(
            fontSize: isMobile ? 16 : 20,
            letterSpacing: 4,
          ),
          decoration: InputDecoration(
            hintText: 'Ingresa tu PIN',
            hintStyle: TextStyle(
              fontSize: isMobile ? 14 : 16, 
              color: Colors.grey.shade400,
              letterSpacing: 0.5, 
              fontWeight: FontWeight.w400,
            ),
            counterText: '',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade500, size: isTablet ? 28 : 24),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: isTablet ? 28 : 24,
              ),
              onPressed: () => setState(() => _obscurePin = !_obscurePin),
            ),
            // Espaciado vertical extra en tablets para ser fácil de tocar
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: paddingVerticalInput),
          ),
          onFieldSubmitted: (_) => _intentarLoginPin(),
        ),
      ],
    );
  }

  Widget _buildEmailMode(bool isMobile, bool isTablet) {
    final double fontSizeLabel = isMobile ? 13.0 : 15.0;
    final double paddingVerticalInput = isTablet ? 22.0 : 18.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Correo Electrónico',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSizeLabel,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(fontSize: isMobile ? 15 : 18),
          decoration: InputDecoration(
            hintText: 'ejemplo@correo.com',
            hintStyle: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.grey.shade400),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Icon(Icons.email_outlined, color: Colors.grey.shade500, size: isTablet ? 28 : 24),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: paddingVerticalInput),
          ),
        ),
        SizedBox(height: isMobile ? 16 : 24),
        Text(
          'Contraseña',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: fontSizeLabel,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: TextStyle(fontSize: isMobile ? 15 : 18),
          decoration: InputDecoration(
            hintText: 'Ingresa tu contraseña',
            hintStyle: TextStyle(fontSize: isMobile ? 14 : 16, color: Colors.grey.shade400),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Icon(Icons.lock_outline_rounded, color: Colors.grey.shade500, size: isTablet ? 28 : 24),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: Colors.grey.shade500,
                size: isTablet ? 28 : 24,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: paddingVerticalInput),
          ),
          onFieldSubmitted: (_) => _intentarLoginEmail(),
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
        ),
        onPressed: _cargando
            ? null
            : (_isEmailMode ? _intentarLoginEmail : _intentarLoginPin),
        child: _cargando
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