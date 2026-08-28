import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';

import 'package:app_boosti_v2/features/pos/presentation/utils/input_decoration_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart'; // ✅ Importación necesaria

class CrearLocalDialog extends ConsumerStatefulWidget {
  final LocalEntity? local;

  const CrearLocalDialog({super.key, this.local});

  @override
  ConsumerState<CrearLocalDialog> createState() => _CrearLocalDialogState();
}

class _CrearLocalDialogState extends ConsumerState<CrearLocalDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _direccionController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  bool _activo = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final l = widget.local;
    _nombreController = TextEditingController(text: l?.nombre ?? '');
    _direccionController = TextEditingController(text: l?.direccion ?? '');
    _telefonoController = TextEditingController(text: l?.telefono ?? '');
    _emailController = TextEditingController(text: l?.email ?? '');
    _activo = l?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    super.dispose();
  }

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

    final local = LocalEntity()
      ..nombre = _nombreController.text.trim()
      ..direccion = _direccionController.text.trim().isNotEmpty
          ? _direccionController.text.trim()
          : null
      ..telefono = _telefonoController.text.trim().isNotEmpty
          ? _telefonoController.text.trim()
          : null
      ..email = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null
      ..activo = _activo
      ..supabaseId = widget.local?.supabaseId
      ..sincronizado = false;

    if (widget.local != null) {
      local.id = widget.local!.id;
    }

    try {
      await ref.read(guardarLocalProvider(local).future);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.local == null
                ? '✅ Local creado correctamente'
                : '✅ Local actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
      // Sincronizar en segundo plano
      _sincronizarEnSegundoPlano();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al guardar: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  void _sincronizarEnSegundoPlano() {
    Future.microtask(() async {
      try {
        // ✅ CORRECCIÓN: instanciar correctamente SyncService
        await SyncService().sincronizarLocalesPendientes();
        debugPrint('✅ Locales sincronizados con Supabase en segundo plano');
      } catch (e) {
        debugPrint('⚠️ Error al sincronizar locales en segundo plano: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.local != null;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08),
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
                // Título
                Row(
                  children: [
                    Icon(
                      esEdicion ? Icons.edit_rounded : Icons.add_business_rounded,
                      color: const Color(0xFF8B5CF6),
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        esEdicion ? 'Editar Local' : 'Nuevo Local',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Campos
                TextFormField(
                  controller: _nombreController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecorationHelper.build(
                    context: context,
                    label: 'Nombre del Local *',
                    prefixIcon: Icons.storefront_rounded,
                    isDark: isDark,
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _direccionController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecorationHelper.build(
                    context: context,
                    label: 'Dirección',
                    prefixIcon: Icons.location_on_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefonoController,
                  style: TextStyle(color: colorScheme.onSurface),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecorationHelper.build(
                    context: context,
                    label: 'Teléfono',
                    prefixIcon: Icons.phone_rounded,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: colorScheme.onSurface),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecorationHelper.build(
                    context: context,
                    label: 'Correo electrónico',
                    prefixIcon: Icons.email_rounded,
                    isDark: isDark,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                    if (!emailRegExp.hasMatch(v.trim())) {
                      return 'Correo inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: Text(
                    'Local activo',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  value: _activo,
                  onChanged: (value) => setState(() => _activo = value),
                  activeThumbColor: const Color(0xFF8B5CF6),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 24),

                // Botones
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
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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