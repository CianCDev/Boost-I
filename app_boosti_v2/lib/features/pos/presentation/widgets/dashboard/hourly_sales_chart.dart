// lib/features/pos/presentation/widgets/dashboard/hourly_sales_chart.dart
import 'package:flutter/material.dart';

import 'dashboard_card.dart';

/// Distribución de las ventas de HOY por hora.
///
/// El gráfico de 7 días dice cuánto se vendió, pero no CUÁNDO. Para un
/// restaurante (y para decidir turnos en retail) la hora pico es el dato
/// que permite dimensionar personal. Se dibuja con barras simples para no
/// sumar otro gráfico pesado a la pantalla.
class HourlySalesChart extends StatelessWidget {
  /// Filas con `{hora: int, total: double}` (24 posiciones).
  final List<Map<String, dynamic>> datos;

  const HourlySalesChart({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = const Color(0xFF00E5FF);

    // Solo el tramo con actividad: mostrar 24 barras vacías no informa.
    final activas = datos
        .where((f) => ((f['total'] as num?)?.toDouble() ?? 0) > 0)
        .map((f) => f['hora'] as int)
        .toList();

    if (activas.isEmpty) {
      return DashboardCard(
        titulo: 'Ventas por hora (hoy)',
        icono: Icons.schedule_rounded,
        color: accent,
        subtitulo: 'Sin ventas registradas todavía',
        child: Text(
          'Cuando se registren ventas vas a ver acá las horas pico.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white54 : Colors.grey.shade500,
          ),
        ),
      );
    }

    final desde = (activas.reduce((a, b) => a < b ? a : b) - 1).clamp(0, 23);
    final hasta = (activas.reduce((a, b) => a > b ? a : b) + 1).clamp(0, 23);
    final tramo = datos
        .where((f) {
          final h = f['hora'] as int;
          return h >= desde && h <= hasta;
        })
        .toList();

    final valores = tramo
        .map((f) => (f['total'] as num?)?.toDouble() ?? 0)
        .toList();
    final maximo = valores.reduce((a, b) => a > b ? a : b);
    final horaPico = tramo.firstWhere(
      (f) => ((f['total'] as num?)?.toDouble() ?? 0) == maximo,
    )['hora'] as int;

    return DashboardCard(
      titulo: 'Ventas por hora (hoy)',
      icono: Icons.schedule_rounded,
      color: accent,
      subtitulo: 'Hora pico: '
          '${horaPico.toString().padLeft(2, '0')}:00 – '
          '${(horaPico + 1).toString().padLeft(2, '0')}:00',
      child: SizedBox(
        height: 120,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var i = 0; i < tramo.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Tooltip(
                            message:
                                '${tramo[i]['hora'].toString().padLeft(2, '0')}:00'
                                ' · \$${valores[i].toStringAsFixed(2)}',
                            child: FractionallySizedBox(
                              heightFactor: maximo > 0
                                  ? (valores[i] / maximo).clamp(0.02, 1.0)
                                  : 0.02,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: tramo[i]['hora'] == horaPico
                                      ? accent
                                      : accent.withValues(alpha: 0.35),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Etiqueta cada 3 horas para no saturar en móvil.
                      Text(
                        (tramo[i]['hora'] as int) % 3 == 0
                            ? '${tramo[i]['hora']}h'
                            : '',
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark ? Colors.white38 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
