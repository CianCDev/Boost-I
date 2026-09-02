import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../data/Local/entities/log_entity.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';
import '../providers/usuario_provider.dart';
import '../providers/themes/app_colors.dart';

class PersonnelManagementDialog extends ConsumerStatefulWidget {
  const PersonnelManagementDialog({super.key});

  @override
  ConsumerState<PersonnelManagementDialog> createState() =>
      _PersonnelManagementDialogState();
}

class _PersonnelManagementDialogState
    extends ConsumerState<PersonnelManagementDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _pinController = TextEditingController();
  String _rolSeleccionado = 'cajero';
  bool _guardando = false;
  List<UsuarioEntity> _usuarios = [];
  bool _cargando = true;
  bool _obscurePassword = true;

  late TabController _tabController;

  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

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

  Future<void> _cargarUsuarios() async {
    setState(() => _cargando = true);
    try {
      final usuarios = await _isarService.obtenerUsuarios();
      setState(() {
        _usuarios = usuarios;
        _cargando = false;
      });
    } catch (e) {
      setState(() => _cargando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error al cargar usuarios: $e'),
              backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  // ============================================================
  // INDICADOR DE FORTALEZA DE CONTRASEÑA
  // ============================================================
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
        return Colors.red;
      case 'Media':
        return Colors.orange;
      case 'Fuerte':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getPasswordIcon(String strength) {
    switch (strength) {
      case 'Débil':
        return Icons.error_outline;
      case 'Media':
        return Icons.warning_amber_outlined;
      case 'Fuerte':
        return Icons.check_circle_outline;
      default:
        return Icons.info_outline;
    }
  }

  int _getPasswordScore(String password) {
    final strength = _getPasswordStrength(password);
    switch (strength) {
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

  // ============================================================
  // CREAR USUARIO
  // ============================================================
  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text.trim();
    final strength = _getPasswordStrength(password);
    if (strength == 'Débil' && password.isNotEmpty) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Contraseña débil'),
          content: const Text(
              'La contraseña es débil. ¿Deseas continuar de todos modos? Se recomienda usar al menos 6 caracteres con números y letras.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
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

      final response = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: password,
        data: {
          'nombre': _nombreController.text.trim(),
          'rol': _rolSeleccionado,
          'pin': _pinController.text.trim(),
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
        ..pin = _pinController.text.trim()
        ..rol = _rolSeleccionado
        ..estado = 'inactivo'
        ..activo = true
        ..supabaseId = response.user!.id
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

      setState(() {
        _nombreController.clear();
        _emailController.clear();
        _passwordController.clear();
        _pinController.clear();
        _rolSeleccionado = 'cajero';
        _guardando = false;
      });

      await _cargarUsuarios();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Usuario creado correctamente.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      setState(() => _guardando = false);
      String mensaje = 'Error al crear usuario';
      if (e is AuthWeakPasswordException) {
        mensaje = '❌ Contraseña demasiado débil. Debe tener al menos 6 caracteres.';
      } else if (e.toString().contains('email')) {
        mensaje = '❌ El email ya está registrado.';
      } else {
        mensaje = '❌ $e';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(mensaje),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // ============================================================
  // EDITAR USUARIO
  // ============================================================
  Future<void> _editarUsuario(UsuarioEntity usuario) async {
    final nombreController = TextEditingController(text: usuario.nombre);
    final emailController = TextEditingController(text: usuario.email ?? '');
    final passwordController = TextEditingController();
    final pinController = TextEditingController(text: usuario.pin);
    String rolSeleccionado = usuario.rol;

    final formKey = GlobalKey<FormState>();
    bool editando = false;
    bool obscureEditPassword = true;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.edit_rounded, color: const Color(0xFF8B5CF6)),
                const SizedBox(width: 8),
                Text('Editar Usuario: ${usuario.nombre}'),
              ],
            ),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nombreController,
                      decoration: const InputDecoration(labelText: 'Nombre *'),
                      validator: (v) =>
                          v?.trim().isNotEmpty == true ? null : 'Requerido',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        hintText: 'Se usará para login',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                          return 'Email inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscureEditPassword,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña (opcional)',
                        hintText: 'Dejar vacío para no cambiarla',
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureEditPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setStateDialog(() {
                              obscureEditPassword = !obscureEditPassword;
                            });
                          },
                        ),
                      ),
                      onChanged: (value) => setStateDialog(() {}),
                    ),
                    if (passwordController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              _getPasswordIcon(_getPasswordStrength(passwordController.text)),
                              color: _getPasswordColor(_getPasswordStrength(passwordController.text)),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Fortaleza: ${_getPasswordStrength(passwordController.text)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getPasswordColor(_getPasswordStrength(passwordController.text)),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 80,
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.grey.shade300,
                              ),
                              child: Row(
                                children: [
                                  for (int i = 0; i < 3; i++)
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 1),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(2),
                                          color: i < _getPasswordScore(passwordController.text)
                                              ? _getPasswordColor(_getPasswordStrength(passwordController.text))
                                              : Colors.transparent,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: pinController,
                      decoration: const InputDecoration(labelText: 'PIN (4 dígitos) *'),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Requerido';
                        if (v.trim().length != 4 || int.tryParse(v.trim()) == null) {
                          return 'Debe ser 4 dígitos numéricos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: rolSeleccionado,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                        DropdownMenuItem(value: 'cajero', child: Text('Cajero')),
                      ],
                      onChanged: (val) => rolSeleccionado = val!,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  setState(() => editando = true);

                  try {
                    final newPassword = passwordController.text.trim();
                    if (newPassword.isNotEmpty) {
                      final strength = _getPasswordStrength(newPassword);
                      if (strength == 'Débil') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Contraseña débil'),
                            content: const Text(
                                'La nueva contraseña es débil. ¿Deseas continuar de todos modos?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Continuar'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) {
                          setState(() => editando = false);
                          return;
                        }
                      }
                    }

                    // Actualizar localmente
                    usuario.nombre = nombreController.text.trim();
                    usuario.email = emailController.text.trim();
                    usuario.pin = pinController.text.trim();
                    usuario.rol = rolSeleccionado;
                    if (newPassword.isNotEmpty) {
                      usuario.password = newPassword;
                    }
                    await _isarService.guardarUsuario(usuario);

                    // Actualizar en Supabase
                    if (usuario.supabaseId != null && usuario.supabaseId!.isNotEmpty) {
                      final supabase = Supabase.instance.client;
                      await supabase.from('usuarios').update({
                        'nombre': usuario.nombre,
                        'rol': usuario.rol,
                        'pin': usuario.pin,
                        'email': usuario.email,
                        'updated_at': DateTime.now().toIso8601String(),
                      }).eq('id', usuario.supabaseId!);
                    }

                    // Sincronizar
                    await _syncService.sincronizarUsuariosASupabase();

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Usuario actualizado correctamente'),
                          backgroundColor: Color(0xFF10B981),
                        ),
                      );
                      await _cargarUsuarios();
                    }
                  } catch (e) {
                    setState(() => editando = false);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('❌ Error al actualizar: $e'),
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      );
                    }
                  }
                },
                child: editando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ============================================================
  // ELIMINAR USUARIO
  // ============================================================
  Future<void> _eliminarUsuario(UsuarioEntity usuario) async {
    final usuarioActual = ref.read(usuarioActualProvider);
    if (usuarioActual != null && usuarioActual.id == usuario.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ No puedes eliminar tu propio usuario.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text(
            '¿Estás seguro de eliminar a "${usuario.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Usuario eliminado'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('❌ Error al eliminar: $e'),
                backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
      }
    }
  }

  // ============================================================
  // LIMPIAR USUARIOS HUÉRFANOS
  // ============================================================
  Future<void> _limpiarUsuariosHuerfanos() async {
    final usuarios = await _isarService.obtenerUsuarios();
    int eliminados = 0;
    int limpiados = 0;

    for (var u in usuarios) {
      if (u.email == null || u.email!.isEmpty) {
        if (u.nombre.contains('Administrador') || u.nombre.contains('Admin')) {
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
          await Supabase.instance.client.auth.admin.getUserById(u.supabaseId!);
        } catch (e) {
          u.supabaseId = null;
          await _isarService.guardarUsuario(u);
          limpiados++;
        }
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '🧹 Limpieza: $eliminados eliminados, $limpiados corregidos.'),
          backgroundColor: Colors.green,
        ),
      );
    }
    await _cargarUsuarios();
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final Color neonColor = const Color(0xFF8B5CF6);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: Container(
        width: isMobile ? double.infinity : 720,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF1A2235).withValues(alpha: 0.95)
              : Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : neonColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.6)
                  : neonColor.withValues(alpha: 0.1),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // HEADER
            _buildHeader(theme, colorScheme, neonColor, isMobile),
            const SizedBox(height: 8),
            Divider(color: colorScheme.outline.withValues(alpha: 0.2)),
            const SizedBox(height: 12),

            // TAB BAR
            TabBar(
              controller: _tabController,
              indicatorColor: neonColor,
              labelColor: neonColor,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(icon: Icon(Icons.person_add_rounded), text: 'Datos'),
                Tab(icon: Icon(Icons.people_rounded), text: 'Lista'),
              ],
            ),
            const SizedBox(height: 12),

            // TAB BAR VIEW
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pestaña 1: Formulario
                  _buildFormTab(theme, colorScheme, neonColor, isMobile, isDark),
                  // Pestaña 2: Lista de usuarios
                  _buildListTab(theme, colorScheme, neonColor, isMobile),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(
    ThemeData theme,
    ColorScheme colorScheme,
    Color neonColor,
    bool isMobile,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                neonColor.withValues(alpha: 0.3),
                neonColor.withValues(alpha: 0.1),
              ],
            ),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.admin_panel_settings_rounded,
              color: neonColor, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestión de Personal',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20 : 24,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'Administración de accesos al sistema POS',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: isMobile ? 13 : 15,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, size: 28,
              color: colorScheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Cerrar',
        ),
      ],
    );
  }

  // ============================================================
  // PESTAÑA DE FORMULARIO
  // ============================================================
  Widget _buildFormTab(
    ThemeData theme,
    ColorScheme colorScheme,
    Color neonColor,
    bool isMobile,
    bool isDark,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Nombre
            TextFormField(
              controller: _nombreController,
              enabled: !_guardando,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Nombre completo *',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline_rounded, color: neonColor),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              validator: (v) =>
                  v?.trim().isNotEmpty == true ? null : 'Requerido',
            ),
            const SizedBox(height: 12),

            // Email
            TextFormField(
              controller: _emailController,
              enabled: !_guardando,
              style: TextStyle(color: colorScheme.onSurface),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico * (para login)',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_rounded, color: neonColor),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim())) {
                  return 'Email inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Password
            TextFormField(
              controller: _passwordController,
              enabled: !_guardando,
              obscureText: _obscurePassword,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Contraseña * (mínimo 6 caracteres)',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline_rounded, color: neonColor),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onChanged: (value) => setState(() {}),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                if (v.trim().length < 6) return 'Mínimo 6 caracteres';
                return null;
              },
            ),
            // Indicador de fortaleza
            if (_passwordController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Row(
                  children: [
                    Icon(
                      _getPasswordIcon(
                          _getPasswordStrength(_passwordController.text)),
                      color: _getPasswordColor(
                          _getPasswordStrength(_passwordController.text)),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Fortaleza: ${_getPasswordStrength(_passwordController.text)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: _getPasswordColor(
                            _getPasswordStrength(_passwordController.text)),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 80,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: Colors.grey.shade300,
                      ),
                      child: Row(
                        children: [
                          for (int i = 0; i < 3; i++)
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 1),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  color: i <
                                          _getPasswordScore(
                                              _passwordController.text)
                                      ? _getPasswordColor(_getPasswordStrength(
                                          _passwordController.text))
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),

            // PIN
            TextFormField(
              controller: _pinController,
              enabled: !_guardando,
              style: TextStyle(color: colorScheme.onSurface),
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(
                labelText: 'PIN de acceso (4 dígitos) *',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.pin_rounded, color: neonColor),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                if (v.trim().length != 4 || int.tryParse(v.trim()) == null) {
                  return 'Debe ser 4 dígitos numéricos';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Rol
            DropdownButtonFormField<String>(
              initialValue: _rolSeleccionado,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                labelText: 'Rol / Permisos',
                labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.assignment_ind_rounded, color: neonColor),
                filled: true,
                fillColor:
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'admin',
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings_rounded,
                          color: Colors.blue, size: 18),
                      SizedBox(width: 8),
                      Text('Administrador'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'cajero',
                  child: Row(
                    children: [
                      Icon(Icons.person_rounded, color: Colors.green, size: 18),
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
              isExpanded: true,
            ),
            const SizedBox(height: 12),

            // Info adicional
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: neonColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: neonColor.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: neonColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La contraseña debe tener al menos 6 caracteres. Se recomienda usar mayúsculas, minúsculas, números y símbolos para mayor seguridad.',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _guardando ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cerrar',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _guardando ? null : _crearUsuario,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: neonColor,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: _guardando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Crear Usuario'),
                          ],
                        ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PESTAÑA DE LISTA DE USUARIOS (CORREGIDA PARA EVITAR OVERFLOW)
  // ============================================================
  Widget _buildListTab(
    ThemeData theme,
    ColorScheme colorScheme,
    Color neonColor,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.people_rounded, color: neonColor, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Usuarios registrados (${_usuarios.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 15 : 17,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.cleaning_services_rounded,
                    color: Colors.orange.shade400, size: 22),
                tooltip: 'Limpiar usuarios huérfanos',
                onPressed: _limpiarUsuariosHuerfanos,
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.refresh_rounded,
                    color: colorScheme.primary, size: 22),
                tooltip: 'Recargar lista',
                onPressed: _cargarUsuarios,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: _cargando
              ? Center(child: CircularProgressIndicator(color: neonColor))
              : _usuarios.isEmpty
                  ? Center(
                      child: Text(
                        'No hay usuarios registrados',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: _usuarios.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final usuario = _usuarios[index];
                        return _buildUserCard(
                          usuario,
                          isMobile,
                          theme,
                          colorScheme,
                          neonColor,
                        );
                      },
                    ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ============================================================
  // TARJETA DE USUARIO (CON FLEXIBLE PARA EVITAR OVERFLOW)
  // ============================================================
  Widget _buildUserCard(
    UsuarioEntity usuario,
    bool isMobile,
    ThemeData theme,
    ColorScheme colorScheme,
    Color neonColor,
  ) {
    final isAdmin = usuario.rol == 'admin';
    final bool isActive = usuario.estado == 'activo';
    final bool isSynced =
        usuario.supabaseId != null && usuario.supabaseId!.isNotEmpty;

    final Color avatarColor = isAdmin ? Colors.blue.shade600 : Colors.green.shade600;
    final String estadoTexto = isActive ? 'Activo' : 'Inactivo';
    final Color estadoColor = isActive ? Colors.green.shade600 : Colors.grey.shade500;
    final IconData estadoIcon = isActive ? Icons.circle : Icons.circle_outlined;
    final String rolTexto = isAdmin ? 'Administrador' : 'Cajero';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAdmin
              ? Colors.blue.withValues(alpha: 0.2)
              : colorScheme.outline.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColor.withValues(alpha: 0.12),
              ),
              child: Center(
                child: Icon(
                  isAdmin
                      ? Icons.admin_panel_settings_rounded
                      : Icons.person_rounded,
                  color: avatarColor,
                  size: 26,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Información principal - usando Expanded para ocupar espacio
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nombre + badge sync
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          usuario.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 14 : 15,
                            color: colorScheme.onSurface,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSynced
                              ? Colors.green.withValues(alpha: 0.12)
                              : Colors.orange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSynced
                                ? Colors.green.withValues(alpha: 0.3)
                                : Colors.orange.withValues(alpha: 0.3),
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSynced
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_off_rounded,
                              size: 11,
                              color: isSynced ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              isSynced ? 'Sinc.' : 'Pend.',
                              style: TextStyle(
                                fontSize: 7,
                                fontWeight: FontWeight.w600,
                                color: isSynced ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Rol y estado
                  Wrap(
                    spacing: 8,
                    runSpacing: 2,
                    children: [
                      Text(
                        rolTexto,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w500,
                          color: isAdmin ? Colors.blue.shade700 : Colors.green.shade700,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(estadoIcon, size: 10, color: estadoColor),
                          const SizedBox(width: 4),
                          Text(
                            estadoTexto,
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 11,
                              color: estadoColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Email (solo si existe)
                  if (usuario.email != null && usuario.email!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(Icons.email_outlined,
                              size: 12, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              usuario.email!,
                              style: TextStyle(
                                fontSize: isMobile ? 10 : 11,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Botones de acción - tamaño fijo
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      color: Colors.blue.shade400, size: 20),
                  onPressed: () => _editarUsuario(usuario),
                  tooltip: 'Editar',
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                const SizedBox(width: 2),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      color: Colors.red.shade400, size: 20),
                  onPressed: () => _eliminarUsuario(usuario),
                  tooltip: 'Eliminar',
                  splashRadius: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}