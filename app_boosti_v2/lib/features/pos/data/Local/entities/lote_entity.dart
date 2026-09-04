import 'package:isar/isar.dart';

part 'lote_entity.g.dart';

@Collection()
class LoteEntity {
  Id id = Isar.autoIncrement;

  @Index()
  String? supabaseId;

  @Index()
  late int productoId;

  String? codigoLoteProveedor; // ✅ Cambiado para coincidir con la BD
  // 🔥 ELIMINAMOS 'codigoBarrasLote' o lo dejamos como alias, pero usamos el nuevo nombre.

  double cantidadInicial = 0.0;
  double cantidadRestante = 0.0;

  @Index()
  DateTime fechaIngreso = DateTime.now();
  DateTime? fechaVencimiento;

  @Index()
  String estado = 'pendiente';

  double? costoUnitario;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  LoteEntity();

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': supabaseId,
      'id_isar': id,
      'producto_id_fk': productoId,
      'codigo_lote_proveedor': codigoLoteProveedor, // ✅ Cambiado
      'cantidad_inicial': cantidadInicial,
      'cantidad_restante': cantidadRestante,
      'fecha_ingreso': fechaIngreso.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'estado': estado,
      'costo_unitario': costoUnitario,
      'sincronizado': sincronizado,
      'fecha_sincronizacion': fechaSincronizacion?.toIso8601String(),
    };
  }

  factory LoteEntity.fromSupabase(Map<String, dynamic> json) {
    return LoteEntity()
      ..id = json['id_isar'] as int? ?? Isar.autoIncrement
      ..supabaseId = json['id'] as String?
      ..productoId = json['producto_id_fk'] as int
      ..codigoLoteProveedor = json['codigo_lote_proveedor'] as String? // ✅ Cambiado
      ..cantidadInicial = (json['cantidad_inicial'] as num?)?.toDouble() ?? 0.0
      ..cantidadRestante = (json['cantidad_restante'] as num?)?.toDouble() ?? 0.0
      ..fechaIngreso = DateTime.parse(json['fecha_ingreso'] as String)
      ..fechaVencimiento = json['fecha_vencimiento'] != null
          ? DateTime.parse(json['fecha_vencimiento'] as String)
          : null
      ..estado = json['estado'] as String? ?? 'pendiente'
      ..costoUnitario = (json['costo_unitario'] as num?)?.toDouble()
      ..sincronizado = json['sincronizado'] as bool? ?? false
      ..fechaSincronizacion = json['fecha_sincronizacion'] != null
          ? DateTime.parse(json['fecha_sincronizacion'] as String)
          : null;
  }
}