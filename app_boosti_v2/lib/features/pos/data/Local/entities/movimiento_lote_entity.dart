// lib/features/pos/data/Local/entities/movimiento_lote_entity.dart
import 'package:isar/isar.dart';
import 'json_utils.dart';

part 'movimiento_lote_entity.g.dart';

@Collection()
class MovimientoLoteEntity {
  Id id = Isar.autoIncrement;

  @Index()
  int loteId = 0;

  /// 'activacion', 'venta', 'baja', 'devolucion'.
  ///
  /// 'traspaso' sigue existiendo por los movimientos historicos escritos
  /// con ese valor. Renombrado a 'baja' porque la operacion saca
  /// unidades del lote; 'traspaso' sugeria un traslado entre lotes que
  /// nunca ocurrio. Los 3 switches de historial mapean ambos.
  String tipo = '';

  double cantidad = 0.0;

  @Index()
  DateTime fecha = DateTime.now();

  int usuarioId = 0;

  String? observaciones;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  /// Stock del producto ANTES del ajuste. `null` si el movimiento no viene
  /// de un ajuste de stock (activacion, recepcion, baja, venta).
  ///
  /// Nullable a proposito: los movimientos ya escritos quedan con `null` en
  /// vez de un 0 que pareceria un stock real de cero.
  ///
  /// [toSupabaseJson] todavia NO lo emite: la columna remota depende de la
  /// migracion U23. Serializarlo antes de que la columna exista haria fallar
  /// el insert de todo el sync de movimientos.
  double? stockAntes;

  /// Stock del producto DESPUES del ajuste.
  ///
  /// Es el stock TOTAL del producto, no el del lote: el ajuste se reparte
  /// entre varios lotes y ninguno los representa por si solo.
  double? stockDespues;

  MovimientoLoteEntity();

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id_isar': id,
      'lote_id_isar': loteId,
      'tipo': tipo,
      'cantidad': cantidad,
      // `toUtc()` y no `toIso8601String()` a secas: el DateTime de Isar
      // viene en hora local y el string salia con offset. Los dos lados
      // tienen que leer el mismo instante.
      'fecha': fecha.toUtc().toIso8601String(),
      'usuario_id': usuarioId,
      'observaciones': observaciones,
      'stock_antes': stockAntes,
      'stock_despues': stockDespues,
      'sincronizado': sincronizado,
      'fecha_sincronizacion': fechaSincronizacion?.toUtc().toIso8601String(),
      // `tenant_id` NO se manda: lo llena el default
      // `current_tenant_id()` del server (migracion 20261010000002).
      // Mandarlo desde el cliente mandaria el tenant equivocado si el
      // usuario hot-cambia de local a mitad del sync.
    };
  }

  factory MovimientoLoteEntity.fromSupabase(Map<String, dynamic> json) {
    return MovimientoLoteEntity()
      ..id = safeInt(json['id_isar']) ?? Isar.autoIncrement
      ..loteId = safeInt(json['lote_id_isar']) ?? 0
      ..tipo = json['tipo'] as String? ?? ''
      ..cantidad = (json['cantidad'] as num?)?.toDouble() ?? 0.0
      ..stockAntes = (json['stock_antes'] as num?)?.toDouble()
      ..stockDespues = (json['stock_despues'] as num?)?.toDouble()
      ..fecha = json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now()
      ..usuarioId = safeInt(json['usuario_id']) ?? 0
      ..observaciones = json['observaciones'] as String?
      ..sincronizado = json['sincronizado'] as bool? ?? false
      ..fechaSincronizacion = json['fecha_sincronizacion'] != null
          ? DateTime.parse(json['fecha_sincronizacion'] as String)
          : null;
  }
}
