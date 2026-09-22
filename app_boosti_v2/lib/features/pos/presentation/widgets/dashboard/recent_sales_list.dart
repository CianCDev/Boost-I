// lib/features/pos/presentation/widgets/dashboard/recent_sales_list.dart
import 'package:flutter/material.dart';
import '../../../data/Local/entities/venta_entity.dart';

/// Lista compacta de las últimas ventas.
class RecentSalesList extends StatelessWidget {
  final List<VentaEntity> ventas;
  final VoidCallback? onVerTodas;

  const RecentSalesList({
    super.key,
    required this.ventas,
    this.onVerTodas,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mostrar = ventas.take(isMobile ? 3 : 5).toList();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutQuad,
      opacity: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long_rounded,
                    size: 20, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Últimas ventas',
                    style: TextStyle(
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                    ),
                  ),
                ),
                if (onVerTodas != null)
                  TextButton(
                    onPressed: onVerTodas,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Ver todas',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (ventas.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay ventas recientes',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ),
              )
            else
              for (int i = 0; i < mostrar.length; i++) ...[
                _buildItem(mostrar[i], i, isMobile, isDark),
                if (i < mostrar.length - 1) const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(VentaEntity venta, int index, bool isMobile, bool isDark) {
    final colorMetodo = _getMetodoPagoColor(venta.metodoPago);
    final iconMetodo = _getMetodoPagoIcon(venta.metodoPago);
    final fecha = venta.fecha ?? DateTime.now();
    final hora =
        '${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';

    // ✅ ID corto: usa el id local de Isar (auto-increment) o últimos 6 del UUID
    final idCorto = _shortId(venta);

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - opacity)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Barra de color del método
            Container(
              width: 4,
              height: 36,
              decoration: BoxDecoration(
                color: colorMetodo,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),

            // ── Bloque central (expanded para no desbordar) ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fila 1: ícono + ID corto
                  Row(
                    children: [
                      Icon(iconMetodo, size: 13, color: colorMetodo),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          idCorto,
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.grey.shade200
                                : Colors.grey.shade800,
                            letterSpacing: 0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Fila 2: empleado · hora · items
                  Text(
                    _buildSubtitle(venta, hora),
                    style: TextStyle(
                      fontSize: isMobile ? 10 : 11,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Total a la derecha (siempre visible) ──
            Text(
              '\$${venta.total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.bold,
                color: Colors.cyan.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Devuelve un ID corto y legible para mostrar en la lista.
  ///
  /// Prioriza el `id` local de Isar (ej: #42) porque es corto y estable.
  /// Si no hay, usa los últimos 6 caracteres del UUID de Supabase.
  String _shortId(VentaEntity venta) {
    if (venta.id > 0) return '#${venta.id}';
    final uuid = venta.ventaIdString;
    if (uuid.isEmpty) return '#---';
    if (uuid.length <= 6) return '#$uuid';
    return '#…${uuid.substring(uuid.length - 6)}';
  }

  /// Compone "empleado · hora · N items" en una sola línea.
  String _buildSubtitle(VentaEntity venta, String hora) {
    final partes = <String>[venta.empleadoNombre];
    partes.add(hora);
    if (venta.items.isNotEmpty) {
      final items = venta.items.fold<int>(0, (s, i) => s + i.cantidad.toInt());
      if (items > 0) partes.add('$items items');
    }
    return partes.join(' · ');
  }

  Color _getMetodoPagoColor(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'efectivo':
        return Colors.green.shade500;
      case 'pago móvil':
      case 'transferencia':
        return Colors.blue.shade500;
      case 'punto':
        return Colors.orange.shade500;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getMetodoPagoIcon(String metodo) {
    switch (metodo.toLowerCase()) {
      case 'efectivo':
        return Icons.money_rounded;
      case 'pago móvil':
        return Icons.phone_android_rounded;
      case 'transferencia':
        return Icons.account_balance_rounded;
      case 'punto':
        return Icons.credit_card_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }
}