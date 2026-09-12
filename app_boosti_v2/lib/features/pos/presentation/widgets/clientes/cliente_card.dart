import 'package:flutter/material.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart';

class ClienteCard extends StatefulWidget {
  final ClienteEntity cliente;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClienteCard({
    super.key,
    required this.cliente,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<ClienteCard> createState() => _ClienteCardState();
}

class _ClienteCardState extends State<ClienteCard> {
  bool _isHovered = false;

  static const Color _colorActivo = Color(0xFF10B981);
  static const Color _colorInactivo = Color(0xFFEF4444);
  static const Color _colorFrecuente = Color(0xFFF59E0B);
  static const Color _colorEdit = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final bool activo = widget.cliente.activo;
    final Color estadoColor = activo ? _colorActivo : _colorInactivo;

    // Superficie: usa surfaceContainer en dark, blanco tenue en light
    final baseColor = isDark
        ? colorScheme.surfaceContainerHigh
        : Colors.white.withValues(alpha: 0.75);
    final hoverColor = isDark
        ? colorScheme.surfaceContainerHighest
        : Colors.white.withValues(alpha: 0.95);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: _isHovered ? hoverColor : baseColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isHovered
                  ? colorScheme.outline.withValues(alpha: 0.4)
                  : colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withValues(alpha: isDark ? (_isHovered ? 0.4 : 0.25) : (_isHovered ? 0.12 : 0.05)),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
              BoxShadow(
                color: estadoColor
                    .withValues(alpha: _isHovered ? 0.18 : 0.06),
                blurRadius: _isHovered ? 15 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // Barra lateral de estado
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.cliente.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.cliente.frecuente) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.star_rounded,
                                  color: _colorFrecuente, size: 16),
                            ]
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (widget.cliente.telefono != null &&
                                widget.cliente.telefono!.isNotEmpty)
                              _buildInfoRow(
                                  Icons.phone_rounded,
                                  widget.cliente.telefono!,
                                  colorScheme),
                            if (widget.cliente.telefono != null &&
                                widget.cliente.documento != null)
                              const SizedBox(width: 12),
                            if (widget.cliente.documento != null &&
                                widget.cliente.documento!.isNotEmpty)
                              _buildInfoRow(
                                  Icons.badge_rounded,
                                  'CI/RIF: ${widget.cliente.documento}',
                                  colorScheme),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
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
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildActionButton(
                            icon: Icons.edit_rounded,
                            color: _colorEdit,
                            onPressed: widget.onEdit,
                          ),
                          _buildActionButton(
                            icon: Icons.delete_outline_rounded,
                            color: _colorInactivo,
                            onPressed: widget.onDelete,
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

  Widget _buildInfoRow(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
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
            border:
                Border.all(color: color.withValues(alpha: 0.25), width: 1),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}