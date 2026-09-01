// lib/features/pos/presentation/widgets/lotes/detalle_lote_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/traspaso_lote_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/editar_lote_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/historial_codigos_dialog.dart';

class DetalleLoteDialog extends ConsumerStatefulWidget {
  final LoteEntity lote;
  const DetalleLoteDialog({super.key, required this.lote});

  @override
  ConsumerState<DetalleLoteDialog> createState() => _DetalleLoteDialogState();
}

class _DetalleLoteDialogState extends ConsumerState<DetalleLoteDialog> {
  final IsarService _isar = IsarService();
  late Future<List<MovimientoLoteEntity>> _movimientosFuture;

  @override
  void initState() {
    super.initState();
    _movimientosFuture = _isar.obtenerMovimientosPorLote(widget.lote.id);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final usuario = ref.watch(usuarioActualProvider);
    final esAdmin = usuario?.rol == 'admin';
    final lote = widget.lote;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        color: colorScheme.surface,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inventory_2_rounded, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lote #${lote.id}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // CONTENIDO
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // INFORMACIÓN DEL LOTE
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('Producto ID', '${lote.productoId}'),
                          _buildInfoRow('Código de barras', lote.codigoBarrasLote ?? 'No asignado'),
                          _buildInfoRow('Estado', lote.estado.toUpperCase()),
                          _buildInfoRow('Cantidad inicial', '${lote.cantidadInicial}'),
                          _buildInfoRow('Cantidad restante', '${lote.cantidadRestante}'),
                          _buildInfoRow('Ingreso', DateFormat('dd/MM/yyyy HH:mm').format(lote.fechaIngreso)),
                          _buildInfoRow('Vencimiento', lote.fechaVencimiento != null
                              ? DateFormat('dd/MM/yyyy').format(lote.fechaVencimiento!)
                              : 'Sin vencimiento'),
                          if (lote.costoUnitario != null)
                            _buildInfoRow('Costo unitario', '\$${lote.costoUnitario!.toStringAsFixed(2)}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // BOTONES DE ACCIÓN
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (lote.estado == 'activo' && lote.cantidadRestante > 0 && esAdmin)
                          ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => TraspasoLoteDialog(lote: lote),
                              ).then((_) {
                                setState(() {
                                  _movimientosFuture = _isar.obtenerMovimientosPorLote(widget.lote.id);
                                });
                              });
                            },
                            icon: const Icon(Icons.swap_horiz_rounded),
                            label: const Text('Reponer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            ),
                          ),

                        if (lote.estado == 'activo' && esAdmin)
                          OutlinedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => EditarLoteDialog(lote: lote),
                              ).then((_) {
                                setState(() {
                                  _movimientosFuture = _isar.obtenerMovimientosPorLote(widget.lote.id);
                                });
                              });
                            },
                            icon: const Icon(Icons.edit_rounded),
                            label: const Text('Editar'),
                          ),

                        // 🔥 BOTÓN PARA VER HISTORIAL DE CÓDIGOS DE BARRAS
                        OutlinedButton.icon(
                          onPressed: () async {
                            final producto = await _isar.obtenerProductoPorId(lote.productoId);
                            showDialog(
                              context: context,
                              builder: (_) => HistorialCodigosDialog(
                                productoId: lote.productoId,
                                productoNombre: producto?.nombre ?? 'Producto #${lote.productoId}',
                              ),
                            );
                          },
                          icon: const Icon(Icons.qr_code_rounded),
                          label: const Text('Ver códigos'),
                        ),

                        if (lote.cantidadRestante == 0 && esAdmin)
                          OutlinedButton.icon(
                            onPressed: _confirmarEliminar,
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Eliminar'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // HISTORIAL DE MOVIMIENTOS
                    const Divider(),
                    Row(
                      children: [
                        const Icon(Icons.history_rounded, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Historial de movimientos',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    FutureBuilder<List<MovimientoLoteEntity>>(
                      future: _movimientosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final movimientos = snapshot.data ?? [];
                        if (movimientos.isEmpty) {
                          return Center(
                            child: Text(
                              'Sin movimientos',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: movimientos.length,
                          separatorBuilder: (_, __) => Divider(height: 1, color: colorScheme.outline),
                          itemBuilder: (context, index) {
                            final m = movimientos[index];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(_getIcon(m.tipo), color: _getColor(m.tipo)),
                              title: Text(
                                '${m.tipo.toUpperCase()} - ${m.cantidad} und',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                '${DateFormat('dd/MM/yyyy HH:mm').format(m.fecha)} • Usuario: ${m.usuarioId}',
                              ),
                              trailing: m.observaciones != null
                                  ? Icon(Icons.comment_outlined, size: 16, color: colorScheme.onSurfaceVariant)
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String tipo) {
    switch (tipo) {
      case 'activacion':
        return Icons.play_arrow_rounded;
      case 'venta':
        return Icons.shopping_cart_rounded;
      case 'traspaso':
        return Icons.swap_horiz_rounded;
      case 'devolucion':
        return Icons.undo_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  Color _getColor(String tipo) {
    switch (tipo) {
      case 'activacion':
        return Colors.green;
      case 'venta':
        return Colors.blue;
      case 'traspaso':
        return Colors.orange;
      case 'devolucion':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Lote'),
        content: const Text('¿Estás seguro? Esta acción no se deshace.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final exito = await _isar.eliminarLote(widget.lote.id);
              if (mounted) {
                if (exito) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ Lote eliminado')),
                  );
                  Navigator.pop(context);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Error al eliminar')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}