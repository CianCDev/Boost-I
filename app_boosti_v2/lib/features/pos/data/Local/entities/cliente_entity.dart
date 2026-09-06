import 'package:isar/isar.dart';
part 'cliente_entity.g.dart';

@Collection()
class ClienteEntity {
  Id id = Isar.autoIncrement; // Clave primaria local

  String? supabaseId; // UUID de Supabase (nullable hasta sincronizar)

  // Relación con el local (cada cliente pertenece a un local)
  int? localId; // ID local del LocalEntity en Isar
  String? localSupabaseId; // UUID del local en Supabase (para sincronización)

  late String nombre;
  String? documento; // Ej. V-12345678, J-12345678, etc.
  String? telefono;
  String? email;
  String? direccion;

  DateTime fechaRegistro = DateTime.now();

  // Campos de fidelización
  bool frecuente = false;
  double totalCompras = 0.0;
  DateTime? ultimaCompra;
  int cantidadCompras = 0;

  // Estado y preferencias
  bool activo = true;
  bool preferenciasMarketing = true; // para recibir promociones

  // Campos adicionales
  DateTime? fechaNacimiento;
  String? notas;

  // Sincronización
  String syncStatus = 'pending'; // 'pending', 'synced', 'failed'
  DateTime? createdAt;
  DateTime? updatedAt;

  ClienteEntity();
}