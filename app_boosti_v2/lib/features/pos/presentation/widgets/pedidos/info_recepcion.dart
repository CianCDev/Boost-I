import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class InfoRecepcion extends StatelessWidget {
  final RecepcionEntity recepcion;

  const InfoRecepcion({super.key, required this.recepcion});

  static const _colorSuccess = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _colorSuccess.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _colorSuccess.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _colorSuccess.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: _colorSuccess, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recepción Registrada',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.bold,
                    color: _colorSuccess,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(recepcion.fechaRecepcion)}',
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (recepcion.observaciones?.isNotEmpty ?? false)
                  Text(
                    'Observaciones: ${recepcion.observaciones}',
                    style: TextStyle(
                      fontSize: isMobile ? 11 : 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}