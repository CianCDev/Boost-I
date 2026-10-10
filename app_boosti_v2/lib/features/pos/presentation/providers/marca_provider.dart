// lib/features/pos/presentation/providers/marca_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../data/Local/entities/marca_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../services/sync_service.dart';

// ============================================================
// HELPERS DE FILTRADO (en Dart, no en Isar)
// ============================================================
//
// 🎯 FIX: `syncStatusNotEqualTo` no está disponible como filter
//    clause en el QueryBuilder generado por Isar (probablemente
//    porque `syncStatus` no está @Index()). En vez de pelear con
//    la API de queries, cargamos todo y filtramos en memoria.
//    Para una tabla de marcas esto es trivial en performance.

bool _esVisibleEnUI(MarcaEntity m) => m.syncStatus != 'deleted';

bool _esActivaYVisible(MarcaEntity m) =>
    m.activo && m.syncStatus != 'deleted';

// ============================================================
// PROVIDERS DE LECTURA (reactivos a cambios de Isar)
// ============================================================

/// Marcas activas — reactivo a cambios de Isar.
///
/// 🎯 FIX Bug "marcas no aparecen en el form":
///   - Antes era `FutureProvider`, que cachea para siempre.
///   - Ahora `StreamProvider` + `.watch()` refresca el dropdown
///     automáticamente cuando Isar cambia.
final marcasProvider = StreamProvider<List<MarcaEntity>>((ref) async* {
  final isar = await IsarService().db;
  yield* isar.marcaEntitys
      .where()
      .watch(fireImmediately: true)
      .map((marcas) => marcas.where(_esActivaYVisible).toList());
});

/// TODAS las marcas (activas + inactivas) — reactivo a cambios de Isar.
final todasLasMarcasProvider = StreamProvider<List<MarcaEntity>>((ref) async* {
  final isar = await IsarService().db;
  yield* isar.marcaEntitys
      .where()
      .watch(fireImmediately: true)
      .map((marcas) => marcas.where(_esVisibleEnUI).toList());
});

// ============================================================
// NOTIFIER PRINCIPAL (CRUD + SINCRONIZACIÓN)
// ============================================================

final marcasNotifierProvider =
    StateNotifierProvider<MarcasNotifier, AsyncValue<List<MarcaEntity>>>(
  (ref) => MarcasNotifier(ref),
);

class MarcasNotifier extends StateNotifier<AsyncValue<List<MarcaEntity>>> {
  final Ref ref;

  MarcasNotifier(this.ref) : super(const AsyncValue.loading()) {
    cargarMarcas();
  }

  Future<void> cargarMarcas() async {
    state = const AsyncValue.loading();
    try {
      final isar = await IsarService().db;
      final marcas = await isar.marcaEntitys.where().findAll();
      state = AsyncValue.data(
        marcas.where(_esVisibleEnUI).toList(),
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> crearMarca(MarcaEntity marca) async {
    try {
      final isar = await IsarService().db;
      final now = DateTime.now();

      marca.supabaseId ??= const Uuid().v4();
      marca.syncStatus = 'pending';
      marca.createdAt = now;
      marca.updatedAt = now;

      await isar.writeTxn(() async {
        await isar.marcaEntitys.put(marca);
      });

      await cargarMarcas();
      _sincronizarEnSegundoPlano();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> actualizarMarca(MarcaEntity marca) async {
    try {
      final isar = await IsarService().db;
      marca.updatedAt = DateTime.now();
      marca.syncStatus = 'pending';

      await isar.writeTxn(() async {
        await isar.marcaEntitys.put(marca);
      });

      await cargarMarcas();
      _sincronizarEnSegundoPlano();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Desactiva o marca para eliminación lógica.
  Future<bool> eliminarMarca(int id) async {
    try {
      final isar = await IsarService().db;
      final marca = await isar.marcaEntitys.get(id);
      if (marca == null) return false;

      final productos = await isar.productoEntitys
          .filter()
          .marcaSupabaseIdEqualTo(marca.supabaseId ?? '')
          .findAll();

      if (productos.isNotEmpty) {
        // Soft delete porque tiene productos asociados.
        marca.activo = false;
        marca.syncStatus = 'pending';
        marca.updatedAt = DateTime.now();

        await isar.writeTxn(() async {
          await isar.marcaEntitys.put(marca);
        });

        await cargarMarcas();
        _sincronizarEnSegundoPlano();
        return false; // Desactivada, no eliminada
      } else {
        // 🛠️ MODO OFFLINE: si nunca subió, borramos físicamente.
        // Si ya subió, marcamos `deleted` para que SyncService haga DELETE.
        final nuncaSubio = marca.syncStatus == 'pending' &&
            (marca.supabaseId == null || marca.supabaseId!.isEmpty);

        if (nuncaSubio) {
          await isar.writeTxn(() async {
            await isar.marcaEntitys.delete(id);
          });
        } else {
          marca.activo = false;
          marca.syncStatus = 'deleted';
          marca.updatedAt = DateTime.now();
          await isar.writeTxn(() async {
            await isar.marcaEntitys.put(marca);
          });
        }

        await cargarMarcas();
        _sincronizarEnSegundoPlano();
        return true;
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<List<MarcaEntity>> buscarMarcas(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final isar = await IsarService().db;
      final q = query.trim().toLowerCase();
      // 🎯 FIX: filtramos en Dart para evitar problemas con
      //    filter clauses generados por Isar.
      final marcas = await isar.marcaEntitys.where().findAll();
      return marcas
          .where((m) =>
              _esVisibleEnUI(m) &&
              (m.nombre.toLowerCase().contains(q) ||
                  (m.descripcion ?? '').toLowerCase().contains(q)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<MarcaEntity?> obtenerMarcaPorSupabaseId(String supabaseId) async {
    if (supabaseId.isEmpty) return null;
    try {
      final isar = await IsarService().db;
      return await isar.marcaEntitys
          .filter()
          .supabaseIdEqualTo(supabaseId)
          .findFirst();
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // SINCRONIZACIÓN EN SEGUNDO PLANO
  // ============================================================

  void _sincronizarEnSegundoPlano() {
    Future.microtask(() async {
      try {
        final syncService = ref.read(syncServiceProvider);
        await syncService.sincronizarMarcasPendientes();
        debugPrint(
            '✅ [MarcasNotifier] Sincronización en segundo plano completada.');
      } catch (e) {
        debugPrint(
            '❌ [MarcasNotifier] Error en sincronización en segundo plano: $e');
      }
    });
  }

  Future<void> sincronizarCompleto() async {
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.descargarMarcasDesdeSupabase();
      await syncService.sincronizarMarcasPendientes();
      await cargarMarcas();
      debugPrint('✅ [MarcasNotifier] Sincronización completa finalizada.');
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      debugPrint('❌ [MarcasNotifier] Error en sincronización completa: $e');
    }
  }
}

// ============================================================
// PROVIDERS AUXILIARES
// ============================================================

final marcaNombrePorIdProvider = FutureProvider.family<String?, int>(
  (ref, marcaId) async {
    if (marcaId <= 0) return null;
    final isar = await IsarService().db;
    final marca = await isar.marcaEntitys.get(marcaId);
    return marca?.nombre;
  },
);

final marcaNombrePorSupabaseIdProvider = FutureProvider.family<String?, String>(
  (ref, supabaseId) async {
    if (supabaseId.isEmpty) return null;
    final isar = await IsarService().db;
    final marca = await isar.marcaEntitys
        .filter()
        .supabaseIdEqualTo(supabaseId)
        .findFirst();
    return marca?.nombre;
  },
);

/// `supabaseId` de marca → nombre, en UN solo read.
///
/// ## Por qué existe
/// `ProductCard` usaba `marcaNombrePorSupabaseIdProvider(...)`, un
/// `FutureProvider.family` que hace **una query a Isar por card**. Con 200
/// productos en la grilla eso son 200 providers, 200 round-trips y 200
/// transiciones `loading → data`, o sea ~400 rebuilds de la card solo por
/// el nombre de la marca, en cada apertura del catálogo.
///
/// Acá se lee la colección **una vez** y se indexa en memoria. La card
/// hace un lookup O(1) y no produce transiciones de estado.
///
/// Se apoya en `marcasProvider` (un `StreamProvider` sobre la colección)
/// para re-emitir solo cuando las marcas cambian de verdad, en vez de
/// consultar Isar en cada rebuild del catálogo.
final marcaNombresPorSupabaseIdProvider =
    FutureProvider<Map<String, String>>((ref) async {
  // `watch`: si cambia la colección de marcas, este provider se rehace.
  final marcasAsync = ref.watch(marcasProvider);
  final marcas = marcasAsync.valueOrNull ?? const <MarcaEntity>[];

  final mapa = <String, String>{};
  for (final m in marcas) {
    final sb = m.supabaseId;
    if (sb != null && sb.isNotEmpty) {
      mapa[sb] = m.nombre;
    }
  }
  return mapa;
});

// ============================================================
// PROVIDER DEL SERVICIO DE SINCRONIZACIÓN
// ============================================================

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});