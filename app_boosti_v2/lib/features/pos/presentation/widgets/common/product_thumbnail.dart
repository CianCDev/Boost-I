// lib/features/pos/presentation/widgets/common/product_thumbnail.dart
import 'package:flutter/material.dart';

/// Miniatura de producto con placeholder cuando no hay imagen.
///
/// Copia el patrón de los 13 `Image.network` del catálogo
/// (`product_card.dart:162-182`, `product_list_tile.dart:104`, …), con dos
/// diferencias deliberadas:
///
///   · Añade `loadingBuilder`. En el resto del repo, mientras carga la
///     imagen se ve un `Container` de fondo vacío, sin señal de que está
///     cargando.
///   · Centraliza el placeholder en un solo widget, para que el KDS y el
///     catálogo muestren exactamente la misma silueta cuando el producto
///     no tiene foto.
///
/// Sin `cached_network_image`: no está en `pubspec.yaml` y R.3.2 no añade
/// dependencias.
class ProductThumbnail extends StatelessWidget {
  /// URL de la imagen. `null` o vacío → placeholder.
  final String? imageUrl;

  /// Lado del cuadrado.
  final double size;

  final BorderRadius? borderRadius;

  /// Fondo del placeholder. Si es `null`, se usa
  /// `colorScheme.surfaceContainerHighest`.
  final Color? placeholderColor;

  /// Ícono del placeholder.
  final IconData placeholderIcon;

  const ProductThumbnail({
    super.key,
    this.imageUrl,
    this.size = 56,
    this.borderRadius,
    this.placeholderColor,
    this.placeholderIcon = Icons.inventory_2_rounded,
  });

  bool get _tieneImagen {
    final url = imageUrl;
    return url != null && url.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final fondo = placeholderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.03)
            : colorScheme.surfaceContainerHighest);

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        child: _tieneImagen
            ? Image.network(
                imageUrl!.trim(),
                width: size,
                height: size,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progreso) {
                  if (progreso == null) return child;
                  return _placeholder(
                    fondo,
                    colorScheme,
                    child: Center(
                      child: SizedBox(
                        width: size * 0.3,
                        height: size * 0.3,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: progreso.expectedTotalBytes != null
                              ? progreso.cumulativeBytesLoaded /
                                  progreso.expectedTotalBytes!
                              : null,
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) =>
                    _placeholder(fondo, colorScheme),
              )
            : _placeholder(fondo, colorScheme),
      ),
    );
  }

  Widget _placeholder(Color fondo, ColorScheme colorScheme, {Widget? child}) {
    return Container(
      color: fondo,
      alignment: Alignment.center,
      child: child ??
          Icon(
            placeholderIcon,
            size: 28,
            color: colorScheme.outline,
          ),
    );
  }
}
