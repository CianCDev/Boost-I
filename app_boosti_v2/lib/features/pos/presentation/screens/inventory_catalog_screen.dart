import 'dart:async';
import 'package:app_boosti_v2/features/pos/presentation/widgets/rest_button_widget.dart';
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
import '../utils/responsive_helper.dart';
import '../services/scale_service.dart';
import 'inventory_screen.dart';
import 'pos_menu_screen.dart';

class InventoryCatalogScreen extends ConsumerStatefulWidget {
  final UsuarioEntity? usuarioLogueado;
  const InventoryCatalogScreen({super.key, this.usuarioLogueado});

  @override
  ConsumerState<InventoryCatalogScreen> createState() => _InventoryCatalogScreenState();
}

class _InventoryCatalogScreenState extends ConsumerState<InventoryCatalogScreen> with SingleTickerProviderStateMixin {
  final IsarService _isarService = IsarService();

  String _categoriaSeleccionada = 'Todas';
  List<String> _categorias = ['Todas', 'Stock Bajo'];

  List<ProductoEntity> _productosCatalog = [];
  List<ProductoEntity> _productosFiltrados = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final ScaleService _scaleService = ScaleService();
  StreamSubscription<double>? _weightSub;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    HardwareKeyboard.instance.addHandler(_manejarTecladoFisico);
    _inicializarPantalla();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bcvProvider).actualizarTasa();
      _scaleService.connect();
    });
  }

  Future<void> _inicializarPantalla() async {
    await _cargarProductosDesdeIsar();
  }

  @override
  void dispose() {
    _scaleService.dispose();
    _weightSub?.cancel();
    HardwareKeyboard.instance.removeHandler(_manejarTecladoFisico);
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  bool _manejarTecladoFisico(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.f2) {
        _enfocarBuscador();
        return true;
      }
      if (event.logicalKey == LogicalKeyboardKey.f12) {
        final cartState = ref.read(cartProvider);
        if (cartState.total > 0) _mostrarModalCobro(context);
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
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  int _getLowStockCount() {
    return _productosCatalog.where((p) => p.stock <= p.stockMinimo).length;
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
          coincideCategoria = prod.categoria.trim().toLowerCase() == _categoriaSeleccionada.toLowerCase();
        }

        return (coincideNombre || coincideCodigo) && coincideCategoria;
      }).toList();
    });
  }

  void _agregarAlCarrito(ProductoEntity producto, double cantidad) {
    if (producto.stock < cantidad && !producto.esPesado) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Stock insuficiente para agregar esta cantidad'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
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

    _searchController.clear();
    _filtrarProductos();
  }

  void _mostrarModalCantidad(BuildContext context, ProductoEntity producto) {
    final theme = Theme.of(context);
    final TextEditingController cantidadController = TextEditingController(
      text: producto.esPesado ? '1.000' : '1',
    );
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = !isTablet && !ResponsiveHelper.isMobile(context);

    if (producto.esPesado) {
      _weightSub = _scaleService.weightStream.listen((peso) {
        if (peso > 0) {
          cantidadController.text = peso.toStringAsFixed(3);
          cantidadController.selection = TextSelection.fromPosition(
            TextPosition(offset: cantidadController.text.length)
          );
        }
      });
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isTablet || isDesktop ? 40.0 : 16.0,
            vertical: 24.0,
          ),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isTablet || isDesktop ? 550.0 : double.infinity,
            ),
            padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF10B981), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Agregar ${producto.nombre}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: theme.textTheme.bodyLarge?.color,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    producto.esPesado
                        ? 'Producto de Balanza (ingresa el peso en kg):'
                        : 'Ingresa la cantidad deseada (unidades):',
                    style: TextStyle(
                      fontSize: isTablet || isDesktop ? 16 : 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                    decoration: InputDecoration(
                      labelText: 'Cantidad',
                      labelStyle: TextStyle(fontSize: isTablet || isDesktop ? 16 : 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7)),
                      suffixText: producto.esPesado ? 'kg' : 'unid',
                      suffixStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: isTablet || isDesktop ? 20 : 14),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.brightness == Brightness.dark ? Colors.grey.shade600 : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF10B981), width: 2.5),
                      ),
                    ),
                    onSubmitted: (val) {
                      _weightSub?.cancel();
                      final double? cantidad = double.tryParse(val);
                      if (cantidad != null && cantidad > 0) {
                        Navigator.of(dialogContext).pop();
                        _agregarAlCarrito(producto, cantidad);
                      }
                    },
                  ),
                  const SizedBox(height: 28),

                  Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          foregroundColor: theme.textTheme.bodyMedium?.color,
                          backgroundColor: theme.colorScheme.surfaceVariant,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          _weightSub?.cancel();
                          cantidadController.dispose();
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text('Cancelar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                        ),
                        onPressed: () {
                          _weightSub?.cancel();
                          final double? cantidad = double.tryParse(cantidadController.text);
                          if (cantidad == null || cantidad <= 0) return;

                          Navigator.of(dialogContext).pop();
                          _agregarAlCarrito(producto, cantidad);
                          cantidadController.dispose();
                        },
                        child: const Text('Agregar al Carrito', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
  }

  Future<void> _mostrarModalCobro(BuildContext context) async {
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
        ..documento = 'V-00000000'
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
          SnackBar(content: Text('Error al registrar la venta: $e'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }
  }

  void _limpiarCarritoConConfirmacion() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Reiniciar Venta', style: TextStyle(color: theme.textTheme.bodyLarge?.color, fontWeight: FontWeight.bold, fontSize: 22)),
          content: Text('¿Estás seguro de que quieres reiniciar la venta actual? Se borrarán todos los productos del carrito.', style: TextStyle(fontSize: 18, color: theme.textTheme.bodyMedium?.color)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancelar', style: TextStyle(fontSize: 18, color: theme.textTheme.bodyMedium?.color)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(cartProvider.notifier).limpiarCarrito();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Carrito reiniciado correctamente.'), duration: Duration(seconds: 1)),
                );
              },
              child: const Text('Sí, reiniciar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cartState = ref.watch(cartProvider);
    final bcvController = ref.watch(bcvProvider);
    final double tasaBcv = bcvController.tasa;
    final bool cargandoBcv = bcvController.cargando;

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

    final int lowStockCount = _getLowStockCount();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leadingWidth: 85,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => const Icon(Icons.storefront, color: Colors.white, size: 32),
          ),
        ),
        title: Text(
          isMobile ? '' : 'Catálogo',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromRGBO(68, 109, 241, 1),
                Color.fromARGB(255, 85, 59, 235),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [
          Tooltip(
            message: 'Panel de Control POS',
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: const Icon(Icons.grid_view_rounded, color: Colors.white, size: 24),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PosMenuScreen()),
                  );
                },
                splashRadius: 20,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.usuarioLogueado != null)
            CajeroRestButton(usuario: widget.usuarioLogueado!),
          const SizedBox(width: 6),

          Tooltip(
            message: 'Ir a Gestión de Inventario',
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF59E0B).withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.inventory_2_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InventoryScreen(usuarioLogueado: widget.usuarioLogueado!),
                        ),
                      );
                    },
                    splashRadius: 20,
                    padding: EdgeInsets.zero,
                  ),
                ),
                if (lowStockCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.redAccent,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: Text(
                        '$lowStockCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          Tooltip(
            message: 'Tasa oficial BCV (Haz clic para actualizar)',
            child: AnimatedScale(
              scale: cargandoBcv ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(left: 4, right: 8),
                decoration: BoxDecoration(
                  color: cargandoBcv
                      ? Colors.white.withOpacity(0.25)
                      : Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.currency_exchange, size: 16, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    AnimatedOpacity(
                      opacity: cargandoBcv ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: const Color(0xFF10B981)),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: cargandoBcv ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        'BCV: Bs. ${tasaBcv.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (context, index) => const _ProductCardSkeleton(),
            )
          : useSidebar
              ? _buildDesktopTabletLayout(cartState, crossAxisCount, childAspectRatio)
              : _buildMobileTabletPortraitLayout(cartState, crossAxisCount, childAspectRatio),
    );
  }

  Widget _buildDesktopTabletLayout(dynamic cartState, int crossAxisCount, double childAspectRatio) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: _buildCatalogPanel(cartState, crossAxisCount, childAspectRatio),
        ),
        Container(
          width: 380,
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(
              left: BorderSide(
                color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(-2, 0))],
          ),
          child: _buildCartSidebarDesktop(cartState),
        ),
      ],
    );
  }

  Widget _buildCatalogPanel(dynamic cartState, int crossAxisCount, double childAspectRatio) {
    final theme = Theme.of(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        children: [
          _buildSearchBar(isMobile),
          const SizedBox(height: 16),
          _buildCategoryChips(),
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargarProductosDesdeIsar,
              child: _productosFiltrados.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 48, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3)),
                              const SizedBox(height: 12),
                              Text('No se encontraron productos.', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 14))
                            ],
                          ),
                        ),
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
                      itemCount: _productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final producto = _productosFiltrados[index];
                        final bool stockBajo = producto.stock <= producto.stockMinimo;
                        return _ProductCard(
                          producto: producto,
                          stockBajo: stockBajo,
                          onTap: () => _mostrarModalCantidad(context, producto),
                          isMobile: false,
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

  Widget _buildMobileTabletPortraitLayout(dynamic cartState, int crossAxisCount, double childAspectRatio) {
    final theme = Theme.of(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 24.0 : 12.0),
            child: Column(
              children: [
                _buildSearchBar(isMobile),
                const SizedBox(height: 12),
                _buildCategoryChips(),
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _cargarProductosDesdeIsar,
                    child: _productosFiltrados.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.inventory_2_outlined, size: 48, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3)),
                                    const SizedBox(height: 12),
                                    Text('No se encontraron productos.', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: 14))
                                  ],
                                ),
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.only(bottom: 10),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: childAspectRatio,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: _productosFiltrados.length,
                            itemBuilder: (context, index) {
                              final producto = _productosFiltrados[index];
                              final bool stockBajo = producto.stock <= producto.stockMinimo;
                              return _ProductCard(
                                producto: producto,
                                stockBajo: stockBajo,
                                onTap: () => _mostrarModalCantidad(context, producto),
                                isMobile: true,
                                index: index,
                                animationController: _animationController,
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
        _buildFixedCartSummary(cartState),
      ],
    );
  }

  Widget _buildFixedCartSummary(dynamic cartState) {
    final theme = Theme.of(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final double barHeight = isTablet ? 140.0 : 120.0;

    return Container(
      height: barHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300,
            width: isTablet ? 2 : 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total: \$${cartState.total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isTablet ? 28 : 17,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bs. ${(cartState.total * (ref.read(bcvProvider).tasa > 0 ? ref.read(bcvProvider).tasa : 1)).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isTablet ? 20 : 13,
                    color: const Color(0xFF3B82F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (cartState.items.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.colorScheme.error.withOpacity(0.3), width: 1.5),
                ),
                child: Text(
                  '${cartState.items.length}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.colorScheme.error),
                ),
              ),
            SizedBox(
              height: isTablet ? 66 : 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 12, vertical: 12),
                  elevation: 6,
                  side: const BorderSide(color: Color(0xFF059669), width: 1.5),
                ),
                onPressed: cartState.items.isEmpty
                    ? null
                    : () => _openCartBottomSheet(context, cartState),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart_outlined, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Ver Carrito',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isTablet ? 20 : 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCartBottomSheet(BuildContext context, dynamic cartState) {
    final theme = Theme.of(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.95,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Mi Carrito', style: TextStyle(fontSize: isTablet ? 28 : 22, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
                    Row(
                      children: [
                        if (cartState.items.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.refresh_outlined, color: Color(0xFFEF4444), size: 28),
                            tooltip: 'Reiniciar Venta',
                            splashRadius: 28,
                            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _limpiarCarritoConConfirmacion();
                            },
                          ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 28, color: theme.textTheme.bodyLarge?.color),
                          splashRadius: 28,
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
                Divider(thickness: 2, color: theme.dividerColor),
                const SizedBox(height: 16),
                Expanded(
                  child: cartState.items.isEmpty
                      ? Center(child: Text('El carrito está vacío', style: TextStyle(fontSize: 18, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))))
                      : ListView.separated(
                          itemCount: cartState.items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final cartItem = cartState.items[index];
                            final double subtotal = cartItem.producto.precioUnidad * cartItem.cantidad.toDouble();
                            return Container(
                              padding: EdgeInsets.all(isTablet ? 20 : 16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFCBD5E1),
                                  width: isTablet ? 2 : 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cartItem.producto.nombre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 20 : 16, color: theme.textTheme.bodyLarge?.color), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 6),
                                        Text('${cartItem.cantidad.toStringAsFixed(cartItem.producto.esPesado ? 3 : 0)} x \$${cartItem.producto.precioUnidad.toStringAsFixed(2)}', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7), fontSize: isTablet ? 16 : 14)),
                                      ],
                                    ),
                                  ),
                                  Text('\$${subtotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 20 : 17, color: const Color(0xFF059669))),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () => ref.read(cartProvider.notifier).eliminarItem(index),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: EdgeInsets.all(isTablet ? 12 : 10),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.error.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
                                      ),
                                      child: Icon(Icons.close_rounded, color: theme.colorScheme.error, size: isTablet ? 28 : 22),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                Divider(thickness: 2, color: theme.dividerColor),
                const SizedBox(height: 12),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL USD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 20 : 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
                        Text('\$${cartState.total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 30 : 20, color: const Color(0xFF059669))),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('TOTAL BOLÍVARES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 18 : 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))),
                        Text('Bs. ${(cartState.total * (ref.read(bcvProvider).tasa > 0 ? ref.read(bcvProvider).tasa : 1)).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 22 : 14, color: const Color(0xFF3B82F6))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: isTablet ? 76 : 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 6,
                          side: const BorderSide(color: Color(0xFF059669), width: 1.5),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _mostrarModalCobro(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.payments_outlined, size: isTablet ? 32 : 24),
                            SizedBox(width: 16),
                            Text('COBRAR ORDEN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 24 : 18, letterSpacing: 1.0)),
                          ],
                        ),
                      ),
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

  Widget _buildCartSidebarDesktop(dynamic cartState) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: theme.dividerColor)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('🛒 Orden Activa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: theme.textTheme.bodyLarge?.color)),
                  if (cartState.items.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: theme.colorScheme.primary, borderRadius: BorderRadius.circular(12)),
                      child: Text('${cartState.items.length} ítems', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              if (cartState.items.isNotEmpty)
                Tooltip(
                  message: 'Reiniciar Venta',
                  child: IconButton(
                    icon: const Icon(Icons.refresh_outlined, color: Color(0xFFEF4444), size: 24),
                    splashRadius: 24,
                    onPressed: _limpiarCarritoConConfirmacion,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: cartState.items.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.shopping_cart_outlined, size: 48, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3)), const SizedBox(height: 8), Text('Carrito vacío', style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6), fontSize: 13))]))
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: cartState.items.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final cartItem = cartState.items[index];
                    final double subtotal = cartItem.producto.precioUnidad * cartItem.cantidad.toDouble();
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFCBD5E1),
                          width: 1.5,
                        ),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cartItem.producto.nombre, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textTheme.bodyLarge?.color), maxLines: 1, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text('${cartItem.cantidad.toStringAsFixed(cartItem.producto.esPesado ? 3 : 0)} x \$${cartItem.producto.precioUnidad.toStringAsFixed(2)}', style: TextStyle(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
                              ],
                            ),
                          ),
                          Text('\$${subtotal.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: const Color(0xFF059669))),
                          const SizedBox(width: 10),
                          Container(
                            decoration: BoxDecoration(color: theme.colorScheme.error.withOpacity(0.15), shape: BoxShape.circle),
                            child: IconButton(
                              icon: Icon(Icons.close_rounded, size: 20, color: theme.colorScheme.error),
                              splashRadius: 24,
                              onPressed: () => ref.read(cartProvider.notifier).eliminarItem(index),
                              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            border: Border(
              top: BorderSide(
                color: theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('TOTAL USD', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))), Text('\$${cartState.total.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: const Color(0xFF059669)))],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text('TOTAL BOLÍVARES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6))), Text('Bs. ${(cartState.total * (ref.read(bcvProvider).tasa > 0 ? ref.read(bcvProvider).tasa : 1)).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF3B82F6)))],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cartState.items.isEmpty ? theme.colorScheme.surfaceVariant : const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    side: cartState.items.isEmpty ? null : const BorderSide(color: Color(0xFF059669), width: 1.5),
                  ),
                  onPressed: cartState.items.isEmpty ? null : () => _mostrarModalCobro(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payments_outlined, size: 24),
                      SizedBox(width: 12),
                      Text('COBRAR ORDEN (F12)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isMobile) {
    final theme = Theme.of(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    return SizedBox(
      height: 46,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) => _filtrarProductos(),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre / código (F2)...',
          hintStyle: TextStyle(fontSize: isTablet ? 18 : 14, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
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
              Icon(Icons.search, size: 22, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
            ],
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear, size: 18, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
            onPressed: () {
              _searchController.clear();
              _filtrarProductos();
            },
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
          filled: true,
          fillColor: theme.cardColor,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFCBD5E1),
              width: isTablet ? 2.5 : 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
          ),
        ),
        onSubmitted: (val) {
          if (_productosFiltrados.length == 1) {
            _mostrarModalCantidad(context, _productosFiltrados.first);
          }
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    final theme = Theme.of(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final double height = isTablet ? 60 : 48;

    return SizedBox(
      height: height,
      child: isTablet
          ? Scrollbar(
              thickness: 6,
              radius: const Radius.circular(10),
              scrollbarOrientation: ScrollbarOrientation.bottom,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categorias.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
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
            )
          : ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categorias.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
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
    );
  }
}

// ==========================================
// BOTÓN DE CATEGORÍA
// ==========================================
class _CategoryButton extends StatefulWidget {
  final String categoria;
  final bool esSeleccionada;
  final VoidCallback onTap;
  const _CategoryButton({required this.categoria, required this.esSeleccionada, required this.onTap});
  @override
  State<_CategoryButton> createState() => _CategoryButtonState();
}
class _CategoryButtonState extends State<_CategoryButton> {
  bool _isHovered = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool esStockBajo = widget.categoria == 'Stock Bajo';
    final bool isTablet = ResponsiveHelper.isTablet(context);

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (widget.esSeleccionada) {
      backgroundColor = esStockBajo ? const Color(0xFFEF4444) : const Color(0xFF10B981);
      borderColor = backgroundColor;
      textColor = Colors.white;
    } else {
      backgroundColor = _isHovered ? theme.colorScheme.surfaceVariant.withOpacity(0.7) : theme.cardColor;
      borderColor = _isHovered 
          ? (theme.brightness == Brightness.dark ? Colors.grey.shade500 : const Color(0xFF94A3B8))
          : (theme.brightness == Brightness.dark ? Colors.grey.shade700 : const Color(0xFFCBD5E1));
      textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;
    }

    final double fontSize = isTablet ? 16.0 : 13.0;
    final padding = isTablet
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 14, vertical: 6);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: isTablet ? 2 : 1.5),
            boxShadow: widget.esSeleccionada ? [BoxShadow(color: (esStockBajo ? Colors.red : const Color(0xFF10B981)).withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 4))] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esStockBajo) ...[Icon(Icons.warning_amber_rounded, size: 16, color: widget.esSeleccionada ? Colors.white : Colors.amber), const SizedBox(width: 4)]
              else if (widget.esSeleccionada) ...[const Icon(Icons.check_circle, size: 16, color: Colors.white), const SizedBox(width: 4)],
              Text(widget.categoria, style: TextStyle(fontSize: fontSize, fontWeight: widget.esSeleccionada ? FontWeight.bold : FontWeight.w500, color: textColor)),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// TARJETA DE PRODUCTO
// ==========================================
class _ProductCard extends StatefulWidget {
  final ProductoEntity producto;
  final bool stockBajo;
  final VoidCallback onTap;
  final bool isMobile;
  final int index;
  final AnimationController animationController;

  const _ProductCard({
    required this.producto,
    required this.stockBajo,
    required this.onTap,
    this.isMobile = false,
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
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: widget.animationController,
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isTablet = ResponsiveHelper.isTablet(context);

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
                          : const Color(0xFFE2E8F0)),
                  width: widget.stockBajo ? 2 : (isTablet ? 2.5 : 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isTablet ? 0.08 : 0.04),
                    blurRadius: isTablet ? 16 : 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: widget.producto.imagenUrl?.isNotEmpty ?? false
                                ? Image.network(
                                    widget.producto.imagenUrl!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (_, _, _) => Icon(Icons.inventory_2, size: 40, color: theme.colorScheme.primary),
                                  )
                                : Icon(Icons.inventory_2, size: 40, color: theme.colorScheme.primary),
                          ),
                          if (widget.stockBajo)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDC2626),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '¡STOCK BAJO!',
                                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.cardColor.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.producto.esPesado ? 'Balanza' : 'Unidad',
                                style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.producto.nombre,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: widget.isMobile ? 13 : (isTablet ? 18 : 14),
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                          ),
                          Text(
                            'Cód: ${widget.producto.codigoBarras}',
                            style: TextStyle(fontSize: widget.isMobile ? 9 : (isTablet ? 12 : 10), color: theme.textTheme.bodyMedium?.color?.withOpacity(0.6)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: widget.isMobile ? 15 : (isTablet ? 20 : 16),
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: widget.stockBajo ? theme.colorScheme.error.withOpacity(0.15) : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: theme.brightness == Brightness.dark ? Colors.grey.shade600 : const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Stock: ${widget.producto.stock}',
                                  style: TextStyle(
                                    fontSize: widget.isMobile ? 9 : (isTablet ? 12 : 10),
                                    fontWeight: FontWeight.w600,
                                    color: widget.stockBajo ? theme.colorScheme.error : theme.textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: double.infinity, color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                  Container(height: 10, width: 80, color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 16, width: 60, color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                      Container(height: 14, width: 70, color: theme.colorScheme.surfaceVariant.withOpacity(0.5)),
                    ],
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