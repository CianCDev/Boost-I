// lib/features/pos/presentation/widgets/proveedores/crear_proveedor_dialog.dart
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';

class CrearProveedorDialog extends ConsumerStatefulWidget {
  final ProveedorEntity? proveedor;

  const CrearProveedorDialog({super.key, this.proveedor});

  @override
  ConsumerState<CrearProveedorDialog> createState() => _CrearProveedorDialogState();
}

class _CrearProveedorDialogState extends ConsumerState<CrearProveedorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _cedulaController;
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;
  late TextEditingController _emailController;
  bool _activo = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.proveedor;
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _cedulaController = TextEditingController(text: p?.cedula ?? '');
    _telefonoController = TextEditingController(text: p?.telefono ?? '');
    _direccionController = TextEditingController(text: p?.direccion ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _activo = p?.activo ?? true;

    debugPrint('📧 [Init] Email cargado: "${_emailController.text}"');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los campos marcados en rojo.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final email = _emailController.text.trim();
    final direccion = _direccionController.text.trim();
    debugPrint('📧 [Guardar] Email ingresado: "$email"');
    debugPrint('📍 [Guardar] Dirección ingresada: "$direccion"');

    final nombre = _nombreController.text.trim();
    final proveedor = ProveedorEntity()
      ..nombre = nombre
      ..cedula = _cedulaController.text.trim().isNotEmpty ? _cedulaController.text.trim() : null
      ..telefono = _telefonoController.text.trim().isNotEmpty ? _telefonoController.text.trim() : null
      ..direccion = direccion.isNotEmpty ? direccion : null
      ..email = email.isNotEmpty ? email : null
      ..empresa = nombre
      ..activo = _activo
      ..supabaseId = widget.proveedor?.supabaseId
      ..sincronizado = false // 🔥 FORZAR pendiente
      ..fechaSincronizacion = null;

    if (widget.proveedor != null) {
      proveedor.id = widget.proveedor!.id;
    }

    try {
      debugPrint('💾 Guardando proveedor en Isar...');
      // 1. Guardar en Isar
      await ref.read(guardarProveedorProvider(proveedor).future);

      // Verificar que se guardó correctamente
      final isar = ref.read(isarServiceProvider);
      final verificado = await isar.obtenerProveedorPorId(proveedor.id);
      debugPrint('📦 [Verificación] Proveedor guardado: ${verificado?.nombre}, Email: ${verificado?.email}, Sincronizado: ${verificado?.sincronizado}');

      // 2. Sincronizar AHORA (no en segundo plano)
      debugPrint('🔄 Iniciando sincronización de proveedores pendientes...');
      final syncService = SyncService();
      await syncService.sincronizarProveedoresPendientes();
      debugPrint('✅ Sincronización completada.');

      // 3. Cerrar con éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.proveedor == null
                  ? '✅ Proveedor creado y sincronizado'
                  : '✅ Proveedor actualizado y sincronizado',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ Error al guardar/sincronizar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.proveedor != null;
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
                        esEdicion ? 'Editar Proveedor' : 'Nuevo Proveedor',
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

                // Campos del formulario
                TextFormField(
                  controller: _nombreController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Nombre de la empresa *',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.business_center_rounded, color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _cedulaController,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'RIF / Cédula',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.badge_rounded, color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    if (v.trim().length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _telefonoController,
                  style: TextStyle(color: colorScheme.onSurface),
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.phone_rounded, color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final digits = v.replaceAll(RegExp(r'\D'), '');
                    if (digits.length < 7) return 'Mínimo 7 dígitos';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  style: TextStyle(color: colorScheme.onSurface),
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.email_rounded, color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _direccionController,
                  style: TextStyle(color: colorScheme.onSurface),
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    prefixIcon: Icon(Icons.location_on_rounded, color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: colorScheme.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  title: Text(
                    'Proveedor activo',
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