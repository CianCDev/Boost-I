import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/lock_provider.dart';
// TODO: Asegúrate de importar tu provider de sesión actual si lo tienes
// import '../providers/auth_provider.dart'; 
import '../../data/Local/entities/isar_service.dart';
import '../utils/responsive_helper.dart';

  class RestScreen extends ConsumerStatefulWidget {
  const RestScreen({super.key}); // <-- Eliminamos el required Stack child

  @override
  ConsumerState<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends ConsumerState<RestScreen> with SingleTickerProviderStateMixin {
  final IsarService _isarService = IsarService();
  final FocusNode _keyboardFocus = FocusNode();
  
  String _enteredPin = '';
  String _errorMessage = '';
  bool _cargando = false;
  int _failedAttempts = 0;
  bool _isLockedOut = false;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Configuración de la animación de sacudida (Shake Effect)
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: 12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12, end: -12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -12, end: 12), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 12, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _keyboardFocus.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerError(String message) {
    setState(() {
      _errorMessage = message;
      _enteredPin = ''; // Limpieza segura de memoria
      _failedAttempts++;
    });
    _shakeController.forward(from: 0.0);

    // Bloqueo temporal tras 5 intentos fallidos
    if (_failedAttempts >= 5) {
      setState(() => _isLockedOut = true);
      Timer(const Duration(seconds: 30), () {
        if (mounted) {
          setState(() {
            _isLockedOut = false;
            _failedAttempts = 0;
            _errorMessage = '';
          });
          _keyboardFocus.requestFocus();
        }
      });
    }
  }

  Future<void> _tryUnlock() async {
    if (_enteredPin.length != 4 || _cargando || _isLockedOut) return;

    setState(() {
      _errorMessage = '';
      _cargando = true;
    });

    try {
      final usuarios = await _isarService.obtenerUsuarios();
      
      // 🔒 Validamos que el PIN exista en la base de datos
      final usuarioEncontrado = usuarios.where((u) => u.pin == _enteredPin).firstOrNull;

      if (usuarioEncontrado != null) {
        // 🛡️ RECOMENDACIÓN DE SEGURIDAD: Verifica si este usuario es el que inició la sesión
        // Ejemplo con un provider ficticio (descomenta y adapta según tu código):
        // final usuarioLogueado = ref.read(currentUserProvider);
        // if (usuarioEncontrado.id != usuarioLogueado?.id) {
        //   _triggerError('Este PIN no pertenece al cajero activo.');
        //   setState(() => _cargando = false);
        //   return;
        // }

        await _isarService.actualizarEstadoUsuario(usuarioEncontrado.id, 'activo');
        if (mounted) {
          _enteredPin = ''; // Borrado de seguridad
          await ref.read(lockProvider.notifier).unlock();
        }
      } else {
        if (mounted) _triggerError('PIN incorrecto. Intente de nuevo.');
      }
    } catch (e) {
      if (mounted) _triggerError('Error de verificación. Revise el sistema.');
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _onDigitPressed(String digit) {
    if (_enteredPin.length < 4 && !_isLockedOut && !_cargando) {
      setState(() {
        _enteredPin += digit;
        _errorMessage = '';
      });
      if (_enteredPin.length == 4) _tryUnlock();
    }
  }

  void _onBackspacePressed() {
    if (_enteredPin.isNotEmpty && !_isLockedOut && !_cargando) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = '';
      });
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        _onBackspacePressed();
        return KeyEventResult.handled;
      }
      if (event.character != null && RegExp(r'^[0-9]$').hasMatch(event.character!)) {
        _onDigitPressed(event.character!);
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final cardWidth = isMobile ? double.infinity : 400.0;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Focus(
        focusNode: _keyboardFocus,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surfaceContainerHighest.withValues(alpha: 0.8),
                      colorScheme.primaryContainer,
                    ],
                  )
                : const LinearGradient(
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
              child: AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value, 0),
                    child: child,
                  );
                },
                child: Container(
                  width: cardWidth,
                  padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: _errorMessage.isNotEmpty 
                        ? Border.all(color: colorScheme.error, width: 2) 
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.25),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.coffee_rounded, size: 48, color: colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'CAJA EN DESCANSO',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLockedOut 
                            ? 'Demasiados intentos fallidos.\nEspere 30 segundos.'
                            : 'Esta estación se encuentra pausada.\nIngrese su PIN para continuar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _isLockedOut ? colorScheme.error : colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: _isLockedOut ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Indicadores Visuales del PIN (Círculos)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < _enteredPin.length;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isFilled 
                                  ? (_errorMessage.isNotEmpty ? colorScheme.error : colorScheme.primary) 
                                  : Colors.transparent,
                              border: Border.all(
                                color: _errorMessage.isNotEmpty 
                                    ? colorScheme.error
                                    : (isFilled ? colorScheme.primary : colorScheme.outline),
                                width: 2,
                              ),
                            ),
                          );
                        }),
                      ),
                      
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage,
                          style: TextStyle(color: colorScheme.error, fontSize: 13),
                        ),
                      ],
                      
                      const SizedBox(height: 32),

                      // Teclado Numérico Virtual
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          if (index == 9) return const SizedBox(); // Espacio vacío
                          if (index == 11) {
                            // Botón de borrar
                            return _NumpadButton(
                              icon: Icons.backspace_outlined,
                              onPressed: _onBackspacePressed,
                              isDisabled: _isLockedOut || _cargando,
                            );
                          }
                          // Botones numéricos 0-9
                          final digit = index == 10 ? '0' : '${index + 1}';
                          return _NumpadButton(
                            label: digit,
                            onPressed: () => _onDigitPressed(digit),
                            isDisabled: _isLockedOut || _cargando,
                          );
                        },
                      ),
                      
                      if (_cargando) ...[
                        const SizedBox(height: 20),
                        CircularProgressIndicator(color: colorScheme.primary),
                      ]
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
}

// Widget auxiliar para los botones del teclado
class _NumpadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool isDisabled;

  const _NumpadButton({
    this.label,
    this.icon,
    required this.onPressed,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onPressed,
        borderRadius: BorderRadius.circular(16),
        splashColor: colorScheme.primary.withValues(alpha: 0.2),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: colorScheme.onSurface, size: 28)
                : Text(
                    label!,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}