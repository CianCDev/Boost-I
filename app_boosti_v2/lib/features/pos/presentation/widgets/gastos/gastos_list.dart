import 'package:flutter/material.dart';
import '../../../data/Local/entities/gasto_entity.dart';
import 'gastos_item.dart';

class GastosList extends StatelessWidget {
  final List<GastoEntity> gastos;
  final bool isMobile;
  final bool isTablet;
  final bool shrinkWrap;

  const GastosList({
    super.key,
    required this.gastos,
    required this.isMobile,
    required this.isTablet,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (gastos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'No hay gastos registrados en el periodo seleccionado.',
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
      itemCount: gastos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final gasto = gastos[index];
        return GastosItem(
          gasto: gasto,
          isMobile: isMobile,
          isTablet: isTablet,
        );
      },
    );
  }
}