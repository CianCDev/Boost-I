import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';

class AdminValidationDialog extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const AdminValidationDialog({
    super.key,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<AdminValidationDialog> createState() => _AdminValidationDialogState();
}

class _AdminValidationDialogState extends State<AdminValidationDialog> {
  final TextEditingController _pinController = TextEditingController();
  final IsarService _isarService = IsarService();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _validarAdmin() async {
    final pin = _pinController.text.trim();
    if (pin.isEmpty) {
      setState(() => _errorMessage = 'Por favor ingresa el PIN de Administrador.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

      try {
      final admins = await _isarService.obtenerUsuarios();

      // Búsqueda manual (El método más seguro y sin errores de tipos)
      UsuarioEntity? adminValido;
      for (var user in admins) {
        if (user.rol.toLowerCase() == 'admin' && user.pin == pin) {
          adminValido = user;
          break;
        }
      }

        if (mounted) {
        setState(() => _isLoading = false);

        if (adminValido != null) {
          // 1. Ejecuta la acción restringida
          widget.onSuccess();

          // 2. Cierra el diálogo
          Navigator.of(context).pop();
        } else {
          setState(() {
            _errorMessage = 'PIN de Administrador incorrecto.';
          });
              _pinController.clear();
         }
        
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error al validar el usuario administrador.';
        });
      }
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
          Text('Validación de Administrador', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Esta acción requiere autorización de un administrador. Ingresa su PIN para continuar.',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            maxLength: 4,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'PIN del Administrador',
              errorText: _errorMessage.isEmpty ? null : _errorMessage,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
              ),
            ),
            onSubmitted: (_) => _validarAdmin(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onCancel();
          },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
          ),
          onPressed: _isLoading ? null : _validarAdmin,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Validar', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}