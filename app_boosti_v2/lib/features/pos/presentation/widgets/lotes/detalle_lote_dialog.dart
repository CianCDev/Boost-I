// lib/features/pos/presentation/widgets/lotes/detalle_lote_dialog.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import '../common/glass_dialog.dart';
import '../common/dialog_header.dart';
import '../common/status_badge.dart';
import 'traspaso_lote_dialog.dart';
import 'editar_lote_dialog.dart';
import 'historial_codigos_dialog.dart';

class DetalleLoteDialog extends ConsumerStatefulWidget {
  final LoteEntity lote;
  const DetalleLoteDialog({super.key, required this.lote});

  @override
  ConsumerState<DetalleLoteDialog> createState() => _DetalleLoteDialogState();
}

class _DetalleLoteDialogState extends ConsumerState<DetalleLoteDialog> {
  final IsarService _isar = IsarService();
  late Future<List<MovimientoLoteEntity>> _movimientosFuture;

  static const _colorPrimary = Color(0xFF8B5CF6);
  static const _colorSuccess = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);
  static const _colorInfo = Color(0xFF3B82F6);

  @override
  void initState() {
    super.initState();
    _movimientosFuture = _isar.obtenerMovimientosPorLote(widget.lote.id);
  }

  void _recargarMovimientos() {
    setState(() {
      _movimientosFuture =
          _isar.obtenerMovimientosPorLote(widget.lote.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final usuario = ref.watch(usuarioActualProvider);
    final esAdmin = usuario?.rol == 'admin';
    final lote = widget.lote;
    final estadoColor = _getEstadoColor(lote.estado);

    return GlassDialog(
      maxWidth: 620,
      maxHeightFactor: 0.85,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===== HEADER =====
            DialogHeader(
              icon: Icons.inventory_2_rounded,
              title: 'Lote #${lote.id}',
              subtitle: 'Producto ID: ${lote.productoId}',
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: StatusBadge(
                label: lote.estado.toUpperCase(),
                color: estadoColor,
                icon: _getEstadoIcon(lote.estado),
                size: StatusBadgeSize.medium,
              ),
            ),
            const SizedBox(height: 18),

            // ===== CONTENIDO SCROLLABLE =====
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // INFO LOTE
                    _buildInfoSection(colorScheme, esAdmin),

                    const SizedBox(height: 16),

                    // ACCIONES
                    _buildAcciones(lote, esAdmin, colorScheme),

                    const SizedBox(height: 16),

                    // HISTORIAL
                    _buildHistorialSection(colorScheme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO SECTION
  // ============================================================
  Widget _buildInfoSection(ColorScheme colorScheme, bool esAdmin) {
    final lote = widget.lote;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          if (esAdmin) ...[
            _infoRow('Producto ID', '${lote.productoId}', colorScheme),
            const SizedBox(height: 6),
          ],
          _infoRow('Código de barras',
              lote.codigoLoteProveedor ?? 'No asignado', colorScheme),
          const SizedBox(height: 6),
          _infoRow('Cantidad inicial', '${lote.cantidadInicial} kg',
              colorScheme),
          const SizedBox(height: 6),
          _infoRow('Cantidad restante', '${lote.cantidadRestante} kg',
              colorScheme),
          const SizedBox(height: 6),
          _infoRow('Ingreso',
              DateFormat('dd/MM/yyyy HH:mm').format(lote.fechaIngreso),
              colorScheme),
          const SizedBox(height: 6),
          _infoRow(
            'Vencimiento',
            lote.fechaVencimiento != null
                ? DateFormat('dd/MM/yyyy').format(lote.fechaVencimiento!)
                : 'Sin vencimiento',
            colorScheme,
          ),
          if (lote.costoUnitario != null) ...[
            const SizedBox(height: 6),
            _infoRow(
              'Costo unitario',
              '\$${lote.costoUnitario!.toStringAsFixed(2)}',
              colorScheme,
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, ColorScheme colorScheme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
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
    );
  }

  // ============================================================
  // ACCIONES
  // ============================================================
  Widget _buildAcciones(
      LoteEntity lote, bool esAdmin, ColorScheme colorScheme) {
    final acciones = <Widget>[];

    if (lote.estado == 'activo' && lote.cantidadRestante > 0 && esAdmin) {
      acciones.add(_actionButton(
        icon: Icons.swap_horiz_rounded,
        label: 'Reponer',
        color: _colorSuccess,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => TraspasoLoteDialog(lote: lote),
          ).then((_) => _recargarMovimientos());
        },
      ));
    }

    if (lote.estado == 'activo' && esAdmin) {
      acciones.add(_actionButton(
        icon: Icons.edit_rounded,
        label: 'Editar',
        color: _colorPrimary,
        outlined: true,
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => EditarLoteDialog(lote: lote),
          ).then((_) => _recargarMovimientos());
        },
      ));
    }

    acciones.add(_actionButton(
      icon: Icons.qr_code_rounded,
      label: 'Ver códigos',
      color: _colorInfo,
      outlined: true,
      onPressed: () async {
        final producto =
            await _isar.obtenerProductoPorId(lote.productoId);
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (_) => HistorialCodigosDialog(
            productoId: lote.productoId,
            productoNombre:
                producto?.nombre ?? 'Producto #${lote.productoId}',
          ),
        );
      },
    ));

    if (lote.cantidadRestante == 0 && esAdmin) {
      acciones.add(_actionButton(
        icon: Icons.delete_outline_rounded,
        label: 'Eliminar',
        color: _colorDanger,
        outlined: true,
        onPressed: _confirmarEliminar,
      ));
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: acciones,
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool outlined = false,
  }) {
    if (outlined) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 16),
          label: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color.withValues(alpha: 0.4), width: 1.2),
            backgroundColor: color.withValues(alpha: 0.06),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      );
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }

  // ============================================================
  // HISTORIAL
  // ============================================================
  Widget _buildHistorialSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.history_rounded,
                size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              'Historial de movimientos',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
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
              return const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final movimientos = snapshot.data ?? [];
            if (movimientos.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'Sin movimientos',
                    style: TextStyle(
                        color: colorScheme.onSurfaceVariant, fontSize: 12),
                  ),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: movimientos.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.4),
              ),
              itemBuilder: (context, index) {
                final m = movimientos[index];
                final color = _getTipoColor(m.tipo);
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getTipoIcon(m.tipo), size: 16, color: color),
                  ),
                  title: Text(
                    '${m.tipo.toUpperCase()} - ${m.cantidad} und',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(
                    '${DateFormat('dd/MM/yyyy HH:mm').format(m.fecha)} • Usuario: ${m.usuarioId}',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return _colorWarning;
      case 'activo':
        return _colorSuccess;
      case 'agotado':
        return _colorDanger;
      case 'vencido':
        return _colorPrimary;
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'pendiente':
        return Icons.hourglass_top_rounded;
      case 'activo':
        return Icons.check_circle_rounded;
      case 'agotado':
        return Icons.cancel_rounded;
      case 'vencido':
        return Icons.warning_amber_rounded;
      default:
        return Icons.circle_rounded;
    }
  }

  IconData _getTipoIcon(String tipo) {
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

  Color _getTipoColor(String tipo) {
    switch (tipo) {
      case 'activacion':
        return _colorSuccess;
      case 'venta':
        return _colorInfo;
      case 'traspaso':
        return _colorWarning;
      case 'devolucion':
        return _colorPrimary;
      default:
        return const Color(0xFF6B7280);
    }
  }

  void _confirmarEliminar() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Lote'),
        content: const Text('¿Estás seguro? Esta acción no se deshace.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: ElevatedButton(
              onPressed: () async {
                final exito = await _isar.eliminarLote(widget.lote.id);
                if (!mounted) return;
                if (exito) {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Lote eliminado'),
                      backgroundColor: _colorSuccess,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('❌ Error al eliminar'),
                      backgroundColor: _colorDanger,
                    ),
                  );
                }
              },
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
  }
}