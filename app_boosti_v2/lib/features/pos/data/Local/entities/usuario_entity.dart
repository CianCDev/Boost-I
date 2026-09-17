import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/enums/tipo_documento.dart';

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



/// Tipo de documento: V (Venezolano) o E (Extranjero).
/// Solo `V` y `E` son válidos para usuarios.
@Enumerated(EnumType.name)
TipoDocumento? tipoDocumento;

/// Número de documento sin prefijo ni puntos.
/// Ej: "12345678" para V-12.345.678.
String? numeroDocumento;

String? telefono;      // +58 412-1234567
String? direccion;
String? fotoUrl;       // URL pública en Supabase Storage

// ══════════════════════════════════════════════════════════════
// ORGANIZACIÓN (nuevo en Fase 1)
// ══════════════════════════════════════════════════════════════

/// ID local del usuario que supervisa a este empleado.
/// Puede ser `null` para admin/dueño.
int? supervisorId;


@ignore
String get documentoCompleto {
  if (tipoDocumento == null || numeroDocumento == null) {
    return 'Sin documento';
  }
  return tipoDocumento!.formatear(numeroDocumento);
}

@ignore
bool get tieneDocumento =>
    tipoDocumento != null &&
    numeroDocumento != null &&
    numeroDocumento!.isNotEmpty;
  UsuarioEntity();
}