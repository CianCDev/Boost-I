import 'dart:async';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/models/product_item.dart';
import '../controllers/cart_controller.dart';
import '../providers/catalog_provider.dart';
import '../providers/bcv_provider.dart';
import '../providers/esc_pos_provider.dart';
import '../services/ticket_generator.dart';
import '../services/ticket_service.dart';
import '../widgets/catalog/category_chips.dart';
import '../widgets/catalog/fixed_cart_summary.dart';
import '../widgets/catalog/product_card.dart';
import '../widgets/catalog/product_card_skeleton.dart';
import '../widgets/catalog/search_bar.dart';
import '../widgets/catalog/cart_sidebar.dart';
import '../widgets/catalog/quantity_dialog.dart';
import '../widgets/shared/barcode_scanner_dialog.dart';
import '../utils/responsive_helper.dart';
import '../services/scale_service.dart';
import 'inventory_screen.dart';
import 'pos_menu_screen.dart';
import '../widgets/cobrar_dialog.dart';

class InventoryCatalogScreen extends ConsumerStatefulWidget {
  final UsuarioEntity? usuarioLogueado;
  final bool showAppBar; // opcional con valor por defecto

  const InventoryCatalogScreen({
    super.key,
    this.usuarioLogueado,
    this.showAppBar = true, // ✅ ahora es opcional
  });

  @override
  ConsumerState<InventoryCatalogScreen> createState() => _InventoryCatalogScreenState();
}

class _InventoryCatalogScreenState extends ConsumerState<InventoryCatalogScreen>
    with SingleTickerProviderStateMixin {
  final IsarService _isarService = IsarService();
  final ScaleService _scaleService = ScaleService();
  late AnimationController _animationController;
  final FocusNode _searchFocusNode = FocusNode();

  StreamSubscription<double>? _weightSubscription;
  Timer? _pollingTimer;

  // ==========================================================================
  // CICLO DE VIDA
  // ==========================================================================
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _scaleService.connect();
    _weightSubscription = _scaleService.weightStream.listen((peso) {
      debugPrint('⚖️ Peso en tiempo real: $peso kg');
    });

    HardwareKeyboard.instance.addHandler(_manejarTecladoFisico);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bcvProvider).actualizarTasa();
    });

    _iniciarPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _scaleService.dispose();
    _weightSubscription?.cancel();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // POLLING
  // ==========================================================================
  void _iniciarPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (mounted) {
        try {
          await ref.read(catalogProvider.notifier).recargarDesdeSupabase();
        } catch (e) {
          debugPrint('⚠️ Error en polling: $e');
        }
      }
    });
  }

  // ==========================================================================
  // TECLADO FÍSICO
  // ==========================================================================
  bool _manejarTecladoFisico(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f2) {
        _searchFocusNode.requestFocus();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.f12) {
        final cartState = ref.read(cartProvider);
        if (cartState.total > 0) _mostrarModalCobro();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        ref.read(cartProvider.notifier).limpiarCarrito();
        _searchFocusNode.requestFocus();
        return true;
      }
    }
    return false;
  }

  // ==========================================================================
  // ESCÁNER
  // ==========================================================================
  Future<void> _scanBarcode() async {
    final codigo = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (codigo == null || codigo.isEmpty) return;

    final producto = await _isarService.obtenerProductoPorCodigoBarrasExacto(codigo.trim());
    if (producto != null) {
      _mostrarModalCantidad(producto);
      return;
    }

    final crear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Producto no registrado'),
        content: Text('El código "$codigo" no está registrado.\n¿Deseas crearlo ahora?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crear Producto'),
          ),
        ],
      ),
    );
    if (crear == true && mounted) {
      _mostrarDialogoCrearProducto(codigo);
    }
  }

  // ==========================================================================
  // AGREGAR AL CARRITO
  // ==========================================================================
  void _agregarAlCarrito(ProductoEntity producto, double cantidad) {
    if (producto.stock < cantidad && !producto.esPesado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock insuficiente'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    HapticFeedback.lightImpact();
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${producto.nombre} agregado al carrito.'),
        backgroundColor: const Color(0xFF10B981),
        duration: const Duration(seconds: 1),
      ),
    );
    ref.read(catalogProvider.notifier).setBusqueda('');
  }

  // ==========================================================================
  // MODAL DE CANTIDAD
  // ==========================================================================
  void _mostrarModalCantidad(ProductoEntity producto) {
    showDialog(
      context: context,
      builder: (context) => QuantityDialog(
        producto: producto,
        onAgregar: (productoModificado, cantidad) {
          _agregarAlCarrito(productoModificado, cantidad);
        },
      ),
    );
  }

  // ==========================================================================
  // CREAR PRODUCTO DESDE ESCÁNER (placeholder)
  // ==========================================================================
  void _mostrarDialogoCrearProducto(String codigo) {
    debugPrint('Crear producto con código $codigo');
    // ref.read(catalogProvider.notifier).recargarDesdeSupabase();
  }

  // ==========================================================================
  // COBRO
  // ==========================================================================
  Future<void> _mostrarModalCobro() async {
    final cartState = ref.read(cartProvider);
    if (cartState.total <= 0) return;
    HapticFeedback.mediumImpact();
    double tasaActual = ref.read(bcvProvider).tasa;
    if (tasaActual.isNaN || tasaActual <= 0) tasaActual = 0.0;

    final resultado = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CobrarDialog(
        totalAPagar: cartState.total,
        productos: const [],
      ),
    );

    if (resultado != null && resultado['procesado'] == true && mounted) {
      final String metodoPago = resultado['metodoPago'] ?? 'Efectivo';
      final double montoRecibido = resultado['montoRecibido'] ?? cartState.total;
      final double cambio = resultado['vuelto'] ?? 0.0;
      await _procesarYGuardarVenta(metodoPago, cambio, montoRecibido, tasaActual);
    }
  }

  Future<void> _procesarYGuardarVenta(
      String metodoPago, double cambio, double recibido, double tasaActual) async {
    try {
      final cartState = ref.read(cartProvider);
      final String ventaIdStr =
          'V-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final DateTime ahora = DateTime.now();
      final double totalBsCalculado = cartState.total * tasaActual;

      final itemsIsar = cartState.items.map((cartItem) {
        return DetalleVentaEntity()
          ..productoId = int.tryParse(cartItem.producto.id)
          ..nombreProducto = cartItem.producto.nombre
          ..precioUnidad = cartItem.producto.precioUnidad
          ..cantidad = cartItem.cantidad.toDouble()
          ..subtotal = cartItem.cantidad.toDouble() * cartItem.producto.precioUnidad;
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
        ..documento = '...'
        ..empleado = widget.usuarioLogueado?.nombre ?? 'Administrador / Catálogo'
        ..items = itemsIsar.cast<DetalleVentaEntity>()
        ..syncStatus = 'pending';

      await _isarService.guardarVenta(nuevaVenta);
      ref.read(cartProvider.notifier).limpiarCarrito();
      await ref.read(catalogProvider.notifier).recargarDesdeSupabase();

      try {
        final ticketItems = cartState.items.map((item) {
          return TicketItem(
            nombre: item.producto.nombre,
            precio: item.producto.precioUnidad,
            cantidad: item.cantidad.toDouble(),
            esPesado: item.producto.esPesado,
          );
        }).toList();

        final selectedPrinter = ref.read(printerProvider);
        await TicketService.imprimirTicketVenta(
          context: context,
          items: ticketItems,
          subtotal: cartState.subtotal,
          impuesto: cartState.impuesto,
          total: cartState.total,
          metodoPago: metodoPago,
          montoRecibido: recibido,
          cambio: cambio,
          fechaVenta: DateTime.now(),
          impresoraSeleccionada: selectedPrinter?.device,
        );
      } catch (e) {
        debugPrint('Error al imprimir ticket: $e');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Venta registrada con éxito! 🎉'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar la venta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================
  @override
  Widget build(BuildContext context) {
    final contenido = _buildBody(context);

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(context),
        body: contenido,
      );
    } else {
      return contenido;
    }
  }

  // ==========================================================================
  // CUERPO PRINCIPAL (sin Scaffold)
  // ==========================================================================
  Widget _buildBody(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final bcvState = ref.watch(bcvProvider);
    final catalogState = ref.watch(catalogProvider);

    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final orientation = MediaQuery.of(context).orientation;
    final bool useSidebar = !isMobile && (isTablet ? orientation == Orientation.landscape : true);

    int crossAxisCount;
    double childAspectRatio;
    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 0.65;
    } else if (isTablet) {
      crossAxisCount = 3;
      childAspectRatio = 0.7;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 0.75;
    }

    return catalogState.isLoading
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => const ProductCardSkeleton(),
          )
        : useSidebar
            ? Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: _buildCatalogPanel(crossAxisCount, childAspectRatio),
                  ),
                  Container(
                    width: 380,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(left: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(-2, 0))],
                    ),
                    child: CartSidebar(
                      onCobrar: _mostrarModalCobro,
                      onLimpiar: () {
                        ref.read(cartProvider.notifier).limpiarCarrito();
                      },
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Expanded(
                    child: _buildCatalogPanel(crossAxisCount, childAspectRatio),
                  ),
                  FixedCartSummary(onCobrar: _mostrarModalCobro),
                ],
              );
  }

  // ==========================================================================
  // APP BAR
  // ==========================================================================
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final bcvState = ref.watch(bcvProvider);
    final lowStockCount = ref.read(catalogProvider.notifier).lowStockCount;

    return AppBar(
      leadingWidth: 85,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Icon(Icons.storefront, color: Colors.white, size: 32),
        ),
      ),
      title: Text(isMobile ? '' : 'Catálogo', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromRGBO(68, 109, 241, 1), Color.fromARGB(255, 85, 59, 235)],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      foregroundColor: Colors.white,
      actions: [
        // Panel de control
        Tooltip(
          message: 'Panel de Control POS',
          child: Container(
            width: isTablet ? 44 : 36,
            height: isTablet ? 44 : 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PosMenuScreen())),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(width: 6),
        // Inventario
        Tooltip(
          message: 'Ir a Gestión de Inventario',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: isTablet ? 44 : 36,
                height: isTablet ? 44 : 36,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.inventory_2_outlined, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InventoryScreen(
                        usuarioLogueado: widget.usuarioLogueado!,
                        showAppBar: true, // ✅ pasamos el parámetro
                      ),
                    ),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ),
              if (lowStockCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$lowStockCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        // BCV
        Tooltip(
          message: 'Tasa oficial BCV (Haz clic para actualizar)',
          child: InkWell(
            onTap: () => ref.read(bcvProvider).actualizarTasa(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(left: 4, right: 8),
              decoration: BoxDecoration(
                color: bcvState.cargando ? Colors.white.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.currency_exchange, size: 16, color: Color(0xFF38BDF8)),
                  const SizedBox(width: 6),
                  if (bcvState.cargando)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                    )
                  else
                    Text(
                      'BCV: Bs. ${bcvState.tasa.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ==========================================================================
  // PANEL DE CATÁLOGO
  // ==========================================================================
  Widget _buildCatalogPanel(int crossAxisCount, double childAspectRatio) {
    final catalogState = ref.watch(catalogProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Padding(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        children: [
          CatalogSearchBar(
            focusNode: _searchFocusNode,
            onScanPressed: _scanBarcode,
          ),
          const SizedBox(height: 16),
          const CategoryChips(),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(catalogProvider.notifier).recargarDesdeSupabase(),
              child: catalogState.productosFiltrados.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 12),
                          Text(
                            'No se encontraron productos.',
                            style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.only(bottom: 40),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: catalogState.productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final producto = catalogState.productosFiltrados[index];
                        final bool stockBajo = producto.stock <= producto.stockMinimo;
                        return ProductCard(
                          producto: producto,
                          stockBajo: stockBajo,
                          onTap: () => _mostrarModalCantidad(producto),
                          isMobile: isMobile,
                          index: index,
                          animationController: _animationController,
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}