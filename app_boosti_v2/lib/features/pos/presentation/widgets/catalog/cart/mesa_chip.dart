// lib/features/pos/presentation/widgets/catalog/cart/mesa_chip.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/comanda_provider.dart';

import 'asignar_mesa_dialog.dart';

/// Chip de mesa del carrito (R.2 Fase 1).
///
/// Solo aparece en modo restaurante (`flags.requiereMesa`). En retail no se
/// renderiza NADA: el POS de retail queda intacto.
///
/// 3 estados:
///   · Sin mesa y 0 comandas  → "Sin mesa · Asignar"      (gris)
///   · Sin mesa y N vivas     → "N mesas abiertas · Ver" (ámbar)
///   · Con mesa asignada      → "Mesa N · $X"            (ámbar)
class MesaChip extends ConsumerWidget {
  /// Callback alternativo al tap. Si es null, abre el diálogo.
  final VoidCallback? onTap;

  /// Margen exterior.
  final EdgeInsets margin;

  const MesaChip({
    super.key,
    this.onTap,
    this.margin = const EdgeInsets.fromLTRB(12, 0, 12, 10),
  });

  static const _colorLibre = Color(0xFF94A3B8);
  static const _colorOcupada = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Early return de retail: no se dibuja nada.
    final flags = ref.watch(featureFlagsProvider);
    if (!flags.requiereMesa) return const SizedBox.shrink();

    final comandas = ref.watch(comandasProvider);
    final comanda = comandas.comandaActiva;
    final activas = comandas.activas.length;

    return Padding(
      padding: margin,
      child: _chip(context, comanda, activas),
    );
  }

  Widget _chip(
    BuildContext context,
    CartSessionEntity? comanda,
    int activas,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String texto;
    final Color color;
    final IconData icono;

    if (comanda != null) {
      texto = '${comanda.mesaNombre ?? 'Mesa'} · '
          '\$${comanda.total.toStringAsFixed(2)}';
      color = _colorOcupada;
      icono = Icons.table_restaurant_rounded;
    } else if (activas > 0) {
      final plural = activas == 1 ? '' : 's';
      texto = '$activas mesa$plural abierta$plural · Ver';
      color = _colorOcupada;
      icono = Icons.table_chart_outlined;
    } else {
      texto = 'Sin mesa · Asignar';
      color = _colorLibre;
      icono = Icons.add_circle_outline_rounded;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () => AsignarMesaDialog.mostrar(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.16 : 0.10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.45),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(icono, size: 16, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  texto,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
