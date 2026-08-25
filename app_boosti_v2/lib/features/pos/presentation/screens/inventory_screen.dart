// inventory_screen.dart
// Con estilo unificado al catálogo, modo oscuro y animaciones
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../providers/inventory_provider.dart';
import '../providers/esc_pos_provider.dart';
import '../services/sync_service.dart';
import '../services/printer_service.dart';
import '../services/label_generator.dart';
import '../widgets/inventory/inventory_product_card.dart';
import '../widgets/inventory/inventory_product_card_skeleton.dart';
import '../widgets/inventory/inventory_search_bar.dart';
import '../widgets/inventory/inventory_category_chips.dart';
import '../widgets/inventory/barcode_generator_dialog.dart';
import '../widgets/shared/barcode_scanner_dialog.dart';
import '../utils/responsive_helper.dart';
import 'inventory_catalog_screen.dart';
import '../widgets/inventory/product_form_dialog.dart';
import '../widgets/inventory/product_detail_dialog.dart';

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

  Future<void> _scanBarcode() async {
    final codigo = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (codigo == null || codigo.isEmpty) return;

    final productos = ref.read(inventoryProvider).productos;
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
        onGuardar: (producto) async {
          final isar = IsarService();
          await isar.guardarProducto(producto);
          await SyncService().sincronizarProductosASupabase();
          await ref.read(inventoryProvider.notifier).cargarInventario();
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
          final isar = IsarService();
          await isar.eliminarProducto(producto.id);
          try {
            await SyncService().eliminarProductoEnSupabase(producto.codigoBarras.trim());
          } catch (e) {
            // Error silencioso
          }
          await ref.read(inventoryProvider.notifier).cargarInventario();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Producto eliminado correctamente'), backgroundColor: Color(0xFF10B981)),
            );
          }
        },
      ),
    );
  }

  void _mostrarDialogoCantidadEtiquetas() async {
    final state = ref.read(inventoryProvider);
    final productosSeleccionados = state.productos
        .where((p) => state.productosSeleccionados.contains(p.id))
        .toList();

    if (productosSeleccionados.isEmpty) return;

    final Map<int, int> cantidades = {};
    for (final p in productosSeleccionados) {
      cantidades[p.id] = 1;
    }

    final isMobile = ResponsiveHelper.isMobile(context);
    final result = await showDialog<Map<int, int>>(
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
                ElevatedButton(
                  onPressed: () {
                    final validCantidades = Map<int, int>.from(cantidades)..removeWhere((key, value) => value < 1);
                    if (validCantidades.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ingresa al menos 1 etiqueta por producto')),
                      );
                      return;
                    }
                    Navigator.pop(context, validCantidades);
                  },
                  child: const Text('Imprimir'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      await _imprimirEtiquetasSeleccionadas(result);
    }
  }

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
      final producto = state.productos.firstWhere((p) => p.id == entry.key);
      labels.add(LabelItem(
        nombre: producto.nombre,
        precio: producto.precioUnidad,
        codigoBarras: producto.codigoBarras,
        cantidad: entry.value,
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
        SnackBar(content: Text('✅ ${labels.length} etiquetas impresas correctamente'), backgroundColor: const Color(0xFF10B981)),
      );
      ref.read(inventoryProvider.notifier).limpiarSeleccion();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error al imprimir: ${result.message}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final contenido = _buildBody(context);

    if (widget.showAppBar) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        appBar: _buildAppBar(context),
        floatingActionButton: _buildFAB(context),
        body: contenido,
      );
    } else {
      return contenido;
    }
  }

  Widget _buildBody(BuildContext context) {
    final state = ref.watch(inventoryProvider);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;

    int crossAxisCount;
    double childAspectRatio;
    if (screenWidth < 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.65;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
      childAspectRatio = 0.65;
    } else if (screenWidth < 1200) {
      crossAxisCount = 3;
      childAspectRatio = 0.70;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 0.75;
    }
    if (isMobile && MediaQuery.of(context).orientation == Orientation.landscape) {
      crossAxisCount = 3;
      childAspectRatio = 0.60;
    }

    final productosFiltrados = state.productosFiltrados;

    return state.isLoading
        ? GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 4,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (_, _) => const InventoryProductCardSkeleton(),
          )
        : Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                InventorySearchBar(
                  onScanPressed: _scanBarcode,
                  onSearchChanged: (value) => ref.read(inventoryProvider.notifier).setFiltroBusqueda(value),
                  onStockBajoToggled: (value) => ref.read(inventoryProvider.notifier).setSoloStockBajo(value),
                  soloStockBajo: state.soloStockBajo,
                ),
                const SizedBox(height: 12),
                // Chips de categorías (estilo unificado con el catálogo)
                const InventoryCategoryChips(),
                const SizedBox(height: 12),
                // Contador de productos
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
                    onRefresh: () => ref.read(inventoryProvider.notifier).recargarDesdeSupabase(),
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
                              final isSelected = state.seleccionMultiple && state.productosSeleccionados.contains(p.id);

                              return InventoryProductCard(
                                key: ValueKey(p.id),
                                producto: p,
                                stockBajo: p.stock <= p.stockMinimo,
                                onTap: () {
                                  if (state.seleccionMultiple) {
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

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final state = ref.watch(inventoryProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      leadingWidth: 90,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onPrimary, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const InventoryCatalogScreen()),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Image.asset(
              'assets/logo.png',
              width: 30,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => Icon(Icons.storefront, color: colorScheme.onPrimary, size: 24),
            ),
          ),
        ],
      ),
      title: Text(
        isMobile ? 'Inventario' : 'Gestión de Inventario',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: colorScheme.onPrimary),
      ),
      centerTitle: isMobile,
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
      foregroundColor: colorScheme.onPrimary,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.qr_code, color: colorScheme.onPrimary),
          tooltip: 'Generar Código de Barras',
          onPressed: () => showDialog(context: context, builder: (_) => const BarcodeGeneratorDialog()),
        ),
        const SizedBox(width: 8),
        if (state.seleccionMultiple) ...[
          Row(
            children: [
              Text(
                '${state.cantidadSeleccionados} seleccionados',
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 14),
              ),
              IconButton(
                icon: Icon(Icons.close, color: colorScheme.onPrimary),
                onPressed: () => ref.read(inventoryProvider.notifier).limpiarSeleccion(),
              ),
            ],
          ),
        ] else ...[
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget? _buildFAB(BuildContext context) {
    final isAdmin = widget.usuarioLogueado.rol == 'admin';
    if (!isAdmin) return null;

    final state = ref.watch(inventoryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (state.seleccionMultiple && state.productosSeleccionados.isNotEmpty) {
      return FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5CF6),
        foregroundColor: colorScheme.onPrimary,
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
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 8,
        onPressed: () => _mostrarFormularioProducto(),
        icon: const Icon(Icons.add, size: 24),
        label: Text(ResponsiveHelper.isMobile(context) ? 'Nuevo' : 'Nuevo Producto'),
      );
    }
  }
}