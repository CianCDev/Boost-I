// lib/features/pos/presentation/widgets/cambiar_pin_dialog.dart
import 'package:flutter/material.dart';

import '../../../../core/security/secure_credentials.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/log_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../utils/responsive_helper.dart';
import 'common/dialog_header.dart';
import 'common/glass_dialog.dart';

/// Diálogo unificado para cambio de PIN.
///
/// Usa `SecureCredentials.validatePin` para rechazar PINs triviales
/// (repetidos, secuenciales, año actual).
class PinChangeDialog extends StatefulWidget {
  final UsuarioEntity usuario;
  final IsarService isarService;
  final bool esAdmin;

  const PinChangeDialog({
    super.key,
    required this.usuario,
    required this.isarService,
    this.esAdmin = false,
  });

  /// Helper estático.
  static Future<bool> show(
    BuildContext context, {
    required UsuarioEntity usuario,
    required IsarService isarService,
    bool esAdmin = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PinChangeDialog(
        usuario: usuario,
        isarService: isarService,
        esAdmin: esAdmin,
      ),
    );
    return result ?? false;
  }

  @override
  State<PinChangeDialog> createState() => _PinChangeDialogState();
}

class _PinChangeDialogState extends State<PinChangeDialog> {
  static const _colorPrimary = Color(0xFF0EA5E9);
  static const _colorSuccess = Color(0xFF10B981);
  // ignore: unused_field
  // ignore: unused_field
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);

  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _newPinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();

  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;
  bool _mostrarPinActual = false;
  bool _cargando = false;
  String? _errorNewPin;
  String? _errorConfirmPin;

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    _newPinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    setState(() {
      _errorNewPin = null;
      _errorConfirmPin = null;
    });

    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    // Validación fuerte del PIN nuevo
    final validation = SecureCredentials.validatePin(newPin);
    if (!validation.isValid) {
      setState(() => _errorNewPin = validation.error);
      return;
    }

    // Coincidencia
    if (newPin != confirmPin) {
      setState(() => _errorConfirmPin = 'Los PINs no coinciden.');
      return;
    }

    // Evitar mismo PIN
    if (newPin == widget.usuario.pin) {
      setState(() => _errorNewPin = 'El PIN nuevo debe ser distinto al actual.');
      return;
    }

    setState(() => _cargando = true);

    try {
      final exito = await widget.isarService.cambiarClaveUsuario(
        widget.usuario.id,
        newPin,
      );

      if (!mounted) return;

      if (exito) {
        // Log de auditoría
        await IsarService().guardarLog(
          LogEntity()
            ..accion = 'CAMBIO_PIN'
            ..usuarioNombre = widget.usuario.nombre
            ..usuarioRol = widget.usuario.rol
            ..detalles = 'Usuario ID: ${widget.usuario.id}'
            ..fecha = DateTime.now()
            ..sincronizado = false,
        );

        if (!mounted) return;
        widget.usuario.pin = newPin;
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _cargando = false;
          _errorNewPin = 'No se pudo actualizar el PIN.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _errorNewPin = 'Error inesperado al guardar.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    final title = widget.esAdmin ? 'Cambiar PIN de Admin' : 'Cambiar PIN';
    final subtitle = widget.usuario.nombre;

    return GlassDialog(
      accentColor: _colorPrimary,
      maxWidth: 480,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 24,
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            DialogHeader(
              icon: Icons.lock_reset_rounded,
              title: title,
              subtitle: subtitle,
              color: _colorPrimary,
            ),
            const SizedBox(height: 20),

            // ── PIN actual (opcional, colapsable) ──
            _buildPinActualSection(colorScheme, isDark),
            const SizedBox(height: 16),

            // ── PIN nuevo ──
            _buildPinField(
              controller: _newPinController,
              focusNode: _newPinFocus,
              label: 'Nuevo PIN (4-6 dígitos)',
              obscure: _obscureNewPin,
              errorText: _errorNewPin,
              colorScheme: colorScheme,
              isDark: isDark,
              autofocus: true,
              onToggleObscure: () =>
                  setState(() => _obscureNewPin = !_obscureNewPin),
              onSubmitted: (_) => _confirmPinFocus.requestFocus(),
            ),
            const SizedBox(height: 16),

            // ── Confirmar PIN ──
            _buildPinField(
              controller: _confirmPinController,
              focusNode: _confirmPinFocus,
              label: 'Confirmar PIN',
              obscure: _obscureConfirmPin,
              errorText: _errorConfirmPin,
              colorScheme: colorScheme,
              isDark: isDark,
              onToggleObscure: () =>
                  setState(() => _obscureConfirmPin = !_obscureConfirmPin),
              onSubmitted: (_) => _guardar(),
            ),
            const SizedBox(height: 20),

            // ── Botones ──
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _cargando
                        ? null
                        : () => Navigator.pop(context, false),
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

  // ══════════════════════════════════════════════════════════════
  // HELPERS DE BUILD
  // ══════════════════════════════════════════════════════════════

  Widget _buildPinActualSection(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () =>
                setState(() => _mostrarPinActual = !_mostrarPinActual),
            icon: Icon(
              _mostrarPinActual
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 16,
            ),
            label: Text(
              _mostrarPinActual ? 'Ocultar PIN actual' : 'Ver PIN actual',
              style: const TextStyle(fontSize: 12),
            ),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
        if (_mostrarPinActual) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: _colorWarning.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _colorWarning.withValues(alpha: 0.30),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: _colorWarning,
                ),
                const SizedBox(width: 8),
                Text(
                  'PIN actual: ',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  widget.usuario.pin.isEmpty ? '—' : widget.usuario.pin,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPinField({
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
      keyboardType: TextInputType.number,
      maxLength: 6,
      autofocus: autofocus,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 4,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: '••••',
        hintStyle: TextStyle(
          letterSpacing: 4,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
        ),
        counterText: '',
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
            obscure
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
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
          borderSide: const BorderSide(
            color: _colorPrimary,
            width: 2,
          ),
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

// ══════════════════════════════════════════════════════════════════
// WRAPPERS DE COMPATIBILIDAD
// ══════════════════════════════════════════════════════════════════

class AdminPinChangeDialog extends StatelessWidget {
  final UsuarioEntity admin;
  final IsarService isarService;

  const AdminPinChangeDialog({
    super.key,
    required this.admin,
    required this.isarService,
  });

  @override
  Widget build(BuildContext context) {
    return PinChangeDialog(
      usuario: admin,
      isarService: isarService,
      esAdmin: true,
    );
  }
}

class CashierPinChangeDialog extends StatelessWidget {
  final UsuarioEntity cajero;
  final IsarService isarService;

  const CashierPinChangeDialog({
    super.key,
    required this.cajero,
    required this.isarService,
  });

  @override
  Widget build(BuildContext context) {
    return PinChangeDialog(
      usuario: cajero,
      isarService: isarService,
      esAdmin: false,
    );
  }
}