// lib/features/pos/presentation/providers/mesas_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';

import 'local_actual_provider.dart';

// ══════════════════════════════════════════════════════════════════
// ESTADO
// ══════════════════════════════════════════════════════════════════

class MesasState {
  final List<MesaEntity> mesas;
  final bool isLoading;
  final String? error;

  /// Filtro de zona activo. `null` = todas.
  final MesaZona? zonaFiltro;

  /// Local dueño de las mesas cargadas. `null` = todavía no hay local.
  final int? localId;

  const MesasState({
    this.mesas = const [],
    this.isLoading = true,
    this.error,
    this.zonaFiltro,
    this.localId,
  });

  MesasState copyWith({
    List<MesaEntity>? mesas,
    bool? isLoading,
    String? error,
    MesaZona? zonaFiltro,
    bool limpiarZonaFiltro = false,
    int? localId,
    bool limpiarLocalId = false,
  }) {
    return MesasState(
      mesas: mesas ?? this.mesas,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      zonaFiltro:
          limpiarZonaFiltro ? null : (zonaFiltro ?? this.zonaFiltro),
      localId: limpiarLocalId ? null : (localId ?? this.localId),
    );
  }

  /// Mesas tras aplicar el filtro de zona (ya vienen ordenadas).
  List<MesaEntity> get mesasVisibles =>
      zonaFiltro == null
          ? mesas
          : mesas.where((m) => m.zona == zonaFiltro).toList();

  /// Zonas que tienen al menos una mesa, para poblar el filtro.
  List<MesaZona> get zonasDisponibles {
    final zonas = mesas.map((m) => m.zona).toSet().toList();
    zonas.sort((a, b) => a.index.compareTo(b.index));
    return zonas;
  }
}

// ══════════════════════════════════════════════════════════════════
// NOTIFIER
// ══════════════════════════════════════════════════════════════════

class MesasNotifier extends StateNotifier<MesasState> {
  final IsarService _isar = IsarService();
  final Ref _ref;

  /// Recarga al cambiar de local (hot-switch).
  ///
  /// Réplica de `lotes_provider.dart:138`. Es la garantía real: funciona
  /// aunque alguien olvide añadir el provider a la lista de
  /// `invalidate` de `setLocalActual`.
  late final ProviderSubscription<int?> _localSubscription;

  MesasNotifier(this._ref) : super(const MesasState()) {
    _localSubscription = _ref.listen(localActualProvider, (previous, next) {
      debugPrint('📍 [Mesas] Local cambiado: $previous → $next');
      cargar();
    });
    cargar();
  }

  @override
  void dispose() {
    _localSubscription.close();
    super.dispose();
  }

  // ── Carga ────────────────────────────────────────────────────────

  Future<void> cargar() async {
    state = state.copyWith(isLoading: true);
    try {
      final localId = _ref.read(localActualProvider);
      if (localId == null) {
        // Sin local activo no hay mesas: no inventamos nada.
        debugPrint('⚠️ [Mesas] Sin local activo, lista vacía');
        state = state.copyWith(
          mesas: const [],
          isLoading: false,
          limpiarLocalId: true,
        );
        return;
      }

      final mesas = await _isar.obtenerMesasDelLocal(localId);
      state = state.copyWith(
        mesas: mesas,
        isLoading: false,
        localId: localId,
      );
    } catch (e) {
      debugPrint('❌ [Mesas] Error cargando: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Cambia el filtro de zona. `null` = mostrar todas.
  void filtrarPorZona(MesaZona? zona) {
    if (zona == null) {
      state = state.copyWith(limpiarZonaFiltro: true);
    } else {
      state = state.copyWith(zonaFiltro: zona);
    }
  }

  // ── Alta / edición ───────────────────────────────────────────────

  /// Crea una mesa en el local activo.
  ///
  /// Devuelve el id creado, o `null` si no se pudo (sin local activo,
  /// nombre duplicado o capacidad inválida). El error concreto queda en
  /// `state.error` para que la UI lo muestre.
  Future<int?> crearMesa({
    required String nombre,
    MesaZona zona = MesaZona.salon,
    int capacidad = 4,
    MesaEstado estado = MesaEstado.libre,
  }) async {
    try {
      final localId = _ref.read(localActualProvider);
      if (localId == null) {
        return _fallar('No hay local activo. Selecciona un local primero.');
      }

      final nombreLimpio = nombre.trim();
      if (nombreLimpio.isEmpty) {
        return _fallar('El nombre de la mesa no puede estar vacío.');
      }
      if (capacidad < 1 || capacidad > 50) {
        return _fallar('La capacidad debe estar entre 1 y 50.');
      }

      // Índice único: no hay dos mesas con el mismo nombre en un local.
      final clave = '$localId::$nombreLimpio';
      if (await _isar.existeMesaConClave(clave)) {
        return _fallar('Ya existe una mesa llamada "$nombreLimpio" '
            'en este local.');
      }

      final mesa = MesaEntity()
        ..localId = localId
        ..nombre = nombreLimpio
        ..zona = zona
        ..capacidad = capacidad
        ..estado = estado
        ..ordenGrid = state.mesas.length
        ..ocupadaDesde = estado == MesaEstado.ocupada ? DateTime.now() : null;

      // Obligatorio antes de guardar: mantiene el índice único honesto.
      mesa.recalcularClaveUnica();

      final id = await _isar.guardarMesa(mesa);
      await cargar();
      return id;
    } catch (e) {
      debugPrint('❌ [Mesas] Error creando: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Actualiza una mesa existente.
  Future<bool> actualizarMesa(MesaEntity mesa) async {
    try {
      final nombreLimpio = mesa.nombre.trim();
      if (nombreLimpio.isEmpty) {
        return _fallarBool('El nombre de la mesa no puede estar vacío.');
      }
      if (mesa.capacidad < 1 || mesa.capacidad > 50) {
        return _fallarBool('La capacidad debe estar entre 1 y 50.');
      }
      if (mesa.localId == 0) {
        return _fallarBool('La mesa no tiene local asignado.');
      }

      // Al renombrar o mover de local cambia la clave: hay que revalidar.
      final clave = '${mesa.localId}::$nombreLimpio';
      if (await _isar.existeMesaConClave(clave, excluirId: mesa.id)) {
        return _fallarBool('Ya existe una mesa llamada "$nombreLimpio" '
            'en este local.');
      }

      mesa.nombre = nombreLimpio;
      mesa.recalcularClaveUnica();

      if (mesa.estado == MesaEstado.ocupada) {
        mesa.ocupadaDesde ??= DateTime.now();
      } else {
        mesa.ocupadaDesde = null;
      }

      await _isar.guardarMesa(mesa);
      await cargar();
      return true;
    } catch (e) {
      debugPrint('❌ [Mesas] Error actualizando: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  // ── Estado ───────────────────────────────────────────────────────

  /// Cambia el estado de una mesa.
  Future<bool> cambiarEstado(int id, MesaEstado nuevoEstado) async {
    final mesa = await _isar.obtenerMesaPorId(id);
    if (mesa == null) {
      return _fallarBool('La mesa ya no existe.');
    }
    if (mesa.estado == nuevoEstado) return true;

    mesa.estado = nuevoEstado;
    mesa.ocupadaDesde =
        nuevoEstado == MesaEstado.ocupada ? DateTime.now() : null;
    await _isar.guardarMesa(mesa);
    await cargar();
    return true;
  }

  // ── Borrado ──────────────────────────────────────────────────────

  /// Elimina una mesa. Solo se permite si está `libre`.
  Future<bool> eliminarMesa(int id) async {
    final mesa = await _isar.obtenerMesaPorId(id);
    if (mesa == null) {
      return _fallarBool('La mesa ya no existe.');
    }
    if (mesa.estado != MesaEstado.libre) {
      return _fallarBool(
        'No se puede eliminar una mesa en estado "${_etiqueta(mesa.estado)}". '
        'Vuelve a "Libre" primero.',
      );
    }
    if (mesa.estaUnida) {
      return _fallarBool('DesUne la mesa antes de eliminarla.');
    }

    final ok = await _isar.eliminarMesa(id);
    await cargar();
    return ok;
  }

  // ── Unión de mesas ───────────────────────────────────────────────

  /// Une dos mesas: la secundaria queda enlazada a la principal.
  Future<bool> unirMesas(int idPrincipal, int idSecundaria) async {
    if (idPrincipal == idSecundaria) {
      return _fallarBool('Una mesa no puede unirse consigo misma.');
    }

    final principal = await _isar.obtenerMesaPorId(idPrincipal);
    final secundaria = await _isar.obtenerMesaPorId(idSecundaria);
    if (principal == null || secundaria == null) {
      return _fallarBool('Alguna de las mesas ya no existe.');
    }
    if (principal.estaUnida || secundaria.estaUnida) {
      return _fallarBool('Una de las mesas ya está unida a otra.');
    }
    if (principal.estado != MesaEstado.libre ||
        secundaria.estado != MesaEstado.libre) {
      return _fallarBool('Solo se pueden unir mesas libres.');
    }
    if (principal.localId != secundaria.localId) {
      return _fallarBool('No se pueden unir mesas de locales distintos.');
    }

    secundaria.unidaConMesaId = idPrincipal;
    principal.capacidad += secundaria.capacidad;
    await _isar.guardarMesa(secundaria);
    await _isar.guardarMesa(principal);
    await cargar();
    return true;
  }

  /// Rompe la unión de una mesa.
  Future<bool> desunirMesa(int id) async {
    final mesa = await _isar.obtenerMesaPorId(id);
    if (mesa == null) {
      return _fallarBool('La mesa ya no existe.');
    }
    final principalId = mesa.unidaConMesaId;
    if (principalId == null) return true;

    final principal = await _isar.obtenerMesaPorId(principalId);
    mesa.unidaConMesaId = null;
    await _isar.guardarMesa(mesa);

    if (principal != null) {
      principal.capacidad =
          (principal.capacidad - mesa.capacidad).clamp(1, 50);
      await _isar.guardarMesa(principal);
    }

    await cargar();
    return true;
  }

  // ── Utilidades ───────────────────────────────────────────────────

  int? _fallar(String mensaje) {
    debugPrint('⚠️ [Mesas] $mensaje');
    state = state.copyWith(error: mensaje);
    return null;
  }

  bool _fallarBool(String mensaje) {
    debugPrint('⚠️ [Mesas] $mensaje');
    state = state.copyWith(error: mensaje);
    return false;
  }

  void limpiarError() {
    state = state.copyWith(error: null);
  }

  /// Etiqueta legible de un estado.
  static String etiquetaEstado(MesaEstado estado) => _etiqueta(estado);
}

String _etiqueta(MesaEstado estado) {
  switch (estado) {
    case MesaEstado.libre:
      return 'Libre';
    case MesaEstado.ocupada:
      return 'Ocupada';
    case MesaEstado.reservada:
      return 'Reservada';
    case MesaEstado.porLimpiar:
      return 'Por limpiar';
  }
}

String etiquetaZona(MesaZona zona) {
  switch (zona) {
    case MesaZona.salon:
      return 'Salón';
    case MesaZona.terraza:
      return 'Terraza';
    case MesaZona.bar:
      return 'Bar';
    case MesaZona.privado:
      return 'Privado';
    case MesaZona.vip:
      return 'VIP';
  }
}

// ══════════════════════════════════════════════════════════════════
// PROVIDER
// ══════════════════════════════════════════════════════════════════

/// Mesas del local activo.
///
/// Auto-carga en el factory y se recarga solo al hacer hot-switch
/// (patrón `lotesProvider`).
final mesasProvider =
    StateNotifierProvider<MesasNotifier, MesasState>((ref) {
  return MesasNotifier(ref);
});