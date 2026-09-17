import 'package:isar/isar.dart';

part 'empleado_entity.g.dart';

/// Información laboral extendida de un empleado.
/// Relación 1-a-1 con `UsuarioEntity` vía `usuarioId`.
@collection
class EmpleadoInfoEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late int usuarioId;

  // ══════════════════════════════════════════════════════════════
  // CONTRATO
  // ══════════════════════════════════════════════════════════════

  DateTime? fechaIngreso;
  String? cargo;                  // "Cajero", "Gerente de turno"
  String? tipoContrato;           // 'tiempo_completo' | 'medio_tiempo' | 'pasante' | 'por_horas'
  int? numeroEmpleado;

  /// Supervisor directo (FK local a `UsuarioEntity.id`).
  /// Puede diferir del `UsuarioEntity.supervisorId` si en el futuro
  /// se maneja doble jerarquía (operativa vs administrativa).
  int? supervisorId;

  // ══════════════════════════════════════════════════════════════
  // COMPENSACIÓN
  // ══════════════════════════════════════════════════════════════

  double? salarioBase;
  String? frecuenciaPago;         // 'mensual' | 'quincenal' | 'semanal'
  String? monedaSalario;          // 'USD' | 'VES'
  double? comisionPorcentaje;     // % sobre ventas
  double? bonoFijo;               // monto fijo mensual
  bool recibePropinas = false;

  // ══════════════════════════════════════════════════════════════
  // HORARIO
  // ══════════════════════════════════════════════════════════════

  /// Referencia al modelo de horario (FK local a `HorarioEntity.id`).
  int? horarioId;

  /// Días libres por defecto (1=lunes, 7=domingo).
  /// Ej: [6, 7] = sábado y domingo.
  List<int> diasLibres = [];

  // ══════════════════════════════════════════════════════════════
  // CONTACTO DE EMERGENCIA
  // ══════════════════════════════════════════════════════════════

  String? contactoEmergenciaNombre;
  String? contactoEmergenciaTelefono;

  // ══════════════════════════════════════════════════════════════
  // METADATA
  // ══════════════════════════════════════════════════════════════

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  DateTime? fechaSincronizacion;
  String syncStatus = 'pending';
  String? supabaseId;

  EmpleadoInfoEntity();

  // ══════════════════════════════════════════════════════════════
  // GETTERS DE CONVENIENCIA
  // ══════════════════════════════════════════════════════════════

  @ignore
  Duration? get antiguedad {
    if (fechaIngreso == null) return null;
    return DateTime.now().difference(fechaIngreso!);
  }

  @ignore
  String get antiguedadLegible {
    final d = antiguedad;
    if (d == null) return 'Sin fecha';

    final anios = d.inDays ~/ 365;
    final meses = (d.inDays % 365) ~/ 30;

    if (anios == 0) return '$meses mes${meses == 1 ? '' : 'es'}';
    if (meses == 0) return '$anios año${anios == 1 ? '' : 's'}';
    
    return '$anios año${anios == 1 ? '' : 's'} $meses m';
  
  }
}