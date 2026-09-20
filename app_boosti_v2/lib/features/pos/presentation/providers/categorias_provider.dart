// lib/features/pos/presentation/providers/categorias_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/Local/entities/categoria_entity.dart';
import 'isar_provider.dart';
import 'sync_provider.dart';

// ============================================================
// PROVIDERS DE LECTURA
// ============================================================

/// Provider que devuelve SOLO categorías ACTIVAS (para listados generales).
/// ✅ autoDispose: refetchea cuando ningún widget lo escucha y vuelve a
/// montarse, garantizando datos frescos sin invalidación manual.
final categoriasProvider = FutureProvider.autoDispose<List<CategoriaEntity>>(
  (ref) async {
    final isar = ref.watch(isarServiceProvider);
    return await isar.obtenerCategorias(soloActivas: true);
  },
);

/// Provider que devuelve TODAS las categorías (activas e inactivas).
final todasLasCategoriasProvider =
    FutureProvider.autoDispose<List<CategoriaEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerCategorias(soloActivas: false);
});

// ============================================================
// NOTIFIER PRINCIPAL (CRUD)
// ============================================================

final categoriasNotifierProvider =
    StateNotifierProvider<CategoriasNotifier, List<CategoriaEntity>>((ref) {
  return CategoriasNotifier(ref);
});

class CategoriasNotifier extends StateNotifier<List<CategoriaEntity>> {
  final Ref ref;

  CategoriasNotifier(this.ref) : super([]) {
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final isar = ref.read(isarServiceProvider);
    final lista = await isar.obtenerCategorias(soloActivas: true);
    if (!mounted) return;
    state = lista;
    // ✅ Notificar a los FutureProviders para que refetcheen.
    //    Sin esto, los chips y otros listados quedan desincronizados.
    ref.invalidate(categoriasProvider);
    ref.invalidate(todasLasCategoriasProvider);
  }

  // ---------- CRUD ----------
  Future<void> agregarCategoria(String nombre, {String? descripcion}) async {
    final isar = ref.read(isarServiceProvider);
    final nueva = CategoriaEntity(
      supabaseId: const Uuid().v4(),
      nombre: nombre.trim(),
      descripcion: descripcion,
      syncStatus: 'pending',
    );
    await isar.guardarCategoria(nueva);
    await _cargarCategorias();
    await ref.read(syncServiceProvider).sincronizarCategorias();
  }

  Future<void> editarCategoria(
    int id,
    String nuevoNombre, {
    String? nuevaDescripcion,
  }) async {
    final isar = ref.read(isarServiceProvider);
    final categoria = await isar.obtenerCategoriaPorId(id);
    if (categoria != null) {
      categoria.nombre = nuevoNombre.trim();
      if (nuevaDescripcion != null) categoria.descripcion = nuevaDescripcion;
      categoria.updatedAt = DateTime.now();
      categoria.syncStatus = 'pending';
      await isar.guardarCategoria(categoria);
      await _cargarCategorias();
      await ref.read(syncServiceProvider).sincronizarCategorias();
    }
  }

  Future<void> eliminarCategoria(int id) async {
    final isar = ref.read(isarServiceProvider);
    final categoria = await isar.obtenerCategoriaPorId(id);
    if (categoria != null) {
      categoria.activo = false;
      categoria.updatedAt = DateTime.now();
      categoria.syncStatus = 'pending';
      await isar.guardarCategoria(categoria);
      await _cargarCategorias();
      await ref.read(syncServiceProvider).sincronizarCategorias();
    }
  }

  Future<void> reactivarCategoria(int id) async {
  final isar = ref.read(isarServiceProvider);
  final categoria = await isar.obtenerCategoriaPorId(id);
  if (categoria != null) {
    categoria.activo = true;
    categoria.updatedAt = DateTime.now();
    categoria.syncStatus = 'pending';
    await isar.guardarCategoria(categoria);
    await _cargarCategorias();
    await ref.read(syncServiceProvider).sincronizarCategorias();
  }
}

Future<int> purgarCategoriasInactivas() async {
  final isar = ref.read(isarServiceProvider);
  final inactivas = await isar.obtenerCategorias(soloActivas: false);
  final aBorrar = inactivas.where((c) => !c.activo).toList();

  if (aBorrar.isEmpty) return 0;

  for (final cat in aBorrar) {
    await isar.eliminarCategoriaFisica(cat.id);
  }

  await _cargarCategorias();
  return aBorrar.length;
}

  Future<void> refrescar() async {
    await _cargarCategorias();
  }
}