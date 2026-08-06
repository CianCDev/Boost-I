import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../utils/responsive_helper.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../services/sync_service.dart';
import 'inventory_catalog_screen.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  final UsuarioEntity usuarioLogueado;
  const InventoryScreen({super.key, required this.usuarioLogueado});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

  List<ProductoEntity> _productos = [];
  bool _isLoading = true;
  String _filtroBusqueda = '';
  bool _soloStockBajo = false;

  AnimationController? _animationController;

  bool get _esAdmin => widget.usuarioLogueado.rol == 'admin';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _cargarInventario();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  // ==========================================
  // CARGA DE INVENTARIO
  // ==========================================
  Future<void> _cargarInventario() async {
    setState(() => _isLoading = true);
    try {
      final productos = await _isarService.obtenerProductos();
      if (mounted) {
        setState(() {
          _productos = productos;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error al cargar inventario: $e\n$stackTrace');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al cargar el inventario. Intenta de nuevo.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // ==========================================
  // ESCÁNER DE CÓDIGO DE BARRAS
  // ==========================================
  Future<void> _scanBarcode() async {
    final codigoEscaneado = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _BarcodeScannerDialog(),
    );

    if (codigoEscaneado == null || codigoEscaneado.isEmpty) return;

    final productos = await _isarService.buscarProductoPorCodigoONombre(codigoEscaneado);
    final producto = productos.firstWhere(
      (p) => p.codigoBarras == codigoEscaneado,
      orElse: () => ProductoEntity(),
    );

    if (producto.id == 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Producto con código "$codigoEscaneado" no encontrado.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (mounted) {
      _mostrarDetalleProducto(producto);
    }
  }

  // ==========================================
  // DIÁLOGO DE NUEVA CATEGORÍA
  // ==========================================
  Future<String?> _mostrarDialogoNuevaCategoria(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24.0),
            constraints: const BoxConstraints(maxWidth: 450),
            decoration: BoxDecoration(
              color: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nueva Categoría',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Ej: Bebidas, Limpieza, Víveres...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        backgroundColor: const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.pop(dialogContext, text);
                        }
                      },
                      child: const Text(
                        'Agregar',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // SELECCIÓN Y SUBIDA DE IMAGEN (CON PERMISOS CORRECTOS)
  // ==========================================
  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    try {
      final version = await SystemChannels.platform.invokeMethod('System.getVersion');
      final sdkInt = int.tryParse(version.toString()) ?? 0;
      return sdkInt >= 33;
    } catch (_) {
      return false;
    }
  }

  Future<void> _seleccionarImagen(StateSetter setStateModal, Function(XFile) onImageSelected) async {
    final currentContext = context;
    
    Permission permission;
    if (await _isAndroid13OrHigher()) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }

    final status = await permission.request();
    if (!status.isGranted) {
      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Permiso de almacenamiento denegado')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image != null) {
      onImageSelected(image);
    }
  }

  Future<void> _tomarFoto(StateSetter setStateModal, Function(XFile) onImageSelected) async {
    final currentContext = context;
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (!currentContext.mounted) return;
      ScaffoldMessenger.of(currentContext).showSnackBar(
        const SnackBar(content: Text('Permiso de cámara denegado')),
      );
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );
    if (image != null) {
      onImageSelected(image);
    }
  }

  Future<String?> _subirImagenASupabase(File imagen, String codigoBarras) async {
    try {
      final extension = imagen.path.split('.').last;
      final fileName = '${codigoBarras}_${DateTime.now().millisecondsSinceEpoch}.$extension';

      debugPrint('📤 Subiendo imagen: $fileName (${imagen.lengthSync()} bytes)');

      await Supabase.instance.client.storage
          .from('productos')
          .upload(fileName, imagen);

      final publicUrl = Supabase.instance.client.storage
          .from('productos')
          .getPublicUrl(fileName);

      debugPrint('✅ Imagen subida: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error subiendo imagen: $e');
      return null;
    }
  }

  // ==========================================
  // MODAL DE PRODUCTO (CREAR/EDITAR) con IMAGEN
  // ==========================================
  void _mostrarFormularioProducto({ProductoEntity? productoAEditar}) {
    if (!_esAdmin) return;

    final isEditing = productoAEditar != null;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = !isTablet && !isMobile;

    final codigoController =
        TextEditingController(text: productoAEditar?.codigoBarras ?? '');
    final nombreController =
        TextEditingController(text: productoAEditar?.nombre ?? '');
    final imagenUrlController =
        TextEditingController(text: productoAEditar?.imagenUrl ?? '');
    final precioController =
        TextEditingController(text: productoAEditar?.precioUnidad.toString() ?? '');
    final stockController =
        TextEditingController(text: productoAEditar?.stock.toString() ?? '');
    final stockMinController =
        TextEditingController(text: productoAEditar?.stockMinimo.toString() ?? '5.0');
    final proveedorNombreController =
        TextEditingController(text: productoAEditar?.proveedorNombre ?? '');
    final proveedorTelController =
        TextEditingController(text: productoAEditar?.proveedorTelefono ?? '');

    bool esPesado = productoAEditar?.esPesado ?? false;
    String imagenUrlPreview = productoAEditar?.imagenUrl ?? '';

    XFile? imagenSeleccionada;
    bool subiendoImagen = false;

    final setCategorias =
        _productos.map((p) => p.categoria.trim()).where((c) => c.isNotEmpty).toSet();
    setCategorias.addAll(['General', 'Frutas', 'Abarrotes', 'Lácteos']);
    if (productoAEditar != null && productoAEditar.categoria.isNotEmpty) {
      setCategorias.add(productoAEditar.categoria.trim());
    }

    final List<String> listaCategorias = setCategorias.toList()..sort();
    String categoriaSeleccionada = productoAEditar?.categoria ?? 'General';
    if (!listaCategorias.contains(categoriaSeleccionada)) {
      listaCategorias.add(categoriaSeleccionada);
    }
    bool guardando = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 8,
              insetPadding: EdgeInsets.symmetric(
                horizontal: isTablet || isDesktop ? 40.0 : 16.0,
                vertical: 24.0,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isTablet || isDesktop ? 800.0 : double.infinity,
                ),
                padding: EdgeInsets.all(isTablet ? 40.0 : 24.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).dialogTheme.backgroundColor ?? Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // HEADER
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isEditing
                                  ? Icons.edit_outlined
                                  : Icons.add_shopping_cart_outlined,
                              color: const Color(0xFF10B981),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isEditing ? 'Editar Producto' : 'Nuevo Producto',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 26 : 22,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Código de barras
                      TextField(
                        controller: codigoController,
                        style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          labelText: 'Código de Barras',
                          labelStyle: const TextStyle(fontSize: 16),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Nombre
                      TextField(
                        controller: nombreController,
                        style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          labelText: 'Nombre del Producto *',
                          labelStyle: const TextStyle(fontSize: 16),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ==========================================
                      // 🖼️ SECCIÓN DE IMAGEN
                      // ==========================================
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
                                const Icon(Icons.image_outlined,
                                    color: Color(0xFF10B981), size: 24),
                                const SizedBox(width: 8),
                                const Text(
                                  'Imagen del Producto',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const Spacer(),
                                if (imagenSeleccionada != null || imagenUrlPreview.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                                    onPressed: () {
                                      setStateModal(() {
                                        imagenSeleccionada = null;
                                        imagenUrlPreview = '';
                                        imagenUrlController.text = '';
                                      });
                                    },
                                    tooltip: 'Eliminar imagen',
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Previsualización
                            if (imagenSeleccionada != null || imagenUrlPreview.isNotEmpty)
                              Container(
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: imagenSeleccionada != null
                                      ? Image.file(
                                          File(imagenSeleccionada!.path),
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                        )
                                      : (imagenUrlPreview.isNotEmpty
                                          ? Image.network(
                                              imagenUrlPreview,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              errorBuilder: (context, error, stackTrace) => const Icon(
                                                Icons.broken_image,
                                                size: 48,
                                                color: Colors.grey,
                                              ),
                                            )
                                          : const SizedBox.shrink()),
                                ),
                              )
                            else
                              Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Sin imagen',
                                    style: TextStyle(color: Colors.grey, fontSize: 14),
                                  ),
                                ),
                              ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: subiendoImagen ? null : () => _seleccionarImagen(setStateModal, (file) {
                                    setStateModal(() {
                                      imagenSeleccionada = file;
                                      imagenUrlPreview = file.path;
                                      imagenUrlController.text = '';
                                    });
                                  }),
                                  icon: const Icon(Icons.photo_library, size: 18),
                                  label: const Text('Galería'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B82F6),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: subiendoImagen ? null : () => _tomarFoto(setStateModal, (file) {
                                    setStateModal(() {
                                      imagenSeleccionada = file;
                                      imagenUrlPreview = file.path;
                                      imagenUrlController.text = '';
                                    });
                                  }),
                                  icon: const Icon(Icons.camera_alt, size: 18),
                                  label: const Text('Cámara'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Precio y Stock
                      isMobile
                          ? Column(
                              children: [
                                TextField(
                                  controller: precioController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    labelText: 'Precio Unidad (\$) *',
                                    labelStyle: const TextStyle(fontSize: 16),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: stockController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    labelText: 'Stock Inicial *',
                                    labelStyle: const TextStyle(fontSize: 16),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: precioController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                                    decoration: InputDecoration(
                                      labelText: 'Precio Unidad (\$) *',
                                      labelStyle: const TextStyle(fontSize: 16),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextField(
                                    controller: stockController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                                    decoration: InputDecoration(
                                      labelText: 'Stock Inicial *',
                                      labelStyle: const TextStyle(fontSize: 16),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 14),

                      // Stock Mínimo y Categoría
                      isMobile
                          ? Column(
                              children: [
                                TextField(
                                  controller: stockMinController,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                                  decoration: InputDecoration(
                                    labelText: 'Stock Mínimo *',
                                    labelStyle: const TextStyle(fontSize: 16),
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _buildCategoriaDropdown(
                                  listaCategorias,
                                  categoriaSeleccionada,
                                  (val) => setStateModal(() => categoriaSeleccionada = val!),
                                  context,
                                  isMobile,
                                ),
                              ],
                            )
                          : Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: stockMinController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                                    decoration: InputDecoration(
                                      labelText: 'Stock Mínimo *',
                                      labelStyle: const TextStyle(fontSize: 16),
                                      filled: true,
                                      fillColor: const Color(0xFFF8FAFC),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildCategoriaDropdown(
                                    listaCategorias,
                                    categoriaSeleccionada,
                                    (val) => setStateModal(() => categoriaSeleccionada = val!),
                                    context,
                                    isMobile,
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 8),

                      // Switch: Es pesado
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          '¿Es producto pesado (granel)?',
                          style: TextStyle(fontSize: 16, color: Color(0xFF0F172A)),
                        ),
                        activeThumbColor: const Color(0xFF10B981),
                        value: esPesado,
                        onChanged: (val) => setStateModal(() => esPesado = val),
                      ),
                      const Divider(height: 32),

                      // Proveedor
                      const Text(
                        'Información del Proveedor',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF475569),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: proveedorNombreController,
                        style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          labelText: 'Nombre del Proveedor / Empresa',
                          labelStyle: const TextStyle(fontSize: 16),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: proveedorTelController,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                        decoration: InputDecoration(
                          labelText: 'Teléfono del Proveedor',
                          labelStyle: const TextStyle(fontSize: 16),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Botones Guardar/Cancelar
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (!guardando)
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 16,
                                ),
                                foregroundColor: Colors.grey.shade700,
                                backgroundColor: const Color(0xFFF1F5F9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                'Cancelar',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: guardando
                                  ? Colors.grey.shade300
                                  : const Color(0xFF10B981),
                              foregroundColor: guardando ? Colors.grey : Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                            ),
                            onPressed: guardando
                                ? null
                                : () async {
                                    final nombre = nombreController.text.trim();
                                    final precioStr =
                                        precioController.text.trim().replaceAll(',', '.');
                                    final stockStr =
                                        stockController.text.trim().replaceAll(',', '.');

                                    if (nombre.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'El nombre del producto es obligatorio.',
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }
                                    final pPrecio = double.tryParse(precioStr) ?? -1.0;
                                    final pStock = double.tryParse(stockStr) ?? -1.0;
                                    if (pPrecio < 0 || pStock < 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'El precio y el stock deben ser números válidos y mayores o iguales a 0.',
                                          ),
                                          backgroundColor: Colors.redAccent,
                                        ),
                                      );
                                      return;
                                    }

                                    setStateModal(() => guardando = true);

                                    // Subir imagen si se seleccionó una nueva
                                    String imagenUrlFinal = imagenUrlPreview;
                                    if (imagenSeleccionada != null) {
                                      setStateModal(() => subiendoImagen = true);
                                      try {
                                        final String? urlImagen = await _subirImagenASupabase(
                                          File(imagenSeleccionada!.path),
                                          codigoController.text.trim(),
                                        );
                                        if (urlImagen != null && urlImagen.isNotEmpty) {
                                          imagenUrlFinal = urlImagen;
                                        } else {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('⚠️ Error al subir imagen, se guardará sin imagen.'),
                                              backgroundColor: Colors.orange,
                                            ),
                                          );
                                          imagenUrlFinal = '';
                                        }
                                      } catch (e) {
                                        debugPrint('Error subiendo imagen: $e');
                                        imagenUrlFinal = '';
                                      } finally {
                                        setStateModal(() => subiendoImagen = false);
                                      }
                                    }

                                    final producto = productoAEditar ?? ProductoEntity();
                                    producto.codigoBarras = codigoController.text.trim();
                                    producto.nombre = nombre;
                                    producto.imagenUrl = imagenUrlFinal;
                                    producto.precioUnidad = pPrecio;
                                    producto.stock = pStock;
                                    final pStockMin = double.tryParse(stockMinController
                                        .text
                                        .trim()
                                        .replaceAll(',', '.')) ?? 5.0;
                                    producto.stockMinimo = (pStockMin.isNaN ||
                                        pStockMin.isInfinite)
                                        ? 5.0
                                        : pStockMin;
                                    producto.categoria = categoriaSeleccionada;
                                    producto.esPesado = esPesado;
                                    producto.proveedorNombre =
                                        proveedorNombreController.text.trim();
                                    producto.proveedorTelefono =
                                        proveedorTelController.text.trim();
                                    HapticFeedback.lightImpact();

                                    await _isarService.guardarProducto(producto);
                                    await _syncService.sincronizarCategoriasASupabase();
                                    await _syncService.sincronizarProductosASupabase();

                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      _cargarInventario();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Producto guardado y sincronizado exitosamente',
                                          ),
                                          backgroundColor: Color(0xFF10B981),
                                        ),
                                      );
                                    }
                                  },
                            child: guardando
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'Guardar Producto',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
          },
        );
      },
    );
  }

  // ==========================================
  // DROPDOWN DE CATEGORÍAS
  // ==========================================
  Widget _buildCategoriaDropdown(
    List<String> listaCategorias,
    String valorActual,
    ValueChanged<String?> onChanged,
    BuildContext context,
    bool isMobile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: valorActual,
          decoration: InputDecoration(
            labelText: 'Categoría',
            labelStyle: const TextStyle(fontSize: 16),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 22,
            ),
          ),
          isExpanded: true,
          items: listaCategorias.map((cat) {
            return DropdownMenuItem<String>(
              value: cat,
              child: Text(
                cat,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.1),
              foregroundColor: const Color(0xFF10B981),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onPressed: () async {
              final nuevaCat = await _mostrarDialogoNuevaCategoria(context);
              if (nuevaCat != null && nuevaCat.isNotEmpty) {
                setState(() {
                  if (!listaCategorias.contains(nuevaCat)) {
                    listaCategorias.add(nuevaCat);
                    listaCategorias.sort();
                  }
                });
                onChanged(nuevaCat);
              }
            },
            icon: const Icon(Icons.add_circle, size: 20),
            label: const Text(
              'Nueva Categoría',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MODAL DE DETALLES DEL PRODUCTO (CON ELIMINACIÓN MEJORADA)
  // ==========================================
  void _mostrarDetalleProducto(ProductoEntity producto) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);

    final bool isLargeScreen = !isMobile;
    final double maxWidth = isLargeScreen ? 850.0 : 600.0;
    final double padding = isMobile ? 12.0 : (isTablet ? 24.0 : 32.0);
    final double imageHeight = isMobile ? 120 : (isTablet ? 200 : 280);
    final double imageMaxWidth = isLargeScreen ? 500 : 400;
    final double horizontalInset = isMobile ? 16.0 : (isTablet ? 40.0 : 60.0);
    final double verticalInset = isMobile ? 16.0 : 24.0;

    final double titleSize = isMobile ? 16 : (isTablet ? 20 : 24);
    final double nameSize = isMobile ? 18 : (isTablet ? 24 : 28);
    final double detailSize = isMobile ? 11 : (isTablet ? 14 : 16);
    final double priceSize = isMobile ? 14 : (isTablet ? 18 : 20);
    final double stockSize = isMobile ? 12 : (isTablet ? 16 : 18);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          insetPadding: EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: verticalInset,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Container(
              padding: EdgeInsets.all(padding),
              decoration: BoxDecoration(
                color: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Detalles del Producto',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: titleSize,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, size: 28),
                          onPressed: () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // IMAGEN
                    Center(
                      child: Container(
                        height: imageHeight,
                        width: double.infinity,
                        constraints: BoxConstraints(maxWidth: imageMaxWidth),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: producto.imagenUrl.isNotEmpty
                              ? Image.network(
                                  producto.imagenUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.inventory_2,
                                    size: 64,
                                    color: Colors.blueGrey,
                                  ),
                                )
                              : Icon(Icons.inventory_2, size: 64, color: Colors.blueGrey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // DIVIDER
                    const Divider(),
                    const SizedBox(height: 8),

                    // NOMBRE
                    Text(
                      producto.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: nameSize,
                        color: const Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // CÓDIGO
                    Text(
                      'Cód: ${producto.codigoBarras}',
                      style: TextStyle(
                        fontSize: detailSize,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // PRECIO Y CATEGORÍA
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Precio: \$${producto.precioUnidad.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: priceSize,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        Text(
                          'Categoría: ${producto.categoria}',
                          style: TextStyle(
                            fontSize: detailSize,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // STOCK
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stock Actual: ${producto.stock % 1 == 0 ? producto.stock.toInt() : producto.stock}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: stockSize,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Stock Mínimo: ${producto.stockMinimo.isFinite ? (producto.stockMinimo % 1 == 0 ? producto.stockMinimo.toInt() : producto.stockMinimo) : 0}',
                          style: TextStyle(
                            fontSize: detailSize,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // PROVEEDOR
                    if (producto.proveedorNombre.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                        ),
                        child: Text(
                          'Proveedor: ${producto.proveedorNombre} (${producto.proveedorTelefono.isNotEmpty ? producto.proveedorTelefono : "Sin teléfono"})',
                          style: TextStyle(
                            fontSize: detailSize,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4F46E5),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    // BOTONES (responsivos)
                    if (_esAdmin) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 12 : 28,
                                vertical: isMobile ? 8 : 18,
                              ),
                              foregroundColor: Colors.grey.shade700,
                              backgroundColor: const Color(0xFFF1F5F9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              'Cerrar',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 12 : 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 32,
                                vertical: isMobile ? 8 : 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              _mostrarFormularioProducto(productoAEditar: producto);
                            },
                            icon: const Icon(Icons.edit_outlined, size: 20),
                            label: Text(
                              'Editar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 12 : 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // ==========================================
                          // 🗑️ BOTÓN ELIMINAR (MEJORADO)
                          // ==========================================
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEF4444),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 16 : 32,
                                vertical: isMobile ? 8 : 18,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () async {
                              // Confirmación
                              final confirm = await showDialog<bool>(
                                context: dialogContext,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar Producto'),
                                  content: Text(
                                    '¿Estás seguro de que quieres eliminar el producto "${producto.nombre}"? Esta acción no se puede deshacer.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFEF4444),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              try {
                                // 1. Eliminar localmente de Isar
                                await _isarService.eliminarProducto(producto.id);
                                debugPrint('✅ Producto eliminado de Isar (ID: ${producto.id})');

                                // 2. Eliminar en Supabase
                                try {
                                  final eliminado = await _syncService.eliminarProductoEnSupabase(
                                    producto.codigoBarras.trim(),
                                  );
                                  if (eliminado) {
                                    debugPrint('✅ Producto eliminado de Supabase (código: ${producto.codigoBarras})');
                                  } else {
                                    debugPrint('⚠️ El producto no existía en Supabase o ya fue eliminado.');
                                  }
                                } catch (e) {
                                  debugPrint('❌ Error eliminando de Supabase: $e');
                                  // No lanzamos excepción, solo mostramos mensaje
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Producto eliminado localmente, pero falló en la nube: $e'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                }

                                // 3. Recargar la lista local
                                await _cargarInventario();

                                // 4. Forzar descarga de productos desde Supabase para sincronizar la lista
                                await _syncService.descargarProductosDesdeSupabase();
                                await _cargarInventario();

                                // 5. Cerrar el diálogo
                                if (mounted) {
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Producto eliminado correctamente.'),
                                      backgroundColor: Color(0xFF10B981),
                                    ),
                                  );
                                }
                              } catch (e) {
                                debugPrint('❌ Error general al eliminar producto: $e');
                                if (mounted) {
                                  // Recargar la lista para reflejar el estado
                                  await _cargarInventario();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error al eliminar producto: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.delete_outline, size: 20),
                            label: Text(
                              'Eliminar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 12 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // BARRA DE BÚSQUEDA CON ESCÁNER
  // ==========================================
  Widget _buildSearchBar(bool isMobile) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                onChanged: (val) => setState(() => _filtroBusqueda = val),
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar...'
                      : 'Buscar por nombre o código de barras...',
                  hintStyle: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.grey.shade500,
                  ),
                  isDense: true,
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 8, right: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.qr_code_scanner_rounded,
                              size: 28,
                              color: Color(0xFF475569),
                            ),
                            tooltip: 'Escanear código de barras',
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            padding: EdgeInsets.zero,
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              _scanBarcode();
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.search,
                          size: 20,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ],
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 0,
                    minHeight: 0,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 8,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('⚠️ Stock Bajo'),
            selected: _soloStockBajo,
            onSelected: (val) => setState(() => _soloStockBajo = val),
            selectedColor: const Color(0xFFFEE2E2),
            checkmarkColor: Colors.red,
            labelStyle: TextStyle(
              fontSize: isMobile ? 10 : 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ==========================================
  // BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = !isMobile && !isTablet;

    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount;
    double childAspectRatio;

    if (screenWidth < 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.60;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
      childAspectRatio = 0.55;
    } else if (screenWidth < 1200) {
      crossAxisCount = 3;
      childAspectRatio = 0.62;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 0.68;
    }

    if (isMobile && MediaQuery.of(context).orientation == Orientation.landscape) {
      crossAxisCount = 3;
      childAspectRatio = 0.60;
    }

    final productosFiltrados = _productos.where((p) {
      final coincideTexto = p.nombre
          .toLowerCase()
          .contains(_filtroBusqueda.toLowerCase()) ||
          p.codigoBarras.contains(_filtroBusqueda);
      final coincideStockBajo = !_soloStockBajo || (p.stock <= p.stockMinimo);
      return coincideTexto && coincideStockBajo;
    }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leadingWidth: 90,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const InventoryCatalogScreen(),
                    ),
                  );
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Image.asset(
                'assets/logo.png',
                width: 30,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.storefront, color: Colors.white, size: 24),
              ),
            ),
          ],
        ),
        title: Text(
          isMobile ? 'Inventario' : 'Gestión de Inventario y Proveedores',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: isMobile ? true : false,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(68, 109, 241, 1),
                Color.fromARGB(255, 85, 59, 235),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: const [
          SizedBox(width: 8),
        ],
      ),
      floatingActionButton: _esAdmin
          ? SizedBox(
              height: isMobile ? 56 : 72,
              child: FloatingActionButton.extended(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 8,
                heroTag: 'fab_add_product',
                onPressed: () => _mostrarFormularioProducto(),
                icon: const Icon(Icons.add, size: 24),
                label: Text(
                  isMobile ? 'Nuevo' : 'Nuevo Producto',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 15 : 18,
                  ),
                ),
                extendedPadding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
      body: _isLoading
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 4,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (_, index) => const _ProductCardSkeleton(),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildSearchBar(isMobile),
                  const SizedBox(height: 16),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _cargarInventario,
                      color: const Color(0xFF10B981),
                      child: productosFiltrados.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron productos.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childAspectRatio,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: productosFiltrados.length,
                              itemBuilder: (context, index) {
                                final p = productosFiltrados[index];
                                final esStockBajo = p.stock <= p.stockMinimo;
                                final controller = _animationController ??=
                                    AnimationController(
                                      vsync: this,
                                      duration: const Duration(milliseconds: 400),
                                    )..forward();
                                return _ProductCard(
                                  producto: p,
                                  stockBajo: esStockBajo,
                                  onTap: () => _mostrarDetalleProducto(p),
                                  isMobile: isMobile,
                                  isTablet: isTablet,
                                  isDesktop: isDesktop,
                                  index: index,
                                  animationController: controller,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ==========================================
// WIDGET DE TARJETA DE PRODUCTO (COMPACTA)
// ==========================================
class _ProductCard extends StatefulWidget {
  final ProductoEntity producto;
  final bool stockBajo;
  final VoidCallback onTap;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;
  final int index;
  final AnimationController animationController;

  const _ProductCard({
    required this.producto,
    required this.stockBajo,
    required this.onTap,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
    required this.index,
    required this.animationController,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    final start = 0.05 * widget.index;
    final end = start + 0.1;
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(
          start.clamp(0.0, 1.0),
          end.clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double safeStockMin = widget.producto.stockMinimo.isFinite
        ? widget.producto.stockMinimo
        : 0.0;
    final String stockMinStr = safeStockMin % 1 == 0
        ? safeStockMin.toInt().toString()
        : safeStockMin.toStringAsFixed(1);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.stockBajo
                      ? const Color(0xFFFCA5A5)
                      : (widget.isTablet
                          ? const Color(0xFFCBD5E1)
                          : const Color(0xFFE2E8F0)),
                  width: widget.stockBajo ? 2 : (widget.isTablet ? 2.5 : 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: widget.isTablet ? 0.08 : 0.05,
                    ),
                    blurRadius: widget.isTablet ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _buildVerticalLayout(theme, stockMinStr),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // DISEÑO VERTICAL – COMPACTO Y RESPONSIVE
  // ==========================================
  Widget _buildVerticalLayout(ThemeData theme, String stockMinStr) {
    final bool isMobile = widget.isMobile;
    final bool isTablet = widget.isTablet;

    final double imageHeight = isMobile ? 100 : (isTablet ? 140 : 190);
    final double fontSizeNombre = isMobile ? 13 : (isTablet ? 16 : 20);
    final double fontSizePrecio = isMobile ? 14 : (isTablet ? 18 : 22);
    final double fontSizeDetalle = isMobile ? 10 : (isTablet ? 13 : 16);
    final double fontSizeIcono = isMobile ? 16 : (isTablet ? 22 : 28);
    final double paddingInterior = isMobile ? 6 : (isTablet ? 10 : 16);
    final double spacingSmall = isMobile ? 1 : (isTablet ? 2 : 4);
    final double spacingMedium = isMobile ? 2 : (isTablet ? 4 : 8);
    final int nombreMaxLines = (isMobile) ? 1 : 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Imagen
        Container(
          height: imageHeight,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Stack(
            children: [
              Center(
                child: widget.producto.imagenUrl.isNotEmpty
                    ? Image.network(
                        widget.producto.imagenUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.inventory_2,
                          size: isMobile ? 40 : (isTablet ? 50 : 64),
                          color: const Color(0xFF3B82F6),
                        ),
                      )
                    : Icon(
                        Icons.inventory_2,
                        size: isMobile ? 40 : (isTablet ? 50 : 64),
                        color: const Color(0xFF3B82F6),
                      ),
              ),
              if (widget.stockBajo)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDC2626),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '¡STOCK BAJO!',
                      style: TextStyle(
                        fontSize: isMobile ? 8 : (isTablet ? 10 : 12),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    widget.producto.esPesado
                        ? Icons.scale_outlined
                        : Icons.inventory_outlined,
                    size: fontSizeIcono * 0.75,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Información compacta
        Padding(
          padding: EdgeInsets.all(paddingInterior),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.producto.nombre,
                maxLines: nombreMaxLines,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizeNombre,
                ),
              ),
              SizedBox(height: spacingSmall),
              Text(
                'Cód: ${widget.producto.codigoBarras}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: fontSizeDetalle,
                  color: const Color(0xFF94A3B8),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: spacingMedium),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizePrecio,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.stockBajo
                          ? const Color(0xFFFEE2E2)
                          : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: widget.stockBajo
                            ? const Color(0xFFFECACA)
                            : const Color(0xFFE2E8F0),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      'Stock: ${widget.producto.stock}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: fontSizeDetalle - 1,
                        fontWeight: FontWeight.w600,
                        color: widget.stockBajo
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF475569),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacingSmall),
              if (widget.producto.categoria.isNotEmpty)
                Text(
                  'Cat: ${widget.producto.categoria}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: fontSizeDetalle,
                    color: const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              if (widget.producto.proveedorNombre.isNotEmpty) ...[
                SizedBox(height: spacingSmall),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: const Color(0xFFC7D2FE),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.phone,
                        size: isMobile ? 8 : (isTablet ? 12 : 16),
                        color: const Color(0xFF4F46E5),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          widget.producto.proveedorNombre,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: fontSizeDetalle - 1,
                            fontStyle: FontStyle.italic,
                            color: const Color(0xFF4F46E5),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ==========================================
// SKELETON LOADER
// ==========================================
class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.dividerColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 12, width: double.infinity, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 4),
                Container(height: 10, width: 60, color: const Color(0xFFF1F5F9)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(height: 12, width: 40, color: const Color(0xFFF1F5F9)),
                    Container(height: 10, width: 50, color: const Color(0xFFF1F5F9)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// DIÁLOGO DEL ESCÁNER
// ==========================================
class _BarcodeScannerDialog extends StatefulWidget {
  const _BarcodeScannerDialog();

  @override
  State<_BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<_BarcodeScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isTorchOn = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              if (_isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  _isProcessing = true;
                  Navigator.of(context).pop(rawValue);
                  break;
                }
              }
              Future.delayed(const Duration(milliseconds: 500), () {
                _isProcessing = false;
              });
            },
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF10B981), width: 4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🔍 Centra el código',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 28,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _isTorchOn = !_isTorchOn;
                      });
                      _controller.toggleTorch();
                    },
                    splashRadius: 28,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Apunta la cámara al código de barras',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}