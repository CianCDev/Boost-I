import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../services/sync_service.dart';

class PersonnelManagementDialog extends ConsumerStatefulWidget {
  const PersonnelManagementDialog({super.key});

  @override
  ConsumerState<PersonnelManagementDialog> createState() => _PersonnelManagementDialogState();
}

class _PersonnelManagementDialogState extends ConsumerState<PersonnelManagementDialog> {
  final IsarService _isarService = IsarService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  String _selectedRol = 'cajero';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _crearNuevoUsuario() async {
    if (_nameController.text.trim().isEmpty || _pinController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre y un PIN de 4 dígitos son obligatorios.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _isarService.crearUsuario(
        nombre: _nameController.text.trim(),
        pin: _pinController.text.trim(),
        rol: _selectedRol,
        caja: 'Caja Principal',
      );

      // Sincronizar usuarios con Supabase
      try {
        await SyncService().sincronizarUsuariosASupabase();
      } catch (e) {
        debugPrint('Error sincronizando usuario: $e');
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Usuario creado y sincronizado.'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear usuario: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.admin_panel_settings, color: Color(0xFF3B82F6)),
          SizedBox(width: 8),
          Text('Gestión de Personal y Roles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Administración de accesos del sistema POS:',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del nuevo empleado',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pinController,
                obscureText: true,
                maxLength: 4,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'PIN de acceso (4 dígitos)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedRol,
                items: const [
                  DropdownMenuItem(value: 'cajero', child: Text('Cajero')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (val) => setState(() => _selectedRol = val!),
                decoration: InputDecoration(
                  labelText: 'Rol / Permisos',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Para editar roles existentes o eliminar usuarios, ve a Configuración de Usuarios.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
          onPressed: _isLoading ? null : _crearNuevoUsuario,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Crear Nuevo Usuario'),
        ),
      ],
    );
  }
}