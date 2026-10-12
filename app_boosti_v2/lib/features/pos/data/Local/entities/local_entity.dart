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

  /// Path del logo en el bucket `locales` de Supabase Storage.
  ///
  /// Relativo, ej: `<tenant>/local_123.png`. **NO** es una URL ni una
  /// signed URL: guardar una URL firmada fue el bug que mataba los logos
  /// de marca (caducan a la hora). El path es permanente y la URL se
  /// firma en el momento de renderizar.
  ///
  /// Se usa para imprimir el logo del local en tickets y comprobantes.
  String? logoPath;

  /// Razón social del emisor (registro legal). NO es el nombre de
  /// fantasía: "JAHTLABS C.A." vs "Boosti POS".
  ///
  /// Nullable a propósito: los locales creados antes de la migración
  /// `20261012000002` no la tienen, y rellenarla con `nombre` sería
  /// justamente el error que se quiere corregir. El ticket térmico
  /// muestra "[no configurada]" cuando falta.
  String? razonSocial;

  bool activo = true;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  DateTime? createdAt;
  DateTime? updatedAt;


   // ⚠️ No cambiar sin migrar: `BusinessMode.fromId()` acepta el valor
  // legacy 'mercado' y lo coacciona a 'retail'.
  @Index()
  String businessMode = 'retail';

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