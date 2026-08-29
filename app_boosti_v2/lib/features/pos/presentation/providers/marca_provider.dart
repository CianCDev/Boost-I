import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart'; // ✅ Agregar import

import '../../data/Local/entities/marca_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../services/sync_service.dart';

// ============================================================
// PROVIDERS DE LECTURA
// ============================================================

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
      // ✅ Generar UUID válido para Supabase
      marca.supabaseId ??= const Uuid().v4(); // 🔥 Cambio clave: usar UUID real
      marca.syncStatus = 'pending';
      marca.createdAt = DateTime.now();
      marca.updatedAt = DateTime.now();

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

      final productos = await isar.productoEntitys
          .filter()
          .marcaSupabaseIdEqualTo(marca.supabaseId ?? '')
          .findAll();

      if (productos.isNotEmpty) {
        marca.activo = false;
        marca.syncStatus = 'pending';
        await isar.writeTxn(() async {
          await isar.marcaEntitys.put(marca);
        });
        await cargarMarcas();
        _sincronizarEnSegundoPlano();
        return false;
      } else {
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

  /// Busca marcas por nombre
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

  // ============================================================
  // SINCRONIZACIÓN EN SEGUNDO PLANO
  // ============================================================

  void _sincronizarEnSegundoPlano() {
    Future.microtask(() async {
      try {
        final syncService = ref.read(syncServiceProvider);
        await syncService.sincronizarMarcasPendientes();
        debugPrint('✅ [MarcasNotifier] Sincronización en segundo plano completada.');
      } catch (e) {
        debugPrint('❌ [MarcasNotifier] Error en sincronización en segundo plano: $e');
      }
    });
  }

  /// Fuerza la sincronización completa
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

// ============================================================
// PROVIDER DEL SERVICIO DE SINCRONIZACIÓN
// ============================================================

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});