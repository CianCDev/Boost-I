import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

part 'usuario_entity.g.dart';

@Collection()
class UsuarioEntity {
  // 1. ID interno de Isar (autoincremental)
  Id id = Isar.autoIncrement;

  // 2. ID dinámico único generado automáticamente
  @Index(unique: true)
  String dynamicId = Uuid().v4();

  // ==================== DATOS BÁSICOS ====================
  String nombre = '';
  String pin = '';
  String rol = 'cajero';
  bool activo = true;
  String estado = 'inactivo';
  String cajaAsignada = 'Caja Principal';
  String? email;
  String? password;
  String? supabaseId;
  String? supabaseUid;
  String? deviceId;
  String? departamento;
  int? departamentoId;
  int? localId;

  // ==================== 🆕 CAMPOS NUEVOS ====================
  /// UUID del tenant en Supabase (`usuarios.tenant_id`).
  /// Guardamos el UUID directamente para no depender de conversiones.
  String? tenantId;

  /// Inicio del descanso actual (Supabase: `inicio_descanso`).
  DateTime? inicioDescanso;

  /// Minutos de descanso acumulados (Supabase: `minutos_descanso`).
  int? minutosDescanso;

  /// Última actividad del usuario (Supabase: `ultima_actividad`).
  DateTime? ultimaActividad;

  /// Fecha de última actualización remota (Supabase: `ultimaActualizacion`).
  DateTime? ultimaActualizacion;

  // ==================== AUDITORÍA ====================
  DateTime? createdAt;
  DateTime? updatedAt;
  bool sincronizado = false;
  DateTime? fechaSincronizacion;

  UsuarioEntity();
}