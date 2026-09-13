// lib/features/pos/presentation/widgets/locales/seleccionar_empleados_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';

class SeleccionarEmpleadosDialog extends ConsumerStatefulWidget {
  final int localId;
  final List<UsuarioEntity> empleadosDisponibles;

  const SeleccionarEmpleadosDialog({
    super.key,
    required this.localId,
    required this.empleadosDisponibles,
  });

  @override
  ConsumerState<SeleccionarEmpleadosDialog> createState() =>
      _SeleccionarEmpleadosDialogState();
}

class _SeleccionarEmpleadosDialogState
    extends ConsumerState<SeleccionarEmpleadosDialog> {
  final Set<int> _seleccionados = {};

  void _toggleEmpleado(int id) {
    setState(() {
      if (_seleccionados.contains(id)) {
        _seleccionados.remove(id);
      } else {
        _seleccionados.add(id);
      }
    });
  }

  void _seleccionarTodos() {
    setState(() {
      if (_seleccionados.length == widget.empleadosDisponibles.length) {
        _seleccionados.clear();
      } else {
        _seleccionados.addAll(widget.empleadosDisponibles.map((e) => e.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final allSelected = _seleccionados.length ==
            widget.empleadosDisponibles.length &&
        widget.empleadosDisponibles.isNotEmpty;

    return GlassDialog(
      maxWidth: 500,
      maxHeightFactor: 0.8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DialogHeader(
              icon: Icons.person_add_rounded,
              title: 'Agregar Empleados',
              subtitle:
                  '${widget.empleadosDisponibles.length} disponibles',
            ),
            const SizedBox(height: 12),

            // Select all
            if (widget.empleadosDisponibles.isNotEmpty)
              TextButton.icon(
                onPressed: _seleccionarTodos,
                icon: Icon(
                  allSelected
                      ? Icons.check_box_rounded
                      : Icons.check_box_outline_blank_rounded,
                  size: 18,
                ),
                label: Text(allSelected
                    ? 'Deseleccionar todos'
                    : 'Seleccionar todos'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  alignment: Alignment.centerLeft,
                ),
              ),

            const SizedBox(height: 4),

            Flexible(
              child: widget.empleadosDisponibles.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline_rounded,
                                size: 48,
                                color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(
                              'No hay empleados disponibles',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const BouncingScrollPhysics(),
                      itemCount: widget.empleadosDisponibles.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.4),
                      ),
                      itemBuilder: (context, index) {
                        final empleado = widget.empleadosDisponibles[index];
                        final selected = _seleccionados.contains(empleado.id);

                        return _EmpleadoTile(
                          empleado: empleado,
                          selected: selected,
                          onTap: () => _toggleEmpleado(empleado.id),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),

            // ===== BOTONES =====
            Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
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
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: MouseRegion(
                    cursor: _seleccionados.isEmpty
                        ? SystemMouseCursors.forbidden
                        : SystemMouseCursors.click,
                    child: ElevatedButton(
                      onPressed: _seleccionados.isEmpty
                          ? null
                          : () =>
                              Navigator.pop(context, _seleccionados.toList()),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmpleadoTile extends StatefulWidget {
  final UsuarioEntity empleado;
  final bool selected;
  final VoidCallback onTap;

  const _EmpleadoTile({
    required this.empleado,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_EmpleadoTile> createState() => _EmpleadoTileState();
}

class _EmpleadoTileState extends State<_EmpleadoTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: widget.selected
                      ? const Color(0xFF8B5CF6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: widget.selected
                        ? const Color(0xFF8B5CF6)
                        : colorScheme.outlineVariant,
                    width: 1.6,
                  ),
                ),
                child: widget.selected
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 16,
                backgroundColor:
                    const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                child: Text(
                  widget.empleado.nombre.isNotEmpty
                      ? widget.empleado.nombre[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.empleado.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'Rol: ${widget.empleado.rol}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}