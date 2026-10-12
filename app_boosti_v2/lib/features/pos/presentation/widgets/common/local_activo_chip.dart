import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/local_entity.dart';
import '../../providers/local_actual_provider.dart';
import '../../providers/locales_provider.dart';

/// Dónde se dibuja el chip. El mismo dato necesita dos tratamientos
/// distintos porque el fondo es otro.
enum LocalActivoVariante {
  /// Sobre una superficie de página (tema claro u oscuro).
  superficie,

  /// Dentro de un `CustomAppBar`, cuyo fondo es el gradiente violeta y
  /// por lo tanto el contenido va en blanco.
  appBar,
}

/// Chip informativo del local activo.
///
/// ## No es un guard
/// Muestra DÓNDE se está operando, pero no bloquea nada. Bloquear es
/// trabajo de [GuardTenantActivo]. Si este chip empezara a validar, se
/// mezclan las dos responsabilidades y una de las dos falla.
///
/// ## Tampoco es el hot-switch
/// El cambio de local vive en el side panel
/// (`LocalSelectorDialog.show`) y en la pantalla de Locales. Por eso
/// este widget **no** recibe `onTap`: un control que parece pulsable y
/// no lo es peor que no mostrarlo.
class LocalActivoChip extends ConsumerWidget {
  const LocalActivoChip({
    super.key,
    this.variante = LocalActivoVariante.superficie,
  });

  final LocalActivoVariante variante;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localId = ref.watch(localActualProvider);
    if (localId == null) return const SizedBox.shrink();

    // `localPorIdProvider` es `FutureProvider.family<LocalEntity?, int>`:
    // devuelve null si el id no resuelve, no lanza. Por eso el `data`
    // necesita chequear null además del `when`.
    final localAsync = ref.watch(localPorIdProvider(localId));

    return localAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (local) {
        if (local == null) return const SizedBox.shrink();

        return switch (variante) {
          LocalActivoVariante.superficie => _superficie(context, local),
          LocalActivoVariante.appBar => _enAppBar(local),
        };
      },
    );
  }

  /// Variante sobre superficie: fondo del tema, glifo oscuro.
  Widget _superficie(BuildContext context, LocalEntity local) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Local activo: ${local.nombre}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isDark ? 14 : 12,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: isDark ? 0.35 : 0.40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_rounded, size: 16, color: cs.primary),
            const SizedBox(width: 6),
            // El nombre puede ser largo ("Sucursal Norte - Valencia").
            // `Flexible` + ellipsis: sin él el Row(min) desborda en móvil
            // en vez de recortar.
            Flexible(
              child: Text(
                local.nombre,
                style: TextStyle(
                  color: cs.onPrimaryContainer,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Variante dentro del AppBar violeta: tinte blanco translúcido.
  Widget _enAppBar(LocalEntity local) {
    return Semantics(
      label: 'Local activo: ${local.nombre}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.20),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_rounded, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            // `ConstrainedBox` en vez de `Flexible`: dentro de las
            // `actions` del AppBar el ancho disponible ya está acotado,
            // y sin un tope explícito un nombre largo empuja al título.
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                local.nombre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
