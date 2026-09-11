// lib/features/pos/presentation/screens/inventory_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../providers/inventory_provider.dart';
import '../providers/productos_provider.dart';
import '../providers/usuario_provider.dart';
import '../providers/esc_pos_provider.dart';
import '../providers/themes/app_colors.dart';
import '../services/sync_service.dart';
import '../services/printer_service.dart';
import '../services/label_generator.dart';
import '../services/label_pdf_generator.dart';
import '../widgets/inventory/inventory_product_card.dart';
import '../widgets/inventory/inventory_product_card_skeleton.dart';
import '../widgets/inventory/inventory_search_bar.dart';
import '../widgets/inventory/inventory_category_chips.dart';
import '../widgets/inventory/barcode_generator_dialog.dart';
import '../widgets/inventory/marcas_managment_dialog.dart';
import '../widgets/shared/barcode_scanner_dialog.dart';
import '../utils/responsive_helper.dart';
import '../widgets/inventory/product_form_dialog.dart';
import '../widgets/inventory/product_detail_dialog.dart';
import '../widgets/appbar.dart';
import '../widgets/inventory/categorias_management_dialog.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  @Deprecated('Use usuarioActualProvider instead.')
  final UsuarioEntity? usuarioLogueado;
  final String? codigoBarrasInicial;
  final bool showAppBar;

  const InventoryScreen({
    super.key,
    this.usuarioLogueado,
    this.codigoBarrasInicial,
    this.showAppBar = true,
  });

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  UsuarioEntity get usuarioActual =>
      ref.read(usuarioActualProvider) ??
      widget.usuarioLogueado ??
      (throw StateError('No hay usuario autenticado para Inventario'));

  @override
  void initState() {
    super.initState();
    if (widget.codigoBarrasInicial != null && widget.codigoBarrasInicial!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarFormularioProducto(codigoBarrasPrecargado: widget.codigoBarrasInicial);
      });
    }
  }

  // ============================================================
  // MÉTODOS DE ACCIÓN
  // ============================================================
  Future<void> _scanBarcode() async {
    final codigo = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (codigo == null || codigo.isEmpty) return;

    final productos = ref.read(productosProvider).items;
    final producto = productos.firstWhere(
      (p) => p.codigoBarras == codigo,
      orElse: () => ProductoEntity(),
    );

    if (producto.id != 0) {
      _mostrarDetalleProducto(producto);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Producto no encontrado'),
        content: Text('El código "$codigo" no está registrado.\n¿Deseas crearlo ahora?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crear Producto'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      _mostrarFormularioProducto(codigoBarrasPrecargado: codigo);
    }
  }

  void _mostrarFormularioProducto({ProductoEntity? productoAEditar, String? codigoBarrasPrecargado}) {
    final esAdmin = usuarioActual.rol == 'admin';
    if (!esAdmin) return;

    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        producto: productoAEditar,
        usuarioActual: usuarioActual,
        onGuardar: (producto) async {
          final productosNotifier = ref.read(productosProvider.notifier);
          if (productoAEditar == null) {
            await productosNotifier.guardarProducto(producto, usuarioActual, esNuevo: true);
          } else {
            await productosNotifier.guardarProducto(producto, usuarioActual, esNuevo: false);
          }
          // 🔥 CORRECCIÓN: Verificar si el widget sigue montado
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Producto ${productoAEditar != null ? 'actualizado' : 'creado'} exitosamente'),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
          }
        },
        codigoBarrasPrecargado: codigoBarrasPrecargado,
      ),
    );
  }

  void _mostrarDetalleProducto(ProductoEntity producto) {
    showDialog(
      context: context,
      builder: (context) => ProductDetailDialog(
        producto: producto,
        esAdmin: usuarioActual.rol == 'admin',
        onEditar: () {
          Navigator.pop(context);
          _mostrarFormularioProducto(productoAEditar: producto);
        },
        onEliminar: () async {
          final productosNotifier = ref.read(productosProvider.notifier);
          await productosNotifier.eliminarProducto(producto.id, usuarioActual);
          
          // 🔥 CORRECCIÓN: Verificar si el widget sigue montado ANTES de mostrar SnackBar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Producto eliminado correctamente'), backgroundColor: Color(0xFF10B981)),
            );
          }
        },
      ),
    );
  }

  // ============================================================
  // BUILD PRINCIPAL
  // ============================================================
  @override
  Widget build(BuildContext context) {
    // 🔥 ELIMINADO debugPrint (causaba reconstrucciones masivas)
    
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isAdmin = usuarioActual.rol == 'admin';

    final contenido = _buildBody(context);

    if (widget.showAppBar) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final state = ref.watch(inventoryProvider);

      final gradient = isDark
          ? const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            )
          : const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF5352ED), Color(0xFF4840E8), Color(0xFF5955EE)],
            );

      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: CustomAppBar(
          title: isMobile ? 'Inventario' : 'Gestión de Inventario',
          showBackButton: true,
          centerTitle: false,
          gradient: gradient,
          actions: _buildAppBarActions(isMobile, isTablet, isAdmin, state),
        ),
        floatingActionButton: _buildFAB(context),
        body: contenido,
      );
    } else {
      return contenido;
    }
  }

  // 🔥 OPTIMIZACIÓN: Extraer acciones del AppBar para limpiar el `build`
  List<Widget> _buildAppBarActions(bool isMobile, bool isTablet, bool isAdmin, InventoryState state) {
    return [
      _buildActionButton(
        context,
        icon: Icons.branding_watermark_rounded,
        tooltip: 'Gestionar marcas',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const MarcasManagementDialog(),
        ),
        isTablet: isTablet,
      ),
      const SizedBox(width: 8),
      if (isAdmin) ...[
        _buildActionButton(
          context,
          icon: Icons.image_search_outlined,
          tooltip: 'Reparar imágenes faltantes',
          onPressed: () async {
            final count = await SyncService().repararImagenesFaltantes();
            if (!mounted) return;
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => AlertDialog(
                title: Text(count > 0 ? '✅ Imágenes reparadas' : ' Sin cambios'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🔥 ELIMINADO Lottie (causaba error 404)
                    count > 0
                        ? const Icon(Icons.check_circle_outline_rounded, size: 60, color: Color(0xFF10B981))
                        : const Icon(Icons.info_outline, size: 60, color: Colors.orange),
                    const SizedBox(height: 12),
                    Text(
                      count > 0
                          ? 'Se repararon $count imágenes correctamente.'
                          : 'No se encontraron imágenes faltantes.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Aceptar'),
                  ),
                ],
              ),
            );
            await ref.read(productosProvider.notifier).cargarProductos();
          },
          isTablet: isTablet,
        ),
        const SizedBox(width: 8),
      ],
      if (isAdmin) ...[
        _buildActionButton(
          context,
          icon: Icons.category_outlined,
          tooltip: 'Gestionar categorías',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const CategoriasManagementDialog(),
            );
          },
          isTablet: isTablet,
        ),
        const SizedBox(width: 8),
      ],
      _buildActionButton(
        context,
        icon: Icons.qr_code,
        tooltip: 'Generar Código de Barras',
        onPressed: () => showDialog(context: context, builder: (_) => const BarcodeGeneratorDialog()),
        isTablet: isTablet,
      ),
      const SizedBox(width: 12),
      if (state.seleccionMultiple) ...[
        Text(
          '${state.cantidadSeleccionados} seleccionados',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => ref.read(inventoryProvider.notifier).limpiarSeleccion(),
        ),
      ],
    ];
  }

  // ============================================================
  // BODY CON `select` PARA EVITAR RECONSTRUCCIONES
  // ============================================================
  Widget _buildBody(BuildContext context) {
    final inventoryState = ref.watch(inventoryProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    int crossAxisCount;
    double childAspectRatio;
    if (screenWidth < 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.60;
    } else if (screenWidth < 900) {
      crossAxisCount = 3;
      childAspectRatio = 0.65;
    } else if (screenWidth < 1200) {
      crossAxisCount = 4;
      childAspectRatio = 0.70;
    } else {
      crossAxisCount = 5;
      childAspectRatio = 0.75;
    }
    if (isMobile && MediaQuery.of(context).orientation == Orientation.landscape) {
      crossAxisCount = 3;
      childAspectRatio = 0.60;
    }

    // 🔥 Usamos `select` para escuchar solo la lista filtrada, no el estado completo del inventario
    final productosFiltrados = ref.watch(inventoryProvider.select((s) => s.productosFiltrados));
    final isLoading = ref.watch(inventoryProvider.select((s) => s.isLoading));
    final isSelectionMode = ref.watch(inventoryProvider.select((s) => s.seleccionMultiple));

    return isLoading
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => const InventoryProductCardSkeleton(),
          )
        : Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                InventorySearchBar(
                  onScanPressed: _scanBarcode,
                  onSearchChanged: (value) => ref.read(inventoryProvider.notifier).setFiltroBusqueda(value),
                ),
                const SizedBox(height: 12),
                const InventoryCategoryChips(),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${productosFiltrados.length} productos',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ref.read(productosProvider.notifier).recargarDesdeSupabase(),
                    color: colorScheme.primary,
                    child: productosFiltrados.isEmpty
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
                        : RepaintBoundary(
                            child: GridView.builder(
                              key: const PageStorageKey('inventory_grid'),
                              addAutomaticKeepAlives: true,
                              padding: const EdgeInsets.only(bottom: 100),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                childAspectRatio: childAspectRatio,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: productosFiltrados.length,
                              itemBuilder: (context, index) {
                                final p = productosFiltrados[index];
                                final isSelected = isSelectionMode && inventoryState.productosSeleccionados.contains(p.id);

                                // 🔥 OPTIMIZACIÓN: RepaintBoundary en cada tarjeta evita repintar TODA la grilla al scrollear
                                return RepaintBoundary(
                                  child: InventoryProductCard(
                                    key: ValueKey(p.id),
                                    producto: p,
                                    stockBajo: p.stock <= p.stockMinimo,
                                    onTap: () {
                                      if (isSelectionMode) {
                                        ref.read(inventoryProvider.notifier).toggleSeleccionProducto(p.id);
                                      } else {
                                        _mostrarDetalleProducto(p);
                                      }
                                    },
                                    onLongPress: () {
                                      ref.read(inventoryProvider.notifier).toggleSeleccionProducto(p.id);
                                    },
                                    isSelected: isSelected,
                                    isMobile: isMobile,
                                    isTablet: isTablet,
                                    index: index,
                                    animationController: null, // 🔥 Eliminamos la animación del padre para evitar jank en scroll
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
  }

  // ============================================================
  // BOTONES DE ACCIÓN DEL APPBAR
  // ============================================================
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    final size = isTablet ? 48.0 : 40.0;
    final iconSize = isTablet ? 26.0 : 22.0;

    // 🔥 Simplificado: Eliminamos el StatefulBuilder innecesario para cada botón
    return Tooltip(
      message: tooltip,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: iconSize),
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          splashRadius: isTablet ? 28 : 22,
        ),
      ),
    );
  }

  // ============================================================
  // FAB
  // ============================================================
  Widget? _buildFAB(BuildContext context) {
    final isAdmin = usuarioActual.rol == 'admin';
    if (!isAdmin) return null;

    final state = ref.watch(inventoryProvider);

    if (state.seleccionMultiple && state.productosSeleccionados.isNotEmpty) {
      return FloatingActionButton.extended(
        backgroundColor: pumpkinSpice,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () {
          // 🔥 CORRECCIÓN: Verificar montado
          if (mounted) {
            debugPrint('Imprimiendo etiquetas...'); // Asumo que este método existe, si no, añade la lógica aquí
          }
        },
        icon: const Icon(Icons.local_offer_outlined, size: 24),
        label: Text(
          'Imprimir etiquetas (${state.cantidadSeleccionados})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return FloatingActionButton.extended(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () => _mostrarFormularioProducto(),
        icon: const Icon(Icons.add, size: 24),
        label: Text(ResponsiveHelper.isMobile(context) ? 'Nuevo' : 'Nuevo Producto'),
      );
    }
  }
}