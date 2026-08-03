import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';

// ==========================================
// DIÁLOGO PARA EL CAMBIO DE PIN DEL CAJERO (Requiere validación previa del admin)
// ==========================================
class CashierPinChangeDialog extends StatefulWidget {
  final UsuarioEntity cajero;
  final IsarService isarService;

  const CashierPinChangeDialog({
    super.key,
    required this.cajero,
    required this.isarService,
  });

  @override
  State<CashierPinChangeDialog> createState() => _CashierPinChangeDialogState();
}

class _CashierPinChangeDialogState extends State<CashierPinChangeDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _obscureText = true;
  bool _isRevealed = false;
  bool _cargando = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  void _toggleReveal() {
    setState(() => _isRevealed = !_isRevealed);
    if (_isRevealed) {
      _pinController.text = widget.cajero.pin;
    } else {
      _pinController.clear();
    }
  }

  Future<void> _guardarCambio() async {
    final newPin = _pinController.text.trim();
    if (newPin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El PIN debe tener 4 dígitos.')));
      return;
    }
    setState(() => _cargando = true);
    final exito = await widget.isarService.cambiarClaveUsuario(widget.cajero.id, newPin);
    if (mounted) {
      setState(() => _cargando = false);
      if (exito) {
        widget.cajero.pin = newPin;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clave actualizada correctamente.'), backgroundColor: Color(0xFF10B981)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cambiar la clave.'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.lock_reset, color: Color(0xFF3B82F6)),
          SizedBox(width: 8),
          Text('Cambiar PIN del Cajero', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('El administrador ha validado el acceso. Puedes cambiar el PIN.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
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
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Botón de revelar PIN (Solo visible aquí porque ya pasó la validación del admin)
                  IconButton(
                    icon: Icon(_isRevealed ? Icons.visibility : Icons.visibility_off),
                    onPressed: _toggleReveal,
                    tooltip: _isRevealed ? 'Ocultar PIN actual' : 'Revelar PIN actual',
                  ),
                  IconButton(
                    icon: const Icon(Icons.lock_open),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    tooltip: _obscureText ? 'Mostrar texto' : 'Ocultar texto',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          onPressed: _cargando ? null : _guardarCambio,
          child: _cargando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Guardar Cambios', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}

// ==========================================
// DIÁLOGO PARA EL CAMBIO DE PIN DEL ADMINISTRADOR (Sin revelar, validación básica)
// ==========================================
class AdminPinChangeDialog extends StatefulWidget {
  final UsuarioEntity admin;
  final IsarService isarService;

  const AdminPinChangeDialog({
    super.key,
    required this.admin,
    required this.isarService,
  });

  @override
  State<AdminPinChangeDialog> createState() => _AdminPinChangeDialogState();
}

class _AdminPinChangeDialogState extends State<AdminPinChangeDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _obscureText = true;
  bool _cargando = false;

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambio() async {
    final newPin = _pinController.text.trim();
    if (newPin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El PIN debe tener 4 dígitos.')));
      return;
    }
    setState(() => _cargando = true);
    final exito = await widget.isarService.cambiarClaveUsuario(widget.admin.id, newPin);
    if (mounted) {
      setState(() => _cargando = false);
      if (exito) {
        widget.admin.pin = newPin;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Clave de administrador actualizada correctamente.'), backgroundColor: Color(0xFF10B981)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al cambiar la clave.'), backgroundColor: Colors.red));
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
          Text('Cambiar mi PIN de Admin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Ingresa tu nuevo PIN de administrador:', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
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
              suffixIcon: IconButton(
                icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          onPressed: _cargando ? null : _guardarCambio,
          child: _cargando
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Guardar Nuevo PIN', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}