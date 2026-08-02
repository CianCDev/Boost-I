import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lock_provider.dart';
import '../../data/Local/entities/isar_service.dart';
import '../utils/responsive_helper.dart';

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

  Future<void> _tryUnlock() async {
    final pinIngresado = _pinController.text.trim();
    if (pinIngresado.isEmpty || _cargando) return;

    setState(() {
      _errorMessage = '';
      _cargando = true;
    });

    try {
      final usuarios = await _isarService.obtenerUsuarios();
      final usuarioEncontrado = usuarios.where((u) => u.pin == pinIngresado).firstOrNull;
      final esClaveMaestra = pinIngresado == '1234';

      if (usuarioEncontrado != null || esClaveMaestra) {
        if (usuarioEncontrado != null) {
          await _isarService.actualizarEstadoUsuario(usuarioEncontrado.id, 'activo');
        }
        if (mounted) {
          try {
            ref.read(lockProvider.notifier).unlockScreen('1234');
          } catch (e) {
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
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final double cardWidth = isMobile ? double.infinity : (isTablet ? 500 : 600);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(122, 153, 255, 1),
              Color.fromARGB(255, 85, 59, 235),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Container(
              width: cardWidth,
              padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.98),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 40, offset: const Offset(0, 20))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), shape: BoxShape.circle), child: const Icon(Icons.coffee_rounded, size: 48, color: Color(0xFF10B981))),
                  const SizedBox(height: 24),
                  const Text("CAJA EN DESCANSO", style: TextStyle(color: Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 8),
                  const Text("Esta estación se encuentra temporalmente pausada.\nIngrese su PIN de cajero o administrador para continuar.", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _pinController,
                    focusNode: _pinFocus,
                    autofocus: true,
                    obscureText: true,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF0F172A), fontSize: 24, letterSpacing: 8),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "••••",
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
                      errorText: _errorMessage.isEmpty ? null : _errorMessage,
                      errorStyle: const TextStyle(color: Colors.redAccent),
                    ),
                    onSubmitted: (_) => _tryUnlock(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _cargando ? null : _tryUnlock,
                      child: _cargando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text("DESBLOQUEAR CAJA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}