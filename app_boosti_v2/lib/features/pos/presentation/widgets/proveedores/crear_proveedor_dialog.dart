// lib/features/pos/presentation/widgets/proveedores/crear_proveedor_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/active_toggle.dart';
import '../common/persona_form_template.dart';

class CrearProveedorDialog extends ConsumerStatefulWidget {
  final ProveedorEntity? proveedor;

  const CrearProveedorDialog({super.key, this.proveedor});

  @override
  ConsumerState<CrearProveedorDialog> createState() =>
      _CrearProveedorDialogState();
}

class _CrearProveedorDialogState extends ConsumerState<CrearProveedorDialog> {
  final _formKey = GlobalKey<FormState>();

  // ── Controllers ──
  late TextEditingController _nombreController;
  late TextEditingController _documentoController;
  late TextEditingController _rifController;
  late TextEditingController _empresaController;
  late TextEditingController _telefonoController;
  late TextEditingController _emailController;
  late TextEditingController _direccionController;

  // ── Estado ──
  String? _tipoDocumento;
  bool _activo = true;
  bool _isSaving = false;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);

  // ═══════════════════════════════════════════════════════════════
  // LIFECYCLE
  // ═══════════════════════════════════════════════════════════════

  @override
  void initState() {
    super.initState();
    final p = widget.proveedor;

    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _documentoController =
        TextEditingController(text: p?.documento?.toString() ?? '');
    _rifController = TextEditingController(text: p?.rif ?? '');
    _empresaController = TextEditingController(text: p?.empresa ?? '');
    _telefonoController = TextEditingController(text: p?.telefono ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');
    _direccionController = TextEditingController(text: p?.direccion ?? '');

    _tipoDocumento = p?.tipoDocumento;
    _activo = p?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _documentoController.dispose();
    _rifController.dispose();
    _empresaController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  // ═══════════════════════════════════════════════════════════════
  // GUARDAR
  // ═══════════════════════════════════════════════════════════════

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final isEdit = widget.proveedor != null;
    final nombre = _nombreController.text.trim();
    final empresa = _empresaController.text.trim();
    final rif = _rifController.text.trim();
    final telefono = _telefonoController.text.trim();
    final email = _emailController.text.trim();
    final direccion = _direccionController.text.trim();

    final proveedor = ProveedorEntity()
      ..nombre = nombre
      // ── Identificación (NUEVO) ──
      ..tipoDocumento = _tipoDocumento
      ..documento = int.tryParse(_documentoController.text.trim())
      ..rif = rif.isEmpty ? null : rif.toUpperCase()
      // ── Empresa (ahora explícita, no auto-asignada) ──
      ..empresa = empresa.isEmpty ? null : empresa
      // ── Contacto ──
      ..telefono = telefono.isEmpty ? null : telefono
      ..email = email.isEmpty ? null : email
      ..direccion = direccion.isEmpty ? null : direccion
      // ── Estado ──
      ..activo = _activo
      // ── Sync ──
      ..supabaseId = widget.proveedor?.supabaseId
      ..sincronizado = false
      ..fechaSincronizacion = null
      // ── Legacy: preservar `cedula` en edición, null en creación ──
      ..cedula = isEdit ? widget.proveedor!.cedula : null;

    if (isEdit) {
      proveedor.id = widget.proveedor!.id;
    }

    try {
      await ref.read(proveedoresProvider.notifier).guardarProveedor(proveedor);

      // Intento de sync (no bloquea si falla)
      try {
        final syncService = SyncService();
        await syncService.sincronizarProveedoresPendientes();
      } catch (_) {
        // El sync silencioso se ignora: el proveedor ya quedó local
      }

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
                  isEdit
                      ? 'Proveedor actualizado'
                      : 'Proveedor creado',
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

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.proveedor != null;

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
              // ── Header ──
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

              // ── Sección: Identificación ──
              FormSection(
                title: 'Identificación',
                icon: Icons.badge_rounded,
                accentColor: _colorPrimary,
                children: [
                  PersonaTextField(
                    controller: _nombreController,
                    label: 'Nombre de la empresa *',
                    icon: Icons.business_center_rounded,
                    accentColor: _colorPrimary,
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                  ),
                  const SizedBox(height: 14),
                  DocumentoIdentidadField(
                    tipoDocumento: _tipoDocumento,
                    onTipoDocumentoChanged: (v) =>
                        setState(() => _tipoDocumento = v),
                    numeroController: _documentoController,
                    accentColor: _colorPrimary,
                  ),
                  const SizedBox(height: 14),
                  RifField(
                    controller: _rifController,
                    accentColor: _colorPrimary,
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── Sección: Contacto y empresa ──
              FormSection(
                title: 'Contacto y empresa',
                icon: Icons.contact_mail_rounded,
                accentColor: _colorPrimary,
                children: [
                  PersonaTextField(
                    controller: _empresaController,
                    label: 'Razón social / Empresa',
                    icon: Icons.storefront_rounded,
                    accentColor: _colorPrimary,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),
                  PersonaTextField(
                    controller: _telefonoController,
                    label: 'Teléfono',
                    icon: Icons.phone_rounded,
                    accentColor: _colorPrimary,
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
                    icon: Icons.email_rounded,
                    accentColor: _colorPrimary,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return null;
                      final re = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      return re.hasMatch(v.trim()) ? null : 'Correo inválido';
                    },
                  ),
                  const SizedBox(height: 14),
                  PersonaTextField(
                    controller: _direccionController,
                    label: 'Dirección',
                    icon: Icons.location_on_rounded,
                    accentColor: _colorPrimary,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // ── Sección: Estado ──
              ActiveToggle(
                value: _activo,
                onChanged: (v) => setState(() => _activo = v),
                activeLabel: 'Proveedor Activo',
                inactiveLabel: 'Proveedor Inactivo',
                activeSubtitle: 'Disponible para crear pedidos',
                inactiveSubtitle: 'Oculto de la selección de pedidos',
                activeColor: _colorSuccess,
              ),
              const SizedBox(height: 24),

              // ── Acciones ──
              FormActions(
                isSaving: _isSaving,
                confirmLabel:
                    esEdicion ? 'Guardar Cambios' : 'Crear Proveedor',
                accentColor: _colorPrimary,
                onCancel: () => Navigator.pop(context),
                onConfirm: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}