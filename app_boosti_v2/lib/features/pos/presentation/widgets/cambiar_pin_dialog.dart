import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';

class ChangePinDialog extends StatefulWidget {
  final UsuarioEntity usuario;
  const ChangePinDialog({super.key, required this.usuario});

  @override
  State<ChangePinDialog> createState() => _ChangePinDialogState();
}

class _ChangePinDialogState extends State<ChangePinDialog> {
  final IsarService _isarService = IsarService();
  final TextEditingController _pinController = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(children: [Icon(Icons.lock_reset, color: Color(0xFF3B82F6)), SizedBox(width: 8), Text('Cambiar mi Clave', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ingresa tu nuevo PIN de seguridad:', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          const SizedBox(height: 12),
          TextField(
            controller: _pinController,
            obscureText: _obscureText,
            keyboardType: TextInputType.number,
            maxLength: 4,
            autofocus: true,
            decoration: InputDecoration(
              labelText: 'Nuevo PIN (4 dígitos)',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              suffixIcon: IconButton(icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _obscureText = !_obscureText)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          onPressed: () async {
            final newPin = _pinController.text.trim();
            if (newPin.length < 4) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El PIN debe tener 4 dígitos.')));
              return;
            }
            if (await _isarService.cambiarClaveUsuario(widget.usuario.id, newPin)) {
              // ignore: use_build_context_synchronously
              if (mounted) { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clave actualizada correctamente.'), backgroundColor: Color(0xFF10B981))); }
            }
          },
          child: const Text('Guardar Nueva Clave'),
        ),
      ],
    );
  }
}