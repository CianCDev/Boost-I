// lib/features/pos/presentation/widgets/lotes/historial_codigos_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/status_badge.dart';

class HistorialCodigosDialog extends ConsumerStatefulWidget {
  final int productoId;
  final String productoNombre;

  const HistorialCodigosDialog({
    super.key,
    required this.productoId,
    required this.productoNombre,
  });

  @override
  ConsumerState<HistorialCodigosDialog> createState() =>
      _HistorialCodigosDialogState();
}

class _HistorialCodigosDialogState
    extends ConsumerState<HistorialCodigosDialog> {
  final IsarService _isar = IsarService();
  late Future<List<HistorialCodigoItem>> _historialFuture;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorInfo = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _historialFuture =
        _isar.obtenerHistorialCodigosPorProducto(widget.productoId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GlassDialog(
      maxWidth: 900,
      maxHeightFactor: 0.85,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DialogHeader(
              icon: Icons.qr_code_rounded,
              title: 'Historial de códigos',
              subtitle: widget.productoNombre,
            ),
            const SizedBox(height: 18),

            // ===== TABLA =====
            Flexible(
              child: FutureBuilder<List<HistorialCodigoItem>>(
                future: _historialFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final items = snapshot.data ?? [];
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code_rounded,
                                size: 48,
                                color:
                                    colorScheme.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text(
                              'No hay códigos registrados',
                              style: TextStyle(
                                  color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
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
                          colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.5),
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.hovered)
                              ? _colorPrimary.withValues(alpha: 0.05)
                              : null,
                        ),
                        columns: const [
                          DataColumn(
                              label: Text('Código',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Tipo',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Proveedor',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('F. Ingreso',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Vencimiento',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Cantidad',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Precio',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold))),
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
                                StatusBadge(
                                  label: item.tipo == 'lote'
                                      ? 'Lote'
                                      : 'Alias',
                                  color: item.tipo == 'lote'
                                      ? _colorInfo
                                      : _colorPrimary,
                                  size: StatusBadgeSize.small,
                                ),
                              ),
                              DataCell(Text(item.proveedorNombre ?? '-')),
                              DataCell(Text(DateFormat('dd/MM/yyyy')
                                  .format(item.fechaIngreso))),
                              DataCell(Text(
                                item.fechaVencimiento != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(item.fechaVencimiento!)
                                    : '-',
                              )),
                              DataCell(Text(
                                item.cantidad > 0
                                    ? item.cantidad.toString()
                                    : '-',
                              )),
                              DataCell(Text(
                                item.precio > 0
                                    ? '\$${item.precio.toStringAsFixed(2)}'
                                    : '-',
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

            // ===== CERRAR =====
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Cerrar',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurfaceVariant,
                    side: BorderSide(
                      color: colorScheme.outlineVariant
                          .withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}