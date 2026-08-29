import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../../data/Local/entities/marca_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import 'pedidos_provider.dart';

/// Provider para leer marcas activas (solo lectura)
final marcasProvider = FutureProvider<List<MarcaEntity>>((ref) async {
  final isar = await IsarService().db;
  return await isar.marcaEntitys
      .where()
      .filter()
      .activoEqualTo(true)
      .findAll();
});

/// Provider para obtener TODAS las marcas (activas + inactivas)
final todasLasMarcasProvider = FutureProvider<List<MarcaEntity>>((ref) async {
  final isar = await IsarService().db;
  return await isar.marcaEntitys.where().findAll();
});

/// Notifier para gestionar marcas (CRUD + sincronización)
final marcasNotifierProvider =
    StateNotifierProvider<MarcasNotifier, AsyncValue<List<MarcaEntity>>>(
  (ref) => MarcasNotifier(ref),
);

class MarcasNotifier extends StateNotifier<AsyncValue<List<MarcaEntity>>> {
  final Ref ref;

  MarcasNotifier(this.ref) : super(const AsyncValue.loading()) {
    cargarMarcas();
  }

  /// Carga todas las marcas desde Isar
  Future<void> cargarMarcas() async {
    state = const AsyncValue.loading();
    try {
      final isar = await IsarService().db;
      final marcas = await isar.marcaEntitys.where().findAll();
      state = AsyncValue.data(marcas);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Crea una nueva marca localmente y la marca para sincronizar
  Future<void> crearMarca(MarcaEntity marca) async {
    try {
      final isar = await IsarService().db;
      // Si no tiene supabaseId, generamos uno temporal
      marca.supabaseId ??= DateTime.now().millisecondsSinceEpoch.toString();
      marca.syncStatus = 'pending';
      marca.createdAt = DateTime.now();
      marca.updatedAt = DateTime.now();

      await isar.writeTxn(() async {
        await isar.marcaEntitys.put(marca);
      });

      // Recargar lista
      await cargarMarcas();

      // Sincronizar con Supabase en segundo plano
      _sincronizarEnSegundoPlano();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  /// Actualiza una marca existente
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

  /// Desactiva o elimina una marca (según tenga productos asociados)
  Future<bool> eliminarMarca(int id) async {
    try {
      final isar = await IsarService().db;
      final marca = await isar.marcaEntitys.get(id);
      if (marca == null) return false;

      // Verificar si tiene productos asociados
      final productos = await isar.productoEntitys
          .filter()
          .marcaSupabaseIdEqualTo(marca.supabaseId ?? '')
          .findAll();

      if (productos.isNotEmpty) {
        // Tiene productos → solo desactivar
        marca.activo = false;
        marca.syncStatus = 'pending';
        await isar.writeTxn(() async {
          await isar.marcaEntitys.put(marca);
        });
        await cargarMarcas();
        _sincronizarEnSegundoPlano();
        return false; // no se eliminó, solo desactivó
      } else {
        // No tiene productos → eliminar físicamente
        await isar.writeTxn(() async {
          await isar.marcaEntitys.delete(id);
        });
        await cargarMarcas();
        _sincronizarEnSegundoPlano();
        return true;
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  /// Busca marcas por nombre (para autocomplete en formularios)
  Future<List<MarcaEntity>> buscarMarcas(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final isar = await IsarService().db;
      final q = query.trim().toLowerCase();
      return await isar.marcaEntitys
          .filter()
          .nombreContains(q, caseSensitive: false)
          .findAll();
    } catch (e) {
      return [];
    }
  }

  /// Obtiene una marca por su UUID de Supabase
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

  /// Sincroniza marcas pendientes con Supabase (en segundo plano)
  void _sincronizarEnSegundoPlano() {
    Future.microtask(() async {
      try {
        final syncService = ref.read(syncServiceProvider);
        await syncService.sincronizarMarcasPendientes();
      } catch (e) {
        // Silenciar errores en segundo plano
      }
    });
  }

  /// Fuerza la sincronización completa (subir + descargar)
  Future<void> sincronizarCompleto() async {
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.descargarMarcasDesdeSupabase();
      await syncService.sincronizarMarcasPendientes();
      await cargarMarcas();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

/// Provider de solo lectura para obtener el nombre de una marca por su ID
final marcaNombrePorIdProvider = FutureProvider.family<String?, int>(
  (ref, marcaId) async {
    if (marcaId <= 0) return null;
    final isar = await IsarService().db;
    final marca = await isar.marcaEntitys.get(marcaId);
    return marca?.nombre;
  },
);

/// Provider de solo lectura para obtener el nombre de una marca por su UUID
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