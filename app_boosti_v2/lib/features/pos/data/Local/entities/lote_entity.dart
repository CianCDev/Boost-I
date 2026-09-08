// lib/features/pos/data/Local/entities/lote_entity.dart
import 'package:isar/isar.dart';

part 'lote_entity.g.dart';

@Collection()
class LoteEntity {
  Id id = Isar.autoIncrement;

  @Index()
  String? supabaseId;

  @Index()
  late int productoId;

  @Index() // ✅ NUEVO: para filtrar por local
  late int localId;

  String? codigoLoteProveedor;
  double cantidadInicial = 0.0;
  double cantidadRestante = 0.0;

  @Index()
  DateTime fechaIngreso = DateTime.now();
  DateTime? fechaVencimiento;

  @Index()
  String estado = 'pendiente';

  double? costoUnitario;

  // ✅ NUEVO: proveedor asociado al lote
  String? proveedorId;
  String? proveedorNombre;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  LoteEntity();

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': supabaseId,
      'id_isar': id,
      'producto_id_fk': productoId,
      'local_id': localId, // ✅ NUEVO
      'codigo_lote_proveedor': codigoLoteProveedor,
      'cantidad_inicial': cantidadInicial,
      'cantidad_restante': cantidadRestante,
      'fecha_ingreso': fechaIngreso.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'estado': estado,
      'costo_unitario': costoUnitario,
      'proveedor_id': proveedorId, // ✅ NUEVO
      'proveedor_nombre': proveedorNombre, // ✅ NUEVO
      'sincronizado': sincronizado,
      'fecha_sincronizacion': fechaSincronizacion?.toIso8601String(),
    };
  }

  factory LoteEntity.fromSupabase(Map<String, dynamic> json) {
    return LoteEntity()
      ..id = json['id_isar'] as int? ?? Isar.autoIncrement
      ..supabaseId = json['id'] as String?
      ..productoId = json['producto_id_fk'] as int
      ..localId = json['local_id'] as int? ?? 0 // ✅ NUEVO (con fallback)
      ..codigoLoteProveedor = json['codigo_lote_proveedor'] as String?
      ..cantidadInicial = (json['cantidad_inicial'] as num?)?.toDouble() ?? 0.0
      ..cantidadRestante = (json['cantidad_restante'] as num?)?.toDouble() ?? 0.0
      ..fechaIngreso = DateTime.parse(json['fecha_ingreso'] as String)
      ..fechaVencimiento = json['fecha_vencimiento'] != null
          ? DateTime.parse(json['fecha_vencimiento'] as String)
          : null
      ..estado = json['estado'] as String? ?? 'pendiente'
      ..costoUnitario = (json['costo_unitario'] as num?)?.toDouble()
      ..proveedorId = json['proveedor_id'] as String? // ✅ NUEVO
      ..proveedorNombre = json['proveedor_nombre'] as String? // ✅ NUEVO
      ..sincronizado = json['sincronizado'] as bool? ?? false
      ..fechaSincronizacion = json['fecha_sincronizacion'] != null
          ? DateTime.parse(json['fecha_sincronizacion'] as String)
          : null;
  }
}