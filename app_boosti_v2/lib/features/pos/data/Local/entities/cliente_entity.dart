// lib/features/pos/data/Local/entities/cliente_entity.dart
import 'package:isar/isar.dart';

part 'cliente_entity.g.dart';

@Collection()
class ClienteEntity {
  Id id = Isar.autoIncrement;

  String? supabaseId;
  int? localId;
  String? localSupabaseId;

  // ──────────────── Identidad ────────────────

  String nombre = '';

  /// Tipo de documento: 'V' | 'E' | 'J' | 'G' | 'P' | 'C'
  /// (V-venezolano, E-extranjero, J-jurídico, G-gubernamental, P-pasaporte)
  String? tipoDocumento;

  /// Número de documento SIN prefijo. Ej: 12345678
  /// Se combina con `tipoDocumento` para mostrar "V-12345678".
  int? documento;

  String? telefono;
  String? email;
  String? direccion;

  DateTime fechaRegistro = DateTime.now();

  // ──────────────── Fidelización ────────────────
  bool frecuente = false;
  double totalCompras = 0.0;
  DateTime? ultimaCompra;
  int cantidadCompras = 0;

  // ──────────────── Estado y preferencias ────────────────
  bool activo = true;
  bool preferenciasMarketing = true;

  DateTime? fechaNacimiento;
  String? notas;

  // ──────────────── Mayorista ────────────────
  String? razonSocial;
  String? rif;

  @Index()
  bool esMayorista = false;

  double? limiteCredito;
  int? diasCredito;
  double? descuentoPreferencial;

  // ──────────────── Sincronización ────────────────
  String syncStatus = 'pending';
  DateTime? createdAt;
  DateTime? updatedAt;

  ClienteEntity();

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  /// Devuelve "V-12345678" o "12345678" si no hay tipo.
  /// Cadena vacía si no hay documento.
  String get documentoFormateado {
    if (documento == null) return '';
    if (tipoDocumento == null || tipoDocumento!.isEmpty) {
      return documento.toString();
    }
    return '$tipoDocumento-${documento!}';
  }

  /// Devuelve el tipo de documento normalizado en mayúscula.
  String get tipoDocumentoLabel {
    if (tipoDocumento == null || tipoDocumento!.isEmpty) return '';
    return tipoDocumento!.toUpperCase();
  }

  /// Texto completo listo para UI: "V-12345678" o "Sin documento".
  String get documentoDisplay =>
      documentoFormateado.isEmpty ? 'Sin documento' : documentoFormateado;

  // ═══════════════════════════════════════════════════════════════
  // SERIALIZACIÓN SUPABASE
  // ═══════════════════════════════════════════════════════════════

  factory ClienteEntity.fromSupabase(Map<String, dynamic> json) {
    return ClienteEntity()
      ..supabaseId = json['id'] as String?
      ..localSupabaseId = json['tenant_id'] as String?
      ..nombre = json['nombre'] as String? ?? ''
      ..tipoDocumento = json['tipo_documento'] as String?
      ..documento = (json['documento'] as num?)?.toInt()
      ..telefono = json['telefono'] as String?
      ..email = json['email'] as String?
      ..direccion = json['direccion'] as String?
      ..fechaRegistro = json['fecha_registro'] != null
          ? DateTime.parse(json['fecha_registro'].toString())
          : DateTime.now()
      ..frecuente = json['frecuente'] as bool? ?? false
      ..totalCompras = (json['total_compras'] as num?)?.toDouble() ?? 0.0
      ..ultimaCompra = json['ultima_compra'] != null
          ? DateTime.tryParse(json['ultima_compra'].toString())
          : null
      ..cantidadCompras = (json['cantidad_compras'] as num?)?.toInt() ?? 0
      ..activo = json['activo'] as bool? ?? true
      ..preferenciasMarketing =
          json['preferencias_marketing'] as bool? ?? true
      ..fechaNacimiento = json['fecha_nacimiento'] != null
          ? DateTime.tryParse(json['fecha_nacimiento'].toString())
          : null
      ..notas = json['notas'] as String?
      // Mayorista
      ..rif = json['rif'] as String?
      ..razonSocial = json['razon_social'] as String?
      ..esMayorista = json['es_mayorista'] as bool? ?? false
      ..limiteCredito = (json['limite_credito'] as num?)?.toDouble()
      ..diasCredito = (json['dias_credito'] as num?)?.toInt()
      ..descuentoPreferencial =
          (json['descuento_preferencial'] as num?)?.toDouble()
      ..syncStatus = 'synced'
      ..createdAt = json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null
      ..updatedAt = json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null;
  }

  Map<String, dynamic> toSupabaseJson(String tenantId) {
    return {
      if (supabaseId != null) 'id': supabaseId,
      'tenant_id': tenantId,
      'nombre': nombre,
      'tipo_documento': tipoDocumento,
      'documento': documento,
      'telefono': telefono,
      'email': email,
      'direccion': direccion,
      'fecha_registro': fechaRegistro.toIso8601String(),
      'frecuente': frecuente,
      'total_compras': totalCompras,
      'ultima_compra': ultimaCompra?.toIso8601String(),
      'cantidad_compras': cantidadCompras,
      'activo': activo,
      'preferencias_marketing': preferenciasMarketing,
      'fecha_nacimiento':
          fechaNacimiento?.toIso8601String().split('T')[0],
      'notas': notas,
      // Mayorista
      'rif': rif,
      'razon_social': razonSocial,
      'es_mayorista': esMayorista,
      'limite_credito': limiteCredito,
      'dias_credito': diasCredito,
      'descuento_preferencial': descuentoPreferencial,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}