// lib/features/pos/presentation/providers/proveedores_provider.dart
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';

final isarServiceProvider = Provider<IsarService>((ref) => IsarService());

final proveedoresProvider =
    StateNotifierProvider<ProveedoresNotifier, List<ProveedorEntity>>((ref) {
  return ProveedoresNotifier(ref);
});

class ProveedoresNotifier extends StateNotifier<List<ProveedorEntity>> {
  final Ref ref;

  ProveedoresNotifier(this.ref) : super([]) {
    cargarProveedores();
  }

  IsarService get _isar => ref.read(isarServiceProvider);

  Future<void> cargarProveedores() async {
    final todos = await _isar.obtenerProveedores(soloActivos: false);
    if (!mounted) return;
    state = todos;
  }

  Future<void> guardarProveedor(ProveedorEntity proveedor) async {
    await _isar.guardarProveedor(proveedor);
    await cargarProveedores();
  }

  Future<void> desactivarProveedor(int id) async {
    await _isar.desactivarProveedor(id);
    await cargarProveedores();
  }
}

final proveedorPorIdProvider = Provider.family<ProveedorEntity?, int>((ref, id) {
  final todos = ref.watch(proveedoresProvider);
  return todos.firstWhereOrNull((p) => p.id == id);
});

// ✅ Para usar en diálogos que necesitan AsyncValue
final proveedorPorIdAsyncProvider =
    FutureProvider.family<ProveedorEntity?, int>((ref, id) async {
  final isar = ref.read(isarServiceProvider);
  return await isar.obtenerProveedorPorId(id);
});

// ═══════════════════════════════════════════════════════════════════════
// FILTRO
// ═══════════════════════════════════════════════════════════════════════

/// Enum explícito con 3 estados. Antes era `bool mostrarInactivos`.
enum FiltroProveedores { activos, inactivos, todos }

final proveedoresConFiltroProvider = FutureProvider.family<
    List<ProveedorEntity>,
    ({
      String query,
      FiltroProveedores filtro,
      String? categoria, // ← ✅ CAMBIO: de int? productoId a String? categoria
    })>((ref, params) async {
  final todos = ref.watch(proveedoresProvider);

  var resultado = todos.where((p) {
    switch (params.filtro) {
      case FiltroProveedores.activos:
        return p.activo;
      case FiltroProveedores.inactivos:
        return !p.activo;
      case FiltroProveedores.todos:
        return true;
    }
  }).toList();

  if (params.query.isNotEmpty) {
    final q = params.query.toLowerCase();
    resultado = resultado.where((p) {
      final coincideNombre = p.nombre.toLowerCase().contains(q);
      final coincideEmpresa = (p.empresa ?? '').toLowerCase().contains(q);
      final coincideRif = (p.rif ?? '').toLowerCase().contains(q);
      return coincideNombre || coincideEmpresa || coincideRif;
    }).toList();
  }

  // ✅ NUEVO: filtro por categoría. Devuelve proveedores que tengan
  //    al menos un producto de esa categoría.
  if (params.categoria != null && params.categoria!.isNotEmpty) {
    final isar = ref.read(isarServiceProvider);
    final productos = await isar.obtenerProductos();
    final proveedoresIdsConCategoria = productos
        .where(
          (p) =>
              p.categoria == params.categoria && p.proveedorId != null,
        )
        .map((p) => p.proveedorId!)
        .toSet();
    resultado = resultado
        .where((p) => proveedoresIdsConCategoria.contains(p.id))
        .toList();
  }

  return resultado;
});

final productosPorProveedorProvider =
    FutureProvider.family<List<ProductoEntity>, int>((ref, proveedorId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerProductosPorProveedor(proveedorId);
});

// ═══════════════════════════════════════════════════════════════════════
// CATEGORÍAS DISPONIBLES
// ═══════════════════════════════════════════════════════════════════════

/// Devuelve las categorías únicas presentes en los productos, ordenadas
/// alfabéticamente. Se usa en el dropdown de filtros de la pantalla.
final categoriasDisponiblesProvider = FutureProvider<List<String>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  final productos = await isar.obtenerProductos();
  final set = <String>{};
  for (final p in productos) {
    if (p.categoria.isNotEmpty) set.add(p.categoria);
  }
  final lista = set.toList()..sort();
  return lista;
});