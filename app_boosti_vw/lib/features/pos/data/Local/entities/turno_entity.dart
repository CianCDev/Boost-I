// lib/features/pos/data/Local/entities/turno_entity.dart

class TurnoEntity {
  int id = 0; // 0 = nuevo
  String turnoId = ''; // UUID de Supabase
  int usuarioId = 0;
  String usuarioNombre = '';

  String cajaId = '';      // UUID de la caja en Supabase
  String cajaNombre = '';  // Nombre de la caja

  double montoInicial = 0.0;
  double? montoFinal;      // Nullable hasta que se cierre el turno
  DateTime fechaApertura = DateTime.now();
  DateTime? fechaCierre;
  String estado = 'abierto'; // 'abierto', 'cerrado'
  String syncStatus = 'pending';

  int? ventasCount;
  double? totalVentas;

  TurnoEntity();

  // ✅ Convertir a Mapa (para Sembast)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'turnoId': turnoId,
      'usuarioId': usuarioId,
      'usuarioNombre': usuarioNombre,
      'cajaId': cajaId,
      'cajaNombre': cajaNombre,
      'montoInicial': montoInicial,
      'montoFinal': montoFinal,
      'fechaApertura': fechaApertura.toIso8601String(),
      'fechaCierre': fechaCierre?.toIso8601String(),
      'estado': estado,
      'syncStatus': syncStatus,
      'ventasCount': ventasCount,
      'totalVentas': totalVentas,
    };
  }

  // ✅ Crear desde Mapa (Sembast)
  factory TurnoEntity.fromMap(Map<String, dynamic> map) {
    return TurnoEntity()
      ..id = (map['id'] as int?) ?? 0
      ..turnoId = (map['turnoId'] as String?) ?? ''
      ..usuarioId = (map['usuarioId'] as int?) ?? 0
      ..usuarioNombre = (map['usuarioNombre'] as String?) ?? ''
      ..cajaId = (map['cajaId'] as String?) ?? ''
      ..cajaNombre = (map['cajaNombre'] as String?) ?? ''
      ..montoInicial = (map['montoInicial'] as num?)?.toDouble() ?? 0.0
      ..montoFinal = (map['montoFinal'] as num?)?.toDouble()
      ..fechaApertura = DateTime.tryParse(map['fechaApertura'] as String? ?? '') ?? DateTime.now()
      ..fechaCierre = map['fechaCierre'] != null ? DateTime.tryParse(map['fechaCierre'] as String) : null
      ..estado = (map['estado'] as String?) ?? 'abierto'
      ..syncStatus = (map['syncStatus'] as String?) ?? 'pending'
      ..ventasCount = map['ventasCount'] as int?
      ..totalVentas = (map['totalVentas'] as num?)?.toDouble();
  }
}