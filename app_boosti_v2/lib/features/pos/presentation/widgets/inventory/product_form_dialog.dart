// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isar/isar.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

// Entidades y servicios
import '../../../data/Local/entities/categoria_entity.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../../data/Local/entities/proveedor_entity.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../../data/Local/entities/marca_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/categorias_provider.dart';
import '../../providers/productos_provider.dart';
import '../../services/sync_service.dart';
import '../../utils/responsive_helper.dart';
import '../proveedores/crear_proveedor_dialog.dart';
import '../shared/barcode_scanner_dialog.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/active_toggle.dart';
import '../common/glass_search_bar.dart';
import 'product_detail_dialog.dart';

// ignore: constant_identifier_names
const String _DRAFT_KEY = 'product_form_draft';

class ProductFormDialog extends ConsumerStatefulWidget {
  final ProductoEntity? producto;
  final Future<void> Function(ProductoEntity) onGuardar;
  final String? codigoBarrasPrecargado;
  final UsuarioEntity? usuarioActual;
  final bool esDuplicado;

  const ProductFormDialog({
    super.key,
    this.producto,
    required this.onGuardar,
    this.codigoBarrasPrecargado,
    this.usuarioActual,
    this.esDuplicado = false,
  });

  @override
  ConsumerState<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends ConsumerState<ProductFormDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _stockMinController = TextEditingController();
  final TextEditingController _proveedorNombreController =
      TextEditingController();
  final TextEditingController _proveedorTelController =
      TextEditingController();
  final TextEditingController _proveedorBusquedaController =
      TextEditingController();
  final TextEditingController _marcaBusquedaController =
      TextEditingController();

  late String _categoriaSeleccionada;
  int? _categoriaIdSeleccionada;
  late bool _esPesado;
  late bool _activo;
  String _imagenUrlPreview = '';
  XFile? _imagenSeleccionada;
  bool _subiendoImagen = false;
  bool _guardando = false;

  ProveedorEntity? _proveedorSeleccionado;
  bool _cargandoProveedores = false;
  List<ProveedorEntity> _proveedores = [];

  MarcaEntity? _marcaSeleccionada;
  bool _cargandoMarcas = false;
  List<MarcaEntity> _marcas = [];

  bool _generandoCodigo = false;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorInfo = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final p = widget.producto;
    final esDuplicado = widget.esDuplicado;
    final stockBase = esDuplicado ? 0.0 : p?.stock ?? 0.0;

    _codigoController.text =
        p?.codigoBarras ?? widget.codigoBarrasPrecargado ?? '';
    _nombreController.text = p?.nombre ?? '';
    _precioController.text = p?.precioUnidad.toString() ?? '';
    _stockController.text = stockBase.toStringAsFixed(0);
    _stockMinController.text = p?.stockMinimo.toString() ?? '5.0';
    _proveedorNombreController.text = p?.proveedorNombre ?? '';
    _proveedorTelController.text = p?.proveedorTelefono ?? '';

    _categoriaIdSeleccionada = p?.categoriaId;
    _categoriaSeleccionada = p?.categoria ?? 'General';
    _esPesado = p?.esPesado ?? false;
    _activo = p?.activo ?? true;
    _imagenUrlPreview = p?.imagenUrl ?? '';

    _cargarProveedores();
    _cargarMarcas();
    _recuperarBorrador();
  }

  @override
  void dispose() {
    _guardarBorrador();
    _tabController.dispose();
    _codigoController.dispose();
    _nombreController.dispose();
    _precioController.dispose();
    _stockController.dispose();
    _stockMinController.dispose();
    _proveedorNombreController.dispose();
    _proveedorTelController.dispose();
    _proveedorBusquedaController.dispose();
    _marcaBusquedaController.dispose();
    super.dispose();
  }

  // ==================== BORRADOR ====================
  Future<void> _guardarBorrador() async {
    if (widget.producto != null) return;
    final prefs = await SharedPreferences.getInstance();
    final draft = {
      'codigo': _codigoController.text,
      'nombre': _nombreController.text,
      'precio': _precioController.text,
      'stock': _stockController.text,
      'stockMin': _stockMinController.text,
      'categoria': _categoriaSeleccionada,
      'esPesado': _esPesado,
      'activo': _activo,
      'proveedorNombre': _proveedorNombreController.text,
      'proveedorTel': _proveedorTelController.text,
      'imagenUrl': _imagenUrlPreview,
      'marcaSupabaseId': _marcaSeleccionada?.supabaseId,
    };
    await prefs.setString(_DRAFT_KEY, draft.toString());
  }

  Future<void> _recuperarBorrador() async {
    if (widget.producto != null) return;
    final prefs = await SharedPreferences.getInstance();
    final draftStr = prefs.getString(_DRAFT_KEY);
    if (draftStr == null) return;
  }

  // ==================== CÓDIGO DE BARRAS ====================
  Future<void> _generarCodigoBarras() async {
    setState(() => _generandoCodigo = true);
    try {
      final codigo = await IsarService().generarCodigoBarrasUnico();
      _codigoController.text = codigo;
    } catch (e) {
      if (mounted) {
        _mostrarDialogoSimple(
          titulo: 'Error',
          mensaje: 'Error al generar código de barras: $e',
          esError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _generandoCodigo = false);
    }
  }

  Future<void> _escanearCodigoBarras() async {
    final codigo = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const BarcodeScannerDialog(),
    );

    if (codigo == null || codigo.isEmpty) return;

    final productos = ref.read(productosProvider).items;
    final productoExistente = productos.firstWhere(
      (p) => p.codigoBarras == codigo,
      orElse: () => ProductoEntity(),
    );

    if (productoExistente.id != 0) {
      final accion = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Código ya registrado'),
          content: Text(
            'El código "$codigo" pertenece a:\n\n'
            '📦 ${productoExistente.nombre}\n'
            '💰 \$${productoExistente.precioUnidad}\n\n'
            '¿Qué deseas hacer?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'continuar'),
              child: const Text('Crear nuevo de todos modos'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, 'editar'),
              child: const Text('Editar existente'),
            ),
          ],
        ),
      );

      if (accion == 'editar') {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => ProductDetailDialog(
            producto: productoExistente,
            esAdmin: widget.usuarioActual?.rol == 'admin',
            onEditar: () {
              Navigator.pop(context);
              _mostrarFormularioEdicion(productoExistente);
            },
            onEliminar: () async {
              Navigator.pop(context);
            },
          ),
        );
        return;
      }
    }

    _codigoController.text = codigo;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Código escaneado: se ha rellenado el campo'),
        backgroundColor: _colorSuccess,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _mostrarFormularioEdicion(ProductoEntity producto) {
    showDialog(
      context: context,
      builder: (context) => ProductFormDialog(
        producto: producto,
        usuarioActual: widget.usuarioActual,
        onGuardar: (productoEditado) async {
          final productosNotifier = ref.read(productosProvider.notifier);
          await productosNotifier.guardarProducto(
            productoEditado,
            widget.usuarioActual!,
            esNuevo: false,
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                behavior: SnackBarBehavior.floating,
                content: Text('Producto actualizado correctamente'),
                backgroundColor: _colorSuccess,
              ),
            );
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  // ==================== PROVEEDORES ====================
  Future<void> _cargarProveedores() async {
    setState(() => _cargandoProveedores = true);
    try {
      final syncService = SyncService();
      await syncService.descargarProveedoresDesdeSupabase();
      final isar = IsarService();
      final proveedores = await isar.obtenerProveedores(soloActivos: true);
      debugPrint(
          '📦 [ProductForm] Proveedores cargados: ${proveedores.length}');
      setState(() {
        _proveedores = proveedores;
        if (widget.producto?.proveedorId != null) {
          _proveedorSeleccionado = proveedores.firstWhereOrNull(
            (p) => p.id == widget.producto!.proveedorId,
          );
          if (_proveedorSeleccionado != null) {
            _proveedorNombreController.text = _proveedorSeleccionado!.nombre;
            _proveedorTelController.text =
                _proveedorSeleccionado!.telefono ?? '';
            _proveedorBusquedaController.text =
                _proveedorSeleccionado!.nombre;
          }
        }
      });
    } catch (e) {
      debugPrint('Error cargando proveedores: $e');
    } finally {
      if (mounted) setState(() => _cargandoProveedores = false);
    }
  }

  Future<void> _crearProveedorRapido() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const CrearProveedorDialog(),
    );
    if (result == true) {
      await _cargarProveedores();
      if (_proveedores.isNotEmpty) {
        final nuevo = _proveedores.last;
        _proveedorSeleccionado = nuevo;
        _proveedorNombreController.text = nuevo.nombre;
        _proveedorTelController.text = nuevo.telefono ?? '';
        _proveedorBusquedaController.text = nuevo.nombre;
        setState(() {});
      }
    }
  }

  void _seleccionarProveedor(ProveedorEntity? proveedor) {
    setState(() {
      _proveedorSeleccionado = proveedor;
      if (proveedor != null) {
        _proveedorNombreController.text = proveedor.nombre;
        _proveedorTelController.text = proveedor.telefono ?? '';
        _proveedorBusquedaController.text = proveedor.nombre;
      } else {
        _proveedorNombreController.clear();
        _proveedorTelController.clear();
        _proveedorBusquedaController.clear();
      }
    });
  }

  Future<void> _abrirPanelProveedores() async {
    final proveedorSeleccionado = await showGeneralDialog<ProveedorEntity>(
      context: context,
      pageBuilder: (context, animation, secondaryAnimation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: _ProveedoresPanelDialog(
            proveedores: _proveedores,
            seleccionado: _proveedorSeleccionado,
            onSeleccionar: (p) => Navigator.pop(context, p),
            onCrearProveedor: () async {
              Navigator.pop(context);
              await _crearProveedorRapido();
              _abrirPanelProveedores();
            },
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
      barrierDismissible: true,
      barrierLabel: 'Cerrar panel',
    );
    if (proveedorSeleccionado != null) {
      _seleccionarProveedor(proveedorSeleccionado);
    }
  }

  // ==================== MARCAS ====================
  Future<void> _cargarMarcas() async {
    setState(() => _cargandoMarcas = true);
    try {
      final isar = IsarService();
      final marcas = await isar.obtenerMarcas(soloActivas: true);
      setState(() {
        _marcas = marcas;
        if (widget.producto?.marcaSupabaseId != null) {
          _marcaSeleccionada = marcas.firstWhereOrNull(
            (m) => m.supabaseId == widget.producto!.marcaSupabaseId,
          );
          if (_marcaSeleccionada != null) {
            _marcaBusquedaController.text = _marcaSeleccionada!.nombre;
          }
        }
      });
    } catch (e) {
      debugPrint('Error cargando marcas: $e');
    } finally {
      if (mounted) setState(() => _cargandoMarcas = false);
    }
  }

  void _seleccionarMarca(MarcaEntity? marca) {
    setState(() {
      _marcaSeleccionada = marca;
      if (marca != null) {
        _marcaBusquedaController.text = marca.nombre;
      } else {
        _marcaBusquedaController.clear();
      }
    });
  }

  // ==================== IMAGEN ====================
  Future<void> _seleccionarImagen(ImageSource source) async {
    if (!await _checkPermission()) {
      if (mounted) {
        _mostrarDialogoSimple(
          titulo: 'Permiso denegado',
          mensaje:
              'Se necesita acceso a la galería/cámara para seleccionar una imagen.',
          esError: true,
        );
      }
      return;
    }

    setState(() => _subiendoImagen = true);
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() {
          _imagenSeleccionada = image;
          _imagenUrlPreview = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        _mostrarDialogoSimple(
          titulo: 'Error',
          mensaje: 'Error al seleccionar imagen: $e',
          esError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _subiendoImagen = false);
    }
  }

  Future<bool> _checkPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  void _limpiarImagen() {
    setState(() {
      _imagenSeleccionada = null;
      _imagenUrlPreview = '';
    });
  }

  // ==================== GUARDAR ====================
  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      _mostrarDialogoSimple(
        titulo: 'Campos incompletos',
        mensaje: 'Por favor, completa todos los campos obligatorios.',
        esError: true,
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      String imagenUrlFinal = _imagenUrlPreview;

      if (_imagenSeleccionada != null) {
        setState(() => _subiendoImagen = true);
        try {
          final url = await _uploadImage(
            File(_imagenSeleccionada!.path),
            _codigoController.text.trim(),
          );
          if (url != null && url.isNotEmpty) {
            imagenUrlFinal = url;
          } else {
            if (_imagenUrlPreview.isNotEmpty &&
                _imagenUrlPreview.startsWith('http')) {
              imagenUrlFinal = _imagenUrlPreview;
            } else {
              imagenUrlFinal = '';
            }
          }
        } catch (e) {
          if (_imagenUrlPreview.isNotEmpty &&
              _imagenUrlPreview.startsWith('http')) {
            imagenUrlFinal = _imagenUrlPreview;
          }
        } finally {
          if (mounted) setState(() => _subiendoImagen = false);
        }
      }

      final producto = widget.producto ?? ProductoEntity();
      if (widget.esDuplicado) {
        producto.id = Isar.autoIncrement;
        producto.stock = 0.0;
      }
      producto.codigoBarras = _codigoController.text.trim();
      producto.nombre = _nombreController.text.trim();
      producto.marcaSupabaseId = _marcaSeleccionada?.supabaseId;
      producto.marca = _marcaSeleccionada?.nombre ?? '';
      producto.imagenUrl = imagenUrlFinal;
      producto.precioUnidad = double.tryParse(_precioController.text) ?? 0.0;
      producto.stock = double.tryParse(_stockController.text) ?? 0.0;
      producto.stockMinimo =
          double.tryParse(_stockMinController.text) ?? 5.0;
      producto.categoriaId = _categoriaIdSeleccionada;
      producto.categoria = _categoriaSeleccionada;
      producto.esPesado = _esPesado;
      producto.activo = _activo;
      producto.proveedorId = _proveedorSeleccionado?.id;
      producto.proveedorNombre = _proveedorSeleccionado?.nombre ?? '';
      producto.proveedorTelefono = _proveedorSeleccionado?.telefono ?? '';
      producto.proveedorEmail = _proveedorSeleccionado?.email ?? '';
      producto.proveedorDireccion = _proveedorSeleccionado?.direccion ?? '';
      producto.updatedAt = DateTime.now();

      await widget.onGuardar(producto);

      if (mounted) {
        _mostrarDialogoExito(
          titulo:
              'Producto ${widget.producto != null ? 'actualizado' : 'creado'}',
          mensaje: '"${producto.nombre}" ha sido guardado correctamente.',
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_DRAFT_KEY);
    } catch (e) {
      if (mounted) {
        _mostrarDialogoSimple(
          titulo: 'Error al guardar',
          mensaje: e.toString(),
          esError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<String?> _uploadImage(File image, String codigo) async {
    try {
      final ext = image.path.split('.').last;
      final fileName =
          '${codigo}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await Supabase.instance.client.storage
          .from('productos')
          .upload(fileName, image);
      final publicUrl = Supabase.instance.client.storage
          .from('productos')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      return null;
    }
  }

  // ==================== DIÁLOGOS DE FEEDBACK ====================
  void _mostrarDialogoExito({
    required String titulo,
    required String mensaje,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GlassDialog(
        maxWidth: 420,
        accentColor: _colorSuccess,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLottieWithFallback('assets/animations/success.json'),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: _colorSuccess,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorSuccess,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Aceptar',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarDialogoSimple({
    required String titulo,
    required String mensaje,
    bool esError = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GlassDialog(
        maxWidth: 420,
        accentColor: esError ? _colorDanger : _colorInfo,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esError)
                _buildLottieWithFallback('assets/animations/error.json')
              else
                const Icon(Icons.info_outline, size: 60, color: _colorInfo),
              const SizedBox(height: 12),
              Text(
                titulo,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: esError ? _colorDanger : _colorInfo,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          Theme.of(dialogContext).colorScheme.onSurfaceVariant,
                      side: BorderSide(
                        color: Theme.of(dialogContext)
                            .colorScheme
                            .outlineVariant
                            .withValues(alpha: 0.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLottieWithFallback(String assetPath) {
    return Lottie.asset(
      assetPath,
      width: 120,
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          assetPath.contains('error')
              ? Icons.error_outline_rounded
              : Icons.check_circle_rounded,
          size: 80,
          color: assetPath.contains('error') ? _colorDanger : _colorSuccess,
        );
      },
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 900,
      maxHeightFactor: 0.92,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(colorScheme, isMobile),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 12 : 13,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: isMobile ? 12 : 13,
                ),
                tabs: const [
                  Tab(
                    height: 42,
                    icon: Icon(Icons.inventory_2_outlined, size: 18),
                    text: 'Producto',
                  ),
                  Tab(
                    height: 42,
                    icon: Icon(Icons.business_center_rounded, size: 18),
                    text: 'Proveedor',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductTab(colorScheme, isMobile),
                    _buildProveedorTab(colorScheme, isMobile),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAcciones(colorScheme, isMobile),
          ],
        ),
      ),
    );
  }

  // ==================== PESTAÑA PRODUCTO ====================
  Widget _buildProductTab(ColorScheme colorScheme, bool isMobile) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _campoCodigoBarras(colorScheme),
          const SizedBox(height: 16),
          _campoNombre(colorScheme),
          const SizedBox(height: 16),
          _campoSelectorMarca(colorScheme),
          const SizedBox(height: 16),
          _campoCategoriaSelector(colorScheme),
          const SizedBox(height: 16),
          _buildSwitchPesado(colorScheme),
          const SizedBox(height: 12),
          ActiveToggle(
            value: _activo,
            onChanged: (v) => setState(() => _activo = v),
            activeLabel: 'Producto activo',
            inactiveLabel: 'Producto inactivo',
            activeSubtitle: 'Disponible en el catálogo y POS',
            inactiveSubtitle: 'Oculto de la operación actual',
          ),
          const SizedBox(height: 16),
          _buildImageSection(colorScheme, isMobile),
          const SizedBox(height: 16),
          _buildPrecioStock(colorScheme, isMobile),
        ],
      ),
    );
  }

  // ==================== PESTAÑA PROVEEDOR ====================
  Widget _buildProveedorTab(ColorScheme colorScheme, bool isMobile) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildSelectorProveedor(colorScheme, isMobile),
          const SizedBox(height: 16),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _crearProveedorRapido,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text(
                  'Crear nuevo proveedor',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (_proveedorSeleccionado != null)
            _buildProveedorSeleccionadoCard(colorScheme),
        ],
      ),
    );
  }

  // ==================== SWITCH PESADO ====================
  Widget _buildSwitchPesado(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: _esPesado
              ? _colorInfo.withValues(alpha: 0.1)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF9FAFB)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _esPesado
                ? _colorInfo.withValues(alpha: 0.3)
                : colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: SwitchListTile(
          title: Text(
            '¿Es producto pesado (granel)?',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            _esPesado
                ? 'Se pesa al vender (kg)'
                : 'Se vende por unidad',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          value: _esPesado,
          onChanged: (val) => setState(() => _esPesado = val),
          activeThumbColor: _colorInfo,
          contentPadding: EdgeInsets.zero,
          dense: true,
        ),
      ),
    );
  }

  // ==================== PRECIO Y STOCK ====================
  Widget _buildPrecioStock(ColorScheme colorScheme, bool isMobile) {
    return isMobile
        ? Column(
            children: [
              _campoPrecio(colorScheme),
              const SizedBox(height: 12),
              _campoStock(colorScheme),
              const SizedBox(height: 12),
              _campoStockMinimo(colorScheme),
            ],
          )
        : Row(
            children: [
              Expanded(child: _campoPrecio(colorScheme)),
              const SizedBox(width: 12),
              Expanded(child: _campoStock(colorScheme)),
              const SizedBox(width: 12),
              Expanded(child: _campoStockMinimo(colorScheme)),
            ],
          );
  }

  // ==================== SELECTOR DE PROVEEDOR ====================
  Widget _buildSelectorProveedor(ColorScheme colorScheme, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center_rounded,
                  color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Proveedores',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: Icon(Icons.view_list_rounded,
                      color: colorScheme.primary, size: 20),
                  tooltip: 'Ver todos',
                  onPressed: _abrirPanelProveedores,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _cargandoProveedores
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _proveedores.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No hay proveedores activos. Crea uno desde "Crear nuevo proveedor".',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Autocomplete<ProveedorEntity>(
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _proveedores;
                        }
                        final query = textEditingValue.text.toLowerCase();
                        return _proveedores.where((p) =>
                            p.nombre.toLowerCase().contains(query) ||
                            (p.empresa ?? '')
                                .toLowerCase()
                                .contains(query));
                      },
                      displayStringForOption: (proveedor) => proveedor.nombre,
                      fieldViewBuilder: (context, controller, focusNode,
                          onFieldSubmitted) {
                        _proveedorBusquedaController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: _inputDecor(
                            label: 'Buscar proveedor...',
                            icon: Icons.search,
                            colorScheme: colorScheme,
                            isDark: isDark,
                          ),
                          onChanged: (value) {
                            controller.text = value;
                            if (_proveedorSeleccionado != null &&
                                _proveedorSeleccionado!.nombre != value) {
                              _seleccionarProveedor(null);
                            }
                          },
                        );
                      },
                      onSelected: (proveedor) {
                        _seleccionarProveedor(proveedor);
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            color: colorScheme.surface,
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    dense: true,
                                    title: Text(option.nombre),
                                    subtitle: option.empresa != null &&
                                            option.empresa!.isNotEmpty
                                        ? Text(
                                            option.empresa!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          )
                                        : null,
                                    onTap: () => onSelected(option),
                                    leading: Icon(Icons.business,
                                        color: colorScheme.primary, size: 20),
                                    tileColor: option == _proveedorSeleccionado
                                        ? colorScheme.primary
                                            .withValues(alpha: 0.1)
                                        : null,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }

  // ==================== TARJETA PROVEEDOR SELECCIONADO ====================
  Widget _buildProveedorSeleccionadoCard(ColorScheme colorScheme) {
    final proveedor = _proveedorSeleccionado!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _colorPrimary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _colorPrimary.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  size: 16, color: _colorPrimary),
              const SizedBox(width: 6),
              Text(
                'Proveedor seleccionado',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _colorPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const Spacer(),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: Icon(Icons.close,
                      size: 16, color: colorScheme.onSurfaceVariant),
                  onPressed: () => _seleccionarProveedor(null),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Quitar',
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            proveedor.nombre,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (proveedor.telefono?.isNotEmpty ?? false) ...[
            const SizedBox(height: 4),
            _buildDetailRow(
              icon: Icons.phone_rounded,
              text: proveedor.telefono!,
              colorScheme: colorScheme,
            ),
          ],
          if (proveedor.email?.isNotEmpty ?? false)
            _buildDetailRow(
              icon: Icons.email_rounded,
              text: proveedor.email!,
              colorScheme: colorScheme,
            ),
          if (proveedor.direccion?.isNotEmpty ?? false)
            _buildDetailRow(
              icon: Icons.location_on_rounded,
              text: proveedor.direccion!,
              colorScheme: colorScheme,
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String text,
    required ColorScheme colorScheme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SELECTOR DE MARCA ====================
  Widget _campoSelectorMarca(ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.branding_watermark_outlined,
                  color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Marca (opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _cargandoMarcas
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                )
              : _marcas.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No hay marcas disponibles.',
                        style: TextStyle(
                          fontSize: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : Autocomplete<MarcaEntity>(
                      optionsBuilder: (textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return _marcas;
                        }
                        final query = textEditingValue.text.toLowerCase();
                        return _marcas.where((m) =>
                            m.nombre.toLowerCase().contains(query) ||
                            (m.descripcion ?? '')
                                .toLowerCase()
                                .contains(query));
                      },
                      displayStringForOption: (marca) => marca.nombre,
                      fieldViewBuilder: (context, controller, focusNode,
                          onFieldSubmitted) {
                        _marcaBusquedaController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: _inputDecor(
                            label: 'Buscar marca...',
                            icon: Icons.search,
                            colorScheme: colorScheme,
                            isDark: isDark,
                          ),
                          onChanged: (value) {
                            controller.text = value;
                            if (_marcaSeleccionada != null &&
                                _marcaSeleccionada!.nombre != value) {
                              _seleccionarMarca(null);
                            }
                          },
                        );
                      },
                      onSelected: (marca) {
                        _seleccionarMarca(marca);
                        _marcaBusquedaController.text = marca.nombre;
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4,
                            borderRadius: BorderRadius.circular(12),
                            color: colorScheme.surface,
                            child: ConstrainedBox(
                              constraints:
                                  const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    dense: true,
                                    title: Text(option.nombre),
                                    subtitle: option.descripcion != null &&
                                            option.descripcion!.isNotEmpty
                                        ? Text(
                                            option.descripcion!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          )
                                        : null,
                                    onTap: () => onSelected(option),
                                    leading: Icon(
                                        Icons.branding_watermark_rounded,
                                        color: colorScheme.primary,
                                        size: 20),
                                    tileColor: option == _marcaSeleccionada
                                        ? colorScheme.primary
                                            .withValues(alpha: 0.1)
                                        : null,
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          if (_marcaSeleccionada != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _colorPrimary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _colorPrimary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  if (_marcaSeleccionada!.logoUrl != null &&
                      _marcaSeleccionada!.logoUrl!.isNotEmpty)
                    ClipOval(
                      child: Image.network(
                        _marcaSeleccionada!.logoUrl!,
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(
                          Icons.branding_watermark_rounded,
                          size: 20,
                          color: _colorPrimary,
                        ),
                      ),
                    )
                  else
                    const Icon(
                      Icons.branding_watermark_rounded,
                      size: 20,
                      color: _colorPrimary,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _marcaSeleccionada!.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: IconButton(
                      icon: Icon(Icons.close,
                          size: 16, color: colorScheme.onSurfaceVariant),
                      onPressed: () => _seleccionarMarca(null),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== SELECTOR DE CATEGORÍAS ====================
  Widget _campoCategoriaSelector(ColorScheme colorScheme) {
    final categoriasAsync = ref.watch(todasLasCategoriasProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return categoriasAsync.when(
      data: (categorias) {
        CategoriaEntity? categoriaSeleccionada;
        if (_categoriaIdSeleccionada != null) {
          categoriaSeleccionada = categorias.firstWhereOrNull(
            (c) => c.id == _categoriaIdSeleccionada,
          );
        }
        if (categoriaSeleccionada == null && _categoriaSeleccionada.isNotEmpty) {
          categoriaSeleccionada = categorias.firstWhereOrNull(
            (c) => c.nombre == _categoriaSeleccionada,
          );
        }

        return DropdownButtonFormField<CategoriaEntity>(
          initialValue: categoriaSeleccionada,
          isExpanded: true,
          decoration: _inputDecor(
            label: 'Categoría *',
            icon: Icons.category_outlined,
            colorScheme: colorScheme,
            isDark: isDark,
          ),
          hint: const Text('Selecciona una categoría'),
          items: [
            const DropdownMenuItem<CategoriaEntity>(
              value: null,
              child: Text('Sin categoría'),
            ),
            ...categorias.map((cat) {
              final isActive = cat.activo;
              return DropdownMenuItem<CategoriaEntity>(
                value: cat,
                child: Row(
                  children: [
                    if (!isActive)
                      Icon(Icons.visibility_off,
                          size: 16, color: colorScheme.error),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        isActive ? cat.nombre : '${cat.nombre} (inactiva)',
                        style: TextStyle(
                          color: isActive ? null : colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: (nuevaCat) {
            setState(() {
              if (nuevaCat != null) {
                _categoriaIdSeleccionada = nuevaCat.id;
                _categoriaSeleccionada = nuevaCat.nombre;
              } else {
                _categoriaIdSeleccionada = null;
                _categoriaSeleccionada = 'General';
              }
            });
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Text(
        'Error al cargar categorías: $err',
        style: TextStyle(color: colorScheme.error),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(ColorScheme colorScheme, bool isMobile) {
    final esEdicion = widget.producto != null && !widget.esDuplicado;

    return DialogHeader(
      icon: widget.esDuplicado
          ? Icons.copy_outlined
          : esEdicion
              ? Icons.edit_outlined
              : Icons.add_shopping_cart_outlined,
      title: widget.esDuplicado
          ? 'Duplicar Producto'
          : esEdicion
              ? 'Editar Producto'
              : 'Nuevo Producto',
      subtitle: esEdicion
          ? 'Actualiza los datos del producto'
          : 'Registra un nuevo producto en el catálogo',
      color: colorScheme.primary,
    );
  }

  // ==================== ACCIONES ====================
  Widget _buildAcciones(ColorScheme colorScheme, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MouseRegion(
          cursor: _guardando
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: SizedBox(
            height: 52,
            child: TextButton(
              onPressed: _guardando ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        MouseRegion(
          cursor: _guardando
              ? SystemMouseCursors.forbidden
              : SystemMouseCursors.click,
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _guardando ? null : _guardar,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _guardando
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Guardar Producto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== CAMPOS DE TEXTO ====================
  Widget _campoCodigoBarras(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _codigoController,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: _inputDecor(
            label: 'Código de Barras *',
            icon: Icons.qr_code,
            colorScheme: colorScheme,
            isDark: Theme.of(context).brightness == Brightness.dark,
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Requerido';
            return null;
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildBotonCodigo(
              icon: Icons.refresh_rounded,
              label: 'Generar',
              onPressed: _generandoCodigo ? null : _generarCodigoBarras,
              color: colorScheme.primary,
            ),
            _buildBotonCodigo(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Escanear',
              onPressed: _escanearCodigoBarras,
              color: colorScheme.secondary,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBotonCodigo({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return MouseRegion(
      cursor: onPressed == null
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.2),
          backgroundColor: color.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _campoNombre(ColorScheme colorScheme) {
    return TextFormField(
      controller: _nombreController,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: _inputDecor(
        label: 'Nombre del Producto *',
        icon: Icons.label_outline,
        colorScheme: colorScheme,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Requerido';
        return null;
      },
    );
  }

  Widget _campoPrecio(ColorScheme colorScheme) {
    return TextFormField(
      controller: _precioController,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: _inputDecor(
        label: 'Precio (\$) *',
        icon: Icons.attach_money,
        colorScheme: colorScheme,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        final val = double.tryParse(v);
        if (val == null || val < 0) return 'Precio inválido';
        return null;
      },
    );
  }

  Widget _campoStock(ColorScheme colorScheme) {
    return TextFormField(
      controller: _stockController,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: _inputDecor(
        label: 'Stock Inicial *',
        icon: Icons.inventory_outlined,
        colorScheme: colorScheme,
        isDark: Theme.of(context).brightness == Brightness.dark,
        suffix: _esPesado ? 'kg' : 'unid',
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        final val = double.tryParse(v);
        if (val == null || val < 0) return 'Stock inválido';
        return null;
      },
    );
  }

  Widget _campoStockMinimo(ColorScheme colorScheme) {
    return TextFormField(
      controller: _stockMinController,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: _inputDecor(
        label: 'Stock Mínimo *',
        icon: Icons.warning_amber_outlined,
        colorScheme: colorScheme,
        isDark: Theme.of(context).brightness == Brightness.dark,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Requerido';
        final val = double.tryParse(v);
        if (val == null || val < 0) return 'Stock mínimo inválido';
        return null;
      },
    );
  }

  // ==================== IMAGE SECTION ====================
  Widget _buildImageSection(ColorScheme colorScheme, bool isMobile) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.image_outlined,
                  color: colorScheme.primary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Imagen del producto',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _imagenSeleccionada != null
                  ? Image.file(
                      File(_imagenSeleccionada!.path),
                      fit: BoxFit.cover,
                    )
                  : _imagenUrlPreview.isNotEmpty &&
                          _imagenUrlPreview.startsWith('http')
                      ? Image.network(
                          _imagenUrlPreview,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.broken_image,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        )
                      : Icon(
                          Icons.image_outlined,
                          size: 64,
                          color: colorScheme.onSurfaceVariant,
                        ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildImageButton(
                icon: Icons.photo_library,
                label: 'Galería',
                onPressed: () => _seleccionarImagen(ImageSource.gallery),
                color: colorScheme.primary,
              ),
              _buildImageButton(
                icon: Icons.camera_alt,
                label: 'Cámara',
                onPressed: () => _seleccionarImagen(ImageSource.camera),
                color: colorScheme.primary,
              ),
              if (_imagenSeleccionada != null ||
                  (_imagenUrlPreview.isNotEmpty &&
                      _imagenUrlPreview.startsWith('http')))
                _buildImageButton(
                  icon: Icons.delete_outline,
                  label: 'Eliminar',
                  onPressed: _limpiarImagen,
                  color: _colorDanger,
                ),
            ],
          ),
          if (_subiendoImagen) ...[
            const SizedBox(height: 10),
            LinearProgressIndicator(
              backgroundColor: colorScheme.surfaceContainerHighest,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 4),
            Text(
              'Subiendo imagen...',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImageButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label, style: const TextStyle(fontSize: 13)),
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.2),
          backgroundColor: color.withValues(alpha: 0.06),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ==================== INPUT DECOR HELPER ====================
  InputDecoration _inputDecor({
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool isDark,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      prefixIcon: Icon(icon, color: colorScheme.primary),
      suffixText: suffix,
      suffixStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    );
  }
}

// ==================== PANEL LATERAL DE PROVEEDORES ====================
class _ProveedoresPanelDialog extends StatefulWidget {
  final List<ProveedorEntity> proveedores;
  final ProveedorEntity? seleccionado;
  final void Function(ProveedorEntity) onSeleccionar;
  final VoidCallback onCrearProveedor;

  const _ProveedoresPanelDialog({
    required this.proveedores,
    this.seleccionado,
    required this.onSeleccionar,
    required this.onCrearProveedor,
  });

  @override
  State<_ProveedoresPanelDialog> createState() =>
      _ProveedoresPanelDialogState();
}

class _ProveedoresPanelDialogState extends State<_ProveedoresPanelDialog> {
  String _busqueda = '';

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  List<ProveedorEntity> get _proveedoresFiltrados {
    var lista = widget.proveedores;
    if (_busqueda.isNotEmpty) {
      final q = _busqueda.toLowerCase();
      lista = lista.where((p) =>
          p.nombre.toLowerCase().contains(q) ||
          (p.empresa ?? '').toLowerCase().contains(q) ||
          (p.telefono ?? '').contains(q)).toList();
    }
    return lista;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      alignment: Alignment.centerRight,
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.9,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surface.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              // ===== HEADER =====
              const DialogHeader(
                icon: Icons.business_center_rounded,
                title: 'Proveedores',
                subtitle: 'Selecciona uno o crea uno nuevo',
              ),
              const SizedBox(height: 16),

              // ===== BÚSQUEDA =====
              GlassSearchBar(
                hint: 'Buscar por nombre, empresa o teléfono...',
                onChanged: (val) => setState(() => _busqueda = val),
              ),
              const SizedBox(height: 12),

              // ===== LISTA =====
              Expanded(
                child: _proveedoresFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_center_rounded,
                                size: 48,
                                color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text(
                              'No hay proveedores',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _proveedoresFiltrados.length,
                        separatorBuilder: (context, index) => Divider(
                          color: colorScheme.outlineVariant
                              .withValues(alpha: 0.4),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final proveedor = _proveedoresFiltrados[index];
                          final seleccionado =
                              widget.seleccionado?.id == proveedor.id;
                          final isActivo = proveedor.activo;

                          return MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: ListTile(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    _colorPrimary.withValues(alpha: 0.12),
                                child: const Icon(
                                  Icons.business_center_rounded,
                                  color: _colorPrimary,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                proveedor.nombre,
                                style: TextStyle(
                                  fontWeight: seleccionado
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: seleccionado
                                      ? _colorPrimary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (proveedor.empresa?.isNotEmpty ?? false)
                                    Text(proveedor.empresa!,
                                        style: const TextStyle(fontSize: 12)),
                                  if (proveedor.telefono?.isNotEmpty ?? false)
                                    Text('Tel: ${proveedor.telefono}',
                                        style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isActivo
                                              ? _colorSuccess
                                              : _colorDanger)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      isActivo ? 'Activo' : 'Inactivo',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isActivo
                                            ? _colorSuccess
                                            : _colorDanger,
                                      ),
                                    ),
                                  ),
                                  if (seleccionado) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: _colorPrimary,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                              onTap: () {
                                widget.onSeleccionar(proveedor);
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),

              // ===== CREAR NUEVO =====
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: widget.onCrearProveedor,
                    icon: const Icon(Icons.add_circle_outline, size: 18),
                    label: const Text(
                      'Crear Nuevo Proveedor',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}