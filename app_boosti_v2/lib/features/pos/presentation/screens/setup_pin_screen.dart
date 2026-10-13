// lib/features/pos/presentation/screens/setup_pin_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/security/secure_credentials.dart';
import '../providers/usuario_provider.dart';
import '../services/error_service.dart';
import '../utils/responsive_helper.dart';

/// Pantalla obligatoria post-signup. Bloquea el acceso al POS hasta que el
/// usuario configura un PIN.
///
/// Sin esto, el usuario nuevo queda con `pin = ''` en `UsuarioEntity`, y
/// `IsarService.validarLogin` hace `if (storedPin.isEmpty) continue;`:
/// el usuario desaparece del resultado de validación y el lock screen
/// (`RestScreen`) le responde "PIN incorrecto" para siempre, sin salida
/// (no hay botón de cerrar sesión ni de "olvidé mi PIN"). Un primer bloqueo
/// por inactividad lo dejaba soft-loqueado para siempre.
///
/// No tiene "Más tarde" ni "Cancelar": es bloqueante a propósito.
class SetupPinScreen extends ConsumerStatefulWidget {
  /// A dónde ir cuando el PIN quedó guardado.
  final Widget? destino;

  const SetupPinScreen({super.key, this.destino});

  @override
  ConsumerState<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends ConsumerState<SetupPinScreen> {
  final TextEditingController _pinCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();
  final FocusNode _pinFocus = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _guardando = false;
  String? _errorInterno;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _pinFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    _confirmCtrl.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  /// Mensaje de error del campo "Nuevo PIN".
  ///
  /// Usa `SecureCredentials.validatePin`, que es la MISMA validación que
  /// aplica `CashierPinChangeDialog` al cambiar el PIN más tarde. Así el
  /// usuario no puede elegir acá un PIN que después le sería rechazado.
  String? _validarPin(String? valor) {
    final v = (valor ?? '').trim();
    if (v.isEmpty) return 'Ingresá un PIN';

    final resultado = SecureCredentials.validatePin(v);
    if (!resultado.isValid) return resultado.error;

    return null;
  }

  bool _coinciden() {
    final a = _pinCtrl.text.trim();
    final b = _confirmCtrl.text.trim();
    return a.isNotEmpty && a == b;
  }

  Future<void> _guardar() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (!_coinciden()) {
      setState(() => _errorInterno = 'Los PIN no coinciden.');
      return;
    }

    setState(() {
      _guardando = true;
      _errorInterno = null;
    });

    final pin = _pinCtrl.text.trim();

    try {
      // Offline-first: `cambiarPin` hashea con salt nuevo, guarda en Isar
      // con `sincronizado = false`, y solo después propaga a Supabase si
      // hay sesión. Si la red falla, el PIN queda igual y se sube en el
      // próximo sync.
      final resultado = await ref
          .read(usuarioActualProvider.notifier)
          .cambiarPin(pin);

      if (!mounted) return;

      if (!resultado.exito) {
        setState(() {
          _guardando = false;
          _errorInterno = resultado.mensaje;
        });
        return;
      }

      debugPrint('🔐 PIN configurado en el onboarding');

      final destino = widget.destino;
      if (destino == null) {
        // Nadie pasó destino: volver atrás es lo menos invasivo. Esta
        // pantalla nunca deberíaarse reachable sin destino.
        Navigator.of(context).popUntil((r) => r.isFirst);
        return;
      }

      // `pushAndRemoveUntil` → no se puede volver atrás con el gesto de
      // Android y volver a caer en el PIN obligatorio.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => destino),
        (_) => false,
      );
    } catch (e, stack) {
      ErrorService.captureError(
        e,
        stack: stack,
        hint: 'setupPin_guardar_fallo',
      );
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _errorInterno = 'No se pudo guardar el PIN. Intentá de nuevo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardWidth = isMobile ? double.infinity : 440.0;

    // El botón se habilita solo cuando los dos campos están completos,
    // coinciden y el PIN pasa la validación de fuerza.
    final habilitado =
        !_guardando && _coinciden() && _validarPin(_pinCtrl.text) == null;

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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Container(
              width: cardWidth,
              padding: EdgeInsets.all(isMobile ? 24.0 : 32.0),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Ícono ──
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_person_rounded,
                          size: 36,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Títulos ──
                    Text(
                      'Configurá tu PIN',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 26,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Elegí un PIN de 4 a 6 dígitos. Lo vas a necesitar '
                      'para desbloquear la pantalla cuando la tablet se '
                      'pause.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // ── Nuevo PIN ──
                    TextFormField(
                      controller: _pinCtrl,
                      focusNode: _pinFocus,
                      enabled: !_guardando,
                      autofocus: true,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Nuevo PIN',
                        hintText: '••••',
                        counterText: '',
                        prefixIcon: const Icon(Icons.password_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: _validarPin,
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) {
                        if (!_guardando) FocusScope.of(context).nextFocus();
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Confirmar PIN ──
                    TextFormField(
                      controller: _confirmCtrl,
                      enabled: !_guardando,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Confirmar PIN',
                        hintText: '••••',
                        counterText: '',
                        prefixIcon: const Icon(Icons.verified_user_rounded),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      validator: (valor) {
                        if ((valor ?? '').trim().isEmpty) {
                          return 'Repetí el PIN';
                        }
                        if (!_coinciden()) {
                          return 'Los PIN no coinciden';
                        }
                        return null;
                      },
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) {
                        if (habilitado) _guardar();
                      },
                    ),
                    const SizedBox(height: 12),

                    // ── Error no asociado a un campo ──
                    if (_errorInterno != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            size: 18,
                            color: Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorInterno!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                    // ── Acción ──
                    SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: habilitado ? _guardar : null,
                        icon: _guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(
                          _guardando ? 'Guardando…' : 'Guardar PIN',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
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
      ),
    );
  }
}
