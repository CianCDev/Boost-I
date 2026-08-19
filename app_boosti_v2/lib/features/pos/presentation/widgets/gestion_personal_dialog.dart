import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';

class PersonnelManagementDialog extends ConsumerStatefulWidget {
  const PersonnelManagementDialog({super.key});

  @override
  ConsumerState<PersonnelManagementDialog> createState() =>
      _PersonnelManagementDialogState();
}

class _PersonnelManagementDialogState
    extends ConsumerState<PersonnelManagementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _pinController = TextEditingController();
  String _rolSeleccionado = 'cajero';
  bool _guardando = false;
  List<UsuarioEntity> _usuarios = [];
  bool _cargando = true;

  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  @override
  void dispose() {
    _nombreController.dispose();
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
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    try {
      final nuevoUsuario = UsuarioEntity()
        ..nombre = _nombreController.text.trim()
        ..pin = _pinController.text.trim()
        ..rol = _rolSeleccionado
        ..estado = 'inactivo'
        ..activo = true
        ..cajaAsignada = '';

      await _isarService.guardarUsuario(nuevoUsuario);
      await _syncService.sincronizarUsuariosASupabase();

      setState(() {
        _nombreController.clear();
        _pinController.clear();
        _rolSeleccionado = 'cajero';
        _guardando = false;
      });

      await _cargarUsuarios();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Usuario creado correctamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      setState(() => _guardando = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Error al crear usuario: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _eliminarUsuario(UsuarioEntity usuario) async {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final theme = Theme.of(context);
    final color = const Color(0xFF8B5CF6); // Morado para gestión

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: Container(
        width: isMobile ? double.infinity : 700,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: theme.dialogTheme.backgroundColor ?? theme.cardColor,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ========== HEADER ==========
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.admin_panel_settings_rounded,
                      color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Gestión de Personal',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 20 : 24,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      size: 28, color: theme.iconTheme.color),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Administración de accesos al sistema POS',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: isMobile ? 14 : 16,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            // ========== FORMULARIO (siempre visible) ==========
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nombreController,
                    enabled: !_guardando,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del nuevo empleado *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (v) =>
                        v?.trim().isNotEmpty == true ? null : 'Requerido',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _pinController,
                    enabled: !_guardando,
                    decoration: const InputDecoration(
                      labelText: 'PIN de acceso (4 dígitos) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline_rounded),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    validator: (v) {
                      if (v?.trim().length != 4) return 'Debe tener 4 dígitos';
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _rolSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Rol / Permisos',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.assignment_ind_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                      DropdownMenuItem(value: 'cajero', child: Text('Cajero')),
                    ],
                    onChanged: _guardando ? null : (val) {
                      if (val != null) setState(() => _rolSeleccionado = val);
                    },
                    isExpanded: true,
                  ),
                  const SizedBox(height: 16),
                  // Nota informativa
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            color: Colors.amber.shade800, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Para editar roles existentes o eliminar usuarios, ve a Configuración de Usuarios.',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Botones de acción
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton(
                        onPressed: _guardando ? null : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: const Text('Cerrar'),
                      ),
                      ElevatedButton(
                        onPressed: _guardando ? null : _crearUsuario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                ],
              ),
            ),

            const SizedBox(height: 12),
            const Divider(),

            // ========== LISTA DE USUARIOS (expanded) ==========
            Expanded(
              child: _cargando
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF8B5CF6)))
                  : _usuarios.isEmpty
                      ? Center(
                          child: Text(
                            'No hay usuarios registrados',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.6),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _usuarios.length,
                          itemBuilder: (context, index) {
                            final usuario = _usuarios[index];
                            final isAdmin = usuario.rol == 'admin';
                            final avatarColor =
                                isAdmin ? const Color(0xFF3B82F6) : const Color(0xFF10B981);
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 2),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: avatarColor.withOpacity(0.15),
                                child: Icon(
                                  isAdmin
                                      ? Icons.admin_panel_settings_rounded
                                      : Icons.person_rounded,
                                  color: avatarColor,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                usuario.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isMobile ? 14 : 16,
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              subtitle: Text(
                                '${usuario.rol.toUpperCase()} • ${usuario.estado}',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.6),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded,
                                    color: Color(0xFFEF4444)),
                                onPressed: () => _eliminarUsuario(usuario),
                                tooltip: 'Eliminar',
                              ),
                              dense: true,
                            );
                          },
                        ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}