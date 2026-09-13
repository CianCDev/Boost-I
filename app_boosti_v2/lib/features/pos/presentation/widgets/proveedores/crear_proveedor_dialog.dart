// lib/features/pos/presentation/widgets/proveedores/crear_proveedor_dialog.dart
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';

class CrearProveedorDialog extends ConsumerStatefulWidget {
  final ProveedorEntity? proveedor;

  const CrearProveedorDialog({super.key, this.proveedor});

  @override
  ConsumerState<CrearProveedorDialog> createState() =>
      _CrearProveedorDialogState();
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

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);

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
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final nombre = _nombreController.text.trim();
    final email = _emailController.text.trim();
    final direccion = _direccionController.text.trim();

    final proveedor = ProveedorEntity()
      ..nombre = nombre
      ..cedula = _cedulaController.text.trim().isNotEmpty
          ? _cedulaController.text.trim()
          : null
      ..telefono = _telefonoController.text.trim().isNotEmpty
          ? _telefonoController.text.trim()
          : null
      ..direccion = direccion.isNotEmpty ? direccion : null
      ..email = email.isNotEmpty ? email : null
      ..empresa = nombre
      ..activo = _activo
      ..supabaseId = widget.proveedor?.supabaseId
      ..sincronizado = false
      ..fechaSincronizacion = null;

    if (widget.proveedor != null) {
      proveedor.id = widget.proveedor!.id;
    }

    try {
      await ref.read(proveedoresProvider.notifier).guardarProveedor(proveedor);
      final syncService = SyncService();
      await syncService.sincronizarProveedoresPendientes();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.proveedor == null
                      ? 'Proveedor creado y sincronizado'
                      : 'Proveedor actualizado y sincronizado',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: _colorSuccess,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.proveedor != null;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 560,
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DialogHeader(
                icon: esEdicion
                    ? Icons.edit_rounded
                    : Icons.add_business_rounded,
                title: esEdicion ? 'Editar Proveedor' : 'Nuevo Proveedor',
                subtitle: esEdicion
                    ? 'Actualiza la información del proveedor'
                    : 'Registra un nuevo proveedor para tus pedidos',
              ),
              const SizedBox(height: 24),

              _field(
                controller: _nombreController,
                label: 'Nombre de la empresa *',
                icon: Icons.business_center_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 14),

              _field(
                controller: _cedulaController,
                label: 'RIF / Cédula',
                icon: Icons.badge_rounded,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  if (v.trim().length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _field(
                controller: _telefonoController,
                label: 'Teléfono',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final digits = v.replaceAll(RegExp(r'\D'), '');
                  if (digits.length < 7) return 'Mínimo 7 dígitos';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              _field(
                controller: _emailController,
                label: 'Correo electrónico',
                icon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null;
                  final re = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                  return re.hasMatch(v.trim()) ? null : 'Correo inválido';
                },
              ),
              const SizedBox(height: 14),

              _field(
                controller: _direccionController,
                label: 'Dirección',
                icon: Icons.location_on_rounded,
                maxLines: 2,
              ),
              const SizedBox(height: 20),

              // ===== TOGGLE ACTIVO =====
              _ActivoToggle(
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
              ),
              const SizedBox(height: 24),

              // ===== BOTONES =====
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: TextButton(
                        onPressed: _isSaving
                            ? null
                            : () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: MouseRegion(
                      cursor: _isSaving
                          ? SystemMouseCursors.forbidden
                          : SystemMouseCursors.click,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _colorPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                esEdicion
                                    ? 'Guardar Cambios'
                                    : 'Crear Proveedor',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: _colorPrimary),
        filled: true,
        fillColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : const Color(0xFFF9FAFB),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _colorPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}

/// Toggle reutilizable de activo/inactivo para diálogos.
class _ActivoToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ActivoToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const color = Color(0xFF10B981);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: value
              ? color.withValues(alpha: 0.1)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF9FAFB)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: value
                ? color.withValues(alpha: 0.3)
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: SwitchListTile(
          title: Text(
            value ? 'Proveedor Activo' : 'Proveedor Inactivo',
            style: TextStyle(
              color: value
                  ? (isDark
                      ? const Color(0xFF34D399)
                      : const Color(0xFF059669))
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            value
                ? 'Disponible para crear pedidos'
                : 'Oculto de la selección de pedidos',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          value: value,
          onChanged: onChanged,
          activeThumbColor: color,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ),
    );
  }
}