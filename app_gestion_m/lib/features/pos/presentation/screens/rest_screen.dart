import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lock_provider.dart';
import '../../data/Local/entities/isar_service.dart';

class RestScreen extends ConsumerStatefulWidget {
  const RestScreen({super.key});

  @override
  ConsumerState<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends ConsumerState<RestScreen> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocus = FocusNode();
  final IsarService _isarService = IsarService();
  
  String _errorMessage = '';
  bool _cargando = false;

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  /// Valida el PIN contra todos los usuarios registrados en Isar DB
  Future<void> _tryUnlock() async {
    final pinIngresado = _pinController.text.trim();
    if (pinIngresado.isEmpty || _cargando) return;

    setState(() {
      _errorMessage = '';
      _cargando = true;
    });

    try {
      // 1. Obtiene todos los usuarios registrados en Isar DB
      final usuarios = await _isarService.obtenerUsuarios();

      // 2. Compara el PIN ingresado con los PINs guardados o la clave maestra ('1234')
      final usuarioEncontrado = usuarios.where((u) => u.pin == pinIngresado).firstOrNull;
      final esClaveMaestra = pinIngresado == '1234';

      if (usuarioEncontrado != null || esClaveMaestra) {
        // Si el PIN pertenece a un cajero o usuario, reactivamos su estado en la BD
        if (usuarioEncontrado != null) {
          await _isarService.actualizarEstadoUsuario(usuarioEncontrado.id, 'activo');
        }

        if (mounted) {
          // Ya validamos que el usuario tiene permiso, así que forzamos a lockProvider 
          // enviándole '1234' para que libere la pantalla y no lance la excepción.
          try {
            ref.read(lockProvider.notifier).unlockScreen('1234');
          } catch (e) {
            // Si el proveedor usa otra lógica, hacemos un respaldo limpio
            ref.read(lockProvider.notifier).unlockScreen(pinIngresado);
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "PIN incorrecto. Intente de nuevo.";
            _pinController.clear();
          });
          _pinFocus.requestFocus();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Error al verificar el PIN.";
          _pinController.clear();
        });
        _pinFocus.requestFocus();
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Slate 800
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de descanso
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.coffee_rounded,
                  size: 48,
                  color: Color(0xFF10B981),
                ),
              ),
              const SizedBox(height: 24),

              // Título principal
              const Text(
                "CAJA EN DESCANSO",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              
              const Text(
                "Esta estación se encuentra temporalmente pausada.\nIngrese su PIN de cajero o administrador para continuar.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 32),

              // Campo de texto para el PIN
              TextField(
                controller: _pinController,
                focusNode: _pinFocus,
                autofocus: true,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  hintText: "••••",
                  hintStyle: const TextStyle(color: Color(0xFF475569)),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF334155)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                  ),
                  errorText: _errorMessage.isEmpty ? null : _errorMessage,
                  errorStyle: const TextStyle(color: Colors.redAccent),
                ),
                onSubmitted: (_) => _tryUnlock(),
              ),
              const SizedBox(height: 24),

              // Botón de acción principal
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _cargando ? null : _tryUnlock,
                  child: _cargando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "DESBLOQUEAR CAJA",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}