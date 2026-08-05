import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/detalle_venta_entity.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/turno_entity.dart';
import '../../data/Local/entities/venta_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/models/product_item.dart';
import '../controllers/cart_controller.dart';
import '../providers/bcv_provider.dart';
import '../services/sync_service.dart';
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
  ConsumerState<InventoryCatalogScreen> createState() =>
      _InventoryCatalogScreenState();
}

class _InventoryCatalogScreenState
    extends ConsumerState<InventoryCatalogScreen>
    with SingleTickerProviderStateMixin {
  final IsarService _isarService = IsarService();
  final SyncService syncService = SyncService();
  final ScaleService _scaleService = ScaleService(); // Balanza

  // ============================
  // VARIABLES DE INSTANCIA
  // ============================
  String _categoriaSeleccionada = 'Todas';
  List<String> _categorias = ['Todas', 'Stock Bajo'];

  List<ProductoEntity> _productosCatalog = [];
  List<ProductoEntity> _productosFiltrados = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // Realtime
  RealtimeChannel? _productosChannel;
  bool _realtimeSuscrito = false;

  // Balanza - suscripción global para debug
  StreamSubscription<double>? _weightSubscription;

  // TURNO – variables de instancia (corregido)
  TurnoEntity? _turnoActual;
  bool _turnoAbierto = false;

  // ============================
  // INIT
  // ============================
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    syncService.iniciarMonitoreo();
    syncService.sincronizarTodo();

    _scaleService.connect();
    _weightSubscription = _scaleService.weightStream.listen((peso) {
      debugPrint('⚖️ Peso en tiempo real: $peso kg');
    });

    _suscribirseARealtime();

    HardwareKeyboard.instance.addHandler(_manejarTecladoFisico);
    _inicializarPantalla();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarTurnoActual();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bcvProvider).actualizarTasa();
    });
  }

  @override
  void dispose() {
    _scaleService.dispose();
    _weightSubscription?.cancel();
    _productosChannel?.unsubscribe();
    _productosChannel = null;
    _realtimeSuscrito = false;
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================
  // MÉTODOS AUXILIARES
  // ============================
  Future<void> _inicializarPantalla() async {
    await _cargarProductosDesdeIsar();
  }

  // --- CARGAR TURNO ACTUAL (corregido) ---
  Future<void> _cargarTurnoActual() async {
    final usuario = widget.usuarioLogueado;
    if (usuario == null) return;
    final turno = await _isarService.obtenerTurnoAbiertoPorUsuario(usuario.id);
    if (turno != null) {
      setState(() {
        _turnoActual = turno;
        _turnoAbierto = true;
      });
    }
  }

  // --- ABRIR TURNO ---
  Future<void> _abrirTurno() async {
    final usuario = widget.usuarioLogueado;
    if (usuario == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario no identificado.')),
        );
      }
      return;
    }

    final turnoExistente = await _isarService.obtenerTurnoAbiertoPorUsuario(usuario.id);
    if (turnoExistente != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya tienes un turno abierto.')),
        );
      }
      return;
    }

    final turno = TurnoEntity()
      ..usuarioId = usuario.id
      ..usuarioNombre = usuario.nombre
      ..fechaApertura = DateTime.now()
      ..montoInicial = 0.0
      ..estado = 'abierto'
      ..syncStatus = 'pending';

    await _isarService.guardarTurno(turno);
    setState(() {
      _turnoActual = turno;
      _turnoAbierto = true;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Turno abierto para ${usuario.nombre}'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  // --- CERRAR TURNO ---
  Future<void> _cerrarTurno() async {
    if (_turnoActual == null) return;

    final montoFinal = _turnoActual?.totalVentas ?? 0.0;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Turno'),
        content: Text(
          'El total de ventas del turno es: \$${montoFinal.toStringAsFixed(2)}\n¿Cerrar turno?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Turno'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _isarService.cerrarTurno(_turnoActual!.id, montoFinal);
    setState(() {
      _turnoActual = null;
      _turnoAbierto = false;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Turno cerrado correctamente.'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
    }
  }

  // --- TECLADO FÍSICO ---
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

  // ============================
  // REALTIME (productos)
  // ============================
  void _suscribirseARealtime() { /* ... sin cambios ... */ }
  void _handleRealtimeProductChange(dynamic payload) { /* ... sin cambios ... */ }
  Future<void> _actualizarProductoDesdeRecord(Map<String, dynamic> record) async { /* ... sin cambios ... */ }
  Future<void> _eliminarProductoPorCodigo(String? codigo) async { /* ... sin cambios ... */ }

  // ============================
  // CARGA Y FILTROS DE PRODUCTOS
  // ============================
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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar inventario: $e'),
            backgroundColor: Colors.redAccent,
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
          coincideCategoria = prod.categoria.trim().toLowerCase() ==
              _categoriaSeleccionada.toLowerCase();
        }
        return (coincideNombre || coincideCodigo) && coincideCategoria;
      }).toList();
    });
  }

  void _agregarAlCarrito(ProductoEntity producto, double cantidad) {
    if (producto.stock < cantidad && !producto.esPesado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stock insuficiente'),
          backgroundColor: Colors.redAccent,
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

  // ============================
  // COBRO
  // ============================
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

  Future<void> _procesarYGuardarVentaIsar(
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
          ..subtotal =
              cartItem.cantidad.toDouble() * cartItem.producto.precioUnidad;
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
        ..empleado =
            widget.usuarioLogueado?.nombre ?? 'Administrador / Catálogo'
        ..items = itemsIsar.cast<DetalleVentaEntity>()
        ..turnoId = _turnoActual?.id   // <--- asociar turno
        ..syncStatus = 'pending';

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

  void _limpiarCarritoConConfirmacion() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Reiniciar Venta',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 22)),
          content: const Text(
              '¿Estás seguro de que quieres reiniciar la venta actual?',
              style: TextStyle(fontSize: 18)),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancelar',
                  style: TextStyle(fontSize: 18, color: Color(0xFF64748B))),
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
                  const SnackBar(
                      content: Text('Carrito reiniciado correctamente.'),
                      duration: Duration(seconds: 1)),
                );
              },
              child: const Text('Sí, reiniciar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  // ============================
  // ESCÁNER
  // ============================
  Future<void> _scanBarcode() async { /* ... sin cambios ... */ }

  // ============================
  // MODAL DE CANTIDAD CON BALANZA
  // ============================
  void _mostrarModalCantidad(BuildContext context, ProductoEntity producto) { /* ... sin cambios ... */ }

  // ============================================================
  // BUILD (continúa en la Parte 2)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final bcvController = ref.watch(bcvProvider);
    final double tasaBcv = bcvController.tasa;
    final bool cargandoBcv = bcvController.cargando;

    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final orientation = MediaQuery.of(context).orientation;
    final bool useSidebar =
        !isMobile && (isTablet ? orientation == Orientation.landscape : true);

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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        leadingWidth: 85,
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.storefront, color: Colors.white, size: 32),
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
          // 1. PANEL DE CONTROL
          Tooltip(
            message: 'Panel de Control POS',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: isTablet ? 44 : 36,
                height: isTablet ? 44 : 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
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
                  splashRadius: 24,
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // 2. BOTÓN DE TURNO
          Tooltip(
            message: _turnoAbierto ? 'Cerrar Turno' : 'Abrir Turno',
            child: Container(
              width: isTablet ? 44 : 36,
              height: isTablet ? 44 : 36,
              decoration: BoxDecoration(
                color: _turnoAbierto
                    ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                    : const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                icon: Icon(
                  _turnoAbierto ? Icons.lock_open : Icons.lock_outline,
                  color: _turnoAbierto ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                  size: 22,
                ),
                onPressed: _turnoAbierto ? _cerrarTurno : _abrirTurno,
                splashRadius: 24,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 4),

          // 3. BOTÓN DE INVENTARIO
          Tooltip(
            message: 'Ir a Gestión de Inventario',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: isTablet ? 44 : 36,
                    height: isTablet ? 44 : 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
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
                            builder: (context) => InventoryScreen(
                                usuarioLogueado: widget.usuarioLogueado!),
                          ),
                        );
                      },
                      splashRadius: 24,
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
          ),
          const SizedBox(width: 4),

          // 4. BOTÓN BCV
          Tooltip(
            message: 'Tasa oficial BCV (Haz clic para actualizar)',
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedScale(
                scale: cargandoBcv ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: InkWell(
                  onTap: () => ref.read(bcvProvider).actualizarTasa(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    margin: const EdgeInsets.only(left: 4, right: 8),
                    decoration: BoxDecoration(
                      color: cargandoBcv
                          ? Colors.white.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: const Color(0xFF10B981),
                            ),
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

  // ============================================================
  // LAYOUTS (continúa en Parte 2)
  // ============================================================
  Widget _buildDesktopTabletLayout(dynamic cartState, int crossAxisCount, double childAspectRatio) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: _buildCatalogPanel(cartState, crossAxisCount, childAspectRatio),
        ),
        Container(
          width: 380,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(left: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(-2, 0))],
          ),
          child: _buildCartSidebarDesktop(cartState),
        ),
      ],
    );
  }

    // ============================================================
  // LAYOUTS (continuación)
  // ============================================================

  Widget _buildCatalogPanel(dynamic cartState, int crossAxisCount, double childAspectRatio) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    return Padding(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        children: [
          _buildSearchBar(isMobile),
          const SizedBox(height: 16),
          _buildCategoryChips(), // <--- fondo mejorado
          const SizedBox(height: 16),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _cargarProductosDesdeIsar,
              child: _productosFiltrados.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: const Center(
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
                _buildCategoryChips(), // <--- fondo mejorado
                const SizedBox(height: 12),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _cargarProductosDesdeIsar,
                    child: _productosFiltrados.isEmpty
                        ? SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.5,
                              child: const Center(
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

  // ============================================================
  // CARRITO – SIDEBAR (ESCRITORIO)
  // ============================================================
  Widget _buildCartSidebarDesktop(dynamic cartState) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🛒 Orden Activa',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                  if (cartState.items.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${cartState.items.length} ítems',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
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
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_outlined, size: 48, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 8),
                      Text('Carrito vacío', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                    ],
                  ),
                )
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(cartItem.producto.nombre,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 4),
                                Text(
                                  '${cartItem.cantidad.toStringAsFixed(cartItem.producto.esPesado ? 3 : 0)} x \$${cartItem.producto.precioUnidad.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF059669)),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFFEF4444)),
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
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL USD',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF64748B))),
                  Text(
                    '\$${cartState.total.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Color(0xFF059669)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL BOLÍVARES',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF94A3B8))),
                  Text(
                    'Bs. ${(cartState.total * (ref.read(bcvProvider).tasa > 0 ? ref.read(bcvProvider).tasa : 1)).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3B82F6)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cartState.items.isEmpty
                        ? Colors.grey.shade300
                        : const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                    side: cartState.items.isEmpty
                        ? null
                        : const BorderSide(color: Color(0xFF059669), width: 1.5),
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

  // ============================================================
  // CARRITO – RESUMEN FIJO (MÓVIL)
  // ============================================================
  Widget _buildFixedCartSummary(dynamic cartState) {
    final isTablet = ResponsiveHelper.isTablet(context);
    final double barHeight = isTablet ? 140.0 : 120.0;

    return Container(
      height: barHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300, width: isTablet ? 2 : 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
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
                    color: const Color(0xFF0F172A),
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
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
                ),
                child: Text(
                  '${cartState.items.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFDC2626)),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTablet ? 20 : 14),
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

  // ============================================================
  // BOTTOM SHEET DEL CARRITO (MÓVIL)
  // ============================================================
  void _openCartBottomSheet(BuildContext context, dynamic cartState) {
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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mi Carrito',
                      style: TextStyle(
                        fontSize: isTablet ? 28 : 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
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
                          icon: const Icon(Icons.close_rounded, size: 28),
                          splashRadius: 28,
                          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(thickness: 2),
                const SizedBox(height: 16),
                Expanded(
                  child: cartState.items.isEmpty
                      ? const Center(
                          child: Text(
                            'El carrito está vacío',
                            style: TextStyle(fontSize: 18, color: Color(0xFF94A3B8)),
                          ),
                        )
                      : ListView.separated(
                          itemCount: cartState.items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final cartItem = cartState.items[index];
                            final double subtotal =
                                cartItem.producto.precioUnidad * cartItem.cantidad.toDouble();
                            return Container(
                              padding: EdgeInsets.all(isTablet ? 20 : 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFCBD5E1),
                                  width: isTablet ? 2 : 1.5,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cartItem.producto.nombre,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isTablet ? 20 : 16,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          '${cartItem.cantidad.toStringAsFixed(cartItem.producto.esPesado ? 3 : 0)} x \$${cartItem.producto.precioUnidad.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: isTablet ? 16 : 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '\$${subtotal.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 20 : 17,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  InkWell(
                                    onTap: () => ref.read(cartProvider.notifier).eliminarItem(index),
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      padding: EdgeInsets.all(isTablet ? 12 : 10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEE2E2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.red.shade200),
                                      ),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Colors.redAccent,
                                        size: isTablet ? 28 : 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                const Divider(thickness: 2),
                const SizedBox(height: 12),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL USD',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 20 : 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        Text(
                          '\$${cartState.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 30 : 20,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL BOLÍVARES',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 18 : 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        Text(
                          'Bs. ${(cartState.total * (ref.read(bcvProvider).tasa > 0 ? ref.read(bcvProvider).tasa : 1)).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isTablet ? 22 : 14,
                            color: Color(0xFF3B82F6),
                          ),
                        ),
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
                            const SizedBox(width: 16),
                            Text(
                              'COBRAR ORDEN',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 24 : 18,
                                letterSpacing: 1.0,
                              ),
                            ),
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

  // ============================================================
  // SEARCH BAR (CORREGIDA)
  // ============================================================
  Widget _buildSearchBar(bool isMobile) {
    final isTablet = ResponsiveHelper.isTablet(context);
    return SizedBox(
      height: 46,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (_) => _filtrarProductos(),
        decoration: InputDecoration(
          hintText: 'Buscar por nombre / código (F2)...',
          hintStyle: TextStyle(
            fontSize: isTablet ? 18 : 14,
            color: const Color(0xFF94A3B8),
          ),
          prefixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 28, color: Color(0xFF475569)),
                  tooltip: 'Escanear código de barras',
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _scanBarcode();
                  },
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.search, size: 22, color: Color(0xFF64748B)),
            ],
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, size: 18),
            onPressed: () {
              _searchController.clear();
              _filtrarProductos();
            },
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 14),
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: const Color(0xFFCBD5E1),
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

  // ============================================================
  // CATEGORY CHIPS – CON FONDO MEJORADO  <--- CAMBIO AQUÍ
  // ============================================================
  Widget _buildCategoryChips() {
    final isTablet = ResponsiveHelper.isTablet(context);
    final double height = isTablet ? 60 : 48;

    return Container(
      height: height + 16,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85), // <--- fondo semitransparente
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
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
        ),
      ),
    );
  }
}

// ============================================================
// WIDGETS AUXILIARES
// ============================================================
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
    final bool isTablet = ResponsiveHelper.isTablet(context);

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (widget.esSeleccionada) {
      backgroundColor = esStockBajo ? const Color(0xFFEF4444) : const Color(0xFF10B981);
      borderColor = backgroundColor;
      textColor = Colors.white;
    } else {
      backgroundColor = _isHovered ? const Color(0xFFF1F5F9) : Colors.white;
      borderColor = _isHovered ? const Color(0xFF94A3B8) : const Color(0xFFCBD5E1);
      textColor = const Color(0xFF334155);
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
            boxShadow: widget.esSeleccionada
                ? [
                    BoxShadow(
                      color: (esStockBajo ? Colors.red : const Color(0xFF10B981))
                          .withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esStockBajo) ...[
                Icon(Icons.warning_amber_rounded,
                    size: 16,
                    color: widget.esSeleccionada ? Colors.white : Colors.amber),
                const SizedBox(width: 4),
              ] else if (widget.esSeleccionada) ...[
                const Icon(Icons.check_circle, size: 16, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                widget.categoria,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: widget.esSeleccionada ? FontWeight.bold : FontWeight.w500,
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

// ============================================================
// PRODUCT CARD
// ============================================================
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
        curve: Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.stockBajo
                      ? const Color(0xFFFCA5A5)
                      : (isTablet ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0)),
                  width: widget.stockBajo ? 2 : (isTablet ? 2.5 : 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isTablet ? 0.08 : 0.04),
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: widget.producto.imagenUrl.isNotEmpty
                                ? Image.network(
                                    widget.producto.imagenUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.inventory_2, size: 40, color: Color(0xFF3B82F6)),
                                  )
                                : const Icon(Icons.inventory_2, size: 40, color: Color(0xFF3B82F6)),
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
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                widget.producto.esPesado ? 'Balanza' : 'Unidad',
                                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
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
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Cód: ${widget.producto.codigoBarras}',
                            style: TextStyle(
                              fontSize: widget.isMobile ? 9 : (isTablet ? 12 : 10),
                              color: const Color(0xFF94A3B8),
                            ),
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
                                  color: widget.stockBajo
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                                ),
                                child: Text(
                                  'Stock: ${widget.producto.stock}',
                                  style: TextStyle(
                                    fontSize: widget.isMobile ? 9 : (isTablet ? 12 : 10),
                                    fontWeight: FontWeight.w600,
                                    color: widget.stockBajo
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

// ============================================================
// SKELETON LOADER
// ============================================================
class _ProductCardSkeleton extends StatelessWidget {
  const _ProductCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                  Container(height: 14, width: double.infinity, color: const Color(0xFFF1F5F9)),
                  Container(height: 10, width: 80, color: const Color(0xFFF1F5F9)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 16, width: 60, color: const Color(0xFFF1F5F9)),
                      Container(height: 14, width: 70, color: const Color(0xFFF1F5F9)),
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

// ============================================================
// DIÁLOGO DEL ESCÁNER DE CÓDIGO DE BARRAS
// ============================================================
class _BarcodeScannerDialog extends StatefulWidget {
  const _BarcodeScannerDialog();

  @override
  State<_BarcodeScannerDialog> createState() => _BarcodeScannerDialogState();
}

class _BarcodeScannerDialogState extends State<_BarcodeScannerDialog> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    torchEnabled: false,
  );
  bool _isTorchOn = false;
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Cámara
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              if (_isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  _isProcessing = true;
                  Navigator.of(context).pop(rawValue);
                  break;
                }
              }
              Future.delayed(const Duration(milliseconds: 500), () {
                _isProcessing = false;
              });
            },
          ),

          // Marco de escaneo
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF10B981), width: 4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🔍 Centra el código',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.black45, blurRadius: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Botones superior (Linterna y Cerrar)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 28,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isTorchOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () {
                      setState(() {
                        _isTorchOn = !_isTorchOn;
                      });
                      _controller.toggleTorch();
                    },
                    splashRadius: 28,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                ),
              ],
            ),
          ),

          // Instrucción inferior
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Apunta la cámara al código de barras',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}