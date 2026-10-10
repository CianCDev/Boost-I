import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/client_note.dart';
import '../data/models/payment.dart';
import '../data/models/plan.dart';
import '../data/models/suscripcion.dart';
import '../data/models/tenant.dart';
import '../data/repositories/notes_repository.dart';
import '../data/repositories/payments_repository.dart';
import '../utils/resolver_usuario_id.dart';
import 'clients_provider.dart';
import 'plans_provider.dart';
import 'subscriptions_provider.dart';

// ═══════════════════════════════════════════════════════════════
// REPOSITORIOS (inyectables para tests)
// ═══════════════════════════════════════════════════════════════

/// Repositorio de notas. Se declara aquí porque solo lo usa la ficha de
/// cliente; los de tenants, planes y suscripciones viven en sus propios
/// providers.
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  return NotesRepository();
});

/// Repositorio de pagos. Mismo criterio que [notesRepositoryProvider].
final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository();
});

// Los otros tres se reusan, sin duplicar la instancia:
//   tenants       → [tenantsRepositoryProvider]   (clients_provider.dart)
//   suscripciones → [subscriptionsRepositoryProvider]
//   planes        → [plansRepositoryProvider]      (plans_provider.dart)

// ═══════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════

/// Estado de la ficha de un cliente.
class ClientDetailState {
  final bool cargando;
  final String? error;

  final Tenant? tenant;
  final Suscripcion? suscripcion;
  final Plan? plan;
  final List<ClientNote> notas;
  final List<Payment> pagos;
  final DateTime? ultimaActualizacion;

  ClientDetailState({
    this.cargando = false,
    this.error,
    this.tenant,
    this.suscripcion,
    this.plan,
    this.notas = const [],
    this.pagos = const [],
    this.ultimaActualizacion,
  });

  /// Estado inicial: sin cargar.
  factory ClientDetailState.inicial() => ClientDetailState();

  /// Estado de carga: conserva lo ya cargado y **limpia** el error.
  ///
  /// Hace falta porque `copyWith(error: null)` conservaría el error anterior
  /// (un `copyWith` no puede distinguir "no cambies" de "pon null").
  ClientDetailState aCargando() {
    return ClientDetailState(
      cargando: true,
      tenant: tenant,
      suscripcion: suscripcion,
      plan: plan,
      notas: notas,
      pagos: pagos,
      ultimaActualizacion: ultimaActualizacion,
    );
  }

  ClientDetailState copyWith({
    bool? cargando,
    String? error,
    Tenant? tenant,
    Suscripcion? suscripcion,
    Plan? plan,
    List<ClientNote>? notas,
    List<Payment>? pagos,
    DateTime? ultimaActualizacion,
  }) {
    return ClientDetailState(
      cargando: cargando ?? this.cargando,
      error: error ?? this.error,
      tenant: tenant ?? this.tenant,
      suscripcion: suscripcion ?? this.suscripcion,
      plan: plan ?? this.plan,
      notas: notas ?? this.notas,
      pagos: pagos ?? this.pagos,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════

/// Carga el detalle de un tenant: sus datos, suscripción, plan, notas
/// y pagos.
///
/// Las 4 consultas base van en paralelo; el plan se pide después porque
/// depende de `suscripcion.planId`.
class ClientDetailNotifier extends StateNotifier<ClientDetailState> {
  ClientDetailNotifier(this._ref, this.tenantId)
      : super(ClientDetailState.inicial());

  final Ref _ref;

  /// UUID del tenant cuyo detalle se está cargando.
  final String tenantId;

  // ═════════════════════════════════════════════════════════════
  // CARGA
  // ═════════════════════════════════════════════════════════════

  Future<void> cargar() async {
    state = state.aCargando();

    try {
      final resultados = await Future.wait<Object?>([
        _ref.read(tenantsRepositoryProvider).obtenerPorId(tenantId),
        _ref.read(subscriptionsRepositoryProvider).obtenerPorTenant(tenantId),
        _ref.read(notesRepositoryProvider).listarPorTenant(tenantId),
        _ref.read(paymentsRepositoryProvider).listarPorTenant(tenantId),
      ]);

      // Los repositorios no lanzan: devuelven null/[] y loguean, así que
      // los casts son seguros.
      final tenant = resultados[0] as Tenant?;
      final suscripcion = resultados[1] as Suscripcion?;
      final notas = resultados[2] as List<ClientNote>;
      final pagos = resultados[3] as List<Payment>;

      Plan? plan;
      if (suscripcion != null) {
        plan = await _ref
            .read(plansRepositoryProvider)
            .obtenerPorId(suscripcion.planId);
      }

      state = state.copyWith(
        cargando: false,
        tenant: tenant,
        suscripcion: suscripcion,
        plan: plan,
        notas: notas,
        pagos: pagos,
        ultimaActualizacion: DateTime.now(),
      );

      debugPrint(
        '[ClientDetailProvider] $tenantId cargado: '
        'plan=${plan?.nombre ?? "-"} '
        'notas=${notas.length} pagos=${pagos.length}',
      );
    } catch (e, stack) {
      debugPrint('[ClientDetailProvider] Error en cargar(): $e');
      debugPrint('[ClientDetailProvider] Stack: $stack');
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  /// Vuelve a pedir todos los datos al repositorio.
  Future<void> refrescar() => cargar();

  // ═════════════════════════════════════════════════════════════
  // ESCRITURA
  // ═════════════════════════════════════════════════════════════

  /// Resuelve el autor/registrador de una escritura.
  ///
  /// Delega en [resolverUsuarioId] (cascada de 3 niveles compartida con
  /// `SubscriptionsActionsNotifier`).
  String? _resolverUsuarioId() => resolverUsuarioId(_ref);

  /// Añade una nota al cliente actual.
  ///
  /// Devuelve `true` en éxito, `false` si el contenido viene vacío o si
  /// la escritura falla. Nunca propaga excepciones.
  Future<bool> agregarNota({
    required String contenido,
    List<String> tags = const [],
  }) async {
    final limpio = contenido.trim();
    if (limpio.isEmpty) return false;

    try {
      final autorId = _resolverUsuarioId();

      await _ref.read(notesRepositoryProvider).crear(
            tenantId: tenantId,
            contenido: limpio,
            autorId: autorId,
            tags: tags,
          );

      await _recargarNotas();
      return true;
    } catch (e, stack) {
      debugPrint('[ClientDetailProvider] Error agregando nota: $e');
      debugPrint('[ClientDetailProvider] Stack: $stack');
      return false;
    }
  }

  /// Marca o desmarca una nota como fijada.
  Future<bool> toggleFijadaNota(String notaId, bool fijada) async {
    try {
      await _ref.read(notesRepositoryProvider).toggleFijada(notaId, fijada);
      await _recargarNotas();
      return true;
    } catch (e, stack) {
      debugPrint('[ClientDetailProvider] Error en toggleFijada: $e');
      debugPrint('[ClientDetailProvider] Stack: $stack');
      return false;
    }
  }

  /// Elimina una nota.
  Future<bool> eliminarNota(String notaId) async {
    try {
      await _ref.read(notesRepositoryProvider).eliminar(notaId);
      await _recargarNotas();
      return true;
    } catch (e, stack) {
      debugPrint('[ClientDetailProvider] Error eliminando nota: $e');
      debugPrint('[ClientDetailProvider] Stack: $stack');
      return false;
    }
  }

  /// Recarga solo las notas, sin volver a pedir tenant/suscripción/pagos.
  Future<void> _recargarNotas() async {
    final notas =
        await _ref.read(notesRepositoryProvider).listarPorTenant(tenantId);
    if (!mounted) return;
    state = state.copyWith(notas: notas);
  }

  /// Registra un pago para el cliente actual.
  ///
  /// [monto] debe ser mayor que 0. [estado] debe ser uno de: 'pendiente',
  /// 'pagado', 'fallido', 'reembolsado'.
  ///
  /// Devuelve `true` en éxito, `false` si el monto es inválido o si la
  /// escritura falla. Nunca propaga excepciones.
  Future<bool> registrarPago({
    required double monto,
    String moneda = 'USD',
    String estado = 'pagado',
    String? metodo,
    String? referencia,
    DateTime? pagadoEn,
    DateTime? periodoInicio,
    DateTime? periodoFin,
    String? notas,
    double? tasaConversion,
    double? montoOriginal,
    String? monedaOriginal,
  }) async {
    if (monto <= 0) return false;

    try {
      final registradoPor = _resolverUsuarioId();

      await _ref.read(paymentsRepositoryProvider).registrar(
            tenantId: tenantId,
            // `suscripcion_id` es nullable en la tabla: si el tenant no
            // tiene suscripción se registra el pago igual, sin vincular.
            suscripcionId: state.suscripcion?.id,
            monto: monto,
            moneda: moneda,
            estado: estado,
            metodo: metodo,
            referencia: referencia,
            pagadoEn: pagadoEn,
            periodoInicio: periodoInicio,
            periodoFin: periodoFin,
            notas: notas,
            registradoPor: registradoPor,
            tasaConversion: tasaConversion,
            montoOriginal: montoOriginal,
            monedaOriginal: monedaOriginal,
          );

      await _recargarPagos();
      return true;
    } catch (e, stack) {
      debugPrint('[ClientDetailProvider] Error registrando pago: $e');
      debugPrint('[ClientDetailProvider] Stack: $stack');
      return false;
    }
  }

  /// Cambia el estado de un pago existente.
  ///
  /// [nuevoEstado] debe ser el `name` de un `EstadoPago`.
  Future<bool> actualizarEstadoPago(
    String pagoId,
    String nuevoEstado,
  ) async {
    try {
      await _ref
          .read(paymentsRepositoryProvider)
          .actualizarEstado(pagoId, nuevoEstado);
      await _recargarPagos();
      return true;
    } catch (e, stack) {
      debugPrint('[ClientDetailProvider] Error actualizando estado pago: $e');
      debugPrint('[ClientDetailProvider] Stack: $stack');
      return false;
    }
  }

  /// Recarga solo los pagos, sin volver a pedir tenant/suscripción/notas.
  Future<void> _recargarPagos() async {
    final pagos =
        await _ref.read(paymentsRepositoryProvider).listarPorTenant(tenantId);
    if (!mounted) return;
    state = state.copyWith(pagos: pagos);
  }

  // ═════════════════════════════════════════════════════════════
  // SUSCRIPCIÓN
  //
  // Estos 4 métodos NO reimplementan la lógica: delegan en
  // `SubscriptionsActionsNotifier`, que ya la ejecuta y escribe en
  // `suscripcion_historial`. Aquí solo se refresca el estado local de
  // la ficha para que la UI lo vea al instante.
  // ═════════════════════════════════════════════════════════════

  /// Extiende el trial [dias] días. Solo válido con estado `trial`.
  Future<bool> extenderTrial(int dias) async {
    if (dias <= 0) return false;
    if (state.suscripcion?.estado != EstadoSuscripcion.trial) return false;

    final ok = await _ref
        .read(subscriptionsActionsProvider.notifier)
        .extenderTrial(tenantId, dias);
    if (ok) await _recargarSuscripcion();
    return ok;
  }

  /// Cambia el plan de la suscripción a [nuevoPlanId].
  Future<bool> cambiarPlan(String nuevoPlanId, {String? motivo}) async {
    final planActual = state.plan?.id;
    if (planActual == nuevoPlanId) return false;

    final ok = await _ref
        .read(subscriptionsActionsProvider.notifier)
        .cambiarPlan(tenantId, nuevoPlanId, notas: motivo);
    if (ok) await _recargarSuscripcion();
    return ok;
  }

  /// Cancela la suscripción con el [motivo] dado.
  Future<bool> cancelar(String motivo) async {
    final estado = state.suscripcion?.estado;
    if (estado == null || estado == EstadoSuscripcion.cancelado) {
      return false;
    }

    final ok = await _ref
        .read(subscriptionsActionsProvider.notifier)
        .cancelar(tenantId, motivo);
    if (ok) await _recargarSuscripcion();
    return ok;
  }

  /// Reactiva una suscripción cancelada o expirada.
  Future<bool> reactivar() async {
    final estado = state.suscripcion?.estado;
    if (estado != EstadoSuscripcion.cancelado &&
        estado != EstadoSuscripcion.expirado) {
      return false;
    }

    final ok = await _ref
        .read(subscriptionsActionsProvider.notifier)
        .reactivar(tenantId);
    if (ok) await _recargarSuscripcion();
    return ok;
  }

  /// Recarga suscripción + plan desde la BD.
  ///
  /// ⚠️ `copyWith` usa `?? this.x`, así que **no puede dejar `suscripcion`
  /// en null**: si la fila desapareciera, el estado conservaría la
  /// anterior. Ninguna de las 4 acciones borra la suscripción, así que
  /// hoy es inofensivo; si alguna vez lo hiciera, haría falta un método
  /// `aSinSuscripcion()` que reconstruya el estado.
  Future<void> _recargarSuscripcion() async {
    final sub = await _ref
        .read(subscriptionsRepositoryProvider)
        .obtenerPorTenant(tenantId);
    Plan? plan;
    if (sub != null) {
      plan = await _ref.read(plansRepositoryProvider).obtenerPorId(sub.planId);
    }
    if (!mounted) return;
    state = state.copyWith(suscripcion: sub, plan: plan);
  }
}

// ═══════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════

/// Detalle de un tenant, indexado por su UUID.
///
/// Se usa `StateNotifierProvider.family` y no `FamilyNotifier`: este
/// notifier extiende `StateNotifier`, mientras que `FamilyNotifier`
/// pertenece a la API nueva de Riverpod (`NotifierProvider.family`).
final clientDetailProvider = StateNotifierProvider.family<
    ClientDetailNotifier, ClientDetailState, String>((ref, tenantId) {
  return ClientDetailNotifier(ref, tenantId);
});
