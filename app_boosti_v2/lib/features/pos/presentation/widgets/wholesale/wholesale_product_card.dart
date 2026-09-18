// lib/features/pos/presentation/widgets/wholesale/wholesale_product_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/producto_entity.dart';
import '../../providers/marca_provider.dart';
import '../../providers/themes/app_colors.dart' as AppColors;
import '../../services/mayoreo/wholesale_pricing_service.dart';
import '../../utils/responsive_helper.dart';
import '../common/status_badge.dart';

/// Variante visual de la card.
enum WholesaleCardVariant { grid, list }

/// Tarjeta de producto para la pantalla de ventas al mayor.
///
/// Soporta 2 layouts:
///   - **grid**: imagen grande, información vertical, badge flotante
///   - **list**: layout horizontal, info clara, sin overflow
///
/// **Comportamiento del precio**:
/// Muestra siempre el **mejor precio mayorista disponible**
/// (mayor > medio mayor > detal) independiente de la cantidad.
/// Esto es intencional: el usuario ve "desde" qué precio puede comprar.
class WholesaleProductCard extends ConsumerStatefulWidget {
  final ProductoEntity producto;
  final VoidCallback onTap;
  final int index;

  /// Layout de la card. Default: `grid`.
  final WholesaleCardVariant variant;

  const WholesaleProductCard({
    super.key,
    required this.producto,
    required this.onTap,
    this.index = 0,
    this.variant = WholesaleCardVariant.grid,
  });

  @override
  ConsumerState<WholesaleProductCard> createState() =>
      _WholesaleProductCardState();
}

class _WholesaleProductCardState extends ConsumerState<WholesaleProductCard> {
  bool _isHovered = false;

  // ── Colores por tier ──
  static const _colorMayor = Color(0xFF10B981);
  static const _colorMedio = Color(0xFF3B82F6);
  static const _colorDetal = Color(0xFF64748B);
  static const _colorStockBajo = Color(0xFFF59E0B);

  // ══════════════════════════════════════════════════════════════
  // PRECIO RESUELTO (mejor tier disponible)
  // ══════════════════════════════════════════════════════════════

  /// Devuelve el **mejor** precio mayorista disponible sin importar
  /// cantidad. Prioridad: mayor > medio mayor > detal.
  PrecioResuelto get _mejorPrecio {
    final p = widget.producto;

    // Si no permite mayor → detal
    if (!p.permiteVentaMayor) {
      return PrecioResuelto(
        precioUnitario: p.precioUnidad,
        tipo: PrecioTipo.detal,
        precioDetalOriginal: p.precioUnidad,
      );
    }

    // Preferir MAYOR si existe
    if (p.precioMayor != null && p.precioMayor! > 0) {
      return PrecioResuelto(
        precioUnitario: p.precioMayor!,
        tipo: PrecioTipo.mayor,
        precioDetalOriginal: p.precioUnidad,
        precioMayorAplicado: p.precioMayor,
      );
    }

    // Fallback: MEDIO MAYOR
    if (p.precioMedioMayor != null && p.precioMedioMayor! > 0) {
      return PrecioResuelto(
        precioUnitario: p.precioMedioMayor!,
        tipo: PrecioTipo.medioMayor,
        precioDetalOriginal: p.precioUnidad,
        precioMayorAplicado: p.precioMedioMayor,
      );
    }

    // Último fallback: detal
    return PrecioResuelto(
      precioUnitario: p.precioUnidad,
      tipo: PrecioTipo.detal,
      precioDetalOriginal: p.precioUnidad,
    );
  }

  /// Cantidad mínima requerida para el tier actual.
  int? get _cantidadMinimaTier {
    final p = widget.producto;
    switch (_mejorPrecio.tipo) {
      case PrecioTipo.mayor:
        return p.cantidadMinimaMayor;
      case PrecioTipo.medioMayor:
        return p.cantidadMinimaMedioMayor;
      case PrecioTipo.detal:
        return null;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final p = widget.producto;

    final sinStock = p.stock <= 0;
    final stockBajo = p.stock > 0 && p.stock <= p.stockMinimo;

    final cardBg = isDark
        ? cs.surfaceContainerHigh.withValues(alpha: 0.55)
        : Colors.white;

    final borderColor = _isHovered
        ? cs.primary.withValues(alpha: 0.5)
        : cs.outlineVariant.withValues(alpha: 0.35);

    final shadow = _isHovered
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ];

    return MouseRegion(
      cursor: sinStock
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.4),
          boxShadow: shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: sinStock ? null : widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: widget.variant == WholesaleCardVariant.grid
                ? _buildGridLayout(context, cs, sinStock, stockBajo)
                : _buildListLayout(context, cs, sinStock, stockBajo),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LAYOUT: GRID (vertical, imagen grande, info debajo)
  // ══════════════════════════════════════════════════════════════

  Widget _buildGridLayout(
    BuildContext context,
    ColorScheme cs,
    bool sinStock,
    bool stockBajo,
  ) {
    final p = widget.producto;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Imagen grande con badge flotante ──
          Stack(
            children: [
              _buildImageBig(p),
              // Badge de tier flotante esquina superior derecha
              Positioned(
                top: 6,
                right: 6,
                child: _buildTierBadge(_mejorPrecio.tipo, floating: true),
              ),
              // Overlay "sin stock" sobre la imagen
              if (sinStock)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'SIN STOCK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // ── Nombre ──
          Text(
            p.nombre,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              height: 1.2,
            ),
          ),

          const SizedBox(height: 2),

          // ── Marca ──
          _buildMarcaLine(p, cs),

          const SizedBox(height: 8),

          // ── Precio ──
          _buildPrecio(cs, prominent: true),

          const SizedBox(height: 6),

          // ── Stock ──
          _buildStockCompact(cs, sinStock: sinStock, stockBajo: stockBajo),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // LAYOUT: LIST (horizontal, sin overflow)
  // ══════════════════════════════════════════════════════════════

  Widget _buildListLayout(
    BuildContext context,
    ColorScheme cs,
    bool sinStock,
    bool stockBajo,
  ) {
    final p = widget.producto;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Imagen ──
          Stack(
            children: [
              _buildImageMedium(p),
              if (sinStock)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.block_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // ── Columna central: nombre + marca + código ──
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre + badge tier
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        p.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildTierBadge(_mejorPrecio.tipo),
                  ],
                ),

                const SizedBox(height: 3),

                // Marca
                _buildMarcaLine(p, cs),

                const SizedBox(height: 4),

                // Código de barras
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_2_rounded,
                      size: 11,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        p.codigoBarras,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          color: cs.onSurfaceVariant,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Columna derecha: precio + stock ──
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Precio
              _buildPrecio(cs, prominent: true, compact: true),

              const SizedBox(height: 6),

              // Stock
              _buildStockCompact(
                cs,
                sinStock: sinStock,
                stockBajo: stockBajo,
                alignRight: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // IMÁGENES
  // ══════════════════════════════════════════════════════════════

  /// Imagen grande para grid (cuadrada, ancho completo)
  Widget _buildImageBig(ProductoEntity p) {
    final tieneImagen = p.imagenUrl != null && p.imagenUrl!.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: tieneImagen
              ? Image.network(
                  p.imagenUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(p, 48),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return _placeholder(p, 48);
                  },
                )
              : _placeholder(p, 48),
        ),
      ),
    );
  }

  /// Imagen mediana para lista (64x64)
  Widget _buildImageMedium(ProductoEntity p) {
    final tieneImagen = p.imagenUrl != null && p.imagenUrl!.isNotEmpty;

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: tieneImagen
            ? Image.network(
                p.imagenUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholder(p, 64),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _placeholder(p, 64);
                },
              )
            : _placeholder(p, 64),
      ),
    );
  }

  Widget _placeholder(ProductoEntity p, double size) {
    final initials = p.nombre.trim().isEmpty
        ? '?'
        : p.nombre
            .trim()
            .split(RegExp(r'\s+'))
            .take(2)
            .map((s) => s.isEmpty ? '' : s[0].toUpperCase())
            .join();

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: size * 0.3,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // MARCA
  // ══════════════════════════════════════════════════════════════

  Widget _buildMarcaLine(ProductoEntity p, ColorScheme cs) {
    if (p.marcaSupabaseId != null && p.marcaSupabaseId!.isNotEmpty) {
      final marcaAsync = ref.watch(
        marcaNombrePorSupabaseIdProvider(p.marcaSupabaseId!),
      );
      return marcaAsync.when(
        data: (nombre) => _marcaText(nombre ?? p.marca, cs),
        loading: () => _marcaText(p.marca, cs),
        error: (_, __) => _marcaText(p.marca, cs),
      );
    }
    return _marcaText(p.marca, cs);
  }

  Widget _marcaText(String marca, ColorScheme cs) {
    if (marca.trim().isEmpty) return const SizedBox(height: 0);
    return Text(
      marca,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════
  // BADGE DE TIER
  // ══════════════════════════════════════════════════════════════

  Widget _buildTierBadge(PrecioTipo tipo, {bool floating = false}) {
    Color color;
    String label;
    IconData icon;

    switch (tipo) {
      case PrecioTipo.mayor:
        color = _colorMayor;
        label = 'MAYOR';
        icon = Icons.workspace_premium_rounded;
      case PrecioTipo.medioMayor:
        color = _colorMedio;
        label = 'MEDIO';
        icon = Icons.trending_up_rounded;
      case PrecioTipo.detal:
        color = _colorDetal;
        label = 'DETAL';
        icon = Icons.local_offer_rounded;
    }

    // Badge flotante (sobre imagen): fondo sólido para contraste
    if (floating) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: Colors.white),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      );
    }

    return StatusBadge(
      label: label,
      color: color,
      icon: icon,
      size: StatusBadgeSize.small,
    );
  }

  // ══════════════════════════════════════════════════════════════
  // PRECIO
  // ══════════════════════════════════════════════════════════════

  Widget _buildPrecio(
    ColorScheme cs, {
    required bool prominent,
    bool compact = false,
  }) {
    final precio = _mejorPrecio;
    final precioFinal = precio.precioUnitario;
    final precioDetal = precio.precioDetalOriginal ?? precioFinal;
    final esMayorista = precio.esMayorista;
    final mostrarTachado = esMayorista && precioDetal > precioFinal;
    final cantidadMin = _cantidadMinimaTier;

    // Color del precio según tier
    final precioColor = switch (precio.tipo) {
      PrecioTipo.mayor => _colorMayor,
      PrecioTipo.medioMayor => _colorMedio,
      PrecioTipo.detal => _colorDetal,
    };

    final fontSize = compact ? 16.0 : (prominent ? 20.0 : 18.0);

    return Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Precio grande
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            Text(
              '\$',
              style: TextStyle(
                fontSize: fontSize * 0.6,
                fontWeight: FontWeight.w700,
                color: precioColor,
              ),
            ),
            Text(
              precioFinal.toStringAsFixed(2),
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: precioColor,
                letterSpacing: -0.4,
                height: 1,
              ),
            ),
          ],
        ),

        // "Desde X u." (solo si es mayorista y hay cantidad mínima)
        if (esMayorista && cantidadMin != null && cantidadMin > 1) ...[
          const SizedBox(height: 2),
          Text(
            'Desde $cantidadMin u.',
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: precioColor.withValues(alpha: 0.85),
              letterSpacing: 0.1,
            ),
          ),
        ],

        // Precio detal tachado
        if (mostrarTachado) ...[
          const SizedBox(height: 2),
          Text(
            'Detal: \$${precioDetal.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 10,
              color: cs.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
              decorationColor: cs.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════
  // STOCK COMPACTO
  // ══════════════════════════════════════════════════════════════

  Widget _buildStockCompact(
    ColorScheme cs, {
    required bool sinStock,
    required bool stockBajo,
    bool alignRight = false,
  }) {
    final p = widget.producto;

    Color color;
    IconData icon;
    String label;

    if (sinStock) {
      color = cs.error;
      icon = Icons.block_rounded;
      label = 'Sin stock';
    } else if (stockBajo) {
      color = _colorStockBajo;
      icon = Icons.warning_amber_rounded;
      label = '${_fmt(p.stock)} (bajo)';
    } else {
      color = AppColors.primaryGreen;
      icon = Icons.inventory_2_outlined;
      label = _fmt(p.stock);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:
          alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  String _fmt(double v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 2);
}