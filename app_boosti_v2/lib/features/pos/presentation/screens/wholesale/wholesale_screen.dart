// lib/features/pos/presentation/screens/wholesale/wholesale_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:app_boosti_v2/features/pos/presentation/screens/wholesale/wholesale_history_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/producto_entity.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../../domain/permissions/roles.dart';
import '../../providers/wholesale/wholesale_cart_provider.dart';
import '../../providers/wholesale/wholesale_filter_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/appbar.dart';
import '../../widgets/common/filtro_chip_template.dart';
import '../../widgets/common/glass_search_bar.dart';
import '../../widgets/common/segmented_toggle.dart';
import '../../widgets/wholesale/wholesale_product_card.dart';
import '../../widgets/wholesale/wholesale_quantity_dialog.dart';
import 'wholesale_cart_screen.dart';

class WholesaleScreen extends ConsumerStatefulWidget {
  final UsuarioEntity? usuarioLogueado;

  const WholesaleScreen({super.key, this.usuarioLogueado});

  @override
  ConsumerState<WholesaleScreen> createState() => _WholesaleScreenState();
}

class _WholesaleScreenState extends ConsumerState<WholesaleScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════════════
  // BUILD
  // ════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    // ── Validación de rol ──
    final usuario = widget.usuarioLogueado;
    if (usuario != null) {
      final role = UserRole.fromString(usuario.rol);
      final autorizado = role == UserRole.admin ||
          role == UserRole.supervisor ||
          role == UserRole.cajero;
      if (!autorizado) {
        return _buildAccesoDenegado(colorScheme);
      }
    }

    // ── Datos ──
    final productosFiltrados = ref.watch(wholesaleFilteredProductsProvider);
    final filterState = ref.watch(wholesaleFilterProvider);
    final categorias = ref.watch(wholesaleCategoriesProvider);
    final productosBase = ref.watch(wholesaleBaseProductsProvider);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Ventas al Mayor',
        showBackButton: true,
        actions: [
          IconButton(
            tooltip: 'Historial de ventas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WholesaleHistoryScreen(),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded, size: 22),
            color: Colors.white,
          ),
          _buildCartButton(context),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Column(
              children: [
                // ── Buscador ──
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 12 : 20,
                    12,
                    isMobile ? 12 : 20,
                    8,
                  ),
                  child: GlassSearchBar(
                    hint: 'Buscar por nombre, código o marca…',
                    controller: _searchController,
                    onChanged: (v) => ref
                        .read(wholesaleFilterProvider.notifier)
                        .setSearch(v),
                    accentColor: colorScheme.primary,
                  ),
                ),

                // ── Filtros ──
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : 20,
                  ),
                  child: _buildFiltros(categorias),
                ),

                const SizedBox(height: 12),

                // ── Contenido ──
                Expanded(
                  child: _buildContenido(
                    productosFiltrados: productosFiltrados,
                    productosBase: productosBase,
                    filterState: filterState,
                    isMobile: isMobile,
                    isTablet: isTablet,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CARRITO
  // ════════════════════════════════════════════════════════════════

  Widget _buildCartButton(BuildContext context) {
    final cartState = ref.watch(wholesaleCartProvider);
    final itemCount = cartState.cantidadItems;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip: 'Ver carrito',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const WholesaleCartScreen(),
              ),
            );
          },
          icon: const Icon(Icons.shopping_cart_rounded, size: 22),
          color: Colors.white,
        ),
        if (itemCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 18),
              child: Text(
                '$itemCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // FILTROS
  // ════════════════════════════════════════════════════════════════

  Widget _buildFiltros(List<String> categorias) {
    final filterState = ref.watch(wholesaleFilterProvider);
    final notifier = ref.read(wholesaleFilterProvider.notifier);
    final productosFiltrados = ref.watch(wholesaleFilteredProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Chips horizontal scroll ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              FiltroChip(
                label: 'Todas',
                icon: Icons.apps_rounded,
                color: const Color(0xFF3B82F6),
                selected: filterState.categoriaSeleccionada == null,
                size: FiltroChipSize.small,
                onTap: () => notifier.setCategoria(null),
              ),
              const SizedBox(width: 8),
              for (final cat in categorias) ...[
                FiltroChip(
                  label: cat,
                  icon: Icons.category_rounded,
                  color: const Color(0xFF8B5CF6),
                  selected: filterState.categoriaSeleccionada == cat,
                  size: FiltroChipSize.small,
                  onTap: () => notifier.setCategoria(cat),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                width: 1,
                height: 24,
                color: Colors.grey.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 8),
              for (final f in WholesaleStockFilter.values) ...[
                FiltroChip(
                  label: f.label,
                  icon: _iconoStock(f),
                  color: _colorStock(f),
                  selected: filterState.stockFilter == f,
                  size: FiltroChipSize.small,
                  onTap: () => notifier.setStockFilter(f),
                ),
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),

        const SizedBox(height: 10),

        // ── Contador + toggle grid/lista ──
        Row(
          children: [
            Expanded(
              child: Text(
                '${productosFiltrados.length} productos',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            SegmentedToggle<bool>(
              selected: filterState.esGrid,
              accentColor: const Color(0xFF3B82F6),
              onChanged: (v) => notifier.setEsGrid(v),
              items: const [
                SegmentedToggleItem(
                  value: true,
                  label: 'Grid',
                  icon: Icons.grid_view_rounded,
                ),
                SegmentedToggleItem(
                  value: false,
                  label: 'Lista',
                  icon: Icons.view_list_rounded,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  IconData _iconoStock(WholesaleStockFilter f) {
    switch (f) {
      case WholesaleStockFilter.todos:
        return Icons.inventory_2_outlined;
      case WholesaleStockFilter.conStock:
        return Icons.check_circle_outline_rounded;
      case WholesaleStockFilter.stockBajo:
        return Icons.warning_amber_rounded;
      case WholesaleStockFilter.sinStock:
        return Icons.block_rounded;
    }
  }

  Color _colorStock(WholesaleStockFilter f) {
    switch (f) {
      case WholesaleStockFilter.todos:
        return const Color(0xFF64748B);
      case WholesaleStockFilter.conStock:
        return const Color(0xFF10B981);
      case WholesaleStockFilter.stockBajo:
        return const Color(0xFFF59E0B);
      case WholesaleStockFilter.sinStock:
        return const Color(0xFFEF4444);
    }
  }

  // ════════════════════════════════════════════════════════════════
  // CONTENIDO (con animación Grid ↔ Lista)
  // ════════════════════════════════════════════════════════════════

  Widget _buildContenido({
    required List<ProductoEntity> productosFiltrados,
    required List<ProductoEntity> productosBase,
    required WholesaleFilterState filterState,
    required bool isMobile,
    required bool isTablet,
  }) {
    // ── Empty state ──
    if (productosFiltrados.isEmpty) {
      return _buildEmptyState(hayProductosBase: productosBase.isNotEmpty);
    }

    // ── ✅ AnimatedSwitcher con KeyedSubtree para detectar cambio ──
    //    Duración: 280ms — suave pero responsivo.
    //    LayoutBuilder obliga a que el switcher conozca las constraints.
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (currentChild, previousChildren) {
            return Stack(
              children: [
                ...previousChildren,
                if (currentChild != null) currentChild,
              ],
            );
          },
          transitionBuilder: (child, animation) {
            // Fade + Scale suave (de 0.96 → 1.0)
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: filterState.esGrid
              ? KeyedSubtree(
                  key: const ValueKey('wholesale_grid'),
                  child: _buildGrid(
                    productosFiltrados,
                    isMobile,
                    isTablet,
                  ),
                )
              : KeyedSubtree(
                  key: const ValueKey('wholesale_list'),
                  child: _buildLista(productosFiltrados),
                ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // GRID
  // ════════════════════════════════════════════════════════════════

  Widget _buildGrid(
    List<ProductoEntity> productos,
    bool isMobile,
    bool isTablet,
  ) {
    // ── Columnas según breakpoint ──
    final crossAxisCount = isMobile
        ? 2
        : isTablet
            ? 3
            : 4;

    // ── Aspect ratio más ALTO (cards más verticales) porque la card
    //    ahora tiene imagen grande + nombre 2 líneas + precio + stock.
    final childAspectRatio = isMobile
        ? 0.62
        : isTablet
            ? 0.72
            : 0.78;

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 12 : 20,
        4,
        isMobile ? 12 : 20,
        20,
      ),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: productos.length,
      itemBuilder: (context, i) {
        final p = productos[i];
        return WholesaleProductCard(
          producto: p,
          index: i,
          variant: WholesaleCardVariant.grid,
          onTap: () => _agregarProducto(context, p),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // LISTA (sin SizedBox fijo → sin overflow)
  // ════════════════════════════════════════════════════════════════

  Widget _buildLista(List<ProductoEntity> productos) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: productos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final p = productos[i];
        return WholesaleProductCard(
          producto: p,
          index: i,
          variant: WholesaleCardVariant.list,
          onTap: () => _agregarProducto(context, p),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════
  // EMPTY STATE
  // ════════════════════════════════════════════════════════════════

  Widget _buildEmptyState({required bool hayProductosBase}) {
    final colorScheme = Theme.of(context).colorScheme;
    final mensaje = hayProductosBase
        ? 'No hay productos que coincidan con los filtros'
        : 'Aún no hay productos configurados para venta al mayor';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 72,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            if (!hayProductosBase) ...[
              const SizedBox(height: 8),
              Text(
                'Ve a Inventario y activa la opción "Permite venta al mayor" '
                'en los productos que quieras vender al mayor.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // ACCESO DENEGADO
  // ════════════════════════════════════════════════════════════════

  Widget _buildAccesoDenegado(ColorScheme colorScheme) {
    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Ventas al Mayor',
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_rounded,
              size: 64,
              color: colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Acceso restringido',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Solo administradores, supervisores\ny cajeros pueden acceder.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // AGREGAR PRODUCTO
  // ════════════════════════════════════════════════════════════════

  Future<void> _agregarProducto(
    BuildContext context,
    ProductoEntity producto,
  ) async {
    final result = await WholesaleQuantityDialog.show(
      context,
      producto: producto,
    );

    if (result == null || !mounted) return;

    try {
      await ref.read(wholesaleCartProvider.notifier).agregarProducto(
            producto: producto,
            cantidad: result.cantidad,
            unidadEmpaque: result.unidadEmpaque,
          );

      if (!mounted) return;

      if (kDebugMode) {
        debugPrint(
          '🛒 Agregado: ${producto.nombre} · '
          '${result.cantidad} ${result.unidadEmpaque == 'unidad' ? 'u.' : 'bultos'}',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${producto.nombre} agregado · '
                  '${result.cantidad} '
                  '${result.unidadEmpaque == 'unidad' ? 'u.' : 'bultos'}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al agregar: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}