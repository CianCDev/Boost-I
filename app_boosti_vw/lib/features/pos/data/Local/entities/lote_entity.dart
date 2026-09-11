// lib/features/pos/data/Local/entities/lote_entity.dart

class LoteEntity {
  int id = 0; // 0 = nuevo

  String? supabaseId;
  int productoId = 0;

  String? codigoLoteProveedor;
  String? codigoBarrasLote;

  double cantidadInicial = 0.0;
  double cantidadRestante = 0.0;

  DateTime fechaIngreso = DateTime.now();
  DateTime? fechaVencimiento;

  String estado = 'pendiente';

  double? costoUnitario;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  LoteEntity();

  // ✅ Para Sembast
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'productoId': productoId,
      'codigoLoteProveedor': codigoLoteProveedor,
      'codigoBarrasLote': codigoBarrasLote,
      'cantidadInicial': cantidadInicial,
      'cantidadRestante': cantidadRestante,
      'fechaIngreso': fechaIngreso.toIso8601String(),
      'fechaVencimiento': fechaVencimiento?.toIso8601String(),
      'estado': estado,
      'costoUnitario': costoUnitario,
      'sincronizado': sincronizado,
      'fechaSincronizacion': fechaSincronizacion?.toIso8601String(),
    };
  }

  // ✅ Desde Sembast
  factory LoteEntity.fromMap(Map<String, dynamic> map) {
    return LoteEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as String?
      ..productoId = (map['productoId'] as int?) ?? 0
      ..codigoLoteProveedor = map['codigoLoteProveedor'] as String?
      ..codigoBarrasLote = map['codigoBarrasLote'] as String?
      ..cantidadInicial = (map['cantidadInicial'] as num?)?.toDouble() ?? 0.0
      ..cantidadRestante = (map['cantidadRestante'] as num?)?.toDouble() ?? 0.0
      ..fechaIngreso = DateTime.tryParse(map['fechaIngreso'] as String? ?? '') ?? DateTime.now()
      ..fechaVencimiento = map['fechaVencimiento'] != null ? DateTime.tryParse(map['fechaVencimiento'] as String) : null
      ..estado = (map['estado'] as String?) ?? 'pendiente'
      ..costoUnitario = (map['costoUnitario'] as num?)?.toDouble()
      ..sincronizado = (map['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.tryParse(map['fechaSincronizacion'] as String) : null;
  }

  // ✅ Mantenemos los métodos de Supabase originales
  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': supabaseId,
      'id_isar': id,
      'producto_id': productoId,
      'codigo_lote_proveedor': codigoLoteProveedor,
      'codigo_barras_lote': codigoBarrasLote,
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
      ..id = (json['id_isar'] as int?) ?? 0
      ..supabaseId = json['id'] as String?
      ..productoId = (json['producto_id'] as int?) ?? 0
      ..codigoLoteProveedor = json['codigo_lote_proveedor'] as String?
      ..codigoBarrasLote = json['codigo_barras_lote'] as String?
      ..cantidadInicial = (json['cantidad_inicial'] as num?)?.toDouble() ?? 0.0
      ..cantidadRestante = (json['cantidad_restante'] as num?)?.toDouble() ?? 0.0
      ..fechaIngreso = DateTime.tryParse(json['fecha_ingreso'] as String? ?? '') ?? DateTime.now()
      ..fechaVencimiento = json['fecha_vencimiento'] != null ? DateTime.tryParse(json['fecha_vencimiento'] as String) : null
      ..estado = (json['estado'] as String?) ?? 'pendiente'
      ..costoUnitario = (json['costo_unitario'] as num?)?.toDouble()
      ..sincronizado = (json['sincronizado'] as bool?) ?? false
      ..fechaSincronizacion = json['fecha_sincronizacion'] != null ? DateTime.tryParse(json['fecha_sincronizacion'] as String) : null;
  }
}