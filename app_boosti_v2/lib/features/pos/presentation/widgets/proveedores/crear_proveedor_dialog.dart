import 'dart:ui';
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
        const SnackBar(content: Text('Por favor, corrige los campos requeridos.'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isSaving = true);

    final email = _emailController.text.trim();
    final direccion = _direccionController.text.trim();

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
      ..sincronizado = false
      ..fechaSincronizacion = null;

    if (widget.proveedor != null) {
      proveedor.id = widget.proveedor!.id;
    }

    try {
      await ref.read(guardarProveedorProvider(proveedor).future);
      final syncService = SyncService();
      await syncService.sincronizarProveedoresPendientes();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.proveedor == null
                  ? '✅ Proveedor creado y sincronizado'
                  : '✅ Proveedor actualizado y sincronizado',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.proveedor != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

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
              maxWidth: 600,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: -10,
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
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            esEdicion ? Icons.edit_rounded : Icons.add_business_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            esEdicion ? 'Editar Proveedor' : 'Nuevo Proveedor',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 18 : 22,
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
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _inputDecor('Nombre de la empresa *', Icons.business_center_rounded, isDark),
                      validator: (v) => v!.trim().isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),

                    // RIF
                    TextFormField(
                      controller: _cedulaController,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _inputDecor('RIF / Cédula', Icons.badge_rounded, isDark),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        if (v.trim().length < 6) return 'Mínimo 6 caracteres';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // TELÉFONO
                    TextFormField(
                      controller: _telefonoController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _inputDecor('Teléfono', Icons.phone_rounded, isDark),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final digits = v.replaceAll(RegExp(r'\D'), '');
                        if (digits.length < 7) return 'Mínimo 7 dígitos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // CORREO
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _inputDecor('Correo electrónico', Icons.email_rounded, isDark),
                    ),
                    const SizedBox(height: 16),

                    // DIRECCIÓN
                    TextFormField(
                      controller: _direccionController,
                      maxLines: 2,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                      decoration: _inputDecor('Dirección', Icons.location_on_rounded, isDark),
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
                          _activo ? 'Proveedor Activo' : 'Proveedor Inactivo',
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
                                    esEdicion ? 'Guardar Cambios' : 'Crear Proveedor',
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

  InputDecoration _inputDecor(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white60 : Colors.black54),
      prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6)),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}