// lib/features/pos/presentation/widgets/proveedores/detalle_proveedor_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/pedidos/multi_select_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/status_badge.dart';

class DetalleProveedorDialog extends ConsumerWidget {
  final ProveedorEntity proveedor;

  const DetalleProveedorDialog({super.key, required this.proveedor});

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productosAsync =
        ref.watch(productosPorProveedorProvider(proveedor.id));
    final usuario = ref.watch(usuarioActualProvider);
    final esAdmin = usuario?.rol == 'admin';
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 700,
      maxHeightFactor: 0.9,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== HEADER =====
            DialogHeader(
              icon: Icons.business_center_rounded,
              title: proveedor.nombre,
              subtitle: proveedor.supabaseId != null
                  ? 'ID: ${proveedor.supabaseId!.substring(0, 8)}...'
                  : null,
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: proveedor.activo ? 'Activo' : 'Inactivo',
                color:
                    proveedor.activo ? _colorSuccess : _colorDanger,
                size: StatusBadgeSize.medium,
              ),
            ),
            const SizedBox(height: 18),

            // ===== INFO =====
            _buildInfoSection(colorScheme),
            const SizedBox(height: 20),

            // ===== PRODUCTOS =====
            _buildProductosSection(
              context,
              isMobile,
              colorScheme,
              productosAsync,
              esAdmin,
              ref,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 10,
        children: [
          _infoChip('RIF', proveedor.cedula ?? 'N/A', colorScheme),
          _infoChip('Teléfono', proveedor.telefono ?? 'N/A', colorScheme),
          _infoChip('Empresa', proveedor.empresa ?? proveedor.nombre,
              colorScheme),
          if (proveedor.direccion?.isNotEmpty ?? false)
            _infoChip('Dirección', proveedor.direccion!, colorScheme),
          if (proveedor.email?.isNotEmpty ?? false)
            _infoChip('Correo', proveedor.email!, colorScheme),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value, ColorScheme colorScheme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _buildProductosSection(
    BuildContext context,
    bool isMobile,
    ColorScheme colorScheme,
    AsyncValue<List<ProductoEntity>> productosAsync,
    bool esAdmin,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shopping_bag_rounded,
                color: _colorPrimary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Productos asociados',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 15,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            if (esAdmin)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _mostrarDialogoAsignarProductos(context, ref),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(isMobile ? '' : 'Asignar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _colorPrimary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 10 : 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.35,
          ),
          child: productosAsync.when(
            data: (productos) {
              if (productos.isEmpty) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 24, horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.outlineVariant
                          .withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 20, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          esAdmin
                              ? 'No hay productos asignados. Presiona "Asignar" para agregar.'
                              : 'No hay productos asignados a este proveedor.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                itemCount: productos.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color:
                      colorScheme.outlineVariant.withValues(alpha: 0.4),
                ),
                itemBuilder: (context, index) {
                  final p = productos[index];
                  return _ProductoProveedorTile(
                    producto: p,
                    isMobile: isMobile,
                    colorScheme: colorScheme,
                  );
                },
              );
            },
            loading: () => const Center(
                child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }

  Future<void> _mostrarDialogoAsignarProductos(
      BuildContext context, WidgetRef ref) async {
    final isar = ref.read(isarServiceProvider);
    final todosLosProductos = await isar.obtenerProductos();
    final productosSinProveedor =
        todosLosProductos.where((p) => p.proveedorId == null).toList();

    if (productosSinProveedor.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay productos sin proveedor para asignar'),
            backgroundColor: Color(0xFFF59E0B),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    final seleccionados = await showDialog<List<ProductoEntity>>(
      context: context,
      builder: (_) => MultiSelectDialog(
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
            behavior: SnackBarBehavior.floating,
            content: Text(
                '${seleccionados.length} productos asignados a ${proveedor.nombre}'),
            backgroundColor: _colorSuccess,
          ),
        );
      }
    }
  }
}

// ============================================================
// TILE DE PRODUCTO ASOCIADO
// ============================================================
class _ProductoProveedorTile extends StatefulWidget {
  final ProductoEntity producto;
  final bool isMobile;
  final ColorScheme colorScheme;

  const _ProductoProveedorTile({
    required this.producto,
    required this.isMobile,
    required this.colorScheme,
  });

  @override
  State<_ProductoProveedorTile> createState() =>
      _ProductoProveedorTileState();
}

class _ProductoProveedorTileState extends State<_ProductoProveedorTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
        color: _hovered
            ? widget.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.35)
            : Colors.transparent,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.inventory_2_rounded,
                  color: Color(0xFF8B5CF6), size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.producto.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: widget.colorScheme.onSurface,
                      fontSize: widget.isMobile ? 13 : 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    'Código: ${widget.producto.codigoBarras}',
                    style: TextStyle(
                      fontSize: 11,
                      color: widget.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '\$${widget.producto.precioUnidad.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B5CF6),
                fontSize: widget.isMobile ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}