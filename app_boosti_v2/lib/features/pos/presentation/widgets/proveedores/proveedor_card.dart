// lib/features/pos/presentation/widgets/proveedores/proveedor_card.dart
import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class ProveedorCard extends StatefulWidget {
  final ProveedorEntity proveedor;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActivo;
  final VoidCallback onDelete;

  const ProveedorCard({
    super.key,
    required this.proveedor,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActivo,
    required this.onDelete,
  });

  @override
  State<ProveedorCard> createState() => _ProveedorCardState();
}

class _ProveedorCardState extends State<ProveedorCard> {
  // Estado para controlar el hover de toda la card
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final bool activo = widget.proveedor.activo;
    final Color estadoColor = activo ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // Ajustado al mismo padding de departamentos
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: isHovered ? 0.10 : 0.06)
                : Colors.white.withValues(alpha: isHovered ? 0.85 : 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: isHovered ? 0.15 : 0.08)
                  : Colors.white.withValues(alpha: isHovered ? 0.7 : 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isHovered ? 0.15 : 0.06),
                blurRadius: isHovered ? 20 : 10,
                offset: Offset(0, isHovered ? 8 : 4),
              ),
              // Sombra de color del estado
              BoxShadow(
                color: estadoColor.withValues(alpha: isHovered ? 0.15 : 0.05),
                blurRadius: isHovered ? 15 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            mouseCursor: SystemMouseCursors.click,
            child: Padding(
              padding: const EdgeInsets.all(18), // Ajustado al padding interno de 18
              child: Row(
                children: [
                  // Indicador de estado (barra lateral con brillo)
                  Container(
                    width: 4,
                    height: 48,
                    decoration: BoxDecoration(
                      color: estadoColor,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: estadoColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.proveedor.nombre,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, // Tamaño fijo como en departamentos
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.proveedor.empresa != null && widget.proveedor.empresa!.isNotEmpty)
                          Text(
                            widget.proveedor.empresa!,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 2),
                        // Fila: Teléfono y RIF estructurados como los iconos de departamentos
                        Row(
                          children: [
                            if (widget.proveedor.telefono != null && widget.proveedor.telefono!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.phone_rounded,
                                      size: 14, color: isDark ? Colors.white54 : Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.proveedor.telefono!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            if (widget.proveedor.telefono != null && widget.proveedor.telefono!.isNotEmpty &&
                                widget.proveedor.cedula != null && widget.proveedor.cedula!.isNotEmpty)
                              const SizedBox(width: 12),
                            if (widget.proveedor.cedula != null && widget.proveedor.cedula!.isNotEmpty)
                              Row(
                                children: [
                                  Icon(Icons.badge_rounded,
                                      size: 14, color: isDark ? Colors.white54 : Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(
                                    'RIF: ${widget.proveedor.cedula}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Estado + Botones de acción alineados a la derecha
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Badge de estado
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: estadoColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: estadoColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          activo ? 'Activo' : 'Inactivo',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: estadoColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Botones de acción organizados por bloques
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_rounded,
                            color: const Color(0xFF8B5CF6),
                            onPressed: widget.onEdit,
                            tooltip: 'Editar',
                            isDark: isDark,
                          ),
                          _buildActionButton(
                            icon: widget.proveedor.activo
                                ? Icons.pause_circle_outline_rounded
                                : Icons.play_circle_outline_rounded,
                            color: widget.proveedor.activo ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                            onPressed: widget.onToggleActivo,
                            tooltip: widget.proveedor.activo ? 'Desactivar' : 'Activar',
                            isDark: isDark,
                          ),
                          _buildActionButton(
                            icon: Icons.delete_outline_rounded,
                            color: const Color(0xFFEF4444),
                            onPressed: widget.onDelete,
                            tooltip: 'Eliminar',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Estructura del botón de acción idéntica a la de departamentos
  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
    required bool isDark,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2), // Margen estrecho idéntico
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: color,
          ),
        ),
      ),
    );
  }
}