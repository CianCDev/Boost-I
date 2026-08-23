import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/provedor_autocomplete.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/productor_selector.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalle_producto_card.dart';

class CrearPedidoProveedorScreen extends ConsumerStatefulWidget {
  const CrearPedidoProveedorScreen({super.key});

  @override
  ConsumerState<CrearPedidoProveedorScreen> createState() => _CrearPedidoProveedorScreenState();
}

class _CrearPedidoProveedorScreenState extends ConsumerState<CrearPedidoProveedorScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para proveedores (permite el autocompletado en tiempo real)
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  List<ProveedorEntity> _proveedores = [];
  ProveedorEntity? _proveedorSeleccionado;

  int _localDestinoId = 1;
  final List<DetallePedidoEntity> _detalles = [];

  final TextEditingController _cantidadController = TextEditingController(text: '1');
  final TextEditingController _precioController = TextEditingController();
  ProductoEntity? _productoSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarProveedores();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _telefonoController.dispose();
    _cantidadController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  Future<void> _cargarProveedores() async {
    final isar = ref.read(isarServiceProvider);
    final proveedores = await isar.obtenerProveedores(soloActivos: true);
    setState(() {
      _proveedores = proveedores;
    });
  }

  void _seleccionarProveedor(ProveedorEntity proveedor) {
    setState(() {
      _proveedorSeleccionado = proveedor;
      _nombreController.text = proveedor.nombre;
      _cedulaController.text = proveedor.cedula ?? '';
      _telefonoController.text = proveedor.telefono ?? '';
    });
  }

  void _agregarProducto() {
    if (_productoSeleccionado == null) {
      _mostrarSnackbar('Selecciona un producto');
      return;
    }
    final cantidad = double.tryParse(_cantidadController.text) ?? 0;
    final precio = double.tryParse(_precioController.text) ?? 0;
    if (cantidad <= 0 || precio <= 0) {
      _mostrarSnackbar('Cantidad y precio deben ser mayores a 0');
      return;
    }

    final detalle = DetallePedidoEntity()
      ..pedidoId = 0
      ..productoId = _productoSeleccionado!.id
      ..nombreProducto = _productoSeleccionado!.nombre
      ..cantidad = cantidad
      ..precioUnidad = precio
      ..subtotal = cantidad * precio;

    setState(() {
      _detalles.add(detalle);
      _productoSeleccionado = null;
      _cantidadController.text = '1';
      _precioController.clear();
    });
  }

  void _mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: const Color(0xFF424242),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _guardarPedido() async {
    if (!_formKey.currentState!.validate()) return;
    if (_detalles.isEmpty) {
      _mostrarSnackbar('Agrega al menos un producto');
      return;
    }
    if (_proveedorSeleccionado == null) {
      _mostrarSnackbar('Por favor, selecciona un proveedor válido de la lista.');
      return;
    }

    final pedido = PedidoEntity()
      ..localOrigenId = 1
      ..localDestinoId = _localDestinoId
      ..usuarioId = 1
      ..fechaPedido = DateTime.now()
      ..estado = EstadoPedido.pendiente
      ..proveedorNombre = _proveedorSeleccionado!.nombre
      ..proveedorCedula = _proveedorSeleccionado!.cedula
      ..proveedorTelefono = _proveedorSeleccionado!.telefono
      ..proveedorEmpresa = _proveedorSeleccionado!.empresa
      ..total = _detalles.fold(0.0, (sum, d) => sum + d.subtotal)
      ..sincronizado = false;

    try {
      await ref.read(crearPedidoProvider(
        (pedido: pedido, detalles: _detalles),
      ).future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Pedido creado correctamente'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            margin: EdgeInsets.all(16),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (context.mounted) {
        _mostrarSnackbar('❌ Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productosAsync = ref.watch(productosParaPedidosProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          // ✅ Padding inferior aumentado para que el FAB no tape el contenido
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSeccionProveedor(),
              const SizedBox(height: 20),
              _buildSeccionLocal(),
              const SizedBox(height: 20),
              _buildSeccionProductos(productosAsync),
              const SizedBox(height: 20),
              _buildResumen(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'Nuevo Pedido a Proveedor',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          onPressed: _guardarPedido,
          icon: const Icon(Icons.save_rounded),
        ),
      ],
    );
  }

  Widget _buildSeccionProveedor() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      // ✅ Sin borde lateral para evitar líneas blancas en modo oscuro
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Datos del Proveedor',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Buscar por nombre',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            ProveedorAutocomplete(
              proveedores: _proveedores,
              onSelected: _seleccionarProveedor,
            ),
            const SizedBox(height: 12),
            _buildCampoTexto(
              label: 'Nombre del Proveedor *',
              controller: _nombreController,
              readOnly: true,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 8),
            _buildCampoTexto(
              label: 'Cédula / RIF',
              controller: _cedulaController,
              readOnly: true,
            ),
            const SizedBox(height: 8),
            _buildCampoTexto(
              label: 'Teléfono',
              controller: _telefonoController,
              readOnly: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTexto({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
        filled: true,
        fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildSeccionLocal() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none, // ✅ Sin borde
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.storefront_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Local Destino',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _localDestinoId,
              items: const [
                DropdownMenuItem(value: 1, child: Text('Local Principal')),
                DropdownMenuItem(value: 2, child: Text('Local Secundario')),
              ],
              onChanged: (value) => setState(() => _localDestinoId = value!),
              dropdownColor: colorScheme.surface,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Selecciona un local',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                filled: true,
                fillColor: isDark ? colorScheme.surfaceContainerHighest : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionProductos(AsyncValue<List<ProductoEntity>> productosAsync) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide.none, // ✅ Sin borde
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag_rounded, color: colorScheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Agregar Productos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 12),
            productosAsync.when(
              data: (todos) {
                final List<ProductoEntity> filtrados = _proveedorSeleccionado != null
    ? todos.where((p) => p.proveedorId == _proveedorSeleccionado!.id || p.proveedorId == null).toList()
    : todos;
                return ProductoSelector(
                  productos: filtrados,
                  valorSeleccionado: _productoSeleccionado,
                  onChanged: (value) => setState(() => _productoSeleccionado = value),
                  cantidadController: _cantidadController,
                  precioController: _precioController,
                  onAgregar: _agregarProducto,
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
            const SizedBox(height: 12),
            if (_detalles.isNotEmpty) ...[
              const Divider(),
              Text(
                'Productos agregados:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurface),
              ),
              const SizedBox(height: 8),
              AnimationLimiter(
                child: Column(
                  children: _detalles.map((d) {
                    return AnimationConfiguration.staggeredList(
                      position: _detalles.indexOf(d),
                      duration: const Duration(milliseconds: 300),
                      child: SlideAnimation(
                        verticalOffset: 30,
                        curve: Curves.easeOutCubic,
                        child: FadeInAnimation(
                          curve: Curves.easeOutCubic,
                          child: DetalleProductoCard(
                            detalle: d,
                            onEliminar: () => setState(() => _detalles.remove(d)),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResumen() {
    final total = _detalles.fold(0.0, (sum, d) => sum + d.subtotal);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4F46E5).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total del Pedido', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          Text('Bs ${total.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    return FloatingActionButton.extended(
      onPressed: _guardarPedido,
      backgroundColor: const Color(0xFF8B5CF6),
      foregroundColor: Colors.white,
      elevation: 4,
      icon: const Icon(Icons.save_rounded),
      label: const Text('Guardar Pedido'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}