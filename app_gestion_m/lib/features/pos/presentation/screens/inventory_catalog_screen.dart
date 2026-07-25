import 'package:flutter/material.dart';
import '../services/ticket_service.dart';
import '../widgets/cobrar_dialog.dart'; // Importación del modal reusable

class InventoryCatalogScreen extends StatefulWidget {
  const InventoryCatalogScreen({super.key});

  @override
  State<InventoryCatalogScreen> createState() => _InventoryCatalogScreenState();
}

class _InventoryCatalogScreenState extends State<InventoryCatalogScreen> {
  // Categoría seleccionada
  String _categoriaSeleccionada = 'Todas';

  // Lista de categorías
  final List<String> _categorias = ['Todas', 'Frutas', 'Abarrotes', 'Lácteos', 'Bebidas'];

  // Carrito de compras / Orden activa
  final List<Map<String, dynamic>> _carrito = [];

  // Getter para calcular el total del carrito
  double get _totalCarrito {
    return _carrito.fold(0.0, (suma, item) => suma + (item['subtotal'] as double));
  }

  // Catálogo completo alineado con la UI
  final List<Map<String, dynamic>> _productosCatalog = [
    {
      'nombre': 'Manzana Roja Importada',
      'codigo': '75010001',
      'precio': 3.50,
      'stock': 45.5,
      'esPesado': true,
      'categoria': 'Frutas',
      'color': const Color(0xFFFFE4E6),
      'iconoColor': const Color(0xFFEF4444),
      'icono': Icons.apple,
    },
    {
      'nombre': 'Arroz Premium 1kg',
      'codigo': '75010002',
      'precio': 1.20,
      'stock': 120.0,
      'esPesado': false,
      'categoria': 'Abarrotes',
      'color': const Color(0xFFFEF3C7),
      'iconoColor': const Color(0xFFD97706),
      'icono': Icons.bakery_dining,
    },
    {
      'nombre': 'Queso Blanco Duro',
      'codigo': '75010003',
      'precio': 6.80,
      'stock': 18.2,
      'esPesado': true,
      'categoria': 'Lácteos',
      'color': const Color(0xFFE0F2FE),
      'iconoColor': const Color(0xFF059669),
      'icono': Icons.breakfast_dining,
    },
    {
      'nombre': 'Jugo de Naranja 1L',
      'codigo': '75010004',
      'precio': 2.10,
      'stock': 8.0,
      'esPesado': false,
      'categoria': 'Bebidas',
      'color': const Color(0xFFE0E7FF),
      'iconoColor': const Color(0xFF3B82F6),
      'icono': Icons.local_drink,
    },
  ];

  late List<Map<String, dynamic>> _productosFiltrados;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productosFiltrados = _productosCatalog;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Aplica búsqueda por texto y filtro de categoría
  void _filtrarProductos() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _productosFiltrados = _productosCatalog.where((item) {
        final coincideNombre = item['nombre'].toString().toLowerCase().contains(query);
        final coincideCodigo = item['codigo'].toString().toLowerCase().contains(query);
        final coincideCategoria = _categoriaSeleccionada == 'Todas' || item['categoria'] == _categoriaSeleccionada;

        return (coincideNombre || coincideCodigo) && coincideCategoria;
      }).toList();
    });
  }

  /// Agrega un ítem al carrito o actualiza su cantidad si ya existe
  void _agregarAlCarrito(Map<String, dynamic> producto, double cantidad) {
    setState(() {
      final index = _carrito.indexWhere((item) => item['codigo'] == producto['codigo']);

      if (index != -1) {
        final nuevaCantidad = _carrito[index]['cantidad'] + cantidad;
        _carrito[index]['cantidad'] = nuevaCantidad;
        _carrito[index]['subtotal'] = nuevaCantidad * (producto['precio'] as double);
      } else {
        _carrito.add({
          'codigo': producto['codigo'],
          'nombre': producto['nombre'],
          'precio': producto['precio'],
          'cantidad': cantidad,
          'esPesado': producto['esPesado'],
          'subtotal': cantidad * (producto['precio'] as double),
        });
      }
    });
  }

  /// Remueve un producto del carrito
  void _eliminarDelCarrito(int index) {
    setState(() {
      _carrito.removeAt(index);
    });
  }

  /// Despliega el modal interactivo de cantidad
  void _mostrarModalCantidad(BuildContext context, Map<String, dynamic> item) {
    final TextEditingController cantidadController = TextEditingController(text: '1');
    final bool esPesado = item['esPesado'] ?? false;

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Cantidad para ${item['nombre']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                esPesado 
                    ? 'Producto de Balanza (ingrese peso en kg):' 
                    : 'Ingrese la cantidad deseada:',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cantidadController,
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(decimal: esPesado),
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  suffixText: esPesado ? 'Kg' : 'Unid',
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
                _agregarAlCarrito(item, cantidad);
                cantidadController.dispose();
              },
              child: const Text('Agregar al Carrito'),
            ),
          ],
        );
      },
    );
  }

  /// Despliega el modal reusable de Cobro (CobrarDialog)
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

      _finalizarVenta(metodoPago, cambio, montoRecibido);
    }
  }

  /// Finaliza la venta e invoca el servicio de impresión térmica
  void _finalizarVenta(String metodoPago, double cambio, double recibido) async {
    // Generar ticket térmico en background usando el TicketService importado
    try {
      await TicketService.imprimirTicketVenta(
        items: List.from(_carrito),
        total: _totalCarrito,
        metodoPago: metodoPago,
        montoRecibido: recibido,
        cambio: cambio,
      );
    } catch (e) {
      debugPrint('Error al imprimir ticket: $e');
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
            const Text('¡Venta Completada!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Método: $metodoPago', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            if (metodoPago == 'Efectivo')
              Text('Cambio entregado: \$${cambio.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            const Text('Ticket enviado a la impresora térmica...', style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _carrito.clear();
              });
            },
            child: const Text('Aceptar / Nueva Venta'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Catálogo de Inventario',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Row(
        children: [
          // SECCIÓN IZQUIERDA: CATÁLOGO DE PRODUCTOS (70% Ancho)
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Bar de Búsqueda + Filtros
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => _filtrarProductos(),
                            decoration: InputDecoration(
                              hintText: 'Buscar por producto o código...',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF0F172A), width: 2),
                              ),
                            ),
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
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 220,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: _productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final item = _productosFiltrados[index];
                        final bool stockBajo = (item['stock'] as num) <= 10;

                        return InkWell(
                          onTap: () => _mostrarModalCantidad(context, item),
                          borderRadius: BorderRadius.circular(12),
                          mouseCursor: SystemMouseCursors.click,
                          child: Ink(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
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
                                  decoration: BoxDecoration(
                                    color: item['color'] as Color,
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Icon(
                                          item['icono'] as IconData,
                                          size: 40,
                                          color: item['iconoColor'] as Color,
                                        ),
                                      ),
                                      Positioned(
                                        top: 6,
                                        right: 6,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.9),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item['esPesado'] ? 'Balanza' : 'Unidad',
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
                                        item['nombre'],
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
                                        'Cód: ${item['codigo']}',
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
                                            '\$${(item['precio'] as double).toStringAsFixed(2)}',
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
                                              'Stock: ${item['stock']}',
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

                  // FOOTER DEL CARRITO: TOTAL Y BOTÓN DE COBRO
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