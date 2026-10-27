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
// ⚠️ ESTA ENTIDAD SÍ VIAJA A SUPABASE (desde 2026-10-27)
//
// La receta se empuja con la RPC `guardar_receta()` de
// `supabase/migrations/20261027000001_recetas.sql`, que hace el upsert de la
// fila y el REEMPLAZO COMPLETO de los ingredientes en una sola transacción.
// Se eligió RPC y no 3 llamadas desde el cliente porque un corte entre el
// DELETE y el INSERT dejaría la receta sin ingredientes en la nube, y esa
// versión vacía se propagaría a los demás dispositivos.
//
// ⚠️ El payload NO manda `tenant_id`: lo resuelve `current_tenant_id()` en
// el server. Es la misma lección de los lotes, que se subieron al tenant
// equivocado durante la ventana del hot-switch.
//
// ⚠️ Los borrados NO se sincronizan: `eliminarReceta` existe pero no tiene
// ningún caller (la UI nunca borra, marca `activo = false`). El día que se
// use, hará falta un tombstone: con solo `DELETE` remoto, el pull siguiente
// la resucitaría.
import 'package:isar/isar.dart';

import 'json_utils.dart';

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

  /// Payload de la RPC `guardar_receta(p_receta, p_ingredientes)`.
  ///
  /// ⚠️ NO incluye `tenant_id`: lo pone `current_tenant_id()` en el server.
  /// Mandarlo desde el cliente ya causó que un lote subiera a un tenant y su
  /// movimiento a otro durante la ventana del hot-switch.
  ///
  /// `rindePorciones` se normaliza aquí (0 o negativo → 1) porque es divisor
  /// en el descuento de stock y la columna tiene `CHECK (> 0)`: sin esto, una
  /// receta tocada a mano tumbaría el push entero.
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id_isar': id,
      'producto_id_fk': productoId,
      'nombre_plato': nombrePlato,
      'rinde_porciones': rindePorciones > 0 ? rindePorciones : 1.0,
      'activo': activo,
    };
  }

  /// Ingredientes en el orden en que se capturaron.
  ///
  /// El índice de la lista ES el orden: `RecetaItemEntity` no lleva un campo
  /// `orden` en Isar (el orden del array ya lo dice) y la columna de la nube
  /// existe para que el pull lo reconstruya igual.
  List<Map<String, dynamic>> ingredientesToSupabaseJson() {
    return [
      for (var i = 0; i < items.length; i++)
        items[i].toSupabaseJson(orden: i),
    ];
  }

  /// Reconstruye la receta desde una fila de `recetas` con
  /// `receta_ingredientes(*)` embebido.
  ///
  /// [localIdResuelto] es el id de Isar del local, resuelto por el caller a
  /// partir del `tenant_id` de la fila. Sin él la receta quedaría con
  /// `localId = 0` y sería inalcanzable para `obtenerRecetaPorProducto`.
  factory RecetaEntity.fromSupabase(
    Map<String, dynamic> json, {
    int? localIdResuelto,
  }) {
    final crudos = (json['receta_ingredientes'] as List?) ?? const [];
    final mapas = <Map<String, dynamic>>[];
    for (final crudo in crudos) {
      if (crudo is Map) mapas.add(Map<String, dynamic>.from(crudo));
    }
    // PostgREST no garantiza el orden de las filas embebidas.
    mapas.sort(
      (a, b) => (safeInt(a['orden']) ?? 0).compareTo(safeInt(b['orden']) ?? 0),
    );

    final receta = RecetaEntity()
      ..id = safeInt(json['id_isar']) ?? Isar.autoIncrement
      ..supabaseId = json['id'] as String?
      ..localId = localIdResuelto ?? 0
      ..productoId = safeInt(json['producto_id_fk']) ?? 0
      ..nombrePlato = json['nombre_plato'] as String? ?? ''
      ..rindePorciones = safeDouble(json['rinde_porciones']) ?? 1.0
      ..activo = json['activo'] as bool? ?? true
      ..sincronizado = true
      ..fechaSincronizacion = DateTime.now()
      ..createdAt = _fecha(json['created_at'])
      ..updatedAt = _fecha(json['updated_at'])
      ..items = [for (final mapa in mapas) RecetaItemEntity.fromSupabase(mapa)];

    return receta;
  }

  static DateTime? _fecha(dynamic valor) {
    if (valor is! String || valor.isEmpty) return null;
    return DateTime.tryParse(valor);
  }
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
  /// ⚠️ Se convierte a la unidad del ingrediente al descontar stock
  /// (`ConversionUnidades`, usado por `comanda_provider`). Si las
  /// dimensiones no coinciden (receta en `unidad` y stock en `kg`) se
  /// descuenta 1:1 y se deja un aviso en el log: un plato ya cocinado no se
  /// bloquea por una unidad mal escrita.
  String unidad = 'unidad';

  /// Ingrediente opcional: si falta, se avisa pero NO se bloquea la
  /// entrega (Q3 del usuario: solo avisar, nunca bloquear).
  bool esOpcional = false;

  RecetaItemEntity();

  /// Payload de una fila de `receta_ingredientes`.
  ///
  /// [orden] lo pone `RecetaEntity.ingredientesToSupabaseJson` a partir de la
  /// posición en la lista: en Isar el orden es implícito y en la nube hace
  /// falta una columna para reconstruirlo.
  ///
  /// `ingredienteId` va como `null` si no hay id (> 0). La columna es
  /// nullable a propósito: un ingrediente dado de baja no debe impedir que
  /// la receta viaje, y el nombre queda como snapshot.
  Map<String, dynamic> toSupabaseJson({required int orden}) {
    return {
      'orden': orden,
      'ingrediente_id_fk': ingredienteId > 0 ? ingredienteId : null,
      'ingrediente_nombre': ingredienteNombre,
      'cantidad': cantidad,
      'unidad': unidad,
      'es_opcional': esOpcional,
    };
  }

  /// Reconstruye un ingrediente desde una fila de `receta_ingredientes`.
  factory RecetaItemEntity.fromSupabase(Map<String, dynamic> json) {
    return RecetaItemEntity()
      ..ingredienteId = safeInt(json['ingrediente_id_fk']) ?? 0
      ..ingredienteNombre = json['ingrediente_nombre'] as String? ?? ''
      ..cantidad = safeDouble(json['cantidad']) ?? 0.0
      ..unidad = json['unidad'] as String? ?? 'unidad'
      ..esOpcional = json['es_opcional'] as bool? ?? false;
  }
}
