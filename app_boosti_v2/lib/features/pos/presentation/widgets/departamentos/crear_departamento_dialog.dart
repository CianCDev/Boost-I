// lib/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import '../../providers/usuario_provider.dart';
import '../dialogos_genericos/error_dialog.dart';
import '../dialogos_genericos/succes_dialog.dart';

class CrearDepartamentoDialog extends ConsumerStatefulWidget {
  final DepartamentoEntity? departamento;
  final int? localIdPreseleccionado;

  const CrearDepartamentoDialog({
    super.key,
    this.departamento,
    this.localIdPreseleccionado,
  });

  @override
  ConsumerState<CrearDepartamentoDialog> createState() => _CrearDepartamentoDialogState();
}

class _CrearDepartamentoDialogState extends ConsumerState<CrearDepartamentoDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  int? _localIdSeleccionado;
  int? _usuarioIdSeleccionado;
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
    _usuarioIdSeleccionado = d?.usuarioId;
    _activo = d?.activo ?? true;
    _esDesdeLocal = widget.localIdPreseleccionado != null;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, corrige los campos requeridos.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    final departamento = DepartamentoEntity()
      ..nombre = _nombreController.text.trim()
      ..descripcion = _descripcionController.text.trim().isNotEmpty ? _descripcionController.text.trim() : null
      ..localId = _localIdSeleccionado
      ..usuarioId = _usuarioIdSeleccionado
      ..activo = _activo
      ..supabaseId = widget.departamento?.supabaseId
      ..sincronizado = false;

    if (widget.departamento != null) departamento.id = widget.departamento!.id;

    try {
      await ref.read(guardarDepartamentoProvider(departamento).future);
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => SuccessDialog(
            title: widget.departamento == null ? 'Departamento creado' : 'Departamento actualizado',
            content: 'Se ha guardado correctamente.',
          ),
        );
        if (mounted) Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        await showDialog(context: context, builder: (_) => ErrorDialog(title: 'Error al guardar', content: e.toString()));
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.departamento != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localesAsync = ref.watch(localesProvider);
    final usuariosAsync = ref.watch(usuariosProvider);

    final usuariosFiltrados = usuariosAsync.when(
      data: (usuarios) => _localIdSeleccionado == null ? usuarios : usuarios.where((u) => u.localId == _localIdSeleccionado).toList(),
      loading: () => <UsuarioEntity>[],
      error: (_, __) => <UsuarioEntity>[],
    );

    // Colores base dinámicos para los inputs
    final fillColor = isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF9FAFB);
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB);

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
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A).withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.98),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.1), blurRadius: 40, offset: const Offset(0, 10)),
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 5)),
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4))],
                          ),
                          child: Icon(esEdicion ? Icons.edit_rounded : Icons.add_business_rounded, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            esEdicion ? 'Editar Departamento' : 'Nuevo Departamento',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: isDark ? Colors.white : const Color(0xFF111827), letterSpacing: -0.5),
                          ),
                        ),
                        IconButton(icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // NOMBRE
                    TextFormField(
                      controller: _nombreController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                      decoration: _inputDecor('Nombre del Departamento *', Icons.business_center_rounded, fillColor, borderColor, isDark),
                      validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // DESCRIPCIÓN
                    TextFormField(
                      controller: _descripcionController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      maxLines: 3,
                      decoration: _inputDecor('Descripción', Icons.description_rounded, fillColor, borderColor, isDark),
                    ),
                    const SizedBox(height: 16),

                    // LOCAL
                    localesAsync.when(
                      data: (locales) {
                        if (_esDesdeLocal) {
                          final local = locales.firstWhere((l) => l.id == _localIdSeleccionado, orElse: () => LocalEntity()..nombre = 'Local no encontrado');
                          return _buildReadOnlyTile('Local asociado', local.nombre, Icons.storefront_rounded, isDark);
                        }
                        return DropdownButtonFormField<int?>(
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down_rounded, color: isDark ? Colors.white54 : Colors.black54),
                          dropdownColor: isDark ? const Color(0xFF262626) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                          decoration: _inputDecor('Local asociado (Opcional)', Icons.storefront_rounded, fillColor, borderColor, isDark),
                          initialValue: _localIdSeleccionado,
                          items: [
                            const DropdownMenuItem<int?>(value: null, child: Text('Ninguno (Global)')),
                            ...locales.map((l) => DropdownMenuItem<int?>(value: l.id, child: Text(l.nombre))),
                          ],
                          onChanged: (val) => setState(() { _localIdSeleccionado = val; _usuarioIdSeleccionado = null; }),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(height: 16),

                    // ENCARGADO
                    usuariosAsync.when(
                      data: (_) {
                        if (usuariosFiltrados.isEmpty && _localIdSeleccionado != null) {
                          return _buildReadOnlyTile('Encargado', 'No hay usuarios en este local', Icons.person_off_rounded, isDark);
                        }
                        return DropdownButtonFormField<int?>(
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down_rounded, color: isDark ? Colors.white54 : Colors.black54),
                          dropdownColor: isDark ? const Color(0xFF262626) : Colors.white,
                          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                          decoration: _inputDecor('Encargado (Opcional)', Icons.person_rounded, fillColor, borderColor, isDark),
                          initialValue: _usuarioIdSeleccionado,
                          items: [
                            const DropdownMenuItem<int?>(value: null, child: Text('Sin encargado')),
                            ...usuariosFiltrados.map((u) => DropdownMenuItem<int?>(
                              value: u.id,
                              child: Text('${u.nombre} (${u.rol})'),
                            )),
                          ],
                          onChanged: (val) => setState(() => _usuarioIdSeleccionado = val),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Text('Error: $err', style: const TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(height: 24),

                    // ACTIVO (Tarjeta decorada y viva)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _activo
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _activo
                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                              : isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: SwitchListTile(
                        title: Text(
                          _activo ? 'Departamento Activo' : 'Departamento Inactivo',
                          style: TextStyle(
                            color: _activo ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669)) : (isDark ? Colors.white70 : Colors.black54),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        value: _activo,
                        onChanged: (value) => setState(() => _activo = value),
                        activeThumbColor: const Color(0xFF10B981),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // BOTONES
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _isSaving ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text('Cancelar', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSaving ? null : _guardar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                                : Text(esEdicion ? 'Guardar Cambios' : 'Crear Departamento', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon, Color fill, Color border, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontWeight: FontWeight.normal),
      prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6)),
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: border, width: 1)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }

  Widget _buildReadOnlyTile(String label, String value, IconData icon, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF8B5CF6)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54, fontWeight: FontWeight.w600)),
                Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
          ),
          Icon(Icons.lock_outline_rounded, color: isDark ? Colors.white30 : Colors.black26, size: 20),
        ],
      ),
    );
  }
}