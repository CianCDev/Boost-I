import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/local_actual_provider.dart';
import '../../providers/locales_provider.dart';

/// Chip compacto que muestra el local activo. Tocar abre el selector.
///
/// No bloquea acciones: es informativo + acceso rápido al hot-switch.
/// Va en el Menú POS, entre el banner de turno y la primera sección.
///
/// ⚠️ NO es un guard. Muestra DÓNDE estás, pero no impide cobrar,
/// crear pedido o activar lote sobre otro local. Eso es trabajo de
/// [GuardTenantActivo], que sí bloquea. Si este chip empieza a validar,
/// se mezclan las dos responsabilidades y uno de los dos falla.
class LocalActivoChip extends ConsumerWidget {
  const LocalActivoChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localId = ref.watch(localActualProvider);
    if (localId == null) return const SizedBox.shrink();

    // `localPorIdProvider` es `FutureProvider.family<LocalEntity?, int>`:
    // devuelve null si el id no resuelve, no lanza. Por eso el `data`
    // necesita el chequeo de null además del `when`.
    final localAsync = ref.watch(localPorIdProvider(localId));

    return localAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (local) {
        if (local == null) return const SizedBox.shrink();

        final cs = Theme.of(context).colorScheme;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Semantics(
          button: true,
          label: 'Local activo: ${local.nombre}. Tocar para cambiar.',
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
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
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 6),
                    // El nombre puede ser largo ("Sucursal Norte - Valencia").
                    // `Flexible` + ellipsis: sin él el Row(min) desborda en
                    // móvil en vez de recortar.
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
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more_rounded,
                      size: 16,
                      color: cs.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
