// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

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
import '../utils/responsive_helper.dart';
import '../widgets/appbar.dart';
import '../widgets/inventory/inventory_product_card.dart';
import '../widgets/inventory/inventory_product_card_skeleton.dart';
import '../widgets/inventory/inventory_search_bar.dart';
import '../widgets/inventory/inventory_category_chips.dart';
import '../widgets/inventory/barcode_generator_dialog.dart';
import '../widgets/inventory/marcas_managment_dialog.dart';
import '../widgets/inventory/product_form_dialog.dart';
import '../widgets/inventory/product_detail_dialog.dart';
import '../widgets/inventory/categorias_management_dialog.dart';
import '../widgets/shared/barcode_scanner_dialog.dart';

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

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  /// Atajo sin `throw` para métodos que necesitan el usuario fuera de build.
  UsuarioEntity? get _user =>
      ref.read(usuarioActualProvider) ?? widget.usuarioLogueado;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    final codigo = widget.codigoBarrasInicial;
    if (codigo != null && codigo.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mostrarFormularioProducto(codigoBarrasPrecargado: codigo);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  // SCAN / CRUD
  // ============================================================

  Future<void> _scanBarcode() async {
    final codigo = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (codigo == null || codigo.isEmpty || !mounted) return;

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
      builder: (ctx) => AlertDialog(
        title: const Text('Producto no encontrado'),
        content: Text(
          'El código "$codigo" no está registrado.\n'
          '¿Deseas crearlo ahora?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.primary,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Crear Producto'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      _mostrarFormularioProducto(codigoBarrasPrecargado: codigo);
    }
  }

  void _mostrarFormularioProducto({
    ProductoEntity? productoAEditar,
    String? codigoBarrasPrecargado,
  }) {
    final user = _user;
    if (user == null || user.rol != 'admin') return;

    showDialog(
      context: context,
      builder: (ctx) => ProductFormDialog(
        producto: productoAEditar,
        usuarioActual: user,
        onGuardar: (producto) async {
          final productosNotifier = ref.read(productosProvider.notifier);
          await productosNotifier.guardarProducto(
            producto,
            user,
            esNuevo: productoAEditar == null,
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Producto ${productoAEditar != null ? 'actualizado' : 'creado'} exitosamente',
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        },
        codigoBarrasPrecargado: codigoBarrasPrecargado,
      ),
    );
  }

  void _mostrarDetalleProducto(ProductoEntity producto) {
    final user = _user;
    if (user == null) return;

    showDialog(
      context: context,
      builder: (ctx) => ProductDetailDialog(
        producto: producto,
        esAdmin: user.rol == 'admin',
        onEditar: () {
          Navigator.pop(ctx);
          _mostrarFormularioProducto(productoAEditar: producto);
        },
        onEliminar: () async {
          await ref
              .read(productosProvider.notifier)
              .eliminarProducto(producto.id, user);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Producto eliminado correctamente'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ETIQUETAS — diálogo de cantidades
  // ============================================================

  Future<void> _mostrarDialogoCantidadEtiquetas() async {
    final state = ref.read(inventoryProvider);
    final productosSeleccionados = state.productosFiltrados
        .where((p) => state.productosSeleccionados.contains(p.id))
        .toList();

    if (productosSeleccionados.isEmpty) return;

    final cantidades = <int, int>{
      for (final p in productosSeleccionados) p.id: 1,
    };

    final isMobile = ResponsiveHelper.isMobile(context);

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Cantidad de etiquetas'),
          content: SizedBox(
            width: isMobile ? 300 : 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: productosSeleccionados.map((p) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            p.nombre,
                            style:
                                const TextStyle(fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            initialValue: '1',
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            enableInteractiveSelection: false,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 4),
                            ),
                            onChanged: (val) {
                              final cantidad = int.tryParse(val);
                              if (cantidad != null && cantidad > 0) {
                                setDialogState(() {
                                  cantidades[p.id] = cantidad;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                final valid = Map<int, int>.from(cantidades)
                  ..removeWhere((_, v) => v < 1);
                if (valid.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Ingresa al menos 1 etiqueta por producto'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                _generarPDFEtiquetas(valid);
              },
              icon: const Icon(Icons.picture_as_pdf_rounded),
              label: const Text('Generar PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                final valid = Map<int, int>.from(cantidades)
                  ..removeWhere((_, v) => v < 1);
                if (valid.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Ingresa al menos 1 etiqueta por producto'),
                    ),
                  );
                  return;
                }
                Navigator.pop(ctx);
                _imprimirEtiquetasSeleccionadas(valid);
              },
              child: const Text('Imprimir'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // IMPRESIÓN TÉRMICA
  // ============================================================

  Future<void> _imprimirEtiquetasSeleccionadas(
    Map<int, int> cantidades,
  ) async {
    final selectedPrinter = ref.read(printerProvider);
    if (selectedPrinter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay impresora seleccionada'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final state = ref.read(inventoryProvider);
    final labels = <LabelItem>[];

    for (final entry in cantidades.entries) {
      final producto = state.productosFiltrados
          .cast<ProductoEntity?>()
          .firstWhere((p) => p!.id == entry.key, orElse: () => null);
      if (producto == null) continue;
      labels.add(LabelItem(
        nombre: producto.nombre,
        precio: producto.precioUnidad,
        codigoBarras: producto.codigoBarras,
        cantidad: entry.value,
      ));
    }

    if (labels.isEmpty) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Imprimiendo etiquetas...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final result = await PrinterService().printLabel(
        printer: selectedPrinter.device,
        labels: labels,
      );

      if (!mounted) return;
      messenger.clearSnackBars();

      if (result.success) {
        final total = labels.fold<int>(0, (s, i) => s + i.cantidad);
        messenger.showSnackBar(
          SnackBar(
            content: Text('✅ $total etiquetas impresas correctamente'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
        ref.read(inventoryProvider.notifier).limpiarSeleccion();
      } else {
        messenger.showSnackBar(
          SnackBar(
            content: Text('❌ Error al imprimir: ${result.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text('❌ Error al imprimir: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // GENERACIÓN PDF
  // ============================================================

  Future<void> _generarPDFEtiquetas(Map<int, int> cantidades) async {
    final state = ref.read(inventoryProvider);
    final labels = <LabelItem>[];

    for (final entry in cantidades.entries) {
      final producto = state.productosFiltrados
          .cast<ProductoEntity?>()
          .firstWhere((p) => p!.id == entry.key, orElse: () => null);
      if (producto == null) continue;

      for (var i = 0; i < entry.value; i++) {
        labels.add(LabelItem(
          nombre: producto.nombre,
          precio: producto.precioUnidad,
          codigoBarras: producto.codigoBarras,
          cantidad: 1,
        ));
      }
    }

    if (labels.isEmpty) return;

    try {
      await LabelPdfGenerator.sharePdf(
        labels: labels,
        title: 'Etiquetas de Productos',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ PDF generado y compartido correctamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      ref.read(inventoryProvider.notifier).limpiarSeleccion();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error al generar PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final usuario =
        ref.watch(usuarioActualProvider) ?? widget.usuarioLogueado;

    // Guard: pantalla transitoria mientras carga el usuario.
    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isAdmin = usuario.rol == 'admin';
    final contenido = _buildBody(context);

    if (!widget.showAppBar) return contenido;

    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Solo miramos seleccionMultiple del state para el badge de "N seleccionados".
    final seleccionMultiple = ref.watch(
      inventoryProvider.select((s) => s.seleccionMultiple),
    );
    final cantidadSeleccionados = ref.watch(
      inventoryProvider.select((s) => s.cantidadSeleccionados),
    );

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
        actions: [
          _AppBarActionButton(
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
            _RepararImagenesAction(isTablet: isTablet),
            const SizedBox(width: 8),
            _AppBarActionButton(
              icon: Icons.category_outlined,
              tooltip: 'Gestionar categorías',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const CategoriasManagementDialog(),
              ),
              isTablet: isTablet,
            ),
            const SizedBox(width: 8),
          ],
          _AppBarActionButton(
            icon: Icons.qr_code,
            tooltip: 'Generar código de barras',
            onPressed: () => showDialog(
              context: context,
              builder: (_) => const BarcodeGeneratorDialog(),
            ),
            isTablet: isTablet,
          ),
          const SizedBox(width: 12),
          if (seleccionMultiple) ...[
            Text(
              '$cantidadSeleccionados seleccionados',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () =>
                  ref.read(inventoryProvider.notifier).limpiarSeleccion(),
            ),
          ],
        ],
      ),
      floatingActionButton: _buildFAB(context, isAdmin: isAdmin),
      body: contenido,
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(BuildContext context) {
    final productosState = ref.watch(productosProvider);
    final inventoryState = ref.watch(inventoryProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    if (productosState.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isMobile ? 2 : 4,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => const InventoryProductCardSkeleton(),
      );
    }

    final (crossAxisCount, childAspectRatio) =
        _gridDimensions(screenWidth, isMobile);
    final productosFiltrados = inventoryState.productosFiltrados;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          InventorySearchBar(
            onScanPressed: _scanBarcode,
            onSearchChanged: (value) =>
                ref.read(inventoryProvider.notifier).setFiltroBusqueda(value),
          ),
          const SizedBox(height: 12),
          const InventoryCategoryChips(),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${productosFiltrados.length} productos',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref
                  .read(productosProvider.notifier)
                  .recargarDesdeSupabase(),
              color: colorScheme.primary,
              child: productosFiltrados.isEmpty
                  ? _buildEmptyState(colorScheme)
                  : GridView.builder(
                      key: const PageStorageKey('inventory_grid'),
                      addAutomaticKeepAlives: true,
                      padding: const EdgeInsets.only(bottom: 100),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: childAspectRatio,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final p = productosFiltrados[index];
                        final isSelected =
                            inventoryState.seleccionMultiple &&
                                inventoryState.productosSeleccionados
                                    .contains(p.id);

                        return InventoryProductCard(
                          key: ValueKey(p.id),
                          producto: p,
                          stockBajo: p.stock <= p.stockMinimo,
                          onTap: () {
                            if (inventoryState.seleccionMultiple) {
                              ref
                                  .read(inventoryProvider.notifier)
                                  .toggleSeleccionProducto(p.id);
                            } else {
                              _mostrarDetalleProducto(p);
                            }
                          },
                          onLongPress: () => ref
                              .read(inventoryProvider.notifier)
                              .toggleSeleccionProducto(p.id),
                          isSelected: isSelected,
                          isMobile: isMobile,
                          isTablet: isTablet,
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

  /// Dimensiones responsivas de la grilla. Extraído para claridad.
  (int, double) _gridDimensions(double screenWidth, bool isMobile) {
    if (isMobile &&
        MediaQuery.of(context).orientation == Orientation.landscape) {
      return (3, 0.60);
    }
    if (screenWidth < 600) return (2, 0.60);
    if (screenWidth < 900) return (3, 0.65);
    if (screenWidth < 1200) return (4, 0.70);
    return (5, 0.75);
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'No se encontraron productos.',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FAB
  // ============================================================

  Widget? _buildFAB(BuildContext context, {required bool isAdmin}) {
    if (!isAdmin) return null;

    final seleccionMultiple = ref.watch(
      inventoryProvider.select((s) => s.seleccionMultiple),
    );
    final cantidadSeleccionados = ref.watch(
      inventoryProvider.select((s) => s.cantidadSeleccionados),
    );

    if (seleccionMultiple && cantidadSeleccionados > 0) {
      return FloatingActionButton.extended(
        backgroundColor: pumpkinSpice,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: _mostrarDialogoCantidadEtiquetas,
        icon: const Icon(Icons.local_offer_outlined, size: 24),
        label: Text(
          'Imprimir etiquetas ($cantidadSeleccionados)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }

    return FloatingActionButton.extended(
      backgroundColor: primaryGreen,
      foregroundColor: Colors.white,
      elevation: 8,
      onPressed: () => _mostrarFormularioProducto(),
      icon: const Icon(Icons.add, size: 24),
      label: Text(
        ResponsiveHelper.isMobile(context) ? 'Nuevo' : 'Nuevo Producto',
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// APPBAR ACTION BUTTON
// ══════════════════════════════════════════════════════════════

class _AppBarActionButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isTablet;

  const _AppBarActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    required this.isTablet,
  });

  @override
  State<_AppBarActionButton> createState() => _AppBarActionButtonState();
}

class _AppBarActionButtonState extends State<_AppBarActionButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.isTablet ? 48.0 : 40.0;
    final iconSize = widget.isTablet ? 26.0 : 22.0;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: _hovered ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(widget.icon, color: Colors.white, size: iconSize),
            onPressed: widget.onPressed,
            padding: EdgeInsets.zero,
            splashRadius: widget.isTablet ? 28 : 22,
            mouseCursor: SystemMouseCursors.click,
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// REPARAR IMÁGENES (con estado de loading)
// ══════════════════════════════════════════════════════════════

class _RepararImagenesAction extends ConsumerStatefulWidget {
  final bool isTablet;
  const _RepararImagenesAction({required this.isTablet});

  @override
  ConsumerState<_RepararImagenesAction> createState() =>
      _RepararImagenesActionState();
}

class _RepararImagenesActionState
    extends ConsumerState<_RepararImagenesAction> {
  bool _loading = false;

  Future<void> _reparar() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final count = await SyncService().repararImagenesFaltantes();
      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (ctx) => AlertDialog(
          title: Text(count > 0 ? '✅ Imágenes reparadas' : 'Sin cambios'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (count > 0)
                Lottie.asset(
                  'assets/animations/success.json',
                  width: 100,
                  height: 100,
                  repeat: false,
                )
              else
                const Icon(Icons.info_outline, size: 60, color: Colors.orange),
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      await ref.read(productosProvider.notifier).cargarProductos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reparar imágenes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _AppBarActionButton(
      icon: _loading
          ? Icons.hourglass_top_rounded
          : Icons.image_search_outlined,
      tooltip: _loading ? 'Reparando imágenes...' : 'Reparar imágenes faltantes',
      onPressed: _loading ? () {} : _reparar,
      isTablet: widget.isTablet,
    );
  }
}