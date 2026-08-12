import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(_pinFocus);
    });
  }

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

      if (usuarioEncontrado != null) {
        await _isarService.actualizarEstadoUsuario(usuarioEncontrado.id, 'activo');
        if (mounted) {
          await ref.read(lockProvider.notifier).unlock();
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'PIN incorrecto. Intente de nuevo.';
            _pinController.clear();
            _pinController.text = '';
            _pinController.selection = TextSelection.collapsed(offset: 0);
          });
          _pinFocus.requestFocus();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error al verificar el PIN.';
          _pinController.clear();
          _pinController.text = '';
          _pinController.selection = TextSelection.collapsed(offset: 0);
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
    final cardWidth = isMobile ? double.infinity : (isTablet ? 500 : 600);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
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
            child: Container(
              width: cardWidth.toDouble(),
              padding: EdgeInsets.all(isMobile ? 24.0 : 40.0),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
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
                    child: Icon(
                      Icons.coffee_rounded,
                      size: 48,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
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
                    'Esta estación se encuentra temporalmente pausada.\n'
                    'Ingrese su PIN de cajero para continuar.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // TextField sin animaciones para evitar errores de batch edits
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextField(
                        controller: _pinController,
                        focusNode: _pinFocus,
                        obscureText: !_showPassword,
                        maxLength: 4,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 24,
                          letterSpacing: 8,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '••••',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          contentPadding: const EdgeInsets.symmetric(vertical: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: colorScheme.outline),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorText: _errorMessage.isEmpty ? null : _errorMessage,
                          errorStyle: TextStyle(color: colorScheme.error),
                        ),
                        onChanged: (_) {
                          // Limpiar error sin usar setState si ya está montado
                          if (_errorMessage.isNotEmpty && mounted) {
                            setState(() => _errorMessage = '');
                          }
                        },
                        onSubmitted: (_) => _tryUnlock(),
                        // Desactivación total para web/desktop
                        enableSuggestions: false,
                        autocorrect: false,
                        autofillHints: const <String>[],
                        enableIMEPersonalizedLearning: false,
                        textInputAction: TextInputAction.done,
                      ),
                      // Botón de visibilidad
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: IconButton(
                          icon: Icon(
                            _showPassword ? Icons.visibility : Icons.visibility_off,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _cargando ? null : _tryUnlock,
                      child: _cargando
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : Text(
                              'DESBLOQUEAR CAJA',
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