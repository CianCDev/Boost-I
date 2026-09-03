// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../providers/inventory_provider.dart';
import '../providers/productos_provider.dart';
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
  final UsuarioEntity usuarioLogueado;
  final String? codigoBarrasInicial;
  final bool showAppBar;

  const InventoryScreen({
    super.key,
    required this.usuarioLogueado,
    this.codigoBarrasInicial,
    this.showAppBar = true,
  });

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    if (widget.codigoBarrasInicial != null && widget.codigoBarrasInicial!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarFormularioProducto(codigoBarrasPrecargado: widget.codigoBarrasInicial);
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
    final esAdmin = widget.usuarioLogueado.rol == 'admin';
    if (!esAdmin) return;

    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        producto: productoAEditar,
        usuarioActual: widget.usuarioLogueado,
        onGuardar: (producto) async {
          final productosNotifier = ref.read(productosProvider.notifier);
          if (productoAEditar == null) {
            await productosNotifier.guardarProducto(producto, widget.usuarioLogueado, esNuevo: true);
          } else {
            await productosNotifier.guardarProducto(producto, widget.usuarioLogueado, esNuevo: false);
          }
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
        esAdmin: widget.usuarioLogueado.rol == 'admin',
        onEditar: () {
          Navigator.pop(context);
          _mostrarFormularioProducto(productoAEditar: producto);
        },
        onEliminar: () async {
          final productosNotifier = ref.read(productosProvider.notifier);
          await productosNotifier.eliminarProducto(producto.id, widget.usuarioLogueado);
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
  // DIÁLOGO DE CANTIDAD DE ETIQUETAS (CON PDF)
  // ============================================================
  void _mostrarDialogoCantidadEtiquetas() async {
    final state = ref.read(inventoryProvider);
    final productosSeleccionados = state.productosFiltrados
        .where((p) => state.productosSeleccionados.contains(p.id))
        .toList();

    if (productosSeleccionados.isEmpty) return;

    final Map<int, int> cantidades = {};
    for (final p in productosSeleccionados) {
      cantidades[p.id] = 1;
    }

    final isMobile = ResponsiveHelper.isMobile(context);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
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
                              child: Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
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
                                  contentPadding: EdgeInsets.symmetric(vertical: 4),
                                ),
                                onChanged: (val) {
                                  final int? cantidad = int.tryParse(val);
                                  if (cantidad != null && cantidad > 0) {
                                    setStateDialog(() {
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                // Botón Generar PDF
                ElevatedButton.icon(
                  onPressed: () {
                    final validCantidades = Map<int, int>.from(cantidades)..removeWhere((key, value) => value < 1);
                    if (validCantidades.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ingresa al menos 1 etiqueta por producto')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _generarPDFEtiquetas(validCantidades);
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: const Text('Generar PDF'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700),
                ),
                const SizedBox(width: 8),
                // Botón Imprimir
                ElevatedButton(
                  onPressed: () {
                    final validCantidades = Map<int, int>.from(cantidades)..removeWhere((key, value) => value < 1);
                    if (validCantidades.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ingresa al menos 1 etiqueta por producto')),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _imprimirEtiquetasSeleccionadas(validCantidades);
                  },
                  child: const Text('Imprimir'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // IMPRESIÓN DE ETIQUETAS (TÉRMICA) - VERSIÓN ÚNICA Y CORREGIDA
  // ============================================================
  Future<void> _imprimirEtiquetasSeleccionadas(Map<int, int> cantidades) async {
    final selectedPrinter = ref.read(printerProvider);
    if (selectedPrinter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay impresora seleccionada'), backgroundColor: Colors.orange),
      );
      return;
    }

    final state = ref.read(inventoryProvider);
    final labels = <LabelItem>[];

    for (final entry in cantidades.entries) {
      final producto = state.productosFiltrados.firstWhere((p) => p.id == entry.key);
      labels.add(LabelItem(
        nombre: producto.nombre,
        precio: producto.precioUnidad,
        codigoBarras: producto.codigoBarras,
        cantidad: entry.value, // La impresora térmica repetirá esta cantidad
      ));
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Imprimiendo etiquetas...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    final result = await PrinterService().printLabel(
      printer: selectedPrinter.device,
      labels: labels,
    );

    ScaffoldMessenger.of(context).clearSnackBars();

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${labels.fold<int>(0, (sum, item) => sum + item.cantidad)} etiquetas impresas correctamente'), backgroundColor: const Color(0xFF10B981)),
      );
      ref.read(inventoryProvider.notifier).limpiarSeleccion();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al imprimir: ${result.message}'), backgroundColor: Colors.red),
      );
    }
  }

  // ============================================================
  // GENERACIÓN DE PDF - VERSIÓN CORREGIDA (REPITE ETIQUETAS)
  // ============================================================
  Future<void> _generarPDFEtiquetas(Map<int, int> cantidades) async {
    final state = ref.read(inventoryProvider);
    final labels = <LabelItem>[];

    for (final entry in cantidades.entries) {
      final producto = state.productosFiltrados.firstWhere((p) => p.id == entry.key);
      final cantidad = entry.value;
      // Repetir la etiqueta según la cantidad solicitada
      for (var i = 0; i < cantidad; i++) {
        labels.add(LabelItem(
          nombre: producto.nombre,
          precio: producto.precioUnidad,
          codigoBarras: producto.codigoBarras,
          cantidad: 1,
        ));
      }
    }

    try {
      await LabelPdfGenerator.sharePdf(
        labels: labels,
        title: 'Etiquetas de Productos',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ PDF generado y compartido correctamente'), backgroundColor: Color(0xFF10B981)),
      );
      ref.read(inventoryProvider.notifier).limpiarSeleccion();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al generar PDF: $e'), backgroundColor: Colors.red),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    debugPrint('🔵 [InventoryScreen] build ejecutado');
    final contenido = _buildBody(context);

    if (widget.showAppBar) {
      final isMobile = ResponsiveHelper.isMobile(context);
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final isAdmin = widget.usuarioLogueado.rol == 'admin';
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
          actions: [
            _buildActionButton(
              context,
              icon: Icons.branding_watermark_rounded,
              tooltip: 'Gestionar marcas',
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const MarcasManagementDialog(),
              ),
              isTablet: ResponsiveHelper.isTablet(context),
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
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Aceptar'),
                        ),
                      ],
                    ),
                  );
                  await ref.read(productosProvider.notifier).cargarProductos();
                },
                isTablet: ResponsiveHelper.isTablet(context),
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
                isTablet: ResponsiveHelper.isTablet(context),
              ),
              const SizedBox(width: 8),
            ],
            _buildActionButton(
              context,
              icon: Icons.qr_code,
              tooltip: 'Generar Código de Barras',
              onPressed: () => showDialog(context: context, builder: (_) => const BarcodeGeneratorDialog()),
              isTablet: ResponsiveHelper.isTablet(context),
            ),
            const SizedBox(width: 12),
            if (state.seleccionMultiple) ...[
              Row(
                children: [
                  Text(
                    '${state.cantidadSeleccionados} seleccionados',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => ref.read(inventoryProvider.notifier).limpiarSeleccion(),
                  ),
                ],
              ),
            ],
          ],
        ),
        floatingActionButton: _buildFAB(context),
        body: contenido,
      );
    } else {
      return contenido;
    }
  }

  Widget _buildBody(BuildContext context) {
    final productosState = ref.watch(productosProvider);
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

    final productosFiltrados = inventoryState.productosFiltrados;

    return productosState.isLoading
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
                        : GridView.builder(
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
                              final isSelected = inventoryState.seleccionMultiple && inventoryState.productosSeleccionados.contains(p.id);

                              return InventoryProductCard(
                                key: ValueKey(p.id),
                                producto: p,
                                stockBajo: p.stock <= p.stockMinimo,
                                onTap: () {
                                  if (inventoryState.seleccionMultiple) {
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
    bool isActionHovered = false;

    return Tooltip(
      message: tooltip,
      child: StatefulBuilder(
        builder: (context, setState) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => isActionHovered = true),
            onExit: (_) => setState(() => isActionHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isActionHovered ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(icon, color: Colors.white, size: iconSize),
                onPressed: onPressed,
                padding: EdgeInsets.zero,
                splashRadius: isTablet ? 28 : 22,
                mouseCursor: SystemMouseCursors.click,
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // FAB
  // ============================================================
  Widget? _buildFAB(BuildContext context) {
    final isAdmin = widget.usuarioLogueado.rol == 'admin';
    if (!isAdmin) return null;

    final state = ref.watch(inventoryProvider);

    if (state.seleccionMultiple && state.productosSeleccionados.isNotEmpty) {
      return FloatingActionButton.extended(
        backgroundColor: pumpkinSpice,
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: _mostrarDialogoCantidadEtiquetas,
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