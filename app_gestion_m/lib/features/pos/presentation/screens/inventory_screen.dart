import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/usuario_entity.dart'; //

class InventoryScreen extends StatefulWidget {
  final UsuarioEntity usuarioActual;
  const InventoryScreen({super.key, required this.usuarioActual});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final IsarService _isarService = IsarService();
  List<ProductoEntity> _productos = [];
  bool _isLoading = true;
  String _filtroBusqueda = '';
  bool _soloStockBajo = false;

  bool get _esAdmin => widget.usuarioActual.rol == 'admin';

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

  void _mostrarFormularioProducto({ProductoEntity? productoAEditar}) {
    if (!_esAdmin) return;

    final isEditing = productoAEditar != null;

    final codigoController = TextEditingController(text: productoAEditar?.codigoBarras ?? '');
    final nombreController = TextEditingController(text: productoAEditar?.nombre ?? '');
    final precioController = TextEditingController(text: productoAEditar?.precioUnidad.toString() ?? '');
    final stockController = TextEditingController(text: productoAEditar?.stock.toString() ?? '');
    final stockMinController = TextEditingController(text: productoAEditar?.stockMinimo.toString() ?? '5.0');
    final categoriaController = TextEditingController(text: productoAEditar?.categoria ?? 'General');
    final proveedorNombreController = TextEditingController(text: productoAEditar?.proveedorNombre ?? '');
    final proveedorTelController = TextEditingController(text: productoAEditar?.proveedorTelefono ?? '');
    
    bool esPesado = productoAEditar?.esPesado ?? false;

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
                            child: TextField(
                              controller: categoriaController,
                              decoration: const InputDecoration(labelText: 'Categoría'),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  onPressed: () async {
                    final producto = productoAEditar ?? ProductoEntity();
                    producto.codigoBarras = codigoController.text.trim();
                    producto.nombre = nombreController.text.trim();
                    producto.precioUnidad = double.tryParse(precioController.text) ?? 0.0;
                    producto.stock = double.tryParse(stockController.text) ?? 0.0;
                    producto.stockMinimo = double.tryParse(stockMinController.text) ?? 5.0;
                    producto.categoria = categoriaController.text.trim();
                    producto.esPesado = esPesado;
                    producto.proveedorNombre = proveedorNombreController.text.trim();
                    producto.proveedorTelefono = proveedorTelController.text.trim();

                    await _isarService.guardarProducto(producto);
                    if (context.mounted) {
                      Navigator.pop(context);
                      _cargarInventario();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Producto guardado exitosamente'), backgroundColor: Colors.green),
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
    final productosFiltrados = _productos.where((p) {
      final coincideTexto = p.nombre.toLowerCase().contains(_filtroBusqueda.toLowerCase()) ||
          p.codigoBarras.contains(_filtroBusqueda);
      final coincideStockBajo = !_soloStockBajo || (p.stock <= p.stockMinimo);
      return coincideTexto && coincideStockBajo;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Gestión de Inventario y Proveedores'),
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
              label: const Text('Nuevo Producto'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final p = productosFiltrados[index];
                            final esStockBajo = p.stock <= p.stockMinimo;

                            return Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: esStockBajo ? Colors.red.shade300 : Colors.grey.shade300,
                                  width: esStockBajo ? 1.5 : 1,
                                ),
                              ),
                              child: ListTile(
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
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '📦 Stock actual: ${p.stock % 1 == 0 ? p.stock.toInt() : p.stock} (Mínimo: ${p.stockMinimo % 1 == 0 ? p.stockMinimo.toInt() : p.stockMinimo})',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: esStockBajo ? Colors.red.shade700 : Colors.blueGrey,
                                      ),
                                    ),
                                    if (p.proveedorNombre.isNotEmpty)
                                      Text(
                                        '📞 Proveedor: ${p.proveedorNombre} (${p.proveedorTelefono.isEmpty ? "Sin teléfono" : p.proveedorTelefono})',
                                        style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: Colors.indigo),
                                      ),
                                  ],
                                ),
                                trailing: _esAdmin
                                    ? IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 20),
                                        onPressed: () => _mostrarFormularioProducto(productoAEditar: p),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}