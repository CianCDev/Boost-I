import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart';
import 'package:isar/isar.dart';
import '../../providers/clientes/clientes_provider.dart';

class ClienteFormDialog extends ConsumerStatefulWidget {
  final ClienteEntity? clienteExistente;

  const ClienteFormDialog({super.key, this.clienteExistente});

  @override
  ConsumerState<ClienteFormDialog> createState() => _ClienteFormDialogState();

  /// Devuelve el cliente guardado (o null si canceló).
  static Future<ClienteEntity?> mostrar(
    BuildContext context, {
    ClienteEntity? cliente,
  }) {
    return showDialog<ClienteEntity>(
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

  static const Color _colorCliente = Color(0xFF8B5CF6);
  static const Color _colorFrecuente = Color(0xFFF59E0B);

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
      final isar = ref.read(isarServiceProvider);
      final localActivo = await isar.obtenerLocalActivo();

      if (localActivo == null || localActivo.supabaseId == null) {
        throw Exception(
            'No se encontró un local activo con Supabase ID. Sincroniza primero el local.');
      }

      final isEdit = widget.clienteExistente != null;
      final cliente = ClienteEntity()
        ..id = isEdit ? widget.clienteExistente!.id : Isar.autoIncrement
        ..supabaseId =
            isEdit ? widget.clienteExistente!.supabaseId : null
        ..localSupabaseId = localActivo.supabaseId
        ..localId = localActivo.id
        ..fechaRegistro = isEdit
            ? widget.clienteExistente!.fechaRegistro
            : DateTime.now()
        ..syncStatus = 'pending'
        ..nombre = _nombreController.text.trim()
        ..documento = _documentoController.text.trim().isEmpty
            ? null
            : _documentoController.text.trim()
        ..telefono = _telefonoController.text.trim().isEmpty
            ? null
            : _telefonoController.text.trim()
        ..email = _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim()
        ..direccion = _direccionController.text.trim().isEmpty
            ? null
            : _direccionController.text.trim()
        ..notas = _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim()
        ..frecuente = _isFrecuente
        ..activo = _isActivo
        ..updatedAt = DateTime.now();

      // Capturamos la entidad guardada (ya con id asignado)
      final guardado =
          await ref.read(clientesProvider.notifier).guardarCliente(cliente);

      if (!mounted) return;
      // ✅ Devolvemos el cliente guardado al padre
      Navigator.pop(context, guardado);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isGuardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.clienteExistente != null;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    // Superficie del diálogo — usa colorScheme en lugar de grey[900]
    final surfaceColor = isDark
        ? colorScheme.surface.withValues(alpha: 0.92)
        : Colors.white.withValues(alpha: 0.92);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 12 : 32,
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 520,
          maxHeight: screenSize.height * 0.9,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ===== CABECERA =====
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _colorCliente.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_add_alt_1_rounded,
                              color: _colorCliente,
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
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close_rounded,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              tooltip: 'Cerrar',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ===== CAMPOS =====
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _nombreController,
                                label: 'Nombre completo *',
                                icon: Icons.person_outline_rounded,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                        ? 'Requerido'
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _documentoController,
                                      label: 'CI / RIF',
                                      icon: Icons.badge_outlined,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildTextField(
                                      controller: _telefonoController,
                                      label: 'Teléfono',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
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
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _direccionController,
                                label: 'Dirección',
                                icon: Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 16),
                              _buildTextField(
                                controller: _notasController,
                                label: 'Notas',
                                icon: Icons.note_outlined,
                                maxLines: 2,
                              ),
                              const SizedBox(height: 16),
                              SwitchListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  'Cliente Frecuente',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  'Destacar en listas y reportes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                activeThumbColor: _colorFrecuente,
                                value: _isFrecuente,
                                onChanged: (v) =>
                                    setState(() => _isFrecuente = v),
                              ),
                              if (isEdit)
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  title: Text(
                                    'Cliente Activo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  activeThumbColor: const Color(0xFF10B981),
                                  value: _isActivo,
                                  onChanged: (v) =>
                                      setState(() => _isActivo = v),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ===== BOTÓN GUARDAR =====
                      SizedBox(
                        height: 56,
                        child: MouseRegion(
                          cursor: _isGuardando
                              ? SystemMouseCursors.forbidden
                              : SystemMouseCursors.click,
                          child: ElevatedButton(
                            onPressed: _isGuardando ? null : _guardar,
                            style: ButtonStyle(
                              backgroundColor:
                                  const WidgetStatePropertyAll(_colorCliente),
                              foregroundColor: const WidgetStatePropertyAll(
                                  Colors.white),
                              shape: WidgetStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              elevation: const WidgetStatePropertyAll(0),
                              overlayColor: WidgetStatePropertyAll(
                                Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            child: _isGuardando
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    isEdit
                                        ? 'Guardar Cambios'
                                        : 'Crear Cliente',
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
    int maxLines = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _colorCliente, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
    );
  }
}