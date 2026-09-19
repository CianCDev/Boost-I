// lib/features/pos/presentation/widgets/gestion_personal_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../data/Local/entities/log_entity.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';
import '../providers/usuario_provider.dart';
import '../providers/tenant_provider.dart';
import '../utils/tenant_utils.dart';
import 'common/glass_dialog.dart';
import 'common/persona_form_template.dart';
// ignore: unused_import
import 'common/status_badge.dart';

class PersonnelManagementDialog extends ConsumerStatefulWidget {
  const PersonnelManagementDialog({super.key});

  @override
  ConsumerState<PersonnelManagementDialog> createState() =>
      _PersonnelManagementDialogState();
}

class _PersonnelManagementDialogState
    extends ConsumerState<PersonnelManagementDialog>
    with SingleTickerProviderStateMixin {
  // ── Form state ──
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();

  String _rolSeleccionado = 'cajero';
  bool _guardando = false;
  bool _obscurePassword = true;

  // ── Lista ──
  List<UsuarioEntity> _usuarios = [];
  bool _cargando = true;

  late TabController _tabController;

  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);

  // ═══════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarUsuarios();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═══════════════════════════════════════════════════════════════

  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  String _getPasswordStrength(String password) {
    if (password.isEmpty) return '';
    final length = password.length;
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));

    int score = 0;
    if (length >= 8) score++;
    if (hasLowercase && hasUppercase) score++;
    if (hasDigits) score++;
    if (hasSpecial) score++;

    if (length < 6) return 'Débil';
    if (score <= 2) return 'Media';
    return 'Fuerte';
  }

  Color _getPasswordColor(String strength) {
    switch (strength) {
      case 'Débil':
        return _colorDanger;
      case 'Media':
        return _colorWarning;
      case 'Fuerte':
        return _colorSuccess;
      default:
        return Colors.grey;
    }
  }

  int _getPasswordScore(String password) {
    switch (_getPasswordStrength(password)) {
      case 'Débil':
        return 1;
      case 'Media':
        return 2;
      case 'Fuerte':
        return 3;
      default:
        return 0;
    }
  }

  IconData _getPasswordIcon(String strength) {
    switch (strength) {
      case 'Débil':
        return Icons.error_outline_rounded;
      case 'Media':
        return Icons.warning_amber_rounded;
      case 'Fuerte':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CARGA DE DATOS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _cargarUsuarios() async {
    setState(() => _cargando = true);
    try {
      final usuarios = await _isarService.obtenerUsuarios();
      if (!mounted) return;
      setState(() {
        _usuarios = usuarios;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      _snack('Error al cargar usuarios: $e', _colorDanger);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CREAR USUARIO
  // ═══════════════════════════════════════════════════════════════

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text.trim();
    final strength = _getPasswordStrength(password);
    if (strength == 'Débil' && password.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Contraseña débil'),
          content: const Text(
              'La contraseña es débil. ¿Deseas continuar de todos modos? '
              'Se recomienda usar al menos 6 caracteres con números y letras.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorWarning,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    setState(() => _guardando = true);

    try {
      final supabase = Supabase.instance.client;
      final tenantId =
          ref.read(tenantActualProvider).tenantId ?? getTenantIdFromJWT();

      if (tenantId == null) {
        throw Exception(
            'No hay tenant activo. Vuelve a iniciar sesión antes de crear usuarios.');
      }

      final pinHasheado = _hashPin(_pinController.text.trim());

      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: password,
        data: {
          'nombre': _nombreController.text.trim(),
          'rol': _rolSeleccionado,
          'pin': pinHasheado,
          'tenant_id': tenantId,
        },
      );

      if (response.user == null) {
        throw Exception(
            'No se pudo crear el usuario. Verifica que el email no esté registrado.');
      }

      final nuevoUsuario = UsuarioEntity()
        ..nombre = _nombreController.text.trim()
        ..email = _emailController.text.trim()
        ..password = password
        ..pin = pinHasheado
        ..rol = _rolSeleccionado
        ..estado = 'inactivo'
        ..activo = true
        ..supabaseId = response.user!.id
        ..tenantId = tenantId
        ..cajaAsignada = '';

      await _isarService.guardarUsuario(nuevoUsuario);

      await _isarService.guardarLog(
        LogEntity()
          ..accion = 'CREAR_USUARIO'
          ..usuarioNombre = 'Admin'
          ..usuarioRol = 'admin'
          ..detalles =
              'Usuario: ${_nombreController.text} - Rol: $_rolSeleccionado - Email: ${_emailController.text}'
          ..fecha = DateTime.now()
          ..sincronizado = false,
      );

      if (!mounted) return;

      setState(() {
        _nombreController.clear();
        _emailController.clear();
        _passwordController.clear();
        _pinController.clear();
        _rolSeleccionado = 'cajero';
        _guardando = false;
      });

      await _cargarUsuarios();
      if (!mounted) return;
      _snack('✅ Usuario creado correctamente', _colorSuccess);
    } catch (e) {
      if (!mounted) return;
      setState(() => _guardando = false);

      String mensaje;
      if (e is AuthWeakPasswordException) {
        mensaje =
            '❌ Contraseña demasiado débil. Debe tener al menos 6 caracteres.';
      } else if (e.toString().contains('email')) {
        mensaje = '❌ El email ya está registrado.';
      } else {
        mensaje = '❌ $e';
      }
      _snack(mensaje, _colorDanger);
    }
  }

 Future<void> _editarUsuario(UsuarioEntity usuario) async {
  final nombreController = TextEditingController(text: usuario.nombre);
  final emailController = TextEditingController(text: usuario.email ?? '');
  final passwordController = TextEditingController();
  // PIN vacío al editar para no cargar el hash SHA-256 de 64 chars.
  final pinController = TextEditingController();
  String rolSeleccionado = usuario.rol;

  final formKey = GlobalKey<FormState>();
  bool editando = false;
  bool obscureEditPassword = true;

  await showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setStateDialog) {
        final colorScheme = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GlassDialog(
          maxWidth: 560,
          scrollable: true,
          accentColor: _colorPrimary,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ═══ HEADER ═══
                  _buildEditHeader(context, usuario.nombre, colorScheme),
                  const SizedBox(height: 22),

                  // ═══ SECCIÓN: DATOS PERSONALES ═══
                  FormSection(
                    title: 'Datos personales',
                    icon: Icons.person_rounded,
                    accentColor: _colorPrimary,
                    children: [
                      PersonaTextField(
                        controller: nombreController,
                        label: 'Nombre *',
                        icon: Icons.person_outline_rounded,
                        accentColor: _colorPrimary,
                        textCapitalization: TextCapitalization.words,
                        enabled: !editando,
                        validator: (v) =>
                            v?.trim().isNotEmpty == true ? null : 'Requerido',
                      ),
                      const SizedBox(height: 14),
                      PersonaTextField(
                        controller: emailController,
                        label: 'Correo electrónico *',
                        icon: Icons.email_rounded,
                        accentColor: _colorPrimary,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !editando,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requerido';
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                              .hasMatch(v.trim())) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ═══ SECCIÓN: SEGURIDAD ═══
                  FormSection(
                    title: 'Seguridad',
                    icon: Icons.lock_rounded,
                    accentColor: _colorPrimary,
                    children: [
                      // ── Password con toggle (usa InputDecoration custom) ──
                      TextFormField(
                        controller: passwordController,
                        enabled: !editando,
                        obscureText: obscureEditPassword,
                        onChanged: (_) => setStateDialog(() {}),
                        style: TextStyle(color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Nueva contraseña (opcional)',
                          hintText: 'Dejar vacío para no cambiarla',
                          labelStyle:
                              TextStyle(color: colorScheme.onSurfaceVariant),
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                            fontSize: 12.5,
                          ),
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: _colorPrimary,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureEditPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () => setStateDialog(
                              () => obscureEditPassword = !obscureEditPassword,
                            ),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: _colorPrimary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                      ),
                      if (passwordController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _PasswordStrengthIndicator(
                          password: passwordController.text,
                          strength: _getPasswordStrength(
                              passwordController.text),
                          score:
                              _getPasswordScore(passwordController.text),
                          color: _getPasswordColor(
                              _getPasswordStrength(passwordController.text)),
                          icon: _getPasswordIcon(
                              _getPasswordStrength(passwordController.text)),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // ── PIN (opcional al editar) ──
                      PersonaTextField(
                        controller: pinController,
                        label: 'Nuevo PIN (opcional)',
                        icon: Icons.pin_rounded,
                        accentColor: _colorPrimary,
                        keyboardType: TextInputType.number,
                        enabled: !editando,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return null;
                          if (v.trim().length != 4 ||
                              int.tryParse(v.trim()) == null) {
                            return 'Debe ser 4 dígitos numéricos';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ═══ SECCIÓN: PERMISOS ═══
                  FormSection(
                    title: 'Permisos',
                    icon: Icons.assignment_ind_rounded,
                    accentColor: _colorPrimary,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: rolSeleccionado,
                        isExpanded: true,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Rol',
                          labelStyle:
                              TextStyle(color: colorScheme.onSurfaceVariant),
                          prefixIcon: const Icon(
                            Icons.assignment_ind_rounded,
                            color: _colorPrimary,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.04)
                              : const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: _colorPrimary, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                        ),
                        dropdownColor: colorScheme.surface,
                        items: const [
                          DropdownMenuItem(
                            value: 'admin',
                            child: Row(
                              children: [
                                Icon(Icons.admin_panel_settings_rounded,
                                    color: Color(0xFF3B82F6), size: 18),
                                SizedBox(width: 8),
                                Text('Administrador'),
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'cajero',
                            child: Row(
                              children: [
                                Icon(Icons.person_rounded,
                                    color: Color(0xFF10B981), size: 18),
                                SizedBox(width: 8),
                                Text('Cajero'),
                              ],
                            ),
                          ),
                        ],
                        onChanged: editando
                            ? null
                            : (val) {
                                if (val != null) {
                                  setStateDialog(
                                      () => rolSeleccionado = val);
                                }
                              },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ═══ ACCIONES ═══
                  FormActions(
                    isSaving: editando,
                    confirmLabel: 'Guardar Cambios',
                    accentColor: _colorPrimary,
                    onCancel: () => Navigator.pop(dialogContext),
                    onConfirm: () async {
                      if (!formKey.currentState!.validate()) return;
                      setStateDialog(() => editando = true);

                      try {
                        final newPassword = passwordController.text.trim();
                        final newPin = pinController.text.trim();

                        if (newPassword.isNotEmpty) {
                          final strength = _getPasswordStrength(newPassword);
                          if (strength == 'Débil') {
                            final confirm = await showDialog<bool>(
                              context: dialogContext,
                              builder: (ctx) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: const Text('Contraseña débil'),
                                content: const Text(
                                    'La nueva contraseña es débil. ¿Deseas continuar de todos modos?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _colorWarning,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Continuar'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm != true) {
                              setStateDialog(() => editando = false);
                              return;
                            }
                          }
                        }

                        usuario.nombre = nombreController.text.trim();
                        usuario.email = emailController.text.trim();
                        usuario.rol = rolSeleccionado;

                        if (newPin.isNotEmpty) {
                          usuario.pin = _hashPin(newPin);
                        }
                        if (newPassword.isNotEmpty) {
                          usuario.password = newPassword;
                        }
                        await _isarService.guardarUsuario(usuario);

                        if (usuario.supabaseId != null &&
                            usuario.supabaseId!.isNotEmpty) {
                          final supabase = Supabase.instance.client;
                          final Map<String, dynamic> updateData = {
                            'nombre': usuario.nombre,
                            'rol': usuario.rol,
                            'email': usuario.email,
                            'updated_at':
                                DateTime.now().toIso8601String(),
                          };
                          // Solo envía el PIN si fue modificado
                          if (newPin.isNotEmpty) {
                            updateData['pin'] = usuario.pin;
                          }
                          await supabase
                              .from('usuarios')
                              .update(updateData)
                              .eq('id', usuario.supabaseId!);
                        }

                        await _syncService
                            .sincronizarUsuariosASupabase();

                        if (!mounted) return;
                        Navigator.pop(dialogContext);
                        _snack('✅ Usuario actualizado correctamente',
                            _colorSuccess);
                        await _cargarUsuarios();
                      } catch (e) {
                        if (!mounted) return;
                        setStateDialog(() => editando = false);
                        _snack('❌ Error al actualizar: $e', _colorDanger);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
Widget _buildEditHeader(
  BuildContext context,
  String nombre,
  ColorScheme colorScheme,
) {
  return Row(
    children: [
      Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _colorPrimary,
              Color.lerp(_colorPrimary, Colors.black, 0.15)!,
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: _colorPrimary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.edit_rounded,
          color: Colors.white,
          size: 22,
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Editar Usuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colorScheme.onSurface,
                letterSpacing: -0.4,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              nombre,
              style: TextStyle(
                fontSize: 12.5,
                color: colorScheme.onSurfaceVariant,
                height: 1.3,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.close_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          tooltip: 'Cerrar',
        ),
      ),
    ],
  );
}

  // ═══════════════════════════════════════════════════════════════
  // ELIMINAR USUARIO
  // ═══════════════════════════════════════════════════════════════

  Future<void> _eliminarUsuario(UsuarioEntity usuario) async {
    final usuarioActual = ref.read(usuarioActualProvider);
    if (usuarioActual != null && usuarioActual.id == usuario.id) {
      _snack('⚠️ No puedes eliminar tu propio usuario.', _colorWarning);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar Usuario'),
        content: Text(
            '¿Estás seguro de eliminar a "${usuario.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorDanger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _isarService.eliminarUsuario(usuario.id);
      await _syncService.eliminarUsuarioEnSupabase(usuario.id);
      await _cargarUsuarios();
      await _isarService.guardarLog(
        LogEntity()
          ..accion = 'ELIMINAR_USUARIO'
          ..usuarioNombre = 'Admin'
          ..usuarioRol = 'admin'
          ..detalles = 'Usuario: ${usuario.nombre} (ID: ${usuario.id})'
          ..fecha = DateTime.now()
          ..sincronizado = false,
      );
      if (!mounted) return;
      _snack('✅ Usuario eliminado', _colorSuccess);
    } catch (e) {
      if (!mounted) return;
      _snack('❌ Error al eliminar: $e', _colorDanger);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LIMPIAR HUÉRFANOS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _limpiarUsuariosHuerfanos() async {
    final usuarios = await _isarService.obtenerUsuarios();
    int eliminados = 0;
    int limpiados = 0;

    for (var u in usuarios) {
      if (u.email == null || u.email!.isEmpty) {
        if (u.nombre.contains('Administrador') ||
            u.nombre.contains('Admin')) {
          debugPrint(
              '⚠️ Admin sin email: ${u.nombre} (ID: ${u.id}) - asignar email manualmente.');
          continue;
        }
        await _isarService.eliminarUsuario(u.id);
        eliminados++;
        continue;
      }

      if (u.supabaseId != null && u.supabaseId!.isNotEmpty) {
        try {
          await Supabase.instance.client.auth.admin
              .getUserById(u.supabaseId!);
        } catch (e) {
          u.supabaseId = null;
          await _isarService.guardarUsuario(u);
          limpiados++;
        }
      }
    }

    if (!mounted) return;
    _snack(
      '🧹 Limpieza: $eliminados eliminados, $limpiados corregidos.',
      _colorSuccess,
    );
    await _cargarUsuarios();
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(msg,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 720,
      maxHeightFactor: 0.92,
      accentColor: _colorPrimary,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: 24,
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══ HEADER ═══
            _buildHeader(context, isMobile),
            const SizedBox(height: 12),

            // ═══ TABS ═══
            _buildTabs(colorScheme),
            const SizedBox(height: 8),

            // ═══ CONTENIDO ═══
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFormTab(isMobile, colorScheme),
                  _buildListTab(isMobile, colorScheme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context, bool isMobile) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _colorPrimary,
                Color.lerp(_colorPrimary, Colors.black, 0.15)!,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: _colorPrimary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.admin_panel_settings_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Personal',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.4,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Administración de accesos al sistema POS',
                style: TextStyle(
                  fontSize: 12.5,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
            tooltip: 'Cerrar',
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TABS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildTabs(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: _colorPrimary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: _colorPrimary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        splashBorderRadius: BorderRadius.circular(10),
        tabs: const [
          Tab(
            height: 40,
            icon: Icon(Icons.person_add_rounded, size: 16),
            iconMargin: EdgeInsets.zero,
            text: 'Datos',
          ),
          Tab(
            height: 40,
            icon: Icon(Icons.people_rounded, size: 16),
            iconMargin: EdgeInsets.zero,
            text: 'Lista',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB: FORMULARIO
  // ═══════════════════════════════════════════════════════════════

  Widget _buildFormTab(bool isMobile, ColorScheme colorScheme) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ═══ SECCIÓN: DATOS PERSONALES ═══
            FormSection(
              title: 'Datos personales',
              icon: Icons.person_rounded,
              accentColor: _colorPrimary,
              children: [
                PersonaTextField(
                  controller: _nombreController,
                  label: 'Nombre completo *',
                  icon: Icons.person_outline_rounded,
                  accentColor: _colorPrimary,
                  textCapitalization: TextCapitalization.words,
                  enabled: !_guardando,
                  validator: (v) =>
                      v?.trim().isNotEmpty == true ? null : 'Requerido',
                ),
                const SizedBox(height: 14),
                PersonaTextField(
                  controller: _emailController,
                  label: 'Correo electrónico *',
                  icon: Icons.email_rounded,
                  accentColor: _colorPrimary,
                  keyboardType: TextInputType.emailAddress,
                  enabled: !_guardando,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                        .hasMatch(v.trim())) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 22),

            // ═══ SECCIÓN: SEGURIDAD ═══
            FormSection(
              title: 'Seguridad',
              icon: Icons.lock_rounded,
              accentColor: _colorPrimary,
              children: [
                // Password con toggle de visibilidad
                TextFormField(
                  controller: _passwordController,
                  enabled: !_guardando,
                  obscureText: _obscurePassword,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Contraseña * (mínimo 6 caracteres)',
                    labelStyle:
                        TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon:
                        const Icon(Icons.lock_outline_rounded,
                            color: _colorPrimary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        size: 20,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: colorScheme.brightness == Brightness.dark
                        ? Colors.white.withValues(alpha: 0.04)
                        : const Color(0xFFF9FAFB),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide:
                          const BorderSide(color: _colorPrimary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (v.trim().length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _PasswordStrengthIndicator(
                    password: _passwordController.text,
                    strength:
                        _getPasswordStrength(_passwordController.text),
                    score:
                        _getPasswordScore(_passwordController.text),
                    color: _getPasswordColor(
                        _getPasswordStrength(_passwordController.text)),
                    icon: _getPasswordIcon(
                        _getPasswordStrength(_passwordController.text)),
                  ),
                ],
                const SizedBox(height: 14),

                // PIN
                PersonaTextField(
                  controller: _pinController,
                  label: 'PIN de acceso (4 dígitos) *',
                  icon: Icons.pin_rounded,
                  accentColor: _colorPrimary,
                  keyboardType: TextInputType.number,
                  enabled: !_guardando,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (v.trim().length != 4 ||
                        int.tryParse(v.trim()) == null) {
                      return 'Debe ser 4 dígitos numéricos';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Rol
                _buildRolDropdown(colorScheme),
              ],
            ),
            const SizedBox(height: 22),

            // ═══ ACCIONES ═══
            FormActions(
              isSaving: _guardando,
              confirmLabel: 'Crear Usuario',
              accentColor: _colorPrimary,
              onCancel: () => Navigator.pop(context),
              onConfirm: _crearUsuario,
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildRolDropdown(ColorScheme colorScheme) {
    return DropdownButtonFormField<String>(
      initialValue: _rolSeleccionado,
      style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Rol / Permisos',
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon:
            const Icon(Icons.assignment_ind_rounded, color: _colorPrimary),
        filled: true,
        fillColor: colorScheme.brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _colorPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dropdownColor: colorScheme.surface,
      items: const [
        DropdownMenuItem(
          value: 'admin',
          child: Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded,
                  color: Color(0xFF3B82F6), size: 18),
              SizedBox(width: 8),
              Text('Administrador'),
            ],
          ),
        ),
        DropdownMenuItem(
          value: 'cajero',
          child: Row(
            children: [
              Icon(Icons.person_rounded,
                  color: Color(0xFF10B981), size: 18),
              SizedBox(width: 8),
              Text('Cajero'),
            ],
          ),
        ),
      ],
      onChanged: _guardando
          ? null
          : (val) {
              if (val != null) setState(() => _rolSeleccionado = val);
            },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TAB: LISTA DE USUARIOS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildListTab(bool isMobile, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Encabezado de la lista ──
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.people_rounded,
                  color: _colorPrimary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'USUARIOS REGISTRADOS · ${_usuarios.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: _colorPrimary,
                  ),
                ),
              ),
              _MiniActionButton(
                icon: Icons.cleaning_services_rounded,
                color: _colorWarning,
                tooltip: 'Limpiar usuarios huérfanos',
                onTap: _limpiarUsuariosHuerfanos,
                colorScheme: colorScheme,
              ),
              const SizedBox(width: 6),
              _MiniActionButton(
                icon: Icons.refresh_rounded,
                color: _colorPrimary,
                tooltip: 'Recargar lista',
                onTap: _cargarUsuarios,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // ── Lista ──
        Expanded(
          child: _cargando
              ? const Center(child: CircularProgressIndicator())
              : _usuarios.isEmpty
                  ? _buildEmptyUsuarios(colorScheme)
                  : ListView.separated(
                      padding: const EdgeInsets.only(bottom: 8),
                      physics: const BouncingScrollPhysics(),
                      itemCount: _usuarios.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, i) => _buildUserCard(
                        _usuarios[i],
                        isMobile,
                        colorScheme,
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyUsuarios(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _colorPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_outline_rounded,
              size: 40,
              color: _colorPrimary.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No hay usuarios registrados',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Crea el primero desde la pestaña "Datos"',
            style: TextStyle(
              fontSize: 12.5,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD DE USUARIO
  // ═══════════════════════════════════════════════════════════════

  Widget _buildUserCard(
    UsuarioEntity usuario,
    bool isMobile,
    ColorScheme colorScheme,
  ) {
    final isAdmin = usuario.rol == 'admin';
    final isActive = usuario.estado == 'activo';
    final isSynced = usuario.supabaseId != null &&
        usuario.supabaseId!.isNotEmpty;

    final rolColor = isAdmin ? const Color(0xFF3B82F6) : _colorSuccess;
    final estadoColor = isActive ? _colorSuccess : colorScheme.outline;
    final estadoLabel = isActive ? 'Activo' : 'Inactivo';

    final inicial = usuario.nombre.isNotEmpty
        ? usuario.nombre[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(
          alpha: colorScheme.brightness == Brightness.dark ? 0.35 : 0.5,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAdmin
              ? rolColor.withValues(alpha: 0.25)
              : colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Avatar ──
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isAdmin
                    ? [rolColor, Color.lerp(rolColor, Colors.black, 0.2)!]
                    : [_colorPrimary, const Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(13),
              boxShadow: [
                BoxShadow(
                  color: (isAdmin ? rolColor : _colorPrimary)
                      .withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                inicial,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),

          // ── Info ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        usuario.nombre,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: isMobile ? 14 : 14.5,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.2,
                          height: 1.15,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 6),
                    // Badge de sync
                    _syncBadgeMini(isSynced),
                  ],
                ),
                const SizedBox(height: 4),
                // Rol + Estado
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _infoPill(
                      icon: isAdmin
                          ? Icons.admin_panel_settings_rounded
                          : Icons.person_rounded,
                      label: isAdmin ? 'Admin' : 'Cajero',
                      color: rolColor,
                      colorScheme: colorScheme,
                    ),
                    _infoPill(
                      icon: isActive
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      label: estadoLabel,
                      color: estadoColor,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
                // Email
                if (usuario.email != null && usuario.email!.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          usuario.email!,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colorScheme.onSurfaceVariant,
                            height: 1.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Acciones ──
          _MiniActionButton(
            icon: Icons.edit_outlined,
            color: const Color(0xFF3B82F6),
            tooltip: 'Editar',
            onTap: () => _editarUsuario(usuario),
            colorScheme: colorScheme,
          ),
          const SizedBox(width: 6),
          _MiniActionButton(
            icon: Icons.delete_outline_rounded,
            color: _colorDanger,
            tooltip: 'Eliminar',
            onTap: () => _eliminarUsuario(usuario),
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _syncBadgeMini(bool synced) {
    final color = synced ? _colorSuccess : _colorWarning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Icon(
        synced ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
        size: 10,
        color: color,
      ),
    );
  }

  Widget _infoPill({
    required IconData icon,
    required String label,
    required Color color,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.1,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════

/// Indicador visual de fortaleza de contraseña.
class _PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final String strength;
  final int score;
  final Color color;
  final IconData icon;

  const _PasswordStrengthIndicator({
    required this.password,
    required this.strength,
    required this.score,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Text(
          'Fortaleza: $strength',
          style: TextStyle(
            fontSize: 11.5,
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        // Barra de progreso 3 segmentos
        Container(
          width: 80,
          height: 4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
          child: Row(
            children: [
              for (int i = 0; i < 3; i++)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      color: i < score ? color : Colors.transparent,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Botón mini de icono con hover + tooltip.
class _MiniActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _MiniActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  State<_MiniActionButton> createState() => _MiniActionButtonState();
}

class _MiniActionButtonState extends State<_MiniActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.15)
                  : widget.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: widget.color.withValues(alpha: _hovered ? 0.4 : 0.2),
              ),
            ),
            child: Icon(
              widget.icon,
              size: 17,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}