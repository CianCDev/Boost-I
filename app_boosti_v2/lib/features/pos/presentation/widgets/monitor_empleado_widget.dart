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
    // ignore: unused_local_variable
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 8,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isTablet ? 60.0 : 20.0,
        vertical: 24.0,
      ),
      child: Container(
        width: isTablet ? 700 : double.infinity,
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: theme.dialogBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.people_alt_rounded,
                      color: Color(0xFF3B82F6), size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Monitor de Empleados',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: isTablet ? 26 : 22,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Estado en tiempo real de los cajeros conectados',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: isTablet ? 16 : 14,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            // Stream de usuarios en tiempo real
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Forzar actualización del stream
                  setState(() {});
                },
                color: const Color(0xFF10B981),
                child: StreamBuilder<List<UsuarioEntity>>(
                  stream: _syncService.streamUsuariosEnTiempoReal(),
                  initialData: const [],
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: theme.colorScheme.error),
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
                            Icon(Icons.people_outline,
                                size: 48, color: theme.disabledColor),
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
                    final ordenados = [...usuarios]
                      ..sort((a, b) {
                        final estadoA = a.estado;
                        final estadoB = b.estado;
                        if (estadoA == 'activo' && estadoB != 'activo') return -1;
                        if (estadoA != 'activo' && estadoB == 'activo') return 1;
                        return a.nombre.compareTo(b.nombre);
                      });

                    return ListView.separated(
                      itemCount: ordenados.length,
                      separatorBuilder: (_, _) => const Divider(height: 4),
                      itemBuilder: (context, index) {
                        final usuario = ordenados[index];
                        final isActive = usuario.estado == 'activo';
                        final deviceId = usuario.deviceId ?? '';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isActive
                                ? const Color(0xFF10B981)
                                : theme.dividerColor,
                            child: Text(
                              usuario.nombre.isNotEmpty
                                  ? usuario.nombre[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            usuario.nombre,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isTablet ? 18 : 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.badge_outlined,
                                    size: 14,
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    usuario.rol.toUpperCase(),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      fontSize: isTablet ? 13 : 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // 🔥 device_id (NUEVO)
                                  if (deviceId.isNotEmpty)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.devices,
                                          size: 14,
                                          color: theme.textTheme.bodySmall?.color,
                                        ),
                                        const SizedBox(width: 4),
                                        Tooltip(
                                          message: deviceId, // Muestra el ID completo al pasar mouse
                                          child: Text(
                                            'Dispositivo: ${deviceId.substring(0, deviceId.length > 8 ? 8 : deviceId.length)}...',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              fontSize: isTablet ? 13 : 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFD1FAE5)
                                      : theme.dividerColor.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isActive
                                        ? const Color(0xFF10B981)
                                        : theme.dividerColor,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  isActive ? '🟢 Activo' : '⚪ Inactivo',
                                  style: TextStyle(
                                    fontSize: isTablet ? 14 : 12,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? const Color(0xFF065F46)
                                        : theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          trailing: isActive
                              ? Container(
                                  width: 12,
                                  height: 12,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF10B981),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Los cambios se actualizan automáticamente',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: isTablet ? 13 : 11,
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    setState(() {});
                  },
                  child: const Row(
                    children: [
                      Icon(Icons.refresh_rounded, size: 16),
                      SizedBox(width: 4),
                      Text('Actualizar', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}