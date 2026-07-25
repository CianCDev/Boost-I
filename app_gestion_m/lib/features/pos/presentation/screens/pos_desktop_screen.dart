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
import 'sales_history_screen.dart'; // <-- IMPORTA LA NUEVA PANTALLA

// MODELOS PARA AUDITORÍA Y REGISTRO DE VENTAS
class VentaItemModel {
  final String nombreProducto;
  final double precioUnidad;
  final double cantidad;
  final double subtotal;

  VentaItemModel({
    required this.nombreProducto,
    required this.precioUnidad,
    required this.cantidad,
    required this.subtotal,
  });
}

class VentaModel {
  final String id;
  final DateTime fecha;
  final double total;
  final String metodoPago;
  final String cedulaCliente;
  final String empleado;
  final List<VentaItemModel> items;

  VentaModel({
    required this.id,
    required this.fecha,
    required this.total,
    required this.metodoPago,
    required this.cedulaCliente,
    required this.empleado,
    required this.items,
  });
}

class PosDesktopScreen extends ConsumerStatefulWidget {
  const PosDesktopScreen({super.key});

  @override
  ConsumerState<PosDesktopScreen> createState() => _PosDesktopScreenState();
}

class _PosDesktopScreenState extends ConsumerState<PosDesktopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Historial acumulado en memoria durante la sesión
  final List<VentaModel> _historialVentas = [];

  // Usuario activo en el POS (puedes enlazarlo a tu sistema de login luego)
  final String _cajeroActual = "Yan Camacaro";

  final List<ProductItem> _productosDemo = const [
    ProductItem(
      id: '1',
      codigoBarras: '75010001',
      nombre: 'Manzana Roja Importada',
      precioUnidad: 3.50,
      esPesado: true,
      categoria: 'Frutas',
    ),
    ProductItem(
      id: '2',
      codigoBarras: '75010002',
      nombre: 'Arroz Premium 1kg',
      precioUnidad: 1.20,
      esPesado: false,
      categoria: 'Abarrotes',
    ),
    ProductItem(
      id: '3',
      codigoBarras: '75010003',
      nombre: 'Queso Blanco Duro',
      precioUnidad: 6.80,
      esPesado: true,
      categoria: 'Lácteos',
    ),
  ];

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_manejarTecladoFisico);
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

  void _buscarYAgregarProducto(String query) {
    if (query.trim().isEmpty) return;

    final productoEncontrado = _productosDemo.firstWhere(
      (p) =>
          p.codigoBarras == query.trim() ||
          p.nombre.toLowerCase().contains(query.toLowerCase()),
      orElse: () => _productosDemo.first,
    );

    final cantidad = productoEncontrado.esPesado ? 1.250 : 1.0;

    ref
        .read(cartProvider.notifier)
        .agregarProducto(productoEncontrado, cantidad: cantidad);
    _searchController.clear();
    _enfocarBuscador();
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
        // Mapear los productos del carrito a ítems de auditoría
        final itemsComprados = cartState.items.map((cartItem) {
          return VentaItemModel(
            nombreProducto: cartItem.producto.nombre,
            precioUnidad: cartItem.producto.precioUnidad,
            cantidad: cartItem.cantidad.toDouble(),
            subtotal: cartItem.producto.precioUnidad * cartItem.cantidad.toDouble(),
          );
        }).toList();

        // Registrar en el historial ampliado
        setState(() {
          _historialVentas.add(
            VentaModel(
              id: 'V-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
              fecha: DateTime.now(),
              total: cartState.total,
              metodoPago: resultado['metodoPago'] ?? 'Efectivo',
              cedulaCliente: resultado['cedulaCliente'] ?? 'V-00000000', // Cédula por defecto si es consumidor final
              empleado: _cajeroActual,
              items: itemsComprados,
            ),
          );
        });

        // Adaptar items para el servicio de ticket
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
              content: Text('¡Venta realizada con éxito y ticket emitido! 🎉'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al emitir el ticket: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // ===========================================================================
  // MODAL DE CIERRE DE CAJA (Resumen Financiero y Acceso al Historial Completo)
  // ===========================================================================
  void _mostrarDialogoCaja(BuildContext context) {
    final double totalEfectivo = _historialVentas
        .where((v) => v.metodoPago.toLowerCase() == 'efectivo')
        .fold(0.0, (sum, v) => sum + v.total);

    final double totalTarjeta = _historialVentas
        .where((v) => v.metodoPago.toLowerCase() == 'tarjeta')
        .fold(0.0, (sum, v) => sum + v.total);

    final double totalOtros = _historialVentas
        .where((v) =>
            v.metodoPago.toLowerCase() != 'efectivo' &&
            v.metodoPago.toLowerCase() != 'tarjeta')
        .fold(0.0, (sum, v) => sum + v.total);

    final double granTotal =
        _historialVentas.fold(0.0, (sum, v) => sum + v.total);

    showDialog(
      context: context,
      builder: (context) {
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
                  '${_historialVentas.length} ventas',
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
            child: Column(
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
            // BOTÓN SOLICITADO: Ver historial completo de Día/Semana/Mes
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.analytics_outlined, size: 18),
              label: const Text('Ver Registro y Auditoría', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el modal antes de abrir la pantalla nueva
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SalesHistoryScreen(historialVentas: _historialVentas),
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
          // BOTÓN PARA VER EL CIERRE DE CAJA
          IconButton(
            icon: const Icon(Icons.point_of_sale),
            tooltip: 'Ver Resumen de Caja',
            onPressed: () => _mostrarDialogoCaja(context),
          ),
          // BOTÓN PARA ABRIR EL CATÁLOGO
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
          // REINICIAR VENTA
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
            // PANEL IZQUIERDO: Buscador, Visor Balanza y Tabla de Carrito
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      labelText: 'Escanear código de barras o buscar (F2)...',
                      prefixIcon: const Icon(Icons.qr_code_scanner),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        onPressed: () => _buscarYAgregarProducto(_searchController.text),
                      ),
                    ),
                    onSubmitted: _buscarYAgregarProducto,
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

            // PANEL DERECHO: Resumen de totales y Botón Cobrar
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