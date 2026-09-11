// lib/features/pos/data/Local/entities/entrega_entity.dart

class EntregaEntity {
  int id = 0; // 0 = nuevo
  String? supabaseId;
  int pedidoId = 0;
  DateTime fechaEntrega = DateTime.now();
  int usuarioId = 0;
  String estadoEntrega = 'entregado'; // entregado, parcial, fallido
  String? observaciones;
  DateTime? createdAt;

  EntregaEntity();

  // ✅ Convertir a Mapa
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supabaseId': supabaseId,
      'pedidoId': pedidoId,
      'fechaEntrega': fechaEntrega.toIso8601String(),
      'usuarioId': usuarioId,
      'estadoEntrega': estadoEntrega,
      'observaciones': observaciones,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // ✅ Crear desde Mapa
  factory EntregaEntity.fromMap(Map<String, dynamic> map) {
    return EntregaEntity()
      ..id = (map['id'] as int?) ?? 0
      ..supabaseId = map['supabaseId'] as String?
      ..pedidoId = (map['pedidoId'] as int?) ?? 0
      ..fechaEntrega = DateTime.tryParse(map['fechaEntrega'] as String? ?? '') ?? DateTime.now()
      ..usuarioId = (map['usuarioId'] as int?) ?? 0
      ..estadoEntrega = (map['estadoEntrega'] as String?) ?? 'entregado'
      ..observaciones = map['observaciones'] as String?
      ..createdAt = map['createdAt'] != null ? DateTime.tryParse(map['createdAt'] as String) : null;
  }
}