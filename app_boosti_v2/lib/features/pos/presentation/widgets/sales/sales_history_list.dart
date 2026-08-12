import 'package:flutter/material.dart';
import '../../../data/Local/entities/venta_entity.dart';
import 'sales_history_item.dart';

class SalesHistoryList extends StatelessWidget {
  final List<VentaEntity> ventas;
  final bool isMobile;
  final bool isTablet;
  final bool shrinkWrap;

  const SalesHistoryList({
    super.key,
    required this.ventas,
    required this.isMobile,
    required this.isTablet,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (ventas.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No hay ventas registradas en el periodo seleccionado.',
            style: TextStyle(
              fontSize: isTablet ? 18 : 13,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      itemCount: ventas.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final venta = ventas[index];
        return SalesHistoryItem(
          venta: venta,
          isMobile: isMobile,
          isTablet: isTablet,
        );
      },
    );
  }
}