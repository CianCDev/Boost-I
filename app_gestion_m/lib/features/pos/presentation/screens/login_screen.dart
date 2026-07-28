import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 👈 1. Importamos Riverpod
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../presentation/providers/usuario_provider.dart'; // 👈 Ajusta esta ruta a tu provider
import 'pos_desktop_screen.dart';

// 👈 2. Cambiamos a ConsumerStatefulWidget
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// 👈 3. Cambiamos a ConsumerState<LoginScreen>
class _LoginScreenState extends ConsumerState<LoginScreen> {
  final IsarService _isarService = IsarService();
  final TextEditingController _pinController = TextEditingController();
  
  List<UsuarioEntity> _usuarios = [];
  UsuarioEntity? _usuarioSeleccionado;
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

  Future<void> _intentarLogin() async {
    if (_usuarioSeleccionado == null) return;

    final pinIngresado = _pinController.text.trim();
    if (pinIngresado.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa tu PIN de acceso.');
      return;
    }

    final usuarioValido = await _isarService.validarLogin(
      _usuarioSeleccionado!.nombre,
      pinIngresado,
    );

    if (usuarioValido != null && mounted) {
      // ✅ AHORA SÍ: Guardamos el usuario en Riverpod antes de pasar a la pantalla POS
      ref.read(usuarioActualProvider.notifier).setUsuario(usuarioValido);

      // Navegar al POS enviando el usuario autenticado
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PosDesktopScreen(usuarioActual: usuarioValido),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'PIN incorrecto. Inténtalo de nuevo.';
        _pinController.clear();
      });
    }
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Center(
        child: _cargando
            ? const CircularProgressIndicator(color: Color(0xFF10B981))
            : Container(
                width: 420,
                padding: const EdgeInsets.all(32),
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
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.point_of_sale, size: 36, color: Color(0xFF3B82F6)),
                        SizedBox(width: 12),
                        Text(
                          'SmartPOS',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Inicia sesión para abrir tu turno',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Selector de Empleado
                    const Text('Seleccionar Usuario', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<UsuarioEntity>(
                      initialValue: _usuarioSeleccionado,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                      items: _usuarios.map((u) {
                        return DropdownMenuItem(
                          value: u,
                          child: Text('${u.nombre} (${u.rol.toUpperCase()})'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _usuarioSeleccionado = val;
                          _errorMessage = '';
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de PIN
                    const Text('PIN de Acceso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(color: Color.fromARGB(255, 145, 145, 145)),
                        hintText: 'Ingresa tu PIN',
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      onSubmitted: (_) => _intentarLogin(),
                    ),
                    
                    if (_errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Botón de Ingreso
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _intentarLogin,
                      child: const Text(
                        'Ingresar al Sistema',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Nota: Admin por defecto PIN: 1234 | Cajero PIN: 0000',
                        style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}