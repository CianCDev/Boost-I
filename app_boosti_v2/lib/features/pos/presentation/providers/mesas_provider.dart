// lib/features/pos/presentation/providers/mesas_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/mesa_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/zona_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/seed_zonas_service.dart';

import 'local_actual_provider.dart';

// ══════════════════════════════════════════════════════════════════
// ESTADO
// ══════════════════════════════════════════════════════════════════

class MesasState {
  final List<MesaEntity> mesas;

  /// Zonas del local, ordenadas por `orden` (R.1b).
  final List<ZonaEntity> zonas;
  final bool isLoading;
  final String? error;

  /// Nombre de la zona filtrada. `null` = todas.
  ///
  /// Se filtra por NOMBRE y no por id porque el nombre es el snapshot que
  /// la mesa guarda y funciona igual offline, antes de que la zona tenga
  /// `supabaseId`.
  final String? zonaFiltro;

  /// Local dueño de las mesas cargadas. `null` = todavía no hay local.
  final int? localId;

  const MesasState({
    this.mesas = const [],
    this.zonas = const [],
    this.isLoading = true,
    this.error,
    this.zonaFiltro,
    this.localId,
  });

  MesasState copyWith({
    List<MesaEntity>? mesas,
    List<ZonaEntity>? zonas,
    bool? isLoading,
    String? error,
    String? zonaFiltro,
    bool limpiarZonaFiltro = false,
    int? localId,
    bool limpiarLocalId = false,
  }) {
    return MesasState(
      mesas: mesas ?? this.mesas,
      zonas: zonas ?? this.zonas,
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
          : mesas.where((m) => m.zonaEfectiva == zonaFiltro).toList();

  /// Nombres de zona para poblar los filtros.
  ///
  /// Si el local todavía no tiene zonas (dato previo a R.1b), se derivan
  /// de las mesas para no dejar el salón sin filtros.
  List<String> get zonasDisponibles {
    if (zonas.isNotEmpty) {
      return zonas.map((z) => z.nombre).toList(growable: false);
    }
    final nombres = mesas.map((m) => m.zonaEfectiva).toSet().toList();
    nombres.sort();
    return nombres;
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
          zonas: const [],
          isLoading: false,
          limpiarLocalId: true,
          limpiarZonaFiltro: true,
        );
        return;
      }

      var mesas = await _isar.obtenerMesasDelLocal(localId);
      var zonas = await _isar.obtenerZonasDelLocal(localId);

      // R.1b · Seed perezoso. Cubre los locales que YA eran restaurante
      // antes de este cambio y por eso nunca pasaron por `cambiarModo`:
      // sin esto no tendrían zonas y sus mesas quedarían sin nombre.
      final local = await _isar.obtenerLocalPorId(localId);
      final esRestaurante = local?.businessMode == 'restaurante';
      final faltaMigrar =
          mesas.any((m) => (m.zonaNombre ?? '').trim().isEmpty);

      if ((zonas.isEmpty && esRestaurante) || (zonas.isNotEmpty && faltaMigrar)) {
        final escribio = await const SeedZonasRestaurante()
            .sembrar(localId: localId, isarService: _isar);
        if (escribio) {
          mesas = await _isar.obtenerMesasDelLocal(localId);
          zonas = await _isar.obtenerZonasDelLocal(localId);
        }
      }

      // R.1c · La ocupación NO se sincroniza: se deriva de las comandas
      // vivas. Es la única forma de que el teléfono y el desktop coincidan
      // aunque alguien haya tocado el estado a mano en uno de los dos.
      //
      // `reservada` y `porLimpiar` son estados manuales y se respetan; solo
      // se alterna entre `libre` y `ocupada`.
      for (final mesa in mesas) {
        final viva = await _isar.obtenerComandaVivaDeMesa(mesa.id);
        final MesaEstado esperado;
        if (viva != null) {
          esperado = MesaEstado.ocupada;
        } else if (mesa.estado == MesaEstado.ocupada) {
          esperado = MesaEstado.libre;
        } else {
          esperado = mesa.estado;
        }
        if (esperado == mesa.estado) continue;

        mesa.estado = esperado;
        mesa.ocupadaDesde =
            esperado == MesaEstado.ocupada ? DateTime.now() : null;
        await _isar.guardarMesa(mesa, marcarPendiente: false);
      }

      state = state.copyWith(
        mesas: mesas,
        zonas: zonas,
        isLoading: false,
        localId: localId,
      );
    } catch (e) {
      debugPrint('❌ [Mesas] Error cargando: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Cambia el filtro de zona. `null` = mostrar todas.
  void filtrarPorZona(String? zona) {
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
    String? zonaNombre,
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

      final zona = await _resolverZona(localId, zonaNombre);
      final mesa = MesaEntity()
        ..localId = localId
        ..nombre = nombreLimpio
        ..zona = _zonaLegacyDesdeNombre(zona.nombre)
        ..zonaNombre = zona.nombre
        ..zonaSupabaseId = zona.supabaseId
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
    secundaria.unidaConMesaSupabaseId = principal.supabaseId;
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
    mesa.unidaConMesaSupabaseId = null;
    await _isar.guardarMesa(mesa);

    if (principal != null) {
      principal.capacidad =
          (principal.capacidad - mesa.capacidad).clamp(1, 50);
      await _isar.guardarMesa(principal);
    }

    await cargar();
    return true;
  }

  // ── Zonas (R.1b) ─────────────────────────────────────────────────

  /// Crea una zona nueva en el local activo.
  ///
  /// Devuelve el id creado o `null` si falló (sin local, nombre vacío o
  /// duplicado). El motivo queda en `state.error`.
  Future<int?> crearZona({required String nombre}) async {
    try {
      final localId = _ref.read(localActualProvider);
      if (localId == null) {
        return _fallar('No hay local activo. Selecciona un local primero.');
      }
      final nombreLimpio = nombre.trim();
      if (nombreLimpio.isEmpty) {
        return _fallar('El nombre de la zona no puede estar vacío.');
      }

      final clave = '$localId::$nombreLimpio';
      if (await _isar.existeZonaConClave(clave)) {
        return _fallar('Ya existe una zona llamada "$nombreLimpio".');
      }

      final zona = ZonaEntity()
        ..localId = localId
        ..nombre = nombreLimpio
        ..orden = state.zonas.length
        ..activo = true
        ..sincronizado = false;

      final id = await _isar.guardarZona(zona);
      await cargar();
      return id;
    } catch (e) {
      debugPrint('❌ [Mesas] Error creando zona: $e');
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Renombra una zona y actualiza el snapshot de sus mesas.
  ///
  /// La cascada es obligatoria: la mesa guarda el NOMBRE de la zona, no
  /// un id. Sin esto, renombrar "Salón" a "Piso 1" dejaría las mesas
  /// apuntando a una zona que ya no existe.
  Future<bool> renombrarZona(int id, String nuevoNombre) async {
    try {
      final zona = await _isar.obtenerZonaPorId(id);
      if (zona == null) return _fallarBool('La zona ya no existe.');

      final nombreLimpio = nuevoNombre.trim();
      if (nombreLimpio.isEmpty) {
        return _fallarBool('El nombre de la zona no puede estar vacío.');
      }

      final clave = '${zona.localId}::$nombreLimpio';
      if (await _isar.existeZonaConClave(clave, excluirId: id)) {
        return _fallarBool('Ya existe una zona llamada "$nombreLimpio".');
      }

      final anterior = zona.nombre;
      zona.nombre = nombreLimpio;
      await _isar.guardarZona(zona);

      for (final mesa in state.mesas) {
        if (mesa.zonaEfectiva != anterior) continue;
        mesa
          ..zonaNombre = nombreLimpio
          ..zonaSupabaseId = zona.supabaseId
          ..zona = _zonaLegacyDesdeNombre(nombreLimpio);
        await _isar.guardarMesa(mesa);
      }

      await cargar();
      return true;
    } catch (e) {
      debugPrint('❌ [Mesas] Error renombrando zona: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Elimina una zona. Solo si ninguna mesa la está usando y si no es la
  /// última: un local sin zonas deja el salón sin filtros.
  Future<bool> eliminarZona(int id) async {
    try {
      final zona = await _isar.obtenerZonaPorId(id);
      if (zona == null) return _fallarBool('La zona ya no existe.');

      if (state.zonas.length <= 1) {
        return _fallarBool('Debe quedar al menos una zona.');
      }
      final enUso = state.mesas.any((m) => m.zonaEfectiva == zona.nombre);
      if (enUso) {
        return _fallarBool(
          'No se puede eliminar "${zona.nombre}": tiene mesas asignadas. '
          'Muévelas a otra zona primero.',
        );
      }

      final ok = await _isar.eliminarZona(id);
      await cargar();
      return ok;
    } catch (e) {
      debugPrint('❌ [Mesas] Error eliminando zona: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Reordena las zonas según la lista de ids recibida.
  Future<bool> reordenarZonas(List<int> idsEnOrden) async {
    try {
      for (var i = 0; i < idsEnOrden.length; i++) {
        final zona = await _isar.obtenerZonaPorId(idsEnOrden[i]);
        if (zona == null) continue;
        zona.orden = i;
        await _isar.guardarZona(zona);
      }
      await cargar();
      return true;
    } catch (e) {
      debugPrint('❌ [Mesas] Error reordenando zonas: $e');
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Devuelve la zona pedida, la primera disponible o crea "Salón" si el
  /// local todavía no tiene ninguna.
  Future<ZonaEntity> _resolverZona(int localId, String? nombre) async {
    final buscado = (nombre ?? '').trim();
    if (buscado.isNotEmpty) {
      for (final zona in state.zonas) {
        if (zona.nombre == buscado) return zona;
      }
    }
    if (state.zonas.isNotEmpty) return state.zonas.first;

    final nueva = ZonaEntity()
      ..localId = localId
      ..nombre = 'Salón'
      ..orden = 0
      ..activo = true
      ..sincronizado = false;
    await _isar.guardarZona(nueva);
    return nueva;
  }

  /// Mapea un nombre de zona al enum legacy para no dejar `zona` en un
  /// valor incoherente mientras convivan ambos campos.
  MesaZona _zonaLegacyDesdeNombre(String nombre) =>
      mesaZonaDesdeNombre(nombre);

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

String etiquetaZona(MesaZona zona) => etiquetaZonaLegacy(zona);

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