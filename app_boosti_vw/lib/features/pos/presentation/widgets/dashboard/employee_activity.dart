import 'package:flutter/material.dart';

/// Widget que muestra la actividad de empleados con barras horizontales.
class EmployeeActivity extends StatelessWidget {
  final Map<String, double> empleados;

  const EmployeeActivity({super.key, required this.empleados});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // ✅ maxTotal declarado como double explícitamente
    final double maxTotal = empleados.values.isNotEmpty
        ? empleados.values.reduce((a, b) => a > b ? a : b)
        : 0.0;

    final entries = empleados.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
                Icon(Icons.people_alt_rounded, size: 20, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'Rendimiento del equipo',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (empleados.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No hay ventas registradas esta semana',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ] else ...[
              for (int i = 0; i < entries.length; i++) ...[
                _buildItem(entries[i], i, isMobile, maxTotal, isDark),
                if (i < entries.length - 1) const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItem(MapEntry<String, double> entry, int index, bool isMobile, double maxTotal, bool isDark) {
    // ✅ porcentaje declarado como double
    final double porcentaje = maxTotal > 0 ? entry.value / maxTotal : 0.0;

    final colores = [
      Colors.green.shade600,
      Colors.blue.shade600,
      Colors.purple.shade600,
      Colors.orange.shade600,
      Colors.teal.shade600,
      Colors.pink.shade600,
      Colors.indigo.shade600,
    ];
    final color = colores[entry.key.hashCode % colores.length];

    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(20 * (1 - opacity), 0),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: isMobile ? 12 : 14,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Text(
                  entry.key.substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 14,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Text(
                '\$${entry.value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: isMobile ? 11 : 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: porcentaje.clamp(0.0, 1.0), // ✅ ahora es double
              backgroundColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
              color: color,
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}