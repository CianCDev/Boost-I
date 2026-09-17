// lib/features/pos/data/Local/entities/autorizacion_descuento_entity.dart
import 'package:isar/isar.dart';

part 'autorizacion_descuento_entity.g.dart';

/// Registro de auditoría de cada descuento que requirió autorización.
///
/// Se crea cuando un cajero/supervisor solicita un descuento que supera
/// su tope por rol. El autorizador (admin/supervisor) aprueba o rechaza.
@collection
class AutorizacionDescuentoEntity {
  Id id = Isar.autoIncrement;

  @Index()
  String? supabaseId;

  @Index()
  String? tenantId;

  /// FK local a la venta (si ya se concretó).
  @Index()
  int? ventaIdFk;

  /// UUID de la venta en Supabase.
  String? ventaSupabaseId;

  /// ID local del producto (null si es descuento global).
  int? productoId;

  /// Nombre del producto afectado.
  String? productoNombre;

  /// `true` si el descuento fue aplicado al total (no a un producto).
  bool esGlobal = false;

  /// % de descuento solicitado (0-100).
  double descuentoSolicitado = 0.0;

  /// Tope del rol que solicitó (para trazabilidad).
  double topeRolSolicitante = 0.0;

  // ──────────────── Solicitante ────────────────
  int? solicitadoPorId;
  String solicitadoPorNombre = '';
  String solicitadoPorRol = '';

  // ──────────────── Autorizador ────────────────
  int? autorizadoPorId;
  String? autorizadoPorNombre;
  String? autorizadoPorRol;

  /// `true` si fue aprobado, `false` si rechazado.
  bool aprobado = false;

  String? motivoRechazo;

  DateTime fecha = DateTime.now();

  String syncStatus = 'pending';

  AutorizacionDescuentoEntity();

  // ──────────────── Serialización ────────────────

  Map<String, dynamic> toSupabaseJson() {
    return {
      if (supabaseId != null) 'id': supabaseId,
      'tenant_id': tenantId,
      'id_isar': id,
      'venta_id': ventaSupabaseId,
      'producto_id_isar': productoId,
      'producto_nombre': productoNombre,
      'es_global': esGlobal,
      'descuento_solicitado': descuentoSolicitado,
      'tope_rol_solicitante': topeRolSolicitante,
      'solicitado_por_id': solicitadoPorId,
      'solicitado_por_nombre': solicitadoPorNombre,
      'solicitado_por_rol': solicitadoPorRol,
      'autorizado_por_id': autorizadoPorId,
      'autorizado_por_nombre': autorizadoPorNombre,
      'autorizado_por_rol': autorizadoPorRol,
      'aprobado': aprobado,
      'motivo_rechazo': motivoRechazo,
      'fecha': fecha.toIso8601String(),
      'created_at': fecha.toIso8601String(),
    };
  }

  factory AutorizacionDescuentoEntity.fromSupabase(Map<String, dynamic> json) {
    return AutorizacionDescuentoEntity()
      ..supabaseId = json['id'] as String?
      ..tenantId = json['tenant_id'] as String?
      ..ventaSupabaseId = json['venta_id'] as String?
      ..productoId = (json['producto_id_isar'] as num?)?.toInt()
      ..productoNombre = json['producto_nombre'] as String?
      ..esGlobal = json['es_global'] as bool? ?? false
      ..descuentoSolicitado =
          (json['descuento_solicitado'] as num?)?.toDouble() ?? 0.0
      ..topeRolSolicitante =
          (json['tope_rol_solicitante'] as num?)?.toDouble() ?? 0.0
      ..solicitadoPorId = (json['solicitado_por_id'] as num?)?.toInt()
      ..solicitadoPorNombre = json['solicitado_por_nombre'] as String? ?? ''
      ..solicitadoPorRol = json['solicitado_por_rol'] as String? ?? ''
      ..autorizadoPorId = (json['autorizado_por_id'] as num?)?.toInt()
      ..autorizadoPorNombre = json['autorizado_por_nombre'] as String?
      ..autorizadoPorRol = json['autorizado_por_rol'] as String?
      ..aprobado = json['aprobado'] as bool? ?? false
      ..motivoRechazo = json['motivo_rechazo'] as String?
      ..fecha = json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now()
      ..syncStatus = 'synced';
  }
}