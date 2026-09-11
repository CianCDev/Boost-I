// lib/features/pos/data/Local/entities/gasto_entity.dart

class GastoEntity {
  int id = 0; // 0 = nuevo
  String descripcion = '';
  double monto = 0.0;
  String moneda = 'USD';
  double? tasaBcv;
  String categoria = 'General';
  int usuarioId = 0;
  String usuarioNombre = '';
  DateTime fecha = DateTime.now();
  String syncStatus = 'pending';
  String? supabaseId;

  GastoEntity();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'monto': monto,
      'moneda': moneda,
      'tasaBcv': tasaBcv,
      'categoria': categoria,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'fecha': fecha.toIso8601String(),
      'syncStatus': syncStatus,
      'supabaseId': supabaseId,
    };
  }

  factory GastoEntity.fromMap(Map<String, dynamic> map) {
    return GastoEntity()
      ..id = (map['id'] as int?) ?? 0
      ..descripcion = (map['descripcion'] as String?) ?? ''
      ..monto = (map['monto'] as num?)?.toDouble() ?? 0.0
      ..moneda = (map['moneda'] as String?) ?? 'USD'
      ..tasaBcv = (map['tasaBcv'] as num?)?.toDouble()
      ..categoria = (map['categoria'] as String?) ?? 'General'
      ..usuarioId = (map['usuarioId'] as int?) ?? 0
      ..usuarioNombre = (map['usuarioNombre'] as String?) ?? ''
      ..fecha = DateTime.tryParse(map['fecha'] as String? ?? '') ?? DateTime.now()
      ..syncStatus = (map['syncStatus'] as String?) ?? 'pending'
      ..supabaseId = map['supabaseId'] as String?;
  }
}