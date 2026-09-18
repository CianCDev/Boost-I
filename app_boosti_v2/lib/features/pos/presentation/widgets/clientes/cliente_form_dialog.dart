// lib/features/pos/presentation/widgets/clientes/cliente_form_dialog.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../data/Local/entities/cliente_entity.dart';
import '../../providers/clientes/clientes_provider.dart';

/// Diálogo de creación / edición de cliente.
///
/// **Campos clave**:
///   - Tipo de documento: V | E | J | G | P | C
///   - Número de documento (int)
///   - RIF (texto, ej: `J-40123456-7`)
///   - Razón social (si es empresa)
///   - Toggle "Es mayorista" (activa campos B2B)
///
/// **Validación condicional**:
/// Si `esMayorista == true` → RIF y razón social son obligatorios.
class ClienteFormDialog extends ConsumerStatefulWidget {
  final ClienteEntity? clienteExistente;

  const ClienteFormDialog({super.key, this.clienteExistente});

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

  @override
  ConsumerState<ClienteFormDialog> createState() => _ClienteFormDialogState();
}

class _ClienteFormDialogState extends ConsumerState<ClienteFormDialog> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nombreController;
  late TextEditingController _documentoController;
  late TextEditingController _rifController;
  late TextEditingController _razonSocialController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _direccionController;
  late TextEditingController _notasController;

  // Estado
  String? _tipoDocumento;
  bool _esMayorista = false;
  bool _isFrecuente = false;
  bool _isActivo = true;
  bool _isGuardando = false;

  // Tipos de documento soportados (venezolanos)
  static const _tiposDocumento = <String, String>{
    'V': 'Venezolano',
    'E': 'Extranjero',
    'J': 'Jurídico (RIF)',
    'G': 'Gubernamental',
    'P': 'Pasaporte',
    'C': 'Comuna',
  };

  static const Color _colorCliente = Color(0xFF8B5CF6);
  static const Color _colorFrecuente = Color(0xFFF59E0B);
  static const Color _colorMayorista = Color(0xFF10B981);

  // ═══════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    final c = widget.clienteExistente;

    _nombreController = TextEditingController(text: c?.nombre ?? '');
    _documentoController = TextEditingController(
      text: c?.documento?.toString() ?? '',
    );
    _rifController = TextEditingController(text: c?.rif ?? '');
    _razonSocialController = TextEditingController(text: c?.razonSocial ?? '');
    _telefonoController = TextEditingController(text: c?.telefono ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _direccionController = TextEditingController(text: c?.direccion ?? '');
    _notasController = TextEditingController(text: c?.notas ?? '');

    _tipoDocumento = c?.tipoDocumento;
    _esMayorista = c?.esMayorista ?? false;
    _isFrecuente = c?.frecuente ?? false;
    _isActivo = c?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _rifController.dispose();
    _razonSocialController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // GUARDAR
  // ═══════════════════════════════════════════════════════════════

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isGuardando = true);

    try {
      final isar = ref.read(isarServiceProvider);
      final localActivo = await isar.obtenerLocalActivo();

      if (localActivo == null || localActivo.supabaseId == null) {
        throw Exception(
          'No se encontró un local activo con Supabase ID. '
          'Sincroniza primero el local.',
        );
      }

      final isEdit = widget.clienteExistente != null;
      final cliente = ClienteEntity()
        ..id = isEdit ? widget.clienteExistente!.id : Isar.autoIncrement
        ..supabaseId = isEdit ? widget.clienteExistente!.supabaseId : null
        ..localSupabaseId = localActivo.supabaseId
        ..localId = localActivo.id
        ..fechaRegistro = isEdit
            ? widget.clienteExistente!.fechaRegistro
            : DateTime.now()
        ..syncStatus = 'pending'
        ..nombre = _nombreController.text.trim()
        // Documento: tipo + número
        ..tipoDocumento = _tipoDocumento
        ..documento = int.tryParse(_documentoController.text.trim())
        // RIF
        ..rif = _rifController.text.trim().isEmpty
            ? null
            : _rifController.text.trim().toUpperCase()
        // Razón social
        ..razonSocial = _razonSocialController.text.trim().isEmpty
            ? null
            : _razonSocialController.text.trim()
        // Mayorista
        ..esMayorista = _esMayorista
        // Contacto
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

      // Preservar campos de mayorista avanzados si estamos editando
      if (isEdit) {
        cliente.limiteCredito = widget.clienteExistente!.limiteCredito;
        cliente.diasCredito = widget.clienteExistente!.diasCredito;
        cliente.descuentoPreferencial =
            widget.clienteExistente!.descuentoPreferencial;
      }

      final guardado =
          await ref.read(clientesProvider.notifier).guardarCliente(cliente);

      if (!mounted) return;
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

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.clienteExistente != null;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

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
          maxWidth: isMobile ? double.infinity : 560,
          maxHeight: screenSize.height * 0.92,
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
                      _buildHeader(colorScheme, isMobile, isEdit),
                      const SizedBox(height: 20),
                      Flexible(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // ── Nombre ──
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

                              // ── Tipo doc + Número ──
                              _buildDocumentoRow(),
                              const SizedBox(height: 16),

                              // ── RIF (siempre visible, obligatorio si mayorista) ──
                              _buildRifField(),
                              const SizedBox(height: 16),

                              // ── Razón social ──
                              _buildRazonSocialField(),
                              const SizedBox(height: 16),

                              // ── Toggle mayorista ──
                              _buildMayoristaToggle(colorScheme),
                              const SizedBox(height: 16),

                              // ── Contacto ──
                              _buildTextField(
                                controller: _telefonoController,
                                label: 'Teléfono',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
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

                              // ── Frecuente ──
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
                      const SizedBox(height: 20),
                      _buildSaveButton(isEdit),
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

  // ═══════════════════════════════════════════════════════════════
  // HEADER
  // ═══════════════════════════════════════════════════════════════

  Widget _buildHeader(ColorScheme cs, bool isMobile, bool isEdit) {
    return Row(
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
              color: cs.onSurface,
            ),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: cs.onSurfaceVariant,
            ),
            tooltip: 'Cerrar',
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // DOCUMENTO: TIPO + NÚMERO
  // ═══════════════════════════════════════════════════════════════

  Widget _buildDocumentoRow() {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dropdown de tipo
        SizedBox(
          width: 110,
          child: DropdownButtonFormField<String>(
            initialValue: _tipoDocumento,
            isExpanded: true,
            decoration: _inputDecoration(
              label: 'Tipo',
              icon: Icons.badge_outlined,
              cs: cs,
            ),
            hint: const Text('V/E/J…', style: TextStyle(fontSize: 12)),
            items: _tiposDocumento.entries.map((e) {
              return DropdownMenuItem<String>(
                value: e.key,
                child: Text(
                  e.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
            onChanged: (v) => setState(() => _tipoDocumento = v),
          ),
        ),
        const SizedBox(width: 10),
        // Número
        Expanded(
          child: _buildTextField(
            controller: _documentoController,
            label: 'Número',
            icon: Icons.numbers_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RIF
  // ═══════════════════════════════════════════════════════════════

  Widget _buildRifField() {
    // Si es mayorista, el RIF es obligatorio
    return _buildTextField(
      controller: _rifController,
      label: _esMayorista ? 'RIF *' : 'RIF (opcional)',
      icon: Icons.receipt_outlined,
      textCapitalization: TextCapitalization.characters,
      validator: (v) {
        final val = (v ?? '').trim();
        if (_esMayorista && val.isEmpty) {
          return 'RIF obligatorio para mayoristas';
        }
        // Formato: J-12345678-9
        if (val.isNotEmpty) {
          final regex = RegExp(r'^[VEJGP]-\d{6,10}(-\d)?$');
          if (!regex.hasMatch(val.toUpperCase())) {
            return 'Formato: J-12345678-9';
          }
        }
        return null;
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // RAZÓN SOCIAL
  // ═══════════════════════════════════════════════════════════════

  Widget _buildRazonSocialField() {
    return _buildTextField(
      controller: _razonSocialController,
      label: _esMayorista ? 'Razón social *' : 'Razón social (opcional)',
      icon: Icons.business_outlined,
      textCapitalization: TextCapitalization.words,
      validator: (v) {
        final val = (v ?? '').trim();
        if (_esMayorista && val.isEmpty) {
          return 'Razón social obligatoria para mayoristas';
        }
        return null;
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOGGLE MAYORISTA
  // ═══════════════════════════════════════════════════════════════

  Widget _buildMayoristaToggle(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: _esMayorista
            ? _colorMayorista.withValues(alpha: 0.08)
            : cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _esMayorista
              ? _colorMayorista.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.4),
          width: _esMayorista ? 1.5 : 1,
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        title: Row(
          children: [
            Icon(
              Icons.storefront_rounded,
              size: 18,
              color: _esMayorista ? _colorMayorista : cs.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Cliente mayorista',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: _esMayorista ? _colorMayorista : cs.onSurface,
              ),
            ),
          ],
        ),
        subtitle: Text(
          _esMayorista
              ? 'RIF y razón social son obligatorios'
              : 'Habilita venta al por mayor para este cliente',
          style: TextStyle(
            fontSize: 11,
            color: _esMayorista
                ? _colorMayorista.withValues(alpha: 0.9)
                : cs.onSurfaceVariant,
          ),
        ),
        activeThumbColor: _colorMayorista,
        value: _esMayorista,
        onChanged: (v) => setState(() => _esMayorista = v),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTÓN GUARDAR
  // ═══════════════════════════════════════════════════════════════

  Widget _buildSaveButton(bool isEdit) {
    return SizedBox(
      height: 56,
      child: MouseRegion(
        cursor: _isGuardando
            ? SystemMouseCursors.forbidden
            : SystemMouseCursors.click,
        child: ElevatedButton(
          onPressed: _isGuardando ? null : _guardar,
          style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(_colorCliente),
            foregroundColor: const WidgetStatePropertyAll(Colors.white),
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
                  isEdit ? 'Guardar Cambios' : 'Crear Cliente',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required ColorScheme cs,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: cs.onSurfaceVariant),
      prefixIcon: Icon(icon, color: cs.onSurfaceVariant),
      filled: true,
      fillColor: isDark
          ? cs.surfaceContainerHighest.withValues(alpha: 0.5)
          : cs.surfaceContainerHighest.withValues(alpha: 0.4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _colorCliente, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: cs.error, width: 1.5),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: _inputDecoration(
        label: label,
        icon: icon,
        cs: colorScheme,
      ),
    );
  }
}