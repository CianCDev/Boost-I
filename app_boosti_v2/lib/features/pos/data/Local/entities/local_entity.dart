import 'package:isar/isar.dart';

part 'local_entity.g.dart';

@Collection()
class LocalEntity {
  Id id = Isar.autoIncrement;
  String? supabaseId;

  String nombre = '';
  String? direccion;
  String? telefono;
  String? email;
  String? rif; // NUEVO: RIF del local

  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  DateTime? createdAt;
  DateTime? updatedAt;


   @Index()
  String businessMode = 'mercado';

  /// Cuándo se configuró el modo por última vez (auditoría).
  DateTime? modoConfiguradoEn;

  // ═══════════════════════════════════════════════════════════
  // 🎯 NUEVO: Caché del plan vigente
  // ═══════════════════════════════════════════════════════════
  //
  // Evita consultar Supabase en cada arranque. Se invalida cada
  // 24h o cuando el Realtime detecta un cambio en `suscripciones`.

  String? planIdCache;              // 'basico' | 'pro' | 'corporativo'
  DateTime? planVerificadoEn;       // última validación contra Supabase

  // ═══════════════════════════════════════════════════════════
  // Sync
  // ═══════════════════════════════════════════════════════════



  LocalEntity();
}