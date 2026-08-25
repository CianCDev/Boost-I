import 'package:isar/isar.dart';
import 'producto_entity.dart';
part 'proveedor_entity.g.dart';

@Collection()
class ProveedorEntity {
  Id id = Isar.autoIncrement;

  String? supabaseId;
  late String nombre;
  String? cedula;
  String? telefono;
  String? empresa;
  String? rif;
  String? direccion;
  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;
  String? email;
  
  // 🔥 NUEVO: Para comparar fechas de actualización
  DateTime? updatedAt; 

  @Ignore()
  List<ProductoEntity>? productos;
}