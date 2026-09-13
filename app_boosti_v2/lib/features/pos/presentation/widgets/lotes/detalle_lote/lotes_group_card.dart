// lib/features/pos/presentation/widgets/lotes/detalle_lote/lotes_group_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote/asignar_codigo_lote_dialog.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/lotes_provider.dart';
import '../../common/status_badge.dart';

class LotesGroupCard extends ConsumerStatefulWidget {
  final int productoId;
  final List<LoteEntity> lotes;
  final String estado;
  final Function(LoteEntity) onLoteTap;
  final bool initiallyExpanded;

  const LotesGroupCard({
    super.key,
    required this.productoId,
    required this.lotes,
    required this.estado,
    required this.onLoteTap,
    this.initiallyExpanded = false,
  });

  @override
  ConsumerState<LotesGroupCard> createState() => _LotesGroupCardState();
}

class _LotesGroupCardState extends ConsumerState<LotesGroupCard> {
  String? _productoNombre;
  double _stockTotal = 0;
  late bool _isExpanded;

  static const _colorPendiente = Color(0xFFF59E0B);
  static const _colorActivo = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorVencido = Color(0xFF8B5CF6);
  static const _colorPrimary = Color(0xFF8B5CF6);

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    _cargarProducto();
  }

  Future<void> _cargarProducto() async {
    final isar = IsarService();
    final producto = await isar.obtenerProductoPorId(widget.productoId);
    if (producto != null && mounted) {
      setState(() {
        _productoNombre = producto.nombre;
        _stockTotal = producto.stock;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final estadoColor = _getEstadoColor(widget.estado);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ===== HEADER =====
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _colorActivo.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.inventory_2_rounded,
                            color: _colorActivo, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _productoNombre ??
                                  'Producto #${widget.productoId}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                StatusBadge(
                                  label: _getEstadoLabel(widget.estado),
                                  color: estadoColor,
                                  size: StatusBadgeSize.small,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${widget.lotes.length} lotes • Stock: ${_stockTotal.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _colorActivo.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.lotes.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _colorActivo,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      AnimatedRotation(
                        turns: _isExpanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ===== LISTA EXPANDIBLE =====
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: Column(
                children: widget.lotes
                    .map((lote) => _buildLoteTile(context, lote))
                    .toList(),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoteTile(BuildContext context, LoteEntity lote) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final estadoLoteColor = _getEstadoLoteColor(lote.estado);

    final (diasTexto, diasColor, proximoAVencer) =
        _calcularDias(lote, colorScheme);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => widget.onLoteTap(lote),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.03)
                : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: proximoAVencer
                  ? _colorPendiente.withValues(alpha: 0.5)
                  : estadoLoteColor.withValues(alpha: 0.2),
              width: proximoAVencer ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 44,
                decoration: BoxDecoration(
                  color: estadoLoteColor,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: estadoLoteColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                            fontSize: 14,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: lote.estado.toUpperCase(),
                          color: estadoLoteColor,
                          size: StatusBadgeSize.small,
                        ),
                        if (lote.fechaVencimiento != null) ...[
                          const SizedBox(width: 6),
                          StatusBadge(
                            label: diasTexto,
                            color: diasColor,
                            icon: Icons.event_available_rounded,
                            size: StatusBadgeSize.small,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    _infoRow(
                      Icons.qr_code,
                      lote.codigoLoteProveedor ?? 'Sin asignar',
                      colorScheme,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.inventory_2_rounded,
                            size: 12, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${lote.cantidadRestante} kg',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: estadoLoteColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.calendar_today,
                            size: 12, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${lote.fechaIngreso.day}/${lote.fechaIngreso.month}/${lote.fechaIngreso.year}',
                          style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onSurfaceVariant),
                        ),
                        if (lote.proveedorNombre?.isNotEmpty ?? false) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.business_center_rounded,
                              size: 12, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              lote.proveedorNombre!,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: colorScheme.onSurfaceVariant),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (lote.estado == 'pendiente')
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog<bool>(
                        context: context,
                        builder: (_) => AsignarCodigoLoteDialog(lote: lote),
                      );
                      if (result == true && mounted) {
                        ref.read(lotesProvider.notifier).recargar();
                      }
                    },
                    icon: const Icon(Icons.qr_code_scanner_rounded,
                        size: 14),
                    label: const Text('Activar',
                        style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _colorPendiente,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 12, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            style:
                TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  (String, Color, bool) _calcularDias(
      LoteEntity lote, ColorScheme colorScheme) {
    if (lote.fechaVencimiento == null) {
      return ('', colorScheme.onSurfaceVariant, false);
    }
    final dias = lote.fechaVencimiento!.difference(DateTime.now()).inDays;
    if (dias < 0) return ('VENCIDO', _colorVencido, false);
    if (dias <= 3) return ('¡$dias días!', _colorDanger, true);
    if (dias <= 7) return ('¡$dias días!', _colorPendiente, true);
    if (dias <= 15) return ('$dias días', _colorPendiente, false);
    return ('$dias días', _colorActivo, false);
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return _colorPendiente;
      case 'activo':
        return _colorActivo;
      case 'historial':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getEstadoLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'activo':
        return 'Activo';
      case 'historial':
        return 'Historial';
      default:
        return estado;
    }
  }

  Color _getEstadoLoteColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return _colorPendiente;
      case 'activo':
        return _colorActivo;
      case 'agotado':
        return _colorDanger;
      case 'vencido':
        return _colorVencido;
      default:
        return const Color(0xFF6B7280);
    }
  }
}