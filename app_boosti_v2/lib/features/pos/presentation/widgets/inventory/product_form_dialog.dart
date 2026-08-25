import 'dart:io';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/input_decoration_helper.dart';

class ProductFormDialog extends StatefulWidget {
  final ProductoEntity? producto;
  final Future<void> Function(ProductoEntity) onGuardar;
  final String? codigoBarrasPrecargado;
  final UsuarioEntity? usuarioActual; // 👈 NUEVO

  const ProductFormDialog({
    super.key,
    this.producto,
    required this.onGuardar,
    this.codigoBarrasPrecargado,
    this.usuarioActual, // 👈 NUEVO
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

    final categoriaProducto = p?.categoria ?? 'General';
    _categoriaSeleccionada = _categorias.contains(categoriaProducto) ? categoriaProducto : 'General';

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
      await Supabase.instance.client.storage.from('productos').upload(fileName, image);
      final publicUrl = Supabase.instance.client.storage.from('productos').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Deshabilitar el botón para evitar múltiples clics
    setState(() => _guardando = true);

    try {
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
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          imagenUrlFinal = (_imagenUrlPreview.isNotEmpty && _imagenUrlPreview.startsWith('http'))
              ? _imagenUrlPreview
              : '';
        } finally {
          if (mounted) {
            setState(() => _subiendoImagen = false);
          }
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

      // ✅ Cerrar el diálogo ANTES de ejecutar onGuardar para que no se quede colgado
      if (mounted) {
        Navigator.pop(context);
      }

      // ✅ Ejecutar onGuardar en segundo plano (no bloquear la UI)
      await widget.onGuardar(producto);
      if (widget.usuarioActual != null) {
        await IsarService().guardarLog(
          LogEntity()
            ..accion = widget.producto == null ? 'CREAR_PRODUCTO' : 'EDITAR_PRODUCTO'
            ..usuarioNombre = widget.usuarioActual!.nombre
            ..usuarioRol = widget.usuarioActual!.rol
            ..detalles = 'Producto: ${producto.nombre} (Cód: ${producto.codigoBarras})'
            ..fecha = DateTime.now()
            ..sincronizado = false,
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      // ✅ Restablecer estado aunque haya error (si el widget sigue montado)
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    // ignore: unused_local_variable
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = colorScheme.primary;

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
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 20 : 24,
                          color: colorScheme.onSurface,
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
                  enableInteractiveSelection: false,
                  enableIMEPersonalizedLearning: false,
                  autofillHints: const <String>[],
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecorationHelper.build(
                    context: context,
                    label: 'Código de Barras *',
                    prefixIcon: Icons.qr_code,
                    errorText: _formKey.currentState?.validate() == false ? 'Requerido' : null,
                    isDark: isDark,
                  ),
                  validator: (v) => v?.trim().isNotEmpty == true ? null : 'Requerido',
                ),
                const SizedBox(height: 16),

                // NOMBRE
                TextFormField(
                  controller: _nombreController,
                  enableInteractiveSelection: false,
                  enableIMEPersonalizedLearning: false,
                  autofillHints: const <String>[],
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecorationHelper.build(
                    context: context,
                    label: 'Nombre del Producto *',
                    prefixIcon: Icons.label_outline,
                    errorText: _formKey.currentState?.validate() == false ? 'Requerido' : null,
                    isDark: isDark,
                  ),
                  validator: (v) => v?.trim().isNotEmpty == true ? null : 'Requerido',
                ),
                const SizedBox(height: 16),

                // SECCIÓN DE IMAGEN
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colorScheme.outline),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.image_outlined, color: color, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Imagen del Producto',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                          ),
                          const Spacer(),
                          if (_imagenSeleccionada != null || _imagenUrlPreview.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.clear, color: colorScheme.error, size: 20),
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
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: colorScheme.outline),
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
                                        Icon(Icons.broken_image, size: 48, color: colorScheme.onSurfaceVariant),
                                  )
                                : Center(
                                    child: Text(
                                      'Sin imagen',
                                      style: TextStyle(color: colorScheme.onSurfaceVariant),
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
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              foregroundColor: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _subiendoImagen ? null : () => _seleccionarImagen(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Cámara'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.surfaceContainerHighest,
                              foregroundColor: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (_subiendoImagen) LinearProgressIndicator(color: color),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // PRECIO Y STOCK
                if (isMobile)
                  Column(
                    children: [
                      _campoPrecio(colorScheme, isDark),
                      const SizedBox(height: 16),
                      _campoStock(colorScheme, isDark),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _campoPrecio(colorScheme, isDark)),
                      const SizedBox(width: 16),
                      Expanded(child: _campoStock(colorScheme, isDark)),
                    ],
                  ),
                const SizedBox(height: 16),

                // STOCK MÍNIMO Y CATEGORÍA
                if (isMobile)
                  Column(
                    children: [
                      _campoStockMinimo(colorScheme, isDark),
                      const SizedBox(height: 16),
                      _campoCategoria(colorScheme, isDark),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(child: _campoStockMinimo(colorScheme, isDark)),
                      const SizedBox(width: 16),
                      Expanded(child: _campoCategoria(colorScheme, isDark)),
                    ],
                  ),
                const SizedBox(height: 8),

                // PESADO
               SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '¿Es producto pesado (granel)?',
                    style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
                  ),
                  value: _esPesado,
                  onChanged: (val) => setState(() => _esPesado = val),
                  activeThumbColor: color,
                  activeTrackColor: color.withValues(alpha: 0.3),  // ✅ Corregido
                  tileColor: Colors.transparent,
                ),
                const Divider(height: 32),

                // PROVEEDOR
                Text(
                  'Información del Proveedor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),

                // NOMBRE PROVEEDOR
                TextFormField(
                  controller: _proveedorNombreController,
                  enableInteractiveSelection: false,
                  enableIMEPersonalizedLearning: false,
                  autofillHints: const <String>[],
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecorationHelper.build(
                    context: context,
                    label: 'Nombre del Proveedor',
                    prefixIcon: Icons.business_outlined,
                    errorText: null,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 16),

                // TELÉFONO PROVEEDOR
                TextFormField(
                  controller: _proveedorTelController,
                  enableInteractiveSelection: false,
                  enableIMEPersonalizedLearning: false,
                  autofillHints: const <String>[],
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: InputDecorationHelper.build(
                    context: context,
                    label: 'Teléfono del Proveedor',
                    prefixIcon: Icons.phone_outlined,
                    errorText: null,
                    isDark: isDark,
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
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text('Cancelar', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                    ),
                    ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _guardando
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
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
  Widget _campoPrecio(ColorScheme colorScheme, bool isDark) {
    return TextFormField(
      controller: _precioController,
      enableInteractiveSelection: false,
      enableIMEPersonalizedLearning: false,
      autofillHints: const <String>[],
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecorationHelper.build(
        context: context,
        label: 'Precio (\$) *',
        prefixIcon: Icons.attach_money,
        errorText: _formKey.currentState?.validate() == false ? 'Precio válido' : null,
        isDark: isDark,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Precio válido',
    );
  }

  Widget _campoStock(ColorScheme colorScheme, bool isDark) {
    return TextFormField(
      controller: _stockController,
      enableInteractiveSelection: false,
      enableIMEPersonalizedLearning: false,
      autofillHints: const <String>[],
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecorationHelper.build(
        context: context,
        label: 'Stock Inicial *',
        prefixIcon: Icons.inventory_outlined,
        errorText: _formKey.currentState?.validate() == false ? 'Stock válido' : null,
        isDark: isDark,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Stock válido',
    );
  }

  Widget _campoStockMinimo(ColorScheme colorScheme, bool isDark) {
    return TextFormField(
      controller: _stockMinController,
      enableInteractiveSelection: false,
      enableIMEPersonalizedLearning: false,
      autofillHints: const <String>[],
      enableSuggestions: false,
      autocorrect: false,
      decoration: InputDecorationHelper.build(
        context: context,
        label: 'Stock Mínimo *',
        prefixIcon: Icons.warning_amber_outlined,
        errorText: _formKey.currentState?.validate() == false ? 'Stock mínimo válido' : null,
        isDark: isDark,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Stock mínimo válido',
    );
  }

  Widget _campoCategoria(ColorScheme colorScheme, bool isDark) {
    return DropdownButtonFormField<String>(
      initialValue: _categoriaSeleccionada,
      decoration: InputDecorationHelper.build(
        context: context,
        label: 'Categoría',
        prefixIcon: Icons.category_outlined,
        errorText: null,
        isDark: isDark,
      ),
      items: _categorias.map((cat) {
        return DropdownMenuItem<String>(
          value: cat,
          child: Text(cat, style: TextStyle(color: colorScheme.onSurface)),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _categoriaSeleccionada = newValue;
          });
        }
      },
      isExpanded: true,
      dropdownColor: colorScheme.surface,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Selecciona una categoría';
        }
        return null;
      },
    );
  }
}