import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../utils/responsive_helper.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../services/sync_service.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  final UsuarioEntity usuarioLogueado;
  const InventoryScreen({super.key, required this.usuarioLogueado});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final IsarService _isarService = IsarService();

  List<ProductoEntity> _productos = [];
  bool _isLoading = true;
  String _filtroBusqueda = '';
  bool _soloStockBajo = false;

  bool get _esAdmin => widget.usuarioLogueado.rol == 'admin';

  @override
  void initState() {
    super.initState();
    _cargarInventario();
  }

  Future<void> _cargarInventario() async {
    setState(() => _isLoading = true);
    final productos = await _isarService.obtenerProductos();
    if (mounted) {
      setState(() {
        _productos = productos;
        _isLoading = false;
      });
    }
  }

  Future<String?> _mostrarDialogoNuevaCategoria(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nueva Categoría'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nombre de la categoría',
              hintText: 'Ej: Bebidas, Limpieza, Víveres...',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(dialogContext, text);
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarFormularioProducto({ProductoEntity? productoAEditar}) {
    if (!_esAdmin) return;

    final isEditing = productoAEditar != null;

    final codigoController = TextEditingController(text: productoAEditar?.codigoBarras ?? '');
    final nombreController = TextEditingController(text: productoAEditar?.nombre ?? '');
    final precioController = TextEditingController(text: productoAEditar?.precioUnidad.toString() ?? '');
    final stockController = TextEditingController(text: productoAEditar?.stock.toString() ?? '');
    final stockMinController = TextEditingController(text: productoAEditar?.stockMinimo.toString() ?? '5.0');
    final proveedorNombreController = TextEditingController(text: productoAEditar?.proveedorNombre ?? '');
    final proveedorTelController = TextEditingController(text: productoAEditar?.proveedorTelefono ?? '');

    bool esPesado = productoAEditar?.esPesado ?? false;

    final setCategorias = _productos
        .map((p) => p.categoria.trim())
        .where((c) => c.isNotEmpty)
        .toSet();

    setCategorias.addAll(['General', 'Frutas', 'Abarrotes', 'Lácteos']);

    if (productoAEditar != null && productoAEditar.categoria.isNotEmpty) {
      setCategorias.add(productoAEditar.categoria.trim());
    }

    final List<String> listaCategorias = setCategorias.toList()..sort();
    String categoriaSeleccionada = productoAEditar?.categoria ?? 'General';

    if (!listaCategorias.contains(categoriaSeleccionada)) {
      listaCategorias.add(categoriaSeleccionada);
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Producto' : 'Nuevo Producto / Proveedor'),
              content: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: codigoController,
                        decoration: const InputDecoration(labelText: 'Código de Barras'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: precioController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Precio Unidad (\$)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: stockController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Stock Inicial'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: stockMinController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(labelText: 'Stock Mínimo (Alerta)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    initialValue: categoriaSeleccionada,
                                    decoration: const InputDecoration(
                                      labelText: 'Categoría',
                                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    isExpanded: true,
                                    items: listaCategorias.map((cat) {
                                      return DropdownMenuItem<String>(
                                        value: cat,
                                        child: Text(cat, overflow: TextOverflow.ellipsis),
                                      );
                                    }).toList(),
                                    onChanged: (val) {
                                      if (val != null) {
                                        setStateModal(() => categoriaSeleccionada = val);
                                      }
                                    },
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle, color: Colors.teal),
                                  tooltip: 'Crear nueva categoría',
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
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('¿Es producto pesado (granel)?', style: TextStyle(fontSize: 13)),
                        value: esPesado,
                        onChanged: (val) => setStateModal(() => esPesado = val),
                      ),
                      const Divider(height: 24),
                      const Text(
                        'Información del Proveedor',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: proveedorNombreController,
                        decoration: const InputDecoration(labelText: 'Nombre del Proveedor / Empresa'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: proveedorTelController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Teléfono del Proveedor'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final producto = productoAEditar ?? ProductoEntity();
                    producto.codigoBarras = codigoController.text.trim();
                    producto.nombre = nombreController.text.trim();

                    final pPrecio = double.tryParse(precioController.text.trim().replaceAll(',', '.')) ?? 0.0;
                    final pStock = double.tryParse(stockController.text.trim().replaceAll(',', '.')) ?? 0.0;
                    final pStockMin = double.tryParse(stockMinController.text.trim().replaceAll(',', '.')) ?? 5.0;

                    producto.precioUnidad = (pPrecio.isNaN || pPrecio.isInfinite) ? 0.0 : pPrecio;
                    producto.stock = (pStock.isNaN || pStock.isInfinite) ? 0.0 : pStock;
                    producto.stockMinimo = (pStockMin.isNaN || pStockMin.isInfinite) ? 5.0 : pStockMin;
                    producto.categoria = categoriaSeleccionada;
                    producto.esPesado = esPesado;
                    producto.proveedorNombre = proveedorNombreController.text.trim();
                    producto.proveedorTelefono = proveedorTelController.text.trim();

                    await _isarService.guardarProducto(producto);
                    await SyncService().sincronizarCategoriasASupabase();
                    await SyncService().sincronizarProductosASupabase();

                    if (context.mounted) {
                      Navigator.pop(context);
                      _cargarInventario();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Producto guardado y sincronizado exitosamente'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    ResponsiveHelper.isTablet(context);
    final fontSize = ResponsiveHelper.getFontSize(context, baseSize: 14);

    final productosFiltrados = _productos.where((p) {
      final coincideTexto = p.nombre.toLowerCase().contains(_filtroBusqueda.toLowerCase()) ||
          p.codigoBarras.contains(_filtroBusqueda);
      final coincideStockBajo = !_soloStockBajo || (p.stock <= p.stockMinimo);
      return coincideTexto && coincideStockBajo;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          isMobile ? 'Inventario' : 'Gestión de Inventario y Proveedores',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarInventario,
          ),
        ],
      ),
      floatingActionButton: _esAdmin
          ? FloatingActionButton.extended(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              onPressed: () => _mostrarFormularioProducto(),
              icon: const Icon(Icons.add),
              label: Text(isMobile ? 'Nuevo' : 'Nuevo Producto'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: isMobile
            ? _buildMobileLayout(productosFiltrados, fontSize)
            : _buildDesktopLayout(productosFiltrados, fontSize),
      ),
    );
  }

  // ==========================================
  // LAYOUT DESKTOP
  // ==========================================

  Widget _buildDesktopLayout(List<ProductoEntity> productosFiltrados, double fontSize) {
    return Column(
      children: [
        // Barra de búsqueda y filtro
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 42,
                child: TextField(
                  onChanged: (val) => setState(() => _filtroBusqueda = val),
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o código de barras...',
                    hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilterChip(
              label: const Text('⚠️ Stock Bajo'),
              selected: _soloStockBajo,
              onSelected: (val) => setState(() => _soloStockBajo = val),
              selectedColor: Colors.amber.shade200,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Lista de productos
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.teal))
              : productosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron productos.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      itemCount: productosFiltrados.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final p = productosFiltrados[index];
                        return _buildProductCard(p, fontSize, isMobile: false);
                      },
                    ),
        ),
      ],
    );
  }

  // ==========================================
  // LAYOUT MÓVIL
  // ==========================================

  Widget _buildMobileLayout(List<ProductoEntity> productosFiltrados, double fontSize) {
    return Column(
      children: [
        // Barra de búsqueda con filtro integrado
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: TextField(
                        onChanged: (val) => setState(() => _filtroBusqueda = val),
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
                          prefixIcon: const Icon(Icons.search, size: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('⚠️ Stock Bajo'),
                    selected: _soloStockBajo,
                    onSelected: (val) => setState(() => _soloStockBajo = val),
                    selectedColor: Colors.amber.shade200,
                    labelStyle: const TextStyle(fontSize: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Lista de productos
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.teal))
              : productosFiltrados.isEmpty
                  ? const Center(
                      child: Text(
                        'No se encontraron productos.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    )
                  : ListView.separated(
                      itemCount: productosFiltrados.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (context, index) {
                        final p = productosFiltrados[index];
                        return _buildProductCard(p, fontSize, isMobile: true);
                      },
                    ),
        ),
      ],
    );
  }

  // ==========================================
  // TARJETA DE PRODUCTO (compartida)
  // ==========================================

  Widget _buildProductCard(ProductoEntity p, double fontSize, {required bool isMobile}) {
    final esStockBajo = p.stock <= p.stockMinimo;

    return Card(
      elevation: isMobile ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: esStockBajo ? Colors.red.shade300 : Colors.grey.shade300,
          width: esStockBajo ? 1.5 : 1,
        ),
      ),
      child: isMobile
          ? _buildMobileCard(p, esStockBajo, fontSize)
          : _buildDesktopCard(p, esStockBajo, fontSize),
    );
  }

  Widget _buildDesktopCard(ProductoEntity p, bool esStockBajo, double fontSize) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: esStockBajo ? Colors.red.shade100 : Colors.teal.shade100,
        child: Icon(
          esStockBajo ? Icons.warning_amber_rounded : Icons.inventory_2,
          color: esStockBajo ? Colors.red : Colors.teal,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              p.nombre,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (esStockBajo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Text(
                'STOCK BAJO',
                style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Código: ${p.codigoBarras} | Cat: ${p.categoria} | Precio: \$${p.precioUnidad.toStringAsFixed(2)}',
            style: TextStyle(fontSize: fontSize * 0.8),
          ),
          const SizedBox(height: 2),
          Text(
            '📦 Stock actual: ${p.stock % 1 == 0 ? p.stock.toInt() : p.stock} (Mínimo: ${p.stockMinimo % 1 == 0 ? p.stockMinimo.toInt() : p.stockMinimo})',
            style: TextStyle(
              fontSize: fontSize * 0.8,
              fontWeight: FontWeight.bold,
              color: esStockBajo ? Colors.red.shade700 : Colors.blueGrey,
            ),
          ),
          if (p.proveedorNombre.isNotEmpty)
            Text(
              '📞 Proveedor: ${p.proveedorNombre} (${p.proveedorTelefono.isEmpty ? "Sin teléfono" : p.proveedorTelefono})',
              style: TextStyle(
                fontSize: fontSize * 0.75,
                fontStyle: FontStyle.italic,
                color: Colors.indigo,
              ),
            ),
        ],
      ),
      trailing: _esAdmin
          ? IconButton(
              icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
              onPressed: () => _mostrarFormularioProducto(productoAEditar: p),
            )
          : null,
    );
  }

  Widget _buildMobileCard(ProductoEntity p, bool esStockBajo, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila superior: nombre y badge
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: esStockBajo ? Colors.red.shade100 : Colors.teal.shade100,
                child: Icon(
                  esStockBajo ? Icons.warning_amber_rounded : Icons.inventory_2,
                  color: esStockBajo ? Colors.red : Colors.teal,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  p.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize * 0.9,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (esStockBajo)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: const Text(
                    'STOCK BAJO',
                    style: TextStyle(fontSize: 8, color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // Información
          Text(
            'Cód: ${p.codigoBarras} | Cat: ${p.categoria}',
            style: TextStyle(fontSize: fontSize * 0.75, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Precio: \$${p.precioUnidad.toStringAsFixed(2)}',
                style: TextStyle(fontSize: fontSize * 0.8, fontWeight: FontWeight.w600),
              ),
              Text(
                'Stock: ${p.stock % 1 == 0 ? p.stock.toInt() : p.stock}',
                style: TextStyle(
                  fontSize: fontSize * 0.8,
                  fontWeight: FontWeight.bold,
                  color: esStockBajo ? Colors.red.shade700 : Colors.blueGrey,
                ),
              ),
            ],
          ),
          if (p.proveedorNombre.isNotEmpty)
            Text(
              '📞 ${p.proveedorNombre}',
              style: TextStyle(fontSize: fontSize * 0.7, color: Colors.indigo, fontStyle: FontStyle.italic),
            ),
          const SizedBox(height: 4),
          if (_esAdmin)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _mostrarFormularioProducto(productoAEditar: p),
                icon: const Icon(Icons.edit, size: 14, color: Colors.blueGrey),
                label: const Text('Editar', style: TextStyle(fontSize: 11, color: Colors.blueGrey)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
        ],
      ),
    );
  }
}