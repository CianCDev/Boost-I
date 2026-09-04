import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart' as pedidos;
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart' as proveedores;
import 'package:app_boosti_v2/features/pos/presentation/providers/bcv_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../../providers/local_actual_provider.dart';
import '../../providers/isar_provider.dart';
import '../../providers/usuario_provider.dart';

class CrearPedidoDialog extends ConsumerStatefulWidget {
  const CrearPedidoDialog({super.key});

  @override
  ConsumerState<CrearPedidoDialog> createState() => _CrearPedidoDialogState();
}

class _CrearPedidoDialogState extends ConsumerState<CrearPedidoDialog> {
  // ==================== ESTADO ====================
  ProveedorEntity? _proveedorSeleccionado;
  final List<DetallePedidoEntity> _detalles = [];
  final TextEditingController _observacionesController = TextEditingController();
  final TextEditingController _busquedaProveedorController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController(text: '1.0');
  final FocusNode _cantidadFocusNode = FocusNode();

  bool _isSaving = false;
  int? _productoSeleccionadoId;
  String _categoriaSeleccionada = 'Todas';
  List<String> _categorias = ['Todas'];
  Map<int, Set<String>> _categoriasPorProveedor = {};

  // ==================== ESTADO PARA MODO ====================
  bool _modoBultos = false;
  final TextEditingController _unidadesCantidadController = TextEditingController(text: '1.0');
  final TextEditingController _unidadesPrecioController = TextEditingController(text: '0.00');
  final TextEditingController _bultosCantidadController = TextEditingController(text: '1');
  final TextEditingController _bultosUnidadesPorBultoController = TextEditingController(text: '1');
  final TextEditingController _bultosPrecioPorBultoController = TextEditingController(text: '0.00');

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
    _unidadesCantidadController.addListener(_actualizarCantidadControllerPrincipal);
    _bultosCantidadController.addListener(_actualizarCantidadControllerPrincipal);
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _busquedaProveedorController.dispose();
    _cantidadController.dispose();
    _cantidadFocusNode.dispose();
    _unidadesCantidadController.removeListener(_actualizarCantidadControllerPrincipal);
    _bultosCantidadController.removeListener(_actualizarCantidadControllerPrincipal);
    _unidadesCantidadController.dispose();
    _unidadesPrecioController.dispose();
    _bultosCantidadController.dispose();
    _bultosUnidadesPorBultoController.dispose();
    _bultosPrecioPorBultoController.dispose();
    super.dispose();
  }

  // ==================== INICIALIZACIÓN ====================
  Future<void> _cargarDatosIniciales() async {
    final isar = ref.read(pedidos.isarServiceProvider);
    final productos = await isar.obtenerProductos();

    final categoriasSet = <String>{};
    final provCats = <int, Set<String>>{};

    for (var p in productos) {
      final categoria = p.categoria.trim();
      if (categoria.isNotEmpty) {
        categoriasSet.add(categoria);
        if (p.proveedorId != null) {
          provCats.putIfAbsent(p.proveedorId!, () => {}).add(categoria);
        }
      }
    }

    final categoriasList = categoriasSet.toList()..sort();
    categoriasList.insert(0, 'Todas');

    setState(() {
      _categorias = categoriasList;
      _categoriasPorProveedor = provCats;
    });
  }

  void _actualizarCantidadControllerPrincipal() {
    if (_modoBultos) {
      _cantidadController.text = _bultosCantidadController.text;
    } else {
      _cantidadController.text = _unidadesCantidadController.text;
    }
  }

  // ==================== CÁLCULOS ====================
  double _calcularTotalUnidades() {
    if (_modoBultos) {
      final bultos = double.tryParse(_bultosCantidadController.text) ?? 0.0;
      final undPorBulto = double.tryParse(_bultosUnidadesPorBultoController.text) ?? 1.0;
      return bultos * undPorBulto;
    } else {
      return double.tryParse(_unidadesCantidadController.text) ?? 0.0;
    }
  }

  double _calcularCostoUnitarioEfectivo() {
    if (_modoBultos) {
      final undPorBulto = double.tryParse(_bultosUnidadesPorBultoController.text) ?? 1.0;
      final precioBulto = double.tryParse(_bultosPrecioPorBultoController.text) ?? 0.0;
      return undPorBulto > 0 ? precioBulto / undPorBulto : 0.0;
    } else {
      return double.tryParse(_unidadesPrecioController.text) ?? 0.0;
    }
  }

  List<ProveedorEntity> _filtrarProveedoresPorCategoria(List<ProveedorEntity> proveedores) {
    if (_categoriaSeleccionada == 'Todas') return proveedores;
    return proveedores.where((p) {
      final categorias = _categoriasPorProveedor[p.id] ?? {};
      return categorias.contains(_categoriaSeleccionada);
    }).toList();
  }

  // ==================== AGREGAR PRODUCTO ====================
  void _agregarProducto() {
    if (_proveedorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un proveedor primero')),
      );
      return;
    }
    if (_productoSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un producto de la lista')),
      );
      return;
    }

    final cantidad = _calcularTotalUnidades();
    final precioUnitario = _calcularCostoUnitarioEfectivo();

    if (cantidad <= 0 || precioUnitario <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad y el precio deben ser mayores a 0')),
      );
      return;
    }

    final productosAsync = ref.read(proveedores.productosPorProveedorProvider(_proveedorSeleccionado!.id));
    productosAsync.whenData((productos) {
      final producto = productos.firstWhere(
        (p) => p.id == _productoSeleccionadoId,
        orElse: () => ProductoEntity(),
      );

      if (producto.id == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto no encontrado en este proveedor')),
        );
        return;
      }

      if (producto.precioUnidad <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El producto no tiene precio definido')),
        );
        return;
      }

      final index = _detalles.indexWhere((d) => d.productoId == producto.id);
      if (index != -1) {
        if (_detalles[index].precioUnidad != precioUnitario) {
          _detalles[index].precioUnidad = precioUnitario;
        }
        _detalles[index].cantidad += cantidad;
        _detalles[index].subtotal = _detalles[index].cantidad * _detalles[index].precioUnidad;
        setState(() {});
      } else {
        final detalle = DetallePedidoEntity()
          ..productoId = producto.id
          ..nombreProducto = producto.nombre
          ..cantidad = cantidad
          ..precioUnidad = precioUnitario
          ..subtotal = cantidad * precioUnitario;
        setState(() {
          _detalles.add(detalle);
        });
      }

      setState(() {
        _productoSeleccionadoId = null;
        _unidadesCantidadController.text = '1.0';
        _unidadesPrecioController.text = '0.00';
        _bultosCantidadController.text = '1';
        _bultosUnidadesPorBultoController.text = '1';
        _bultosPrecioPorBultoController.text = '0.00';
        _actualizarCantidadControllerPrincipal();
      });
      _cantidadFocusNode.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${producto.nombre} agregado'),
          duration: const Duration(seconds: 1),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    });
  }

  // ==================== GUARDAR PEDIDO (VERSIÓN PROFESIONAL) ====================
  Future<void> _guardarPedido() async {
    if (_proveedorSeleccionado == null || _detalles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Agrega al menos un producto antes de crear el pedido'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // ============================================================
      // 1. OBTENER LOCAL ACTUAL (profesional y robusto)
      // ============================================================
      final isar = ref.read(pedidos.isarServiceProvider);
      final localActualId = ref.read(localActualProvider);
      
      int localId = 1; // fallback
      
      if (localActualId != null) {
        final local = await isar.obtenerLocalPorId(localActualId);
        if (local != null && local.activo) {
          localId = local.id;
          debugPrint('✅ Local actual obtenido: ID=$localId, Nombre=${local.nombre}');
        } else {
          debugPrint('⚠️ Local actual (ID $localActualId) no existe o está inactivo. Buscando otro...');
          // Buscar el primer local activo
          final locales = await isar.obtenerLocales(soloActivos: true);
          if (locales.isNotEmpty) {
            localId = locales.first.id;
            debugPrint('✅ Usando primer local activo: ID=$localId, Nombre=${locales.first.nombre}');
          } else {
            debugPrint('⚠️ No hay locales activos. Usando fallback ID=1');
          }
        }
      } else {
        debugPrint('⚠️ No hay local actual seleccionado. Buscando el primer local activo...');
        final locales = await isar.obtenerLocales(soloActivos: true);
        if (locales.isNotEmpty) {
          localId = locales.first.id;
          debugPrint('✅ Usando primer local activo: ID=$localId, Nombre=${locales.first.nombre}');
        } else {
          debugPrint('⚠️ No hay locales activos. Usando fallback ID=1');
        }
      }

      // ============================================================
      // 2. OBTENER USUARIO ACTUAL
      // ============================================================
      final usuario = ref.read(usuarioActualProvider);
      final int usuarioId = usuario?.id ?? 1;
      debugPrint('👤 Usuario actual: ID=$usuarioId, Nombre=${usuario?.nombre ?? 'Desconocido'}');

      // ============================================================
      // 3. CREAR PEDIDO
      // ============================================================
      final pedido = PedidoEntity()
        ..proveedorNombre = _proveedorSeleccionado!.nombre
        ..proveedorCedula = _proveedorSeleccionado!.cedula
        ..proveedorTelefono = _proveedorSeleccionado!.telefono
        ..proveedorEmpresa = _proveedorSeleccionado!.empresa
        ..fechaPedido = DateTime.now()
        ..estado = EstadoPedido.pendiente
        ..observaciones = _observacionesController.text
        ..total = _detalles.fold<double>(0.0, (sum, d) => sum + d.subtotal)
        ..localOrigenId = localId      // ✅ Ahora usa el local correcto
        ..localDestinoId = localId     // ✅ Ahora usa el local correcto
        ..usuarioId = usuarioId
        ..sincronizado = false;

      debugPrint('📦 Pedido creado con localOrigenId=$localId, localDestinoId=$localId, usuarioId=$usuarioId');

      // ============================================================
      // 4. GUARDAR EN ISAR
      // ============================================================
      final pedidoId = await isar.guardarPedido(pedido);
      for (var detalle in _detalles) {
        detalle.pedidoId = pedidoId;
        await isar.guardarDetallePedido(detalle);
      }

      // ============================================================
      // 5. SINCRONIZAR (con manejo de errores)
      // ============================================================
      try {
        await ref.read(pedidos.syncServiceProvider).sincronizarPedidosPendientes();
        debugPrint('✅ Pedido sincronizado exitosamente');
      } catch (e) {
        debugPrint('❌ Error sincronizando pedido automáticamente: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⚠️ Pedido guardado, pero falló la sincronización automática: ${e.toString().substring(0, 100)}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // ============================================================
      // 6. FEEDBACK AL USUARIO
      // ============================================================
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pedido creado correctamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('❌ Error guardando pedido: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar el pedido: ${e.toString().substring(0, 100)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ==================== BUILD (resto del código sin cambios) ====================
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    final proveedoresAsync = ref.watch(pedidos.proveedoresActivosProvider);
    final productosFiltradosAsync = _proveedorSeleccionado != null
        ? ref.watch(proveedores.productosPorProveedorProvider(_proveedorSeleccionado!.id))
        : const AsyncValue<List<ProductoEntity>>.data([]);

    final totalPedido = _detalles.fold<double>(0.0, (sum, d) => sum + d.subtotal);
    final tasaBcv = ref.watch(bcvProvider).tasa;
    final totalBs = totalPedido * tasaBcv;

    final double totalUnidades = _calcularTotalUnidades();
    final double costoUnitario = _calcularCostoUnitarioEfectivo();
    final double subtotalProducto = totalUnidades * costoUnitario;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 700,
              maxHeight: MediaQuery.of(context).size.height * 0.92,
            ),
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: -10,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // HEADER
                  _buildHeader(isDark, isMobile),
                  const SizedBox(height: 16),

                  // PROVEEDOR
                  _buildProveedorSection(isDark, isMobile, proveedoresAsync),
                  const SizedBox(height: 16),

                  // SELECCIÓN DE PRODUCTOS
                  if (_proveedorSeleccionado != null)
                    _buildProductoSection(
                      isDark,
                      isMobile,
                      productosFiltradosAsync,
                      totalUnidades,
                      costoUnitario,
                      subtotalProducto,
                    ),
                  const SizedBox(height: 16),

                  // TOTAL Y OBSERVACIONES
                  _buildResumenYObservaciones(isDark, isMobile, totalPedido, totalBs),
                  const SizedBox(height: 24),

                  // BOTONES
                  _buildBotones(isDark, isMobile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(bool isDark, bool isMobile) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            'Crear Pedido a Proveedor',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 18 : 22,
              color: isDark ? Colors.white : const Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ============================================================
  // SECCIÓN PROVEEDOR
  // ============================================================
  Widget _buildProveedorSection(bool isDark, bool isMobile, AsyncValue<List<ProveedorEntity>> proveedoresAsync) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.business_center_rounded, size: 18, color: const Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              Text(
                'Seleccionar Proveedor',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filtro por categoría
          proveedoresAsync.when(
            data: (proveedores) {
              return DropdownButtonFormField<String>(
                initialValue: _categoriaSeleccionada,
                hint: Text(
                  'Filtrar por categoría',
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                ),
                items: _categorias.map((cat) {
                  return DropdownMenuItem<String>(
                    value: cat,
                    child: Text(cat, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSeleccionada = value ?? 'Todas';
                    _proveedorSeleccionado = null;
                    _productoSeleccionadoId = null;
                    _detalles.clear();
                    _busquedaProveedorController.clear();
                  });
                },
                decoration: _inputDecor('Categoría', Icons.category_rounded, isDark),
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
          const SizedBox(height: 12),

          // Autocomplete de proveedores
          proveedoresAsync.when(
            data: (proveedores) {
              final proveedoresFiltrados = _filtrarProveedoresPorCategoria(proveedores);

              if (proveedores.isEmpty) {
                return Center(
                  child: Text(
                    'No hay proveedores activos. Crea uno primero.',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                  ),
                );
              }

              if (proveedoresFiltrados.isEmpty && _categoriaSeleccionada != 'Todas') {
                return Center(
                  child: Text(
                    'No hay proveedores para la categoría "$_categoriaSeleccionada"',
                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                  ),
                );
              }

              return Autocomplete<ProveedorEntity>(
                key: ValueKey(_categoriaSeleccionada),
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) return proveedoresFiltrados;
                  return proveedoresFiltrados.where((p) =>
                      p.nombre.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                displayStringForOption: (proveedor) => proveedor.nombre,
                onSelected: (proveedor) {
                  setState(() {
                    _proveedorSeleccionado = proveedor;
                    _detalles.clear();
                    _productoSeleccionadoId = null;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                    onChanged: (value) {
                      if (value.trim().isEmpty && _proveedorSeleccionado != null) {
                        setState(() {
                          _proveedorSeleccionado = null;
                          _detalles.clear();
                          _productoSeleccionadoId = null;
                        });
                      }
                    },
                    decoration: _inputDecor('Buscar Proveedor *', Icons.search_rounded, isDark),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) {
                  return Material(
                    elevation: 4,
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final option = options.elementAt(index);
                          return ListTile(
                            title: Text(option.nombre, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                            subtitle: option.cedula != null
                                ? Text('RIF: ${option.cedula}', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))
                                : null,
                            leading: Icon(Icons.business_rounded, color: const Color(0xFF8B5CF6)),
                            onTap: () => onSelected(option),
                            hoverColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECCIÓN PRODUCTO
  // ============================================================
  Widget _buildProductoSection(
    bool isDark,
    bool isMobile,
    AsyncValue<List<ProductoEntity>> productosFiltradosAsync,
    double totalUnidades,
    double costoUnitario,
    double subtotalProducto,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shopping_bag_rounded, size: 18, color: const Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              Text(
                'Seleccionar Producto',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Autocomplete de productos
          productosFiltradosAsync.when(
            data: (productos) {
              final productosFiltrados = _categoriaSeleccionada == 'Todas'
                  ? productos
                  : productos.where((p) => p.categoria == _categoriaSeleccionada).toList();

              if (productosFiltrados.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No hay productos para la categoría "$_categoriaSeleccionada" en este proveedor.',
                      style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                    ),
                  ),
                );
              }

              final productosOrdenados = List<ProductoEntity>.from(productosFiltrados)
                ..sort((a, b) => a.nombre.compareTo(b.nombre));

              return Column(
                children: [
                  Autocomplete<int>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return productosOrdenados.map((p) => p.id).toList();
                      }
                      return productosOrdenados
                          .where((p) => p.nombre
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()))
                          .map((p) => p.id)
                          .toList();
                    },
                    displayStringForOption: (id) {
                      final producto = productosOrdenados.firstWhere((p) => p.id == id);
                      return '${producto.nombre} (Stock: ${producto.stock})';
                    },
                    onSelected: (id) {
                      setState(() {
                        _productoSeleccionadoId = id;
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                        decoration: _inputDecor('Buscar producto *', Icons.search_rounded, isDark),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Material(
                        elevation: 4,
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (context, index) {
                              final id = options.elementAt(index);
                              final producto = productosOrdenados.firstWhere((p) => p.id == id);
                              return ListTile(
                                title: Text(producto.nombre, style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
                                subtitle: Text(
                                  'Stock: ${producto.stock} • Precio: \$${producto.precioUnidad}',
                                  style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
                                ),
                                leading: Icon(Icons.inventory_2_rounded, color: const Color(0xFF8B5CF6)),
                                onTap: () => onSelected(id),
                                hoverColor: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Modo de compra
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment<bool>(
                        value: false,
                        label: Text('Unidades'),
                        icon: Icon(Icons.square_outlined),
                      ),
                      ButtonSegment<bool>(
                        value: true,
                        label: Text('Bultos / Paquetes'),
                        icon: Icon(Icons.inventory_2_outlined),
                      ),
                    ],
                    selected: {_modoBultos},
                    onSelectionChanged: (Set<bool> newSelection) {
                      setState(() {
                        _modoBultos = newSelection.first;
                        _actualizarCantidadControllerPrincipal();
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      selectedBackgroundColor: const Color(0xFF8B5CF6),
                      selectedForegroundColor: Colors.white,
                      foregroundColor: isDark ? Colors.white70 : Colors.black54,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Campos dinámicos
                  if (!_modoBultos) ...[
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _unidadesCantidadController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: _inputDecor('Cantidad (Unidades)', Icons.numbers, isDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _unidadesPrecioController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: _inputDecor('Costo Unitario (USD)', Icons.attach_money, isDark),
                          ),
                        ),
                      ],
                    ),
                    if (totalUnidades > 0 && costoUnitario > 0)
                      _buildTotalPagar(isDark, subtotalProducto),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _bultosCantidadController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: _inputDecor('N° de Bultos', Icons.inventory_2_outlined, isDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _bultosUnidadesPorBultoController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: _inputDecor('Unidades / Bulto', Icons.fork_right, isDark),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _bultosPrecioPorBultoController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                            decoration: _inputDecor('Costo por Bulto (USD)', Icons.attach_money, isDark),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total Unidades',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.white54 : Colors.black54,
                                  ),
                                ),
                                Text(
                                  '${totalUnidades.toStringAsFixed(0)} und',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(0xFF8B5CF6),
                                  ),
                                ),
                                if (totalUnidades > 0 && costoUnitario > 0)
                                  Text(
                                    'Costo unitario: \$${costoUnitario.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (totalUnidades > 0 && costoUnitario > 0)
                      _buildTotalPagar(isDark, subtotalProducto),
                  ],
                  const SizedBox(height: 12),

                  // Botón Agregar
                  Row(
                    children: [
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _proveedorSeleccionado == null || _productoSeleccionadoId == null
                            ? null
                            : _agregarProducto,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 12 : 16,
                            vertical: isMobile ? 8 : 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.add_rounded, size: 18),
                            const SizedBox(width: 4),
                            const Text('Agregar'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Lista de productos agregados
                  if (_detalles.isNotEmpty) _buildListaProductosAgregados(isDark, isMobile),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDGETS AUXILIARES
  // ============================================================
  Widget _buildTotalPagar(bool isDark, double subtotal) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '▶ Total a pagar:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            Text(
              '\$${subtotal.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaProductosAgregados(bool isDark, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Text(
          'Productos agregados (${_detalles.length})',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          constraints: BoxConstraints(maxHeight: isMobile ? 120 : 150),
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _detalles.length,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemBuilder: (context, index) {
              final d = _detalles[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.inventory_2_rounded, color: const Color(0xFF8B5CF6), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        d.nombreProducto,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: SizedBox(
                        width: 50,
                        child: TextFormField(
                          initialValue: d.cantidad.toStringAsFixed(1),
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                            isDense: true,
                          ),
                          onChanged: (value) => _actualizarCantidad(index, value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '\$${d.subtotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B5CF6),
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red, size: 16),
                      onPressed: () {
                        setState(() {
                          _detalles.removeAt(index);
                        });
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _actualizarCantidad(int index, String value) {
    final cantidad = double.tryParse(value.trim());
    if (cantidad == null || cantidad <= 0) {
      setState(() {
        _detalles.removeAt(index);
      });
      return;
    }
    setState(() {
      _detalles[index].cantidad = cantidad;
      _detalles[index].subtotal = cantidad * _detalles[index].precioUnidad;
    });
  }

  Widget _buildResumenYObservaciones(bool isDark, bool isMobile, double totalPedido, double totalBs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TOTAL DEL PEDIDO (USD)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '\$${totalPedido.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
                Text(
                  '${_detalles.length} productos • Total en Bs: ${totalBs.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _observacionesController,
          maxLines: 2,
          decoration: _inputDecor('Observaciones (opcional)', Icons.note_add_rounded, isDark),
        ),
      ],
    );
  }

  Widget _buildBotones(bool isDark, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 20, vertical: isMobile ? 10 : 14),
            side: BorderSide(color: isDark ? Colors.white54 : const Color(0xFFE5E7EB)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'Cancelar',
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _isSaving || _proveedorSeleccionado == null || _detalles.isEmpty
              ? null
              : _guardarPedido,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: isMobile ? 10 : 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Crear Pedido', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // ============================================================
  // UTILIDADES DE ESTILO
  // ============================================================
  InputDecoration _inputDecor(String label, IconData icon, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
      prefixIcon: Icon(icon, color: const Color(0xFF8B5CF6)),
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE5E7EB), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}