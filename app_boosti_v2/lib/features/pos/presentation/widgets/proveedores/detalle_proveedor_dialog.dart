// lib/features/pos/presentation/widgets/proveedores/detalle_proveedor_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/multi_select_dialog.dart';

class DetalleProveedorDialog extends ConsumerWidget {
  final ProveedorEntity proveedor;

  const DetalleProveedorDialog({super.key, required this.proveedor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productosPorProveedorProvider(proveedor.id));
    final usuario = ref.watch(usuarioActualProvider);
    final esAdmin = usuario?.rol == 'admin';
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 700,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
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
            // Header
            Row(
              children: [
                Icon(Icons.business_center_rounded, color: const Color(0xFF8B5CF6), size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    proveedor.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
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
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: proveedor.activo
                    ? Colors.green.withValues(alpha: 0.15)
                    : Colors.red.withValues(alpha: 0.15),
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
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),

            // Información
            _buildInfoRow(context, Icons.badge_rounded, 'Cédula/RIF', proveedor.cedula ?? 'No registrada'),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.location_on_rounded, 'Dirección', proveedor.direccion ?? 'No registrada'),
            const SizedBox(height: 8),
            _buildInfoRow(context, Icons.phone_rounded, 'Teléfono', proveedor.telefono ?? 'No registrado'),
            const SizedBox(height: 8),
            if (proveedor.email != null && proveedor.email!.isNotEmpty) ...[
              _buildInfoRow(context, Icons.email_rounded, 'Correo', proveedor.email!),
              const SizedBox(height: 8),
            ],
            _buildInfoRow(context, Icons.business_rounded, 'Empresa', proveedor.empresa ?? proveedor.nombre),
            if (proveedor.supabaseId != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(context, Icons.cloud_rounded, 'ID en nube', proveedor.supabaseId!),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),

            // Productos asociados
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: productosAsync.when(
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
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: productos.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final p = productos[index];
                      return ListTile(
                        leading: Icon(Icons.inventory_2_rounded, color: colorScheme.primary),
                        title: Text(p.nombre, style: TextStyle(color: colorScheme.onSurface)),
                        subtitle: Text('Código: ${p.codigoBarras}', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                        trailing: Text(
                          '\$${p.precioUnidad.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            style: TextStyle(color: colorScheme.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
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
      // ignore: use_build_context_synchronously
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
      // ignore: unused_result
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