// lib/features/pos/presentation/widgets/locales/local_card.dart
import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';

class LocalCard extends StatefulWidget {
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
  State<LocalCard> createState() => _LocalCardState();
}

class _LocalCardState extends State<LocalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    final bool activo = widget.local.activo;
    final Color estadoColor = activo ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final String estadoTexto = activo ? 'Activo' : 'Inactivo';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: _isHovered ? 0.10 : 0.06)
                : Colors.white.withValues(alpha: _isHovered ? 0.85 : 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isLocalActual
                  ? const Color(0xFF10B981).withValues(alpha: 0.5)
                  : (isDark
                      ? Colors.white.withValues(alpha: _isHovered ? 0.15 : 0.08)
                      : Colors.white.withValues(alpha: _isHovered ? 0.7 : 0.5)),
              width: widget.isLocalActual ? 2 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isHovered ? 0.15 : 0.06),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
              BoxShadow(
                color: estadoColor.withValues(alpha: _isHovered ? 0.15 : 0.05),
                blurRadius: _isHovered ? 15 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            mouseCursor: SystemMouseCursors.click,
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 14 : 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de estado (barra lateral)
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.local.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 15 : 18,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.isLocalActual) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'ACTUAL',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (widget.local.direccion != null && widget.local.direccion!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.local.direccion!,
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              color: isDark ? Colors.white54 : Colors.black54,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        // Teléfono, Email, RIF (Wrap responsivo)
                        Wrap(
                          spacing: 12,
                          runSpacing: 2,
                          children: [
                            if (widget.local.telefono != null && widget.local.telefono!.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.phone_rounded,
                                    size: isMobile ? 12 : 14,
                                    color: isDark ? Colors.white54 : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      widget.local.telefono!,
                                      style: TextStyle(
                                        fontSize: isMobile ? 11 : 13,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            if (widget.local.email != null && widget.local.email!.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.email_rounded,
                                    size: isMobile ? 12 : 14,
                                    color: isDark ? Colors.white54 : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      widget.local.email!,
                                      style: TextStyle(
                                        fontSize: isMobile ? 11 : 13,
                                        color: isDark ? Colors.white54 : Colors.black54,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            if (widget.local.rif != null && widget.local.rif!.isNotEmpty)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.assignment_rounded,
                                    size: isMobile ? 12 : 14,
                                    color: isDark ? Colors.white54 : Colors.black54,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      'RIF: ${widget.local.rif}',
                                      style: TextStyle(
                                        fontSize: isMobile ? 11 : 13,
                                        color: isDark ? Colors.white54 : Colors.black54,
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

                  // Estado + Botones de acción
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
                          estadoTexto,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: estadoColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Botones de acción
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
                            icon: widget.local.activo
                                ? Icons.pause_circle_outline_rounded
                                : Icons.play_circle_outline_rounded,
                            color: widget.local.activo ? const Color(0xFFF59E0B) : const Color(0xFF10B981),
                            onPressed: widget.onToggleActivo,
                            tooltip: widget.local.activo ? 'Desactivar' : 'Activar',
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

  // Botón de acción mejorado (idéntico al de departamentos)
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
          margin: const EdgeInsets.symmetric(horizontal: 2),
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