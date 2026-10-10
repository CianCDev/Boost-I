import 'package:isar/isar.dart';

part 'venta_anulada_entity.g.dart';
/// Registro de anulación de una venta.
///
/// Se crea SIEMPRE que un admin/supervisor anula una venta.
/// La venta original NUNCA se edita ni se elimina.
@collection
class VentaAnuladaEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late String ventaIdOriginal;

  @Index()
  late String tenantId;

  late String motivo;
  late int usuarioId;
  late String usuarioNombre;
  late String usuarioRol;
  late DateTime fechaAnulacion;
  late double montoOriginal;

  bool sincronizado = false;
  DateTime? fechaSincronizacion;
}
