import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/product_item.dart';
import '../controllers/cart_controller.dart';
import '../services/ticket_service.dart';
import '../widgets/cart_table_widget.dart';
import '../widgets/cobrar_dialog.dart';
import '../widgets/pos_summary_panel.dart';
import '../widgets/scale_visor_widget.dart';
import 'inventory_catalog_screen.dart';
import 'sales_history_screen.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/producto_entity.dart';

class PosDesktopScreen extends ConsumerStatefulWidget {
  const PosDesktopScreen({super.key});

  @override
  ConsumerState<PosDesktopScreen> createState() => _PosDesktopScreenState();
}

class _PosDesktopScreenState extends ConsumerState<PosDesktopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Instancia de nuestro servicio local Isar
  final IsarService _isarService = IsarService();

  // Usuario activo en el POS
  final String _cajeroActual = "Yan Camacaro";

  // Cache local de productos para el autocompletado rápido
  List<ProductoEntity> _productosLocales = [];

  // Cantidad de ventas pendientes de sincronizar
  int _ventasPendientesSync = 0;

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_manejarTecladoFisico);
    _cargarProductosAutocompletado();
    _actualizarContadorSync();
  }

  Future<void> _cargarProductosAutocompletado() async {
    final prods = await _isarService.obtenerProductos();
    if (mounted) {
      setState(() {
        _productosLocales = prods;
      });
    }
  }

  /// Verifica cuántas ventas locales no se han subido aún
  Future<void> _actualizarContadorSync() async {
    final pendientes = await _isarService.obtenerVentasPendientesSync();
    if (mounted) {
      setState(() {
        _ventasPendientesSync = pendientes.length;
      });
    }
  }

  /// Procesa la adición de un ProductoEntity al carrito usando el estado de Riverpod
  void _agregarProductoEntityAlCarrito(ProductoEntity producto) {
    final productItem = ProductItem(
      id: producto.id.toString(),
      codigoBarras: producto.codigoBarras,
      nombre: producto.nombre,
      precioUnidad: producto.precioUnidad,
      esPesado: producto.esPesado,
      categoria: producto.categoria,
    );

    final cantidad = productItem.esPesado ? 1.250 : 1.0;
    ref.read(cartProvider.notifier).agregarProducto(productItem, cantidad: cantidad);

    _searchController.clear();
    _enfocarBuscador();
  }

  // Buscar producto en Isar por código de barras o coincidencia de nombre
  Future<void> _buscarYAgregarProducto(String query) async {
    if (query.trim().isEmpty) return;

    final queryTrim = query.trim().toLowerCase();
    final productosDb = await _isarService.obtenerProductos();

    ProductoEntity? productoEncontrado;
    try {
      productoEncontrado = productosDb.firstWhere(
        (p) => p.codigoBarras.toLowerCase() == queryTrim || p.nombre.toLowerCase().contains(queryTrim),
      );
    } catch (_) {
      productoEncontrado = null;
    }

    if (productoEncontrado != null) {
      _agregarProductoEntityAlCarrito(productoEncontrado);
    } else {
      _searchController.clear();
      _enfocarBuscador();
    }
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
        _abrirCobro();
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

  Future<void> _abrirCobro() async {
    final cartState = ref.read(cartProvider);
    if (cartState.total <= 0) return;

    // 1. Abrimos CobrarDialog y esperamos el resultado
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CobrarDialog(
        totalAPagar: cartState.total,
      ),
    );

    // 2. Procesar venta si fue confirmada
    if (resultado != null && resultado['procesado'] == true && mounted) {
      try {
        final String ventaIdStr = 'V-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
        final DateTime ahora = DateTime.now();

        // Mapear los productos para Isar (VentaItemEntity)
        final itemsIsar = cartState.items.map((cartItem) {
          return VentaItemEntity()
            ..nombreProducto = cartItem.producto.nombre
            ..precioUnidad = cartItem.producto.precioUnidad
            ..cantidad = cartItem.cantidad.toDouble()
            ..subtotal = cartItem.producto.precioUnidad * cartItem.cantidad.toDouble();
        }).toList();

        // Crear la entidad de Isar
        final nuevaVentaEntity = VentaEntity()
          ..ventaIdString = ventaIdStr
          ..fecha = ahora
          ..total = cartState.total
          ..subtotal = cartState.subtotal
          ..impuesto = cartState.impuesto
          ..metodoPago = resultado['metodoPago'] ?? 'Efectivo'
          ..cedulaCliente = resultado['cedulaCliente'] ?? 'V-00000000'
          ..empleado = _cajeroActual
          ..items = itemsIsar
          ..sincronizado = false;

        // Guardar en Isar
        await _isarService.guardarVenta(nuevaVentaEntity);
        
        // Actualizar el contador de pendientes para la UI
        await _actualizarContadorSync();

        // Adaptar items para el servicio de impresión de ticket PDF
        final ticketItems = cartState.items.map((cartItem) {
          return TicketItem(
            nombre: cartItem.producto.nombre,
            precio: cartItem.producto.precioUnidad,
            cantidad: cartItem.cantidad.toDouble(),
            esPesado: cartItem.producto.esPesado,
          );
        }).toList();

        // Emitir e imprimir PDF
        await TicketService.generarYProcesarPdf(
          items: ticketItems,
          subtotal: cartState.subtotal,
          impuesto: cartState.impuesto,
          total: cartState.total,
          metodoPago: resultado['metodoPago'],
          montoRecibido: resultado['montoRecibido'],
          vuelto: resultado['vuelto'],
        );

        // Limpiar carrito
        ref.read(cartProvider.notifier).limpiarCarrito();
        _enfocarBuscador();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Venta realizada con éxito y guardada localmente! 🎉'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al procesar la venta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ===========================================================================
  // MODAL DE CIERRE DE CAJA
  // ===========================================================================
  void _mostrarDialogoCaja(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<VentaEntity>>(
          future: _isarService.obtenerVentasPorPeriodo('dia'),
          builder: (context, snapshot) {
            final ventasDelDia = snapshot.data ?? [];

            final double totalEfectivo = ventasDelDia
                .where((v) => v.metodoPago.toLowerCase() == 'efectivo')
                .fold(0.0, (sum, v) => sum + v.total);

            final double totalTarjeta = ventasDelDia
                .where((v) => v.metodoPago.toLowerCase() == 'tarjeta')
                .fold(0.0, (sum, v) => sum + v.total);

            final double totalOtros = ventasDelDia
                .where((v) =>
                    v.metodoPago.toLowerCase() != 'efectivo' &&
                    v.metodoPago.toLowerCase() != 'tarjeta')
                .fold(0.0, (sum, v) => sum + v.total);

            final double granTotal =
                ventasDelDia.fold(0.0, (sum, v) => sum + v.total);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.point_of_sale, color: Color(0xFF0F172A)),
                      SizedBox(width: 8),
                      Text(
                        'Caja del Día',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(
                      '${ventasDelDia.length} ventas',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: const Color(0xFFECFDF5),
                    side: BorderSide.none,
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: snapshot.connectionState == ConnectionState.waiting
                    ? const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator(color: Color(0xFF10B981))),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _filaDetalleCaja('Efectivo', totalEfectivo, Icons.payments_outlined, const Color(0xFF10B981)),
                          const SizedBox(height: 10),
                          _filaDetalleCaja('Tarjeta', totalTarjeta, Icons.credit_card, const Color(0xFF3B82F6)),
                          const SizedBox(height: 10),
                          _filaDetalleCaja('Otros / Transf.', totalOtros, Icons.qr_code, const Color(0xFF8B5CF6)),
                          const Divider(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TOTAL EN CAJA',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                                Text(
                                  '\$${granTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF34D399),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              actions: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.analytics_outlined, size: 18),
                  label: const Text('Ver Registro y Auditoría', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SalesHistoryScreen(),
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _filaDetalleCaja(String titulo, double monto, IconData icono, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icono, size: 18, color: color),
            const SizedBox(width: 8),
            Text(titulo, style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
          ],
        ),
        Text(
          '\$${monto.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('app_gestion_m — POS Caja 01'),
        actions: [
          // ☁️ Indicador visual de Sincronización
          Tooltip(
            message: _ventasPendientesSync == 0
                ? 'Sincronizado con el servidor'
                : '$_ventasPendientesSync ventas pendientes por sincronizar',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: _ventasPendientesSync == 0
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _ventasPendientesSync == 0
                      ? const Color(0xFFA7F3D0)
                      : const Color(0xFFFDE68A),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _ventasPendientesSync == 0
                        ? Icons.cloud_done_outlined
                        : Icons.cloud_upload_outlined,
                    size: 18,
                    color: _ventasPendientesSync == 0
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                  if (_ventasPendientesSync > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '$_ventasPendientesSync',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.point_of_sale),
            tooltip: 'Ver Resumen de Caja',
            onPressed: () => _mostrarDialogoCaja(context),
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Ver Catálogo de Inventario',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InventoryCatalogScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(cartProvider.notifier).limpiarCarrito();
              _enfocarBuscador();
            },
            tooltip: 'Reiniciar Venta (Esc)',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  // AUTOCOMPLETADO INTEGRADO EN LA PANTALLA POS DESKTOP
                  RawAutocomplete<ProductoEntity>(
                    textEditingController: _searchController,
                    focusNode: _searchFocusNode,
                    displayStringForOption: (option) => option.nombre,
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.trim().isEmpty) {
                        return const Iterable<ProductoEntity>.empty();
                      }
                      final query = textEditingValue.text.toLowerCase().trim();
                      return _productosLocales.where((p) =>
                          p.nombre.toLowerCase().contains(query) ||
                          p.codigoBarras.toLowerCase().contains(query));
                    },
                    onSelected: (ProductoEntity selection) {
                      _agregarProductoEntityAlCarrito(selection);
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Escanear código de barras o buscar (F2)...',
                          prefixIcon: const Icon(Icons.qr_code_scanner),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () => _buscarYAgregarProducto(controller.text),
                          ),
                        ),
                        onSubmitted: (val) {
                          onFieldSubmitted();
                          _buscarYAgregarProducto(val);
                        },
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: 500,
                          margin: const EdgeInsets.only(top: 4.0),
                          constraints: const BoxConstraints(maxHeight: 280),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            clipBehavior: Clip.antiAlias,
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              itemBuilder: (context, index) {
                                final item = options.elementAt(index);
                                return Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFF1F5F9),
                                      radius: 16,
                                      child: Icon(
                                        item.esPesado ? Icons.scale : Icons.shopping_bag,
                                        color: const Color(0xFF3B82F6),
                                        size: 16,
                                      ),
                                    ),
                                    title: Text(
                                      item.nombre,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    subtitle: Text(
                                      'Cód: ${item.codigoBarras} | Stock: ${item.stock}',
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    trailing: Text(
                                      '\$${item.precioUnidad.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Color(0xFF059669),
                                      ),
                                    ),
                                    onTap: () => onSelected(item),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const ScaleVisorWidget(
                    pesoActual: 0.000,
                    estaConectada: true,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: CartTableWidget(
                      items: cartState.items,
                      onCantidadChanged: (index, cant) {
                        ref.read(cartProvider.notifier).actualizarCantidad(index, cant);
                      },
                      onEliminarItem: (index) {
                        ref.read(cartProvider.notifier).eliminarItem(index);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: PosSummaryPanel(
                subtotal: cartState.subtotal,
                impuesto: cartState.impuesto,
                total: cartState.total,
                onPagarPressed: _abrirCobro,
                onLimpiarPressed: () {
                  ref.read(cartProvider.notifier).limpiarCarrito();
                  _enfocarBuscador();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}