import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../utils/responsive_helper.dart';

// ==========================================
// DIÁLOGO PARA CAMBIO DE PIN (Admin o Cajero)
// ==========================================
class PinChangeDialog extends StatefulWidget {
  final UsuarioEntity usuario;
  final IsarService isarService;
  final bool esAdmin;

  const PinChangeDialog({
    super.key,
    required this.usuario,
    required this.isarService,
    this.esAdmin = false,
  });

  @override
  State<PinChangeDialog> createState() => _PinChangeDialogState();
}

class _PinChangeDialogState extends State<PinChangeDialog> {
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();
  bool _obscureNewPin = true;
  bool _obscureConfirmPin = true;
  bool _cargando = false;
  bool _mostrarPinActual = false;

  @override
  void dispose() {
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  void _toggleRevealActual() {
    setState(() {
      _mostrarPinActual = !_mostrarPinActual;
    });
  }

  Future<void> _guardarCambio() async {
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El PIN debe tener 4 dígitos.'), backgroundColor: Colors.orange),
      );
      return;
    }

    if (newPin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Los PINs no coinciden.'), backgroundColor: Colors.orange),
      );
      return;
    }
      await IsarService().guardarLog(
  LogEntity()
    ..accion = 'CAMBIO_PIN'
    ..usuarioNombre = widget.usuario.nombre
    ..usuarioRol = widget.usuario.rol
    ..detalles = 'Usuario ID: ${widget.usuario.id}'
    ..fecha = DateTime.now()
    ..sincronizado = false,
);
    setState(() => _cargando = true);
    final exito = await widget.isarService.cambiarClaveUsuario(widget.usuario.id, newPin);
    if (mounted) {
      setState(() => _cargando = false);
      if (exito) {
        widget.usuario.pin = newPin;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ PIN actualizado correctamente.'), backgroundColor: Color(0xFF10B981)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Error al cambiar el PIN.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final color = const Color(0xFF0EA5E9);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
      child: Container(
        width: isMobile ? double.infinity : 480,
        padding: EdgeInsets.all(isMobile ? 20 : 28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lock_reset_rounded, color: color, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.esAdmin ? 'Cambiar PIN de Admin' : 'Cambiar PIN de Cajero',
                    style: TextStyle(
                      fontSize: isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tu nuevo PIN de acceso al sistema',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),

            // Ver PIN actual
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: _toggleRevealActual,
                  icon: Icon(
                    _mostrarPinActual ? Icons.visibility_off : Icons.visibility,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  label: Text(
                    _mostrarPinActual ? 'Ocultar PIN actual' : 'Ver PIN actual',
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            if (_mostrarPinActual && widget.usuario.pin.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'PIN actual: ${widget.usuario.pin}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),

            // Campo: Nuevo PIN
            TextFormField(
              controller: _newPinController,
              obscureText: _obscureNewPin,
              keyboardType: TextInputType.number,
              maxLength: 4,
              autofocus: true,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                labelText: 'Nuevo PIN (4 dígitos)',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2.5),
                ),
                prefixIcon: Icon(Icons.lock_outline_rounded, color: color, size: 22),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPin ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () => setState(() => _obscureNewPin = !_obscureNewPin),
                  tooltip: _obscureNewPin ? 'Mostrar texto' : 'Ocultar texto',
                ),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 16),

            // Campo: Confirmar PIN
            TextFormField(
              controller: _confirmPinController,
              obscureText: _obscureConfirmPin,
              keyboardType: TextInputType.number,
              maxLength: 4,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
              decoration: InputDecoration(
                labelText: 'Confirmar PIN (4 dígitos)',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2.5),
                ),
                prefixIcon: Icon(Icons.lock_outline_rounded, color: color, size: 22),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPin ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: () => setState(() => _obscureConfirmPin = !_obscureConfirmPin),
                  tooltip: _obscureConfirmPin ? 'Mostrar texto' : 'Ocultar texto',
                ),
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Botones
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                  onPressed: _cargando ? null : _guardarCambio,
                  child: _cargando
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          isMobile ? 'Guardar' : 'Guardar Cambios',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ADMIN: Cambio de PIN (usa el mismo diálogo)
// ==========================================
class AdminPinChangeDialog extends StatelessWidget {
  final UsuarioEntity admin;
  final IsarService isarService;

  const AdminPinChangeDialog({
    super.key,
    required this.admin,
    required this.isarService,
  });

  @override
  Widget build(BuildContext context) {
    return PinChangeDialog(
      usuario: admin,
      isarService: isarService,
      esAdmin: true,
    );
  }
}

// ==========================================
// CAJERO: Cambio de PIN (usa el mismo diálogo)
// ==========================================
class CashierPinChangeDialog extends StatelessWidget {
  final UsuarioEntity cajero;
  final IsarService isarService;

  const CashierPinChangeDialog({
    super.key,
    required this.cajero,
    required this.isarService,
  });

  @override
  Widget build(BuildContext context) {
    return PinChangeDialog(
      usuario: cajero,
      isarService: isarService,
      esAdmin: false,
    );
  }
}