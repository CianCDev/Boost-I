import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget del gráfico principal con controles de filtro y tooltip personalizado.
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
  String _periodoSeleccionado = '7d';
  late AnimationController _controller;
  late Animation<double> _animation;

  final Map<String, int> _periodoMap = {
    'hoy': 1,
    '7d': 7,
    '30d': 30,
  };

  OverlayEntry? _tooltipEntry;
  final GlobalKey _chartKey = GlobalKey();

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
    _removeTooltip();
    super.dispose();
  }

  // ============================================================
  // TOOLTIP PERSONALIZADO
  // ============================================================

  void _showTooltip(BuildContext context, Offset position, String titulo, String valor) {
    _removeTooltip();

    final overlay = Overlay.of(context);
    final RenderBox renderBox = _chartKey.currentContext!.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.globalToLocal(position);

    _tooltipEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: localPosition.dx - 60,
        top: localPosition.dy - 80,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.blueGrey.shade800,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                Text(
                  valor,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_tooltipEntry!);
  }

  void _removeTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  // ============================================================
  // DATOS FILTRADOS Y AGRUPADOS
  // ============================================================

  List<Map<String, dynamic>> get _datosFiltrados {
    if (widget.datos.isEmpty) return _generarGhostData();

    final dias = _periodoMap[_periodoSeleccionado] ?? 7;
    final start = widget.datos.length > dias ? widget.datos.length - dias : 0;
    var result = widget.datos.sublist(start);

    if (result.isEmpty) return _generarGhostData();

    if (_periodoSeleccionado == '30d') {
      return _agruparPorSemanas(result);
    }

    if (_periodoSeleccionado == '7d' && result.length > 7) {
      result = result.sublist(result.length - 7);
    }

    if (_periodoSeleccionado == 'hoy' && result.length > 1) {
      result = result.sublist(result.length - 1);
    }

    return result;
  }

  List<Map<String, dynamic>> _agruparPorSemanas(List<Map<String, dynamic>> datos) {
    final List<Map<String, dynamic>> semanas = [];
    final start = datos.length > 30 ? datos.length - 30 : 0;
    final datosUtiles = datos.sublist(start);

    for (int i = 0; i < datosUtiles.length; i += 7) {
      final fin = (i + 7 < datosUtiles.length) ? i + 7 : datosUtiles.length;
      final grupo = datosUtiles.sublist(i, fin);
      final totalSemana = grupo.fold(0.0, (sum, item) => sum + (item['total'] as num).toDouble());
      final fechaStr = grupo.first['fecha'] as String;
      semanas.add({
        'fecha': fechaStr,
        'total': totalSemana,
        'semana': 'Sem ${(i ~/ 7) + 1}',
      });
    }
    return semanas;
  }

  List<Map<String, dynamic>> _generarGhostData() {
    final dias = _periodoMap[_periodoSeleccionado] ?? 7;
    final hoy = DateTime.now();
    final List<Map<String, dynamic>> datos = [];

    final cantidad = dias;
    for (int i = 0; i < cantidad; i++) {
      final fecha = hoy.subtract(Duration(days: cantidad - 1 - i));
      final total = (50 + i * 8 + (i % 5) * 6).toDouble();
      datos.add({
        'fecha': fecha.toIso8601String(),
        'total': total,
      });
    }

    if (_periodoSeleccionado == '30d') {
      return _agruparPorSemanas(datos);
    }

    return datos;
  }

  // ============================================================
  // CONSTRUCCIÓN DEL GRÁFICO
  // ============================================================

  List<BarChartGroupData> _buildBarGroups(
    List<Map<String, dynamic>> datos,
    List<Color> colores,
    bool isDark,
  ) {
    double barWidth = 20;
    if (datos.length > 10) barWidth = 14;
    if (datos.length > 20) barWidth = 10;

    return datos.asMap().entries.map((entry) {
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
            width: widget.compacto ? barWidth * 0.7 : barWidth,
            borderRadius: BorderRadius.circular(4),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: _calcularMaximo(datos) * 1.1,
              color: color.withValues(alpha: isDark ? 0.08 : 0.06),
            ),
          ),
        ],
      );
    }).toList();
  }

  double _calcularMaximo(List<Map<String, dynamic>> datos) {
    if (datos.isEmpty) return 100;
    final max = datos.map((e) => (e['total'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
    return max * 1.2;
  }

  double _calcularIntervalo(List<Map<String, dynamic>> datos) {
    final max = _calcularMaximo(datos);
    if (max < 10) return 2.0;
    if (max < 50) return 10.0;
    if (max < 200) return 50.0;
    if (max < 1000) return 200.0;
    return 500.0;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colores = [
      Colors.cyan.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.orange.shade400,
      Colors.green.shade400,
      Colors.indigo.shade400,
      Colors.pink.shade400,
    ];

    final datosFiltrados = _datosFiltrados;
    final double chartHeight = widget.compacto ? 140 : (isMobile ? 160 : 200);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scaleY: _animation.value,
          child: Container(
            key: _chartKey,
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
                // HEADER
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.show_chart_rounded,
                            size: 18, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          isMobile ? 'Estadísticas' : 'Estadísticas Generales',
                          style: TextStyle(
                            fontSize: widget.compacto ? 13 : 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(value: 'hoy', label: Text('Hoy')),
                        ButtonSegment<String>(value: '7d', label: Text('7D')),
                        ButtonSegment<String>(value: '30d', label: Text('30D')),
                      ],
                      selected: {_periodoSeleccionado},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          _periodoSeleccionado = newSelection.first;
                          _removeTooltip();
                        });
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return Theme.of(context).colorScheme.primary;
                            }
                            return Colors.transparent;
                          },
                        ),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.white;
                            }
                            return isDark ? Colors.grey.shade400 : Colors.grey.shade600;
                          },
                        ),
                        side: WidgetStateProperty.resolveWith<BorderSide>(
                          (states) {
                            if (states.contains(WidgetState.selected)) {
                              return BorderSide.none;
                            }
                            return BorderSide(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                            );
                          },
                        ),
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        ),
                        textStyle: WidgetStateProperty.all(
                          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // GRÁFICO con tooltip personalizado
                SizedBox(
                  height: chartHeight,
                  child: ClipRect(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: _calcularMaximo(datosFiltrados),
                        barGroups: _buildBarGroups(datosFiltrados, colores, isDark),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: !widget.compacto,
                          horizontalInterval: _calcularIntervalo(datosFiltrados),
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 || index >= datosFiltrados.length) {
                                  return const SizedBox.shrink();
                                }
                                final item = datosFiltrados[index];
                                final fechaStr = item['fecha'] as String;
                                final fecha = DateTime.parse(fechaStr);

                                if (_periodoSeleccionado == '30d') {
                                  final semana = item['semana'] as String?;
                                  return Text(
                                    semana ?? '${fecha.day}/${fecha.month}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  );
                                }

                                final dia = fecha.day;
                                if (isMobile || widget.compacto) {
                                  final diasSemana = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
                                  final diaSemana = fecha.weekday - 1;
                                  return Text(
                                    diasSemana[diaSemana],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                    ),
                                  );
                                }
                                return Text(
                                  '$dia/${fecha.month}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
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
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade400,
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
                        // ✅ Tooltip personalizado
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            tooltipRoundedRadius: 8,
                            getTooltipColor: (group) => Colors.transparent,
                            tooltipPadding: EdgeInsets.zero,
                            tooltipMargin: 0,
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                          ),
                          touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                            // Mostrar tooltip al tocar una barra
                            if (event is FlTapDownEvent && response != null && response.spot != null) {
                              final barIndex = response.spot!.touchedBarGroupIndex;
                              if (barIndex >= 0 && barIndex < datosFiltrados.length) {
                                final item = datosFiltrados[barIndex];
                                final total = (item['total'] as num).toDouble();
                                String titulo;
                                if (_periodoSeleccionado == '30d') {
                                  titulo = item['semana'] ?? 'Semana';
                                } else {
                                  final fechaStr = item['fecha'] as String;
                                  final fecha = DateTime.parse(fechaStr);
                                  titulo = '${fecha.day}/${fecha.month}';
                                }
                                final valor = '\$${total.toStringAsFixed(2)}';
                                _showTooltip(
                                  context,
                                  event.localPosition,
                                  titulo,
                                  valor,
                                );
                              }
                            }
                            // Cerrar tooltip al soltar o al finalizar cualquier otro gesto
                            else if (event is FlLongPressEnd || event is FlTapUpEvent) {
                              _removeTooltip();
                            }
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
}