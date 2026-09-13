import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import '../common/estado_chip.dart';

class InfoPedido extends StatelessWidget {
  final PedidoEntity pedido;

  const InfoPedido({super.key, required this.pedido});

  static const _colorSuccess = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pedido.proveedorNombre,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 17,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              EstadoChip(
                estado: pedido.estado,
                size: EstadoChipSize.large,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              _infoItem('Empresa', pedido.proveedorEmpresa ?? 'N/A', colorScheme),
              _infoItem('Cédula', pedido.proveedorCedula ?? 'N/A', colorScheme),
              _infoItem('Teléfono', pedido.proveedorTelefono ?? 'N/A', colorScheme),
              _infoItem(
                'Fecha',
                DateFormat('dd/MM/yyyy HH:mm').format(pedido.fechaPedido),
                colorScheme,
              ),
              if (pedido.observaciones?.isNotEmpty ?? false)
                _infoItem('Observaciones', pedido.observaciones!, colorScheme),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: isMobile ? 15 : 17,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '\$${pedido.total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isMobile ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: _colorSuccess,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value, ColorScheme colorScheme) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}