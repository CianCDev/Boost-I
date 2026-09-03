import 'dart:ui';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Agregar Empleados',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // CONTENIDO
                Expanded(
                  child: widget.empleadosDisponibles.isEmpty
                      ? Center(
                          child: Text(
                            'No hay empleados disponibles.',
                            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
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
                              title: Text(
                                empleado.nombre,
                                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                              ),
                              subtitle: Text(
                                'Rol: ${empleado.rol}',
                                style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                              ),
                              secondary: CircleAvatar(
                                backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.person,
                                  color: const Color(0xFF8B5CF6),
                                  size: 20,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              checkColor: Colors.white,
                              activeColor: const Color(0xFF8B5CF6),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 16),
                // BOTONES
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _seleccionados.isEmpty
                            ? null
                            : () => Navigator.pop(context, _seleccionados.toList()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Asignar (${_seleccionados.length})',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}