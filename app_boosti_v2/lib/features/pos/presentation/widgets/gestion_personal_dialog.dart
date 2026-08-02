import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';

class PersonnelManagementDialog extends StatefulWidget {
  const PersonnelManagementDialog({super.key});

  @override
  State<PersonnelManagementDialog> createState() => _PersonnelManagementDialogState();
}

class _PersonnelManagementDialogState extends State<PersonnelManagementDialog> {
  final IsarService _isarService = IsarService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  String _selectedRol = 'cajero';

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _crearNuevoUsuario() async {
    if (_nameController.text.trim().isEmpty || _pinController.text.trim().length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre y un PIN de 4 dígitos son obligatorios.'), backgroundColor: Colors.redAccent));
      return;
    }
    // Lógica de creación segura
    await _isarService.crearUsuario(
      nombre: _nameController.text.trim(),
      pin: _pinController.text.trim(),
      rol: _selectedRol,
      caja: 'Caja Principal',
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [Icon(Icons.admin_panel_settings, color: Color(0xFF3B82F6)), SizedBox(width: 8), Text('Gestión de Personal y Roles', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Administración de accesos del sistema POS:', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              const SizedBox(height: 12),
              TextField(controller: _nameController, decoration: InputDecoration(labelText: 'Nombre del nuevo empleado', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 8),
              TextField(controller: _pinController, obscureText: true, maxLength: 4, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'PIN de acceso (4 dígitos)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedRol,
                items: const [DropdownMenuItem(value: 'cajero', child: Text('Cajero')), DropdownMenuItem(value: 'admin', child: Text('Administrador'))],
                onChanged: (val) => setState(() => _selectedRol = val!),
                decoration: InputDecoration(labelText: 'Rol / Permisos', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
              const SizedBox(height: 16),
              const Text('Para editar roles existentes o eliminar usuarios, ve a Configuración de Usuarios.', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          onPressed: _crearNuevoUsuario,
          child: const Text('Crear Nuevo Usuario'),
        ),
      ],
    );
  }
}