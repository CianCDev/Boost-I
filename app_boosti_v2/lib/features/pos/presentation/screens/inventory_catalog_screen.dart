// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'package:app_boosti_v2/features/pos/domain/models/product_item.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/catalog/catalog_actions.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/catalog/catalog_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../controllers/cart_controller.dart';
import '../providers/catalog_provider.dart';
import '../providers/bcv_provider.dart';
import '../providers/catalog/view_mode_provider.dart';
import '../widgets/catalog/category_chips.dart';
import '../widgets/catalog/fixed_cart_summary.dart';
import '../widgets/catalog/product_card.dart';
import '../widgets/catalog/product_card_skeleton.dart';
import '../widgets/catalog/search_bar.dart';
import '../widgets/catalog/cart_sidebar.dart';
import '../widgets/catalog/view_mode_toggle.dart';
import '../widgets/catalog/product_list_tile.dart';
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
        } catch (_) {}
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
          // ✅ Usamos sumarCantidad (ya existe en CartNotifier)
          cartNotifier.sumarCantidad(existingIndex, cantidad);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${producto.nombre} +${cantidad.toStringAsFixed(0)} unidades'),
              duration: const Duration(milliseconds: 800),
              backgroundColor: mintLeaf,
            ),
          );
        } else {
          cartNotifier.agregarItem(producto as ProductItem, cantidad);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${producto.nombre} agregado al carrito'),
              duration: const Duration(milliseconds: 800),
              backgroundColor: mintLeaf,
            ),
          );
        }
      }
      return;
    }

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
    await actions.mostrarModalCobro(context, widget.usuarioLogueado);
  }

  @override
  Widget build(BuildContext context) {
    final contenido = _buildBody(context);

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: CatalogAppBar(usuarioLogueado: widget.usuarioLogueado),
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
            itemBuilder: (_, _) => const ProductCardSkeleton(),
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

  Widget _buildCatalogPanel(int crossAxisCount, double childAspectRatio) {
    final catalogState = ref.watch(catalogProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;
    final refreshCounter = ref.watch(refreshCatalogCounterProvider);
    final viewMode = ref.watch(viewModeProvider);

    return Padding(
      padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
      child: Column(
        children: [
          CatalogSearchBar(
            focusNode: _searchFocusNode,
            onScanPressed: _scanBarcode,
          ),
          const SizedBox(height: 12),
          const CategoryChips(),
          // ✅ Barra de herramientas con el toggle
          const ViewModeToggle(),
          const SizedBox(height: 8),
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
                  : viewMode == ViewMode.grid
                      ? GridView.builder(
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
                                  onTap: () {
                                    final actions = ref.read(catalogActionsProvider);
                                    actions.mostrarModalCantidad(producto, context, factor: 1.0);
                                  },
                                  isMobile: isMobile,
                                  index: index,
                                  animationController: _animationController,
                                );
                              },
                            );
                          },
                        )
                      : ListView.builder(
                          key: ValueKey(refreshCounter),
                          padding: const EdgeInsets.only(bottom: 40),
                          itemCount: catalogState.productosFiltrados.length,
                          itemBuilder: (context, index) {
                            final producto = catalogState.productosFiltrados[index];
                            return FutureBuilder<double>(
                              future: _isarService.obtenerStockTotalPorProducto(producto.id),
                              builder: (context, snapshot) {
                                final stockTotal = snapshot.data ?? 0.0;
                                final bool stockBajo = stockTotal <= producto.stockMinimo;
                                return ProductListTile(
                                  producto: producto,
                                  stockBajo: stockBajo,
                                  onTap: () {
                                    final actions = ref.read(catalogActionsProvider);
                                    actions.mostrarModalCantidad(producto, context, factor: 1.0);
                                  },
                                  index: index,
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