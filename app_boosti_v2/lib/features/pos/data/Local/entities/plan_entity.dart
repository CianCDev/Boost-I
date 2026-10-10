import 'dart:convert';
import 'package:isar/isar.dart';

part 'plan_entity.g.dart';
/// Caché local de los planes disponibles en Supabase.
///
/// Se sincroniza desde la tabla `planes` y se consulta sin red.
/// Cambia poco (rara vez se añade un plan nuevo), así que refrescarlo
/// una vez al día es suficiente.
@collection
class PlanEntity {
  // 🎯 Constructor por defecto requerido por Dart e Isar al usar factories
  PlanEntity();

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String planId;                    // 'basico' | 'pro' | 'corporativo'

  late String nombre;                    // "Básico", "Pro", "Corporativo"
  String? descripcion;
  double precioMensual = 0.0;
  double? precioAnual;

  /// Modos habilitados: ['retail'], ['retail','restaurante'], etc.
  ///
  /// OJO: los 4 planes de Supabase ya guardan `retail`, nunca `mercado`.
  /// El default de abajo es solo para cuando la API no envía la columna.
  List<String> modosHabilitados = [];

  /// Features serializadas como JSON string.
  /// Para leerlas: `Map<String, bool> features = fromJson(featuresJson)`.
  String featuresJson = '{}';

  /// Orden para mostrar en UI (menor = primero).
  int orden = 0;

  DateTime? updatedAt;

  // ── Helpers ──
  
@ignore
  Map<String, dynamic> get featuresMap {
    try {
      return jsonDecode(featuresJson) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  bool tieneFeature(String key) {
    return featuresMap[key] == true;
  }

  factory PlanEntity.fromSupabase(Map<String, dynamic> json) {
    return PlanEntity()
      ..planId = json['id'] as String
      ..nombre = json['nombre'] as String? ?? ''
      ..descripcion = json['descripcion'] as String?
      ..precioMensual =
          double.tryParse(json['precio_mensual']?.toString() ?? '0') ?? 0.0
      ..precioAnual = json['precio_anual'] != null
          ? double.tryParse(json['precio_anual'].toString())
          : null
      ..modosHabilitados = (json['modos_habilitados'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          ['retail']
      ..featuresJson = jsonEncode(json['features'] ?? {})
      ..orden = (json['orden'] as num?)?.toInt() ?? 0
      ..updatedAt = json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null;
  }
}