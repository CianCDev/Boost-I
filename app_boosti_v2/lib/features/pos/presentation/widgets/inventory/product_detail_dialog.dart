// lib/features/pos/presentation/widgets/productos/product_detail_dialog.dart
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../../data/Local/entities/proveedor_entity.dart';
import '../../providers/esc_pos_provider.dart';
import '../../providers/proveedores_provider.dart';
import '../../services/printer_service.dart';
import '../../services/label_generator.dart';
import '../../utils/responsive_helper.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/status_badge.dart';

class ProductDetailDialog extends ConsumerWidget {
  final ProductoEntity producto;
  final bool esAdmin;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const ProductDetailDialog({
    super.key,
    required this.producto,
    required this.esAdmin,
    required this.onEditar,
    required this.onEliminar,
  });

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final selectedPrinter = ref.watch(printerProvider);

    final proveedorAsync = producto.proveedorId != null
        ? ref.watch(proveedorPorIdAsyncProvider(producto.proveedorId!))
        : const AsyncValue<ProveedorEntity?>.data(null);

    return GlassDialog(
      maxWidth: 850,
      maxHeightFactor: 0.85,
      accentColor: colorScheme.primary,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const DialogHeader(
              icon: Icons.inventory_2_outlined,
              title: 'Detalles del Producto',
              subtitle: 'Información completa del producto',
            ),
            const SizedBox(height: 16),

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildImageSection(colorScheme, isMobile),
                    const SizedBox(height: 16),
                    _buildInfoPrincipal(colorScheme, isMobile),
                    const SizedBox(height: 12),
                    _buildPrecioStock(colorScheme, isMobile),
                    const SizedBox(height: 12),
                    _buildCategoriaStockMinimo(colorScheme, isMobile),
                    if (producto.proveedorNombre.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _buildProveedorSection(
                          colorScheme, isMobile, proveedorAsync),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ===== ACCIONES =====
            _buildAcciones(context, colorScheme, isMobile, selectedPrinter),
          ],
        ),
      ),
    );
  }

  // ==================== IMAGEN ====================
  Widget _buildImageSection(ColorScheme colorScheme, bool isMobile) {
    return Center(
      child: Container(
        height: isMobile ? 160 : 220,
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: isMobile ? 400 : 500),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: producto.imagenUrl != null &&
                  producto.imagenUrl!.isNotEmpty
              ? Image.network(
                  producto.imagenUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(colorScheme),
                )
              : _buildPlaceholder(colorScheme),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined,
              size: 56, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'Sin imagen',
            style: TextStyle(
                color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ==================== INFO PRINCIPAL ====================
  Widget _buildInfoPrincipal(ColorScheme colorScheme, bool isMobile) {
    return _infoCard(
      colorScheme: colorScheme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.label_outline,
                  size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  producto.nombre,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 18 : 20,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.qr_code,
                  size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                producto.codigoBarras,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: isMobile ? 12 : 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== PRECIO Y STOCK ====================
  Widget _buildPrecioStock(ColorScheme colorScheme, bool isMobile) {
    return _infoCard(
      colorScheme: colorScheme,
      child: Row(
        children: [
          Expanded(
            child: _statBlock(
              icon: Icons.attach_money,
              label: 'Precio',
              value: '\$${producto.precioUnidad.toStringAsFixed(2)}',
              valueColor: colorScheme.primary,
              colorScheme: colorScheme,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            child: _statBlock(
              icon: Icons.inventory_outlined,
              label: 'Stock actual',
              value:
                  '${producto.stock} ${producto.esPesado ? 'kg' : 'unid'}',
              valueColor: colorScheme.onSurface,
              colorScheme: colorScheme,
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriaStockMinimo(
      ColorScheme colorScheme, bool isMobile) {
    return _infoCard(
      colorScheme: colorScheme,
      child: Row(
        children: [
          Expanded(
            child: _statBlock(
              icon: Icons.category_outlined,
              label: 'Categoría',
              value: producto.categoria,
              valueColor: colorScheme.onSurface,
              colorScheme: colorScheme,
              isMobile: isMobile,
            ),
          ),
          Expanded(
            child: _statBlock(
              icon: Icons.warning_amber_outlined,
              label: 'Stock mínimo',
              value:
                  '${producto.stockMinimo} ${producto.esPesado ? 'kg' : 'unid'}',
              valueColor: colorScheme.onSurface,
              colorScheme: colorScheme,
              isMobile: isMobile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBlock({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
    required ColorScheme colorScheme,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 16 : 18,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ==================== PROVEEDOR ====================
  Widget _buildProveedorSection(
    ColorScheme colorScheme,
    bool isMobile,
    AsyncValue<ProveedorEntity?> proveedorAsync,
  ) {
    return proveedorAsync.when(
      data: (proveedor) {
        final isActivo = proveedor?.activo ?? true;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.business_center_rounded,
                  color: colorScheme.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proveedor',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            producto.proveedorNombre,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 14 : 15,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (producto.proveedorId != null &&
                            proveedor != null) ...[
                          const SizedBox(width: 8),
                          StatusBadge(
                            label: isActivo ? 'Activo' : 'Inactivo',
                            color: isActivo ? _colorSuccess : _colorDanger,
                            icon: isActivo
                                ? Icons.check_circle
                                : Icons.cancel,
                            size: StatusBadgeSize.small,
                          ),
                        ],
                      ],
                    ),
                    if (producto.proveedorTelefono.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        producto.proveedorTelefono,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  // ==================== HELPER CARD ====================
  Widget _infoCard({
    required ColorScheme colorScheme,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: child,
    );
  }

  // ==================== ACCIONES ====================
  Widget _buildAcciones(
    BuildContext context,
    ColorScheme colorScheme,
    bool isMobile,
    dynamic selectedPrinter,
  ) {
    if (isMobile) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _iconActionButton(
            icon: Icons.local_offer_outlined,
            color: _colorPrimary,
            onPressed: () => _imprimirEtiqueta(context, selectedPrinter),
          ),
          if (esAdmin) ...[
            const SizedBox(width: 8),
            _iconActionButton(
              icon: Icons.edit_outlined,
              color: colorScheme.primary,
              onPressed: onEditar,
            ),
            const SizedBox(width: 8),
            _iconActionButton(
              icon: Icons.delete_outline,
              color: _colorDanger,
              onPressed: () => _confirmarEliminacion(context),
            ),
          ],
        ],
      );
    }

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: ElevatedButton.icon(
            onPressed: () => _imprimirEtiqueta(context, selectedPrinter),
            icon: const Icon(Icons.local_offer_outlined, size: 18),
            label: const Text('Imprimir Etiqueta'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _colorPrimary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Cerrar',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        if (esAdmin) ...[
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: OutlinedButton.icon(
              onPressed: onEditar,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.primary,
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                backgroundColor:
                    colorScheme.primary.withValues(alpha: 0.06),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: OutlinedButton.icon(
              onPressed: () => _confirmarEliminacion(context),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Eliminar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _colorDanger,
                side: BorderSide(
                  color: _colorDanger.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                backgroundColor: _colorDanger.withValues(alpha: 0.06),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _iconActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          icon: Icon(icon, size: 22),
          color: color,
          onPressed: onPressed,
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(
            backgroundColor: color.withValues(alpha: 0.12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _imprimirEtiqueta(
      BuildContext context, dynamic selectedPrinter) async {
    if (selectedPrinter == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('No hay impresora seleccionada'),
          backgroundColor: _colorDanger,
        ),
      );
      return;
    }

    final label = LabelItem(
      nombre: producto.nombre,
      precio: producto.precioUnidad,
      codigoBarras: producto.codigoBarras,
      cantidad: 1,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 12),
            Text('Imprimiendo etiqueta...'),
          ],
        ),
        duration: Duration(seconds: 10),
      ),
    );

    final result = await PrinterService().printLabel(
      printer: selectedPrinter.device,
      labels: [label],
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(result.success
            ? 'Etiqueta impresa correctamente'
            : 'Error al imprimir: ${result.message}'),
        backgroundColor: result.success ? _colorSuccess : _colorDanger,
      ),
    );
  }

  Future<void> _confirmarEliminacion(BuildContext context) async {
    await IsarService().guardarLog(
      LogEntity()
        ..accion = 'ELIMINAR_PRODUCTO'
        ..usuarioNombre = 'Sistema'
        ..usuarioRol = 'admin'
        ..detalles = 'Producto ID: ${producto.id} - ${producto.nombre}'
        ..fecha = DateTime.now()
        ..sincronizado = false,
    );

    if (!context.mounted) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Producto'),
        content: Text(
          '¿Estás seguro de eliminar "${producto.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorDanger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Eliminar'),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      onEliminar();
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }
}