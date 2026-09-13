// lib/features/pos/presentation/widgets/lotes/lote_card.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import '../common/glass_card.dart';
import '../common/status_badge.dart';

class LoteCard extends StatelessWidget {
  final LoteEntity lote;
  final bool esAdmin;
  final VoidCallback onTap;
  final VoidCallback? onVerificar;
  final VoidCallback? onReponer;
  final bool isProximoAVencer;

  const LoteCard({
    super.key,
    required this.lote,
    required this.esAdmin,
    required this.onTap,
    this.onVerificar,
    this.onReponer,
    this.isProximoAVencer = false,
  });

  static const _colorPendiente = Color(0xFFF59E0B);
  static const _colorActivo = Color(0xFF10B981);
  static const _colorAgotado = Color(0xFFEF4444);
  static const _colorVencido = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final estadoColor = _getEstadoColor(lote.estado);
    final estadoTexto = _getEstadoTexto(lote.estado);
    final estadoIcon = _getEstadoIcon(lote.estado);

    final fechaIngreso =
        DateFormat('dd/MM/yyyy HH:mm').format(lote.fechaIngreso);
    final fechaVencimiento = lote.fechaVencimiento != null
        ? DateFormat('dd/MM/yyyy').format(lote.fechaVencimiento!)
        : 'Sin vencimiento';

    final (diasRestantes, diasColor) = _calcularDiasRestantes(colorScheme);

    return FutureBuilder<ProductoEntity?>(
      future: IsarService().obtenerProductoPorId(lote.productoId),
      builder: (context, snapshot) {
        final productoNombre =
            snapshot.data?.nombre ?? 'Producto #${lote.productoId}';

        return GlassCard(
          onTap: onTap,
          showStatusBar: true,
          statusColor: estadoColor,
          isHighlighted: isProximoAVencer,
          highlightColor: _colorPendiente,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              Row(
                children: [
                  Expanded(
                    child: Text(
                      productoNombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: estadoTexto,
                    color: estadoColor,
                    icon: estadoIcon,
                    size: StatusBadgeSize.small,
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // ===== CÓDIGO =====
              if (lote.codigoLoteProveedor?.isNotEmpty ?? false)
                _infoRow(
                  Icons.qr_code,
                  'Código: ${lote.codigoLoteProveedor}',
                  colorScheme,
                ),

              _infoRow(
                Icons.inventory_2_rounded,
                'Inicial: ${lote.cantidadInicial}  •  Restante: ${lote.cantidadRestante}',
                colorScheme,
              ),
              _infoRow(
                Icons.calendar_today_rounded,
                'Ingreso: $fechaIngreso',
                colorScheme,
              ),
              _infoRow(
                Icons.event_available_rounded,
                'Vence: $fechaVencimiento',
                colorScheme,
                trailing: diasRestantes != null
                    ? StatusBadge(
                        label: diasRestantes,
                        color: diasColor ?? colorScheme.primary,
                        size: StatusBadgeSize.small,
                      )
                    : null,
              ),

              // ===== BOTONES =====
              if (onVerificar != null) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: ElevatedButton.icon(
                      onPressed: onVerificar,
                      icon: const Icon(Icons.qr_code_scanner_rounded,
                          size: 18),
                      label: const Text('Verificar y Activar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _colorPendiente,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],

              if (onVerificar == null &&
                  (onReponer != null || isProximoAVencer)) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isProximoAVencer && onReponer == null) ...[
                      StatusBadge(
                        label: 'Próximo a vencer',
                        color: _colorPendiente,
                        icon: Icons.warning_amber_rounded,
                        size: StatusBadgeSize.small,
                      ),
                      const Spacer(),
                    ],
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: TextButton(
                        onPressed: onTap,
                        child: Text(
                          'Ver Detalle',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    if (onReponer != null) ...[
                      const SizedBox(width: 8),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ElevatedButton.icon(
                          onPressed: onReponer,
                          icon: const Icon(Icons.swap_horiz_rounded,
                              size: 16),
                          label: const Text('Reponer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _colorActivo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================
  (String?, Color?) _calcularDiasRestantes(ColorScheme colorScheme) {
    if (lote.fechaVencimiento == null) return (null, null);
    final dias = lote.fechaVencimiento!.difference(DateTime.now()).inDays;
    if (dias <= 0) return ('VENCIDO', _colorVencido);
    if (dias <= 7) return ('¡$dias días!', _colorPendiente);
    if (dias <= 30) return ('$dias días', const Color(0xFF3B82F6));
    return ('$dias días', colorScheme.onSurfaceVariant);
  }

  Widget _infoRow(
    IconData icon,
    String text,
    ColorScheme colorScheme, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 13, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 6),
            trailing,
          ],
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'pendiente':
        return _colorPendiente;
      case 'activo':
        return _colorActivo;
      case 'agotado':
        return _colorAgotado;
      case 'vencido':
        return _colorVencido;
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'activo':
        return 'Activo';
      case 'agotado':
        return 'Agotado';
      case 'vencido':
        return 'Vencido';
      default:
        return estado;
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
}