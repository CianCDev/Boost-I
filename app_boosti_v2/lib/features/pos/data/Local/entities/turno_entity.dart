import 'package:isar/isar.dart';

part 'turno_entity.g.dart';

@Collection()
class TurnoEntity {
  Id id = Isar.autoIncrement; // ID local de Isar
  
  String turnoId = ''; // UUID de Supabase (para sincronización)
  int usuarioId = 0;
  String usuarioNombre = '';
  
  // ✅ Campos para la caja
  String cajaId = '';      // UUID de la caja en Supabase (opcional)
  String cajaNombre = '';  // Nombre de la caja (ej. "Caja Principal")
  
  double montoInicial = 0.0;
  double? montoFinal;      // Nullable hasta que se cierre el turno
  DateTime fechaApertura = DateTime.now();
  DateTime? fechaCierre;
  String estado = 'abierto'; // 'abierto', 'cerrado'
  String syncStatus = 'pending'; // 'pending', 'synced', 'failed'
  
  // Campos adicionales útiles para reportes
  int? ventasCount;
  double? totalVentas;
}