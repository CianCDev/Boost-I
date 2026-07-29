import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/models/product_item.dart';
import '../controllers/cart_controller.dart';
import '../providers/bcv_provider.dart';
import '../services/ticket_service.dart';
import '../widgets/cobrar_dialog.dart';

class InventoryCatalogScreen extends ConsumerStatefulWidget {
  final UsuarioEntity? usuarioLogueado;
  const InventoryCatalogScreen({super.key, this.usuarioLogueado});

  @override
  ConsumerState<InventoryCatalogScreen> createState() => _InventoryCatalogScreenState();
}

class _InventoryCatalogScreenState extends ConsumerState<InventoryCatalogScreen> {
  final IsarService _isarService = IsarService();

  String _categoriaSeleccionada = 'Todas';
  List<String> _categorias = ['Todas', 'Stock Bajo'];

  List<ProductoEntity> _productosCatalog = [];
  List<ProductoEntity> _productosFiltrados = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_manejarTecladoFisico);
    _inicializarPantalla();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bcvProvider).actualizarTasa();
    });
  }

  Future<void> _inicializarPantalla() async {
    await _cargarProductosDesdeIsar();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_manejarTecladoFisico);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool _manejarTecladoFisico(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f2) {
        _enfocarBuscador();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.f12) {
        _mostrarModalCobro(context);
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        ref.read(cartProvider.notifier).limpiarCarrito();
        _enfocarBuscador();
        return true;
      }
    }
    return false;
  }

  void _enfocarBuscador() {
    _searchFocusNode.requestFocus();
    _searchController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _searchController.text.length,
    );
  }

  Future<void> _cargarProductosDesdeIsar() async {
    try {
      if (mounted) setState(() => _isLoading = true);

      final productos = await _isarService.obtenerProductos();

      final setCategorias = productos
          .map((p) => p.categoria.trim())
          .where((c) => c.isNotEmpty)
          .toSet();

      final listaCategoriasOrdenadas = setCategorias.toList()..sort();

      if (mounted) {
        setState(() {
          _productosCatalog = productos;
          _categorias = ['Todas', ...listaCategoriasOrdenadas, 'Stock Bajo'];
          
          if (!_categorias.contains(_categoriaSeleccionada)) {
            _categoriaSeleccionada = 'Todas';
          }
          
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

  void _filtrarProductos() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _productosFiltrados = _productosCatalog.where((prod) {
        final coincideNombre = prod.nombre.toLowerCase().contains(query);
        final coincideCodigo = prod.codigoBarras.toLowerCase().contains(query);
        
        bool coincideCategoria = true;
        if (_categoriaSeleccionada == 'Stock Bajo') {
          coincideCategoria = prod.stock <= prod.stockMinimo;
        } else if (_categoriaSeleccionada != 'Todas') {
          // Normalizado a minúsculas para asegurar coincidencia con "Bebidas" / "bebidas"[cite: 11]
          coincideCategoria = prod.categoria.trim().toLowerCase() == _categoriaSeleccionada.toLowerCase();
        }

        return (coincideNombre || coincideCodigo) && coincideCategoria;
      }).toList();
    });
  }

  void _agregarAlCarrito(ProductoEntity producto, double cantidad) {
    if (producto.stock < cantidad && !producto.esPesado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock insuficiente para agregar esta cantidad'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final productItem = ProductItem(
      id: producto.id.toString(),
      codigoBarras: producto.codigoBarras,
      nombre: producto.nombre,
      precioUnidad: producto.precioUnidad,
      esPesado: producto.esPesado,
      categoria: producto.categoria,
    );

    ref.read(cartProvider.notifier).agregarProducto(
      productItem,
      cantidad: cantidad,
      stockMaximo: producto.stock,
    );

    _searchController.clear();
    _filtrarProductos();
  }

  void _mostrarModalCantidad(BuildContext context, ProductoEntity producto) {
    final TextEditingController cantidadController = TextEditingController(
      text: producto.esPesado ? '1.000' : '1',
    );

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Cantidad para ${producto.nombre}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                producto.esPesado 
                    ? 'Producto de Balanza (ingrese peso en kg):' 
                    : 'Ingrese la cantidad deseada (unidades):',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cantidadController,
                autofocus: true,
                keyboardType: TextInputType.numberWithOptions(decimal: producto.esPesado),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    producto.esPesado
                        ? RegExp(r'^\d*\.?\d{0,3}')
                        : RegExp(r'^\d*'),
                  ),
                ],
                onTap: () {
                  cantidadController.selection = TextSelection(
                    baseOffset: 0,
                    extentOffset: cantidadController.text.length,
                  );
                },
                decoration: InputDecoration(
                  labelText: 'Cantidad',
                  suffixText: producto.esPesado ? 'kg' : 'unid',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                  ),
                ),
                onSubmitted: (val) {
                  final double? cantidad = double.tryParse(val);
                  if (cantidad != null && cantidad > 0) {
                    Navigator.of(dialogContext).pop();
                    _agregarAlCarrito(producto, cantidad);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                cantidadController.dispose();
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancelar', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final double? cantidad = double.tryParse(cantidadController.text);
                if (cantidad == null || cantidad <= 0) return;

                Navigator.of(dialogContext).pop();
                _agregarAlCarrito(producto, cantidad);
                cantidadController.dispose();
              },
              child: const Text('Agregar al Carrito', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _mostrarModalCobro(BuildContext context) async {
    final cartState = ref.read(cartProvider);
    if (cartState.total <= 0) return;

    double tasaActual = ref.read(bcvProvider).tasa;
    if (tasaActual.isNaN || tasaActual <= 0) tasaActual = 0.0;

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CobrarDialog(
        totalAPagar: cartState.total, productos: const [],
      ),
    );

    if (resultado != null && resultado['procesado'] == true && mounted) {
      final String metodoPago = resultado['metodoPago'] ?? 'Efectivo';
      final double montoRecibido = resultado['montoRecibido'] ?? cartState.total;
      final double cambio = resultado['vuelto'] ?? 0.0;

      await _procesarYGuardarVentaIsar(metodoPago, cambio, montoRecibido, tasaActual);
    }
  }

  Future<void> _procesarYGuardarVentaIsar(String metodoPago, double cambio, double recibido, double tasaActual) async {
    try {
      final cartState = ref.read(cartProvider);
      final String ventaIdStr = 'V-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final DateTime ahora = DateTime.now();
      final double totalBsCalculado = cartState.total * tasaActual;

      final itemsIsar = cartState.items.map((cartItem) {
        return VentaItemEntity()
          ..nombreProducto = cartItem.producto.nombre
          ..precioUnidad = cartItem.producto.precioUnidad
          ..cantidad = cartItem.cantidad.toDouble()
          ..subtotal = cartItem.producto.precioUnidad * cartItem.cantidad.toDouble();
      }).toList();

      final nuevaVenta = VentaEntity()
        ..ventaIdString = ventaIdStr
        ..fecha = ahora
        ..total = cartState.total
        ..subtotal = cartState.subtotal
        ..impuesto = cartState.impuesto
        ..tasaBcv = tasaActual
        ..totalBolivares = totalBsCalculado
        ..metodoPago = metodoPago
        ..cedulaCliente = 'V-00000000'
        ..empleado = widget.usuarioLogueado?.nombre ?? 'Administrador / Catálogo'
        ..items = itemsIsar
        ..sincronizado = false;

      await _isarService.guardarVenta(nuevaVenta);
      ref.read(cartProvider.notifier).limpiarCarrito();
      await _cargarProductosDesdeIsar();

      try {
        final ticketItems = cartState.items.map((item) {
          return TicketItem(
            nombre: item.producto.nombre,
            precio: item.producto.precioUnidad,
            cantidad: item.cantidad.toDouble(),
            esPesado: item.producto.esPesado,
          );
        }).toList();

        await TicketService.generarYProcesarPdf(
          items: ticketItems,
          subtotal: cartState.subtotal,
          impuesto: cartState.impuesto,
          total: cartState.total,
          metodoPago: metodoPago,
          montoRecibido: recibido,
          vuelto: cambio,
        );
      } catch (e) {
        debugPrint('Error al procesar ticket PDF: $e');
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Venta registrada con éxito con tasa BCV e importe en Bs.! 🎉'),
          backgroundColor: Color(0xFF10B981),
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
    final cartState = ref.watch(cartProvider);
    final bcvController = ref.watch(bcvProvider);
    final double tasaBcv = bcvController.tasa;
    final bool cargandoBcv = bcvController.cargando;
    final double totalBs = cartState.total * tasaBcv;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Catálogo de Inventario y POS (Isar)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Tooltip(
            message: 'Tasa oficial BCV (Haz clic para actualizar)',
            child: InkWell(
              onTap: () => ref.read(bcvProvider).actualizarTasa(),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.currency_exchange, size: 16, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    cargandoBcv
                        ? const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                          )
                        : Text(
                            'BCV: Bs. ${tasaBcv.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar Catálogo',
            onPressed: _cargarProductosDesdeIsar,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : Row(
              children: [
                Expanded(
                  flex: 7,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 42,
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            autofocus: true,
                            onChanged: (_) => _filtrarProductos(),
                            decoration: InputDecoration(
                              hintText: 'Buscar o escanear por nombre / código (F2)...',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _filtrarProductos();
                                },
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                              filled: true,
                              fillColor: Colors.white,
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                              ),
                            ),
                            onSubmitted: (val) {
                              if (_productosFiltrados.length == 1) {
                                _mostrarModalCantidad(context, _productosFiltrados.first);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 38,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categorias.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = _categorias[index];
                              return _CategoryButton(
                                categoria: cat,
                                esSeleccionada: _categoriaSeleccionada == cat,
                                onTap: () {
                                  setState(() {
                                    _categoriaSeleccionada = cat;
                                  });
                                  _filtrarProductos();
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
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
                                    final bool stockBajo = producto.stock <= producto.stockMinimo;

                                    return InkWell(
                                      onTap: () => _mostrarModalCantidad(context, producto),
                                      borderRadius: BorderRadius.circular(12),
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
                                  '${cartState.items.length} ítems',
                                  style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: cartState.items.isEmpty
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
                                  itemCount: cartState.items.length,
                                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final cartItem = cartState.items[index];
                                    final bool esPesado = cartItem.producto.esPesado;
                                    final String unidad = esPesado ? 'kg' : 'unid';
                                    final double cantidad = cartItem.cantidad.toDouble();
                                    final double subtotalItem = cartItem.producto.precioUnidad * cantidad;

                                    return Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cartItem.producto.nombre,
                                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A)),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${cantidad.toStringAsFixed(esPesado ? 3 : 0)} $unidad x \$${cartItem.producto.precioUnidad.toStringAsFixed(2)}',
                                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            '\$${subtotalItem.toStringAsFixed(2)}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF059669)),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            icon: const Icon(Icons.close, size: 18, color: Color(0xFFEF4444)),
                                            onPressed: () {
                                              ref.read(cartProvider.notifier).eliminarItem(index);
                                            },
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
                                            tooltip: 'Eliminar ítem',
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
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
                                  const Text('TOTAL USD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B))),
                                  Text(
                                    '\$${cartState.total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Color(0xFF059669)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('TOTAL BOLÍVARES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF94A3B8))),
                                  Text(
                                    'Bs. ${totalBs.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3B82F6)),
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
                                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                                    disabledForegroundColor: const Color(0xFF94A3B8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  onPressed: cartState.items.isEmpty ? null : () => _mostrarModalCobro(context),
                                  icon: const Icon(Icons.point_of_sale, size: 20),
                                  label: const Text('COBRAR ORDEN (F12)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

class _CategoryButton extends StatefulWidget {
  final String categoria;
  final bool esSeleccionada;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.categoria,
    required this.esSeleccionada,
    required this.onTap,
  });

  @override
  State<_CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<_CategoryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool esStockBajo = widget.categoria == 'Stock Bajo';
    
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (widget.esSeleccionada) {
      backgroundColor = esStockBajo ? Colors.red : const Color(0xFF10B981);
      borderColor = backgroundColor;
      textColor = Colors.white;
    } else {
      backgroundColor = _isHovered ? const Color(0xFFF1F5F9) : Colors.white;
      borderColor = _isHovered ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1);
      textColor = const Color(0xFF475569);
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esStockBajo) ...[
                Icon(
                  Icons.warning_amber_rounded, 
                  size: 14, 
                  color: widget.esSeleccionada ? Colors.white : Colors.amberAccent,
                ),
                const SizedBox(width: 4),
              ] else if (widget.esSeleccionada) ...[
                const Icon(Icons.check, size: 14, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                widget.categoria,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: widget.esSeleccionada ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}