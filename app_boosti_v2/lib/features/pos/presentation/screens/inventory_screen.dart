import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class _InventoryScreenState extends ConsumerState<InventoryScreen> with SingleTickerProviderStateMixin {
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
          SnackBar(
            content: const Text('Error al cargar el inventario. Intenta de nuevo.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<String?> _mostrarDialogoNuevaCategoria(BuildContext context) async {
    final controller = TextEditingController();
    final theme = Theme.of(context);
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
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Nueva Categoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: theme.textTheme.bodyLarge?.color)),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  style: TextStyle(fontSize: 16, color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: 'Ej: Bebidas, Limpieza, Víveres...',
                    hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.textTheme.bodyMedium?.color,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          Navigator.pop(dialogContext, text);
                        }
                      },
                      child: const Text('Agregar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
  // MODAL DE PRODUCTO
  // ==========================================
  void _mostrarFormularioProducto({ProductoEntity? productoAEditar}) {
    if (!_esAdmin) return;

    final theme = Theme.of(context);
    final isEditing = productoAEditar != null;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = !isTablet && !isMobile;

    final codigoController = TextEditingController(text: productoAEditar?.codigoBarras ?? '');
    final nombreController = TextEditingController(text: productoAEditar?.nombre ?? '');
    final imagenUrlController = TextEditingController(text: productoAEditar?.imagenUrl ?? '');
    final precioController = TextEditingController(text: productoAEditar?.precioUnidad.toString() ?? '');
    final stockController = TextEditingController(text: productoAEditar?.stock.toString() ?? '');
    final stockMinController = TextEditingController(text: productoAEditar?.stockMinimo.toString() ?? '5.0');
    final proveedorNombreController = TextEditingController(text: productoAEditar?.proveedorNombre ?? '');
    final proveedorTelController = TextEditingController(text: productoAEditar?.proveedorTelefono ?? '');

    bool esPesado = productoAEditar?.esPesado ?? false;
    String imagenUrlPreview = productoAEditar?.imagenUrl ?? '';

    final setCategorias = _productos.map((p) => p.categoria.trim()).where((c) => c.isNotEmpty).toSet();
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
            final localTheme = Theme.of(context);
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 8,
              insetPadding: EdgeInsets.symmetric(horizontal: isTablet || isDesktop ? 40.0 : 16.0, vertical: 24.0),
              child: Container(
                constraints: BoxConstraints(maxWidth: isTablet || isDesktop ? 800.0 : double.infinity),
                padding: EdgeInsets.all(isTablet ? 40.0 : 24.0),
                decoration: BoxDecoration(
                  color: localTheme.cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
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
                            decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), shape: BoxShape.circle),
                            child: Icon(isEditing ? Icons.edit_outlined : Icons.add_shopping_cart_outlined, color: const Color(0xFF10B981), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: localTheme.textTheme.bodyLarge?.color)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      TextField(
                        controller: codigoController,
                        style: TextStyle(fontSize: 18, color: localTheme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          labelText: 'Código de Barras',
                          labelStyle: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyMedium?.color),
                          filled: true,
                          fillColor: localTheme.colorScheme.surfaceVariant.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: localTheme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: nombreController,
                        style: TextStyle(fontSize: 18, color: localTheme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          labelText: 'Nombre del Producto *',
                          labelStyle: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyMedium?.color),
                          filled: true,
                          fillColor: localTheme.colorScheme.surfaceVariant.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: localTheme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: imagenUrlController,
                        style: TextStyle(fontSize: 18, color: localTheme.textTheme.bodyLarge?.color),
                        onChanged: (val) => setStateModal(() => imagenUrlPreview = val),
                        decoration: InputDecoration(
                          labelText: 'URL de la Imagen',
                          labelStyle: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyMedium?.color),
                          filled: true,
                          fillColor: localTheme.colorScheme.surfaceVariant.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: localTheme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        ),
                      ),
                      if (imagenUrlPreview.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          height: 160,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: localTheme.colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: localTheme.brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imagenUrlPreview,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Center(
                                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                  Icon(Icons.image_not_supported_outlined, color: localTheme.textTheme.bodyMedium?.color?.withOpacity(0.4), size: 32),
                                  const SizedBox(height: 8),
                                  Text('Imagen no válida', style: TextStyle(color: localTheme.textTheme.bodyMedium?.color?.withOpacity(0.5), fontSize: 12)),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: precioController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(fontSize: 18, color: localTheme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: 'Precio Unidad (\$) *',
                                labelStyle: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyMedium?.color),
                                filled: true,
                                fillColor: localTheme.colorScheme.surfaceVariant.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: localTheme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: stockController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(fontSize: 18, color: localTheme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: 'Stock Inicial *',
                                labelStyle: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyMedium?.color),
                                filled: true,
                                fillColor: localTheme.colorScheme.surfaceVariant.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: localTheme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stockMinController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: TextStyle(fontSize: 18, color: localTheme.textTheme.bodyLarge?.color),
                              decoration: InputDecoration(
                                labelText: 'Stock Mínimo *',
                                labelStyle: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyMedium?.color),
                                filled: true,
                                fillColor: localTheme.colorScheme.surfaceVariant.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: localTheme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DropdownButtonFormField<String>(
                                  initialValue: categoriaSeleccionada,
                                  decoration: InputDecoration(
                                    labelText: 'Categoría',
                                    labelStyle: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyMedium?.color),
                                    filled: true,
                                    fillColor: localTheme.colorScheme.surfaceVariant.withOpacity(0.5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: localTheme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                                  ),
                                  isExpanded: true,
                                  items: listaCategorias.map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyLarge?.color)))).toList(),
                                  onChanged: (val) { if (val != null) setStateModal(() => categoriaSeleccionada = val); },
                                  icon: Icon(Icons.keyboard_arrow_down, color: localTheme.textTheme.bodyMedium?.color),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF10B981).withOpacity(0.1),
                                      foregroundColor: const Color(0xFF10B981),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    ),
                                    onPressed: () async {
                                      final nuevaCat = await _mostrarDialogoNuevaCategoria(context);
                                      if (nuevaCat != null && nuevaCat.isNotEmpty) {
                                        setStateModal(() {
                                          if (!listaCategorias.contains(nuevaCat)) {
                                            listaCategorias.add(nuevaCat);
                                            listaCategorias.sort();
                                          }
                                          categoriaSeleccionada = nuevaCat;
                                        });
                                      }
                                    },
                                    icon: const Icon(Icons.add_circle, size: 20),
                                    label: const Text('Nueva Categoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text('¿Es producto pesado (granel)?', style: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyLarge?.color)),
                        activeThumbColor: const Color(0xFF10B981),
                        value: esPesado,
                        onChanged: (val) => setStateModal(() => esPesado = val),
                      ),
                      Divider(height: 32, color: localTheme.dividerColor),
                      Text('Información del Proveedor', style: TextStyle(fontWeight: FontWeight.bold, color: localTheme.textTheme.bodyMedium?.color, fontSize: 16)),
                      const SizedBox(height: 12),
                      TextField(
                        controller: proveedorNombreController,
                        style: TextStyle(fontSize: 18, color: localTheme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          labelText: 'Nombre del Proveedor / Empresa',
                          labelStyle: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyMedium?.color),
                          filled: true,
                          fillColor: localTheme.colorScheme.surfaceVariant.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: localTheme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: proveedorTelController,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 18, color: localTheme.textTheme.bodyLarge?.color),
                        decoration: InputDecoration(
                          labelText: 'Teléfono del Proveedor',
                          labelStyle: TextStyle(fontSize: 16, color: localTheme.textTheme.bodyMedium?.color),
                          filled: true,
                          fillColor: localTheme.colorScheme.surfaceVariant.withOpacity(0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: localTheme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Wrap(
                        alignment: WrapAlignment.end,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          if (!guardando)
                            TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                                foregroundColor: localTheme.textTheme.bodyMedium?.color,
                                backgroundColor: localTheme.colorScheme.surfaceVariant,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: guardando ? localTheme.colorScheme.surfaceVariant : const Color(0xFF10B981),
                              foregroundColor: guardando ? localTheme.textTheme.bodyMedium?.color : Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                            ),
                            onPressed: guardando ? null : () async {
                              final nombre = nombreController.text.trim();
                              final precioStr = precioController.text.trim().replaceAll(',', '.');
                              final stockStr = stockController.text.trim().replaceAll(',', '.');

                              if (nombre.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El nombre del producto es obligatorio.'), backgroundColor: Colors.redAccent));
                                return;
                              }
                              final pPrecio = double.tryParse(precioStr) ?? -1.0;
                              final pStock = double.tryParse(stockStr) ?? -1.0;
                              if (pPrecio < 0 || pStock < 0) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('El precio y el stock deben ser números válidos y mayores o iguales a 0.'), backgroundColor: Colors.redAccent));
                                return;
                              }

                              setStateModal(() => guardando = true);

                              final producto = productoAEditar ?? ProductoEntity();
                              producto.codigoBarras = codigoController.text.trim();
                              producto.nombre = nombre;
                              producto.imagenUrl = imagenUrlController.text.trim().isNotEmpty ? imagenUrlController.text.trim() : null;
                              producto.precioUnidad = pPrecio;
                              producto.stock = pStock;
                              final pStockMin = double.tryParse(stockMinController.text.trim().replaceAll(',', '.')) ?? 5.0;
                              producto.stockMinimo = (pStockMin.isNaN || pStockMin.isInfinite) ? 5.0 : pStockMin;
                              producto.categoria = categoriaSeleccionada;
                              producto.esPesado = esPesado;
                              producto.proveedorNombre = proveedorNombreController.text.trim();
                              producto.proveedorTelefono = proveedorTelController.text.trim();

                              HapticFeedback.lightImpact();

                              await _isarService.guardarProducto(producto);
                              await SyncService().sincronizarCategoriasASupabase();
                              await SyncService().sincronizarProductosASupabase();

                              if (context.mounted) {
                                Navigator.pop(context);
                                _cargarInventario();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Producto guardado y sincronizado exitosamente'), backgroundColor: Color(0xFF10B981)));
                              }
                            },
                            child: guardando 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Guardar Producto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
  // MODAL DE DETALLES DEL PRODUCTO
  // ==========================================
  void _mostrarDetalleProducto(ProductoEntity producto) {
  final theme = Theme.of(context);
  final isMobile = ResponsiveHelper.isMobile(context);
  final isTablet = ResponsiveHelper.isTablet(context);

  // Ajustar tamaños según el dispositivo
  final bool isLargeScreen = !isMobile;
  final double maxWidth = isLargeScreen ? 850.0 : 600.0;
  final double padding = isMobile ? 16.0 : (isTablet ? 28.0 : 32.0);
  final double imageHeight = isMobile ? 150 : (isTablet ? 220 : 280);
  final double imageMaxWidth = isLargeScreen ? 500 : 400;
  final double insetHorizontal = isMobile ? 8.0 : (isTablet ? 30.0 : 60.0);

  final double titleSize = isMobile ? 18 : (isTablet ? 22 : 24);
  final double nameSize = isMobile ? 20 : (isTablet ? 26 : 28);
  final double detailSize = isMobile ? 12 : (isTablet ? 15 : 16);
  final double priceSize = isMobile ? 16 : (isTablet ? 19 : 20);
  final double stockSize = isMobile ? 14 : (isTablet ? 17 : 18);

  showDialog(
    context: context,
    builder: (dialogContext) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        insetPadding: EdgeInsets.symmetric(horizontal: insetHorizontal, vertical: 24),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalles del Producto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: titleSize,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, size: 28, color: theme.textTheme.bodyLarge?.color),
                      onPressed: () => Navigator.pop(dialogContext),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    height: imageHeight,
                    width: double.infinity,
                    constraints: BoxConstraints(maxWidth: imageMaxWidth),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFE2E8F0),
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: producto.imagenUrl?.isNotEmpty ?? false
                          ? Image.network(
                              producto.imagenUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.inventory_2,
                                size: 64,
                                color: theme.colorScheme.primary,
                              ),
                            )
                          : Icon(
                              Icons.inventory_2,
                              size: 64,
                              color: theme.colorScheme.primary,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 12),
                Text(
                  producto.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: nameSize,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Cód: ${producto.codigoBarras}',
                  style: TextStyle(
                    fontSize: detailSize,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),
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
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Stock Actual: ${producto.stock % 1 == 0 ? producto.stock.toInt() : producto.stock}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: stockSize,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      'Stock Mínimo: ${producto.stockMinimo.isFinite ? (producto.stockMinimo % 1 == 0 ? producto.stockMinimo.toInt() : producto.stockMinimo) : 0}',
                      style: TextStyle(
                        fontSize: detailSize,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (producto.proveedorNombre.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.brightness == Brightness.dark
                          ? Colors.indigo.withOpacity(0.2)
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.brightness == Brightness.dark
                            ? Colors.indigo.withOpacity(0.3)
                            : const Color(0xFFC7D2FE),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Proveedor: ${producto.proveedorNombre} (${producto.proveedorTelefono.isNotEmpty ? producto.proveedorTelefono : "Sin teléfono"})',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                        color: theme.brightness == Brightness.dark
                            ? Colors.indigo.shade300
                            : const Color(0xFF4F46E5),
                        fontSize: detailSize,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_esAdmin) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 16 : 28,
                            vertical: isMobile ? 12 : 18,
                          ),
                          foregroundColor: theme.textTheme.bodyMedium?.color,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          'Cerrar',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : 32,
                            vertical: isMobile ? 12 : 18,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          _mostrarFormularioProducto(productoAEditar: producto);
                        },
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        label: Text(
                          'Editar Producto',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 14 : 16,
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
      );
    },
  );
}

  // ==========================================
  // BARRA DE BÚSQUEDA CON ESCÁNER Y FILTRO
  // ==========================================
  Widget _buildSearchBar(bool isMobile) {
    final theme = Theme.of(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFE2E8F0),
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
                  hintText: isMobile ? 'Buscar...' : 'Buscar por nombre o código de barras...',
                  hintStyle: TextStyle(fontSize: isMobile ? 13 : 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                  prefixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner_rounded, size: 28, color: Color(0xFF475569)),
                          tooltip: 'Escanear código de barras',
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('📷 Escáner de código de barras próximo a implementar...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.search, size: 20, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                    ],
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  filled: true,
                  fillColor: theme.cardColor,
                ),
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('⚠️ Stock Bajo'),
            selected: _soloStockBajo,
            onSelected: (val) => setState(() => _soloStockBajo = val),
            selectedColor: theme.colorScheme.error.withOpacity(0.2),
            checkmarkColor: theme.colorScheme.error,
            labelStyle: TextStyle(fontSize: isMobile ? 10 : 13, fontWeight: FontWeight.bold, color: _soloStockBajo ? theme.colorScheme.error : theme.textTheme.bodyMedium?.color),
            backgroundColor: theme.cardColor,
            side: BorderSide(
              color: _soloStockBajo ? theme.colorScheme.error : (theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFE2E8F0)),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    final productosFiltrados = _productos.where((p) {
      final coincideTexto = p.nombre.toLowerCase().contains(_filtroBusqueda.toLowerCase()) || p.codigoBarras.contains(_filtroBusqueda);
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
                errorBuilder: (_, _, _) => const Icon(Icons.storefront, color: Colors.white, size: 24),
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
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color.fromRGBO(95, 132, 255, 1), Color.fromARGB(255, 85, 59, 235)]),
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
                    fontSize: isMobile ? 15 : 18
                  ),
                ),
                extendedPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            )
          : null,
      body: _isLoading
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                          ? Center(child: Text('No se encontraron productos.', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 14)))
                          : GridView.builder(
                              padding: const EdgeInsets.only(bottom: 100),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: isMobile ? 1 : (isTablet ? 2 : 3),
                                childAspectRatio: isMobile ? 1.4 : (isTablet ? 1.6 : 1.5),
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: productosFiltrados.length,
                              itemBuilder: (context, index) {
                                final p = productosFiltrados[index];
                                final esStockBajo = p.stock <= p.stockMinimo;
                                final controller = _animationController ??= AnimationController(vsync: this, duration: const Duration(milliseconds: 400))..forward();
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
      CurvedAnimation(parent: widget.animationController, curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double safeStockMin = widget.producto.stockMinimo.isFinite ? widget.producto.stockMinimo : 0.0;
    final String stockMinStr = safeStockMin % 1 == 0 ? safeStockMin.toInt().toString() : safeStockMin.toStringAsFixed(1);

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
                    : (theme.brightness == Brightness.dark 
                        ? Colors.grey.shade600 
                        : (widget.isTablet ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0))),
                  width: widget.stockBajo ? 2 : (widget.isTablet ? 2.5 : 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(widget.isTablet ? 0.08 : 0.05),
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
                      width: widget.isMobile ? 70 : (widget.isTablet ? 100 : 90),
                      height: widget.isMobile ? 70 : (widget.isTablet ? 100 : 90),
                      constraints: const BoxConstraints(minWidth: 60, minHeight: 60),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: widget.producto.imagenUrl?.isNotEmpty ?? false
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  widget.producto.imagenUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Icon(Icons.inventory_2, size: 36, color: theme.colorScheme.primary),
                                ),
                              )
                            : Icon(Icons.inventory_2, size: 36, color: theme.colorScheme.primary),
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: widget.isTablet ? 18 : (widget.isMobile ? 16 : 15),
                                    color: theme.textTheme.bodyLarge?.color,
                                  ),
                                ),
                              ),
                              if (widget.stockBajo) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.error.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: theme.colorScheme.error.withOpacity(0.3), width: 1),
                                  ),
                                  child: Text(
                                    '⚠️ BAJO',
                                    style: TextStyle(fontSize: widget.isTablet ? 11 : 9, color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Cód: ${widget.producto.codigoBarras}', style: TextStyle(fontSize: widget.isTablet ? 15 : (widget.isMobile ? 14 : 13), color: theme.textTheme.bodyMedium?.color)),
                              Text('\$${widget.producto.precioUnidad.toStringAsFixed(2)}', style: TextStyle(fontSize: widget.isTablet ? 18 : (widget.isMobile ? 16 : 15), fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Cat: ${widget.producto.categoria}', style: TextStyle(fontSize: widget.isTablet ? 15 : (widget.isMobile ? 14 : 13), color: theme.textTheme.bodyMedium?.color)),
                              Text('Stock: ${widget.producto.stock % 1 == 0 ? widget.producto.stock.toInt() : widget.producto.stock} / Mín: $stockMinStr', style: TextStyle(fontSize: widget.isTablet ? 15 : (widget.isMobile ? 14 : 13), fontWeight: FontWeight.w500, color: widget.stockBajo ? theme.colorScheme.error : theme.textTheme.bodyMedium?.color)),
                            ],
                          ),
                          if (widget.producto.proveedorNombre.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark ? Colors.indigo.withOpacity(0.2) : const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.brightness == Brightness.dark ? Colors.indigo.withOpacity(0.3) : const Color(0xFFC7D2FE),
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '📞 ${widget.producto.proveedorNombre}${widget.producto.proveedorTelefono.isNotEmpty ? " (${widget.producto.proveedorTelefono})" : ''}',
                                style: TextStyle(fontSize: widget.isTablet ? 14 : (widget.isMobile ? 12 : 12), fontStyle: FontStyle.italic, color: theme.brightness == Brightness.dark ? Colors.indigo.shade300 : const Color(0xFF4F46E5)),
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
          color: theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 18, width: double.infinity, color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 60, color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 8),
                  Container(height: 12, width: 80, color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}