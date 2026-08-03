import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../utils/responsive_helper.dart';

class EmployeeMonitorDialog extends StatefulWidget {
  const EmployeeMonitorDialog({super.key});

  @override
  State<EmployeeMonitorDialog> createState() => _EmployeeMonitorDialogState();
}

class _EmployeeMonitorDialogState extends State<EmployeeMonitorDialog> {
  final IsarService _isarService = IsarService();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);

    // Dimensiones dinámicas
    final double dialogWidth = isMobile
        ? MediaQuery.of(context).size.width * 0.92
        : (isTablet ? 480 : 520);

    final double dialogHeight = isMobile
        ? MediaQuery.of(context).size.height * 0.75
        : 340;

    final double fontSizeTitle = isMobile ? 16 : 18;
    final double fontSizeName = isMobile ? 13 : 14;
    final double fontSizeSubtitle = isMobile ? 10 : 12;
    final double fontSizeEstado = isMobile ? 10 : 12;
    final double iconSize = isMobile ? 16 : 20;

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.brightness == Brightness.dark
              ? Colors.grey.shade700
              : Colors.transparent,
          width: 1,
        ),
      ),
      backgroundColor: theme.cardColor,
      titlePadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 12 : 16,
      ),
      title: Row(
        children: [
          Icon(
            Icons.monitor_heart_outlined,
            color: theme.brightness == Brightness.dark
                ? Colors.blue.shade300
                : const Color(0xFF3B82F6),
            size: 28,
          ),
          const SizedBox(width: 10),
          Text(
            'Monitor de Cajeros',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSizeTitle,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      content: SizedBox(
        width: dialogWidth,
        height: dialogHeight,
        child: FutureBuilder<List<UsuarioEntity>>(
          future: _isarService.obtenerUsuarios(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: theme.brightness == Brightness.dark
                      ? Colors.blue.shade300
                      : const Color(0xFF3B82F6),
                ),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              );
            }
            final usuarios = snapshot.data ?? [];
            if (usuarios.isEmpty) {
              return Center(
                child: Text(
                  'No hay cajeros registrados.',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: isMobile ? 13 : 14,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 4 : 8,
                vertical: isMobile ? 4 : 8,
              ),
              itemCount: usuarios.length,
              separatorBuilder: (_, __) => Divider(
                color: theme.dividerColor,
                height: 1,
              ),
              itemBuilder: (context, index) {
                final usuario = usuarios[index];
                Color colorEstado;
                IconData iconoEstado;
                String textoEstado;

                final estado = (usuario.estado ?? 'inactivo').toLowerCase();
                switch (estado) {
                  case 'activo':
                    colorEstado = const Color(0xFF10B981);
                    iconoEstado = Icons.point_of_sale;
                    textoEstado = 'Activo';
                    break;
                  case 'descanso':
                  case 'manualrest':
                    colorEstado = Colors.orange;
                    iconoEstado = Icons.coffee;
                    textoEstado = 'En Descanso';
                    break;
                  default:
                    colorEstado = theme.brightness == Brightness.dark
                        ? Colors.grey.shade500
                        : const Color(0xFF64748B);
                    iconoEstado = Icons.power_off;
                    textoEstado = 'Inactivo';
                }

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 4 : 8,
                    vertical: isMobile ? 2 : 4,
                  ),
                  leading: CircleAvatar(
                    radius: isMobile ? 16 : 20,
                    backgroundColor: colorEstado.withOpacity(0.15),
                    child: Icon(
                      iconoEstado,
                      color: colorEstado,
                      size: iconSize,
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
                  subtitle: Text(
                    'Rol: ${usuario.rol.toUpperCase()} | Caja: ${usuario.cajaAsignada ?? "No asignada"}',
                    style: TextStyle(
                      fontSize: fontSizeSubtitle,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 6 : 10,
                      vertical: isMobile ? 2 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorEstado.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorEstado.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      textoEstado,
                      style: TextStyle(
                        color: colorEstado,
                        fontWeight: FontWeight.bold,
                        fontSize: fontSizeEstado,
                      ),
                    ),
                  ),
                  dense: true,
                );
              },
            );
          },
        ),
      ),
      actionsPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: theme.textTheme.bodyMedium?.color,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cerrar',
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
            ),
          ),
        ),
      ],
    );
  }
}