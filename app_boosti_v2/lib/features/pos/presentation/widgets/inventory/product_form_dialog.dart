import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../utils/responsive_helper.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductoEntity? producto;
  final Future<void> Function(ProductoEntity) onGuardar;
  final String? codigoBarrasPrecargado;

  const ProductFormDialog({
    super.key,
    this.producto,
    required this.onGuardar,
    this.codigoBarrasPrecargado,
  });

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _stockMinController;
  late TextEditingController _proveedorNombreController;
  late TextEditingController _proveedorTelController;
  late String _categoriaSeleccionada;
  late bool _esPesado;
  String _imagenUrlPreview = '';
  XFile? _imagenSeleccionada;
  bool _subiendoImagen = false;
  bool _guardando = false;

  final List<String> _categorias = [
    'Abarrotes',
    'Bebidas',
    'Frutas',
    'Limpieza',
    'Lácteos',
    'Carnes',
    'Panadería',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _codigoController = TextEditingController(
      text: p?.codigoBarras ?? widget.codigoBarrasPrecargado ?? '',
    );
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _precioController = TextEditingController(text: p?.precioUnidad.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _stockMinController = TextEditingController(text: p?.stockMinimo.toString() ?? '5.0');
    _proveedorNombreController = TextEditingController(text: p?.proveedorNombre ?? '');
    _proveedorTelController = TextEditingController(text: p?.proveedorTelefono ?? '');
    _categoriaSeleccionada = p?.categoria.isNotEmpty == true ? p!.categoria : 'General';
    _esPesado = p?.esPesado ?? false;
    _imagenUrlPreview = p?.imagenUrl ?? '';
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _stockMinController.dispose();
    _proveedorNombreController.dispose();
    _proveedorTelController.dispose();
    super.dispose();
  }

  // ==================== PERMISOS Y SELECCIÓN DE IMAGEN ====================
  Future<bool> _getImagePermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final permission = await _getImagePermission();
    if (!permission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permiso de acceso a imágenes denegado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() {
        _imagenSeleccionada = image;
        _imagenUrlPreview = image.path;
      });
    }
  }

  Future<String?> _uploadImage(File image, String codigo) async {
    try {
      final ext = image.path.split('.').last;
      final fileName = '${codigo}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      debugPrint('📤 Subiendo imagen: $fileName (${image.lengthSync()} bytes)');
      await Supabase.instance.client.storage.from('productos').upload(fileName, image);
      final publicUrl = Supabase.instance.client.storage.from('productos').getPublicUrl(fileName);
      debugPrint('✅ Imagen subida: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error subiendo imagen: $e');
      return null;
    }
  }

  // ==================== GUARDAR ====================
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    String imagenUrlFinal = _imagenUrlPreview;

    if (_imagenSeleccionada != null) {
      setState(() => _subiendoImagen = true);
      try {
        final url = await _uploadImage(
          File(_imagenSeleccionada!.path),
          _codigoController.text.trim(),
        );
        if (url != null && url.isNotEmpty) {
          imagenUrlFinal = url;
        } else {
          // Si falla, mantener URL anterior solo si es válida
          if (_imagenUrlPreview.isNotEmpty && _imagenUrlPreview.startsWith('http')) {
            imagenUrlFinal = _imagenUrlPreview;
          } else {
            imagenUrlFinal = '';
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ No se pudo subir la imagen. El producto se guardará sin imagen.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al subir imagen: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        imagenUrlFinal = (_imagenUrlPreview.isNotEmpty && _imagenUrlPreview.startsWith('http'))
            ? _imagenUrlPreview
            : '';
      } finally {
        setState(() => _subiendoImagen = false);
      }
    }

    final producto = widget.producto ?? ProductoEntity();
    producto.codigoBarras = _codigoController.text.trim();
    producto.nombre = _nombreController.text.trim();
    producto.imagenUrl = imagenUrlFinal;
    producto.precioUnidad = double.tryParse(_precioController.text) ?? 0.0;
    producto.stock = double.tryParse(_stockController.text) ?? 0.0;
    producto.stockMinimo = double.tryParse(_stockMinController.text) ?? 5.0;
    producto.categoria = _categoriaSeleccionada;
    producto.esPesado = _esPesado;
    producto.proveedorNombre = _proveedorNombreController.text.trim();
    producto.proveedorTelefono = _proveedorTelController.text.trim();

    await widget.onGuardar(producto);
    if (mounted) Navigator.pop(context);
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);
    final color = const Color(0xFF10B981);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        decoration: BoxDecoration(
          color: Theme.of(context).dialogTheme.backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // HEADER
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.producto == null
                            ? Icons.add_shopping_cart_outlined
                            : Icons.edit_outlined,
                        color: color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.producto == null ? 'Nuevo Producto' : 'Editar Producto',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 20 : 24,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // CÓDIGO DE BARRAS
                TextFormField(
                  controller: _codigoController,
                  decoration: const InputDecoration(
                    labelText: 'Código de Barras *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.qr_code),
                  ),
                  validator: (v) => v?.trim().isNotEmpty == true ? null : 'Requerido',
                ),
                const SizedBox(height: 16),

                // NOMBRE
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Producto *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (v) => v?.trim().isNotEmpty == true ? null : 'Requerido',
                ),
                const SizedBox(height: 16),

                // SECCIÓN DE IMAGEN
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.image_outlined, color: Color(0xFF10B981), size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Imagen del Producto',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const Spacer(),
                          if (_imagenSeleccionada != null || _imagenUrlPreview.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                              onPressed: () => setState(() {
                                _imagenSeleccionada = null;
                                _imagenUrlPreview = '';
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _imagenSeleccionada != null
                            ? Image.file(
                                File(_imagenSeleccionada!.path),
                                fit: BoxFit.cover,
                              )
                            : _imagenUrlPreview.isNotEmpty
                                ? Image.network(
                                    _imagenUrlPreview,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                  )
                                : const Center(
                                    child: Text(
                                      'Sin imagen',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _subiendoImagen ? null : () => _seleccionarImagen(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text('Galería'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _subiendoImagen ? null : () => _seleccionarImagen(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Cámara'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                      if (_subiendoImagen) const LinearProgressIndicator(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // PRECIO Y STOCK
                if (isMobile)
                  Column(
                    children: [
                      _campoPrecio(),
                      const SizedBox(height: 16),
                      _campoStock(),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _campoPrecio()),
                      const SizedBox(width: 16),
                      Expanded(child: _campoStock()),
                    ],
                  ),
                const SizedBox(height: 16),

                // STOCK MÍNIMO Y CATEGORÍA
                if (isMobile)
                  Column(
                    children: [
                      _campoStockMinimo(),
                      const SizedBox(height: 16),
                      _campoCategoria(),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _campoStockMinimo()),
                      const SizedBox(width: 16),
                      Expanded(child: _campoCategoria()),
                    ],
                  ),
                const SizedBox(height: 8),

                // PESADO
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    '¿Es producto pesado (granel)?',
                    style: TextStyle(fontSize: 16),
                  ),
                  value: _esPesado,
                  onChanged: (val) => setState(() => _esPesado = val),
                  activeThumbColor: color,
                  activeColor: color.withValues(alpha: 0.3),
                ),
                const Divider(height: 32),

                // PROVEEDOR
                const Text(
                  'Información del Proveedor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _proveedorNombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del Proveedor',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business_outlined),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _proveedorTelController,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono del Proveedor',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                // BOTONES
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: _guardando ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _guardando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Guardar Producto'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== CAMPOS REUTILIZABLES ====================
  Widget _campoPrecio() {
    return TextFormField(
      controller: _precioController,
      decoration: const InputDecoration(
        labelText: 'Precio (\$) *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.attach_money_rounded),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Precio válido',
    );
  }

  Widget _campoStock() {
    return TextFormField(
      controller: _stockController,
      decoration: const InputDecoration(
        labelText: 'Stock Inicial *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.inventory_outlined),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Stock válido',
    );
  }

  Widget _campoStockMinimo() {
    return TextFormField(
      controller: _stockMinController,
      decoration: const InputDecoration(
        labelText: 'Stock Mínimo *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.warning_amber_outlined),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Stock mínimo válido',
    );
  }

  Widget _campoCategoria() {
    return DropdownButtonFormField<String>(
      initialValue: _categoriaSeleccionada,
      decoration: const InputDecoration(
        labelText: 'Categoría',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.category_outlined),
      ),
      items: _categorias.map((cat) {
        return DropdownMenuItem(
          value: cat,
          child: Text(cat),
        );
      }).toList(),
      onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
      isExpanded: true,
    );
  }
}