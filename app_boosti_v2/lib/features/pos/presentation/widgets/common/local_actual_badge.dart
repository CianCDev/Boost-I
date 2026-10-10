// lib/features/pos/presentation/widgets/common/local_actual_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/locales_provider.dart';
import '../../providers/local_actual_provider.dart';

/// Badge de SOLO LECTURA con el nombre del local actual.
///
/// ## Para qué
/// Las pantallas de Pedidos, Lotes, Proveedores y Departamentos operan
/// siempre sobre el local activo. Antes, `PedidosProveedorScreen` tenía su
/// propio `PopupMenuButton` para cambiar de local, duplicando el
/// `setLocalActual` canónico y pudiendo desincronizarse de él: el diálogo
/// de crear pedido usaba `localActualProvider` mientras la lista usaba el
/// `_localDestinoUuid` de la pantalla, así que podían filtrar por locales
/// distintos.
///
/// Ahora el cambio de local vive únicamente en la pantalla de Locales y en
/// `local_selector_dialog.dart`. Estas pantallas solo **muestran** en qué
/// local están, para que el usuario no tenga que abrir el menú para
/// averiguarlo.
///
/// ## Deliberadamente NO es pulsable
/// Un badge con `onTap` invitaría a cambiar de local desde acá, que es
/// justo lo que se pidió eliminar. Para cambiar hay que ir a Locales.
class LocalActualBadge extends ConsumerWidget {
  /// Compacidad del badge. `compact` aprieta el padding, útil en AppBars
  /// con muchas acciones.
  final bool compact;

  const LocalActualBadge({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localId = ref.watch(localActualProvider);

    if (localId == null) {
      return _contenedor(
        isDark: isDark,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront_rounded,
                size: 14, color: Colors.white.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(
              'Local…',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    final localAsync = ref.watch(localPorIdProvider(localId));

    return localAsync.maybeWhen(
      data: (local) => _contenedor(
        isDark: isDark,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storefront_rounded,
                size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            ConstrainedBox(
              // El nombre de un local puede ser largo y la AppBar no
              // puede desbordar. Se recorta en lugar de romper el layout.
              constraints: const BoxConstraints(maxWidth: 110),
              child: Text(
                local?.nombre ?? 'Local',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      orElse: () => _contenedor(
        isDark: isDark,
        child: const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _contenedor({required bool isDark, required Widget child}) {
    return Tooltip(
      message: 'Local actual (se cambia desde Locales)',
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: compact ? 2 : 4),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: isDark ? 0.10 : 0.18),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.20),
            width: 1,
          ),
        ),
        child: child,
      ),
    );
  }
}
