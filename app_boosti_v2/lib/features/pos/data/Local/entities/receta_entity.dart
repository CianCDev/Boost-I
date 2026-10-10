// lib/features/pos/data/Local/entities/receta_entity.dart
//
// R.4 · G.1 · Modelo de recetas (descomposición de platos).
//
// ⚠️ POR QUÉ `productoId` NO LLEVA `@Index(unique: true)`
//
// El plan original sí lo pedía, pero `productoId` es un id LOCAL de Isar,
// autoincremental POR BASE. Con multi-local, dos sucursales distintas
// pueden tener productos con el mismo id numérico: el producto 7 del local
// A y el producto 7 del local B son cosas distintas. Un índice único sobre
// `productoId` solo haría que el local B no pudiera tener receta del
// producto 7 si el local A ya la tenía.
//
// Por eso `productoId` lleva `@Index()` a secas (para filtrar rápido) y la
// unicidad REAL es `(localId, productoId)`, que se aplica en Dart dentro de
// `IsarService.obtenerRecetaPorProducto`. Isar 3 no compone índices.
//
// ⚠️ ESTA ENTIDAD NO VIAJA A SUPABASE TODAVÍA
//
// Los campos `supabaseId` / `sincronizado` / `fechaSincronizacion` están
// por convención A, pero `sync_service` NO empuja recetas todavía. Cuando
// se haga, hará falta la tabla `recetas` + `receta_ingredientes` en
// Supabase, y este archivo ganará un `toSupabaseJson` / `fromSupabase`
// como los de `LoteEntity`. Marcado en `docs/TODO.md`.
import 'package:isar/isar.dart';

part 'receta_entity.g.dart';

@Collection()
class RecetaEntity {
  Id id = Isar.autoIncrement;

  // ── Sync (convención A) ──
  String? supabaseId;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  // ── Local ──
  @Index()
  int localId = 0;

  String? localSupabaseId;

  // ── Identidad ──
  //
  // ⚠️ SIN `unique`: ver la nota de cabecera. La unicidad real es
  // `(localId, productoId)` y se aplica en `isar_service.dart`.
  @Index()
  int productoId = 0;

  /// Nombre del plato (snapshot) para poder listar recetas sin hacer un
  /// JOIN con `ProductoEntity` por cada fila.
  ///
  /// Es un snapshot, no una relación: si el plato se renombra, la receta
  /// sigue enseñando el nombre viejo hasta que se reescriba. Para G.2 es
  /// lo comodo (una lista sin N queries); si alguna vez molesta, se
  /// refresca al guardar la receta.
  String nombrePlato = '';

  /// Cuántas unidades del plato rinde esta receta.
  ///
  /// `1.0` (lo habitual): 1 de cada ingrediente por 1 plato.
  /// `10.0`: la receta es de un lote de 10 y `cantidad` de cada
  /// ingrediente es por PORCIÓN, no por lote. Es lo que permite que "1
  /// porción de arroz" y "1 lote de arroz" compartan la misma fila.
  double rindePorciones = 1.0;

  /// Receta desactivada: se conserva pero no se usa al entregar.
  bool activo = true;

  /// Ingredientes embebidos.
  ///
  /// `@embedded` como `CartSessionItem.items`: mutar uno exige releer la
  /// receta entera y hacer `put()` en un `writeTxn`.
  List<RecetaItemEntity> items = [];

  // ── Auditoría ──
  DateTime? createdAt;
  DateTime? updatedAt;

  RecetaEntity();

  /// Total de ingredientes no opcionales.
  ///
  /// Sirve para la UI de G.2 ("3 ingredientes, 1 opcional") y para decidir
  /// rápido si una receta está vacía.
  @ignore
  int get ingredientesObligatorios =>
      items.where((i) => !i.esOpcional).length;

  /// `true` si no hay NADA que descontar del inventario.
  ///
  /// Una receta vacía o solo con opcionales se considera vacía: al
  /// entregar un plato así no tiene sentido tocar el stock.
  @ignore
  bool get vacia => ingredientesObligatorios == 0;
}

/// Un ingrediente dentro de una receta.
///
/// ⚠️ Es `@embedded`, NO una colección propia: no tiene id propio ni se
/// consulta por separado. La razón es que siempre se lee y escribe como
/// parte de su receta, igual que `CartSessionItem`.
@embedded
class RecetaItemEntity {
  /// Id local de Isar del `ProductoEntity` que actúa como ingrediente.
  ///
  /// ⚠️ Es un id LOCAL, no el UUID de Supabase. `RecetaEntity.productoId`
  /// y este campo comparten ese requisito, y por eso `productoId` NO
  /// lleva `@Index(unique: true)`: dos sucursales pueden tener el producto
  /// 7 con recetas distintas.
  int ingredienteId = 0;

  /// Snapshot del nombre, para pintar la receta sin JOIN.
  String ingredienteNombre = '';

  /// Cantidad por PORCIÓN del plato (ver [RecetaEntity.rindePorciones]).
  ///
  /// Con `rindePorciones = 1.0` es la cantidad por plato.
  double cantidad = 0.0;

  /// Unidad de medida: `'kg'`, `'g'`, `'lt'`, `'ml'`, `'unidad'`.
  ///
  /// ⚠️ `String` libre a propósito (misma decisión que
  /// `DetalleVentaEntity.unidadEmpaque`): meter un enum obligaría a una
  /// migración cuando aparezca una unidad nueva, y el dato es de solo
  /// lectura en pantalla.
  ///
  /// ⚠️ El descuento de stock de G.3 necesita convertir esta cantidad a la
  /// unidad del `ProductoEntity`. Como ese campo no existe todavía, de
  /// momento se asume 1:1. Ver `docs/TODO.md`.
  String unidad = 'unidad';

  /// Ingrediente opcional: si falta, se avisa pero NO se bloquea la
  /// entrega (Q3 del usuario: solo avisar, nunca bloquear).
  bool esOpcional = false;

  RecetaItemEntity();
}
