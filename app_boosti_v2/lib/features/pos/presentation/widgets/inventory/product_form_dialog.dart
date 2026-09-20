// lib/features/pos/presentation/widgets/product/product_form_dialog.dart
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

// ignore: unused_import
import '../../../data/Local/entities/categoria_entity.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../../data/Local/entities/proveedor_entity.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../../data/Local/entities/marca_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/productos_provider.dart';
import '../../services/sync_service.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/tenant_utils.dart';
import '../common/dialog_header.dart';
import '../common/glass_dialog.dart';
import '../proveedores/crear_proveedor_dialog.dart';
import '../shared/barcode_scanner_dialog.dart';
import 'product_data_tab.dart';
import 'product_detail_dialog.dart';
import 'product_proveedor_tab.dart';

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

  // Controllers
  final _codigoCtrl = TextEditingController();
  final _nombreCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _stockMinCtrl = TextEditingController();
  final _provBusqCtrl = TextEditingController();
  final _precioMayorCtrl = TextEditingController();
  final _cantMinMayorCtrl = TextEditingController();
  final _precioMedioMayorCtrl = TextEditingController();
  final _cantMinMedioMayorCtrl = TextEditingController();
  final _unidadesBultoCtrl = TextEditingController(text: '1');
  final _costoUnitarioCtrl = TextEditingController();

  // State
  int? _categoriaIdSel;
  String _categoriaSel = 'General';
  bool _esPesado = false;
  bool _activo = true;
  bool _permiteVentaMayor = false;
  String _imagenUrlPreview = '';
  XFile? _imagenSel;
  bool _subiendoImagen = false;
  bool _guardando = false;
  bool _generandoCodigo = false;

  ProveedorEntity? _proveedorSel;
  List<ProveedorEntity> _proveedores = [];
  bool _cargandoProveedores = false;

  MarcaEntity? _marcaSel;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorInfo = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarInicial();
    _cargarProveedores();
  }

  @override
  void dispose() {
    _guardarBorrador();
    _tabController.dispose();
    _codigoCtrl.dispose();
    _nombreCtrl.dispose();
    _precioCtrl.dispose();
    _stockCtrl.dispose();
    _stockMinCtrl.dispose();
    _provBusqCtrl.dispose();
    _precioMayorCtrl.dispose();
    _cantMinMayorCtrl.dispose();
    _precioMedioMayorCtrl.dispose();
    _cantMinMedioMayorCtrl.dispose();
    _unidadesBultoCtrl.dispose();
    _costoUnitarioCtrl.dispose();
    super.dispose();
  }

  void _cargarInicial() {
    final p = widget.producto;
    final stockBase = widget.esDuplicado ? 0.0 : p?.stock ?? 0.0;

    _codigoCtrl.text = p?.codigoBarras ?? widget.codigoBarrasPrecargado ?? '';
    _nombreCtrl.text = p?.nombre ?? '';
    _precioCtrl.text = p?.precioUnidad.toString() ?? '';
    _stockCtrl.text = stockBase.toStringAsFixed(0);
    _stockMinCtrl.text = p?.stockMinimo.toString() ?? '5.0';

    _categoriaIdSel = p?.categoriaId;
    _categoriaSel = p?.categoria ?? 'General';
    _esPesado = p?.esPesado ?? false;
    _activo = p?.activo ?? true;
    _imagenUrlPreview = p?.imagenUrl ?? '';

    _permiteVentaMayor = p?.permiteVentaMayor ?? false;
    _precioMayorCtrl.text = p?.precioMayor?.toString() ?? '';
    _cantMinMayorCtrl.text = p?.cantidadMinimaMayor?.toString() ?? '';
    _precioMedioMayorCtrl.text = p?.precioMedioMayor?.toString() ?? '';
    _cantMinMedioMayorCtrl.text =
        p?.cantidadMinimaMedioMayor?.toString() ?? '';
    _unidadesBultoCtrl.text = (p?.unidadesPorBulto ?? 1).toString();
    _costoUnitarioCtrl.text = p?.costoUnitarioPromedio?.toString() ?? '';
  }

  double? _parseDouble(String t) {
    final s = t.trim();
    if (s.isEmpty) return null;
    return double.tryParse(s.replaceAll(',', '.'));
  }

  int? _parseInt(String t) {
    final s = t.trim();
    if (s.isEmpty) return null;
    return int.tryParse(s);
  }

  Future<void> _guardarBorrador() async {
    if (widget.producto != null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_DRAFT_KEY, '{}');
  }

  // ═══════════════════════════════════════════════════════════════
  // PROVEEDORES
  // ═══════════════════════════════════════════════════════════════

  Future<void> _cargarProveedores() async {
    setState(() => _cargandoProveedores = true);
    try {
      await SyncService().descargarProveedoresDesdeSupabase();
      final proveedores =
          await IsarService().obtenerProveedores(soloActivos: true);
      if (!mounted) return;
      setState(() {
        _proveedores = proveedores;
        if (widget.producto?.proveedorId != null) {
          _proveedorSel = proveedores.firstWhereOrNull(
            (p) => p.id == widget.producto!.proveedorId,
          );
          if (_proveedorSel != null) {
            _provBusqCtrl.text = _proveedorSel!.nombre;
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
      builder: (_) => const CrearProveedorDialog(),
    );
    if (result == true) {
      await _cargarProveedores();
      if (_proveedores.isNotEmpty) {
        final nuevo = _proveedores.last;
        setState(() {
          _proveedorSel = nuevo;
          _provBusqCtrl.text = nuevo.nombre;
        });
      }
    }
  }

  void _seleccionarProveedor(ProveedorEntity? proveedor) {
    setState(() {
      _proveedorSel = proveedor;
      _provBusqCtrl.text = proveedor?.nombre ?? '';
    });
  }

  Future<void> _abrirPanelProveedores() async {
    final sel = await showGeneralDialog<ProveedorEntity>(
      context: context,
      pageBuilder: (ctx, anim, sec) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: anim,
          curve: Curves.easeOutCubic,
        )),
        child: ProveedoresPanelDialog(
          proveedores: _proveedores,
          seleccionado: _proveedorSel,
          onSeleccionar: (p) => Navigator.pop(ctx, p),
          onCrearProveedor: () async {
            Navigator.pop(ctx);
            await _crearProveedorRapido();
            if (mounted) _abrirPanelProveedores();
          },
        ),
      ),
      transitionDuration: const Duration(milliseconds: 350),
      barrierDismissible: true,
      barrierLabel: 'Cerrar panel',
    );
    if (sel != null) _seleccionarProveedor(sel);
  }

  // ═══════════════════════════════════════════════════════════════
  // CÓDIGO DE BARRAS
  // ═══════════════════════════════════════════════════════════════

  Future<void> _generarCodigo() async {
    setState(() => _generandoCodigo = true);
    try {
      final codigo = await IsarService().generarCodigoBarrasUnico();
      _codigoCtrl.text = codigo;
    } catch (e) {
      if (mounted) {
        _mostrarDialogoSimple(
          titulo: 'Error',
          mensaje: 'Error al generar código: $e',
          esError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _generandoCodigo = false);
    }
  }

  Future<void> _escanearCodigo() async {
    final codigo = await showDialog<String>(
      context: context,
      builder: (_) => const BarcodeScannerDialog(),
    );
    if (codigo == null || codigo.isEmpty) return;

    final productos = ref.read(productosProvider).items;
    final existente = productos.firstWhere(
      (p) => p.codigoBarras == codigo,
      orElse: () => ProductoEntity(),
    );

    if (existente.id != 0) {
      final accion = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Código ya registrado'),
          content: Text(
            'El código "$codigo" pertenece a:\n\n'
            '📦 ${existente.nombre}\n'
            '💰 \$${existente.precioUnidad}\n\n'
            '¿Qué deseas hacer?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'continuar'),
              child: const Text('Crear nuevo de todos modos'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorPrimary,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx, 'editar'),
              child: const Text('Editar existente'),
            ),
          ],
        ),
      );
      if (accion == 'editar') {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (ctx) => ProductDetailDialog(
            producto: existente,
            esAdmin: widget.usuarioActual?.rol == 'admin',
            onEditar: () {
              Navigator.pop(ctx);
              _abrirFormEdicion(existente);
            },
            onEliminar: () async => Navigator.pop(ctx),
          ),
        );
        return;
      }
    }
    _codigoCtrl.text = codigo;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Código escaneado'),
        backgroundColor: _colorSuccess,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _abrirFormEdicion(ProductoEntity producto) {
    showDialog(
      context: context,
      builder: (ctx) => ProductFormDialog(
        producto: producto,
        usuarioActual: widget.usuarioActual,
        onGuardar: (edit) async {
          await ref
              .read(productosProvider.notifier)
              .guardarProducto(edit, widget.usuarioActual!, esNuevo: false);
          if (mounted) Navigator.pop(ctx);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // IMAGEN
  // ═══════════════════════════════════════════════════════════════

  Future<void> _pickImage(ImageSource source) async {
    if (!await _checkPermission()) {
      if (mounted) {
        _mostrarDialogoSimple(
          titulo: 'Permiso denegado',
          mensaje: 'Se necesita acceso a la galería/cámara.',
          esError: true,
        );
      }
      return;
    }
    setState(() => _subiendoImagen = true);
    try {
      final image = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );
      if (image != null && mounted) {
        setState(() {
          _imagenSel = image;
          _imagenUrlPreview = image.path;
        });
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

  void _clearImagen() {
    setState(() {
      _imagenSel = null;
      _imagenUrlPreview = '';
    });
  }

  Future<String?> _uploadImage(File image, String codigo) async {
    try {
      final tenantId = getTenantIdFromJWT();
      if (tenantId == null || tenantId.isEmpty) return null;

      final ext = image.path.split('.').last;
      final fileName =
          '$tenantId/productos/${codigo}_${DateTime.now().millisecondsSinceEpoch}.$ext';

      await Supabase.instance.client.storage
          .from('productos')
          .upload(fileName, image);

      return Supabase.instance.client.storage
          .from('productos')
          .getPublicUrl(fileName);
    } catch (e) {
      debugPrint('❌ [_uploadImage] $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // GUARDAR
  // ═══════════════════════════════════════════════════════════════

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      _mostrarDialogoSimple(
        titulo: 'Campos incompletos',
        mensaje: 'Completa todos los campos obligatorios.',
        esError: true,
      );
      return;
    }

    if (_permiteVentaMayor) {
      final pm = _parseDouble(_precioMayorCtrl.text);
      final cm = _parseInt(_cantMinMayorCtrl.text);
      if (pm == null || pm <= 0) {
        _mostrarDialogoSimple(
          titulo: 'Falta precio mayor',
          mensaje: 'Debes ingresar un precio mayor válido.',
          esError: true,
        );
        return;
      }
      if (cm == null || cm <= 0) {
        _mostrarDialogoSimple(
          titulo: 'Falta cantidad mínima',
          mensaje: 'Debes indicar la cantidad mínima.',
          esError: true,
        );
        return;
      }
    }

    setState(() => _guardando = true);

    try {
      String imagenUrlFinal = _imagenUrlPreview;

      if (_imagenSel != null) {
        setState(() => _subiendoImagen = true);
        try {
          final url = await _uploadImage(
            File(_imagenSel!.path),
            _codigoCtrl.text.trim(),
          );
          if (url != null && url.isNotEmpty) {
            imagenUrlFinal = url;
          } else if (_imagenUrlPreview.startsWith('http')) {
            imagenUrlFinal = _imagenUrlPreview;
          } else {
            imagenUrlFinal = '';
          }
        } finally {
          if (mounted) setState(() => _subiendoImagen = false);
        }
      }

      final p = widget.producto ?? ProductoEntity();
      if (widget.esDuplicado) {
        p.id = Isar.autoIncrement;
        p.stock = 0.0;
      }
      p.codigoBarras = _codigoCtrl.text.trim();
      p.nombre = _nombreCtrl.text.trim();
      p.marcaSupabaseId = _marcaSel?.supabaseId;
      p.marca = _marcaSel?.nombre ?? '';
      p.imagenUrl = imagenUrlFinal;
      p.precioUnidad = _parseDouble(_precioCtrl.text) ?? 0.0;
      p.stock = _parseDouble(_stockCtrl.text) ?? 0.0;
      p.stockMinimo = _parseDouble(_stockMinCtrl.text) ?? 5.0;
      p.categoriaId = _categoriaIdSel;
      p.categoria = _categoriaSel;
      p.esPesado = _esPesado;
      p.activo = _activo;
      p.proveedorId = _proveedorSel?.id;
      p.proveedorNombre = _proveedorSel?.nombre ?? '';
      p.proveedorTelefono = _proveedorSel?.telefono ?? '';
      p.proveedorEmail = _proveedorSel?.email ?? '';
      p.proveedorDireccion = _proveedorSel?.direccion ?? '';
      p.updatedAt = DateTime.now();

      p.permiteVentaMayor = _permiteVentaMayor;
      if (_permiteVentaMayor) {
        p.precioMayor = _parseDouble(_precioMayorCtrl.text);
        p.cantidadMinimaMayor = _parseInt(_cantMinMayorCtrl.text);
        p.precioMedioMayor = _parseDouble(_precioMedioMayorCtrl.text);
        p.cantidadMinimaMedioMayor =
            _parseInt(_cantMinMedioMayorCtrl.text);
        p.unidadesPorBulto = _parseInt(_unidadesBultoCtrl.text) ?? 1;
        p.costoUnitarioPromedio = _parseDouble(_costoUnitarioCtrl.text);
      } else {
        p.precioMayor = null;
        p.cantidadMinimaMayor = null;
        p.precioMedioMayor = null;
        p.cantidadMinimaMedioMayor = null;
        p.unidadesPorBulto = 1;
        p.costoUnitarioPromedio = null;
      }

      await widget.onGuardar(p);

      if (mounted) {
        _mostrarDialogoExito(
          titulo: 'Producto ${widget.producto != null ? 'actualizado' : 'creado'}',
          mensaje: '"${p.nombre}" guardado correctamente.',
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

  // ═══════════════════════════════════════════════════════════════
  // FEEDBACK
  // ═══════════════════════════════════════════════════════════════

  void _mostrarDialogoExito({
    required String titulo,
    required String mensaje,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => GlassDialog(
        maxWidth: 420,
        accentColor: _colorSuccess,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _lottie('assets/animations/success.json'),
              const SizedBox(height: 12),
              Text(titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: _colorSuccess)),
              const SizedBox(height: 8),
              Text(mensaje,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      height: 1.4)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorSuccess,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Aceptar',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
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
      builder: (ctx) => GlassDialog(
        maxWidth: 420,
        accentColor: esError ? _colorDanger : _colorInfo,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (esError)
                _lottie('assets/animations/error.json')
              else
                const Icon(Icons.info_outline_rounded,
                    size: 60, color: _colorInfo),
              const SizedBox(height: 12),
              Text(titulo,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: esError ? _colorDanger : _colorInfo)),
              const SizedBox(height: 8),
              Text(mensaje,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                      height: 1.4)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cerrar',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lottie(String path) {
    return Lottie.asset(
      path,
      width: 120,
      height: 120,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        path.contains('error')
            ? Icons.error_outline_rounded
            : Icons.check_circle_rounded,
        size: 80,
        color: path.contains('error') ? _colorDanger : _colorSuccess,
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

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
            _buildHeader(cs),
            const SizedBox(height: 16),
            _buildTabBar(cs, isMobile),
            const SizedBox(height: 12),
            Flexible(
              child: Form(
                key: _formKey,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ProductDataTab(
                      codigoController: _codigoCtrl,
                      nombreController: _nombreCtrl,
                      precioController: _precioCtrl,
                      stockController: _stockCtrl,
                      stockMinController: _stockMinCtrl,
                      precioMayorController: _precioMayorCtrl,
                      cantidadMinimaMayorController: _cantMinMayorCtrl,
                      precioMedioMayorController: _precioMedioMayorCtrl,
                      cantidadMinimaMedioMayorController:
                          _cantMinMedioMayorCtrl,
                      unidadesPorBultoController: _unidadesBultoCtrl,
                      costoUnitarioController: _costoUnitarioCtrl,
                      esPesado: _esPesado,
                      activo: _activo,
                      permiteVentaMayor: _permiteVentaMayor,
                      generandoCodigo: _generandoCodigo,
                      subiendoImagen: _subiendoImagen,
                      categoriaIdSeleccionada: _categoriaIdSel,
                      categoriaSeleccionada: _categoriaSel,
                      marcaSeleccionada: _marcaSel,
                      imagenUrlPreview: _imagenUrlPreview,
                      imagenSeleccionada: _imagenSel,
                      onEsPesadoChanged: (v) =>
                          setState(() => _esPesado = v),
                      onActivoChanged: (v) => setState(() => _activo = v),
                      onPermiteVentaMayorChanged: (v) =>
                          setState(() => _permiteVentaMayor = v),
                      onMarcaChanged: (m) => setState(() => _marcaSel = m),
                      onCategoriaChanged: (c) {
                        setState(() {
                          if (c != null) {
                            _categoriaIdSel = c.id;
                            _categoriaSel = c.nombre;
                          } else {
                            _categoriaIdSel = null;
                            _categoriaSel = 'General';
                          }
                        });
                      },
                      onGenerarCodigo: _generarCodigo,
                      onEscanear: _escanearCodigo,
                      onPickImage: _pickImage,
                      onClearImage: _clearImagen,
                    ),
                    ProductProveedorTab(
                      proveedores: _proveedores,
                      proveedorSeleccionado: _proveedorSel,
                      cargandoProveedores: _cargandoProveedores,
                      onAbrirPanel: _abrirPanelProveedores,
                      onCrearProveedor: _crearProveedorRapido,
                      onSeleccionar: _seleccionarProveedor,
                      busquedaController: _provBusqCtrl,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildAcciones(cs),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    final edicion = widget.producto != null && !widget.esDuplicado;
    return DialogHeader(
      icon: widget.esDuplicado
          ? Icons.copy_outlined
          : edicion
              ? Icons.edit_outlined
              : Icons.add_shopping_cart_outlined,
      title: widget.esDuplicado
          ? 'Duplicar producto'
          : edicion
              ? 'Editar producto'
              : 'Nuevo producto',
      subtitle: edicion
          ? 'Actualiza los datos del producto'
          : 'Registra un nuevo producto en el catálogo',
      color: cs.primary,
    );
  }

  Widget _buildTabBar(ColorScheme cs, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: TextStyle(
          fontWeight: FontWeight.bold,
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
    );
  }

  Widget _buildAcciones(ColorScheme cs) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
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
                color: cs.onSurfaceVariant,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _guardando ? null : _guardar,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
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
                        strokeWidth: 2.4, color: Colors.white),
                  )
                : const Text(
                    'Guardar Producto',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }
}