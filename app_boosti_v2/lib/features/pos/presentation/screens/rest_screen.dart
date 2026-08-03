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
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final double cardWidth = isMobile ? double.infinity : (isTablet ? 500 : 600);

    // Colores dinámicos para el contenedor interno
    final Color cardBgColor = theme.cardColor.withOpacity(0.98);
    final Color cardShadowColor = Colors.black.withOpacity(0.25);
    final Color titleColor = theme.textTheme.bodyLarge?.color ?? const Color(0xFF0F172A);
    final Color subtitleColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.8) ?? const Color(0xFF64748B);
    final Color inputTextColor = theme.textTheme.bodyLarge?.color ?? const Color(0xFF0F172A);
    final Color inputHintColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.5) ?? const Color(0xFF94A3B8);
    final Color inputFillColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade800
        : const Color(0xFFF8FAFC);
    final Color inputBorderColor = theme.brightness == Brightness.dark
        ? Colors.grey.shade700
        : const Color(0xFFCBD5E1);
    final Color inputFocusedBorderColor = const Color(0xFF10B981);
    final Color errorTextColor = theme.colorScheme.error;

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
                color: cardBgColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: cardShadowColor,
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
                border: Border.all(
                  color: theme.brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.coffee_rounded,
                      size: 48,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "CAJA EN DESCANSO",
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Esta estación se encuentra temporalmente pausada.\nIngrese su PIN de cajero o administrador para continuar.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _pinController,
                    focusNode: _pinFocus,
                    autofocus: true,
                    obscureText: true,
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    enableSuggestions: false,   // 👈 Desactiva autocompletado
                    autocorrect: false,         // 👈 Desactiva autocorrección
                    style: TextStyle(
                      color: inputTextColor,
                      fontSize: 24,
                      letterSpacing: 8,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "••••",
                      hintStyle: TextStyle(
                        color: inputHintColor,
                      ),
                      filled: true,
                      fillColor: inputFillColor,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: inputFocusedBorderColor, width: 2),
                      ),
                      errorText: _errorMessage.isEmpty ? null : _errorMessage,
                      errorStyle: TextStyle(
                        color: errorTextColor,
                      ),
                    ),
                    onSubmitted: (_) => _tryUnlock(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
        ),
      ),
    );
  }
}