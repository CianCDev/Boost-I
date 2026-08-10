import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../presentation/providers/usuario_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/admin_validation_dialog.dart';
import '../widgets/cambiar_pin_dialog.dart';
import 'login_screen.dart';

class UserSettingsScreen extends ConsumerStatefulWidget {
  final UsuarioEntity usuarioLogueado;

  const UserSettingsScreen({super.key, required this.usuarioLogueado});

  @override
  ConsumerState<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends ConsumerState<UserSettingsScreen> {
  final IsarService _isarService = IsarService();
  final TextEditingController _nombreController = TextEditingController();
  bool _editandoNombre = false;
  bool _guardandoNombre = false;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.usuarioLogueado.nombre;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  Future<void> _cambiarNombre() async {
    final nuevoNombre = _nombreController.text.trim();
    if (nuevoNombre.isEmpty || nuevoNombre == widget.usuarioLogueado.nombre) {
      setState(() => _editandoNombre = false);
      return;
    }

    setState(() => _guardandoNombre = true);

    try {
      // Actualizar local
      widget.usuarioLogueado.nombre = nuevoNombre;
      await _isarService.guardarUsuario(widget.usuarioLogueado);

      // Actualizar el provider
      ref.read(usuarioActualProvider.notifier).setUsuario(widget.usuarioLogueado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Nombre actualizado correctamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar nombre: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardandoNombre = false;
          _editandoNombre = false;
        });
      }
    }
  }

  Future<void> _cambiarPin() async {
    final esAdmin = widget.usuarioLogueado.rol == 'admin';

    if (esAdmin) {
      await showDialog(
        context: context,
        builder: (context) => AdminPinChangeDialog(
          admin: widget.usuarioLogueado,
          isarService: _isarService,
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AdminValidationDialog(
          onSuccess: () {
            showDialog(
              context: context,
              builder: (context) => CashierPinChangeDialog(
                cajero: widget.usuarioLogueado,
                isarService: _isarService,
              ),
            );
          },
          onCancel: () {},
        ),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      ref.read(usuarioActualProvider.notifier).clearUsuario();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final color = const Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Ajustes de Usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(68, 109, 241, 1),
                Color.fromARGB(255, 85, 59, 235),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encabezado de perfil
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.05),
                    color.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          color,
                          color.withValues(alpha: 0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: isMobile ? 32 : 44,
                      backgroundColor: Colors.transparent,
                      child: Text(
                        widget.usuarioLogueado.nombre.isNotEmpty
                            ? widget.usuarioLogueado.nombre[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: isMobile ? 28 : 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.usuarioLogueado.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 18 : 22,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.usuarioLogueado.rol == 'admin'
                                ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                                : const Color(0xFF10B981).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            widget.usuarioLogueado.rol.toUpperCase(),
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: widget.usuarioLogueado.rol == 'admin'
                                  ? const Color(0xFF3B82F6)
                                  : const Color(0xFF10B981),
                            ),
                          ),
                        ),
                        if (widget.usuarioLogueado.cajaAsignada.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Caja: ${widget.usuarioLogueado.cajaAsignada}',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sección: Información Personal
            _buildSectionHeader('Información Personal', Icons.person_outline_rounded),
            const SizedBox(height: 8),

            // Cambiar nombre
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: _editandoNombre
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          TextField(
                            controller: _nombreController,
                            autofocus: true,
                            decoration: const InputDecoration(
                              labelText: 'Nuevo nombre',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person_outline_rounded),
                            ),
                            onSubmitted: (_) => _cambiarNombre(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _editandoNombre = false;
                                    _nombreController.text = widget.usuarioLogueado.nombre;
                                  });
                                },
                                child: const Text('Cancelar'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _guardandoNombre ? null : _cambiarNombre,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                child: _guardandoNombre
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Guardar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  : ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline_rounded, color: Color(0xFF3B82F6)),
                      ),
                      title: const Text('Nombre de usuario'),
                      subtitle: Text(widget.usuarioLogueado.nombre),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit_rounded, color: Color(0xFF3B82F6)),
                        onPressed: () => setState(() => _editandoNombre = true),
                      ),
                      dense: false,
                    ),
            ),
            const SizedBox(height: 8),

            // Cambiar PIN
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset_rounded, color: Color(0xFF0EA5E9)),
                ),
                title: const Text('Cambiar PIN de acceso'),
                subtitle: Text('Actualizar tu PIN de ${widget.usuarioLogueado.rol}'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                onTap: _cambiarPin,
              ),
            ),
            const SizedBox(height: 8),

            // Cambiar tema
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.brightness_6_rounded, color: Color(0xFFF59E0B)),
                ),
                title: const Text('Tema de la aplicación'),
                subtitle: const Text('Alternar entre claro y oscuro'),
                trailing: Switch(
                  value: ref.watch(themeProvider) == ThemeMode.dark,
                  onChanged: (value) {
                    ref.read(themeProvider.notifier).toggleTheme();
                  },
                  activeColor: const Color(0xFF10B981),
                ),
              ),
            ),
            const SizedBox(height: 8),

            const SizedBox(height: 16),
            _buildSectionHeader('Acciones', Icons.settings_rounded),
            const SizedBox(height: 8),

            // Cerrar sesión
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
                ),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Color(0xFFEF4444))),
                subtitle: const Text('Salir de la aplicación'),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
                onTap: _cerrarSesion,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}