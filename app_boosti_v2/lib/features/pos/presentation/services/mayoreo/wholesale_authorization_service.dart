// lib/features/pos/domain/services/wholesale_authorization_service.dart
import '../../../data/Local/entities/autorizacion_descuento_entity.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../../domain/permissions/roles.dart';


/// Resultado de la evaluación de un descuento.
class DescuentoEvaluacion {
  /// `true` si el descuento supera el tope del rol.
  final bool requiereAutorizacion;

  /// Tope (%) permitido sin autorización para el rol.
  final double topeRol;

  /// `true` si el descuento es válido (0 <= pct <= 100).
  final bool esValido;

  /// Motivo de invalidez (si aplica).
  final String? motivoInvalidez;

  const DescuentoEvaluacion({
    required this.requiereAutorizacion,
    required this.topeRol,
    required this.esValido,
    this.motivoInvalidez,
  });
}

/// Servicio de validación y registro de descuentos.
class WholesaleAuthorizationService {
  WholesaleAuthorizationService._();

  // ──────────────── Configuración ────────────────

  /// Topes por rol (porcentaje máximo sin autorización).
  ///
  /// En el futuro se podrán mover a `SharedPreferences` para que el
  /// admin los configure desde la app.
   static final Map<UserRole, double> _topesPorRol = {
    UserRole.admin: 100.0,
    UserRole.supervisor: 15.0,
    UserRole.cajero: 5.0,
    UserRole.almacen: 0.0,
    UserRole.rrhh: 0.0,
    UserRole.soporte: 0.0,
    UserRole.auditor: 0.0,
  };
  /// Devuelve el tope (%) permitido para un rol.
  static double topeParaRol(UserRole rol) {
    return _topesPorRol[rol] ?? 0.0;
  }

  // ──────────────── Evaluación ────────────────

  /// Evalúa si un descuento requiere autorización.
  static DescuentoEvaluacion evaluar({
    required double descuentoPorcentaje,
    required UserRole rolSolicitante,
  }) {
    // Validaciones básicas
    if (descuentoPorcentaje < 0) {
      return const DescuentoEvaluacion(
        requiereAutorizacion: false,
        topeRol: 0,
        esValido: false,
        motivoInvalidez: 'El descuento no puede ser negativo',
      );
    }
    if (descuentoPorcentaje > 100) {
      return const DescuentoEvaluacion(
        requiereAutorizacion: false,
        topeRol: 0,
        esValido: false,
        motivoInvalidez: 'El descuento no puede superar el 100%',
      );
    }

    final tope = topeParaRol(rolSolicitante);
    final requiere = descuentoPorcentaje > tope;

    return DescuentoEvaluacion(
      requiereAutorizacion: requiere,
      topeRol: tope,
      esValido: true,
    );
  }

  // ──────────────── Registro ────────────────

  /// Registra una autorización de descuento en Isar.
  ///
  /// Debe llamarse:
  ///   - Al **rechazar**: `aprobado = false`.
  ///   - Al **aprobar**: `aprobado = true` con datos del autorizador.
  ///
  /// Devuelve la entidad ya persistida (con `id` asignado).
  static Future<AutorizacionDescuentoEntity> registrar({
    required double descuentoSolicitado,
    required UserRole rolSolicitante,
    required int solicitanteId,
    required String solicitanteNombre,
    required String solicitanteRol,
    required bool aprobado,
    int? autorizadorId,
    String? autorizadorNombre,
    String? autorizadorRol,
    int? ventaIdFk,
    String? ventaSupabaseId,
    int? productoId,
    String? productoNombre,
    bool esGlobal = false,
    String? motivoRechazo,
    IsarService? isarService,
  }) async {
    final entidad = AutorizacionDescuentoEntity()
      ..descuentoSolicitado = descuentoSolicitado
      ..topeRolSolicitante = topeParaRol(rolSolicitante)
      ..solicitadoPorId = solicitanteId
      ..solicitadoPorNombre = solicitanteNombre
      ..solicitadoPorRol = solicitanteRol
      ..aprobado = aprobado
      ..autorizadoPorId = autorizadorId
      ..autorizadoPorNombre = autorizadorNombre
      ..autorizadoPorRol = autorizadorRol
      ..ventaIdFk = ventaIdFk
      ..ventaSupabaseId = ventaSupabaseId
      ..productoId = productoId
      ..productoNombre = productoNombre
      ..esGlobal = esGlobal
      ..motivoRechazo = motivoRechazo
      ..fecha = DateTime.now()
      ..syncStatus = 'pending';

    final service = isarService ?? IsarService();
    await service.guardarAutorizacionDescuento(entidad);

    return entidad;
  }

  /// Formatea un porcentaje para mostrar en UI.
  static String formatearPorcentaje(double pct) {
    if (pct == pct.roundToDouble()) {
      return '${pct.toInt()}%';
    }
    return '${pct.toStringAsFixed(2)}%';
  }
}