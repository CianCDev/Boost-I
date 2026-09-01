// lib/features/pos/presentation/widgets/lotes/historial_codigos_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

class HistorialCodigosDialog extends ConsumerStatefulWidget {
  final int productoId;
  final String productoNombre;

  const HistorialCodigosDialog({
    super.key,
    required this.productoId,
    required this.productoNombre,
  });

  @override
  ConsumerState<HistorialCodigosDialog> createState() => _HistorialCodigosDialogState();
}

class _HistorialCodigosDialogState extends ConsumerState<HistorialCodigosDialog> {
  final IsarService _isar = IsarService();
  late Future<List<HistorialCodigoItem>> _historialFuture;

  @override
  void initState() {
    super.initState();
    _historialFuture = _isar.obtenerHistorialCodigosPorProducto(widget.productoId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 800,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        color: colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.qr_code_rounded, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Historial de códigos - ${widget.productoNombre}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Tabla
            Expanded(
              child: FutureBuilder<List<HistorialCodigoItem>>(
                future: _historialFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        'No hay códigos de barras registrados para este producto.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columnSpacing: 16,
                        horizontalMargin: 8,
                        headingRowColor: WidgetStateProperty.all(
                          colorScheme.surfaceContainerHighest,
                        ),
                        columns: const [
                          DataColumn(label: Text('Código', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Proveedor', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('F. Ingreso', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Vencimiento', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Cantidad', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: items.map((item) {
                          return DataRow(
                            cells: [
                              DataCell(
                                SelectableText(
                                  item.codigo,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.tipo == 'lote'
                                        ? Colors.blue.shade50
                                        : Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: item.tipo == 'lote'
                                          ? Colors.blue.shade200
                                          : Colors.purple.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    item.tipo == 'lote' ? 'Lote' : 'Alias',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: item.tipo == 'lote'
                                          ? Colors.blue.shade700
                                          : Colors.purple.shade700,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(item.proveedorNombre ?? '-')),
                              DataCell(Text(DateFormat('dd/MM/yyyy').format(item.fechaIngreso))),
                              DataCell(Text(
                                item.fechaVencimiento != null
                                    ? DateFormat('dd/MM/yyyy').format(item.fechaVencimiento!)
                                    : '-',
                              )),
                              DataCell(Text(
                                item.cantidad > 0 ? item.cantidad.toString() : '-',
                              )),
                              DataCell(Text(
                                item.precio > 0 ? '\$${item.precio.toStringAsFixed(2)}' : '-',
                              )),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}