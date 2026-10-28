// lib/features/pos/presentation/providers/sync_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/sync_service.dart';
import 'business_mode_provider.dart';
import 'categorias_provider.dart';
import 'clientes/clientes_provider.dart';
import 'comanda_provider.dart';
import 'dashboard_provider.dart';
import 'departamentos_provider.dart';
import 'locales_provider.dart';
import 'mesas_provider.dart';
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
      // R.1b / R.1c · Salón y comandas. Se refrescan tras cualquier sync o
      // evento realtime para que el otro dispositivo se vea sin recargar.
      _safe(ref, () {
        ref.read(mesasProvider.notifier).cargar();
      });
      _safe(ref, () {
        ref.read(comandasProvider.notifier).cargar();
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
    // 🎯 NUEVO: reacciona a cambios de locales desde otro dispositivo.
    //
    // Solo recarga el modo de negocio del local activo. La UI se
    // reconstruye automáticamente porque `featureFlagsProvider` es
    // derivado y depende de `businessModeProvider`.
    //
    // NO se invalidan catálogo/inventario/lotes porque todavía NO
    // dependen reactivamente de los flags (eso es Fase 2).
    onLocalCambiado: () {
      _safe(ref, () {
        ref.read(businessModeProvider.notifier).recargar();
      });
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