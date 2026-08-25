import 'package:flutter/material.dart';

class MetricCard extends StatefulWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final String? subtitulo;
  final Color? subtituloColor;
  final int index;

  const MetricCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    this.subtitulo,
    this.subtituloColor,
    this.index = 0,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();
    _animateEntry();
  }

  void _animateEntry() {
    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      opacity: _opacity,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
          transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0) *
              Matrix4.diagonal3Values(
                _isHovered ? 1.03 : 1.0,
                _isHovered ? 1.03 : 1.0,
                1.0,
              ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _isHovered ? 0.25 : 0.12),
                blurRadius: _isHovered ? 24 : 16,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
            border: Border.all(
              color: widget.color.withValues(alpha: _isHovered ? 0.4 : 0.15),
              width: _isHovered ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 4,
                  decoration: BoxDecoration(
                    color: _isHovered ? widget.color : widget.color.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(4),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isMobile ? 12 : 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: _isHovered ? 0.2 : 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.icono,
                            size: isMobile ? 16 : 20,
                            color: widget.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.titulo,
                            style: TextStyle(
                              fontSize: isMobile ? 10 : 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.valor,
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 28,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                        height: 1.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (widget.subtitulo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitulo!,
                        style: TextStyle(
                          fontSize: isMobile ? 9 : 11,
                          color: widget.subtituloColor ?? (isDark ? Colors.grey.shade400 : Colors.grey.shade500),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}