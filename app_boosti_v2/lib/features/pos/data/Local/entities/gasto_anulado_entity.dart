import 'package:isar/isar.dart';

part 'gasto_anulado_entity.g.dart';

/// Registro de anulación de un gasto.
///
/// El gasto original NUNCA se elimina; si ya pasaron las 24h desde
/// su creación, tampoco se puede editar. Se crea este registro para
/// marcar el gasto como anulado.
@collection
class GastoAnuladoEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late int gastoIdOriginal;

  @Index()
  late String tenantId;

  late String motivo;
  late int usuarioId;
  late String usuarioNombre;
  late DateTime fechaAnulacion;
  late double montoOriginal;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;
}
