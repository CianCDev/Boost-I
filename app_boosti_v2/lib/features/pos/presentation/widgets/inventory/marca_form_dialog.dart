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
import '../proveedores/crear_proveedor_dialog.dart';

/// Formulario para crear o editar una marca
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
  final TextEditingController _proveedorBusquedaController = TextEditingController();

  String? _logoUrl;
  XFile? _imagenSeleccionada;
  bool _subiendoImagen = false;
  bool _guardando = false;

  ProveedorEntity? _proveedorSeleccionado;
  List<ProveedorEntity> _proveedores = [];
  bool _cargandoProveedores = false;

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
      if (proveedor != null) {
        setState(() => _proveedorSeleccionado = proveedor);
      }
    } catch (e) {
      debugPrint('Error cargando proveedor seleccionado: $e');
    }
  }

  Future<void> _crearProveedorRapido() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CrearProveedorDialog(),
    );
    if (result == true) {
      await _cargarProveedores();
      if (_proveedores.isNotEmpty) {
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
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Se necesita permiso para acceder a la galería/cámara')),
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
          _logoUrl = image.path; // Vista previa local
        });
      }
    } catch (e) {
      if (mounted) {
        _mostrarError('Error al seleccionar imagen: $e');
      }
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
      final fileName = 'marca_${nombre}_${DateTime.now().millisecondsSinceEpoch}.$ext';
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

      // Subir imagen si se seleccionó una nueva
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
            logoUrlFinal = _logoUrl?.startsWith('http') == true ? _logoUrl : null;
          }
        } catch (e) {
          logoUrlFinal = _logoUrl?.startsWith('http') == true ? _logoUrl : null;
        } finally {
          if (mounted) setState(() => _subiendoImagen = false);
        }
      }

      // Crear o actualizar marca
      final marca = widget.marca ?? MarcaEntity();
      if (widget.marca == null) {
        // Nueva marca: generar supabaseId temporal
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

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Marca "${marca.nombre}" ${widget.marca == null ? 'creada' : 'actualizada'}',
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _mostrarError('Error al guardar: $e');
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(colorScheme, isMobile),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
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
              const SizedBox(height: 16),
              _buildAcciones(colorScheme, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(ColorScheme colorScheme, bool isMobile) {
    final esEdicion = widget.marca != null;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            esEdicion ? Icons.edit_outlined : Icons.add_circle_outline,
            color: colorScheme.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            esEdicion ? 'Editar Marca' : 'Nueva Marca',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 20 : 24,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ==================== ACCIONES ====================
  Widget _buildAcciones(ColorScheme colorScheme, bool isMobile) {
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: isMobile ? 20 : 32,
      vertical: 14,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(
            'Cancelar',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _guardando
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  widget.marca == null ? 'Crear Marca' : 'Actualizar',
                  style: TextStyle(fontSize: isMobile ? 16 : 18),
                ),
        ),
      ],
    );
  }

  // ==================== CAMPOS ====================
  Widget _campoNombre(ColorScheme colorScheme, bool isDark) {
    return TextFormField(
      controller: _nombreController,
      decoration: InputDecoration(
        labelText: 'Nombre de la marca *',
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.branding_watermark_outlined, color: colorScheme.primary),
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
      decoration: InputDecoration(
        labelText: 'Descripción (opcional)',
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.description_outlined, color: colorScheme.primary),
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        alignLabelWithHint: true,
      ),
    );
  }

  // ==================== IMAGEN ====================
  Widget _buildImagenSection(ColorScheme colorScheme, bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Logo de la marca',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline,
              ),
            ),
            child: _imagenSeleccionada != null
                ? Image.file(
                    File(_imagenSeleccionada!.path),
                    fit: BoxFit.cover,
                  )
                : _logoUrl != null && _logoUrl!.startsWith('http')
                    ? Image.network(
                        _logoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
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
              if (_imagenSeleccionada != null || (_logoUrl != null && _logoUrl!.isNotEmpty))
                _buildImageButton(
                  icon: Icons.delete_outline,
                  label: 'Eliminar',
                  onPressed: _limpiarImagen,
                  color: Colors.red,
                ),
            ],
          ),
          if (_subiendoImagen) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: null,
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
      ),
    );
  }

  // ==================== SELECTOR DE PROVEEDOR ====================
  Widget _buildSelectorProveedor(ColorScheme colorScheme, bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center_rounded, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Proveedor (opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
                        (p.empresa ?? '').toLowerCase().contains(query));
                  },
                  displayStringForOption: (proveedor) => proveedor.nombre,
                  fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                    _proveedorBusquedaController.text = controller.text;
                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        hintText: 'Buscar proveedor...',
                        prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                        filled: true,
                        fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                        color: Colors.transparent,
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final option = options.elementAt(index);
                              return Material(
                                color: Colors.transparent,
                                child: ListTile(
                                  title: Text(option.nombre),
                                  subtitle: option.empresa != null && option.empresa!.isNotEmpty
                                      ? Text(option.empresa!, style: TextStyle(fontSize: 12))
                                      : null,
                                  onTap: () => onSelected(option),
                                  leading: Icon(Icons.business, color: colorScheme.primary),
                                  tileColor: option == _proveedorSeleccionado
                                      ? colorScheme.primary.withValues(alpha: 0.1)
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _crearProveedorRapido,
              icon: Icon(Icons.add, size: 18, color: colorScheme.primary),
              label: Text(
                'Crear nuevo proveedor',
                style: TextStyle(color: colorScheme.primary),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}