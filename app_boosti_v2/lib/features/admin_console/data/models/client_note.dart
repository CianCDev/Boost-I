/// Modelo de datos para una nota interna de cliente del Control Center.
///
/// Mapea la tabla `notas_cliente` de Supabase.
class ClientNote {
  // ═══════════════════════════════════════════════════════════════
  // CAMPOS
  // ═══════════════════════════════════════════════════════════════
  final String id;
  final String tenantId;
  final String? autorId;
  final String contenido;
  final List<String> tags;
  final bool fijada;
  final DateTime createdAt;

  // ═══════════════════════════════════════════════════════════════
  // CONSTRUCTOR
  // ═══════════════════════════════════════════════════════════════
  const ClientNote({
    required this.id,
    required this.tenantId,
    this.autorId,
    required this.contenido,
    required this.tags,
    required this.fijada,
    required this.createdAt,
  });

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  bool get tieneTags => tags.isNotEmpty;

  // ═══════════════════════════════════════════════════════════════
  // SERIALIZACIÓN
  // ═══════════════════════════════════════════════════════════════
  factory ClientNote.fromMap(Map<String, dynamic> map) {
    return ClientNote(
      id: map['id'] as String,
      tenantId: map['tenant_id'] as String,
      autorId: map['autor_id'] as String?,
      contenido: map['contenido'] as String,
      tags:
          (map['tags'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const <String>[],
      fijada: map['fijada'] as bool? ?? false,
      // Fallback defensivo: epoch si la fila viniera sin `created_at`.
      createdAt:
          _fecha(map['created_at']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenant_id': tenantId,
      'autor_id': autorId,
      'contenido': contenido,
      'tags': tags,
      'fijada': fijada,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ClientNote copyWith({
    String? id,
    String? tenantId,
    String? autorId,
    String? contenido,
    List<String>? tags,
    bool? fijada,
    DateTime? createdAt,
  }) {
    return ClientNote(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      autorId: autorId ?? this.autorId,
      contenido: contenido ?? this.contenido,
      tags: tags ?? this.tags,
      fijada: fijada ?? this.fijada,
      createdAt: createdAt ?? this.createdAt,
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
