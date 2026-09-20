// lib/features/pos/presentation/widgets/clientes/cliente_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../../data/Local/entities/cliente_entity.dart';
import '../../providers/clientes/clientes_provider.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/active_toggle.dart';
import '../common/persona_form_template.dart';

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
///
/// **Refactor**: Usa el template `persona_form_template.dart` para
/// mantener consistencia visual con Proveedores y Gestión de Personal.
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

  // ── Controllers ──
  late TextEditingController _nombreController;
  late TextEditingController _documentoController;
  late TextEditingController _rifController;
  late TextEditingController _razonSocialController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _direccionController;
  late TextEditingController _notasController;

  // ── Estado ──
  String? _tipoDocumento;
  bool _esMayorista = false;
  bool _isFrecuente = false;
  bool _isActivo = true;
  bool _isGuardando = false;

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
    final colorScheme = Theme.of(context).colorScheme;
    final isEdit = widget.clienteExistente != null;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return GlassDialog(
      maxWidth: 560,
      maxHeightFactor: 0.92,
      accentColor: _colorCliente,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 12 : 32,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═══ HEADER ═══
              DialogHeader(
                icon: isEdit
                    ? Icons.edit_rounded
                    : Icons.person_add_alt_1_rounded,
                title: isEdit ? 'Editar Cliente' : 'Nuevo Cliente',
                subtitle: isEdit
                    ? 'Actualiza los datos del cliente'
                    : 'Registra un nuevo cliente',
                color: _colorCliente,
              ),
              const SizedBox(height: 20),

              // ═══ SECCIONES SCROLLABLES ═══
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─── IDENTIFICACIÓN ───
                      FormSection(
                        title: 'Identificación',
                        icon: Icons.badge_rounded,
                        accentColor: _colorCliente,
                        children: [
                          PersonaTextField(
                            controller: _nombreController,
                            label: 'Nombre completo *',
                            icon: Icons.person_outline_rounded,
                            accentColor: _colorCliente,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? 'Requerido'
                                    : null,
                          ),
                          const SizedBox(height: 14),
                          DocumentoIdentidadField(
                            tipoDocumento: _tipoDocumento,
                            onTipoDocumentoChanged: (v) =>
                                setState(() => _tipoDocumento = v),
                            numeroController: _documentoController,
                            accentColor: _colorCliente,
                          ),
                          const SizedBox(height: 14),
                          RifField(
                            controller: _rifController,
                            accentColor: _colorCliente,
                            obligatorio: _esMayorista,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // ─── CONTACTO ───
                      FormSection(
                        title: 'Contacto',
                        icon: Icons.contact_mail_rounded,
                        accentColor: _colorCliente,
                        children: [
                          PersonaTextField(
                            controller: _telefonoController,
                            label: 'Teléfono',
                            icon: Icons.phone_outlined,
                            accentColor: _colorCliente,
                            keyboardType: TextInputType.phone,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              final digits = v.replaceAll(RegExp(r'\D'), '');
                              if (digits.length < 7) return 'Mínimo 7 dígitos';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          PersonaTextField(
                            controller: _emailController,
                            label: 'Correo electrónico',
                            icon: Icons.email_outlined,
                            accentColor: _colorCliente,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return null;
                              final re = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                              return re.hasMatch(v.trim())
                                  ? null
                                  : 'Correo inválido';
                            },
                          ),
                          const SizedBox(height: 14),
                          PersonaTextField(
                            controller: _direccionController,
                            label: 'Dirección',
                            icon: Icons.location_on_outlined,
                            accentColor: _colorCliente,
                            maxLines: 2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // ─── DATOS COMERCIALES ───
                      FormSection(
                        title: 'Datos comerciales',
                        icon: Icons.storefront_rounded,
                        accentColor: _colorMayorista,
                        children: [
                          PersonaTextField(
                            controller: _razonSocialController,
                            label: _esMayorista
                                ? 'Razón social *'
                                : 'Razón social (opcional)',
                            icon: Icons.business_outlined,
                            accentColor: _colorCliente,
                            textCapitalization: TextCapitalization.words,
                            validator: (v) {
                              if (_esMayorista &&
                                  (v == null || v.trim().isEmpty)) {
                                return 'Razón social obligatoria para mayoristas';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          _buildMayoristaToggle(colorScheme),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // ─── NOTAS ───
                      FormSection(
                        title: 'Notas',
                        icon: Icons.note_alt_outlined,
                        accentColor: _colorCliente,
                        children: [
                          PersonaTextField(
                            controller: _notasController,
                            label: 'Observaciones',
                            icon: Icons.note_outlined,
                            accentColor: _colorCliente,
                            maxLines: 3,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      // ─── PREFERENCIAS ───
                      ActiveToggle(
                        value: _isFrecuente,
                        onChanged: (v) => setState(() => _isFrecuente = v),
                        activeLabel: 'Cliente frecuente',
                        inactiveLabel: 'Marcar como frecuente',
                        activeSubtitle: 'Destacado en listas y reportes',
                        inactiveSubtitle: 'No destacado actualmente',
                        activeColor: _colorFrecuente,
                      ),
                      if (isEdit) ...[
                        const SizedBox(height: 12),
                        ActiveToggle(
                          value: _isActivo,
                          onChanged: (v) => setState(() => _isActivo = v),
                          activeLabel: 'Cliente activo',
                          inactiveLabel: 'Cliente inactivo',
                          activeSubtitle: 'Disponible para ventas',
                          inactiveSubtitle: 'Oculto del catálogo',
                          activeColor: const Color(0xFF10B981),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ═══ ACCIONES ═══
              FormActions(
                isSaving: _isGuardando,
                confirmLabel: isEdit ? 'Guardar Cambios' : 'Crear Cliente',
                accentColor: _colorCliente,
                onCancel: () => Navigator.pop(context),
                onConfirm: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // TOGGLE MAYORISTA (custom — específico del módulo Clientes)
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
}