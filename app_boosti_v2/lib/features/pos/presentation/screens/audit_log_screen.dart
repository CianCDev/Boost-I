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

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Auditoría del Sistema', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color.fromRGBO(81, 120, 252, 1), Color.fromARGB(255, 62, 40, 189)],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<LogEntity>>(
        future: _isarService.obtenerLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)));
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar los logs: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final logs = snapshot.data ?? [];

          if (logs.isEmpty) {
            return const Center(
              child: Text(
                'No hay registros de auditoría aún.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            );
          }

          // ==========================================
          // GRID VIEW RESPONSIVO (1 columna móvil, 2 columnas tablet/PC)
          // ==========================================
          return Padding(
            padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 2 : 1, // 2 columnas en tablet, 1 en móvil
                childAspectRatio: isMobile ? 1.4 : 2.2, // Más alargadas en tablet para aprovechar el ancho
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final fechaLocal = log.fecha.toLocal();
                final String fechaFormatted =
                    '${fechaLocal.day.toString().padLeft(2, '0')}/${fechaLocal.month.toString().padLeft(2, '0')}/${fechaLocal.year.toString()} - ${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';

                // Determinar colores e íconos según la acción
                Color colorIcon;
                IconData icon;

                if (log.accion.contains('ELIMINAR') || log.accion.contains('BORRAR')) {
                  colorIcon = Colors.red;
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

                return Container(
                  padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorIcon.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: colorIcon, size: isMobile ? 24 : 28),
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
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isMobile ? 14 : 16,
                                      color: const Color(0xFF0F172A),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    log.usuarioRol.toUpperCase(),
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${log.usuarioNombre} • $fechaFormatted',
                              style: TextStyle(fontSize: isMobile ? 11 : 12, color: Color(0xFF64748B)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (log.detalles != null && log.detalles!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                log.detalles!,
                                style: TextStyle(fontSize: isMobile ? 12 : 13, fontStyle: FontStyle.italic, color: Color(0xFF334155)),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}