// lib/features/pos/data/Local/entities/config_descuento_mayorista_entity.dart
import 'package:isar/isar.dart';

part 'config_descuento_mayorista_entity.g.dart';

/// Regla de descuento automático por volumen para ventas al mayor.
///
/// Ejemplo: "Categoría Bebidas, cantidad 6-11 → 5% de descuento".
/// Puede requerir autorización si supera el tope del rol.
@collection
class ConfigDescuentoMayoristaEntity {
  Id id = Isar.autoIncrement;

  @Index()
  String? supabaseId;

  @Index()
  String? tenantId;

  /// Nombre descriptivo de la regla.
  String nombre = '';

  /// FK local a la categoría (null = aplica a todas).
  int? categoriaIdIsar;

  /// UUID de la categoría en Supabase.
  String? categoriaSupabaseId;

  /// Cantidad mínima de unidades para que aplique.
  int cantidadMinima = 0;

  /// Cantidad máxima (null = sin tope).
  int? cantidadMaxima;

  /// % de descuento (0-100).
  double descuentoPorcentaje = 0.0;

  /// Si `true`, se requiere autorización de admin/supervisor.
  bool requiereAutorizacion = false;

  bool activo = true;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  String syncStatus = 'pending';

  ConfigDescuentoMayoristaEntity();

  // ──────────────── Serialización ────────────────

  Map<String, dynamic> toSupabaseJson() {
    return {
      if (supabaseId != null) 'id': supabaseId,
      'tenant_id': tenantId,
      'id_isar': id,
      'nombre': nombre,
      'categoria_id_isar': categoriaIdIsar,
      'categoria_supabase_id': categoriaSupabaseId,
      'cantidad_minima': cantidadMinima,
      'cantidad_maxima': cantidadMaxima,
      'descuento_porcentaje': descuentoPorcentaje,
      'requiere_autorizacion': requiereAutorizacion,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ConfigDescuentoMayoristaEntity.fromSupabase(
    Map<String, dynamic> json,
  ) {
    return ConfigDescuentoMayoristaEntity()
      ..supabaseId = json['id'] as String?
      ..tenantId = json['tenant_id'] as String?
      ..nombre = json['nombre'] as String? ?? ''
      ..categoriaIdIsar = (json['categoria_id_isar'] as num?)?.toInt()
      ..categoriaSupabaseId = json['categoria_supabase_id'] as String?
      ..cantidadMinima = (json['cantidad_minima'] as num?)?.toInt() ?? 0
      ..cantidadMaxima = (json['cantidad_maxima'] as num?)?.toInt()
      ..descuentoPorcentaje =
          (json['descuento_porcentaje'] as num?)?.toDouble() ?? 0.0
      ..requiereAutorizacion =
          json['requiere_autorizacion'] as bool? ?? false
      ..activo = json['activo'] as bool? ?? true
      ..createdAt = json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now()
      ..updatedAt = json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now()
      ..syncStatus = 'synced';
  }
}