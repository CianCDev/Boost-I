import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/subscriptions_repository.dart';
import '../utils/resolver_usuario_id.dart';

// ═══════════════════════════════════════════════════════════════
// REPOSITORIO (inyectable para tests)
// ═══════════════════════════════════════════════════════════════

/// Repositorio de suscripciones. Se expone como provider para poder
/// sustituirlo con un fake en los tests.
final subscriptionsRepositoryProvider =
    Provider<SubscriptionsRepository>((ref) {
  return SubscriptionsRepository();
});

// ═══════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════

/// Estado global de las acciones sobre suscripciones.
enum AccionSuscripcionEstado {
  /// Sin operación en curso.
  idle,

  /// Una operación está en curso.
  loading,

  /// La última operación terminó bien.
  success,

  /// La última operación falló.
  error,
}

/// Estado expuesto por [subscriptionsActionsProvider].
///
/// Nota sobre `copyWith`: al ser `mensaje` nullable, pasar `null` conserva
/// el valor anterior (limitación clásica de `copyWith` en Dart). Para
/// limpiarlo se construye el estado directamente, como en [_ejecutar].
class SubscriptionsActionState {
  final AccionSuscripcionEstado estado;

  /// Mensaje de la última operación.
  final String? mensaje;

  const SubscriptionsActionState({
    this.estado = AccionSuscripcionEstado.idle,
    this.mensaje,
  });

  SubscriptionsActionState copyWith({
    AccionSuscripcionEstado? estado,
    String? mensaje,
  }) {
    return SubscriptionsActionState(
      estado: estado ?? this.estado,
      mensaje: mensaje ?? this.mensaje,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════

/// Orquestador de acciones sobre suscripciones.
///
/// No expone listas: solo ejecuta operaciones (extender trial, cambiar
/// plan, cancelar, reactivar) y reporta si cada una tuvo éxito.
///
/// Ningún método propaga excepciones: todos devuelven `bool` para que la
/// UI decida cómo mostrar el resultado sin try/catch.
class SubscriptionsActionsNotifier
    extends StateNotifier<SubscriptionsActionState> {
  SubscriptionsActionsNotifier(this._ref)
      : super(const SubscriptionsActionState());

  final Ref _ref;

  // ═════════════════════════════════════════════════════════════
  // ACCIONES
  // ═════════════════════════════════════════════════════════════

  /// Extiende el trial del tenant [dias] días.
  Future<bool> extenderTrial(String tenantId, int dias) {
    return _ejecutar(
      operacion: 'extender el trial',
      exito: 'Trial extendido $dias días',
      accion: () => _ref.read(subscriptionsRepositoryProvider).extenderTrial(
            tenantId: tenantId,
            dias: dias,
            cambiadoPor: _cambiadoPor,
          ),
    );
  }

  /// Cambia el plan del tenant a [nuevoPlanId].
  Future<bool> cambiarPlan(
    String tenantId,
    String nuevoPlanId, {
    String? notas,
  }) {
    return _ejecutar(
      operacion: 'cambiar el plan',
      exito: 'Plan actualizado a $nuevoPlanId',
      accion: () => _ref.read(subscriptionsRepositoryProvider).actualizarPlan(
            tenantId: tenantId,
            nuevoPlanId: nuevoPlanId,
            cambiadoPor: _cambiadoPor,
            notas: notas,
          ),
    );
  }

  /// Cancela la suscripción del tenant con el motivo dado.
  Future<bool> cancelar(String tenantId, String motivo) {
    return _ejecutar(
      operacion: 'cancelar la suscripción',
      exito: 'Suscripción cancelada',
      accion: () => _ref.read(subscriptionsRepositoryProvider).cancelar(
            tenantId: tenantId,
            motivo: motivo,
            canceladoPor: _cambiadoPor,
          ),
    );
  }

  /// Reactiva una suscripción cancelada, expirada o vencida.
  Future<bool> reactivar(String tenantId) {
    return _ejecutar(
      operacion: 'reactivar la suscripción',
      exito: 'Suscripción reactivada',
      accion: () => _ref.read(subscriptionsRepositoryProvider).reactivar(
            tenantId: tenantId,
            cambiadoPor: _cambiadoPor,
          ),
    );
  }

  // ═════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═════════════════════════════════════════════════════════════

  /// Envuelve una operación: marca loading, la ejecuta y fija el estado
  /// final. Devuelve `true` si se completó sin excepción.
  ///
  /// Construye el estado de `loading` directamente (no con `copyWith`)
  /// para poder limpiar `mensaje`.
  Future<bool> _ejecutar({
    required String operacion,
    required String exito,
    required Future<void> Function() accion,
  }) async {
    state = const SubscriptionsActionState(
      estado: AccionSuscripcionEstado.loading,
    );

    try {
      await accion();

      debugPrint('[SubscriptionsActions] $operacion: OK');
      state = SubscriptionsActionState(
        estado: AccionSuscripcionEstado.success,
        mensaje: exito,
      );
      return true;
    } catch (e, stack) {
      debugPrint('[SubscriptionsActions] $operacion falló: $e');
      debugPrint('[SubscriptionsActions] Stack: $stack');
      state = SubscriptionsActionState(
        estado: AccionSuscripcionEstado.error,
        mensaje: 'No se pudo $operacion: $e',
      );
      return false;
    }
  }

  /// UUID del usuario autenticado, para la trazabilidad del historial.
  ///
  /// Cascada de 3 niveles en [resolverUsuarioId]; `null` si no hay
  /// ninguna fuente. Antes caía en `'desconocido'`, que no es un UUID
  /// válido y hacía fallar el `INSERT` en `suscripcion_historial`.
  String? get _cambiadoPor => resolverUsuarioId(_ref);
}

// ═══════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════

final subscriptionsActionsProvider = StateNotifierProvider<
    SubscriptionsActionsNotifier, SubscriptionsActionState>((ref) {
  return SubscriptionsActionsNotifier(ref);
});
