import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../services/sync_service.dart';
import '../utils/responsive_helper.dart';

class EmployeeMonitorDialog extends ConsumerStatefulWidget {
  const EmployeeMonitorDialog({super.key});

  @override
  ConsumerState<EmployeeMonitorDialog> createState() => _EmployeeMonitorDialogState();
}

class _EmployeeMonitorDialogState extends ConsumerState<EmployeeMonitorDialog> {
  late final SyncService _syncService;

  @override
  void initState() {
    super.initState();
    _syncService = SyncService();
  }

  @override
  void dispose() {
    _syncService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    // Dimensiones dinámicas para el diálogo
    final double dialogWidth = isMobile 
        ? MediaQuery.of(context).size.width * 0.92 
        : (isTablet ? 700 : 600);
    
    final double dialogMaxHeight = MediaQuery.of(context).size.height * 0.85;
    final double fontSizeTitle = isMobile ? 18 : (isTablet ? 26 : 22);
    final double fontSizeSubtitle = isMobile ? 12 : (isTablet ? 16 : 14);
    final double fontSizeName = isMobile ? 15 : (isTablet ? 18 : 16);
    final double fontSizeDetail = isMobile ? 11 : (isTablet ? 13 : 11);
    final double fontSizeEstado = isMobile ? 11 : (isTablet ? 14 : 12);
    final double iconSize = isMobile ? 20 : 24;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.brightness == Brightness.dark 
              ? Colors.grey.shade700 
              : Colors.transparent,
          width: 1,
        ),
      ),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12.0 : (isTablet ? 60.0 : 40.0),
        vertical: 24.0,
      ),
      child: Container(
        width: dialogWidth,
        constraints: BoxConstraints(maxHeight: dialogMaxHeight),
        padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TÍTULO
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_alt_rounded,
                    color: theme.brightness == Brightness.dark 
                        ? Colors.blue.shade300 
                        : const Color(0xFF3B82F6),
                    size: iconSize,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Monitor de Empleados',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSizeTitle,
                      color: theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, size: 28, color: theme.textTheme.bodyLarge?.color),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Estado en tiempo real de los cajeros conectados',
              style: TextStyle(
                fontSize: fontSizeSubtitle,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 16),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 12),

            // LISTA DE EMPLEADOS
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                color: const Color(0xFF10B981),
                child: StreamBuilder<List<UsuarioEntity>>(
                  stream: _syncService.streamUsuariosEnTiempoReal(),
                  initialData: const [],
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFF3B82F6)),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: theme.colorScheme.error),
                            const SizedBox(height: 12),
                            Text(
                              'Error al cargar empleados',
                              style: TextStyle(color: theme.colorScheme.error),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              snapshot.error.toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: theme.textTheme.bodySmall?.color,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final usuarios = snapshot.data ?? [];

                    if (usuarios.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 48, color: theme.disabledColor),
                            const SizedBox(height: 12),
                            Text(
                              'No hay empleados registrados',
                              style: TextStyle(color: theme.textTheme.bodyMedium?.color),
                            ),
                          ],
                        ),
                      );
                    }

                    // Ordenar: activos primero, luego por nombre
                    final ordenados = [...usuarios]..sort((a, b) {
                      final estadoA = a.estado ?? 'inactivo';
                      final estadoB = b.estado ?? 'inactivo';
                      if (estadoA == 'activo' && estadoB != 'activo') return -1;
                      if (estadoA != 'activo' && estadoB == 'activo') return 1;
                      return a.nombre.compareTo(b.nombre);
                    });

                    return ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 4 : 8,
                        vertical: isMobile ? 4 : 8,
                      ),
                      itemCount: ordenados.length,
                      separatorBuilder: (_, __) => Divider(
                        color: theme.dividerColor,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final usuario = ordenados[index];
                        final isActive = usuario.estado == 'activo';
                        final isDescanso = usuario.estado == 'descanso' || usuario.estado == 'manualrest';

                        Color estadoColor;
                        String estadoTexto;
                        IconData estadoIcon;

                        if (isActive) {
                          estadoColor = const Color(0xFF10B981);
                          estadoTexto = 'Activo';
                          estadoIcon = Icons.point_of_sale;
                        } else if (isDescanso) {
                          estadoColor = Colors.orange;
                          estadoTexto = 'En Descanso';
                          estadoIcon = Icons.coffee;
                        } else {
                          estadoColor = theme.brightness == Brightness.dark
                              ? Colors.grey.shade500
                              : const Color(0xFF64748B);
                          estadoTexto = 'Inactivo';
                          estadoIcon = Icons.power_off;
                        }

                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 4 : 8,
                            vertical: isMobile ? 2 : 4,
                          ),
                          leading: CircleAvatar(
                            radius: isMobile ? 20 : 24,
                            backgroundColor: estadoColor.withOpacity(0.15),
                            child: Icon(
                              estadoIcon,
                              color: estadoColor,
                              size: isMobile ? 18 : 22,
                            ),
                          ),
                          title: Text(
                            usuario.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSizeName,
                              color: theme.textTheme.bodyLarge?.color,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Rol: ${usuario.rol.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: fontSizeDetail,
                                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 6 : 8,
                                  vertical: isMobile ? 2 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: estadoColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: estadoColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      estadoIcon,
                                      size: isMobile ? 12 : 14,
                                      color: estadoColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      estadoTexto,
                                      style: TextStyle(
                                        color: estadoColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: fontSizeEstado,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          trailing: isActive
                              ? Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withOpacity(0.5),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                          dense: true,
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 12),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Los cambios se actualizan automáticamente',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: isMobile ? 11 : 13,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 12 : 20,
                      vertical: isMobile ? 8 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {});
                  },
                  child: Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: isMobile ? 14 : 16),
                      const SizedBox(width: 4),
                      Text(
                        'Actualizar',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}