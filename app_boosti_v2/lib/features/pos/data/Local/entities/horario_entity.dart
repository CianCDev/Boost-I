import 'package:isar/isar.dart';

part 'horario_entity.g.dart';

/// Modelo de horario reutilizable. Varios empleados pueden compartir
/// el mismo horario ("Turno mañana", "Turno noche", etc.).
@collection
class HorarioEntity {
  Id id = Isar.autoIncrement;

  late String nombre;             // "Turno mañana"
  String? descripcion;

  /// JSON con horario por día.
  /// Formato: {"1":"08:00-16:00","2":"08:00-16:00",...,"6":"libre","7":"libre"}
  /// Claves: 1=lunes .. 7=domingo.
  String horarioJson = '{}';

  int horasSemanales = 40;
  int toleranciaMinutos = 10;
  bool activo = true;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  String syncStatus = 'pending';
  String? supabaseId;

  HorarioEntity();

  // ══════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════

  // ignore: invalid_annotation_target
  @ignore
  String nombreDiaCorto(int weekday) {
    const dias = ['', 'L', 'M', 'M', 'J', 'V', 'S', 'D'];
    if (weekday < 1 || weekday > 7) return '?';
    return dias[weekday];
  }

  // ignore: invalid_annotation_target
  @ignore
  String nombreDiaLargo(int weekday) {
    const dias = [
      '', 'Lunes', 'Martes', 'Miércoles',
      'Jueves', 'Viernes', 'Sábado', 'Domingo'
    ];
    if (weekday < 1 || weekday > 7) return '?';
    return dias[weekday];
  }
}