// lib/features/pos/presentation/widgets/locales/crear_local_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../dialogos_genericos/error_dialog.dart';
import '../dialogos_genericos/succes_dialog.dart';

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
  late TextEditingController _rifController;
  bool _activo = true;
  bool _isSaving = false;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);

  @override
  void initState() {
    super.initState();
    final l = widget.local;
    _nombreController = TextEditingController(text: l?.nombre ?? '');
    _direccionController = TextEditingController(text: l?.direccion ?? '');
    _telefonoController = TextEditingController(text: l?.telefono ?? '');
    _emailController = TextEditingController(text: l?.email ?? '');
    _rifController = TextEditingController(text: l?.rif ?? '');
    _activo = l?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _rifController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

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
      ..rif = _rifController.text.trim().isNotEmpty
          ? _rifController.text.trim()
          : null
      ..activo = _activo
      ..supabaseId = widget.local?.supabaseId
      ..sincronizado = false;

    if (widget.local != null) local.id = widget.local!.id;

    try {
      await ref.read(guardarLocalProvider(local).future);
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (_) => SuccessDialog(
          title: widget.local == null ? 'Local creado' : 'Local actualizado',
          content: 'Se ha guardado correctamente.',
        ),
      );
      if (mounted) Navigator.pop(context, true);
      Future.microtask(() async {
        try {
          await SyncService().sincronizarLocalesPendientes();
        } catch (_) {}
      });
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) =>
              ErrorDialog(title: 'Error al guardar', content: e.toString()),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.local != null;
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 520,
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
                title: esEdicion ? 'Editar Local' : 'Nuevo Local',
                subtitle: esEdicion
                    ? 'Actualiza la información del local'
                    : 'Registra un nuevo punto de venta',
              ),
              const SizedBox(height: 24),

              _field(
                controller: _nombreController,
                label: 'Nombre del Local *',
                icon: Icons.storefront_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _direccionController,
                label: 'Dirección',
                icon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 14),
              _field(
                controller: _telefonoController,
                label: 'Teléfono',
                icon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
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
                controller: _rifController,
                label: 'RIF',
                icon: Icons.assignment_rounded,
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
                                    : 'Crear Local',
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
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: const Icon(Icons.circle, size: 0), // placeholder
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
            value ? 'Local Activo' : 'Local Inactivo',
            style: TextStyle(
              color: value
                  ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                  : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            value
                ? 'Visible en operaciones y POS'
                : 'Oculto de la operación actual',
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