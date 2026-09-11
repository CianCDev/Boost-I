// lib/features/pos/presentation/providers/marca_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/Local/entities/marca_entity.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/producto_entity.dart';
import '../services/sync_service.dart';

// ============================================================
// PROVIDERS DE LECTURA
// ============================================================

final marcasProvider = FutureProvider<List<MarcaEntity>>((ref) async {
  final isar = IsarService();
  return await isar.obtenerMarcas(soloActivas: true);
});

final todasLasMarcasProvider = FutureProvider<List<MarcaEntity>>((ref) async {
  final isar = IsarService();
  return await isar.obtenerMarcas(soloActivas: false);
});

// ============================================================
// NOTIFIER PRINCIPAL (CRUD + SINCRONIZACIÓN)
// ============================================================

final marcasNotifierProvider = StateNotifierProvider<MarcasNotifier, AsyncValue<List<MarcaEntity>>>(
  (ref) => MarcasNotifier(ref),
);

class MarcasNotifier extends StateNotifier<AsyncValue<List<MarcaEntity>>> {
  final Ref ref;
  final IsarService _isar = IsarService();

  MarcasNotifier(this.ref) : super(const AsyncValue.loading()) {
    cargarMarcas();
  }

  Future<void> cargarMarcas() async {
    state = const AsyncValue.loading();
    try {
      final marcas = await _isar.obtenerMarcas(soloActivas: false);
      state = AsyncValue.data(marcas);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> crearMarca(MarcaEntity marca) async {
    try {
      marca.supabaseId ??= const Uuid().v4();
      marca.syncStatus = 'pending';
      marca.createdAt = DateTime.now();
      marca.updatedAt = DateTime.now();

      await _isar.guardarMarca(marca);
      await cargarMarcas();
      _sincronizarEnSegundoPlano();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> actualizarMarca(MarcaEntity marca) async {
    try {
      marca.updatedAt = DateTime.now();
      marca.syncStatus = 'pending';
      await _isar.guardarMarca(marca);
      await cargarMarcas();
      _sincronizarEnSegundoPlano();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<bool> eliminarMarca(int id) async {
    try {
      final marca = await _isar.obtenerMarcaPorId(id);
      if (marca == null) return false;

      final productos = await _isar.obtenerProductos();
      final tieneProductos = productos.any((p) => p.marcaSupabaseId == marca.supabaseId);

      if (tieneProductos) {
        marca.activo = false;
        marca.syncStatus = 'pending';
        await _isar.guardarMarca(marca);
      } else {
        // En Sembast no hay delete directo, así que usamos un flag o eliminamos el registro manualmente.
        // En nuestro IsarService stub, eliminamos el método, pero podemos simularlo.
        // Para este caso, marcamos como inactivo (o si prefieres, agregar un método en IsarService para eliminar marca)
        // ⚠️ Si no tienes `eliminarMarca` en tu IsarService, usa `guardarMarca` con `activo=false`.
        // Aquí usamos el método `eliminarMarca` que sí existe en el stub.
        await _isar.eliminarMarca(marca.id);
      }

      await cargarMarcas();
      _sincronizarEnSegundoPlano();
      return !tieneProductos;
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return false;
    }
  }

  Future<List<MarcaEntity>> buscarMarcas(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      return await _isar.buscarMarcas(query);
    } catch (e) {
      return [];
    }
  }

  Future<MarcaEntity?> obtenerMarcaPorSupabaseId(String supabaseId) async {
    if (supabaseId.isEmpty) return null;
    try {
      return await _isar.obtenerMarcaPorSupabaseId(supabaseId);
    } catch (e) {
      return null;
    }
  }

  void _sincronizarEnSegundoPlano() {
    Future.microtask(() async {
      try {
        final syncService = ref.read(syncServiceProvider);
        await syncService.sincronizarMarcasPendientes();
      } catch (e) {
        debugPrint('Error en sincronización en segundo plano: $e');
      }
    });
  }

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

// ============================================================
// PROVIDERS AUXILIARES
// ============================================================

final marcaNombrePorIdProvider = FutureProvider.family<String?, int>((ref, marcaId) async {
  if (marcaId <= 0) return null;
  final isar = IsarService();
  final marca = await isar.obtenerMarcaPorId(marcaId);
  return marca?.nombre;
});

final marcaNombrePorSupabaseIdProvider = FutureProvider.family<String?, String>((ref, supabaseId) async {
  if (supabaseId.isEmpty) return null;
  final isar = IsarService();
  final marca = await isar.obtenerMarcaPorSupabaseId(supabaseId);
  return marca?.nombre;
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});