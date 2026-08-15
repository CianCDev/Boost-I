import 'package:isar/isar.dart';
import 'producto_entity.dart';
part 'proveedor_entity.g.dart';

@Collection()
class ProveedorEntity {
  Id id = Isar.autoIncrement;

  String? supabaseId; // UUID de Supabase
  late String nombre; // Nombre del proveedor (obligatorio)
  String? cedula; // Cédula o RIF
  String? telefono; // Teléfono de contacto
  String? empresa; // Nombre de la empresa
  String? rif;
  String? direccion;
  bool activo = true; // Para desactivar sin eliminar
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  // Relación inversa (opcional): productos asociados a este proveedor
  @Ignore()
  List<ProductoEntity>? productos;
}