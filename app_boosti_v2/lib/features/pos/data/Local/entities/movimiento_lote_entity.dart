// lib/features/pos/data/Local/entities/movimiento_lote_entity.dart
import 'package:isar/isar.dart';

part 'movimiento_lote_entity.g.dart';

@Collection()
class MovimientoLoteEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late int loteId;

  late String tipo; // 'activacion', 'venta', 'traspaso', 'devolucion'

  late double cantidad;

  @Index()
  late DateTime fecha;

  late int usuarioId;

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
      ..id = json['id_isar'] as int? ?? Isar.autoIncrement
      ..loteId = json['lote_id'] as int
      ..tipo = json['tipo'] as String
      ..cantidad = (json['cantidad'] as num).toDouble()
      ..fecha = DateTime.parse(json['fecha'] as String)
      ..usuarioId = json['usuario_id'] as int
      ..observaciones = json['observaciones'] as String?
      ..sincronizado = json['sincronizado'] as bool? ?? false
      ..fechaSincronizacion = json['fecha_sincronizacion'] != null
          ? DateTime.parse(json['fecha_sincronizacion'] as String)
          : null;
  }
}