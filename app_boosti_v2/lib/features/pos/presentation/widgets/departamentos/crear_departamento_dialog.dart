// lib/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart

/// Diálogo para crear o editar un departamento.
/// Permite seleccionar un local asociado (opcional) y activar/desactivar.
/// Se integra con el provider de departamentos y locales para persistencia local y sincronización con Supabase.
library;


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/input_decoration_helper.dart';

class CrearDepartamentoDialog extends ConsumerStatefulWidget {
  final DepartamentoEntity? departamento;
  final int? localIdPreseleccionado;

  const CrearDepartamentoDialog({
    super.key,
    this.departamento,
    this.localIdPreseleccionado,
  });

  @override
  ConsumerState<CrearDepartamentoDialog> createState() =>
      _CrearDepartamentoDialogState();
}

class _CrearDepartamentoDialogState
    extends ConsumerState<CrearDepartamentoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  int? _localIdSeleccionado;
  bool _activo = true;
  bool _isSaving = false;
  bool _esDesdeLocal = false;

  @override
  void initState() {
    super.initState();
    final d = widget.departamento;
    _nombreController = TextEditingController(text: d?.nombre ?? '');
    _descripcionController = TextEditingController(text: d?.descripcion ?? '');
    _localIdSeleccionado = d?.localId ?? widget.localIdPreseleccionado;
    _activo = d?.activo ?? true;
    _esDesdeLocal = widget.localIdPreseleccionado != null;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  /// Guarda el departamento (crea o actualiza) y cierra el diálogo.
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los campos marcados en rojo.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final departamento = DepartamentoEntity()
      ..nombre = _nombreController.text.trim()
      ..descripcion = _descripcionController.text.trim().isNotEmpty
          ? _descripcionController.text.trim()
          : null
      ..localId = _localIdSeleccionado
      ..activo = _activo
      ..supabaseId = widget.departamento?.supabaseId
      ..sincronizado = false;

    if (widget.departamento != null) {
      departamento.id = widget.departamento!.id;
    }

    try {
      await ref.read(guardarDepartamentoProvider(departamento).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.departamento == null
                ? '✅ Departamento creado correctamente'
                : '✅ Departamento actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.departamento != null;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final localesAsync = ref.watch(localesProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TÍTULO
                Row(
                  children: [
                    Icon(
                      esEdicion
                          ? Icons.edit_rounded
                          : Icons.add_business_rounded,
                      color: const Color(0xFF8B5CF6),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        esEdicion ? 'Editar Departamento' : 'Nuevo Departamento',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded,
                          color: colorScheme.onSurfaceVariant),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // NOMBRE
                TextFormField(
                  controller: _nombreController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecorationHelper.build(
                    context: context,
                    label: 'Nombre del Departamento *',
                    prefixIcon: Icons.business_center_rounded,
                    isDark: isDark,
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                // DESCRIPCIÓN
                TextFormField(
                  controller: _descripcionController,
                  style: TextStyle(color: colorScheme.onSurface),
                  maxLines: 3,
                  decoration: InputDecorationHelper.build(
                    context: context,
                    label: 'Descripción',
                    prefixIcon: Icons.description_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 16),

                // CAMPO LOCAL ASOCIADO
                localesAsync.when(
                  data: (locales) {
                    if (_esDesdeLocal) {
                      final local = locales.firstWhere(
                        (l) => l.id == _localIdSeleccionado,
                        orElse: () => LocalEntity()
                          ..nombre = 'Local no encontrado',
                      );
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.storefront_rounded,
                                color: colorScheme.primary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Local asociado',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    local.nombre,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.lock_outline_rounded,
                                color: colorScheme.onSurfaceVariant),
                          ],
                        ),
                      );
                    }

                    return DropdownButtonFormField<int?>(
                      initialValue: _localIdSeleccionado,
                      hint: Text(
                        'Seleccionar local (opcional)',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('Ninguno (Global)'),
                        ),
                        ...locales.map((local) {
                          return DropdownMenuItem<int?>(
                            value: local.id,
                            child: Text(local.nombre),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _localIdSeleccionado = value;
                        });
                      },
                      decoration: InputDecorationHelper.build(
                        context: context,
                        label: 'Local asociado',
                        prefixIcon: Icons.storefront_rounded,
                        isDark: isDark,
                      ),
                      isExpanded: true,
                      dropdownColor: colorScheme.surface,
                      style: TextStyle(color: colorScheme.onSurface),
                    );
                  },
                  loading: () => const Text('Cargando locales...'),
                  error: (err, _) => Text(
                    'Error al cargar locales: $err',
                    style: TextStyle(color: colorScheme.error),
                  ),
                ),
                const SizedBox(height: 16),

                // ACTIVO
                SwitchListTile(
                  title: Text(
                    'Departamento activo',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  value: _activo,
                  onChanged: (value) => setState(() => _activo = value),
                  activeThumbColor: const Color(0xFF8B5CF6),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // BOTONES
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSaving ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: colorScheme.outline),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(esEdicion ? 'Actualizar' : 'Crear'),
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