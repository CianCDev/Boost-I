import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/multi_select_dialog.dart';

class DetalleProveedorScreen extends ConsumerWidget {
  final ProveedorEntity proveedor;

  const DetalleProveedorScreen({super.key, required this.proveedor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productosPorProveedorProvider(proveedor.id));
    final isMobile = ResponsiveHelper.isMobile(context);
    final usuario = ref.watch(usuarioActualProvider);
    final esAdmin = usuario?.rol == 'admin';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: Text(
          proveedor.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
          if (esAdmin)
            IconButton(
              onPressed: () => _mostrarDialogoAsignarProductos(context, ref),
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Asignar productos',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ CORREGIDO: Pasamos el contexto a la función
            _buildInfoProveedor(context),
            const SizedBox(height: 20),
            // ✅ Esta función ya recibía context correctamente
            _buildSeccionProductos(productosAsync, context, ref, esAdmin),
          ],
        ),
      ),
    );
  }

  // ✅ CORREGIDO: La función ahora recibe BuildContext context
  Widget _buildInfoProveedor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_rounded, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  proveedor.nombre,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: proveedor.activo
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    proveedor.activo ? 'Activo' : 'Inactivo',
                    style: TextStyle(
                      color: proveedor.activo ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (proveedor.cedula != null && proveedor.cedula!.isNotEmpty) ...[
              // ✅ CORREGIDO: Pasamos context a _buildInfoRow
              _buildInfoRow(context, Icons.badge_rounded, 'Cédula/RIF', proveedor.cedula!),
              const SizedBox(height: 8),
            ],
            if (proveedor.direccion != null && proveedor.direccion!.isNotEmpty) ...[
              _buildInfoRow(context, Icons.location_on_rounded, 'Dirección', proveedor.direccion!),
              const SizedBox(height: 8),
            ],
            if (proveedor.telefono != null && proveedor.telefono!.isNotEmpty) ...[
              _buildInfoRow(context, Icons.phone_rounded, 'Teléfono', proveedor.telefono!),
              const SizedBox(height: 8),
            ],
            if (proveedor.empresa != null && proveedor.empresa!.isNotEmpty) ...[
              _buildInfoRow(context, Icons.business_rounded, 'Empresa', proveedor.empresa!),
              const SizedBox(height: 8),
            ],
            if (proveedor.supabaseId != null) ...[
              const Divider(color: Color(0xFFE2E8F0)),
              _buildInfoRow(context, Icons.cloud_rounded, 'ID en nube', proveedor.supabaseId!),
            ],
          ],
        ),
      ),
    );
  }

  // ✅ CORREGIDO: La función ahora recibe BuildContext context
  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSeccionProductos(
    AsyncValue<List<ProductoEntity>> productosAsync,
    BuildContext context,
    WidgetRef ref,
    bool esAdmin,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.shopping_bag_rounded, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Productos asociados',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                if (esAdmin)
                  ElevatedButton.icon(
                    onPressed: () => _mostrarDialogoAsignarProductos(context, ref),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Asignar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            productosAsync.when(
              data: (productos) {
                if (productos.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        esAdmin
                            ? 'Este proveedor no tiene productos asignados.\nPresiona "Asignar" para agregar productos.'
                            : 'Este proveedor no tiene productos asignados.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  );
                }
                return Column(
                  children: productos.map((p) {
                    return ListTile(
                      leading: Icon(Icons.inventory_2_rounded, color: colorScheme.primary),
                      title: Text(p.nombre, style: TextStyle(color: colorScheme.onSurface)),
                      subtitle: Text(
                        'Código: ${p.codigoBarras}',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                      trailing: Text(
                        'Bs ${p.precioUnidad.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _mostrarDialogoAsignarProductos(BuildContext context, WidgetRef ref) async {
    final isar = ref.read(isarServiceProvider);

    final todosLosProductos = await isar.obtenerProductos();
    final productosSinProveedor = todosLosProductos.where((p) => p.proveedorId == null).toList();

    if (productosSinProveedor.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay productos sin proveedor para asignar'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final seleccionados = await showDialog<List<ProductoEntity>>(
      context: context,
      builder: (context) => MultiSelectDialog(
        items: productosSinProveedor,
        title: 'Asignar productos a ${proveedor.nombre}',
      ),
    );

    if (seleccionados != null && seleccionados.isNotEmpty) {
      for (var producto in seleccionados) {
        producto.proveedorId = proveedor.id;
        await isar.guardarProducto(producto);
      }

      ref.refresh(productosPorProveedorProvider(proveedor.id));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${seleccionados.length} productos asignados a ${proveedor.nombre}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}