import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../presentation/providers/usuario_provider.dart';
import 'pos_desktop_screen.dart';
import '../utils/responsive_helper.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final IsarService _isarService = IsarService();

  // Controladores para opción 1 (Usuario y PIN local/Supabase)
  final TextEditingController _pinController = TextEditingController();
  List<UsuarioEntity> _usuarios = [];
  UsuarioEntity? _usuarioSeleccionado;

  // Controladores para opción 2 (Correo electrónico y Contraseña en Supabase)
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isEmailMode = false;
  bool _cargando = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _inicializarYCargarUsuarios();
  }

  Future<void> _inicializarYCargarUsuarios() async {
    await _isarService.inicializarUsuarioAdminPorDefecto();
    final usuarios = await _isarService.obtenerUsuariosActivos();

    setState(() {
      _usuarios = usuarios;
      if (usuarios.isNotEmpty) {
        _usuarioSeleccionado = usuarios.first;
      }
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
          final usuarioValido = await _isarService.validarLogin(_usuarioSeleccionado!.nombre, pinIngresado);
          if (usuarioValido != null && mounted) {
            ref.read(usuarioActualProvider.notifier).setUsuario(usuarioValido);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => PosDesktopScreen(usuarioActual: usuarioValido)),
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
          MaterialPageRoute(
            builder: (context) => PosDesktopScreen(usuarioActual: usuarioValido),
          ),
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
          MaterialPageRoute(
            builder: (context) => PosDesktopScreen(usuarioActual: usuarioValido),
          ),
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

  @override
  void dispose() {
    _pinController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    ResponsiveHelper.getFontSize(context, baseSize: 14);

    // Ancho del contenedor
    double containerWidth;
    double paddingSize;
    double titleFontSize;
    double buttonHeight;

    if (isMobile) {
      containerWidth = double.infinity;
      paddingSize = 20.0;
      titleFontSize = 18.0;
      buttonHeight = 48.0;
    } else if (isTablet) {
      containerWidth = 400.0;
      paddingSize = 28.0;
      titleFontSize = 20.0;
      buttonHeight = 50.0;
    } else {
      containerWidth = 420.0;
      paddingSize = 32.0;
      titleFontSize = 22.0;
      buttonHeight = 52.0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: _cargando && _usuarios.isEmpty
            ? const CircularProgressIndicator(color: Color(0xFF10B981))
            : Container(
                width: containerWidth,
                margin: isMobile ? const EdgeInsets.symmetric(horizontal: 16) : EdgeInsets.zero,
                padding: EdgeInsets.all(paddingSize),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo y título
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.point_of_sale,
                          size: isMobile ? 30 : 36,
                          color: const Color(0xFF3B82F6),
                        ),
                        SizedBox(width: isMobile ? 8 : 12),
                        Text(
                          'SmartPOS',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        'Inicia sesión para abrir tu turno',
                        style: TextStyle(
                          color: const Color(0xFF64748B),
                          fontSize: isMobile ? 12 : 13,
                        ),
                      ),
                    ),
                   SizedBox(height: isMobile ? 12 : 16),

                    // Selector de Modo de Acceso
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: !_isEmailMode ? const Color(0xFF3B82F6) : Colors.transparent,
                              foregroundColor: !_isEmailMode ? Colors.white : const Color(0xFF334155),
                              padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => setState(() {
                              _isEmailMode = false;
                              _errorMessage = '';
                            }),
                            child: Text(
                              'Con PIN',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _isEmailMode ? const Color(0xFF3B82F6) : Colors.transparent,
                              foregroundColor: _isEmailMode ? Colors.white : const Color(0xFF334155),
                              padding: EdgeInsets.symmetric(vertical: isMobile ? 8 : 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => setState(() {
                              _isEmailMode = true;
                              _errorMessage = '';
                            }),
                            child: Text(
                              'Con Correo',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 16 : 20),

                    // Campos dinámicos
                    if (!_isEmailMode) ...[
                      // OPCIÓN 1: Usuario y PIN
                      Text(
                        'Seleccionar Usuario',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 11 : 12,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<UsuarioEntity>(
                        initialValue: _usuarioSeleccionado,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        items: _usuarios.map((u) {
                          return DropdownMenuItem(
                            value: u,
                            child: Text(
                              '${u.nombre} (${u.rol.toUpperCase()})',
                              style: TextStyle(
                                fontSize: isMobile ? 13 : 14,
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
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'PIN de Acceso',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 11 : 12,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                        ),
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Color.fromARGB(255, 145, 145, 145)),
                          hintText: 'Ingresa tu PIN',
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        onSubmitted: (_) => _intentarLoginPin(),
                      ),
                    ] else ...[
                      // OPCIÓN 2: Correo electrónico y Contraseña
                      Text(
                        'Correo Electrónico',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 11 : 12,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                        ),
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Color.fromARGB(255, 145, 145, 145)),
                          hintText: 'ejemplo@correo.com',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                      ),
                  SizedBox(height: isMobile ? 12 : 16),
                      Text(
                        'Contraseña',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 11 : 12,
                          color: const Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 15,
                        ),
                        decoration: InputDecoration(
                          hintStyle: const TextStyle(color: Color.fromARGB(255, 145, 145, 145)),
                          hintText: 'Ingresa tu contraseña',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.lock_outline),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: isMobile ? 10 : 12,
                          ),
                        ),
                        onSubmitted: (_) => _intentarLoginEmail(),
                      ),
                    ],

                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    SizedBox(height: isMobile ? 16 : 24),

                    // Botón principal
                    SizedBox(
                      height: buttonHeight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        onPressed: _cargando
                            ? null
                            : (_isEmailMode ? _intentarLoginEmail : _intentarLoginPin),
                        child: _cargando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isMobile ? 'Ingresar' : 'Ingresar al Sistema',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Nota: Admin por defecto PIN: 1234 | Cajero PIN: 0000',
                        style: TextStyle(
                          fontSize: isMobile ? 9 : 10,
                          color: const Color(0xFF94A3B8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}