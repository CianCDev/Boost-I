// lib/features/pos/presentation/widgets/change_company_password_dialog.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/Local/entities/log_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../utils/responsive_helper.dart';
import 'common/dialog_header.dart';
import 'common/glass_dialog.dart';

/// Diálogo para cambiar la contraseña de la cuenta de empresa (Supabase Auth).
///
/// Flujo:
///   1. Valida localmente que la contraseña nueva tenga al menos 6 caracteres
///      y coincida con la confirmación.
///   2. Re-autentica con [SupabaseClient.signInWithPassword] para verificar la
///      contraseña actual del usuario logueado.
///   3. Actualiza la contraseña con [SupabaseClient.updateUser].
class ChangeCompanyPasswordDialog extends StatefulWidget {
  /// Email de la cuenta. Si se omite se toma de la sesión de Supabase.
  final String? email;

  /// Usuario que ejecuta el cambio (para el log de auditoría).
  final UsuarioEntity? usuario;

  const ChangeCompanyPasswordDialog({
    super.key,
    this.email,
    this.usuario,
  });

  /// Helper estático para mostrar el diálogo y saber si hubo cambio.
  static Future<bool> show(
    BuildContext context, {
    String? email,
    UsuarioEntity? usuario,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ChangeCompanyPasswordDialog(
        email: email,
        usuario: usuario,
      ),
    );
    return result ?? false;
  }

  @override
  State<ChangeCompanyPasswordDialog> createState() =>
      _ChangeCompanyPasswordDialogState();
}

class _ChangeCompanyPasswordDialogState
    extends State<ChangeCompanyPasswordDialog> {
  static const _colorPrimary = Color(0xFF0EA5E9);
  static const _colorSuccess = Color(0xFF10B981);

  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  final _currentFocus = FocusNode();
  final _newFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _cargando = false;

  String? _errorCurrent;
  String? _errorNew;
  String? _errorConfirm;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    _currentFocus.dispose();
    _newFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  /// Mensaje en español para los errores de Supabase Auth.
  String _mensajeError(Object error) {
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      if (message.contains('invalid login credentials') ||
          message.contains('invalid credentials')) {
        return 'La contraseña actual es incorrecta.';
      }
      if (message.contains('password should be at least') ||
          message.contains('weak_password')) {
        return 'La contraseña nueva es demasiado débil.';
      }
      if (message.contains('same password')) {
        return 'La contraseña nueva debe ser distinta a la actual.';
      }
      if (message.contains('network') || message.contains('socket')) {
        return 'Sin conexión. Verifica tu internet e inténtalo de nuevo.';
      }
      return error.message;
    }
    return 'No se pudo actualizar la contraseña. Inténtalo de nuevo.';
  }

  Future<void> _guardar() async {
    final current = _currentController.text;
    final nueva = _newController.text;
    final confirmacion = _confirmController.text;

    setState(() {
      _errorCurrent = null;
      _errorNew = null;
      _errorConfirm = null;
    });

    if (current.isEmpty) {
      setState(() => _errorCurrent = 'Ingresa tu contraseña actual.');
      _currentFocus.requestFocus();
      return;
    }
    if (nueva.length < 6) {
      setState(() => _errorNew = 'Debe tener al menos 6 caracteres.');
      _newFocus.requestFocus();
      return;
    }
    if (nueva != confirmacion) {
      setState(() => _errorConfirm = 'Las contraseñas no coinciden.');
      _confirmFocus.requestFocus();
      return;
    }
    if (nueva == current) {
      setState(() => _errorNew = 'La contraseña nueva debe ser distinta.');
      _newFocus.requestFocus();
      return;
    }

    final email = widget.email?.trim().isNotEmpty == true
        ? widget.email!.trim()
        : Supabase.instance.client.auth.currentUser?.email;

    if (email == null || email.isEmpty) {
      setState(() => _errorCurrent =
          'No se encontró la sesión activa. Vuelve a iniciar sesión.');
      return;
    }

    setState(() => _cargando = true);

    try {
      final supabase = Supabase.instance.client;

      // 1) Verificar la contraseña actual re-autenticando la sesión.
      await supabase.auth.signInWithPassword(
        email: email,
        password: current,
      );

      // 2) Actualizar la contraseña de la cuenta.
      await supabase.auth.updateUser(
        UserAttributes(password: nueva),
      );

      if (!mounted) return;

      // Log de auditoría (no incluye la contraseña).
      try {
        await IsarService().guardarLog(
          LogEntity()
            ..accion = 'CAMBIO_CONTRASENA_EMPRESA'
            ..usuarioNombre = widget.usuario?.nombre ?? email
            ..usuarioRol = widget.usuario?.rol ?? 'admin'
            ..detalles = 'Cuenta: $email'
            ..fecha = DateTime.now()
            ..sincronizado = false,
        );
      } catch (_) {
        // El log no debe bloquear el cambio de contraseña.
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final mensaje = _mensajeError(error);
      setState(() {
        _cargando = false;
        if (error is AuthException &&
            (error.message.toLowerCase().contains('invalid login') ||
                error.message.toLowerCase().contains('invalid credentials'))) {
          _errorCurrent = mensaje;
        } else {
          _errorNew = mensaje;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return GlassDialog(
      accentColor: _colorPrimary,
      maxWidth: 480,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 24,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 20 : 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.password_rounded,
              title: 'Cambiar Contraseña de Empresa',
              subtitle: 'Acceso a la nube de Boosti POS',
              color: _colorPrimary,
            ),
            const SizedBox(height: 20),
            _buildPasswordField(
              controller: _currentController,
              focusNode: _currentFocus,
              label: 'Contraseña Actual',
              obscure: _obscureCurrent,
              errorText: _errorCurrent,
              colorScheme: colorScheme,
              isDark: isDark,
              autofocus: true,
              onToggleObscure: () =>
                  setState(() => _obscureCurrent = !_obscureCurrent),
              onSubmitted: (_) => _newFocus.requestFocus(),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _newController,
              focusNode: _newFocus,
              label: 'Nueva Contraseña',
              obscure: _obscureNew,
              errorText: _errorNew,
              colorScheme: colorScheme,
              isDark: isDark,
              onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
              onSubmitted: (_) => _confirmFocus.requestFocus(),
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmController,
              focusNode: _confirmFocus,
              label: 'Confirmar Nueva Contraseña',
              obscure: _obscureConfirm,
              errorText: _errorConfirm,
              colorScheme: colorScheme,
              isDark: isDark,
              onToggleObscure: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              onSubmitted: (_) => _guardar(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed:
                        _cargando ? null : () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: colorScheme.onSurfaceVariant,
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _cargando ? null : _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorSuccess,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Guardar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool obscure,
    required String? errorText,
    required ColorScheme colorScheme,
    required bool isDark,
    required VoidCallback onToggleObscure,
    required ValueChanged<String> onSubmitted,
    bool autofocus = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      autofocus: autofocus,
      autocorrect: false,
      enableSuggestions: false,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        errorStyle: const TextStyle(fontSize: 11.5),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF9FAFB),
        prefixIcon: const Icon(
          Icons.lock_outline_rounded,
          color: _colorPrimary,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: onToggleObscure,
          tooltip: obscure ? 'Mostrar' : 'Ocultar',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _colorPrimary, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      onSubmitted: onSubmitted,
    );
  }
}
