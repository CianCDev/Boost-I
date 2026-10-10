import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/plan.dart';

/// Repositorio de planes comerciales del Control Center.
///
/// Mapea la tabla `planes`, cuya PK `id` es TEXT (no UUID) y no la
/// genera la base: el id se envía siempre desde la app.
///
/// El RLS limita la escritura a `is_superadmin()`, por eso este
/// repositorio solo es funcional dentro del flavor admin.
class PlansRepository {
  /// Se resuelve en cada llamada para no capturar el cliente antes de
  /// que `Supabase.initialize()` se haya ejecutado.
  SupabaseClient get _client => Supabase.instance.client;

  // ═══════════════════════════════════════════════════════════════
  // LECTURA
  // ═══════════════════════════════════════════════════════════════

  /// Lista todos los planes (activos e inactivos) ordenados por `orden` ASC.
  Future<List<Plan>> listarTodos() async {
    try {
      final response = await _client
          .from('planes')
          .select('*')
          .order('orden', ascending: true);

      return response.map(Plan.fromMap).toList();
    } catch (e, stack) {
      debugPrint('[PlansRepository] Error listando planes: $e');
      debugPrint('[PlansRepository] Stack: $stack');
      return [];
    }
  }

  /// Lista solo los planes con `activo = true`, ordenados por `orden` ASC.
  Future<List<Plan>> listarActivos() async {
    try {
      final response = await _client
          .from('planes')
          .select('*')
          .eq('activo', true)
          .order('orden', ascending: true);

      return response.map(Plan.fromMap).toList();
    } catch (e, stack) {
      debugPrint('[PlansRepository] Error listando planes activos: $e');
      debugPrint('[PlansRepository] Stack: $stack');
      return [];
    }
  }

  /// Obtiene un plan por su id (TEXT). Devuelve `null` si no existe.
  Future<Plan?> obtenerPorId(String id) async {
    try {
      final response = await _client
          .from('planes')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        debugPrint('[PlansRepository] Plan no encontrado: $id');
        return null;
      }

      return Plan.fromMap(response);
    } catch (e, stack) {
      debugPrint('[PlansRepository] Error obteniendo plan $id: $e');
      debugPrint('[PlansRepository] Stack: $stack');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ESCRITURA
  // ═══════════════════════════════════════════════════════════════

  /// Crea un plan nuevo.
  ///
  /// El [id] es la PK de tipo TEXT y **no** lo genera la base, así que
  /// debe enviarse siempre (slug corto tipo `basico`, `pro`).
  ///
  /// Lanza [Exception] si falla, incluido el caso de id duplicado.
  Future<Plan> crear({
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
  }) async {
    try {
      // TEXT[] y JSONB se envían como List<String> y Map<String, dynamic>
      // directos: PostgREST los serializa al tipo de la columna.
      final payload = {
        'id': id,
        'nombre': nombre,
        'descripcion': descripcion,
        'precio_mensual': precioMensual,
        'precio_anual': precioAnual,
        'moneda': moneda,
        'max_locales': maxLocales,
        'max_usuarios': maxUsuarios,
        'modos_habilitados': modosHabilitados,
        'features': features,
        'activo': activo,
        'orden': orden,
      };

      // `.select()` pide la fila devuelta (Prefer: return=representation),
      // así no hace falta un segundo query.
      final response =
          await _client.from('planes').insert(payload).select().single();

      debugPrint('[PlansRepository] Plan creado: $id');
      return Plan.fromMap(response);
    } catch (e, stack) {
      debugPrint('[PlansRepository] Error creando plan $id: $e');
      debugPrint('[PlansRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo crear el plan "$id": $e'),
        stack,
      );
    }
  }

  /// Actualiza un plan existente.
  ///
  /// Solo se envían los campos no-null: pasar `null` deja la columna
  /// intacta. Ojo: eso impide limpiar un campo a `null` (por ejemplo
  /// `descripcion`), que requeriría un método aparte.
  ///
  /// Lanza [Exception] si el plan no existe o si falla el update.
  Future<Plan> actualizar({
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
  }) async {
    try {
      final payload = <String, dynamic>{
        if (nombre != null) 'nombre': nombre,
        if (descripcion != null) 'descripcion': descripcion,
        if (precioMensual != null) 'precio_mensual': precioMensual,
        if (precioAnual != null) 'precio_anual': precioAnual,
        if (moneda != null) 'moneda': moneda,
        if (maxLocales != null) 'max_locales': maxLocales,
        if (maxUsuarios != null) 'max_usuarios': maxUsuarios,
        if (modosHabilitados != null)
          'modos_habilitados': modosHabilitados,
        if (features != null) 'features': features,
        if (activo != null) 'activo': activo,
        if (orden != null) 'orden': orden,
        'updated_at': _ahoraIso(),
      };

      final response = await _client
          .from('planes')
          .update(payload)
          .eq('id', id)
          .select()
          .maybeSingle();

      if (response == null) {
        debugPrint('[PlansRepository] Plan no encontrado para actualizar: $id');
        Error.throwWithStackTrace(
          Exception('El plan "$id" no existe'),
          StackTrace.current,
        );
      }

      debugPrint('[PlansRepository] Plan actualizado: $id');
      return Plan.fromMap(response);
    } catch (e, stack) {
      debugPrint('[PlansRepository] Error actualizando plan $id: $e');
      debugPrint('[PlansRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo actualizar el plan "$id": $e'),
        stack,
      );
    }
  }

  /// Alterna el estado activo/inactivo de un plan.
  ///
  /// Lanza [Exception] si el plan no existe o si falla el update.
  Future<void> toggleActivo(String id, bool activo) async {
    try {
      final response = await _client
          .from('planes')
          .update({'activo': activo, 'updated_at': _ahoraIso()})
          .eq('id', id)
          .select('id');

      if (response.isEmpty) {
        debugPrint('[PlansRepository] Plan no encontrado: $id');
        Error.throwWithStackTrace(
          Exception('El plan "$id" no existe'),
          StackTrace.current,
        );
      }

      debugPrint('[PlansRepository] Plan $id → activo=$activo');
    } catch (e, stack) {
      debugPrint('[PlansRepository] Error en toggleActivo($id): $e');
      debugPrint('[PlansRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo cambiar el estado del plan "$id": $e'),
        stack,
      );
    }
  }

  /// Elimina un plan.
  ///
  /// Si hay suscripciones apuntando a este plan, la FK `plan_id` bloquea
  /// el borrado y la excepción se propaga. Usa [sePuedeEliminar] antes
  /// para avisar al usuario.
  Future<void> eliminar(String id) async {
    try {
      final response =
          await _client.from('planes').delete().eq('id', id).select('id');

      if (response.isEmpty) {
        debugPrint('[PlansRepository] Plan no encontrado: $id');
        Error.throwWithStackTrace(
          Exception('El plan "$id" no existe'),
          StackTrace.current,
        );
      }

      debugPrint('[PlansRepository] Plan eliminado: $id');
    } catch (e, stack) {
      debugPrint('[PlansRepository] Error eliminando plan $id: $e');
      debugPrint('[PlansRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo eliminar el plan "$id": $e'),
        stack,
      );
    }
  }

  /// `true` si el plan se puede eliminar, es decir, si ninguna
  /// suscripción lo referencia.
  ///
  /// En caso de error devuelve `false` (fail-safe: no deja offering un
  /// borrado que la FK va a rechazar).
  Future<bool> sePuedeEliminar(String id) async {
    try {
      final response = await _client
          .from('suscripciones')
          .select('id')
          .eq('plan_id', id)
          .count(CountOption.exact);

      final usado = response.count > 0;
      debugPrint(
        '[PlansRepository] Plan $id: '
        '${usado ? "en uso, no eliminable" : "eliminable"}',
      );
      return !usado;
    } catch (e, stack) {
      debugPrint('[PlansRepository] Error en sePuedeEliminar($id): $e');
      debugPrint('[PlansRepository] Stack: $stack');
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═══════════════════════════════════════════════════════════════

  String _ahoraIso() => DateTime.now().toIso8601String();
}
