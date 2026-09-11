import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/multi_select_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class DetalleProveedorDialog extends ConsumerWidget {
  final ProveedorEntity proveedor;

  const DetalleProveedorDialog({super.key, required this.proveedor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync = ref.watch(productosPorProveedorProvider(proveedor.id));
    final usuario = ref.watch(usuarioActualProvider);
    final esAdmin = usuario?.rol == 'admin';
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

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
              maxHeight: MediaQuery.of(context).size.height * 0.9,
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
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, isDark, isMobile),
                  const SizedBox(height: 12),
                  _buildInfoSection(isDark),
                  const SizedBox(height: 16),
                  _buildProductosSection(
                    context, // ✅ Pasar context para usar en MediaQuery
                    isDark,
                    isMobile,
                    productosAsync,
                    esAdmin,
                    ref,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, bool isMobile) {
    final Color estadoColor = proveedor.activo ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.business_center_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                proveedor.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18 : 22,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                  letterSpacing: -0.5,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      proveedor.activo ? 'Activo' : 'Inactivo',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: estadoColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (proveedor.supabaseId != null)
                    Text(
                      'ID: ${proveedor.supabaseId!.substring(0, 8)}...',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white54 : Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildInfoSection(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        children: [
          _buildInfoChip('RIF', proveedor.cedula ?? 'N/A', isDark),
          _buildInfoChip('Teléfono', proveedor.telefono ?? 'N/A', isDark),
          _buildInfoChip('Empresa', proveedor.empresa ?? proveedor.nombre, isDark),
          if (proveedor.direccion != null && proveedor.direccion!.isNotEmpty)
            _buildInfoChip('Dirección', proveedor.direccion!, isDark),
          if (proveedor.email != null && proveedor.email!.isNotEmpty)
            _buildInfoChip('Correo', proveedor.email!, isDark),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value, bool isDark) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildProductosSection(
    BuildContext context, // ✅ Ahora recibe context
    bool isDark,
    bool isMobile,
    AsyncValue<List<ProductoEntity>> productosAsync,
    bool esAdmin,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shopping_bag_rounded, color: const Color(0xFF8B5CF6)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Productos asociados',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (esAdmin)
              _buildActionButton(
                icon: Icons.add_rounded,
                label: 'Asignar',
                onPressed: () => _mostrarDialogoAsignarProductos(context, ref),
                color: const Color(0xFF8B5CF6),
                isDark: isDark,
                isMobile: isMobile,
              ),
          ],
        ),
        const SizedBox(height: 8),
        // ✅ Usamos ConstrainedBox con maxHeight para evitar overflow
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.35,
          ),
          child: productosAsync.when(
            data: (productos) {
              if (productos.isEmpty) {
                return Center(
                  child: Text(
                    esAdmin
                        ? 'No hay productos asignados. Presiona "Asignar" para agregar.'
                        : 'No hay productos asignados.',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: productos.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFE5E7EB),
                ),
                itemBuilder: (context, index) {
                  final p = productos[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.inventory_2_rounded, color: const Color(0xFF8B5CF6), size: 16),
                    ),
                    title: Text(
                      p.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: isMobile ? 13 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      'Código: ${p.codigoBarras}',
                      style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54),
                    ),
                    trailing: Text(
                      '\$${p.precioUnidad.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF8B5CF6),
                        fontSize: isMobile ? 13 : 14,
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
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    required bool isDark,
    required bool isMobile,
  }) {
    if (isMobile) {
      return IconButton(
        icon: Icon(icon, color: color, size: 24),
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        tooltip: label,
        splashRadius: 24,
      );
    }
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(80, 36),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
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
      ref.invalidate(productosPorProveedorProvider(proveedor.id));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${seleccionados.length} productos asignados a ${proveedor.nombre}'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    }
  }
}