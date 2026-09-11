import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart';
// ✅ Import eliminado: package:isar/isar.dart

import '../../providers/clientes/clientes_provider.dart';

class ClienteFormDialog extends ConsumerStatefulWidget {
  final ClienteEntity? clienteExistente;

  const ClienteFormDialog({super.key, this.clienteExistente});

  @override
  ConsumerState<ClienteFormDialog> createState() => _ClienteFormDialogState();

  static Future<void> mostrar(BuildContext context, {ClienteEntity? cliente}) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ClienteFormDialog(clienteExistente: cliente),
    );
  }
}

class _ClienteFormDialogState extends ConsumerState<ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nombreController;
  late TextEditingController _documentoController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _direccionController;
  late TextEditingController _notasController;
  
  bool _isFrecuente = false;
  bool _isActivo = true;
  bool _isGuardando = false;

  @override
  void initState() {
    super.initState();
    final c = widget.clienteExistente;
    _nombreController = TextEditingController(text: c?.nombre ?? '');
    _documentoController = TextEditingController(text: c?.documento ?? '');
    _telefonoController = TextEditingController(text: c?.telefono ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _direccionController = TextEditingController(text: c?.direccion ?? '');
    _notasController = TextEditingController(text: c?.notas ?? '');
    _isFrecuente = c?.frecuente ?? false;
    _isActivo = c?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGuardando = true);

    try {
      // 🔥 Obtener el local activo para asignar el local_id correcto
      final isar = ref.read(isarServiceProvider);
      final localActivo = await isar.obtenerLocalActivo();

      if (localActivo == null || localActivo.supabaseId == null) {
        throw Exception('No se encontró un local activo con Supabase ID. Sincroniza primero el local.');
      }

      final isEdit = widget.clienteExistente != null;
      final cliente = ClienteEntity()
        // ✅ Cambio clave: usar 0 en lugar de Isar.autoIncrement
        ..id = isEdit ? widget.clienteExistente!.id : 0 
        ..supabaseId = isEdit ? widget.clienteExistente!.supabaseId : null
        // 🔥 Forzar el local_id al local activo actual (nunca usar el antiguo)
        ..localSupabaseId = localActivo.supabaseId
        ..localId = localActivo.id
        ..fechaRegistro = isEdit ? widget.clienteExistente!.fechaRegistro : DateTime.now()
        ..syncStatus = 'pending'
        ..nombre = _nombreController.text.trim()
        ..documento = _documentoController.text.trim().isEmpty ? null : _documentoController.text.trim()
        ..telefono = _telefonoController.text.trim().isEmpty ? null : _telefonoController.text.trim()
        ..email = _emailController.text.trim().isEmpty ? null : _emailController.text.trim()
        ..direccion = _direccionController.text.trim().isEmpty ? null : _direccionController.text.trim()
        ..notas = _notasController.text.trim().isEmpty ? null : _notasController.text.trim()
        ..frecuente = _isFrecuente
        ..activo = _isActivo
        ..updatedAt = DateTime.now();

      await ref.read(clientesProvider.notifier).guardarCliente(cliente);

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGuardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.clienteExistente != null;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 12 : 32,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 8,
      child: Container(
        width: isMobile ? double.infinity : 500,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[900]!.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: Color(0xFF8B5CF6),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEdit ? 'Editar Cliente' : 'Nuevo Cliente',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close_rounded,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            tooltip: 'Cerrar',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _nombreController,
                                label: 'Nombre completo *',
                                icon: Icons.person_outline_rounded,
                                validator: (v) => v!.isEmpty ? 'Requerido' : null,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _documentoController,
                                      label: 'CI / RIF',
                                      icon: Icons.badge_outlined,
                                      isDark: isDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _telefonoController,
                                      label: 'Teléfono',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _emailController,
                                label: 'Correo electrónico',
                                icon: Icons.email_outlined,
                                keyboardType: TextInputType.emailAddress,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _direccionController,
                                label: 'Dirección',
                                icon: Icons.location_on_outlined,
                                isDark: isDark,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _notasController,
                                label: 'Notas',
                                icon: Icons.note_outlined,
                                isDark: isDark,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text('Cliente Frecuente', style: TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: const Text('Destacar en listas y reportes', style: TextStyle(fontSize: 12)),
                                activeThumbColor: const Color(0xFFF59E0B),
                                value: _isFrecuente,
                                onChanged: (v) => setState(() => _isFrecuente = v),
                              ),
                              if (isEdit)
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: const Text('Cliente Activo', style: TextStyle(fontWeight: FontWeight.w500)),
                                  activeThumbColor: const Color(0xFF10B981),
                                  value: _isActivo,
                                  onChanged: (v) => setState(() => _isActivo = v),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: _isGuardando ? null : _guardar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isGuardando
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                isEdit ? 'Guardar Cambios' : 'Crear Cliente',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isDark = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isDark ? Colors.white54 : Colors.black54),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.white12 : Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      ),
    );
  }
}