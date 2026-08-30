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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedPrinter = ref.watch(printerProvider);

    // Obtener el proveedor si existe
    final proveedorAsync = producto.proveedorId != null
        ? ref.watch(proveedorPorIdProvider(producto.proveedorId!))
        : const AsyncValue<ProveedorEntity?>.data(null);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 40,
        vertical: 24,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 850,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.all(isMobile ? 16 : 32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              _buildHeader(context, colorScheme, isMobile),
              const SizedBox(height: 16),

              // IMAGEN
              _buildImageSection(colorScheme, isMobile),
              const SizedBox(height: 16),

              // INFORMACIÓN PRINCIPAL
              _buildInfoPrincipal(colorScheme, isMobile),
              const SizedBox(height: 12),

              // PRECIO Y STOCK
              _buildPrecioStock(colorScheme, isMobile),
              const SizedBox(height: 12),

              // CATEGORÍA Y STOCK MÍNIMO
              _buildCategoriaStockMinimo(colorScheme, isMobile),
              const SizedBox(height: 12),

              // PROVEEDOR (si existe)
              if (producto.proveedorNombre.isNotEmpty)
                _buildProveedorSection(colorScheme, isMobile, proveedorAsync),
              const SizedBox(height: 16),

              // BOTONES DE ACCIÓN
              _buildAcciones(context, colorScheme, isMobile, selectedPrinter),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(BuildContext context, ColorScheme colorScheme, bool isMobile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.inventory_2_outlined, color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              'Detalles del Producto',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 20 : 24,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, size: 28, color: colorScheme.onSurfaceVariant),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ==================== IMAGEN ====================
  Widget _buildImageSection(ColorScheme colorScheme, bool isMobile) {
    return Center(
      child: Container(
        height: isMobile ? 160 : 240,
        width: double.infinity,
        constraints: BoxConstraints(maxWidth: isMobile ? 400 : 500),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: producto.imagenUrl != null && producto.imagenUrl!.isNotEmpty
              ? Image.network(
                  producto.imagenUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildPlaceholder(colorScheme),
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
          Icon(Icons.image_outlined, size: 64, color: colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text(
            'Sin imagen',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ==================== INFO PRINCIPAL ====================
  Widget _buildInfoPrincipal(ColorScheme colorScheme, bool isMobile) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.label_outline, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    producto.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.qr_code, size: 16, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  'Código: ${producto.codigoBarras}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: isMobile ? 12 : 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PRECIO Y STOCK ====================
  Widget _buildPrecioStock(ColorScheme colorScheme, bool isMobile) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.attach_money, size: 18, color: colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Precio',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${producto.precioUnidad.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.inventory_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Stock Actual',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${producto.stock} ${producto.esPesado ? 'kg' : 'unid'}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 18 : 22,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== CATEGORÍA Y STOCK MÍNIMO ====================
  Widget _buildCategoriaStockMinimo(ColorScheme colorScheme, bool isMobile) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.category_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Categoría',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    producto.categoria,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: isMobile ? 16 : 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_outlined, size: 18, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text(
                        'Stock Mínimo',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${producto.stockMinimo} ${producto.esPesado ? 'kg' : 'unid'}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: isMobile ? 16 : 18,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== PROVEEDOR (con estado activo) ====================
  Widget _buildProveedorSection(
    ColorScheme colorScheme,
    bool isMobile,
    AsyncValue<ProveedorEntity?> proveedorAsync,
  ) {
    return proveedorAsync.when(
      data: (proveedor) {
        final isActivo = proveedor?.activo ?? true; // Si no hay datos, asumimos activo

        return Card(
          elevation: 0,
          color: colorScheme.primary.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.business_center_rounded, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proveedor',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              producto.proveedorNombre,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 14 : 16,
                                color: colorScheme.onSurface,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Solo mostramos badge si tenemos el proveedor real (con ID)
                          if (producto.proveedorId != null && proveedor != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isActivo ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isActivo ? Colors.green : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isActivo ? Icons.check_circle : Icons.cancel,
                                    size: 14,
                                    color: isActivo ? Colors.green : Colors.red,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isActivo ? 'Activo' : 'Inactivo',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: isActivo ? Colors.green : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (producto.proveedorTelefono.isNotEmpty)
                        Text(
                          producto.proveedorTelefono,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  // ==================== BOTONES DE ACCIÓN (optimizados para móvil) ====================
  Widget _buildAcciones(
    BuildContext context,
    ColorScheme colorScheme,
    bool isMobile,
    dynamic selectedPrinter,
  ) {
    if (isMobile) {
      // En móvil: botones solo con ícono, en fila
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Etiqueta
          _buildIconActionButton(
            icon: Icons.local_offer_outlined,
            color: const Color(0xFF8B5CF6),
            onPressed: () async {
              if (selectedPrinter == null) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('❌ No hay impresora seleccionada. Configura una en Ajustes.'),
                    backgroundColor: Colors.orange,
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
                  content: Row(
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
              if (result.success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('✅ Etiqueta impresa correctamente'),
                    backgroundColor: colorScheme.primary,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ Error al imprimir: ${result.message}'),
                    backgroundColor: colorScheme.error,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8),
    
          
          if (esAdmin) ...[
            const SizedBox(width: 8),
            // Editar
            _buildIconActionButton(
              icon: Icons.edit_outlined,
              color: colorScheme.primary,
              onPressed: onEditar,
            ),
            const SizedBox(width: 8),
            // Eliminar
            _buildIconActionButton(
              icon: Icons.delete_outline,
              color: colorScheme.error,
              onPressed: () async {
                await IsarService().guardarLog(
                  LogEntity()
                    ..accion = 'ELIMINAR_PRODUCTO'
                    ..usuarioNombre = 'Sistema'
                    ..usuarioRol = 'admin'
                    ..detalles = 'Producto ID: ${producto.id} - ${producto.nombre}'
                    ..fecha = DateTime.now()
                    ..sincronizado = false,
                );

                final confirm = await showDialog<bool>(
                  // ignore: use_build_context_synchronously
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Eliminar Producto'),
                    content: Text(
                      '¿Estás seguro de eliminar "${producto.nombre}"? Esta acción no se puede deshacer.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                        ),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  onEliminar();
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ],
      );
    }

    // Para escritorio y tablet: botones con texto e ícono
    final buttonPadding = EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 12,
    );

    return Wrap(
      alignment: WrapAlignment.end,
      spacing: 8,
      runSpacing: 8,
      children: [
        // Etiqueta
        ElevatedButton.icon(
          onPressed: () async {
            if (selectedPrinter == null) {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('❌ No hay impresora seleccionada. Configura una en Ajustes.'),
                  backgroundColor: Colors.orange,
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
                content: Row(
                  children: [
                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
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
            if (result.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Etiqueta impresa correctamente'),
                  backgroundColor: colorScheme.primary,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Error al imprimir: ${result.message}'),
                  backgroundColor: colorScheme.error,
                ),
              );
            }
          },
          icon: const Icon(Icons.local_offer_outlined, size: 20),
          label: const Text('Etiqueta'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: colorScheme.onPrimary,
            padding: buttonPadding,
            minimumSize: const Size(80, 44),
            textStyle: const TextStyle(fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),

        TextButton(
          onPressed: () => Navigator.pop(context),
          style: TextButton.styleFrom(
            padding: buttonPadding,
            minimumSize: const Size(80, 44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            foregroundColor: colorScheme.onSurfaceVariant,
          ),
          child: const Text(
            'Cerrar',
            style: TextStyle(fontSize: 16),
          ),
        ),

        if (esAdmin) ...[
          ElevatedButton.icon(
            onPressed: onEditar,
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Editar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: buttonPadding,
              minimumSize: const Size(80, 44),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await IsarService().guardarLog(
                LogEntity()
                  ..accion = 'ELIMINAR_PRODUCTO'
                  ..usuarioNombre = 'Sistema'
                  ..usuarioRol = 'admin'
                  ..detalles = 'Producto ID: ${producto.id} - ${producto.nombre}'
                  ..fecha = DateTime.now()
                  ..sincronizado = false,
              );

              final confirm = await showDialog<bool>(
                // ignore: use_build_context_synchronously
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar Producto'),
                  content: Text(
                    '¿Estás seguro de eliminar "${producto.nombre}"? Esta acción no se puede deshacer.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                      ),
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                onEliminar();
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              padding: buttonPadding,
              minimumSize: const Size(80, 44),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ],
    );
  }

  // Helper para botones de ícono en móvil
  Widget _buildIconActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        icon: Icon(icon, size: 24),
        color: color,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          backgroundColor: color.withValues(alpha: 0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );
  }
}