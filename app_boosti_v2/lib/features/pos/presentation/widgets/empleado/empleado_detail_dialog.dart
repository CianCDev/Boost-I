// lib/features/pos/presentation/screens/empleados/widgets/empleado_detail_dialog.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/empleado_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/active_toggle.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/dialog_header.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/glass_dialog.dart';
import 'package:flutter/material.dart';

/// Diálogo de detalle rápido de un empleado.
///
/// Muestra info básica + toggle activo/inactivo.
class EmpleadoDetailDialog extends StatefulWidget {
  final UsuarioEntity usuario;
  final EmpleadoInfoEntity? info;
  final VoidCallback onToggleActivo;

  const EmpleadoDetailDialog({
    super.key,
    required this.usuario,
    this.info,
    required this.onToggleActivo,
  });

  static Future<void> show(
    BuildContext context, {
    required UsuarioEntity usuario,
    EmpleadoInfoEntity? info,
    required VoidCallback onToggleActivo,
  }) {
    return showDialog(
      context: context,
      builder: (_) => EmpleadoDetailDialog(
        usuario: usuario,
        info: info,
        onToggleActivo: onToggleActivo,
      ),
    );
  }

  @override
  State<EmpleadoDetailDialog> createState() => _EmpleadoDetailDialogState();
}

class _EmpleadoDetailDialogState extends State<EmpleadoDetailDialog> {
  late UsuarioEntity _u;

  @override
  void initState() {
    super.initState();
    _u = widget.usuario;
  }

  Color _rolColor(String rol) {
    final r = rol.toLowerCase();
    if (r.contains('admin')) return const Color(0xFF8B5CF6);
    if (r.contains('super')) return const Color(0xFF6366F1);
    if (r.contains('cajer')) return const Color(0xFF06B6D4);
    if (r.contains('almac')) return const Color(0xFFEC4899);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final color = _rolColor(_u.rol);

    return GlassDialog(
      maxWidth: 520,
      accentColor: color,
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DialogHeader(
              icon: Icons.person_rounded,
              title: _u.nombre,
              subtitle: _u.email ?? 'Sin correo',
              color: color,
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
            _InfoRow(label: 'Rol', value: _u.rol),
            _InfoRow(label: 'Caja asignada', value: _u.cajaAsignada),
            _InfoRow(
              label: 'Departamento',
              value:
                  (_u.departamento ?? '').isEmpty ? '—' : _u.departamento!,
            ),
            _InfoRow(
              label: 'PIN',
              value: _u.pin.isEmpty ? '—' : '••••',
            ),
            _InfoRow(
              label: 'Estado',
              value: !_u.activo
                  ? 'Inactivo'
                  : (_u.estado == 'descanso' ? 'En descanso' : 'Activo'),
            ),
            const SizedBox(height: 18),
            ActiveToggle(
              value: _u.activo,
              onChanged: (v) {
                setState(() => _u.activo = v);
                widget.onToggleActivo();
              },
              activeLabel: 'Empleado activo',
              inactiveLabel: 'Empleado inactivo',
              activeSubtitle: 'Puede iniciar sesión y operar',
              inactiveSubtitle: 'No podrá iniciar sesión',
              activeColor: const Color(0xFF10B981),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}