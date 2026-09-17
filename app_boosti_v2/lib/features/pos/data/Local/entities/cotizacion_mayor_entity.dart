// lib/features/pos/data/Local/entities/cotizacion_mayor_entity.dart
import 'package:isar/isar.dart';

part 'cotizacion_mayor_entity.g.dart';

/// Cotización de venta al mayor.
///
/// Flujo: borrador → enviada → aprobada → convertida en venta.
/// O bien: borrador → vencida (si pasa la fecha).
@collection
class CotizacionMayorEntity {
  Id id = Isar.autoIncrement;

  @Index()
  String? supabaseId;

  @Index()
  String? tenantId;

  /// Nº correlativo (ej: COT-2026-0001).
  @Index()
  String numero = '';

  /// FK local al cliente (Isar).
  int? clienteId;

  /// UUID del cliente en Supabase.
  String? clienteSupabaseId;

  // ──────────────── Snapshot fiscal ────────────────
  String? clienteRif;
  String? clienteRazonSocial;
  String? clienteNombre;

  /// Items serializados como JSON (mismo formato que DetalleVentaEntity).
  String itemsJson = '[]';

  // ──────────────── Totales ────────────────
  double subtotal = 0.0;
  double descuentoGlobal = 0.0;
  double impuesto = 0.0;
  double total = 0.0;
  double totalBolivares = 0.0;
  double? tasaBcv;

  // ──────────────── Estado y fechas ────────────────
  /// 'borrador' | 'enviada' | 'aprobada' | 'vencida' | 'convertida'
  @Index()
  String estado = 'borrador';

  DateTime fechaEmision = DateTime.now();
  DateTime? fechaVencimiento;

  String? observaciones;

  // ──────────────── Auditoría ────────────────
  int? usuarioId;
  String? usuarioNombre;

  /// UUID de la venta generada si se convirtió.
  String? ventaConvertidaId;

  DateTime? createdAt;
  DateTime? updatedAt;

  String syncStatus = 'pending';

  CotizacionMayorEntity();

  // ──────────────── Serialización ────────────────

  Map<String, dynamic> toSupabaseJson() {
    return {
      if (supabaseId != null) 'id': supabaseId,
      'tenant_id': tenantId,
      'id_isar': id,
      'numero': numero,
      'cliente_id': clienteSupabaseId,
      'cliente_rif': clienteRif,
      'cliente_razon_social': clienteRazonSocial,
      'items_json': itemsJson,
      'subtotal': subtotal,
      'descuento_global': descuentoGlobal,
      'impuesto': impuesto,
      'total': total,
      'total_bolivares': totalBolivares,
      'tasa_bcv': tasaBcv,
      'estado': estado,
      'fecha_emision': fechaEmision.toIso8601String(),
      'fecha_vencimiento': fechaVencimiento?.toIso8601String(),
      'observaciones': observaciones,
      'usuario_id': usuarioId,
      'usuario_nombre': usuarioNombre,
      'venta_convertida_id': ventaConvertidaId,
      'created_at': (createdAt ?? fechaEmision).toIso8601String(),
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory CotizacionMayorEntity.fromSupabase(Map<String, dynamic> json) {
    return CotizacionMayorEntity()
      ..supabaseId = json['id'] as String?
      ..tenantId = json['tenant_id'] as String?
      ..numero = json['numero'] as String? ?? ''
      ..clienteSupabaseId = json['cliente_id'] as String?
      ..clienteRif = json['cliente_rif'] as String?
      ..clienteRazonSocial = json['cliente_razon_social'] as String?
      ..itemsJson = json['items_json'] is Map || json['items_json'] is List
          ? json['items_json'].toString()
          : (json['items_json'] as String? ?? '[]')
      ..subtotal = (json['subtotal'] as num?)?.toDouble() ?? 0.0
      ..descuentoGlobal =
          (json['descuento_global'] as num?)?.toDouble() ?? 0.0
      ..impuesto = (json['impuesto'] as num?)?.toDouble() ?? 0.0
      ..total = (json['total'] as num?)?.toDouble() ?? 0.0
      ..totalBolivares =
          (json['total_bolivares'] as num?)?.toDouble() ?? 0.0
      ..tasaBcv = (json['tasa_bcv'] as num?)?.toDouble()
      ..estado = json['estado'] as String? ?? 'borrador'
      ..fechaEmision = json['fecha_emision'] != null
          ? DateTime.parse(json['fecha_emision'] as String)
          : DateTime.now()
      ..fechaVencimiento = json['fecha_vencimiento'] != null
          ? DateTime.tryParse(json['fecha_vencimiento'] as String)
          : null
      ..observaciones = json['observaciones'] as String?
      ..usuarioId = (json['usuario_id'] as num?)?.toInt()
      ..usuarioNombre = json['usuario_nombre'] as String?
      ..ventaConvertidaId = json['venta_convertida_id'] as String?
      ..createdAt = json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null
      ..updatedAt = json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null
      ..syncStatus = 'synced';
  }
}