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
import '../../services/sync_service.dart';
import '../../utils/responsive_helper.dart';
import '../proveedores/crear_proveedor_dialog.dart';

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
  final TextEditingController _proveedorNombreController = TextEditingController();
  final TextEditingController _proveedorTelController = TextEditingController();
  final TextEditingController _proveedorBusquedaController = TextEditingController();
  final TextEditingController _marcaBusquedaController = TextEditingController();

  late String _categoriaSeleccionada;
  int? _categoriaIdSeleccionada;
  late bool _esPesado;
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final p = widget.producto;
    final esDuplicado = widget.esDuplicado;
    final stockBase = esDuplicado ? 0.0 : p?.stock ?? 0.0;

    _codigoController.text = p?.codigoBarras ?? widget.codigoBarrasPrecargado ?? '';
    _nombreController.text = p?.nombre ?? '';
    _precioController.text = p?.precioUnidad.toString() ?? '';
    _stockController.text = stockBase.toStringAsFixed(0);
    _stockMinController.text = p?.stockMinimo.toString() ?? '5.0';
    _proveedorNombreController.text = p?.proveedorNombre ?? '';
    _proveedorTelController.text = p?.proveedorTelefono ?? '';

    _categoriaIdSeleccionada = p?.categoriaId;
    _categoriaSeleccionada = p?.categoria ?? 'General';
    _esPesado = p?.esPesado ?? false;
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

  // ==================== PROVEEDORES ====================
  Future<void> _cargarProveedores() async {
    setState(() => _cargandoProveedores = true);
    try {
      final syncService = SyncService();
      await syncService.descargarProveedoresDesdeSupabase();
      final isar = IsarService();
      final proveedores = await isar.obtenerProveedores(soloActivos: true);
      debugPrint('📦 [ProductForm] Proveedores cargados: ${proveedores.length}');
      setState(() {
        _proveedores = proveedores;
        // Si el producto tiene un proveedor asignado, seleccionarlo
        if (widget.producto?.proveedorId != null) {
          _proveedorSeleccionado = proveedores.firstWhereOrNull(
            (p) => p.id == widget.producto!.proveedorId,
          );
          if (_proveedorSeleccionado != null) {
            _proveedorNombreController.text = _proveedorSeleccionado!.nombre;
            _proveedorTelController.text = _proveedorSeleccionado!.telefono ?? '';
            _proveedorBusquedaController.text = _proveedorSeleccionado!.nombre;
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
      builder: (context) => CrearProveedorDialog(),
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
            onSeleccionar: (p) {
              Navigator.pop(context, p);
            },
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
          mensaje: 'Se necesita acceso a la galería/cámara para seleccionar una imagen.',
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

      // ✅ Asignar marca
      producto.marcaSupabaseId = _marcaSeleccionada?.supabaseId;
      producto.marca = _marcaSeleccionada?.nombre ?? '';

      producto.imagenUrl = imagenUrlFinal;
      producto.precioUnidad = double.tryParse(_precioController.text) ?? 0.0;
      producto.stock = double.tryParse(_stockController.text) ?? 0.0;
      producto.stockMinimo = double.tryParse(_stockMinController.text) ?? 5.0;
      producto.categoriaId = _categoriaIdSeleccionada;
      producto.categoria = _categoriaSeleccionada;
      producto.esPesado = _esPesado;

      // ✅ Asignar proveedor
      producto.proveedorId = _proveedorSeleccionado?.id;
      producto.proveedorNombre = _proveedorSeleccionado?.nombre ?? '';
      producto.proveedorTelefono = _proveedorSeleccionado?.telefono ?? '';
      producto.proveedorEmail = _proveedorSeleccionado?.email ?? '';
      producto.proveedorDireccion = _proveedorSeleccionado?.direccion ?? '';

      producto.updatedAt = DateTime.now();

      await widget.onGuardar(producto);

      if (mounted) {
        _mostrarDialogoExito(
          titulo: '✅ Producto ${widget.producto != null ? 'actualizado' : 'creado'}',
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
      final fileName = '${codigo}_${DateTime.now().millisecondsSinceEpoch}.$ext';
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
  void _mostrarDialogoExito({required String titulo, required String mensaje}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLottieWithFallback('assets/animations/success.json'),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Aceptar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(
          children: [
            Icon(
              esError ? Icons.error_outline_rounded : Icons.info_outline,
              color: esError ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
            ),
            const SizedBox(width: 8),
            Text(
              titulo,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (esError)
              _buildLottieWithFallback('assets/animations/error.json')
            else
              const Icon(Icons.info_outline, size: 60, color: Color(0xFF3B82F6)),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cerrar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
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
          assetPath.contains('error') ? Icons.error_outline_rounded : Icons.check_circle_rounded,
          size: 80,
          color: assetPath.contains('error') ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        );
      },
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final Color color = colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(colorScheme, isMobile, color),
            const SizedBox(height: 16),
            TabBar(
              controller: _tabController,
              indicatorColor: color,
              dividerColor: Colors.transparent,
              labelColor: color,
              unselectedLabelColor: colorScheme.onSurfaceVariant,
              tabs: const [
                Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Producto'),
                Tab(icon: Icon(Icons.business_center_rounded), text: 'Proveedor'),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildProductTab(colorScheme, isDark, isMobile),
                    _buildProveedorTab(colorScheme, isDark, isMobile),
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
  Widget _buildProductTab(ColorScheme colorScheme, bool isDark, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _campoCodigoBarras(colorScheme, isDark),
          const SizedBox(height: 16),
          _campoNombre(colorScheme, isDark),
          const SizedBox(height: 16),
          _campoSelectorMarca(colorScheme, isDark),
          const SizedBox(height: 16),
          _campoCategoriaSelector(colorScheme, isDark),
          const SizedBox(height: 16),
          _buildSwitchPesado(colorScheme, colorScheme.primary),
          const SizedBox(height: 16),
          _buildImageSection(colorScheme, isDark, isMobile),
          const SizedBox(height: 16),
          _buildPrecioStock(colorScheme, isDark, isMobile),
        ],
      ),
    );
  }

  // ==================== PESTAÑA PROVEEDOR ====================
  Widget _buildProveedorTab(ColorScheme colorScheme, bool isDark, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          _buildSelectorProveedor(colorScheme, isDark, isMobile),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _crearProveedorRapido,
              icon: Icon(Icons.add_circle_outline, color: colorScheme.onPrimary),
              label: const Text('Crear nuevo proveedor'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
  Widget _buildSwitchPesado(ColorScheme colorScheme, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Text(
          '¿Es producto pesado (granel)?',
          style: TextStyle(
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        value: _esPesado,
        onChanged: (val) => setState(() => _esPesado = val),
        activeThumbColor: color,
        activeTrackColor: color.withValues(alpha: 0.3),
        tileColor: Colors.transparent,
        dense: true,
      ),
    );
  }

  // ==================== PRECIO Y STOCK ====================
  Widget _buildPrecioStock(ColorScheme colorScheme, bool isDark, bool isMobile) {
    return isMobile
        ? Column(
            children: [
              _campoPrecio(colorScheme, isDark),
              const SizedBox(height: 12),
              _campoStock(colorScheme, isDark),
              const SizedBox(height: 12),
              _campoStockMinimo(colorScheme, isDark),
            ],
          )
        : Row(
            children: [
              Expanded(child: _campoPrecio(colorScheme, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _campoStock(colorScheme, isDark)),
              const SizedBox(width: 12),
              Expanded(child: _campoStockMinimo(colorScheme, isDark)),
            ],
          );
  }

  // ==================== SELECTOR DE PROVEEDOR ====================
  Widget _buildSelectorProveedor(ColorScheme colorScheme, bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center_rounded, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Proveedores',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.view_list_rounded, color: colorScheme.primary),
                tooltip: 'Ver todos',
                onPressed: _abrirPanelProveedores,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
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
                          fontSize: 14,
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
                            (p.empresa ?? '').toLowerCase().contains(query));
                      },
                      displayStringForOption: (proveedor) => proveedor.nombre,
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _proveedorBusquedaController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Buscar proveedor...',
                            prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                            filled: true,
                            fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                            color: Colors.transparent,
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return Material(
                                    color: Colors.transparent,
                                    child: ListTile(
                                      title: Text(option.nombre),
                                      subtitle: option.empresa != null && option.empresa!.isNotEmpty
                                          ? Text(option.empresa!, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant))
                                          : null,
                                      onTap: () => onSelected(option),
                                      leading: Icon(Icons.business, color: colorScheme.primary),
                                      tileColor: option == _proveedorSeleccionado
                                          ? colorScheme.primary.withValues(alpha: 0.1)
                                          : null,
                                    ),
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

  // ==================== TARJETA DE PROVEEDOR SELECCIONADO (CORREGIDA) ====================
  Widget _buildProveedorSeleccionadoCard(ColorScheme colorScheme) {
    final proveedor = _proveedorSeleccionado!;
    final isActivo = proveedor.activo;

    return Card(
      elevation: 0,
      color: colorScheme.primary.withValues(alpha: 0.04),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Proveedor seleccionado',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Nombre
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

            const SizedBox(height: 4),

            // Teléfono
            if (proveedor.telefono != null && proveedor.telefono!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.phone_rounded,
                text: proveedor.telefono!,
                colorScheme: colorScheme,
              ),

            // Email
            if (proveedor.email != null && proveedor.email!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.email_rounded,
                text: proveedor.email!,
                colorScheme: colorScheme,
              ),

            // Dirección
            if (proveedor.direccion != null && proveedor.direccion!.isNotEmpty)
              _buildDetailRow(
                icon: Icons.location_on_rounded,
                text: proveedor.direccion!,
                colorScheme: colorScheme,
              ),

            const SizedBox(height: 4),

            // Estado activo/inactivo
            Row(
              children: [
                Icon(
                  isActivo ? Icons.circle : Icons.circle_outlined,
                  size: 12,
                  color: isActivo ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 6),
                Text(
                  isActivo ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActivo ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Método auxiliar para construir cada fila de detalle
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
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
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
  Widget _campoSelectorMarca(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.branding_watermark_outlined, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Marca (opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                        'No hay marcas disponibles. Crea una desde "Gestionar marcas".',
                        style: TextStyle(
                          fontSize: 14,
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
                            (m.descripcion ?? '').toLowerCase().contains(query));
                      },
                      displayStringForOption: (marca) => marca.nombre,
                      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                        _marcaBusquedaController.text = controller.text;
                        return TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: 'Buscar marca...',
                            prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                            filled: true,
                            fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                            color: Colors.transparent,
                            child: Container(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (context, index) {
                                  final option = options.elementAt(index);
                                  return Material(
                                    color: Colors.transparent,
                                    child: ListTile(
                                      title: Text(option.nombre),
                                      subtitle: option.descripcion != null && option.descripcion!.isNotEmpty
                                          ? Text(option.descripcion!, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant))
                                          : null,
                                      onTap: () => onSelected(option),
                                      leading: Icon(Icons.branding_watermark_rounded, color: colorScheme.primary),
                                      tileColor: option == _marcaSeleccionada
                                          ? colorScheme.primary.withValues(alpha: 0.1)
                                          : null,
                                    ),
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
                color: colorScheme.primary.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.15),
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
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.branding_watermark_rounded,
                          size: 20,
                          color: colorScheme.primary,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.branding_watermark_rounded,
                      size: 20,
                      color: colorScheme.primary,
                    ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _marcaSeleccionada!.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16, color: colorScheme.onSurfaceVariant),
                    onPressed: () => _seleccionarMarca(null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
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
  Widget _campoCategoriaSelector(ColorScheme colorScheme, bool isDark) {
    final categoriasAsync = ref.watch(todasLasCategoriasProvider);

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
          value: categoriaSeleccionada,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Categoría *',
            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            prefixIcon: Icon(Icons.category_outlined, color: colorScheme.primary),
            filled: true,
            fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                      Icon(Icons.visibility_off, size: 16, color: colorScheme.error),
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
          validator: (value) => null,
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Text(
        'Error al cargar categorías: $err',
        style: TextStyle(color: colorScheme.error),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(ColorScheme colorScheme, bool isMobile, Color color) {
    final esEdicion = widget.producto != null && !widget.esDuplicado;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            widget.esDuplicado
                ? Icons.copy_outlined
                : esEdicion
                    ? Icons.edit_outlined
                    : Icons.add_shopping_cart_outlined,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.esDuplicado
                ? 'Duplicar Producto'
                : esEdicion
                    ? 'Editar Producto'
                    : 'Nuevo Producto',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 20 : 24,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ==================== ACCIONES ====================
  Widget _buildAcciones(ColorScheme colorScheme, bool isMobile) {
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: isMobile ? 20 : 32,
      vertical: 14,
    );
    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 12,
      runSpacing: 12,
      children: [
        TextButton(
          onPressed: _guardando ? null : () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: buttonPadding,
            minimumSize: const Size(80, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Cancelar',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: buttonPadding,
            minimumSize: const Size(120, 48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _guardando
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: colorScheme.onPrimary,
                  ),
                )
              : Text(
                  'Guardar Producto',
                  style: TextStyle(fontSize: isMobile ? 16 : 18),
                ),
        ),
      ],
    );
  }

  // ==================== CAMPOS DE TEXTO ====================
  Widget _campoCodigoBarras(ColorScheme colorScheme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _codigoController,
          decoration: InputDecoration(
            labelText: 'Código de Barras *',
            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            prefixIcon: Icon(Icons.qr_code, color: colorScheme.primary),
            filled: true,
            fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Requerido';
            return null;
          },
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
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
              onPressed: () {
                _mostrarDialogoSimple(
                  titulo: 'Escáner',
                  mensaje: 'Función de escaneo disponible en el catálogo.',
                  esError: false,
                );
              },
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
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label, style: const TextStyle(fontSize: 14)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withValues(alpha: 0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: color.withValues(alpha: 0.3)),
        ),
        minimumSize: const Size(80, 40),
      ),
    );
  }

  Widget _campoNombre(ColorScheme colorScheme, bool isDark) {
    return TextFormField(
      controller: _nombreController,
      decoration: InputDecoration(
        labelText: 'Nombre del Producto *',
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.label_outline, color: colorScheme.primary),
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Requerido';
        return null;
      },
    );
  }

  Widget _campoPrecio(ColorScheme colorScheme, bool isDark) {
    return TextFormField(
      controller: _precioController,
      decoration: InputDecoration(
        labelText: 'Precio (\$) *',
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.attach_money, color: colorScheme.primary),
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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

  Widget _campoStock(ColorScheme colorScheme, bool isDark) {
    return TextFormField(
      controller: _stockController,
      decoration: InputDecoration(
        labelText: 'Stock Inicial *',
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.inventory_outlined, color: colorScheme.primary),
        suffixText: _esPesado ? 'kg' : 'unid',
        suffixStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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

  Widget _campoStockMinimo(ColorScheme colorScheme, bool isDark) {
    return TextFormField(
      controller: _stockMinController,
      decoration: InputDecoration(
        labelText: 'Stock Mínimo *',
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        prefixIcon: Icon(Icons.warning_amber_outlined, color: colorScheme.primary),
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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

  // ==================== IMAGEN SECTION ====================
  Widget _buildImageSection(ColorScheme colorScheme, bool isDark, bool isMobile) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Imagen del producto',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline,
              ),
            ),
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
                        errorBuilder: (_, _, _) => Icon(
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
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildImageButton(
                context,
                icon: Icons.photo_library,
                label: 'Galería',
                onPressed: () => _seleccionarImagen(ImageSource.gallery),
                color: colorScheme.primary,
              ),
              _buildImageButton(
                context,
                icon: Icons.camera_alt,
                label: 'Cámara',
                onPressed: () => _seleccionarImagen(ImageSource.camera),
                color: colorScheme.primary,
              ),
              if (_imagenSeleccionada != null ||
                  (_imagenUrlPreview.isNotEmpty &&
                      _imagenUrlPreview.startsWith('http')))
                _buildImageButton(
                  context,
                  icon: Icons.delete_outline,
                  label: 'Eliminar',
                  onPressed: _limpiarImagen,
                  color: Colors.red,
                ),
            ],
          ),
          if (_subiendoImagen) ...[
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: null,
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

  Widget _buildImageButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.blue,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withValues(alpha: 0.2)),
          ),
        ),
      ),
    );
  }
}

// ==================== PANEL LATERAL DE PROVEEDORES (CORREGIDO) ====================
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
  State<_ProveedoresPanelDialog> createState() => _ProveedoresPanelDialogState();
}

class _ProveedoresPanelDialogState extends State<_ProveedoresPanelDialog> {
  final TextEditingController _busquedaController = TextEditingController();
  final TextEditingController _filtroMarcaController = TextEditingController();
  String _busqueda = '';
  String _filtroMarca = '';

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
    return Dialog(
      insetPadding: const EdgeInsets.all(8),
      alignment: Alignment.centerRight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.7,
          height: MediaQuery.of(context).size.height * 0.9,
          color: colorScheme.surface,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                  border: Border(
                    bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.2)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business_center_rounded, color: colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Proveedores',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _busquedaController,
                      decoration: InputDecoration(
                        hintText: 'Buscar proveedor...',
                        prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      onChanged: (val) => setState(() => _busqueda = val),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _filtroMarcaController,
                      decoration: InputDecoration(
                        hintText: 'Filtrar por marca (TODO)',
                        prefixIcon: Icon(Icons.filter_alt_outlined, color: colorScheme.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                      ),
                      onChanged: (val) => setState(() => _filtroMarca = val),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _proveedoresFiltrados.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_center_rounded, size: 48, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text(
                              'No hay proveedores',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: _proveedoresFiltrados.length,
                        separatorBuilder: (_, __) => Divider(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final proveedor = _proveedoresFiltrados[index];
                          final seleccionado = widget.seleccionado?.id == proveedor.id;
                          final isActivo = proveedor.activo;
                          return Material(
                            type: MaterialType.transparency,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                                child: Icon(Icons.business_center_rounded, color: colorScheme.primary),
                              ),
                              title: Text(
                                proveedor.nombre,
                                style: TextStyle(
                                  fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
                                  color: seleccionado ? colorScheme.primary : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (proveedor.empresa != null && proveedor.empresa!.isNotEmpty)
                                    Text(proveedor.empresa!, style: TextStyle(fontSize: 12)),
                                  if (proveedor.telefono != null && proveedor.telefono!.isNotEmpty)
                                    Text('Tel: ${proveedor.telefono}', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isActivo ? Icons.circle : Icons.circle_outlined,
                                    size: 12,
                                    color: isActivo ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  if (seleccionado)
                                    Icon(Icons.check_circle_rounded, color: colorScheme.primary),
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
              Padding(
                padding: const EdgeInsets.all(12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onCrearProveedor,
                    icon: Icon(Icons.add_circle_outline, color: colorScheme.onPrimary),
                    label: const Text('Crear Nuevo Proveedor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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

  @override
  void dispose() {
    _busquedaController.dispose();
    _filtroMarcaController.dispose();
    super.dispose();
  }
}