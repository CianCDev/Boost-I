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
  List<ProveedorEntity> _proveedoresDisponibles = [];

  @override
  void initState() {
    super.initState();
    _cargarDatosIniciales();
  }

  @override
  void dispose() {
    _observacionesController.dispose();
    _busquedaProveedorController.dispose();
    _cantidadController.dispose();
    _cantidadFocusNode.dispose();
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

  // ==================== MÉTODOS DE FILTRO ====================
  List<ProveedorEntity> _filtrarProveedoresPorCategoria(
    List<ProveedorEntity> proveedores,
  ) {
    if (_categoriaSeleccionada == 'Todas') return proveedores;
    return proveedores.where((p) {
      final categorias = _categoriasPorProveedor[p.id] ?? {};
      return categorias.contains(_categoriaSeleccionada);
    }).toList();
  }

  // ==================== AGREGAR PRODUCTO (MULTIPRODUCTO) ====================
  void _agregarProducto() {
    if (_proveedorSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un proveedor primero')),
      );
      return;
    }
    if (_productoSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un producto')),
      );
      return;
    }

    final cantidad = double.tryParse(_cantidadController.text.trim());
    if (cantidad == null || cantidad <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La cantidad debe ser mayor a 0')),
      );
      return;
    }

    final productosAsync = ref.read(proveedores.productosPorProveedorProvider(_proveedorSeleccionado!.id));
    productosAsync.whenData((productos) {
      final producto = productos.firstWhere((p) => p.id == _productoSeleccionadoId);
      if (producto.precioUnidad <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('El producto no tiene precio definido')),
        );
        return;
      }

      // 🔥 Lógica multiproducto: si ya existe, suma cantidad; si no, crea nuevo
      final index = _detalles.indexWhere((d) => d.productoId == producto.id);
      if (index != -1) {
        _detalles[index].cantidad += cantidad;
        _detalles[index].subtotal = _detalles[index].cantidad * _detalles[index].precioUnidad;
        setState(() {});
      } else {
        final detalle = DetallePedidoEntity()
          ..productoId = producto.id
          ..nombreProducto = producto.nombre
          ..cantidad = cantidad
          ..precioUnidad = producto.precioUnidad
          ..subtotal = cantidad * producto.precioUnidad;
        setState(() {
          _detalles.add(detalle);
        });
      }

      // Resetear selección para continuar agregando
      setState(() {
        _productoSeleccionadoId = null;
        _cantidadController.text = '1.0';
      });
      _cantidadFocusNode.requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${producto.nombre} agregado'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // ==================== ACTUALIZAR CANTIDAD DESDE LA LISTA ====================
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

  // ==================== GUARDAR PEDIDO ====================
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
      final pedido = PedidoEntity()
        ..proveedorNombre = _proveedorSeleccionado!.nombre
        ..proveedorCedula = _proveedorSeleccionado!.cedula
        ..proveedorTelefono = _proveedorSeleccionado!.telefono
        ..proveedorEmpresa = _proveedorSeleccionado!.empresa
        ..fechaPedido = DateTime.now()
        ..estado = EstadoPedido.pendiente
        ..observaciones = _observacionesController.text
        ..total = _detalles.fold<double>(0.0, (sum, d) => sum + d.subtotal)
        ..localOrigenId = 1
        ..localDestinoId = 1
        ..usuarioId = 1
        ..sincronizado = false;

      final isar = ref.read(pedidos.isarServiceProvider);
      final pedidoId = await isar.guardarPedido(pedido);
      for (var detalle in _detalles) {
        detalle.pedidoId = pedidoId;
        await isar.guardarDetallePedido(detalle);
      }
      await ref.read(pedidos.syncServiceProvider).sincronizarPedidosPendientes();

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ==================== STEPS PARA CANTIDAD (RESPONSIVE) ====================
  Widget _buildCantidadStepper() {
    final isMobile = ResponsiveHelper.isMobile(context);
    final iconSize = isMobile ? 20.0 : 24.0;
    final fontSize = isMobile ? 14.0 : 16.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () {
            final current = double.tryParse(_cantidadController.text) ?? 1.0;
            if (current > 0.5) {
              _cantidadController.text = (current - 0.5).toStringAsFixed(1);
            }
          },
          icon: Icon(Icons.remove_circle_outline_rounded, size: iconSize),
          style: IconButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
            padding: EdgeInsets.zero,
            minimumSize: const Size(32, 32),
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: isMobile ? 36 : 44,
          child: TextFormField(
            controller: _cantidadController,
            focusNode: _cantidadFocusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: () {
            final current = double.tryParse(_cantidadController.text) ?? 1.0;
            _cantidadController.text = (current + 0.5).toStringAsFixed(1);
          },
          icon: Icon(Icons.add_circle_outline_rounded, size: iconSize),
          style: IconButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
            padding: EdgeInsets.zero,
            minimumSize: const Size(32, 32),
          ),
        ),
      ],
    );
  }

  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    final proveedoresAsync = ref.watch(pedidos.proveedoresActivosProvider);
    final productosFiltradosAsync = _proveedorSeleccionado != null
        ? ref.watch(proveedores.productosPorProveedorProvider(_proveedorSeleccionado!.id))
        : const AsyncValue<List<ProductoEntity>>.data([]);

    final totalPedido = _detalles.fold<double>(0.0, (sum, d) => sum + d.subtotal);
    final tasaBcv = ref.watch(bcvProvider).tasa;
    final totalBs = totalPedido * tasaBcv;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== HEADER =====
            Row(
              children: [
                Icon(Icons.add_shopping_cart_rounded, color: const Color(0xFF8B5CF6), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Crear Pedido a Proveedor',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== CARD: BÚSQUEDA Y SELECCIÓN DE PROVEEDOR =====
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business_center_rounded, size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Seleccionar Proveedor',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 13 : 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Filtro por categoría
                    proveedoresAsync.when(
                      data: (proveedores) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_proveedoresDisponibles.isEmpty && proveedores.isNotEmpty) {
                            setState(() {
                              _proveedoresDisponibles = proveedores;
                            });
                          }
                        });

                        return DropdownButtonFormField<String>(
                          initialValue: _categoriaSeleccionada,
                          hint: Text(
                            'Filtrar por categoría',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                          items: _categorias.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat,
                              child: Text(
                                cat,
                                style: TextStyle(color: colorScheme.onSurface),
                              ),
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
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            prefixIcon: Icon(Icons.category_rounded, color: colorScheme.onSurfaceVariant),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: colorScheme.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          isExpanded: true,
                          dropdownColor: colorScheme.surface,
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text('Error al cargar categorías: $err')),
                    ),
                    const SizedBox(height: 12),

                    // Autocomplete de proveedores con key
                    proveedoresAsync.when(
                      data: (proveedores) {
                        final proveedoresFiltrados = _filtrarProveedoresPorCategoria(proveedores);

                        if (proveedores.isEmpty) {
                          return Center(
                            child: Text(
                              'No hay proveedores activos. Crea uno primero.',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          );
                        }

                        if (proveedoresFiltrados.isEmpty && _categoriaSeleccionada != 'Todas') {
                          return Center(
                            child: Text(
                              'No hay proveedores para la categoría "$_categoriaSeleccionada"',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          );
                        }

                        return Autocomplete<ProveedorEntity>(
                          key: ValueKey(_categoriaSeleccionada),
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return proveedoresFiltrados;
                            }
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
                            if (controller.text != _busquedaProveedorController.text) {
                              _busquedaProveedorController.text = controller.text;
                            }
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              style: TextStyle(color: colorScheme.onSurface),
                              onChanged: (value) {
                                if (value.trim().isEmpty && _proveedorSeleccionado != null) {
                                  setState(() {
                                    _proveedorSeleccionado = null;
                                    _detalles.clear();
                                    _productoSeleccionadoId = null;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Buscar Proveedor *',
                                prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            );
                          },
                          optionsViewBuilder: (context, onSelected, options) {
                            return Material(
                              elevation: 4,
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                constraints: const BoxConstraints(maxHeight: 200),
                                child: ListView.builder(
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option.nombre, style: TextStyle(color: colorScheme.onSurface)),
                                      subtitle: option.cedula != null
                                          ? Text('RIF: ${option.cedula}', style: TextStyle(color: colorScheme.onSurfaceVariant))
                                          : null,
                                      leading: Icon(Icons.business_rounded, color: colorScheme.primary),
                                      onTap: () => onSelected(option),
                                      hoverColor: colorScheme.primary.withValues(alpha: 0.08),
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
              ),
            ),
            const SizedBox(height: 16),

            // ===== CARD: SELECCIÓN DE PRODUCTOS =====
            if (_proveedorSeleccionado != null)
              productosFiltradosAsync.when(
                data: (productos) {
                  // 🔥 Filtrar productos por categoría seleccionada
                  final productosFiltrados = _categoriaSeleccionada == 'Todas'
                      ? productos
                      : productos.where((p) => p.categoria == _categoriaSeleccionada).toList();

                  if (productosFiltrados.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No hay productos para la categoría "$_categoriaSeleccionada" en este proveedor.',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ),
                    );
                  }

                  final productosOrdenados = List<ProductoEntity>.from(productosFiltrados)
                    ..sort((a, b) => a.nombre.compareTo(b.nombre));

                  return Card(
                    elevation: 0,
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          Row(
                            children: [
                              Icon(Icons.shopping_bag_rounded, size: 18, color: colorScheme.primary),
                              const SizedBox(width: 8),
                              Text(
                                'Seleccionar Producto',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isMobile ? 13 : 14,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Línea 1: Autocomplete de productos (100% ancho)
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
                                style: TextStyle(color: colorScheme.onSurface),
                                decoration: InputDecoration(
                                  labelText: 'Buscar producto *',
                                  prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: colorScheme.primary, width: 2),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              );
                            },
                            optionsViewBuilder: (context, onSelected, options) {
                              return Material(
                                elevation: 4,
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  constraints: const BoxConstraints(maxHeight: 200),
                                  child: ListView.builder(
                                    itemCount: options.length,
                                    itemBuilder: (context, index) {
                                      final id = options.elementAt(index);
                                      final producto = productosOrdenados.firstWhere((p) => p.id == id);
                                      return ListTile(
                                        title: Text(producto.nombre, style: TextStyle(color: colorScheme.onSurface)),
                                        subtitle: Text(
                                          'Stock: ${producto.stock} • Precio: \$${producto.precioUnidad}',
                                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                                        ),
                                        leading: Icon(Icons.inventory_2_rounded, color: colorScheme.primary),
                                        onTap: () => onSelected(id),
                                        hoverColor: colorScheme.primary.withValues(alpha: 0.08),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 12),

                          // Línea 2: Stepper de cantidad + Botón Agregar (responsivo)
                          Row(
                            children: [
                              const Text(
                                'Cantidad:',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(width: 12),
                              _buildCantidadStepper(),
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
                                  textStyle: TextStyle(
                                    fontSize: isMobile ? 12 : 14,
                                  ),
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

                          // Lista de productos agregados (multiproducto)
                          if (_detalles.isNotEmpty) ...[
                            const Divider(),
                            Text(
                              'Productos agregados (${_detalles.length})',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 12 : 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              constraints: BoxConstraints(
                                maxHeight: isMobile ? 120 : 150,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: colorScheme.outlineVariant,
                                  width: 1,
                                ),
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
                                        Icon(
                                          Icons.inventory_2_rounded,
                                          color: colorScheme.primary,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            d.nombreProducto,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              color: colorScheme.onSurface,
                                              fontSize: isMobile ? 12 : 13,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          width: isMobile ? 50 : 60,
                                          child: TextFormField(
                                            initialValue: d.cantidad.toStringAsFixed(1),
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                              color: colorScheme.onSurface,
                                              fontSize: isMobile ? 12 : 13,
                                            ),
                                            textAlign: TextAlign.center,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 4,
                                              ),
                                              isDense: true,
                                            ),
                                            onChanged: (value) => _actualizarCantidad(index, value),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '\$${d.subtotal.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                            fontSize: isMobile ? 12 : 13,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _detalles.removeAt(index);
                                            });
                                          },
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            const SizedBox(height: 16),
            Divider(color: colorScheme.outlineVariant),

            // ===== TOTAL =====
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
                        color: colorScheme.onSurfaceVariant,
                        fontSize: isMobile ? 10 : 12,
                      ),
                    ),
                    Text(
                      '\$${totalPedido.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 20 : 22,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                    Text(
                      '${_detalles.length} productos • Total en Bs: ${totalBs.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 13,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ===== OBSERVACIONES =====
            TextFormField(
              controller: _observacionesController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Observaciones',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 24),

            // ===== BOTONES =====
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isSaving ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 10 : 14,
                    ),
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: isMobile ? 13 : 14,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 24,
                      vertical: isMobile ? 10 : 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: TextStyle(fontSize: isMobile ? 13 : 14),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Crear Pedido'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}