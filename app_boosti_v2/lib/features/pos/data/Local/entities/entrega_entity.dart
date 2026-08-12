import 'package:isar/isar.dart';

part 'entrega_entity.g.dart';

@Collection()
class EntregaEntity {
  Id id = Isar.autoIncrement;
  String? supabaseId;
  int pedidoId = 0;
  DateTime fechaEntrega = DateTime.now();
  int usuarioId = 0;
  String estadoEntrega = 'entregado'; // entregado, parcial, fallido
  String? observaciones;
  DateTime? createdAt;
}