import 'dart:async';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/inventory/product_form_dialog.dart';
import '../services/sync_service.dart';
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

// ✅ IMPORT DE ALIAS (mantenido como está)
import '../../data/Local/entities/codigo_barra_alia_entity.dart';
import '../../data/Local/entities/lote_entity.dart';

// ✅ PROVIDER PARA FORZAR REBUILD DEL GRIDVIEW
final refreshCatalogCounterProvider = StateProvider<int>((ref) => 0);

class InventoryCatalogScreen extends ConsumerStatefulWidget {
  final UsuarioEntity? usuarioLogueado;
  final bool showAppBar;

  const InventoryCatalogScreen({
    super.key,
    this.usuarioLogueado,
    this.showAppBar = true,
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

  // Variable para almacenar el factor del alias escaneado
  double _factorEscaneado = 1.0;

  StreamSubscription<double>? _weightSubscription;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    _scaleService.connect();
    _weightSubscription = _scaleService.weightStream.listen((_) {});

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

  void _iniciarPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (mounted) {
        try {
          await ref.read(catalogProvider.notifier).recargarEnSegundoPlano();
        } catch (_) {
          // Error silencioso en polling
        }
      }
    });
  }

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

  // ==========================================
  // ESCANEAR CÓDIGO DE BARRAS (CON ALIAS)
  // ==========================================
  Future<void> _scanBarcode() async {
    final codigo = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (codigo == null || codigo.isEmpty) return;

    // Buscar primero en alias, luego en producto principal
    final resultado = await _buscarProductoPorCodigo(codigo.trim());

    if (resultado != null) {
      // Usar el factor del alias (si se encontró uno)
      _mostrarModalCantidad(resultado, factor: _factorEscaneado);
      return;
    }

    // Si no se encontró, ofrecer opciones: crear producto o afiliar
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Producto no registrado'),
        content: Text('El código "$codigo" no está registrado.\n¿Qué deseas hacer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'cancel'),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'affiliate'),
            child: const Text('Afiliar a existente'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            onPressed: () => Navigator.pop(context, 'create'),
            child: const Text('Crear nuevo producto'),
          ),
        ],
      ),
    );

    if (action == 'create' && mounted) {
      _mostrarDialogoCrearProducto(codigo);
    } else if (action == 'affiliate' && mounted) {
      _mostrarDialogoAfiliarCodigo(codigo);
    }
  }

  // Método para buscar producto por código (incluyendo alias)
  Future<ProductoEntity?> _buscarProductoPorCodigo(String codigo) async {
    final codigoLimpio = codigo.trim();
    _factorEscaneado = 1.0;

    // 1. Buscar en alias
    final alias = await _isarService.obtenerAliasPorCodigo(codigoLimpio);
    if (alias != null) {
      final producto = await _isarService.obtenerProductoPorId(alias.productoId);
      if (producto != null) {
        _factorEscaneado = alias.factor;
        return producto;
      }
    }

    // 2. Buscar en el campo principal del producto
    final producto = await _isarService.obtenerProductoPorCodigoBarrasExacto(codigoLimpio);
    if (producto != null) {
      _factorEscaneado = 1.0;
      return producto;
    }

    return null;
  }

  // Diálogo para afiliar un código a un producto existente
  Future<void> _mostrarDialogoAfiliarCodigo(String codigo) async {
    final productos = await _isarService.obtenerProductos();

    if (productos.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay productos disponibles para afiliar. Crea uno primero.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final productoSeleccionado = await showDialog<ProductoEntity>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Producto'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final p = productos[index];
              return FutureBuilder<double>(
                future: _isarService.obtenerStockTotalPorProducto(p.id),
                builder: (context, snapshot) {
                  final stock = snapshot.data ?? 0.0;
                  return ListTile(
                    title: Text(p.nombre),
                    subtitle: Text('Código: ${p.codigoBarras} | Stock: $stock'),
                    onTap: () => Navigator.pop(context, p),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (productoSeleccionado != null) {
      // Guardar el alias
      final nuevoAlias = CodigoBarrasAliasEntity()
        ..codigo = codigo.trim()
        ..productoId = productoSeleccionado.id
        ..factor = 1.0 // Por defecto 1, luego se puede editar
        ..activo = true
        ..fechaAsignacion = DateTime.now()
        ..observaciones = 'Código afiliado desde escaneo'
        ..sincronizado = false;

      await _isarService.guardarCodigoAlias(nuevoAlias);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Código "$codigo" afiliado a "${productoSeleccionado.nombre}"'),
            backgroundColor: Colors.green,
          ),
        );
        await ref.read(catalogProvider.notifier).recargarDesdeSupabase();
      }
    }
  }

  // Método para afiliar un código desde el detalle del producto
  Future<void> _afiliarCodigoAProducto(ProductoEntity producto, String codigo) async {
    final aliasExistente = await _isarService.obtenerAliasPorCodigo(codigo.trim());
    if (aliasExistente != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Este código ya está afiliado a otro producto.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final factor = await showDialog<double>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: '1.0');
        return AlertDialog(
          title: const Text('Factor de Conversión'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cuántas unidades representa este código?'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Factor (ej. 12 para caja)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text);
                if (val != null && val > 0) {
                  Navigator.pop(context, val);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ingresa un factor válido mayor a 0')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );

    if (factor != null) {
      final nuevoAlias = CodigoBarrasAliasEntity()
        ..codigo = codigo.trim()
        ..productoId = producto.id
        ..factor = factor
        ..activo = true
        ..fechaAsignacion = DateTime.now()
        ..observaciones = 'Afiliado manualmente'
        ..sincronizado = false;

      await _isarService.guardarCodigoAlias(nuevoAlias);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Código "$codigo" afiliado con factor $factor'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _agregarAlCarrito(ProductoEntity producto, double cantidad) {
    _isarService.obtenerStockTotalPorProducto(producto.id).then((stockTotal) {
      if (stockTotal < cantidad && !producto.esPesado) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stock insuficiente. Disponible: $stockTotal'),
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
            stockMaximo: stockTotal,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${producto.nombre} agregado al carrito.'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 1),
        ),
      );
      ref.read(catalogProvider.notifier).setBusqueda('');
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al verificar stock: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    });
  }

  void _mostrarModalCantidad(ProductoEntity producto, {double factor = 1.0}) {
    showDialog(
      context: context,
      builder: (context) => QuantityDialog(
        producto: producto,
        cantidadInicial: factor,
        onAgregar: (productoModificado, cantidad) {
          _agregarAlCarrito(productoModificado, cantidad);
        },
      ),
    );
  }

  // Versión sobrecargada para mantener compatibilidad
  void _mostrarModalCantidadOriginal(ProductoEntity producto) {
    _mostrarModalCantidad(producto, factor: 1.0);
  }

  void _mostrarDialogoCrearProducto(String codigo) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        codigoBarrasPrecargado: codigo,
        onGuardar: (producto) async {
          final isar = IsarService();
          await isar.guardarProducto(producto);

          // Crear lote inicial para el producto
          final loteInicial = LoteEntity()
            ..productoId = producto.id
            ..cantidadInicial = producto.stock
            ..cantidadRestante = producto.stock
            ..fechaIngreso = DateTime.now()
            ..estado = 'activo'
            ..sincronizado = false;

          await isar.guardarLote(loteInicial);

          await SyncService().sincronizarProductosASupabase();
          await ref.read(catalogProvider.notifier).recargarDesdeSupabase();

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Producto creado exitosamente'), backgroundColor: Color(0xFF10B981)),
            );
          }
        },
      ),
    );
  }

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

  // _procesarYGuardarVenta modificado para descontar de lotes
  Future<void> _procesarYGuardarVenta(
      String metodoPago, double cambio, double recibido, double tasaActual) async {
    try {
      final cartState = ref.read(cartProvider);
      final String ventaIdStr =
          'V-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final DateTime ahora = DateTime.now();
      final double totalBsCalculado = cartState.total * tasaActual;

      // Descontar de lotes antes de guardar la venta
      for (var cartItem in cartState.items) {
        final productoId = int.tryParse(cartItem.producto.id);
        if (productoId == null) continue;

        double cantidadPorDescontar = cartItem.cantidad;
        while (cantidadPorDescontar > 0.001) {
          final lote = await _isarService.obtenerLoteParaVenta(
            productoId,
            priorizarVencimiento: true,
          );
          if (lote == null) {
            throw Exception('Stock insuficiente para ${cartItem.producto.nombre}');
          }

          final descontar = cantidadPorDescontar > lote.cantidadRestante
              ? lote.cantidadRestante
              : cantidadPorDescontar;

          final exito = await _isarService.descontarLote(lote.id, descontar);
          if (!exito) {
            throw Exception('Error al descontar lote de ${cartItem.producto.nombre}');
          }

          cantidadPorDescontar -= descontar;
        }
      }

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
      } catch (_) {
        // Error al imprimir ticket, ignorar
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('¡Venta registrada con éxito! 🎉'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al registrar la venta: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contenido = _buildBody(context);

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: _buildAppBar(context),
        body: contenido,
      );
    } else {
      return contenido;
    }
  }

  Widget _buildBody(BuildContext context) {
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
            itemBuilder: (_, _) => ProductCardSkeleton(),
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
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.black.withValues(alpha: 0.5)
                              : Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(-4, 0),
                        ),
                      ],
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final bcvState = ref.watch(bcvProvider);
    final lowStockCount = ref.read(catalogProvider.notifier).lowStockCount;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      leadingWidth: 85,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(Icons.storefront, color: colorScheme.onPrimary, size: 32),
        ),
      ),
      title: Text(isMobile ? '' : 'Catálogo',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: colorScheme.onPrimary)),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.9),
                    colorScheme.primary,
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color.fromRGBO(68, 109, 241, 1), Color.fromARGB(255, 85, 59, 235)],
                ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: colorScheme.onPrimary,
      actions: [
        Tooltip(
          message: 'Panel de Control POS',
          child: Container(
            width: isTablet ? 44 : 36,
            height: isTablet ? 44 : 36,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.grid_view_rounded, color: colorScheme.onPrimary, size: 24),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PosMenuScreen())),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(width: 6),
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
                        showAppBar: true,
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
        Tooltip(
          message: 'Tasa oficial BCV (Haz clic para actualizar)',
          child: InkWell(
            onTap: () => ref.read(bcvProvider).actualizarTasa(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(left: 4, right: 8),
              decoration: BoxDecoration(
                color: bcvState.cargando
                    ? colorScheme.onPrimary.withValues(alpha: 0.25)
                    : colorScheme.onPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.onPrimary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.currency_exchange, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  if (bcvState.cargando)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  else
                    Text(
                      'BCV: Bs. ${bcvState.tasa.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: colorScheme.onPrimary,
                      ),
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

  Widget _buildCatalogPanel(int crossAxisCount, double childAspectRatio) {
    final catalogState = ref.watch(catalogProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;

    // ✅ OBTENER EL CONTADOR PARA USARLO COMO KEY
    final refreshCounter = ref.watch(refreshCatalogCounterProvider);

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
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 48, color: colorScheme.outline),
                          const SizedBox(height: 12),
                          Text(
                            'No se encontraron productos.',
                            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      // ✅ KEY QUE CAMBIA PARA FORZAR REBUILD
                      key: ValueKey(refreshCounter),
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
                        return FutureBuilder<double>(
                          future: _isarService.obtenerStockTotalPorProducto(producto.id),
                          builder: (context, snapshot) {
                            final stockTotal = snapshot.data ?? 0.0;
                            final bool stockBajo = stockTotal <= producto.stockMinimo;
                            return ProductCard(
                              producto: producto,
                              stockBajo: stockBajo,
                              onTap: () => _mostrarModalCantidad(producto, factor: 1.0),
                              isMobile: isMobile,
                              index: index,
                              animationController: _animationController,
                            );
                          },
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