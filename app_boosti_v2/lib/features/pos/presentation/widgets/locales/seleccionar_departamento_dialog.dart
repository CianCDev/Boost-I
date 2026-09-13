// lib/features/pos/presentation/widgets/locales/seleccionar_departamento_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';

class SeleccionarDepartamentoDialog extends ConsumerStatefulWidget {
  final int? localId;

  const SeleccionarDepartamentoDialog({super.key, this.localId});

  @override
  ConsumerState<SeleccionarDepartamentoDialog> createState() =>
      _SeleccionarDepartamentoDialogState();
}

class _SeleccionarDepartamentoDialogState
    extends ConsumerState<SeleccionarDepartamentoDialog> {
  @override
  Widget build(BuildContext context) {
    final departamentosAsync = ref.watch(todosDepartamentosProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GlassDialog(
      maxWidth: 500,
      maxHeightFactor: 0.8,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.add_business_rounded,
              title: 'Agregar Departamento',
              subtitle: 'Asigna un departamento existente a este local',
            ),
            const SizedBox(height: 20),
            Flexible(
              child: departamentosAsync.when(
                data: (departamentos) {
                  final disponibles = departamentos
                      .where((d) => d.localId != widget.localId)
                      .toList();

                  if (disponibles.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_center_outlined,
                                size: 48,
                                color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(
                              'No hay departamentos disponibles',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 16),
                            _primaryButton(
                              label: 'Crear nuevo departamento',
                              icon: Icons.add_rounded,
                              onPressed: _crearNuevoDepartamento,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: disponibles.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: colorScheme.outlineVariant.withValues(alpha: 0.4),
                    ),
                    itemBuilder: (context, index) {
                      final d = disponibles[index];
                      return _DepartamentoTile(
                        nombre: d.nombre,
                        descripcion: d.descripcion,
                        onTap: () {
                          d.localId = widget.localId;
                          ref
                              .read(guardarDepartamentoProvider(d).future)
                              .then((_) {
                            if (mounted) Navigator.pop(context, d);
                          });
                        },
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
            const SizedBox(height: 12),
            if (departamentosAsync.hasValue &&
                departamentosAsync.value!.isNotEmpty)
              TextButton.icon(
                onPressed: _crearNuevoDepartamento,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Crear nuevo departamento'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> _crearNuevoDepartamento() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => CrearDepartamentoDialog(
        localIdPreseleccionado: widget.localId,
      ),
    );
    if (result == true) {
      ref.invalidate(todosDepartamentosProvider);
      if (mounted) setState(() {});
    }
  }
}

class _DepartamentoTile extends StatefulWidget {
  final String nombre;
  final String? descripcion;
  final VoidCallback onTap;

  const _DepartamentoTile({
    required this.nombre,
    this.descripcion,
    required this.onTap,
  });

  @override
  State<_DepartamentoTile> createState() => _DepartamentoTileState();
}

class _DepartamentoTileState extends State<_DepartamentoTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                child: const Icon(Icons.business_center_rounded,
                    size: 16, color: Color(0xFF8B5CF6)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (widget.descripcion != null &&
                        widget.descripcion!.isNotEmpty)
                      Text(
                        widget.descripcion!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: _hovered
                    ? const Color(0xFF8B5CF6)
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}