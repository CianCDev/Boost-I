import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/plan.dart';
import '../data/repositories/plans_repository.dart';

// ═══════════════════════════════════════════════════════════════
// REPOSITORIO (inyectable para tests)
// ═══════════════════════════════════════════════════════════════

/// Repositorio de planes. Se expone como provider para poder sustituirlo
/// con un fake en los tests.
final plansRepositoryProvider = Provider<PlansRepository>((ref) {
  return PlansRepository();
});

// ═══════════════════════════════════════════════════════════════
// LISTAS
// ═══════════════════════════════════════════════════════════════

/// Lista de planes activos, ordenados por `orden` ASC.
///
/// Es la lista que consume el selector de plan al cambiar la suscripción.
final planesActivosProvider = FutureProvider<List<Plan>>((ref) async {
  return ref.watch(plansRepositoryProvider).listarActivos();
});

/// Lista completa de planes (activos e inactivos).
///
/// Pensada para la pantalla de gestión de planes.
final planesTodosProvider = FutureProvider<List<Plan>>((ref) async {
  return ref.watch(plansRepositoryProvider).listarTodos();
});

// ═══════════════════════════════════════════════════════════════
// ESTADO DE LAS ACCIONES
// ═══════════════════════════════════════════════════════════════

/// Estado global de las operaciones de escritura sobre planes.
enum PlanAccionEstado { idle, cargando, exito, error }

/// Estado expuesto por [planesActionsProvider].
class PlanesActionState {
  final PlanAccionEstado estado;
  final String? mensajeError;

  const PlanesActionState._(this.estado, [this.mensajeError]);

  const PlanesActionState.idle() : this._(PlanAccionEstado.idle);
  const PlanesActionState.cargando() : this._(PlanAccionEstado.cargando);
  const PlanesActionState.exito() : this._(PlanAccionEstado.exito);

  PlanesActionState.error(String msg)
      : this._(PlanAccionEstado.error, msg);
}

// ═══════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════

/// Ejecuta el CRUD de planes sobre [PlansRepository].
///
/// Ningún método propaga excepciones: todos devuelven `bool` para que la
/// UI decida cómo mostrar el resultado sin try/catch. Tras cada
/// operación exitosa invalida los dos providers de lectura, así las
/// listas se recargan solas.
class PlanesActionsNotifier extends StateNotifier<PlanesActionState> {
  PlanesActionsNotifier(this._ref) : super(const PlanesActionState.idle());

  final Ref _ref;

  // ═════════════════════════════════════════════════════════════
  // ACCIONES
  // ═════════════════════════════════════════════════════════════

  /// Crea un plan nuevo.
  Future<bool> crear({
    required String id,
    required String nombre,
    String? descripcion,
    required double precioMensual,
    required double precioAnual,
    String moneda = 'USD',
    int maxLocales = 999999,
    int maxUsuarios = 999999,
    List<String> modosHabilitados = const [],
    Map<String, dynamic> features = const {},
    bool activo = true,
    int orden = 0,
  }) {
    return _ejecutar(
      operacion: 'crear el plan',
      accion: () => _ref.read(plansRepositoryProvider).crear(
            id: id,
            nombre: nombre,
            descripcion: descripcion,
            precioMensual: precioMensual,
            precioAnual: precioAnual,
            moneda: moneda,
            maxLocales: maxLocales,
            maxUsuarios: maxUsuarios,
            modosHabilitados: modosHabilitados,
            features: features,
            activo: activo,
            orden: orden,
          ),
    );
  }

  /// Actualiza un plan existente. Solo se envían los campos no-null.
  Future<bool> actualizar({
    required String id,
    String? nombre,
    String? descripcion,
    double? precioMensual,
    double? precioAnual,
    String? moneda,
    int? maxLocales,
    int? maxUsuarios,
    List<String>? modosHabilitados,
    Map<String, dynamic>? features,
    bool? activo,
    int? orden,
  }) {
    return _ejecutar(
      operacion: 'actualizar el plan',
      accion: () => _ref.read(plansRepositoryProvider).actualizar(
            id: id,
            nombre: nombre,
            descripcion: descripcion,
            precioMensual: precioMensual,
            precioAnual: precioAnual,
            moneda: moneda,
            maxLocales: maxLocales,
            maxUsuarios: maxUsuarios,
            modosHabilitados: modosHabilitados,
            features: features,
            activo: activo,
            orden: orden,
          ),
    );
  }

  /// Activa o desactiva un plan.
  Future<bool> toggleActivo(String id, bool activo) {
    return _ejecutar(
      operacion: 'cambiar el estado del plan',
      accion: () => _ref.read(plansRepositoryProvider).toggleActivo(
            id,
            activo,
          ),
    );
  }

  /// Elimina un plan.
  ///
  /// Falla si hay suscripciones apuntando a él; la UI puede anticiparlo
  /// con [sePuedeEliminar].
  Future<bool> eliminar(String id) {
    return _ejecutar(
      operacion: 'eliminar el plan',
      accion: () => _ref.read(plansRepositoryProvider).eliminar(id),
    );
  }

  /// Consulta si un plan se puede eliminar, sin lanzar.
  ///
  /// No cambia el estado: es una consulta, no una acción de escritura.
  Future<bool> sePuedeEliminar(String id) async {
    try {
      return await _ref.read(plansRepositoryProvider).sePuedeEliminar(id);
    } catch (e) {
      debugPrint('[PlanesActions] sePuedeEliminar($id) falló: $e');
      return false;
    }
  }

  // ═════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═════════════════════════════════════════════════════════════

  /// Envuelve una escritura: marca cargando, la ejecuta, y fija exito o
  /// error. Devuelve `true` si se completó sin excepción.
  Future<bool> _ejecutar({
    required String operacion,
    required Future<Object?> Function() accion,
  }) async {
    state = const PlanesActionState.cargando();

    try {
      await accion();

      // Invalida las dos listas para que la UI se recargue sola.
      _ref.invalidate(planesActivosProvider);
      _ref.invalidate(planesTodosProvider);

      debugPrint('[PlanesActions] $operacion: OK');
      state = const PlanesActionState.exito();
      return true;
    } catch (e, stack) {
      debugPrint('[PlanesActions] $operacion falló: $e');
      debugPrint('[PlanesActions] Stack: $stack');
      state = PlanesActionState.error('No se pudo $operacion: $e');
      return false;
    }
  }
}

// ═══════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════

final planesActionsProvider =
    StateNotifierProvider<PlanesActionsNotifier, PlanesActionState>((ref) {
  return PlanesActionsNotifier(ref);
});
