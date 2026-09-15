// lib/features/pos/presentation/screens/inventory_catalog_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/catalog/catalog_actions.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/catalog/catalog_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import '../utils/keyboard_shortcut_helper.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../controllers/cart_controller.dart';
import '../controllers/cart_sessions_controller.dart';
import '../controllers/panel_controller.dart';
import '../providers/catalog_provider.dart';
import '../providers/catalog/recent_products_provider.dart';
import '../providers/bcv_provider.dart';
import '../providers/usuario_provider.dart';
import '../providers/panel/panel_provider.dart';
import '../widgets/catalog/category_chips.dart';
import '../widgets/catalog/cart/fixed_cart_summary.dart';
import '../widgets/catalog/product_card.dart';
import '../widgets/catalog/product_card_skeleton.dart';
import '../widgets/catalog/search_bar.dart';
import '../widgets/catalog/cart/cart_sidebar.dart';
import '../widgets/catalog/cart/parked_carts_dialog.dart';
import '../widgets/catalog/cart/save_cart_dialog.dart';
import '../widgets/catalog/top_products_widget.dart';
import '../widgets/catalog/view_mode_toggle.dart';
import '../widgets/catalog/product_list_tile.dart';
import '../widgets/printer_selection_widget.dart';
import '../widgets/shared/barcode_scanner_dialog.dart';
import '../utils/responsive_helper.dart';
import '../services/scale_service.dart';
import '../providers/themes/app_colors.dart';

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
  ConsumerState<InventoryCatalogScreen> createState() =>
      _InventoryCatalogScreenState();
}

class _InventoryCatalogScreenState extends ConsumerState<InventoryCatalogScreen>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final ScaleService _scaleService = ScaleService();
  final PanelProvider _panelProvider = PanelProvider();
  final PanelController _panelController = PanelController();
  late AnimationController _animationController;
  final FocusNode _searchFocusNode = FocusNode();

  StreamSubscription<double>? _weightSubscription;
  Timer? _pollingTimer;

  /// Referencia al Navigator del panel de productos top (F3).
  /// Se usa para poder cerrarlo con otra pulsación de F3.
  NavigatorState? _topProductsNavigator;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorWarning = Color(0xFFF59E0B);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  bool get wantKeepAlive => true;

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
      // Cargar carritos parkeados del usuario
      final usuario = ref.read(usuarioActualProvider);
      if (usuario != null) {
        ref.read(cartSessionsProvider.notifier).cargarSesiones(usuario.id);
      }
    });

    _iniciarPolling();
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_manejarTecladoFisico);
    _pollingTimer?.cancel();
    _scaleService.dispose();
    _weightSubscription?.cancel();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _iniciarPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(minutes: 10), (timer) async {
      if (mounted) {
        try {
          debugPrint('⏰ [Polling] Ejecutando recarga en segundo plano...');
          await ref.read(catalogProvider.notifier).recargarEnSegundoPlano();
        } catch (e) {
          debugPrint('⚠️ [Polling] Error: $e');
        }
      }
    });
  }

  // ════════════════════════════════════════════════════════════════
  // ATAJOS DE TECLADO
  // ════════════════════════════════════════════════════════════════

 bool _manejarTecladoFisico(KeyEvent event) {
  if (event is! KeyDownEvent) return false;

  final key = event.logicalKey;

  // ═══ Escape: SIEMPRE se procesa ═══
  // Necesario para poder cerrar modales/paneles desde el teclado.
  if (key == LogicalKeyboardKey.escape) {
    if (_topProductsNavigator != null) {
      _topProductsNavigator!.pop();
      return true;
    }
    // Si hay un campo de texto enfocado, primero soltamos el foco.
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
      return true;
    }
    // Si estamos dentro de un modal, no interceptamos Escape
    // para que el modal lo maneje (ej. cerrar el dialog).
    if (_hayRutaEncima || _hayTextFieldEnFoco) {
      return false;
    }
    // Esc en el catálogo limpia el carrito (con confirmación).
    final cartState = ref.read(cartProvider);
    if (cartState.items.isNotEmpty) {
      _confirmarLimpiarCarrito();
      return true;
    }
    return false;
  }

  // ═══ Otros atajos: NO procesar si hay modal o input activo ═══
  // Esto evita que los números/F-keys rompan la escritura dentro
  // de QuantityDialog, CobrarDialog, SaveCartDialog, PrinterSelectionDialog, etc.
  if (_hayRutaEncima || _hayTextFieldEnFoco) {
    return false;
  }

  // ───── F-keys ─────
  if (key == LogicalKeyboardKey.f1) {
    _mostrarAyudaAtajos();
    return true;
  }
  if (key == LogicalKeyboardKey.f2) {
    _toggleSearchFocus();
    return true;
  }
  if (key == LogicalKeyboardKey.f3) {
    _togglePanelProductos();
    return true;
  }
  if (key == LogicalKeyboardKey.f4) {
    _abrirModalImpresoras();
    return true;
  }
  if (key == LogicalKeyboardKey.f5) {
    _recargarCatalogo();
    return true;
  }
  if (key == LogicalKeyboardKey.f8) {
    _parkearCarritoActual();
    return true;
  }
  if (key == LogicalKeyboardKey.f9) {
    _abrirCarritosEnEspera();
    return true;
  }
  if (key == LogicalKeyboardKey.f12) {
    final cartState = ref.read(cartProvider);
    if (cartState.total > 0) _mostrarModalCobro();
    return true;
  }

  // ───── Delete ─────
  if (key == LogicalKeyboardKey.delete) {
    final cartState = ref.read(cartProvider);
    if (cartState.items.isNotEmpty) {
      _confirmarLimpiarCarrito();
      return true;
    }
    return false;
  }

  // ───── Hotkeys 1-9 ─────
    final int? numero = KeyboardShortcutHelper.keyToDigit(key);
  if (numero != null) {
    // ✅ Si el buscador tiene foco, los números se escriben allí.
    if (_searchFocusNode.hasFocus) return false;
    // ✅ Si el panel de top products está abierto, no disparar.
    if (_topProductsNavigator != null) return false;
    _agregarProductoReciente(numero);
    return true;
  }

  return false;
}

// ════════════════════════════════════════════════════════════════
// DETECCIÓN DE CONTEXTO
// ════════════════════════════════════════════════════════════════

/// True si hay un dialog, bottom sheet u otra ruta encima del catálogo.
///
/// Funciona porque `showDialog`, `showGeneralDialog` y `showModalBottomSheet`
/// apilan una nueva `ModalRoute` en el navigator del `context` que se les pasa.
bool get _hayRutaEncima {
  try {
    final route = ModalRoute.of(context);
    return route != null && !route.isCurrent;
  } catch (_) {
    return false;
  }
}

/// True si hay un `TextField` / `TextFormField` enfocado que NO sea
/// nuestro buscador del catálogo.
///
/// Cuando el usuario hace tap en un input de un diálogo, el
/// `FocusManager` apunta al `EditableText` interno del `TextField`.
/// Detectamos eso para no secuestrar las teclas numéricas.
bool get _hayTextFieldEnFoco {
  final primaryFocus = FocusManager.instance.primaryFocus;
  if (primaryFocus == null) return false;
  if (primaryFocus == _searchFocusNode) return false;

  final ctx = primaryFocus.context;
  if (ctx == null) return false;

  // Los TextField/TextFormField de Flutter montan internamente
  // un `EditableText`. El context del FocusNode suele apuntar al
  // `EditableText` o al `TextField`, así que chequeamos ambos.
  final widget = ctx.widget;
  final tipo = widget.runtimeType.toString();
  if (widget is EditableText) return true;
  if (tipo == 'EditableText') return true;
  if (tipo == 'TextField') return true;
  if (tipo == 'TextFormField') return true;

  // Fallback: buscar el ancestro `EditableText` más cercano.
  try {
    final el = ctx as Element;
    final editable = el.findAncestorWidgetOfExactType<EditableText>();
    if (editable != null) return true;
  } catch (_) {
    // ignore
  }

  return false;
}


  // ════════════════════════════════════════════════════════════════
  // ACCIONES DE ATAJOS
  // ════════════════════════════════════════════════════════════════

  void _toggleSearchFocus() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    } else {
      _searchFocusNode.requestFocus();
    }
  }

  /// F3 — Abre o cierra el panel de productos destacados.
  Future<void> _togglePanelProductos() async {
    // Si ya está abierto, lo cerramos.
    if (_topProductsNavigator != null) {
      _topProductsNavigator!.pop();
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: Duration.zero,
      pageBuilder: (dialogContext, _, __) {
        _topProductsNavigator = Navigator.of(dialogContext);
        return TopProductsWidget(
          onClose: () {
            if (_topProductsNavigator?.canPop() ?? false) {
              _topProductsNavigator!.pop();
            }
          },
        );
      },
    );

    // Cuando el dialog se cierra, limpiamos la referencia.
    _topProductsNavigator = null;
  }

  /// F4 — Abre el diálogo de selección de impresora.
  Future<void> _abrirModalImpresoras() async {
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const PrinterSelectionDialog(),
    );
  }

  Future<void> _recargarCatalogo() async {
    _snack('Recargando catálogo...', _colorPrimary);
    try {
      await ref.read(catalogProvider.notifier).recargarDesdeSupabase();
      ref.read(recentProductsRefreshProvider.notifier).state++;
      _snack('Catálogo actualizado', _colorSuccess);
    } catch (e) {
      _snack('Error al recargar: $e', _colorDanger);
    }
  }

  Future<void> _parkearCarritoActual() async {
    final cartState = ref.read(cartProvider);
    if (cartState.items.isEmpty) {
      _snack('El carrito está vacío', _colorWarning);
      return;
    }
    final count = ref.read(cartSessionsProvider).count;
    if (count >= kMaxCarritosEnEspera) {
      _snack(
        'Límite alcanzado: máximo $kMaxCarritosEnEspera carritos en espera',
        _colorDanger,
      );
      return;
    }
    await SaveCartDialog.mostrar(context);
  }

  Future<void> _abrirCarritosEnEspera() async {
    await ParkedCartsDialog.mostrar(context);
  }

  Future<void> _agregarProductoReciente(int posicion) async {
    try {
      final productos = await ref.read(recentProductsProvider.future);

      if (productos.isEmpty) {
        _snack('Sin productos recientes', _colorWarning);
        return;
      }
      if (posicion > productos.length) {
        _snack(
          'Solo hay ${productos.length} producto(s) reciente(s)',
          _colorWarning,
        );
        return;
      }

      final entity = productos[posicion - 1];
      final item = _entityToProductItem(entity);
      final cartNotifier = ref.read(cartProvider.notifier);
      final existingIndex = cartNotifier.buscarItemIndex(
        int.tryParse(item.id) ?? -1,
      );

      if (existingIndex != -1) {
        cartNotifier.sumarCantidad(existingIndex, 1.0);
      } else {
        cartNotifier.agregarItem(item, 1.0);
      }

      _snack('$posicion → ${entity.nombre}', _colorSuccess);
    } catch (e) {
      _snack('Error al agregar reciente: $e', _colorDanger);
    }
  }

  ProductItem _entityToProductItem(ProductoEntity e) {
    return ProductItem(
      id: e.supabaseId ?? e.id.toString(),
      nombre: e.nombre,
      codigoBarras: e.codigoBarras,
      categoria: e.categoria,
      precioUnidad: e.precioUnidad,
      esPesado: e.esPesado,
    );
  }

  void _confirmarLimpiarCarrito() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Limpiar carrito'),
        content: const Text(
            '¿Seguro que deseas eliminar todos los productos del carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).limpiarCarrito();
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorDanger,
              foregroundColor: Colors.white,
            ),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }

  void _mostrarAyudaAtajos() {
    showDialog(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final colorScheme = theme.colorScheme;
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _colorPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.keyboard_alt_outlined,
                    color: _colorPrimary),
              ),
              const SizedBox(width: 10),
              const Text('Atajos de teclado'),
            ],
          ),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _AtajoRow(tecla: 'F1', descripcion: 'Mostrar esta ayuda'),
                  _AtajoRow(
                      tecla: 'F2',
                      descripcion: 'Enfocar / soltar el buscador'),
                  _AtajoRow(
                      tecla: 'F3',
                      descripcion: 'Abrir/cerrar productos destacados'),
                  _AtajoRow(
                      tecla: 'F4', descripcion: 'Conectar impresora'),
                  _AtajoRow(tecla: 'F5', descripcion: 'Recargar catálogo'),
                  _AtajoRow(
                      tecla: 'F8',
                      descripcion: 'Poner carrito en espera'),
                  _AtajoRow(
                      tecla: 'F9',
                      descripcion: 'Ver carritos en espera'),
                  _AtajoRow(tecla: 'F12', descripcion: 'Cobrar'),
                  _AtajoRow(
                      tecla: 'Esc',
                      descripcion:
                          'Cerrar panel / limpiar búsqueda / carrito'),
                  _AtajoRow(
                      tecla: 'Delete',
                      descripcion: 'Limpiar carrito'),
                  _AtajoRow(
                      tecla: '1-9',
                      descripcion:
                          'Agregar el N-ésimo producto reciente (con el buscador sin foco)'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style:
                  TextButton.styleFrom(foregroundColor: colorScheme.primary),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // SCAN / COBRO
  // ════════════════════════════════════════════════════════════════

  Future<void> _scanBarcode() async {
    final codigo = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (codigo == null || codigo.isEmpty) return;

    final actions = ref.read(catalogActionsProvider);
    final producto = await actions.buscarProductoPorCodigo(codigo.trim());

    if (producto != null) {
      final factor = ref.read(ultimoFactorProvider);
      final cartNotifier = ref.read(cartProvider.notifier);
      final existingIndex = cartNotifier.buscarItemIndex(producto.id);

      if (producto.esPesado) {
        actions.mostrarModalCantidad(producto, context, factor: factor);
      } else {
        final cantidad = factor > 0 ? factor : 1.0;
        if (existingIndex != -1) {
          cartNotifier.sumarCantidad(existingIndex, cantidad);
          _snack('${producto.nombre} +${cantidad.toStringAsFixed(0)} unidades',
              mintLeaf);
        } else {
          cartNotifier.agregarItem(producto as ProductItem, cantidad);
          _snack('${producto.nombre} agregado al carrito', mintLeaf);
        }
      }
      return;
    }

    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Producto no registrado'),
        content: Text(
            'El código "$codigo" no está registrado.\n¿Qué deseas hacer?'),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: mintLeaf,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, 'create'),
            child: const Text('Crear nuevo producto'),
          ),
        ],
      ),
    );

    if (action == 'create' && mounted) {
      await actions.crearProducto(codigo, context);
    } else if (action == 'affiliate' && mounted) {
      await actions.afiliarCodigo(codigo, context);
    }
  }

  Future<void> _mostrarModalCobro() async {
    final actions = ref.read(catalogActionsProvider);
    await actions.mostrarModalCobro(context, ref.read(usuarioActualProvider));
    // Después de cobrar, invalidar los productos recientes
    ref.read(recentProductsRefreshProvider.notifier).state++;
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return provider.MultiProvider(
      providers: [
        provider.ChangeNotifierProvider<PanelProvider>(
          create: (_) => _panelProvider,
        ),
        provider.Provider<PanelController>.value(value: _panelController),
      ],
      child: _buildScaffold(context),
    );
  }

  Widget _buildScaffold(BuildContext context) {
    final contenido = RepaintBoundary(child: _buildBody(context));

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: CatalogAppBar(
          onScanPressed: _scanBarcode,
          searchFocusNode: _searchFocusNode,
        ),
        body: contenido,
      );
    } else {
      return contenido;
    }
  }

  Widget _buildBody(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final orientation = MediaQuery.of(context).orientation;
    final bool useSidebar = !isMobile &&
        (isTablet ? orientation == Orientation.landscape : true);

    final isLoading =
        ref.watch(catalogProvider.select((state) => state.isLoading));
    final productosFiltrados = ref.watch(
        catalogProvider.select((state) => state.productosFiltrados));

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

    if (isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => const ProductCardSkeleton(),
      );
    }

    if (useSidebar) {
      return Row(
        children: [
          Expanded(
            flex: 7,
            child: _buildCatalogPanel(
                crossAxisCount, childAspectRatio, productosFiltrados),
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
      );
    }

    return Column(
      children: [
        Expanded(
          child: _buildCatalogPanel(
              crossAxisCount, childAspectRatio, productosFiltrados),
        ),
        FixedCartSummary(onCobrar: _mostrarModalCobro),
      ],
    );
  }

  Widget _buildCatalogPanel(int crossAxisCount, double childAspectRatio,
      List<ProductoEntity> productosFiltrados) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final colorScheme = Theme.of(context).colorScheme;

    final isEmpty = productosFiltrados.isEmpty;

    return Padding(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        children: [
          if (!isDesktop) ...[
            CatalogSearchBar(
              focusNode: _searchFocusNode,
              onScanPressed: _scanBarcode,
            ),
            const SizedBox(height: 12),
          ],
          const CategoryChips(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref
                    .read(catalogProvider.notifier)
                    .recargarDesdeSupabase();
                ref.read(recentProductsRefreshProvider.notifier).state++;
              },
              child: isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined,
                              size: 48, color: colorScheme.outline),
                          const SizedBox(height: 12),
                          Text(
                            'No se encontraron productos.',
                            style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  : RepaintBoundary(
                      child: ViewModeToggle(
                        gridChild: GridView.builder(
                          key: const ValueKey('grid'),
                          padding: const EdgeInsets.only(bottom: 40),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: childAspectRatio,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: productosFiltrados.length,
                          itemBuilder: (context, index) {
                            final producto = productosFiltrados[index];
                            final bool stockBajo =
                                producto.stock <= producto.stockMinimo;

                            return ProductCard(
                              producto: producto,
                              stockBajo: stockBajo,
                              onTap: () {
                                final actions =
                                    ref.read(catalogActionsProvider);
                                actions.mostrarModalCantidad(producto, context,
                                    factor: 1.0);
                              },
                              isMobile: isMobile,
                              index: index,
                              animationController: _animationController,
                            );
                          },
                        ),
                        listChild: ListView.builder(
                          key: const ValueKey('list'),
                          padding: const EdgeInsets.only(bottom: 40),
                          itemCount: productosFiltrados.length,
                          itemBuilder: (context, index) {
                            final producto = productosFiltrados[index];
                            final bool stockBajo =
                                producto.stock <= producto.stockMinimo;

                            return ProductListTile(
                              producto: producto,
                              stockBajo: stockBajo,
                              onTap: () {
                                final actions =
                                    ref.read(catalogActionsProvider);
                                actions.mostrarModalCantidad(producto, context,
                                    factor: 1.0);
                              },
                              index: index,
                            );
                          },
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// WIDGET AUXILIAR PARA LA AYUDA DE ATAJOS
// ════════════════════════════════════════════════════════════════

class _AtajoRow extends StatelessWidget {
  final String tecla;
  final String descripcion;

  const _AtajoRow({required this.tecla, required this.descripcion});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              tecla,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              descripcion,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}