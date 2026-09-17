import 'package:isar/isar.dart';

@collection
class EmpleadoCVEntity {
  Id id = Isar.autoIncrement;
  late int usuarioId;
  
  //List<ExperienciaLaboral> experiencia = [];  // embedded
  //List<FormacionAcademica> formacion = [];    // embedded
  List<String> certificaciones = [];
  List<String> skills = [];
  String? cvPdfUrl;                            // en Supabase Storage
  
  DateTime updatedAt = DateTime.now();
}