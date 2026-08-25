import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../providers/esc_pos_provider.dart';
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
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedPrinter = ref.watch(printerProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
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
        padding: EdgeInsets.all(isMobile ? 12 : (isTablet ? 24 : 32)),
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Detalles del Producto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 20 : 24,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 28, color: colorScheme.onSurfaceVariant),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // IMAGEN
              Center(
                child: Container(
                  height: isMobile ? 120 : (isTablet ? 200 : 280),
                  width: double.infinity,
                  constraints: BoxConstraints(maxWidth: isMobile ? 400 : 500),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colorScheme.outline, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: producto.imagenUrl.isNotEmpty
                        ? Image.network(
                            producto.imagenUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                Icon(Icons.inventory_2, size: 64, color: colorScheme.primary),
                          )
                        : Icon(Icons.inventory_2, size: 64, color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),

              // INFORMACIÓN
              Text(
                producto.nombre,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 20 : 24,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'Cód: ${producto.codigoBarras}',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: isMobile ? 12 : 14,
                ),
              ),
              const SizedBox(height: 8),

              // PRECIO Y CATEGORÍA
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Precio: \$${producto.precioUnidad.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: isMobile ? 16 : 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Categoría: ${producto.categoria}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: isMobile ? 14 : 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // STOCK
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Stock Actual: ${producto.stock}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isMobile ? 16 : 18,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Stock Mínimo: ${producto.stockMinimo}',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: isMobile ? 14 : 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // PROVEEDOR
              if (producto.proveedorNombre.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Text(
                    'Proveedor: ${producto.proveedorNombre} (${producto.proveedorTelefono.isNotEmpty ? producto.proveedorTelefono : "Sin teléfono"})',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                      fontSize: isMobile ? 12 : 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // BOTONES
              Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Imprimir etiqueta
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      foregroundColor: colorScheme.onSurfaceVariant,
                    ),
                    child: const Text('Cerrar'),
                  ),

                  if (esAdmin) ...[
                    ElevatedButton.icon(
                      onPressed: onEditar,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      label: const Text('Editar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                                style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error),
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}