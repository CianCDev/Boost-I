import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/productos_provider.dart';
import '../../services/sync_service.dart';
import '../dialogos_genericos/confirm_dialog.dart';
import '../dialogos_genericos/error_dialog.dart';
import '../dialogos_genericos/succes_dialog.dart';


class ProductosInactivosDialog extends ConsumerStatefulWidget {
  const ProductosInactivosDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const ProductosInactivosDialog(),
    );
  }

  @override
  ConsumerState<ProductosInactivosDialog> createState() =>
      _ProductosInactivosDialogState();
}

class _ProductosInactivosDialogState
    extends ConsumerState<ProductosInactivosDialog> {
  final IsarService _isarService = IsarService();
  List<ProductoEntity> _productosInactivos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarProductosInactivos();
  }

  Future<void> _cargarProductosInactivos() async {
    setState(() => _isLoading = true);
    try {
      final productos = await _isarService.obtenerProductos();
      final inactivos = productos.where((p) => !p.activo).toList();
      setState(() {
        _productosInactivos = inactivos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            title: 'Error',
            content: 'No se pudieron cargar los productos inactivos: $e',
          ),
        );
      }
    }
  }

  Future<void> _reactivarProducto(ProductoEntity producto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmDialog(
        title: 'Reactivar producto',
        content: '¿Estás seguro de reactivar "${producto.nombre}"?',
        confirmText: 'Reactivar',
        confirmColor: const Color(0xFF10B981),
        onConfirm: () {},
      ),
    );

    if (confirmado != true) return;

    try {
      // Actualizar localmente
      producto.activo = true;
      await _isarService.guardarProducto(producto);

      // Sincronizar con Supabase
      await SyncService().sincronizarProductosASupabase();

      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => const SuccessDialog(
            title: 'Producto reactivado',
            content: 'El producto ha sido reactivado exitosamente.',
          ),
        );
        // Recargar lista
        _cargarProductosInactivos();
        // Invalidar provider para actualizar UI principal
        ref.invalidate(productosProvider);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            title: 'Error',
            content: 'No se pudo reactivar el producto: $e',
          ),
        );
      }
    }
  }

  Future<void> _eliminarProducto(ProductoEntity producto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ConfirmDialog(
        title: 'Eliminar producto',
        content: '¿Estás seguro de eliminar permanentemente "${producto.nombre}"? Esta acción no se puede deshacer.',
        confirmText: 'Eliminar',
        confirmColor: Colors.red,
        onConfirm: () {},
      ),
    );

    if (confirmado != true) return;

    try {
      // Eliminar localmente
      await _isarService.eliminarProducto(producto.id);

      // Eliminar en Supabase
      await SyncService().eliminarProductoEnSupabase(producto.codigoBarras);

      if (mounted) {
        await showDialog(
          context: context,
          builder: (_) => const SuccessDialog(
            title: 'Producto eliminado',
            content: 'El producto ha sido eliminado permanentemente.',
          ),
        );
        // Recargar lista
        _cargarProductosInactivos();
        ref.invalidate(productosProvider);
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => ErrorDialog(
            title: 'Error',
            content: 'No se pudo eliminar el producto: $e',
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 40,
        vertical: isMobile ? 12 : 32,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 8,
      child: Container(
        width: isMobile ? double.infinity : 700,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 40,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.grey[900]!.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.5),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Cabecera
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.inventory_2_rounded,
                            color: Colors.red,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Productos inactivos',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(
                            Icons.close_rounded,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          tooltip: 'Cerrar',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Contador
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _isLoading
                            ? 'Cargando...'
                            : '${_productosInactivos.length} productos inactivos',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lista de productos
                    Expanded(
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _productosInactivos.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 64,
                                        color: isDark
                                            ? Colors.white30
                                            : Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No hay productos inactivos',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: isDark
                                              ? Colors.white54
                                              : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: _productosInactivos.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final producto = _productosInactivos[index];
                                    return _ProductoInactivoTile(
                                      producto: producto,
                                      onReactivar: () =>
                                          _reactivarProducto(producto),
                                      onEliminar: () =>
                                          _eliminarProducto(producto),
                                      isDark: isDark,
                                      isMobile: isMobile,
                                    );
                                  },
                                ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductoInactivoTile extends StatelessWidget {
  final ProductoEntity producto;
  final VoidCallback onReactivar;
  final VoidCallback onEliminar;
  final bool isDark;
  final bool isMobile;

  const _ProductoInactivoTile({
    required this.producto,
    required this.onReactivar,
    required this.onEliminar,
    required this.isDark,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icono de producto inactivo
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  producto.nombre,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Código: ${producto.codigoBarras} | Precio: \$${producto.precioUnidad.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Botones de acción
          Row(
            children: [
              _buildActionButton(
                icon: Icons.restore_rounded,
                color: const Color(0xFF10B981),
                onPressed: onReactivar,
                label: 'Reactivar',
              ),
              const SizedBox(width: 8),
              _buildActionButton(
                icon: Icons.delete_outline_rounded,
                color: Colors.red,
                onPressed: onEliminar,
                label: 'Eliminar',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String label,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}