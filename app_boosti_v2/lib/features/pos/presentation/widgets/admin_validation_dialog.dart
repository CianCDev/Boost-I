// lib/features/pos/presentation/widgets/admin_validation_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/log_entity.dart';
// ignore: unused_import
import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/permissions/roles.dart';
import '../providers/usuario_provider.dart';
import '../utils/responsive_helper.dart';
import 'common/dialog_header.dart';
import 'common/glass_dialog.dart';

/// Diálogo de autorización para acciones restringidas.
///
/// Valida contra los roles indicados en [allowedRoles]. Por defecto
/// acepta `admin` y `supervisor`.
///
/// Uso típico:
/// ```dart
/// final ok = await AdminValidationDialog.show(context, ref);
/// if (ok == true) { ... }
/// ```
class AdminValidationDialog extends ConsumerStatefulWidget {
  final List<UserRole> allowedRoles;

  /// Callback legacy (compatibilidad con código existente).
  final VoidCallback? onSuccess;
  final VoidCallback? onCancel;

  const AdminValidationDialog({
    super.key,
    this.allowedRoles = const [UserRole.admin, UserRole.supervisor],
    this.onSuccess,
    this.onCancel,
  });

  /// Helper estático que devuelve `true` si la validación pasó.
  /// Uso: `final ok = await AdminValidationDialog.show(context, ref);`
  static Future<bool?> show(
    BuildContext context,
    WidgetRef ref, {
    List<UserRole> allowedRoles = const [
      UserRole.admin,
      UserRole.supervisor,
    ],
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AdminValidationDialog(allowedRoles: allowedRoles),
    );
  }

  @override
  ConsumerState<AdminValidationDialog> createState() =>
      _AdminValidationDialogState();
}

class _AdminValidationDialogState extends ConsumerState<AdminValidationDialog> {
  static const _colorPrimary = Color(0xFF3B82F6);
  // ignore: unused_field
  static const _colorSuccess = Color(0xFF10B981);
  // ignore: unused_field
  static const _colorDanger = Color(0xFFEF4444);

  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _validar() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Ingresa el PIN de autorización.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final usuarios = await IsarService().obtenerUsuarios();

      // Buscamos un usuario activo cuyo PIN coincida y cuyo rol esté
      // en la lista permitida. No exponemos qué falló (rol vs PIN)
      // para no dar pistas a un atacante.
      final valido = usuarios.any((u) {
        if (!u.activo) return false;
        final role = UserRole.fromString(u.rol);
        if (!widget.allowedRoles.contains(role)) return false;
        return u.pin == pin;
      });

      if (!mounted) return;

      if (valido) {
        // Log de auditoría
        final usuarioActual = ref.read(usuarioActualProvider);
        await IsarService().guardarLog(
          LogEntity()
            ..accion = 'AUTORIZACION_ADMIN'
            ..usuarioNombre = usuarioActual?.nombre ?? 'Desconocido'
            ..usuarioRol = usuarioActual?.rol ?? '-'
            ..detalles =
                'Autorización aprobada para: ${_rolesLabel(widget.allowedRoles)}'
            ..fecha = DateTime.now()
            ..sincronizado = false,
        );

        if (!mounted) return;
        widget.onSuccess?.call();
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'PIN incorrecto o usuario sin permisos suficientes.';
        });
        _pinController.clear();
        _focusNode.requestFocus();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al validar. Intenta de nuevo.';
      });
    }
  }

  String _rolesLabel(List<UserRole> roles) {
    if (roles.isEmpty) return 'Ninguno';
    if (roles.length == 1) return roles.first.label;
    return roles.map((r) => r.label).join(' o ');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final rolesLabel = _rolesLabel(widget.allowedRoles);

    return GlassDialog(
      accentColor: _colorPrimary,
      maxWidth: 460,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 32,
        vertical: 24,
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            const DialogHeader(
              icon: Icons.shield_outlined,
              title: 'Autorización requerida',
              subtitle: 'Verifica tu identidad para continuar',
              color: _colorPrimary,
            ),
            const SizedBox(height: 20),

            // ── Info del permiso requerido ──
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: _colorPrimary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _colorPrimary.withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: _colorPrimary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Esta acción requiere autorización de: $rolesLabel',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Campo PIN ──
            TextField(
              controller: _pinController,
              focusNode: _focusNode,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              autofocus: true,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
                color: colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: 'PIN de autorización',
                hintText: '••••',
                hintStyle: TextStyle(
                  letterSpacing: 4,
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                counterText: '',
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : const Color(0xFFF9FAFB),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: _colorPrimary,
                ),
                errorText: _errorMessage,
                errorStyle: const TextStyle(fontSize: 11.5),
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
              onSubmitted: (_) => _validar(),
            ),
            const SizedBox(height: 20),

            // ── Botones ──
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            widget.onCancel?.call();
                            Navigator.of(context).pop(false);
                          },
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
                    onPressed: _isLoading ? null : _validar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
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
                              Icon(Icons.verified_user_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Validar',
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
}