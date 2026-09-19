// lib/features/pos/data/Local/entities/proveedor_entity.dart
import 'package:isar/isar.dart';
import 'producto_entity.dart';
part 'proveedor_entity.g.dart';

@Collection()
class ProveedorEntity {
  Id id = Isar.autoIncrement;

  String? supabaseId;
  String nombre = '';

  // ──────────────── Identificación (NUEVO) ────────────────

  /// Tipo de documento: 'V' | 'E' | 'J' | 'G' | 'P' | 'C'
  /// (V-venezolano, E-extranjero, J-jurídico, G-gubernamental,
  ///  P-pasaporte, C-comuna)
  String? tipoDocumento;

  /// Número de documento SIN prefijo. Ej: 12345678
  /// Se combina con `tipoDocumento` para mostrar "V-12345678".
  int? documento;

  /// RIF formateado (aplica principalmente a J/G).
  /// Formato canónico: `J-12345678-9`.
  String? rif;

  // ──────────────── Legacy ────────────────

  /// ⚠️ DEPRECATED: usar `documento` + `tipoDocumento` o `rif`.
  /// Se mantiene para no romper datos existentes. Se puede limpiar
  /// en una migración futura.
  String? cedula;

  // ──────────────── Contacto / empresa ────────────────
  String? telefono;
  String? email;
  String? direccion;

  /// Nombre comercial / empresa (para mostrar en card).
  String? empresa;

  // ──────────────── Estado ────────────────
  bool activo = true;

  // ──────────────── Sincronización ────────────────
  bool sincronizado = false;
  DateTime? fechaSincronizacion;
  DateTime? updatedAt;

  @Ignore()
  List<ProductoEntity>? productos;

  ProveedorEntity();

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Devuelve el documento formateado priorizando el RIF:
  ///   1. Si hay `rif` → lo devuelve tal cual.
  ///   2. Si hay `documento` + `tipoDocumento` → "V-12345678".
  ///   3. Si hay `documento` solo → "12345678".
  ///   4. Fallback legacy: `cedula`.
  ///   5. Cadena vacía.
  String get documentoFormateado {
    if (rif != null && rif!.isNotEmpty) return rif!;
    if (documento != null) {
      if (tipoDocumento == null || tipoDocumento!.isEmpty) {
        return documento.toString();
      }
      return '$tipoDocumento-$documento';
    }
    if (cedula != null && cedula!.isNotEmpty) return cedula!;
    return '';
  }

  /// Tipo de documento normalizado en mayúscula. Vacío si no hay.
  String get tipoDocumentoLabel {
    if (tipoDocumento == null || tipoDocumento!.isEmpty) return '';
    return tipoDocumento!.toUpperCase();
  }

  /// Texto listo para UI: "J-12345678-9" o "Sin identificación".
  String get identificacionDisplay =>
      documentoFormateado.isEmpty ? 'Sin identificación' : documentoFormateado;

  /// ¿Tiene al menos un dato de identificación cargado?
  bool get tieneIdentificacion =>
      documentoFormateado.isNotEmpty;

  // ═══════════════════════════════════════════════════════════════
  // SERIALIZACIÓN SUPABASE
  // ═══════════════════════════════════════════════════════════════

  factory ProveedorEntity.fromSupabase(Map<String, dynamic> json) {
    return ProveedorEntity()
      ..supabaseId = json['id'] as String?
      ..nombre = json['nombre'] as String? ?? ''
      ..tipoDocumento = json['tipo_documento'] as String?
      ..documento = (json['documento'] as num?)?.toInt()
      ..rif = json['rif'] as String?
      ..telefono = json['telefono'] as String?
      ..email = json['email'] as String?
      ..direccion = json['direccion'] as String?
      ..empresa = json['empresa'] as String?
      ..activo = json['activo'] as bool? ?? true
      ..sincronizado = true
      ..updatedAt = json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null;
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      if (supabaseId != null) 'id': supabaseId,
      'nombre': nombre,
      'tipo_documento': tipoDocumento,
      'documento': documento,
      'rif': rif,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'empresa': empresa,
      'activo': activo,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}