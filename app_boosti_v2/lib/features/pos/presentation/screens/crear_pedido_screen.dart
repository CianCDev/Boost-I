import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart'; // ✅ Importación correcta
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
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

  String _proveedorNombre = '';
  String _proveedorCedula = '';
  String _proveedorTelefono = '';
  String _proveedorEmpresa = '';

  int _localDestinoId = 1;
  final List<DetallePedidoEntity> _detalles = [];

  final TextEditingController _cantidadController = TextEditingController(text: '1');
  final TextEditingController _precioController = TextEditingController();

  ProductoEntity? _productoSeleccionado;
  List<String> _proveedoresDisponibles = [];

  @override
  void initState() {
    super.initState();
    _cargarProveedores();
  }

  Future<void> _cargarProveedores() async {
    final isar = ref.read(isarServiceProvider);
    final productos = await isar.obtenerProductos();
    final empresas = productos
        .map((p) => p.proveedorEmpresa)
        .where((e) => e != null && e!.isNotEmpty)
        .map((e) => e!)
        .toSet()
        .toList()
      ..sort();
    setState(() {
      _proveedoresDisponibles = empresas;
    });
  }

  void _seleccionarProveedor(String empresa) {
    setState(() {
      _proveedorEmpresa = empresa;
      _proveedorNombre = '';
      _proveedorTelefono = '';
    });
    _autoCompletarDatosProveedor(empresa);
  }

  Future<void> _autoCompletarDatosProveedor(String empresa) async {
    final isar = ref.read(isarServiceProvider);
    final productos = await isar.obtenerProductos();
    final producto = productos.firstWhere(
      (p) => p.proveedorEmpresa == empresa,
      orElse: () => ProductoEntity(),
    );
    if (producto.id != 0) {
      setState(() {
        _proveedorNombre = producto.proveedorNombre ?? '';
        _proveedorTelefono = producto.proveedorTelefono ?? '';
      });
    }
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
        backgroundColor: Colors.grey.shade800,
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

    final pedido = PedidoEntity()
      ..localOrigenId = 1 // TODO: obtener del usuario actual
      ..localDestinoId = _localDestinoId
      ..usuarioId = 1 // TODO: obtener del usuario actual
      ..fechaPedido = DateTime.now()
      ..estado = EstadoPedido.pendiente
      ..proveedorNombre = _proveedorNombre
      ..proveedorCedula = _proveedorCedula.isNotEmpty ? _proveedorCedula : null
      ..proveedorTelefono = _proveedorTelefono.isNotEmpty ? _proveedorTelefono : null
      ..proveedorEmpresa = _proveedorEmpresa.isNotEmpty ? _proveedorEmpresa : null
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
    // ✅ Ahora sí, usamos el provider definido en pedidos_provider.dart
    final productosAsync = ref.watch(productosParaPedidosProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
            colors: [
              Color.fromRGBO(68, 109, 241, 1),
              Color.fromARGB(255, 85, 59, 235),
            ],
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
          tooltip: 'Guardar pedido',
        ),
      ],
    );
  }

  Widget _buildSeccionProveedor() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business_rounded, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Datos del Proveedor',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Buscar por empresa', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            ProveedorAutocomplete(
              proveedoresDisponibles: _proveedoresDisponibles,
              onSelected: _seleccionarProveedor,
            ),
            const SizedBox(height: 12),
            _buildCampoTexto(
              label: 'Nombre del Proveedor *',
              initialValue: _proveedorNombre,
              onChanged: (v) => _proveedorNombre = v,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 8),
            _buildCampoTexto(
              label: 'Cédula / RIF',
              initialValue: _proveedorCedula,
              onChanged: (v) => _proveedorCedula = v,
            ),
            const SizedBox(height: 8),
            _buildCampoTexto(
              label: 'Teléfono',
              initialValue: _proveedorTelefono,
              onChanged: (v) => _proveedorTelefono = v,
            ),
            const SizedBox(height: 8),
            _buildCampoTexto(
              label: 'Empresa *',
              initialValue: _proveedorEmpresa,
              onChanged: (v) => _proveedorEmpresa = v,
              validator: (v) => v!.isEmpty ? 'Requerido' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTexto({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildSeccionLocal() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.storefront_rounded, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Local Destino',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                hintText: 'Selecciona un local',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionProductos(AsyncValue<List<ProductoEntity>> productosAsync) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag_rounded, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Agregar Productos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            productosAsync.when(
              data: (todos) {
                final filtrados = _proveedorEmpresa.isNotEmpty
                    ? todos.where((p) => p.proveedorEmpresa == _proveedorEmpresa).toList()
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
              const Text(
                'Productos agregados:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total del Pedido',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            'Bs ${total.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
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