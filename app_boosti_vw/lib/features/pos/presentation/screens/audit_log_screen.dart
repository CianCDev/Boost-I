import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/log_entity.dart';
import '../utils/responsive_helper.dart';
import '../widgets/appbar.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  final IsarService _isarService = IsarService();

  Future<List<LogEntity>> _cargarLogs() async {
    return await _isarService.obtenerLogs();
  }

  // Agrupa los logs por fecha (sin hora)
  Map<DateTime, List<LogEntity>> _groupLogsByDate(List<LogEntity> logs) {
    final grouped = <DateTime, List<LogEntity>>{};
    for (var log in logs) {
      final date = DateTime(log.fecha.year, log.fecha.month, log.fecha.day);
      grouped.putIfAbsent(date, () => []).add(log);
    }
    return grouped;
  }

  // Construye el encabezado de sección (fecha) centrado y con ancho limitado
  Widget _buildSectionHeader(DateTime date, ThemeData theme) {
    final fechaLocal = date.toLocal();
    final fechaFormatted =
        '${fechaLocal.day.toString().padLeft(2, '0')}/'
        '${fechaLocal.month.toString().padLeft(2, '0')}/'
        '${fechaLocal.year}';
    return Center(
      child: SizedBox(
        width: 600, // Ancho máximo para mantener consistencia
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: theme.dividerColor.withValues(alpha: 0.3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Text(
                  fechaFormatted,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: theme.dividerColor.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Construye una tarjeta de log (diseño original) pero centrada y con ancho fijo
  Widget _buildLogCard(LogEntity log, ThemeData theme, bool isMobile) {
    final fechaLocal = log.fecha.toLocal();
    final fechaFormatted =
        '${fechaLocal.day.toString().padLeft(2, '0')}/'
        '${fechaLocal.month.toString().padLeft(2, '0')}/'
        '${fechaLocal.year} - '
        '${fechaLocal.hour.toString().padLeft(2, '0')}:'
        '${fechaLocal.minute.toString().padLeft(2, '0')}';

    Color colorIcon;
    IconData icon;

    if (log.accion.contains('ELIMINAR') || log.accion.contains('BORRAR')) {
      colorIcon = theme.colorScheme.error;
      icon = Icons.delete_outline;
    } else if (log.accion.contains('GASTO') || log.accion.contains('EGRESO')) {
      colorIcon = Colors.redAccent;
      icon = Icons.money_off;
    } else if (log.accion.contains('CAMBIO_PIN') || log.accion.contains('CLAVE')) {
      colorIcon = const Color(0xFF8B5CF6);
      icon = Icons.lock_reset_rounded;
    } else if (log.accion.contains('CIERRE_SESION')) {
      colorIcon = Colors.orange;
      icon = Icons.logout_rounded;
    } else {
      colorIcon = const Color(0xFF3B82F6);
      icon = Icons.history_rounded;
    }

    return Center(
      child: SizedBox(
        width: 600, // Ancho máximo para todas las tarjetas
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          color: theme.cardColor,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorIcon.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: colorIcon,
                    size: isMobile ? 24 : 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              log.accion.replaceAll('_', ' '),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 14 : 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.dividerColor.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              log.usuarioRol.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${log.usuarioNombre} • $fechaFormatted',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: isMobile ? 11 : 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (log.detalles != null && log.detalles!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          log.detalles!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontSize: isMobile ? 12 : 13,
                            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Auditoría del Sistema',
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        color: const Color(0xFF10B981),
        child: FutureBuilder<List<LogEntity>>(
          future: _cargarLogs(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF10B981)),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error al cargar los logs: ${snapshot.error}',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              );
            }

            final logs = snapshot.data ?? [];

            if (logs.isEmpty) {
              return Center(
                child: Text(
                  'No hay registros de auditoría aún.',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              );
            }

            // Agrupar logs por fecha
            final grouped = _groupLogsByDate(logs);
            final sortedDates = grouped.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            // Construir la lista de widgets centrados
            final List<Widget> children = [];
            for (var date in sortedDates) {
              children.add(_buildSectionHeader(date, theme));
              final logsForDate = grouped[date]!;
              logsForDate.sort((a, b) => b.fecha.compareTo(a.fecha));
              for (var log in logsForDate) {
                children.add(_buildLogCard(log, theme, isMobile));
              }
            }

            return ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 8.0 : 16.0,
                vertical: isMobile ? 8.0 : 16.0,
              ),
              children: children,
            );
          },
        ),
      ),
    );
  }
}