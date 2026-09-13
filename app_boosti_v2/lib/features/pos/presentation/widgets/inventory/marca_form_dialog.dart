// lib/features/pos/presentation/widgets/marcas/marca_form_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/Local/entities/marca_entity.dart';
import '../../../data/Local/entities/proveedor_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/marca_provider.dart';
import '../../utils/responsive_helper.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../proveedores/crear_proveedor_dialog.dart';

class MarcaFormDialog extends ConsumerStatefulWidget {
  final MarcaEntity? marca;
  final VoidCallback onGuardar;

  const MarcaFormDialog({
    super.key,
    this.marca,
    required this.onGuardar,
  });

  @override
  ConsumerState<MarcaFormDialog> createState() => _MarcaFormDialogState();
}

class _MarcaFormDialogState extends ConsumerState<MarcaFormDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _proveedorBusquedaController =
      TextEditingController();

  String? _logoUrl;
  XFile? _imagenSeleccionada;
  bool _subiendoImagen = false;
  bool _guardando = false;

  ProveedorEntity? _proveedorSeleccionado;
  List<ProveedorEntity> _proveedores = [];
  bool _cargandoProveedores = false;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    final marca = widget.marca;
    if (marca != null) {
      _nombreController.text = marca.nombre;
      _descripcionController.text = marca.descripcion ?? '';
      _logoUrl = marca.logoUrl;
      _cargarProveedorSeleccionado(marca.proveedorId);
    }
    _cargarProveedores();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _proveedorBusquedaController.dispose();
    super.dispose();
  }

  // ==================== PROVEEDORES ====================
  Future<void> _cargarProveedores() async {
    setState(() => _cargandoProveedores = true);
    try {
      final isar = IsarService();
      final proveedores = await isar.obtenerProveedores(soloActivos: true);
      if (!mounted) return;
      setState(() => _proveedores = proveedores);
    } catch (e) {
      debugPrint('Error cargando proveedores: $e');
    } finally {
      if (mounted) setState(() => _cargandoProveedores = false);
    }
  }

  Future<void> _cargarProveedorSeleccionado(String? proveedorId) async {
    if (proveedorId == null || proveedorId.isEmpty) return;
    try {
      final isar = IsarService();
      final proveedor = await isar.obtenerProveedorPorSupabaseId(proveedorId);
      if (proveedor != null && mounted) {
        setState(() => _proveedorSeleccionado = proveedor);
      }
    } catch (e) {
      debugPrint('Error cargando proveedor seleccionado: $e');
    }
  }

  Future<void> _crearProveedorRapido() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CrearProveedorDialog(),
    );
    if (result == true) {
      await _cargarProveedores();
      if (_proveedores.isNotEmpty && mounted) {
        setState(() {
          _proveedorSeleccionado = _proveedores.last;
        });
      }
    }
  }

  void _seleccionarProveedor(ProveedorEntity? proveedor) {
    setState(() => _proveedorSeleccionado = proveedor);
  }

  // ==================== IMAGEN ====================
  Future<void> _seleccionarImagen(ImageSource source) async {
    if (!await _checkPermission()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Se necesita permiso para acceder a la galería/cámara'),
        ),
      );
      return;
    }

    setState(() => _subiendoImagen = true);
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() {
          _imagenSeleccionada = image;
          _logoUrl = image.path;
        });
      }
    } catch (e) {
      if (mounted) _mostrarError('Error al seleccionar imagen: $e');
    } finally {
      if (mounted) setState(() => _subiendoImagen = false);
    }
  }

  Future<bool> _checkPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  void _limpiarImagen() {
    setState(() {
      _imagenSeleccionada = null;
      _logoUrl = null;
    });
  }

  // ==================== SUBIR IMAGEN ====================
  Future<String?> _uploadLogo(File image, String nombre) async {
    try {
      final ext = image.path.split('.').last;
      final fileName =
          'marca_${nombre}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Supabase.instance.client.storage
          .from('marcas')
          .upload(fileName, image);
      final publicUrl = Supabase.instance.client.storage
          .from('marcas')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Error subiendo logo: $e');
      return null;
    }
  }

  // ==================== GUARDAR ====================
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      _mostrarError('Completa todos los campos obligatorios.');
      return;
    }

    setState(() => _guardando = true);

    try {
      String? logoUrlFinal = _logoUrl;

      if (_imagenSeleccionada != null) {
        setState(() => _subiendoImagen = true);
        try {
          final url = await _uploadLogo(
            File(_imagenSeleccionada!.path),
            _nombreController.text.trim(),
          );
          if (url != null && url.isNotEmpty) {
            logoUrlFinal = url;
          } else {
            logoUrlFinal =
                _logoUrl?.startsWith('http') == true ? _logoUrl : null;
          }
        } catch (_) {
          logoUrlFinal =
              _logoUrl?.startsWith('http') == true ? _logoUrl : null;
        } finally {
          if (mounted) setState(() => _subiendoImagen = false);
        }
      }

      final marca = widget.marca ?? MarcaEntity();
      if (widget.marca == null) {
        marca.supabaseId = DateTime.now().millisecondsSinceEpoch.toString();
      }
      marca.nombre = _nombreController.text.trim();
      marca.descripcion = _descripcionController.text.trim().isEmpty
          ? null
          : _descripcionController.text.trim();
      marca.logoUrl = logoUrlFinal;
      marca.proveedorId = _proveedorSeleccionado?.supabaseId;
      marca.activo = true;
      marca.syncStatus = 'pending';
      marca.updatedAt = DateTime.now();

      final notifier = ref.read(marcasNotifierProvider.notifier);
      if (widget.marca == null) {
        await notifier.crearMarca(marca);
      } else {
        await notifier.actualizarMarca(marca);
      }

      widget.onGuardar();

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          content: Text(
            'Marca "${marca.nombre}" ${widget.marca == null ? 'creada' : 'actualizada'}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: _colorSuccess,
        ),
      );
    } catch (e) {
      if (mounted) _mostrarError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: _colorDanger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final esEdicion = widget.marca != null;

    return GlassDialog(
      maxWidth: 520,
      maxHeightFactor: 0.9,
      accentColor: colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 20 : 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DialogHeader(
                icon: esEdicion
                    ? Icons.edit_outlined
                    : Icons.add_circle_outline,
                title: esEdicion ? 'Editar Marca' : 'Nueva Marca',
                subtitle: esEdicion
                    ? 'Actualiza los datos de la marca'
                    : 'Registra una nueva marca en el catálogo',
              ),
              const SizedBox(height: 20),

              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _campoNombre(colorScheme, isDark),
                      const SizedBox(height: 16),
                      _campoDescripcion(colorScheme, isDark),
                      const SizedBox(height: 16),
                      _buildImagenSection(colorScheme, isDark, isMobile),
                      const SizedBox(height: 16),
                      _buildSelectorProveedor(colorScheme, isDark, isMobile),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ===== BOTONES =====
              Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      cursor: _guardando
                          ? SystemMouseCursors.forbidden
                          : SystemMouseCursors.click,
                      child: SizedBox(
                        height: 52,
                        child: TextButton(
                          onPressed: _guardando
                              ? null
                              : () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: MouseRegion(
                      cursor: _guardando
                          ? SystemMouseCursors.forbidden
                          : SystemMouseCursors.click,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _guardando ? null : _guardar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _guardando
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  widget.marca == null
                                      ? 'Crear Marca'
                                      : 'Guardar Cambios',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
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

  // ==================== CAMPOS ====================
  Widget _campoNombre(ColorScheme colorScheme, bool isDark) {
    return TextFormField(
      controller: _nombreController,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: _inputDecor(
        label: 'Nombre de la marca *',
        icon: Icons.branding_watermark_outlined,
        colorScheme: colorScheme,
        isDark: isDark,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Requerido';
        return null;
      },
    );
  }

  Widget _campoDescripcion(ColorScheme colorScheme, bool isDark) {
    return TextFormField(
      controller: _descripcionController,
      maxLines: 3,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: _inputDecor(
        label: 'Descripción (opcional)',
        icon: Icons.description_outlined,
        colorScheme: colorScheme,
        isDark: isDark,
        alignLabel: true,
      ),
    );
  }

  // ==================== IMAGEN ====================
  Widget _buildImagenSection(
      ColorScheme colorScheme, bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined,
                  color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Logo de la marca',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _imagenSeleccionada != null
                  ? Image.file(
                      File(_imagenSeleccionada!.path),
                      fit: BoxFit.cover,
                    )
                  : _logoUrl != null && _logoUrl!.startsWith('http')
                      ? Image.network(
                          _logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.branding_watermark_rounded,
                            size: 64,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Icon(
                          Icons.branding_watermark_rounded,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildImageButton(
                icon: Icons.photo_library,
                label: 'Galería',
                onPressed: () => _seleccionarImagen(ImageSource.gallery),
                color: colorScheme.primary,
              ),
              _buildImageButton(
                icon: Icons.camera_alt,
                label: 'Cámara',
                onPressed: () => _seleccionarImagen(ImageSource.camera),
                color: colorScheme.primary,
              ),
              if (_imagenSeleccionada != null ||
                  (_logoUrl != null && _logoUrl!.isNotEmpty))
                _buildImageButton(
                  icon: Icons.delete_outline,
                  label: 'Eliminar',
                  onPressed: _limpiarImagen,
                  color: _colorDanger,
                ),
            ],
          ),
          if (_subiendoImagen) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Subiendo imagen...',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.2),
          backgroundColor: color.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ==================== SELECTOR PROVEEDOR ====================
  Widget _buildSelectorProveedor(
      ColorScheme colorScheme, bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center_rounded,
                  color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Proveedor (opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _cargandoProveedores
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              : Autocomplete<ProveedorEntity>(
                  optionsBuilder: (textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _proveedores;
                    }
                    final query = textEditingValue.text.toLowerCase();
                    return _proveedores.where((p) =>
                        p.nombre.toLowerCase().contains(query) ||
                        (p.empresa ?? '')
                            .toLowerCase()
                            .contains(query));
                  },
                  displayStringForOption: (proveedor) => proveedor.nombre,
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    _proveedorBusquedaController.text = controller.text;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      style: TextStyle(color: colorScheme.onSurface),
                      decoration: _inputDecor(
                        label: 'Buscar proveedor...',
                        icon: Icons.search,
                        colorScheme: colorScheme,
                        isDark: isDark,
                      ),
                      onChanged: (value) {
                        controller.text = value;
                        if (_proveedorSeleccionado != null &&
                            _proveedorSeleccionado!.nombre != value) {
                          _seleccionarProveedor(null);
                        }
                      },
                    );
                  },
                  onSelected: (proveedor) {
                    _seleccionarProveedor(proveedor);
                    _proveedorBusquedaController.text = proveedor.nombre;
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(12),
                        color: colorScheme.surface,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                dense: true,
                                title: Text(option.nombre),
                                subtitle:
                                    option.empresa != null &&
                                            option.empresa!.isNotEmpty
                                        ? Text(option.empresa!,
                                            style:
                                                const TextStyle(fontSize: 12))
                                        : null,
                                onTap: () => onSelected(option),
                                leading: Icon(Icons.business,
                                    color: colorScheme.primary, size: 20),
                                tileColor:
                                    option == _proveedorSeleccionado
                                        ? colorScheme.primary
                                            .withValues(alpha: 0.1)
                                        : null,
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 8),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _crearProveedorRapido,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Crear nuevo proveedor'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                  side: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                  backgroundColor:
                      colorScheme.primary.withValues(alpha: 0.06),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER ====================
  InputDecoration _inputDecor({
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool isDark,
    bool alignLabel = false,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      prefixIcon: Icon(icon, color: colorScheme.primary),
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      alignLabelWithHint: alignLabel,
    );
  }
}