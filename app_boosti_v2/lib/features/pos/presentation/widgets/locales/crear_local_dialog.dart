import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
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
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrige los campos requeridos.'),
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
      ..rif = _rifController.text.trim().isNotEmpty
          ? _rifController.text.trim()
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
        await showDialog(
          context: context,
          builder: (_) => SuccessDialog(
            title: widget.local == null ? 'Local creado' : 'Local actualizado',
            content: 'Se ha guardado correctamente.',
          ),
        );
        if (mounted) Navigator.pop(context, true);
      }
      Future.microtask(() async {
        try {
          await SyncService().sincronizarLocalesPendientes();
        } catch (_) {}
      });
    } catch (e) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => ErrorDialog(title: 'Error al guardar', content: e.toString()),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.local != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores base dinámicos para inputs
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
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            esEdicion ? Icons.edit_rounded : Icons.add_business_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            esEdicion ? 'Editar Local' : 'Nuevo Local',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
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
                    const SizedBox(height: 24),

                    // NOMBRE
                    TextFormField(
                      controller: _nombreController,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: _inputDecor('Nombre del Local *', Icons.storefront_rounded, fillColor, borderColor, isDark),
                      validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // DIRECCIÓN
                    TextFormField(
                      controller: _direccionController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _inputDecor('Dirección', Icons.location_on_rounded, fillColor, borderColor, isDark),
                    ),
                    const SizedBox(height: 16),

                    // TELÉFONO
                    TextFormField(
                      controller: _telefonoController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      keyboardType: TextInputType.phone,
                      decoration: _inputDecor('Teléfono', Icons.phone_rounded, fillColor, borderColor, isDark),
                    ),
                    const SizedBox(height: 16),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      keyboardType: TextInputType.emailAddress,
                      decoration: _inputDecor('Correo electrónico', Icons.email_rounded, fillColor, borderColor, isDark),
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

                    // RIF
                    TextFormField(
                      controller: _rifController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _inputDecor('RIF', Icons.assignment_rounded, fillColor, borderColor, isDark),
                    ),
                    const SizedBox(height: 24),

                    // ACTIVO
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
                          _activo ? 'Local Activo' : 'Local Inactivo',
                          style: TextStyle(
                            color: _activo
                                ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
                                : (isDark ? Colors.white70 : Colors.black54),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    esEdicion ? 'Guardar Cambios' : 'Crear Local',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label, IconData icon, Color fill, Color border, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: isDark ? Colors.white60 : Colors.black54,
        fontWeight: FontWeight.normal,
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6)),
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}