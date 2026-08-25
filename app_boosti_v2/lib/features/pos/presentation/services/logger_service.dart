// lib/features/pos/services/logger_service.dart
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/log_entity.dart';

class LoggerService {
  static final IsarService _isar = IsarService();

  static Future<void> log({
    required String accion,
    required String usuarioNombre,
    required String usuarioRol,
    String? detalles,
  }) async {
    final log = LogEntity()
      ..accion = accion
      ..usuarioNombre = usuarioNombre
      ..usuarioRol = usuarioRol
      ..detalles = detalles
      ..fecha = DateTime.now()
      ..sincronizado = false;
    await _isar.guardarLog(log);
  }
}