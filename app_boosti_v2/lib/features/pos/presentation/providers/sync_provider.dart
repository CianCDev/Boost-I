// lib/features/pos/presentation/providers/sync_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';
import 'categorias_provider.dart';
import 'clientes/clientes_provider.dart';
import 'dashboard_provider.dart';
import 'departamentos_provider.dart';
import 'locales_provider.dart';
import 'productos_provider.dart';
import 'proveedores_provider.dart';

// ⚠️ NO importamos usuario_provider: invalidarlo desloguea al usuario.

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    onDataChanged: () {
      // ════════════════════════════════════════════════════════════
      // 1. FUTURE PROVIDERS → invalidar refetchea limpio
      // ════════════════════════════════════════════════════════════
      ref.invalidate(categoriasProvider);
      ref.invalidate(todasLasCategoriasProvider);
      ref.invalidate(dashboardProvider);
      ref.invalidate(proveedoresConFiltroProvider);
      ref.invalidate(clientesFrecuentesProvider);
      ref.invalidate(localesProvider);
      ref.invalidate(departamentosProvider);

      // ════════════════════════════════════════════════════════════
      // 2. STATE NOTIFIERS → llamar a su método de refresco, NO invalidar
      //    (invalidate destruye el notifier y pierde estado interno)
      // ════════════════════════════════════════════════════════════
      _safe(ref, () {
        ref.read(categoriasNotifierProvider.notifier).refrescar();
      });
      _safe(ref, () {
        ref.read(productosProvider.notifier).cargarProductos();
      });
      _safe(ref, () {
        ref.read(clientesProvider.notifier).cargarClientes();
      });
      // Si tu MarcasNotifier tiene un método de recarga, añádelo aquí:
      // _safe(ref, () {
      //   ref.read(marcasNotifierProvider.notifier).cargarMarcas();
      // });

      // ════════════════════════════════════════════════════════════
      // 3. ❌ NO TOCAR:
      //    - usuariosProvider → desloguea al usuario
      //    - catalogProvider / inventoryProvider → pierden filtros activos.
      //      Se auto-actualizan porque observan productosProvider.
      //    - localActualProvider → apunta al local activo, se pierde
      // ════════════════════════════════════════════════════════════
    },
  );
});

/// Ejecuta una acción ignorando errores si el provider no está inicializado.
/// Evita crashes cuando algún provider aún no fue `watch`eado por la UI.
void _safe(Ref ref, void Function() action) {
  try {
    action();
  } catch (_) {
    // Provider no montado aún → se salta silenciosamente.
  }
}