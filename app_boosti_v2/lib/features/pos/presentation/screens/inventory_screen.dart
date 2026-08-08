// ============================================================
// inventory_screen.dart (CON SELECCIÓN MÚLTIPLE, ETIQUETAS Y GENERADOR DE CÓDIGO DE BARRAS AVANZADO)
// ============================================================
// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:io';
import 'dart:ui' as ui;
import 'package:app_boosti_v2/features/pos/presentation/services/ticket_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart' as barcode;
import '../../data/Local/entities/producto_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../utils/responsive_helper.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../services/sync_service.dart';
import 'inventory_catalog_screen.dart';
import '../services/printer_service.dart';
import '../services/label_generator.dart';
import '../providers/esc_pos_provider.dart';

// ============================================================
// WIDGET PRINCIPAL
// ============================================================
class InventoryScreen extends ConsumerStatefulWidget {
  final UsuarioEntity usuarioLogueado;
  final String? codigoBarrasInicial;

  const InventoryScreen({
    super.key,
    required this.usuarioLogueado,
    this.codigoBarrasInicial,
  });

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  final IsarService _isarService = IsarService();
  final SyncService _syncService = SyncService();

  List<ProductoEntity> _productos = [];
  bool _isLoading = true;
  String _filtroBusqueda = '';
  bool _soloStockBajo = false;

  // Variables de selección múltiple
  bool _seleccionMultiple = false;
  final Set<int> _productosSeleccionados = {};

  bool get _esAdmin => widget.usuarioLogueado.rol == 'admin';
  int get _cantidadSeleccionados => _productosSeleccionados.length;

  @override
  void initState() {
    super.initState();
    _cargarInventario();

    if (widget.codigoBarrasInicial != null && widget.codigoBarrasInicial!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mostrarFormularioProducto(codigoBarrasPrecargado: widget.codigoBarrasInicial);
      });
    }
  }

  // ==========================================================
  // CARGA DE INVENTARIO
  // ==========================================================
  Future<void> _cargarInventario() async {
    setState(() => _isLoading = true);
    try {
      final productos = await _isarService.obtenerProductos();
      if (mounted) {
        setState(() {
          _productos = productos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _mostrarSnackbar('Error al cargar el inventario', isError: true);
      }
    }
  }

  void _mostrarSnackbar(String mensaje, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF10B981),
      ),
    );
  }

  // ==========================================================
  // ESCÁNER
  // ==========================================================
  Future<void> _scanBarcode() async {
    final codigoEscaneado = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (context) => const _BarcodeScannerDialog(),
    );
    if (codigoEscaneado == null || codigoEscaneado.isEmpty) return;

    final productos = await _isarService.buscarProductoPorCodigoONombre(codigoEscaneado);
    final producto = productos.firstWhere(
      (p) => p.codigoBarras == codigoEscaneado,
      orElse: () => ProductoEntity(),
    );

    if (producto.id != 0) {
      if (mounted) _mostrarDetalleProducto(producto);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Producto no encontrado'),
        content: Text(
          'El código "$codigoEscaneado" no está registrado.\n¿Deseas crear un nuevo producto con este código?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Crear Producto'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      _mostrarFormularioProducto(codigoBarrasPrecargado: codigoEscaneado);
    }
  }

  // ==========================================================
  // GENERADOR DE CÓDIGO DE BARRAS (AVANZADO)
  // ==========================================================
  void _generarCodigoBarras() {
    final TextEditingController codigoController = TextEditingController();
    final GlobalKey previewKey = GlobalKey();
    final ValueNotifier<int> regenerarNotifier = ValueNotifier(0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final isMobile = ResponsiveHelper.isMobile(context);
            final isTablet = ResponsiveHelper.isTablet(context);
            final double barcodeWidth = isMobile ? 150 : (isTablet ? 200 : 250);
            final double barcodeHeight = isMobile ? 60 : (isTablet ? 80 : 100);
            final double fontSizeTitle = isMobile ? 16 : (isTablet ? 20 : 22);
            final double fontSizeHint = isMobile ? 12 : (isTablet ? 14 : 16);
            final double buttonFontSize = isMobile ? 11 : (isTablet ? 13 : 14);
            final double paddingContent = isMobile ? 12 : (isTablet ? 16 : 20);

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 16 : 24)),
              titlePadding: EdgeInsets.all(paddingContent),
              contentPadding: EdgeInsets.all(paddingContent),
              actionsPadding: EdgeInsets.symmetric(horizontal: paddingContent, vertical: 8),
              title: Text('Generar Código de Barras', style: TextStyle(fontSize: fontSizeTitle, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: codigoController,
                          style: TextStyle(fontSize: isMobile ? 14 : (isTablet ? 16 : 18)),
                          decoration: InputDecoration(
                            hintText: 'Código generado automáticamente',
                            hintStyle: TextStyle(fontSize: fontSizeHint, color: Colors.grey.shade500),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(isMobile ? 8 : 12)),
                            contentPadding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 16, vertical: isMobile ? 8 : 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.qr_code, color: const Color(0xFF10B981), size: isMobile ? 24 : (isTablet ? 28 : 32)),
                          onPressed: () => regenerarNotifier.value++,
                          tooltip: 'Generar otro código',
                          padding: EdgeInsets.all(isMobile ? 8 : 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ValueListenableBuilder(
                    valueListenable: regenerarNotifier,
                    builder: (context, version, child) {
                      return FutureBuilder<String>(
                        key: ValueKey(version),
                        future: _isarService.generarCodigoBarrasUnico(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: Padding(
                                padding: EdgeInsets.all(isMobile ? 20 : 30),
                                child: CircularProgressIndicator(color: const Color(0xFF10B981), strokeWidth: isMobile ? 2 : 3),
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red, fontSize: fontSizeHint)),
                            );
                          } else if (snapshot.hasData) {
                            final codigo = snapshot.data!;
                            if (codigoController.text != codigo) codigoController.text = codigo;
                            return RepaintBoundary(
                              key: previewKey,
                              child: Container(
                                padding: EdgeInsets.all(isMobile ? 12 : 16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Center(
                                  child: barcode.BarcodeWidget(
                                    barcode: barcode.Barcode.code128(),
                                    data: codigo,
                                    width: barcodeWidth,
                                    height: barcodeHeight,
                                    drawText: false,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cerrar', style: TextStyle(fontSize: buttonFontSize)),
                ),
                ValueListenableBuilder(
                  valueListenable: regenerarNotifier,
                  builder: (context, version, child) {
                    return FutureBuilder<String>(
                      key: ValueKey(version),
                      future: _isarService.generarCodigoBarrasUnico(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                          final codigo = snapshot.data!;
                          final buttonStyle = ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 8 : 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isMobile ? 8 : 10)),
                            minimumSize: isMobile ? const Size(70, 34) : const Size(90, 38),
                          );
                          final buttonIconSize = isMobile ? 16.0 : 18.0;

                          if (isMobile) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  style: buttonStyle.copyWith(
                                    backgroundColor: WidgetStateProperty.all(Colors.grey.shade200),
                                    foregroundColor: WidgetStateProperty.all(Colors.grey.shade800),
                                  ),
                                  onPressed: () async {
                                    try {
                                      final boundary = previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                      final image = await boundary.toImage();
                                      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                                      final bytes = byteData!.buffer.asUint8List();
                                      final tempDir = await getTemporaryDirectory();
                                      final file = File('${tempDir.path}/codigo_barras.png');
                                      await file.writeAsBytes(bytes);
                                      await Share.shareXFiles([XFile(file.path)], text: 'Código de barras: $codigo');
                                    } catch (e) {
                                      // Ignorar
                                    }
                                  },
                                  icon: Icon(Icons.share, size: buttonIconSize),
                                  label: Text('Compartir', style: TextStyle(fontSize: buttonFontSize)),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  style: buttonStyle.copyWith(
                                    backgroundColor: WidgetStateProperty.all(const Color(0xFF10B981)),
                                    foregroundColor: WidgetStateProperty.all(Colors.white),
                                  ),
                                  onPressed: () async {
                                    try {
                                      final renderObject = previewKey.currentContext!.findRenderObject();
                                      if (renderObject is! RenderRepaintBoundary) throw Exception('No es RenderRepaintBoundary');
                                      final boundary = renderObject;
                                      final image = await boundary.toImage();
                                      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                                      final bytes = byteData!.buffer.asUint8List();
                                      final impresora = ref.read(printerProvider);
                                      await TicketService.imprimirCodigoBarras(
                                        codigo: codigo,
                                        imageBytes: bytes,
                                        impresoraSeleccionada: impresora,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('✅ Código enviado a imprimir'), backgroundColor: Color(0xFF10B981)),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: ${e.toString().substring(0, 100)}'), backgroundColor: Colors.red),
                                        );
                                      }
                                    }
                                  },
                                  icon: Icon(Icons.print, size: buttonIconSize),
                                  label: Text('Imprimir', style: TextStyle(fontSize: buttonFontSize)),
                                ),
                              ],
                            );
                          } else {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ElevatedButton.icon(
                                  style: buttonStyle.copyWith(
                                    backgroundColor: WidgetStateProperty.all(Colors.grey.shade200),
                                    foregroundColor: WidgetStateProperty.all(Colors.grey.shade800),
                                  ),
                                  onPressed: () async {
                                    try {
                                      final boundary = previewKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
                                      final image = await boundary.toImage();
                                      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                                      final bytes = byteData!.buffer.asUint8List();
                                      final tempDir = await getTemporaryDirectory();
                                      final file = File('${tempDir.path}/codigo_barras.png');
                                      await file.writeAsBytes(bytes);
                                      await Share.shareXFiles([XFile(file.path)], text: 'Código de barras: $codigo');
                                    } catch (e) {
                                      // Ignorar
                                    }
                                  },
                                  icon: Icon(Icons.share, size: buttonIconSize),
                                  label: Text('Compartir', style: TextStyle(fontSize: buttonFontSize)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  style: buttonStyle.copyWith(
                                    backgroundColor: WidgetStateProperty.all(const Color(0xFF10B981)),
                                    foregroundColor: WidgetStateProperty.all(Colors.white),
                                  ),
                                  onPressed: () async {
                                    try {
                                      final renderObject = previewKey.currentContext!.findRenderObject();
                                      if (renderObject is! RenderRepaintBoundary) throw Exception('No es RenderRepaintBoundary');
                                      final boundary = renderObject;
                                      final image = await boundary.toImage();
                                      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
                                      final bytes = byteData!.buffer.asUint8List();
                                      final impresora = ref.read(printerProvider);
                                      await TicketService.imprimirCodigoBarras(
                                        codigo: codigo,
                                        imageBytes: bytes,
                                        impresoraSeleccionada: impresora,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('✅ Código enviado a imprimir'), backgroundColor: Color(0xFF10B981)),
                                        );
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error: ${e.toString().substring(0, 100)}'), backgroundColor: Colors.red),
                                        );
                                      }
                                    }
                                  },
                                  icon: Icon(Icons.print, size: buttonIconSize),
                                  label: Text('Imprimir', style: TextStyle(fontSize: buttonFontSize)),
                                ),
                              ],
                            );
                          }
                        } else {
                          return const SizedBox.shrink();
                        }
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // FORMULARIO DE PRODUCTO (CREAR/EDITAR)
  // ==========================================================
  void _mostrarFormularioProducto({ProductoEntity? productoAEditar, String? codigoBarrasPrecargado}) {
    if (!_esAdmin) return;

    showDialog(
      context: context,
      builder: (context) => _ProductFormDialog(
        producto: productoAEditar,
        categoriasExistentes: _productos
            .map((p) => p.categoria.trim())
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort(),
        onGuardar: (producto) async {
            await _isarService.guardarProducto(producto);
            await _syncService.sincronizarProductosASupabase();
            await _cargarInventario(); // ✅ Recarga la lista local
            if (mounted) {
            _mostrarSnackbar('Producto ${productoAEditar != null ? 'actualizado' : 'creado'} exitosamente');
          }
        },
        codigoBarrasPrecargado: codigoBarrasPrecargado,
      ),
    );
  }

  // ==========================================================
  // DETALLE DEL PRODUCTO
  // ==========================================================
  void _mostrarDetalleProducto(ProductoEntity producto) {
    showDialog(
      context: context,
      builder: (context) => _ProductDetailDialog(
        producto: producto,
        esAdmin: _esAdmin,
        onEditar: () {
          Navigator.pop(context);
          _mostrarFormularioProducto(productoAEditar: producto);
        },
        onEliminar: () async {
          try {
            await _isarService.eliminarProducto(producto.id);
            try {
              await _syncService.eliminarProductoEnSupabase(producto.codigoBarras.trim());
            } catch (e) {
              debugPrint('Error eliminando de Supabase: $e');
            }
            await _cargarInventario();
            if (mounted) {
              _mostrarSnackbar('Producto eliminado correctamente');
            }
          } catch (e) {
            _mostrarSnackbar('Error al eliminar producto: $e', isError: true);
          }
        },
      ),
    );
  }

  // ==========================================================
  // MÉTODOS DE SELECCIÓN MÚLTIPLE
  // ==========================================================
  void _toggleSeleccionProducto(int productoId) {
    setState(() {
      if (_productosSeleccionados.contains(productoId)) {
        _productosSeleccionados.remove(productoId);
      } else {
        _productosSeleccionados.add(productoId);
      }
      if (_productosSeleccionados.isEmpty) {
        _seleccionMultiple = false;
      }
    });
  }

  void _limpiarSeleccion() {
    setState(() {
      _productosSeleccionados.clear();
      _seleccionMultiple = false;
    });
  }

  // ==========================================================
  // DIÁLOGO DE CANTIDAD POR PRODUCTO
  // ==========================================================
  Future<void> _mostrarDialogoCantidadEtiquetas() async {
    final productosSeleccionados = _productos
        .where((p) => _productosSeleccionados.contains(p.id))
        .toList();

    if (productosSeleccionados.isEmpty) {
      _mostrarSnackbar('No hay productos seleccionados', isError: true);
      return;
    }

    // Mapa para guardar la cantidad por producto (ID -> cantidad)
    final Map<int, int> cantidades = {};
    for (final p in productosSeleccionados) {
      cantidades[p.id] = 1; // valor por defecto
    }

    final isMobile = ResponsiveHelper.isMobile(context);
    // ignore: unused_local_variable
    final isTablet = ResponsiveHelper.isTablet(context);

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
                              child: Text(
                                p.nombre,
                                style: const TextStyle(fontWeight: FontWeight.w500),
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
                    // Filtrar cantidades válidas
                    final validCantidades = Map<int, int>.from(cantidades)
                      ..removeWhere((key, value) => value < 1);
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

  // ==========================================================
  // IMPRESIÓN DE ETIQUETAS EN LOTE
  // ==========================================================
  Future<void> _imprimirEtiquetasSeleccionadas(Map<int, int> cantidades) async {
    // Obtener la impresora seleccionada
    final selectedPrinter = ref.read(printerProvider);
    if (selectedPrinter == null) {
      _mostrarSnackbar('No hay impresora seleccionada', isError: true);
      return;
    }

    // Generar la lista de LabelItem
    final labels = <LabelItem>[];
    for (final entry in cantidades.entries) {
      final producto = _productos.firstWhere((p) => p.id == entry.key);
      labels.add(LabelItem(
        nombre: producto.nombre,
        precio: producto.precioUnidad,
        codigoBarras: producto.codigoBarras,
        cantidad: entry.value,
      ));
    }

    // Mostrar indicador de carga
    final snackBar = SnackBar(
      content: Row(
        children: const [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Imprimiendo etiquetas...'),
        ],
      ),
      duration: const Duration(seconds: 10),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Imprimir
    final result = await PrinterService().printLabel(
      printer: selectedPrinter.device,
      labels: labels,
    );

    ScaffoldMessenger.of(context).clearSnackBars();

    if (result.success) {
      _mostrarSnackbar('✅ ${labels.length} etiquetas impresas correctamente');
      _limpiarSeleccion();
    } else {
      _mostrarSnackbar('❌ Error al imprimir: ${result.message}', isError: true);
    }
  }

  // ==========================================================
  // BARRA DE BÚSQUEDA
  // ==========================================================
  Widget _buildSearchBar(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 46,
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                onChanged: (val) => setState(() => _filtroBusqueda = val),
                decoration: InputDecoration(
                  hintText: isMobile ? 'Buscar...' : 'Buscar por nombre o código...',
                  hintStyle: TextStyle(fontSize: isMobile ? 13 : 14, color: Colors.grey.shade500),
                  isDense: true,
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
                          tooltip: 'Escanear código',
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            _scanBarcode();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                    ],
                  ),
                  prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilterChip(
            label: const Text('⚠️ Stock Bajo'),
            selected: _soloStockBajo,
            onSelected: (val) => setState(() => _soloStockBajo = val),
            selectedColor: const Color(0xFFFEE2E2),
            checkmarkColor: Colors.red,
            labelStyle: TextStyle(fontSize: isMobile ? 10 : 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount;
    double childAspectRatio;
    if (screenWidth < 600) {
      crossAxisCount = 2;
      childAspectRatio = 0.60;
    } else if (screenWidth < 900) {
      crossAxisCount = 2;
      childAspectRatio = 0.55;
    } else if (screenWidth < 1200) {
      crossAxisCount = 3;
      childAspectRatio = 0.62;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 0.68;
    }
    if (isMobile && MediaQuery.of(context).orientation == Orientation.landscape) {
      crossAxisCount = 3;
      childAspectRatio = 0.60;
    }

    final productosFiltrados = _productos.where((p) {
      final coincideTexto = p.nombre.toLowerCase().contains(_filtroBusqueda.toLowerCase()) ||
          p.codigoBarras.contains(_filtroBusqueda);
      final coincideStockBajo = !_soloStockBajo || (p.stock <= p.stockMinimo);
      return coincideTexto && coincideStockBajo;
    }).toList();

    // APP BAR CON CONTADOR DE SELECCIÓN
    final appBar = AppBar(
      leadingWidth: 90,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
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
              errorBuilder: (_, _, _) => const Icon(Icons.storefront, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
      title: Text(
        isMobile ? 'Inventario' : 'Gestión de Inventario',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      centerTitle: isMobile,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.fromRGBO(68, 109, 241, 1), Color.fromARGB(255, 85, 59, 235)],
          ),
        ),
      ),
      foregroundColor: Colors.white,
      actions: [
        // Botón para generar código de barras
        IconButton(
          icon: const Icon(Icons.qr_code, color: Colors.white),
          tooltip: 'Generar Código de Barras',
          onPressed: _generarCodigoBarras,
        ),
        const SizedBox(width: 8),
        if (_seleccionMultiple) ...[
          Row(
            children: [
              Text(
                '$_cantidadSeleccionados seleccionados',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _limpiarSeleccion,
              ),
            ],
          ),
        ] else ...[
          const SizedBox(width: 8),
        ],
      ],
    );

    // FLOATING ACTION BUTTON CONDICIONAL
    Widget? fab;
    if (_esAdmin) {
      if (_seleccionMultiple && _productosSeleccionados.isNotEmpty) {
        fab = FloatingActionButton.extended(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          elevation: 8,
          onPressed: _mostrarDialogoCantidadEtiquetas,
          icon: const Icon(Icons.local_offer_outlined, size: 24),
          label: Text(
            'Imprimir etiquetas ($_cantidadSeleccionados)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      } else {
        fab = FloatingActionButton.extended(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          elevation: 8,
          onPressed: () => _mostrarFormularioProducto(),
          icon: const Icon(Icons.add, size: 24),
          label: Text(isMobile ? 'Nuevo' : 'Nuevo Producto'),
        );
      }
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: appBar,
      floatingActionButton: fab,
      body: _isLoading
          ? GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 4,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 6,
              itemBuilder: (_, _) => const _ProductCardSkeleton(),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildSearchBar(isMobile),
                  const SizedBox(height: 16),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _cargarInventario,
                      color: const Color(0xFF10B981),
                      child: productosFiltrados.isEmpty
                          ? Center(
                              child: Text(
                                'No se encontraron productos.',
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey, fontSize: 14),
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
                                final bool isSelected = _seleccionMultiple &&
                                    _productosSeleccionados.contains(p.id);

                                return _ProductCard(
                                  key: ValueKey(p.id),
                                  producto: p,
                                  stockBajo: p.stock <= p.stockMinimo,
                                  onTap: () {
                                    if (_seleccionMultiple) {
                                      _toggleSeleccionProducto(p.id);
                                    } else {
                                      _mostrarDetalleProducto(p);
                                    }
                                  },
                                  onLongPress: () {
                                    if (!_seleccionMultiple) {
                                      setState(() {
                                        _seleccionMultiple = true;
                                        _productosSeleccionados.add(p.id);
                                      });
                                    } else {
                                      _toggleSeleccionProducto(p.id);
                                    }
                                  },
                                  isSelected: isSelected,
                                  isMobile: isMobile,
                                  isTablet: isTablet,
                                  index: index,
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ============================================================
// TARJETA DE PRODUCTO (CON SELECCIÓN Y LONG PRESS) - ESTILO CATÁLOGO
// ============================================================
class _ProductCard extends StatelessWidget {
  final ProductoEntity producto;
  final bool stockBajo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;
  final bool isMobile;
  final bool isTablet;
  final int index;

  const _ProductCard({
    super.key,
    required this.producto,
    required this.stockBajo,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false,
    required this.isMobile,
    required this.isTablet,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final double fontSizeNombre = isMobile ? 12 : (isTablet ? 16 : 14);
    final double fontSizePrecio = isMobile ? 14 : (isTablet ? 18 : 16);
    final double fontSizeDetalle = isMobile ? 8 : (isTablet ? 11 : 10);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.85, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 30)),
      curve: Curves.easeOutCubic,
      child: _ProductCardContent(
        producto: producto,
        stockBajo: stockBajo,
        onTap: onTap,
        onLongPress: onLongPress,
        isSelected: isSelected,
        isMobile: isMobile,
        isTablet: isTablet,
        fontSizeNombre: fontSizeNombre,
        fontSizePrecio: fontSizePrecio,
        fontSizeDetalle: fontSizeDetalle,
      ),
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child!),
    );
  }
}

class _ProductCardContent extends StatelessWidget {
  final ProductoEntity producto;
  final bool stockBajo;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool isSelected;
  final bool isMobile;
  final bool isTablet;
  final double fontSizeNombre;
  final double fontSizePrecio;
  final double fontSizeDetalle;

  const _ProductCardContent({
    required this.producto,
    required this.stockBajo,
    required this.onTap,
    required this.onLongPress,
    this.isSelected = false,
    required this.isMobile,
    required this.isTablet,
    required this.fontSizeNombre,
    required this.fontSizePrecio,
    required this.fontSizeDetalle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF8B5CF6)
                : (stockBajo
                    ? const Color(0xFFFCA5A5)
                    : (isTablet ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0))),
            width: isSelected ? 3 : (stockBajo ? 2 : (isTablet ? 2.5 : 1.5)),
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFF8B5CF6).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: isTablet ? 0.08 : 0.05),
              blurRadius: isSelected ? 20 : (isTablet ? 16 : 12),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Contenido normal (imagen + info)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen (flex 5)
                Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        Center(
                          child: producto.imagenUrl.isNotEmpty
                              ? Image.network(
                                  producto.imagenUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (_, _, _) =>
                                      Icon(Icons.inventory_2, size: 40, color: const Color(0xFF3B82F6)),
                                )
                              : Icon(Icons.inventory_2, size: 40, color: const Color(0xFF3B82F6)),
                        ),
                        if (stockBajo)
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
                              producto.esPesado ? 'Balanza' : 'Unidad',
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Información (flex 4)
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: EdgeInsets.all(isMobile ? 8.0 : 12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: fontSizeNombre,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Cód: ${producto.codigoBarras}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: fontSizeDetalle,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${producto.precioUnidad.toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: fontSizePrecio,
                                color: const Color(0xFF059669),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: stockBajo ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                              ),
                              child: Text(
                                'Stock: ${producto.stock}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: fontSizeDetalle,
                                  fontWeight: FontWeight.w600,
                                  color: stockBajo ? const Color(0xFFEF4444) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (producto.categoria.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Cat: ${producto.categoria}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: fontSizeDetalle,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (producto.proveedorNombre.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFC7D2FE), width: 0.5),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.phone,
                                    size: isMobile ? 8 : (isTablet ? 12 : 16),
                                    color: const Color(0xFF4F46E5)),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    producto.proveedorNombre,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: fontSizeDetalle - 1,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Indicador de selección (check en la esquina superior derecha)
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
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
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 5,
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
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 12, width: double.infinity, color: const Color(0xFFF1F5F9)),
                  Container(height: 10, width: 60, color: const Color(0xFFF1F5F9)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 16, width: 40, color: const Color(0xFFF1F5F9)),
                      Container(height: 12, width: 50, color: const Color(0xFFF1F5F9)),
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
// DIÁLOGO DEL ESCÁNER
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
          MobileScanner(
            controller: _controller,
            onDetect: (capture) async {
              if (_isProcessing) return;
              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final rawValue = barcode.rawValue;
                if (rawValue != null && rawValue.isNotEmpty) {
                  _isProcessing = true;
                  Navigator.of(context).pop(rawValue);
                  break;
                }
              }
              Future.delayed(const Duration(milliseconds: 500), () => _isProcessing = false);
            },
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF10B981), width: 4),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: const Color(0xFF10B981).withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 10)],
              ),
              child: const Center(
                child: Text(
                  '🔍 Centra el código',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, shadows: [Shadow(color: Colors.black45, blurRadius: 10)]),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 28,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(_isTorchOn ? Icons.flash_on : Icons.flash_off, color: Colors.white, size: 30),
                    onPressed: () {
                      setState(() => _isTorchOn = !_isTorchOn);
                      _controller.toggleTorch();
                    },
                    splashRadius: 28,
                    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 40,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(12)),
              child: const Text(
                'Apunta la cámara al código de barras',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DIÁLOGO DE DETALLE DEL PRODUCTO (CON ETIQUETA PARA TODOS Y BOTONES MEJORADOS)
// ============================================================
class _ProductDetailDialog extends ConsumerWidget {
  final ProductoEntity producto;
  final bool esAdmin;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const _ProductDetailDialog({
    required this.producto,
    required this.esAdmin,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);

    final selectedPrinterState = ref.watch(printerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 850, maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 24 : 32)),
        decoration: BoxDecoration(
          color: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Detalles del Producto',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Imagen
              Center(
                child: Container(
                  height: isMobile ? 120.0 : (isTablet ? 200.0 : 280.0),
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: isMobile ? 400 : 500),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: producto.imagenUrl.isNotEmpty
                        ? Image.network(producto.imagenUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => Icon(Icons.inventory_2, size: 64, color: Colors.blueGrey))
                        : Icon(Icons.inventory_2, size: 64, color: Colors.blueGrey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              // Información del producto
              Text(
                producto.nombre,
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text('Cód: ${producto.codigoBarras}', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF94A3B8))),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Precio: \$${producto.precioUnidad.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Categoría: ${producto.categoria}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Stock Actual: ${producto.stock % 1 == 0 ? producto.stock.toInt() : producto.stock}',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Stock Mínimo: ${producto.stockMinimo.isFinite ? (producto.stockMinimo % 1 == 0 ? producto.stockMinimo.toInt() : producto.stockMinimo) : 0}',
                      style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF64748B)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (producto.proveedorNombre.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
                  ),
                  child: Text(
                    'Proveedor: ${producto.proveedorNombre} (${producto.proveedorTelefono.isNotEmpty ? producto.proveedorTelefono : "Sin teléfono"})',
                    style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, color: const Color(0xFF4F46E5)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // ================================================
              // BOTONES MEJORADOS (RESPONSIVE)
              // ================================================
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Botón "Imprimir Etiqueta" - DISPONIBLE PARA TODOS
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (selectedPrinterState == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('❌ No hay impresora seleccionada. Configura una en Ajustes.'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      final label = LabelItem(
                        nombre: producto.nombre,
                        precio: producto.precioUnidad,
                        codigoBarras: producto.codigoBarras,
                        cantidad: 1,
                      );

                      final snackBar = SnackBar(
                        content: Row(
                          children: const [
                            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                            SizedBox(width: 12),
                            Text('Imprimiendo etiqueta...'),
                          ],
                        ),
                        duration: const Duration(seconds: 10),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      final result = await PrinterService().printLabel(
                        printer: selectedPrinterState.device,
                        labels: [label],
                      );

                      ScaffoldMessenger.of(context).clearSnackBars();

                      if (result.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Etiqueta impresa correctamente'),
                            backgroundColor: Color(0xFF10B981),
                          ),
                        );
                      } else {
                        // ignore: use_build_context_synchronously
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('❌ Error al imprimir: ${result.message}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.local_offer_outlined, size: 20),
                    label: const Text('Etiqueta'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cerrar'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),

                  if (esAdmin) ...[
                    ElevatedButton.icon(
                      onPressed: onEditar,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Eliminar Producto'),
                            content: Text('¿Estás seguro de eliminar "${producto.nombre}"? Esta acción no se puede deshacer.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          onEliminar();
                          if (!context.mounted) return;
                          Navigator.pop(context);
                        }
                      },
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DIÁLOGO DE FORMULARIO DE PRODUCTO (EXTRAÍDO CON MEJORAS DE IMAGEN)
// ============================================================
class _ProductFormDialog extends StatefulWidget {
  final ProductoEntity? producto;
  final List<String> categoriasExistentes;
  final Future<void> Function(ProductoEntity) onGuardar;
  final String? codigoBarrasPrecargado;

  const _ProductFormDialog({
    required this.producto,
    required this.categoriasExistentes,
    required this.onGuardar,
    this.codigoBarrasPrecargado,
  });

  @override
  State<_ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<_ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codigoController;
  late TextEditingController _nombreController;
  late TextEditingController _precioController;
  late TextEditingController _stockController;
  late TextEditingController _stockMinController;
  late TextEditingController _proveedorNombreController;
  late TextEditingController _proveedorTelController;
  late String _categoriaSeleccionada;
  late bool _esPesado;
  String _imagenUrlPreview = '';
  XFile? _imagenSeleccionada;
  bool _subiendoImagen = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _codigoController = TextEditingController(
      text: p?.codigoBarras ?? widget.codigoBarrasPrecargado ?? '',
    );
    _nombreController = TextEditingController(text: p?.nombre ?? '');
    _precioController = TextEditingController(text: p?.precioUnidad.toString() ?? '');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '');
    _stockMinController = TextEditingController(text: p?.stockMinimo.toString() ?? '5.0');
    _proveedorNombreController = TextEditingController(text: p?.proveedorNombre ?? '');
    _proveedorTelController = TextEditingController(text: p?.proveedorTelefono ?? '');
    _categoriaSeleccionada = p?.categoria.isNotEmpty == true ? p!.categoria : 'General';
    _esPesado = p?.esPesado ?? false;
    _imagenUrlPreview = p?.imagenUrl ?? '';
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _stockMinController.dispose();
    _proveedorNombreController.dispose();
    _proveedorTelController.dispose();
    super.dispose();
  }

  // ==========================================================
  // PERMISOS DE IMAGEN (CORREGIDO PARA ANDROID 13+)
  // ==========================================================
  Future<bool> _getImagePermission() async {
    if (!Platform.isAndroid) return true;
    Permission permission;
    if (await _isAndroid13OrHigher()) {
      permission = Permission.photos;
    } else {
      permission = Permission.storage;
    }
    final status = await permission.request();
    return status.isGranted;
  }

  Future<bool> _isAndroid13OrHigher() async {
    if (!Platform.isAndroid) return false;
    try {
      final version = await SystemChannels.platform.invokeMethod('System.getVersion');
      final sdkInt = int.tryParse(version.toString()) ?? 0;
      return sdkInt >= 33;
    } catch (_) {
      return false;
    }
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    final permission = await _getImagePermission();
    if (!permission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permiso de acceso a imágenes denegado'), backgroundColor: Colors.red),
      );
      return;
    }
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, maxWidth: 800, maxHeight: 800, imageQuality: 80);
    if (image != null) {
      setState(() {
        _imagenSeleccionada = image;
        _imagenUrlPreview = image.path;
      });
    }
  }

  Future<String?> _uploadImage(File image, String codigo) async {
    try {
      final ext = image.path.split('.').last;
      final fileName = '${codigo}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      debugPrint('📤 Subiendo imagen: $fileName (${image.lengthSync()} bytes)');
      await Supabase.instance.client.storage.from('productos').upload(fileName, image);
      final publicUrl = Supabase.instance.client.storage.from('productos').getPublicUrl(fileName);
      debugPrint('✅ Imagen subida: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error subiendo imagen: $e');
      return null;
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);

    String imagenUrlFinal = _imagenUrlPreview; // Inicialmente la URL existente (vacía o http)
    if (_imagenSeleccionada != null) {
      setState(() => _subiendoImagen = true);
      try {
        final url = await _uploadImage(File(_imagenSeleccionada!.path), _codigoController.text.trim());
        if (url != null && url.isNotEmpty) {
          imagenUrlFinal = url;
          // Mostrar éxito (opcional)
        } else {
          // Si la subida falla (url null o vacío), mostrar advertencia y no guardar ruta local
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ No se pudo subir la imagen. El producto se guardará sin imagen.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          // Solo mantener la URL anterior si es una URL de red (http/https)
          imagenUrlFinal = (_imagenUrlPreview.isNotEmpty && _imagenUrlPreview.startsWith('http')) ? _imagenUrlPreview : '';
        }
      } catch (e) {
        // Excepción: mostrar error y solo mantener URL previa si es válida
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error al subir imagen: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
        imagenUrlFinal = (_imagenUrlPreview.isNotEmpty && _imagenUrlPreview.startsWith('http')) ? _imagenUrlPreview : '';
      } finally {
        setState(() => _subiendoImagen = false);
      }
    }

    final producto = widget.producto ?? ProductoEntity();
    producto.codigoBarras = _codigoController.text.trim();
    producto.nombre = _nombreController.text.trim();
    producto.imagenUrl = imagenUrlFinal;
    producto.precioUnidad = double.tryParse(_precioController.text) ?? 0.0;
    producto.stock = double.tryParse(_stockController.text) ?? 0.0;
    producto.stockMinimo = double.tryParse(_stockMinController.text) ?? 5.0;
    producto.categoria = _categoriaSeleccionada;
    producto.esPesado = _esPesado;
    producto.proveedorNombre = _proveedorNombreController.text.trim();
    producto.proveedorTelefono = _proveedorTelController.text.trim();

    await widget.onGuardar(producto);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    // ignore: unused_local_variable
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 40, vertical: 24),
      child: Container(
        constraints: BoxConstraints(maxWidth: 800, maxHeight: MediaQuery.of(context).size.height * 0.9),
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        decoration: BoxDecoration(color: theme.dialogTheme.backgroundColor ?? theme.colorScheme.surface, borderRadius: BorderRadius.circular(28)),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(widget.producto == null ? Icons.add_shopping_cart_outlined : Icons.edit_outlined,
                          color: const Color(0xFF10B981), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.producto == null ? 'Nuevo Producto' : 'Editar Producto',
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _codigoController,
                  decoration: const InputDecoration(labelText: 'Código de Barras', border: OutlineInputBorder()),
                  validator: (v) => v?.trim().isNotEmpty == true ? null : 'Requerido',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del Producto *', border: OutlineInputBorder()),
                  validator: (v) => v?.trim().isNotEmpty == true ? null : 'Requerido',
                ),
                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.image_outlined, color: Color(0xFF10B981), size: 24),
                          const SizedBox(width: 8),
                          const Text('Imagen del Producto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const Spacer(),
                          if (_imagenSeleccionada != null || _imagenUrlPreview.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.red, size: 20),
                              onPressed: () => setState(() {
                                _imagenSeleccionada = null;
                                _imagenUrlPreview = '';
                              }),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                        child: _imagenSeleccionada != null
                            ? Image.file(File(_imagenSeleccionada!.path), fit: BoxFit.cover)
                            : _imagenUrlPreview.isNotEmpty
                                ? Image.network(_imagenUrlPreview, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.broken_image, size: 48, color: Colors.grey))
                                : const Center(child: Text('Sin imagen', style: TextStyle(color: Colors.grey))),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _subiendoImagen ? null : () => _seleccionarImagen(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library, size: 18),
                            label: const Text('Galería'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: _subiendoImagen ? null : () => _seleccionarImagen(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt, size: 18),
                            label: const Text('Cámara'),
                          ),
                        ],
                      ),
                      if (_subiendoImagen) const LinearProgressIndicator(),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                isMobile
                    ? Column(
                        children: [
                          TextFormField(
                            controller: _precioController,
                            decoration: const InputDecoration(labelText: 'Precio (\$) *', border: OutlineInputBorder()),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Precio válido',
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(labelText: 'Stock Inicial *', border: OutlineInputBorder()),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Stock válido',
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _precioController,
                              decoration: const InputDecoration(labelText: 'Precio (\$) *', border: OutlineInputBorder()),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Precio válido',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _stockController,
                              decoration: const InputDecoration(labelText: 'Stock Inicial *', border: OutlineInputBorder()),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Stock válido',
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 16),

                isMobile
                    ? Column(
                        children: [
                          TextFormField(
                            controller: _stockMinController,
                            decoration: const InputDecoration(labelText: 'Stock Mínimo *', border: OutlineInputBorder()),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Stock mínimo válido',
                          ),
                          const SizedBox(height: 16),
                          _buildCategoriaDropdown(),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _stockMinController,
                              decoration: const InputDecoration(labelText: 'Stock Mínimo *', border: OutlineInputBorder()),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (v) => (double.tryParse(v ?? '') ?? -1) >= 0 ? null : 'Stock mínimo válido',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: _buildCategoriaDropdown()),
                        ],
                      ),
                const SizedBox(height: 8),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('¿Es producto pesado (granel)?', style: TextStyle(fontSize: 16)),
                  value: _esPesado,
                  onChanged: (val) => setState(() => _esPesado = val),
                  activeThumbColor: const Color(0xFF10B981),
                ),
                const Divider(height: 32),

                const Text('Información del Proveedor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF475569))),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _proveedorNombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del Proveedor', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _proveedorTelController,
                  decoration: const InputDecoration(labelText: 'Teléfono del Proveedor', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 24),

                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    TextButton(
                      onPressed: _guardando ? null : () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _guardando ? null : _guardar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: _guardando
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('Guardar Producto'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriaDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _categoriaSeleccionada,
      decoration: const InputDecoration(labelText: 'Categoría', border: OutlineInputBorder()),
      items: widget.categoriasExistentes.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
      onChanged: (val) => setState(() => _categoriaSeleccionada = val!),
      isExpanded: true,
    );
  }
}