import 'package:isar/isar.dart';

part 'departamento_entity.g.dart';

@Collection()
class DepartamentoEntity {
  Id id = Isar.autoIncrement;
  String? supabaseId;

  String nombre = '';
  String? descripcion;
  int? localId; // ID del local asociado (opcional)

  // ✅ NUEVO: ID del usuario encargado (opcional)
  int? usuarioId;

  /// R.3.2 · Orden de aparición en el selector de estaciones del KDS y en
  /// cualquier lista de departamentos.
  ///
  /// Antes los departamentos se ordenaban como salieran de Isar (que es
  /// orden de inserción, no de intención). Con el KDS eso no basta: el
  /// cocinero quiere ver Cocina, Barra y Postres siempre en ese orden.
  ///
  /// Default 0 = "sin opinionar", que deja a los departamentos antiguos
  /// (creados antes de R.3.2) agrupados al principio en vez de repartidos
  /// de forma arbitraria. El seed de R.3.2 asigna 0/1/2.
  ///
  /// ⚠️ `IsarService.obtenerDepartamentos()` NO ordena por este campo: el
  /// orden se aplica en el provider/pantalla. Si algum día quieres
  /// ordenarlo en la query, necesita `@Index()`.
  int orden = 0;

  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  DateTime? createdAt;
  DateTime? updatedAt;

  DepartamentoEntity();
}