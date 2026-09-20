// lib/features/pos/data/Local/entities/movimiento_lote_entity.dart
import 'package:isar/isar.dart';
import 'json_utils.dart';

part 'movimiento_lote_entity.g.dart';

@Collection()
class MovimientoLoteEntity {
  Id id = Isar.autoIncrement;

  @Index()
  int loteId = 0;

  String tipo = ''; // 'activacion', 'venta', 'traspaso', 'devolucion'

  double cantidad = 0.0;

  @Index()
  DateTime fecha = DateTime.now();

  int usuarioId = 0;

  String? observaciones;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  MovimientoLoteEntity();

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id_isar': id,
      'lote_id': loteId,
      'tipo': tipo,
      'cantidad': cantidad,
      'fecha': fecha.toIso8601String(),
      'usuario_id': usuarioId,
      'observaciones': observaciones,
      'sincronizado': sincronizado,
      'fecha_sincronizacion': fechaSincronizacion?.toIso8601String(),
    };
  }

  factory MovimientoLoteEntity.fromSupabase(Map<String, dynamic> json) {
    return MovimientoLoteEntity()
      ..id = safeInt(json['id_isar']) ?? Isar.autoIncrement
      ..loteId = safeInt(json['lote_id']) ?? 0
      ..tipo = json['tipo'] as String
      ..cantidad = (json['cantidad'] as num).toDouble()
      ..fecha = DateTime.parse(json['fecha'] as String)
      ..usuarioId = safeInt(json['usuario_id']) ?? 0
      ..observaciones = json['observaciones'] as String?
      ..sincronizado = json['sincronizado'] as bool? ?? false
      ..fechaSincronizacion = json['fecha_sincronizacion'] != null
          ? DateTime.parse(json['fecha_sincronizacion'] as String)
          : null;
  }
}
