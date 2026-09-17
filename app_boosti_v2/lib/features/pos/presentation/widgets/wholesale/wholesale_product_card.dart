// lib/features/pos/presentation/widgets/wholesale/wholesale_product_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/producto_entity.dart';
import '../../providers/marca_provider.dart';
// ignore: unused_import
import '../../providers/themes/app_colors.dart';
import '../../providers/themes/app_colors.dart' as AppColors;
import '../../services/mayoreo/wholesale_pricing_service.dart';
import '../../utils/responsive_helper.dart';
import '../common/status_badge.dart';

/// Tarjeta de producto para la pantalla de ventas al mayor.
///
/// Muestra:
///   - Imagen del producto (o placeholder con iniciales)
///   - Nombre, marca, código de barras
///   - Precio mayor + precio detal tachado (si aplica)
///   - Badge de tipo (Mayor / Medio Mayor / Detal)
///   - Stock + alerta si stock bajo
///   - Ahorro calculado
class WholesaleProductCard extends ConsumerStatefulWidget {
  final ProductoEntity producto;
  final VoidCallback onTap;
  final int index;

  const WholesaleProductCard({
    super.key,
    required this.producto,
    required this.onTap,
    this.index = 0,
  });

  @override
  ConsumerState<WholesaleProductCard> createState() =>
      _WholesaleProductCardState();
}

class _WholesaleProductCardState extends ConsumerState<WholesaleProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final isMobile = ResponsiveHelper.isMobile(context);
    // ignore: unused_local_variable
    final isTablet = ResponsiveHelper.isTablet(context);

    final p = widget.producto;
    final stockBajo = p.stock > 0 && p.stock <= p.stockMinimo;
    final sinStock = p.stock <= 0;
    final colorSchemeLocal = colorScheme;

    // Resolver precio (cantidad 1 para mostrar "a partir de")
    final precio = WholesalePricingService.resolver(
      producto: p,
      cantidad: 1,
    );

    final precioDetal = p.precioUnidad;
    final precioMayorMostrado = precio.precioUnitario;
    final mostrarPrecioDetalTachado = precio.esMayorista &&
        precioDetal > precioMayorMostrado;

    final cardBackground = isDark
        ? colorSchemeLocal.surfaceContainerHigh.withValues(alpha: 0.6)
        : Colors.white;

    final cardBorderColor = _isHovered
        ? colorSchemeLocal.primary.withValues(alpha: 0.5)
        : colorSchemeLocal.outlineVariant.withValues(alpha: 0.4);

    final cardShadow = _isHovered
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ];

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: sinStock ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorderColor, width: 1.4),
            boxShadow: cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: sinStock ? null : widget.onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Fila superior: imagen + badges ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildImage(p, isMobile),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                p.nombre,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isMobile ? 13 : 14,
                                  fontWeight: FontWeight.w700,
                                  color: colorSchemeLocal.onSurface,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 3),
                              _buildMarca(p, isMobile, colorSchemeLocal),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildTipoBadge(precio.tipo),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // ── Código de barras ──
                    Row(
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 12,
                          color: colorSchemeLocal.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            p.codigoBarras,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              color: colorSchemeLocal.onSurfaceVariant,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // ── Precio ──
                    _buildPrecio(
                      precioMayorMostrado: precioMayorMostrado,
                      precioDetal: precioDetal,
                      mostrarTachado: mostrarPrecioDetalTachado,
                      colorScheme: colorSchemeLocal,
                      isMobile: isMobile,
                    ),

                    const SizedBox(height: 8),

                    // ── Stock ──
                    _buildStock(
                      stock: p.stock,
                      stockMinimo: p.stockMinimo,
                      stockBajo: stockBajo,
                      sinStock: sinStock,
                      colorScheme: colorSchemeLocal,
                      isMobile: isMobile,
                    ),

                    // ── Advertencia sin stock ──
                    if (sinStock) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorSchemeLocal.errorContainer
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Sin stock disponible',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorSchemeLocal.error,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────── Imagen / placeholder ────────────────

  Widget _buildImage(ProductoEntity p, bool isMobile) {
    final size = isMobile ? 48.0 : 56.0;
    final tieneImagen = p.imagenUrl != null && p.imagenUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
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
                errorBuilder: (_, __, ___) => _placeholder(p, size),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _placeholder(p, size);
                },
              )
            : _placeholder(p, size),
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
          fontSize: size * 0.36,
          fontWeight: FontWeight.w800,
          color: AppColors.primaryGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // ──────────────── Marca ────────────────

  Widget _buildMarca(ProductoEntity p, bool isMobile, ColorScheme cs) {
    // Si tiene marcaSupabaseId, busca el nombre real
    if (p.marcaSupabaseId != null && p.marcaSupabaseId!.isNotEmpty) {
      final marcaAsync = ref.watch(
        marcaNombrePorSupabaseIdProvider(p.marcaSupabaseId!),
      );
      return marcaAsync.when(
        data: (nombre) => _marcaText(nombre ?? p.marca, cs, isMobile),
        loading: () => _marcaText(p.marca, cs, isMobile),
        error: (_, __) => _marcaText(p.marca, cs, isMobile),
      );
    }
    return _marcaText(p.marca, cs, isMobile);
  }

  Widget _marcaText(String marca, ColorScheme cs, bool isMobile) {
    if (marca.trim().isEmpty) return const SizedBox.shrink();
    return Text(
      marca,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: isMobile ? 10 : 11,
        fontWeight: FontWeight.w500,
        color: cs.onSurfaceVariant,
      ),
    );
  }

  // ──────────────── Badge de tipo de precio ────────────────

  Widget _buildTipoBadge(PrecioTipo tipo) {
    Color color;
    String label;
    IconData icon;

    switch (tipo) {
      case PrecioTipo.mayor:
        color = AppColors.primaryGreen;
        label = 'MAYOR';
        icon = Icons.workspace_premium_rounded;
      case PrecioTipo.medioMayor:
        color = const Color(0xFF3B82F6);
        label = 'MEDIO';
        icon = Icons.trending_up_rounded;
      case PrecioTipo.detal:
        color = const Color(0xFF64748B);
        label = 'DETAL';
        icon = Icons.local_offer_rounded;
    }

    return StatusBadge(
      label: label,
      color: color,
      icon: icon,
      size: StatusBadgeSize.small,
    );
  }

  // ──────────────── Precio ────────────────

  Widget _buildPrecio({
    required double precioMayorMostrado,
    required double precioDetal,
    required bool mostrarTachado,
    required ColorScheme colorScheme,
    required bool isMobile,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '\$',
              style: TextStyle(
                fontSize: isMobile ? 11 : 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryGreen,
              ),
            ),
            Text(
              precioMayorMostrado.toStringAsFixed(2),
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
                letterSpacing: -0.4,
                height: 1,
              ),
            ),
          ],
        ),
        if (mostrarTachado) ...[
          const SizedBox(height: 2),
          Text(
            'Detal: \$${precioDetal.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              color: colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
              decorationColor: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  // ──────────────── Stock ────────────────

  Widget _buildStock({
    required double stock,
    required double stockMinimo,
    required bool stockBajo,
    required bool sinStock,
    required ColorScheme colorScheme,
    required bool isMobile,
  }) {
    Color color;
    IconData icon;
    String label;

    if (sinStock) {
      color = colorScheme.error;
      icon = Icons.block_rounded;
      label = 'Sin stock';
    } else if (stockBajo) {
      color = const Color(0xFFF59E0B);
      icon = Icons.warning_amber_rounded;
      label = '${stock.toStringAsFixed(stock % 1 == 0 ? 0 : 2)} (bajo)';
    } else {
      color = AppColors.primaryGreen;
      icon = Icons.inventory_2_outlined;
      label = stock.toStringAsFixed(stock % 1 == 0 ? 0 : 2);
    }

    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: isMobile ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}