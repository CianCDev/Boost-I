import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
  // MODAL DE PRODUCTO (CREAR/EDITAR)
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
                  color: Theme.of(context).dialogBackgroundColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                shape: BoxShape.circle),
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

                      // === Código de barras ===
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

                      // === Nombre ===
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

                      // === URL Imagen ===
                      TextField(
                        controller: imagenUrlController,
                        style: const TextStyle(fontSize: 18, color: Color(0xFF0F172A)),
                        onChanged: (val) => setStateModal(() => imagenUrlPreview = val),
                        decoration: InputDecoration(
                          labelText: 'URL de la Imagen',
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
                      if (imagenUrlPreview.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imagenUrlPreview,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      color: Colors.grey.shade400,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Imagen no válida',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),

                      // === Precio y Stock (Row) – en móvil se apilan ===
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
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981)
                                          .withOpacity(0.1),
                                      foregroundColor: const Color(0xFF10B981),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
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

                      // === Switch: Es pesado ===
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

                      // === Proveedor ===
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

                      // === Botones Guardar/Cancelar ===
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

                                    final producto = productoAEditar ?? ProductoEntity();
                                    producto.codigoBarras =
                                        codigoController.text.trim();
                                    producto.nombre = nombre;
                                    producto.imagenUrl =
                                        imagenUrlController.text.trim().isNotEmpty
                                            ? imagenUrlController.text.trim()
                                            : '';
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
                                    await SyncService().sincronizarCategoriasASupabase();
                                    await SyncService().sincronizarProductosASupabase();

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

  // Widget auxiliar para el dropdown de categoría (evita duplicación)
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
  // MODAL DE DETALLES DEL PRODUCTO (CORREGIDO)
  // ==========================================
 void _mostrarDetalleProducto(ProductoEntity producto) {
  final isMobile = ResponsiveHelper.isMobile(context);
  final isTablet = ResponsiveHelper.isTablet(context);

  final bool isLargeScreen = !isMobile;
  final double maxWidth = isLargeScreen ? 850.0 : 600.0;
  final double padding = isMobile ? 12.0 : (isTablet ? 24.0 : 32.0);
  final double imageHeight = isMobile ? 120 : (isTablet ? 200 : 280);
  final double imageMaxWidth = isLargeScreen ? 500 : 400;
  
  // ✅ MÁRGENES LATERALES MEJORADOS
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
          horizontal: horizontalInset, // ✅ MÁRGENES LATERALES
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
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
                      )
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
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.inventory_2,
                                  size: 64,
                                  color: Colors.blueGrey,
                                ),
                              )
                            : const Icon(Icons.inventory_2, size: 64, color: Colors.blueGrey),
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

                  // BOTONES
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
                              await _isarService.eliminarProducto(producto.id);
                              if (mounted) {
                                // ignore: use_build_context_synchronously
                                Navigator.pop(dialogContext);
                                _cargarInventario();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Producto eliminado correctamente.'),
                                    backgroundColor: Color(0xFF10B981),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error al eliminar: $e'),
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
                onChanged: (val) => setState(() => _filtroBusqueda = val),
                decoration: InputDecoration(
                  hintText: isMobile
                      ? 'Buscar...'
                      : 'Buscar por nombre o código de barras...',
                  hintStyle: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: Row(
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColorDark ?? Colors.indigo.shade700,
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
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
                                crossAxisCount:
                                    isMobile ? 1 : (isTablet ? 2 : 3),
                                childAspectRatio:
                                    isMobile ? 1.4 : (isTablet ? 1.6 : 1.5),
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
// WIDGET DE TARJETA DE PRODUCTO
// ==========================================
class _ProductCard extends StatefulWidget {
  final ProductoEntity producto;
  final bool stockBajo;
  final VoidCallback onTap;
  final bool isMobile;
  final bool isTablet;
  final int index;
  final AnimationController animationController;

  const _ProductCard({
    required this.producto,
    required this.stockBajo,
    required this.onTap,
    required this.isMobile,
    required this.isTablet,
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
            child: Ink(
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
                    color: Colors.black.withOpacity(
                        widget.isTablet ? 0.08 : 0.05),
                    blurRadius: widget.isTablet ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: widget.isMobile
                          ? 70
                          : (widget.isTablet ? 100 : 90),
                      height: widget.isMobile
                          ? 70
                          : (widget.isTablet ? 100 : 90),
                      constraints: const BoxConstraints(
                        minWidth: 60,
                        minHeight: 60,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: widget.producto.imagenUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.producto.imagenUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.inventory_2,
                                    size: 36,
                                    color: Color(0xFF3B82F6),
                                  ),
                                ),
                              )
                            : const Icon(
                                Icons.inventory_2,
                                size: 36,
                                color: Color(0xFF3B82F6),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.producto.nombre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: widget.isTablet
                                        ? 18
                                        : (widget.isMobile ? 16 : 15),
                                  ),
                                ),
                              ),
                              if (widget.stockBajo) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFFECACA),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '⚠️ BAJO',
                                    style: TextStyle(
                                      fontSize: widget.isTablet ? 11 : 9,
                                      color: const Color(0xFFEF4444),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cód: ${widget.producto.codigoBarras}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: widget.isTablet
                                      ? 15
                                      : (widget.isMobile ? 14 : 13),
                                ),
                              ),
                              Text(
                                '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: widget.isTablet
                                      ? 18
                                      : (widget.isMobile ? 16 : 15),
                                  color: const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Cat: ${widget.producto.categoria}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: widget.isTablet
                                      ? 15
                                      : (widget.isMobile ? 14 : 13),
                                ),
                              ),
                              Text(
                                'Stock: ${widget.producto.stock % 1 == 0 ? widget.producto.stock.toInt() : widget.producto.stock} / Mín: $stockMinStr',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: widget.isTablet
                                      ? 15
                                      : (widget.isMobile ? 14 : 13),
                                  fontWeight: FontWeight.w500,
                                  color: widget.stockBajo
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF475569),
                                ),
                              ),
                            ],
                          ),
                          if (widget.producto.proveedorNombre.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFC7D2FE),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '📞 ${widget.producto.proveedorNombre}${widget.producto.proveedorTelefono.isNotEmpty ? " (${widget.producto.proveedorTelefono})" : ''}',
                                style: TextStyle(
                                  fontSize: widget.isTablet
                                      ? 14
                                      : (widget.isMobile ? 12 : 12),
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
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
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18,
                    width: double.infinity,
                    color: const Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 60,
                    color: const Color(0xFFF1F5F9),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 80,
                    color: const Color(0xFFF1F5F9),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                    color: const Color(0xFF10B981).withOpacity(0.3),
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