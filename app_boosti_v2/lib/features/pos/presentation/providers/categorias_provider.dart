import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/categoria_entity.dart';
import '../../data/Local/entities/isar_service.dart';

import 'package:uuid/uuid.dart';

import 'pedidos_provider.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

/// Provider que devuelve SOLO categorías ACTIVAS (para listados generales)
final categoriasProvider = FutureProvider<List<CategoriaEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerCategorias(soloActivas: true);
});

/// 🔥 NUEVO: Provider que devuelve TODAS las categorías (activas e inactivas)
/// Útil para formularios donde se necesita mostrar la categoría actual del producto,
/// incluso si está inactiva.
final todasLasCategoriasProvider = FutureProvider<List<CategoriaEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerCategorias(soloActivas: false);
});

final categoriasNotifierProvider = StateNotifierProvider<CategoriasNotifier, List<CategoriaEntity>>((ref) {
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
    state = lista;
  }

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

  Future<void> editarCategoria(int id, String nuevoNombre, {String? nuevaDescripcion}) async {
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

  Future<void> refrescar() async {
    await _cargarCategorias();
  }
}