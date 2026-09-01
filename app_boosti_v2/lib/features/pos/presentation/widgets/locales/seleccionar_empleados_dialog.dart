// lib/features/pos/presentation/widgets/seleccionar_empleados_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';

class SeleccionarEmpleadosDialog extends ConsumerStatefulWidget {
  final int localId;
  final List<UsuarioEntity> empleadosDisponibles;

  const SeleccionarEmpleadosDialog({
    super.key,
    required this.localId,
    required this.empleadosDisponibles,
  });

  @override
  ConsumerState<SeleccionarEmpleadosDialog> createState() => _SeleccionarEmpleadosDialogState();
}

class _SeleccionarEmpleadosDialogState extends ConsumerState<SeleccionarEmpleadosDialog> {
  final Set<int> _seleccionados = {};

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.person_add_rounded, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            'Agregar Empleados',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: widget.empleadosDisponibles.isEmpty
            ? Center(
                child: Text(
                  'No hay empleados disponibles para asignar.',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              )
            : ListView.builder(
                itemCount: widget.empleadosDisponibles.length,
                itemBuilder: (context, index) {
                  final empleado = widget.empleadosDisponibles[index];
                  final isSelected = _seleccionados.contains(empleado.id);

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) {
                      setState(() {
                        if (isSelected) {
                          _seleccionados.remove(empleado.id);
                        } else {
                          _seleccionados.add(empleado.id);
                        }
                      });
                    },
                    title: Text(empleado.nombre),
                    subtitle: Text('Rol: ${empleado.rol}'),
                    secondary: CircleAvatar(
                      backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _seleccionados.isEmpty
              ? null
              : () {
                  Navigator.pop(context, _seleccionados.toList());
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: Text(
            'Asignar (${_seleccionados.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}