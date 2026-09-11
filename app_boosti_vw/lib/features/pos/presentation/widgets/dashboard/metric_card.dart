import 'package:flutter/material.dart';

/// Tarjeta de métrica con estilo glassmorphism, sparkline y badge de variación.
class MetricCard extends StatefulWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;
  final String? subtitulo;
  final Color? subtituloColor;
  final int index;
  final double? variacion;
  final bool variacionPositiva;

  const MetricCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
    this.subtitulo,
    this.subtituloColor,
    this.index = 0,
    this.variacion,
    this.variacionPositiva = true,
  });

  @override
  State<MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<MetricCard> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  double _opacity = 0.0;
  late AnimationController _controller;

  final List<double> _sparklineData = [10, 25, 15, 30, 20, 35, 28];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animateEntry();
  }

  void _animateEntry() {
    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) {
        setState(() => _opacity = 1.0);
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    Widget? badge;
    if (widget.variacion != null) {
      final colorBadge = widget.variacionPositiva ? Colors.green.shade400 : Colors.red.shade400;
      final iconBadge = widget.variacionPositiva ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
      final textoBadge = '${widget.variacionPositiva ? '+' : ''}${widget.variacion!.toStringAsFixed(1)}%';

      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: colorBadge.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorBadge.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconBadge, size: 12, color: colorBadge),
            const SizedBox(width: 2),
            Text(
              textoBadge,
              style: TextStyle(
                fontSize: isMobile ? 9 : 11,
                fontWeight: FontWeight.w700,
                color: colorBadge,
              ),
            ),
          ],
        ),
      );
    }

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
                _isHovered ? 1.02 : 1.0,
                _isHovered ? 1.02 : 1.0,
                1.0,
              ),
          decoration: BoxDecoration(
            color: const Color(0xFF1A2235),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _isHovered ? 0.25 : 0.12),
                blurRadius: _isHovered ? 24 : 16,
                offset: Offset(0, _isHovered ? 8 : 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: _isHovered ? 0.15 : 0.08),
              width: _isHovered ? 1.5 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Sparkline
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: CustomPaint(
                    painter: SparklinePainter(
                      data: _sparklineData,
                      color: widget.color,
                      lineWidth: 2.0,
                    ),
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: badge,
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
                              color: Colors.white70,
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
                          color: widget.subtituloColor ?? Colors.white60,
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

class SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double lineWidth;

  SparklinePainter({
    required this.data,
    required this.color,
    this.lineWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double minValue = data.reduce((a, b) => a < b ? a : b);
    final double maxValue = data.reduce((a, b) => a > b ? a : b);
    final double range = maxValue - minValue;
    final double normalizedRange = range > 0 ? range : 1.0;

    final path = Path();
    final double width = size.width;
    final double height = size.height;
    final double padding = 8.0;
    final double usableWidth = width - padding * 2;
    final double usableHeight = height - padding * 2;

    for (int i = 0; i < data.length; i++) {
      final double x = padding + (i / (data.length - 1)) * usableWidth;
      final double y = padding + (1 - (data[i] - minValue) / normalizedRange) * usableHeight;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(SparklinePainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}