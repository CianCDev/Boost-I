/// Modelo de datos para un tenant (cliente) del Control Center.
///
/// Mapea la tabla `tenants` de Supabase. El `id` es UUID.
class Tenant {
  // ═══════════════════════════════════════════════════════════════
  // CAMPOS
  // ═══════════════════════════════════════════════════════════════
  final String id;
  final String nombre;
  final String? rif;
  final String? emailContacto;
  final String? telefono;
  final String? ownerId;
  final bool activo;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // ═══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ═══════════════════════════════════════════════════════════════
  const Tenant({
    required this.id,
    required this.nombre,
    this.rif,
    this.emailContacto,
    this.telefono,
    this.ownerId,
    required this.activo,
    required this.createdAt,
    this.updatedAt,
  });

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  bool get tieneContacto => (emailContacto?.isNotEmpty ?? false);

  String get iniciales {
    final partes = nombre
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return '?';
    if (partes.length == 1) return partes.first.substring(0, 1).toUpperCase();
    return (partes.first.substring(0, 1) + partes[1].substring(0, 1))
        .toUpperCase();
  }

  // ═══════════════════════════════════════════════════════════════
  // SERIALIZACIÓN
  // ═══════════════════════════════════════════════════════════════
  factory Tenant.fromMap(Map<String, dynamic> map) {
    return Tenant(
      id: map['id'] as String,
      nombre: map['nombre'] as String,
      rif: map['rif'] as String?,
      emailContacto: map['email_contacto'] as String?,
      telefono: map['telefono'] as String?,
      ownerId: map['owner_id'] as String?,
      activo: map['activo'] as bool? ?? true,
      // Fallback defensivo: epoch si la fila viniera sin `created_at`.
      createdAt:
          _fecha(map['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _fecha(map['updated_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'rif': rif,
      'email_contacto': emailContacto,
      'telefono': telefono,
      'owner_id': ownerId,
      'activo': activo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Tenant copyWith({
    String? id,
    String? nombre,
    String? rif,
    String? emailContacto,
    String? telefono,
    String? ownerId,
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      rif: rif ?? this.rif,
      emailContacto: emailContacto ?? this.emailContacto,
      telefono: telefono ?? this.telefono,
      ownerId: ownerId ?? this.ownerId,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═══════════════════════════════════════════════════════════════
  static DateTime? _fecha(dynamic valor) {
    if (valor == null) return null;
    return DateTime.tryParse(valor.toString());
  }
}
