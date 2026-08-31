// lib/features/pos/presentation/widgets/locales/local_card.dart
import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class LocalCard extends StatelessWidget {
  final LocalEntity local;
  final bool isLocalActual;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActivo;
  final VoidCallback onDelete;

  const LocalCard({
    super.key,
    required this.local,
    this.isLocalActual = false,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActivo,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);

    final Color estadoColor = local.activo ? Colors.green.shade500 : Colors.red.shade400;
    final String estadoTexto = local.activo ? 'Activo' : 'Inactivo';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isLocalActual ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isLocalActual
            ? BorderSide(color: Colors.green.shade400, width: 2)
            : BorderSide.none,
      ),
      color: isLocalActual ? Colors.green.shade50 : colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de estado (línea vertical)
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: estadoColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),

              // Información del local
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            local.nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge "Actual"
                        if (isLocalActual)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade400),
                            ),
                            child: Text(
                              'ACTUAL',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),

                    // Dirección
                    if (local.direccion != null && local.direccion!.isNotEmpty) ...[
                      Text(
                        local.direccion!,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],

                    // Teléfono, Email y RIF
                    Wrap(
                      spacing: 12,
                      runSpacing: 2,
                      children: [
                        if (local.telefono != null && local.telefono!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: isMobile ? 12 : 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  local.telefono!,
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        if (local.email != null && local.email!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.email_rounded,
                                size: isMobile ? 12 : 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  local.email!,
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        if (local.rif != null && local.rif!.isNotEmpty)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.assignment_rounded,
                                size: isMobile ? 12 : 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  'RIF: ${local.rif}',
                                  style: TextStyle(
                                    fontSize: isMobile ? 11 : 13,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Badge de estado y acciones
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: estadoColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: estadoColor, width: 0.5),
                    ),
                    child: Text(
                      estadoTexto,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: estadoColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Botón Editar (tamaño aumentado para móvil)
                      _buildActionButton(
                        icon: Icons.edit_rounded,
                        color: const Color(0xFF8B5CF6),
                        onPressed: onEdit,
                        tooltip: 'Editar',
                        isMobile: isMobile,
                      ),
                      // Botón Activar/Desactivar
                      _buildActionButton(
                        icon: local.activo
                            ? Icons.pause_circle_outline_rounded
                            : Icons.play_circle_outline_rounded,
                        color: local.activo ? Colors.orange : Colors.green,
                        onPressed: onToggleActivo,
                        tooltip: local.activo ? 'Desactivar' : 'Activar',
                        isMobile: isMobile,
                      ),
                      // Botón Eliminar
                      _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        color: Colors.red,
                        onPressed: onDelete,
                        tooltip: 'Eliminar',
                        isMobile: isMobile,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
    required bool isMobile,
  }) {
    return IconButton(
      icon: Icon(icon, size: isMobile ? 22 : 18, color: color),
      onPressed: onPressed,
      padding: isMobile ? const EdgeInsets.all(8) : EdgeInsets.zero,
      constraints: isMobile
          ? const BoxConstraints(minWidth: 40, minHeight: 40)
          : const BoxConstraints(minWidth: 32, minHeight: 32),
      splashRadius: isMobile ? 24 : 20,
      tooltip: tooltip,
    );
  }
}