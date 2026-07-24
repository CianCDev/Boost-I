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

class PosDesktopScreen extends ConsumerStatefulWidget {
  const PosDesktopScreen({super.key});

  @override
  ConsumerState<PosDesktopScreen> createState() => _PosDesktopScreenState();
}

class _PosDesktopScreenState extends ConsumerState<PosDesktopScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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
      (p) => p.codigoBarras == query.trim() || p.nombre.toLowerCase().contains(query.toLowerCase()),
      orElse: () => _productosDemo.first,
    );

    final cantidad = productoEncontrado.esPesado ? 1.250 : 1.0;

    ref.read(cartProvider.notifier).agregarProducto(productoEncontrado, cantidad: cantidad);
    _searchController.clear();
    _enfocarBuscador();
  }

  Future<void> _abrirCobro() async {
    final cartState = ref.read(cartProvider);
    if (cartState.total <= 0) return;

    // 1. Abrimos CobrarDialog y esperamos el Map de resultado
    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CobrarDialog(
        totalAPagar: cartState.total,
      ),
    );

    // 2. Si el cobro fue confirmado, procesamos la impresión en el contexto activo de la pantalla
    if (resultado != null && resultado['procesado'] == true && mounted) {
      try {
        // Mapeo adaptado a los parámetros esperados por TicketItem:
        // 'precio' en lugar de 'precioUnidad', y 'cantidad' convertida a int
        final ticketItems = cartState.items.map((cartItem) {
          return TicketItem(
            nombre: cartItem.producto.nombre,
            precio: cartItem.producto.precioUnidad,
            cantidad: cartItem.cantidad.toInt(),
          );
        }).toList();

        await TicketService.generarYProcesarPdf(
          items: ticketItems,
          subtotal: cartState.subtotal,
          impuesto: cartState.impuesto,
          total: cartState.total,
          metodoPago: resultado['metodoPago'],
          montoRecibido: resultado['montoRecibido'],
          vuelto: resultado['vuelto'],
        );

        // 3. Limpiamos carrito y restablecemos foco
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

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('app_gestion_m — POS Caja 01'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(cartProvider.notifier).limpiarCarrito();
              _enfocarBuscador();
            },
            tooltip: 'Reiniciar Venta (Esc)',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PANEL IZQUIERDO
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

            // PANEL DERECHO
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