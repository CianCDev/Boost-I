import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/log_entity.dart';
import '../utils/responsive_helper.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    // Ajuste dinámico del Grid
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
    final childAspectRatio = isMobile ? 1.2 : (isTablet ? 2.5 : 3.0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ← dinámico
      appBar: AppBar(
        title: const Text(
          'Auditoría del Sistema',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor, // ← usa el color primario del tema
                // ignore: dead_code
                theme.primaryColorDark,
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}), // recarga
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

            return Padding(
              padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  final fechaLocal = log.fecha.toLocal();
                  final String fechaFormatted =
                      '${fechaLocal.day.toString().padLeft(2, '0')}/'
                      '${fechaLocal.month.toString().padLeft(2, '0')}/'
                      '${fechaLocal.year} - '
                      '${fechaLocal.hour.toString().padLeft(2, '0')}:'
                      '${fechaLocal.minute.toString().padLeft(2, '0')}';

                  // Determinar colores e íconos según la acción
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

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    color: theme.cardColor, // ← dinámico
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
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}