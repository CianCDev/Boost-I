import 'package:flutter/material.dart';
import '../../data/local/entities/isar_service.dart';
import '../../data/local/entities/producto_entity.dart';
import '../../data/local/entities/venta_entity.dart';
import '../services/ticket_service.dart';
import '../widgets/cobrar_dialog.dart';

class InventoryCatalogScreen extends StatefulWidget {
  const InventoryCatalogScreen({super.key});

  @override
  State<InventoryCatalogScreen> createState() => _InventoryCatalogScreenState();
}

class _InventoryCatalogScreenState extends State<InventoryCatalogScreen> {
  final IsarService _isarService = IsarService();

  String _categoriaSeleccionada = 'Todas';
  final List<String> _categorias = ['Todas', 'Frutas', 'Abarrotes', 'Lácteos', 'Bebidas'];
  final List<Map<String, dynamic>> _carrito = [];

  List<ProductoEntity> _productosCatalog = [];
  List<ProductoEntity> _productosFiltrados = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _inicializarPantalla();
  }

  Future<void> _inicializarPantalla() async {
    await _cargarProductosDesdeIsar();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarProductosDesdeIsar() async {
    try {
      if (mounted) setState(() => _isLoading = true);

      final productos = await _isarService.obtenerProductos();

      if (mounted) {
        setState(() {
          _productosCatalog = productos;
          _isLoading = false;
        });
        _filtrarProductos();
      }
    } catch (e, stackTrace) {
      debugPrint('Error al cargar productos desde Isar: $e\n$stackTrace');
      if (mounted) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error al cargar inventario: $e'),
        backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  double get _totalCarrito {
    return _carrito.fold(0.0, (suma, item) => suma + (item['subtotal'] as double));
  }

  void _filtrarProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _productosFiltrados = _productosCatalog.where((prod) {
        final coincideNombre = prod.nombre.toLowerCase().contains(query);
        final coincideCodigo = prod.codigoBarras.toLowerCase().contains(query);
        final coincideCategoria = _categoriaSeleccionada == 'Todas' || prod.categoria == _categoriaSeleccionada;

        return (coincideNombre || coincideCodigo) && coincideCategoria;
      }).toList();
    });
  }

  void _agregarAlCarrito(ProductoEntity producto, double cantidad) {
    if (producto.stock < cantidad && !producto.esPesado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock insuficiente para agregar esta cantidad'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      final index = _carrito.indexWhere((item) => item['codigo'] == producto.codigoBarras);

      if (index != -1) {
        final nuevaCantidad = _carrito[index]['cantidad'] + cantidad;
        _carrito[index]['cantidad'] = nuevaCantidad;
        _carrito[index]['subtotal'] = nuevaCantidad * producto.precioUnidad;
      } else {
        _carrito.add({
          'codigo': producto.codigoBarras,
          'nombre': producto.nombre,
          'precio': producto.precioUnidad,
          'cantidad': cantidad,
          'esPesado': producto.esPesado,
          'subtotal': cantidad * producto.precioUnidad,
        });
      }
    });
  }

  void _eliminarDelCarrito(int index) {
    setState(() {
      _carrito.removeAt(index);
    });
  }

  void _mostrarModalCantidad(BuildContext context, ProductoEntity producto) {
    final TextEditingController cantidadController = TextEditingController(text: producto.esPesado ? '1.25' : '1');

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Cantidad para ${producto.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto.esPesado 
                    ? 'Producto de Balanza (ingrese peso en kg):' 
                    : 'Ingrese la cantidad deseada:',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cantidadController,
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(decimal: producto.esPesado),
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  suffixText: producto.esPesado ? 'Kg' : 'Unid',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                cantidadController.dispose();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final double? cantidad = double.tryParse(cantidadController.text);
                if (cantidad == null || cantidad <= 0) return;

                Navigator.of(dialogContext).pop();
                _agregarAlCarrito(producto, cantidad);
                cantidadController.dispose();
              },
              child: const Text('Agregar al Carrito'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarModalCobro(BuildContext context) async {
    if (_totalCarrito <= 0) return;

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CobrarDialog(
        totalAPagar: _totalCarrito,
      ),
    );

    if (resultado != null && resultado['procesado'] == true && mounted) {
      final String metodoPago = resultado['metodoPago'] ?? 'Efectivo';
      final double montoRecibido = resultado['montoRecibido'] ?? _totalCarrito;
      final double cambio = resultado['vuelto'] ?? 0.0;

      await _procesarYGuardarVentaIsar(metodoPago, cambio, montoRecibido);
    }
  }

  Future<void> _procesarYGuardarVentaIsar(String metodoPago, double cambio, double recibido) async {
    try {
      final String ventaIdStr = 'V-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final DateTime ahora = DateTime.now();
      final double subtotal = _totalCarrito / 1.16;
      final double impuesto = _totalCarrito - subtotal;

      final itemsIsar = _carrito.map((cartItem) {
        return VentaItemEntity()
          ..nombreProducto = cartItem['nombre']
          ..precioUnidad = cartItem['precio']
          ..cantidad = (cartItem['cantidad'] as num).toDouble()
          ..subtotal = cartItem['subtotal'];
      }).toList();

      final nuevaVenta = VentaEntity()
        ..ventaIdString = ventaIdStr
        ..fecha = ahora
        ..total = _totalCarrito
        ..subtotal = subtotal
        ..impuesto = impuesto
        ..metodoPago = metodoPago
        ..cedulaCliente = 'V-00000000'
        ..empleado = 'Administrador / Catálogo'
        ..items = itemsIsar
        ..sincronizado = false;

      await _isarService.guardarVenta(nuevaVenta);

      setState(() {
        _carrito.clear();
      });

      await _cargarProductosDesdeIsar();

      try {
        final ticketItems = itemsIsar.map((item) {
          return TicketItem(
            nombre: item.nombreProducto,
            precio: item.precioUnidad,
            cantidad: item.cantidad,
            esPesado: false,
          );
        }).toList();

        await TicketService.generarYProcesarPdf(
          items: ticketItems,
          subtotal: subtotal,
          impuesto: impuesto,
          total: nuevaVenta.total,
          metodoPago: metodoPago,
          montoRecibido: recibido,
          vuelto: cambio,
        );
      } catch (e) {
        debugPrint('Error al procesar ticket PDF: $e');
      }

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 48),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¡Venta Registrada Exitosamente!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              Text('ID Venta: $ventaIdStr', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text('Método: $metodoPago', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              if (metodoPago == 'Efectivo')
                Text('Cambio entregado: \$${cambio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar la venta: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Catálogo de Inventario (Local Isar)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar Catálogo',
            onPressed: _cargarProductosDesdeIsar,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : Row(
              children: [
                // SECCIÓN IZQUIERDA: CATÁLOGO DE PRODUCTOS (70% Ancho)
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // BARRA DE BÚSQUEDA CON AUTOCOMPLETADO
                        Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 42,
                                child: Autocomplete<ProductoEntity>(
                                  displayStringForOption: (ProductoEntity option) => option.nombre,
                                  optionsBuilder: (TextEditingValue textEditingValue) {
                                    if (textEditingValue.text.isEmpty) {
                                      return const Iterable<ProductoEntity>.empty();
                                    }
                                    final query = textEditingValue.text.toLowerCase();
                                    return _productosCatalog.where((ProductoEntity option) {
                                      final coincideNombre = option.nombre.toLowerCase().contains(query);
                                      final coincideCodigo = option.codigoBarras.toLowerCase().contains(query);
                                      return coincideNombre || coincideCodigo;
                                    });
                                  },
                                  onSelected: (ProductoEntity selection) {
                                    _mostrarModalCantidad(context, selection);
                                  },
                                  fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                                    return TextField(
                                      controller: textEditingController,
                                      focusNode: focusNode,
                                      onChanged: (text) {
                                        _searchController.text = text;
                                        _filtrarProductos();
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Buscar o escanear por nombre / código...',
                                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                        prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                        filled: true,
                                        fillColor: Colors.white,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8),
                                          borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                                        ),
                                      ),
                                    );
                                  },
                                  optionsViewBuilder: (context, onSelected, options) {
                                    return Align(
                                      alignment: Alignment.topLeft,
                                      child: Material(
                                        elevation: 6,
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          width: 380,
                                          height: 250,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFFE2E8F0)),
                                          ),
                                          child: ListView.separated(
                                            padding: const EdgeInsets.symmetric(vertical: 4),
                                            shrinkWrap: true,
                                            itemCount: options.length,
                                            separatorBuilder: (_, __) => const Divider(height: 1),
                                            itemBuilder: (BuildContext context, int index) {
                                              final ProductoEntity option = options.elementAt(index);
                                              return ListTile(
                                                dense: true,
                                                leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF3B82F6), size: 20),
                                                title: Text(
                                                  option.nombre,
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                ),
                                                subtitle: Text(
                                                  'Cód: ${option.codigoBarras} | Stock: ${option.stock}',
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                ),
                                                trailing: Text(
                                                  '\$${option.precioUnidad.toStringAsFixed(2)}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF059669)),
                                                ),
                                                onTap: () => onSelected(option),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Row(
                              children: _categorias.map((cat) {
                                final bool esSeleccionada = _categoriaSeleccionada == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _categoriaSeleccionada = cat;
                                      });
                                      _filtrarProductos();
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    mouseCursor: SystemMouseCursors.click,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: esSeleccionada ? const Color(0xFF10B981) : Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: esSeleccionada ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          if (esSeleccionada) ...[
                                            const Icon(Icons.check, size: 14, color: Colors.white),
                                            const SizedBox(width: 4),
                                          ],
                                          Text(
                                            cat,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: esSeleccionada ? FontWeight.bold : FontWeight.normal,
                                              color: esSeleccionada ? Colors.white : const Color(0xFF475569),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Grid de Productos
                        Expanded(
                          child: _productosFiltrados.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No se encontraron productos en el inventario.',
                                    style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                                  ),
                                )
                              : GridView.builder(
                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 220,
                                    childAspectRatio: 0.85,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                  ),
                                  itemCount: _productosFiltrados.length,
                                  itemBuilder: (context, index) {
                                    final producto = _productosFiltrados[index];
                                    final bool stockBajo = producto.stock <= 10;

                                    return InkWell(
                                      onTap: () => _mostrarModalCantidad(context, producto),
                                      borderRadius: BorderRadius.circular(12),
                                      mouseCursor: SystemMouseCursors.click,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.02),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 100,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFF1F5F9),
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                              ),
                                              child: Stack(
                                                children: [
                                                  const Center(
                                                    child: Icon(
                                                      Icons.inventory_2,
                                                      size: 40,
                                                      color: Color(0xFF3B82F6),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 6,
                                                    right: 6,
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withValues(alpha: 0.9),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        producto.esPesado ? 'Balanza' : 'Unidad',
                                                        style: const TextStyle(
                                                          fontSize: 9,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF334155),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    producto.nombre,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 13,
                                                      color: Color(0xFF0F172A),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Cód: ${producto.codigoBarras}',
                                                    style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Color(0xFF94A3B8),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '\$${producto.precioUnidad.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFF059669),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: stockBajo
                                                              ? const Color(0xFFFEE2E2)
                                                              : const Color(0xFFF1F5F9),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          'Stock: ${producto.stock}',
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            fontWeight: FontWeight.w600,
                                                            color: stockBajo
                                                                ? const Color(0xFFEF4444)
                                                                : const Color(0xFF475569),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),

                // SECCIÓN DERECHA: SIDEBAR DE ORDEN ACTIVA / CARRITO (30% Ancho)
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(left: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: const Color(0xFFF1F5F9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Orden Activa',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${_carrito.length} ítems',
                                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // LISTA DE PRODUCTOS EN EL CARRITO
                        Expanded(
                          child: _carrito.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.shopping_cart_outlined, size: 48, color: Color(0xFFCBD5E1)),
                                      SizedBox(height: 8),
                                      Text(
                                        'El carrito está vacío',
                                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(12),
                                  itemCount: _carrito.length,
                                  separatorBuilder: (_, __) => const Divider(height: 12),
                                  itemBuilder: (context, index) {
                                    final item = _carrito[index];
                                    final bool esPesado = item['esPesado'] ?? false;
                                    final String unidad = esPesado ? 'kg' : 'unid';

                                    return Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['nombre'],
                                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${item['cantidad']} $unidad x \$${(item['precio'] as double).toStringAsFixed(2)}',
                                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${(item['subtotal'] as double).toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.close, size: 16, color: Color(0xFFEF4444)),
                                          onPressed: () => _eliminarDelCarrito(index),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                        ),

                        // FOOTER DEL CARRITO
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B))),
                                  Text(
                                    '\$${_totalCarrito.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF059669)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF10B981),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: _carrito.isEmpty ? null : () => _mostrarModalCobro(context),
                                  icon: const Icon(Icons.point_of_sale, size: 20),
                                  label: const Text('COBRAR ORDEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}