// lib/features/pos/presentation/widgets/lotes/detalle_lote/lotes_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';

class LotesTab extends ConsumerStatefulWidget {
  final int productoId;
  final int localId;

  const LotesTab({super.key, required this.productoId, required this.localId});

  @override
  ConsumerState<LotesTab> createState() => _LotesTabState();
}

class _LotesTabState extends ConsumerState<LotesTab> {
  final IsarService _isar = IsarService();
  late Future<List<LoteEntity>> _lotesFuture;

  @override
  void initState() {
    super.initState();
    _lotesFuture = _isar.obtenerLotesPorProductoYLocal(widget.productoId, widget.localId);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<List<LoteEntity>>(
      future: _lotesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                const SizedBox(height: 12),
                Text('Error al cargar los lotes'),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          );
        }

        final lotes = snapshot.data ?? [];

        if (lotes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  'No hay otros lotes para este producto',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: lotes.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final lote = lotes[index];
            return _buildLoteCard(context, lote, isDark);
          },
        );
      },
    );
  }

  Widget _buildLoteCard(BuildContext context, LoteEntity lote, bool isDark) {
    final colorScheme = Theme.of(context).colorScheme;
    final estadoColor = _getEstadoColor(lote.estado);

    // ✅ SIN onTap → NO navega a otra pantalla
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: estadoColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: estadoColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Lote #${lote.id}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: estadoColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lote.estado.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: estadoColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.qr_code, size: 14, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lote.codigoLoteProveedor ?? 'Sin código',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.inventory_2_rounded, size: 14, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '${lote.cantidadRestante} kg',
                        style: TextStyle(
                          fontSize: 13,
                          color: estadoColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.calendar_today, size: 14, color: isDark ? Colors.white54 : Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        '${lote.fechaIngreso.day}/${lote.fechaIngreso.month}/${lote.fechaIngreso.year}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Icono informativo (sin navegación)
            Icon(
              Icons.info_outline_rounded,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente': return Colors.orange;
      case 'activo': return Colors.green;
      case 'agotado': return Colors.red;
      case 'vencido': return Colors.purple;
      default: return Colors.grey;
    }
  }
}