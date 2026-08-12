import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class SalesChart extends StatefulWidget {
  final List<Map<String, dynamic>> datos;
  final bool compacto;

  const SalesChart({
    super.key,
    required this.datos,
    this.compacto = false,
  });

  @override
  State<SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.datos.isEmpty) {
      return _buildEmptyState();
    }

    final isMobile = MediaQuery.of(context).size.width < 600;
    final colores = [
      Colors.blue.shade600,
      Colors.purple.shade600,
      Colors.teal.shade600,
      Colors.orange.shade600,
      Colors.green.shade600,
      Colors.indigo.shade600,
      Colors.pink.shade600,
    ];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scaleY: _animation.value,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart_rounded, size: 18, color: Colors.blue.shade600),
                    const SizedBox(width: 8),
                    Text(
                      'Ventas de los últimos 7 días',
                      style: TextStyle(
                        fontSize: widget.compacto ? 13 : 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: widget.compacto ? 140 : 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: _calcularMaximo(),
                      barGroups: _buildBarGroups(colores),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: !widget.compacto,
                        horizontalInterval: _calcularIntervalo(),
                        drawVerticalLine: false,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < 0 || index >= widget.datos.length) {
                                return const SizedBox.shrink();
                              }
                              final fechaStr = widget.datos[index]['fecha'] as String;
                              final fecha = DateTime.parse(fechaStr);
                              final dia = fecha.day;

                              if (isMobile || widget.compacto) {
                                final diasSemana = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                                final diaSemana = fecha.weekday - 1;
                                return Text(
                                  diasSemana[diaSemana],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              }

                              return Text(
                                '$dia/${fecha.month}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade500,
                                ),
                              );
                            },
                            reservedSize: 22,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: !widget.compacto,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '\$${value.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: Colors.grey.shade400,
                                ),
                              );
                            },
                            reservedSize: 30,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.grey.shade800,
                          tooltipPadding: const EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            final fechaStr = widget.datos[groupIndex]['fecha'] as String;
                            final fecha = DateTime.parse(fechaStr);
                            final fechaFormateada =
                                '${fecha.day}/${fecha.month}/${fecha.year}';
                            return BarTooltipItem(
                              '$fechaFormateada\n\$${rod.toY.toStringAsFixed(2)}',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<BarChartGroupData> _buildBarGroups(List<Color> colores) {
    return widget.datos.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final total = (item['total'] as num).toDouble();
      final color = colores[index % colores.length];

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: total,
            color: color,
            width: widget.compacto ? 14 : 20,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calcularMaximo() * 1.1,
              color: color.withValues(alpha: 0.06),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _calcularMaximo() {
    if (widget.datos.isEmpty) return 100;
    final max = widget.datos.map((e) => (e['total'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  double _calcularIntervalo() {
    final max = _calcularMaximo();
    if (max < 10) return 2;
    if (max < 50) return 10;
    if (max < 200) return 50;
    if (max < 1000) return 200;
    return 500;
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.show_chart_rounded, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text(
              'Sin datos de ventas',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}