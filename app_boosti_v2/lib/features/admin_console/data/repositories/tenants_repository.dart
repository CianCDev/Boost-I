import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/plan.dart';
import '../models/suscripcion.dart';
import '../models/tenant.dart';

/// Repositorio de tenants (clientes) del Control Center.
///
/// Mapea la tabla `tenants`. El RLS de la tabla restringe la lectura a
/// `is_superadmin()` o al propio tenant, por lo que este repositorio
/// solo es funcional dentro del flavor admin.
class TenantsRepository {
  /// Se resuelve en cada llamada para no capturar el cliente antes de
  /// que `Supabase.initialize()` se haya ejecutado.
  SupabaseClient get _client => Supabase.instance.client;

  /// Trae el tenant con su suscripción y el plan de esa suscripción.
  ///
  /// Cadena de embeds: `suscripciones` por `tenant_id` (FK, 1:1) y
  /// `planes` por `plan_id` (FK, many-to-one).
  static const String _selectConPlan =
      '*, suscripciones(*, planes(*))';

  // ═══════════════════════════════════════════════════════════════
  // LECTURA
  // ═══════════════════════════════════════════════════════════════

  /// Lista los tenants ordenados por `created_at` DESC.
  ///
  /// Si [soloActivos] es `true` filtra por `activo = true`.
  Future<List<Tenant>> listar({bool soloActivos = true}) async {
    try {
      final base = _client.from('tenants').select('*');

      final response = soloActivos
          ? await base
              .eq('activo', true)
              .order('created_at', ascending: false)
          : await base.order('created_at', ascending: false);

      return response.map(Tenant.fromMap).toList();
    } catch (e, stack) {
      debugPrint('[TenantsRepository] Error listando tenants: $e');
      debugPrint('[TenantsRepository] Stack: $stack');
      return [];
    }
  }

  /// Obtiene un tenant por su id (UUID). Devuelve `null` si no existe.
  Future<Tenant?> obtenerPorId(String id) async {
    try {
      final response =
          await _client.from('tenants').select('*').eq('id', id).maybeSingle();

      if (response == null) {
        debugPrint('[TenantsRepository] Tenant no encontrado: $id');
        return null;
      }

      return Tenant.fromMap(response);
    } catch (e, stack) {
      debugPrint('[TenantsRepository] Error obteniendo tenant $id: $e');
      debugPrint('[TenantsRepository] Stack: $stack');
      return null;
    }
  }

  /// Busca tenants por nombre con coincidencia parcial (`ilike %query%`).
  ///
  /// Si [query] está vacío delega a [listar].
  Future<List<Tenant>> buscarPorNombre(String query) async {
    final limpio = query.trim();
    if (limpio.isEmpty) return listar();

    try {
      final response = await _client
          .from('tenants')
          .select('*')
          .ilike('nombre', '%$limpio%')
          .order('created_at', ascending: false);

      return response.map(Tenant.fromMap).toList();
    } catch (e, stack) {
      debugPrint('[TenantsRepository] Error buscando "$limpio": $e');
      debugPrint('[TenantsRepository] Stack: $stack');
      return [];
    }
  }

  /// Cuenta los tenants usando el header `Content-Range` de PostgREST
  /// (`CountOption.exact`), sin traer filas al cliente.
  Future<int> contarTotal({bool soloActivos = true}) async {
    try {
      final base = _client.from('tenants').select('id');

      final response = soloActivos
          ? await base.eq('activo', true).count(CountOption.exact)
          : await base.count(CountOption.exact);

      return response.count;
    } catch (e, stack) {
      debugPrint('[TenantsRepository] Error contando tenants: $e');
      debugPrint('[TenantsRepository] Stack: $stack');
      return 0;
    }
  }

  /// Lista los tenants con su suscripción asociada en un solo query, usando
  /// el embed de Supabase sobre la FK `suscripciones.tenant_id → tenants.id`.
  ///
  /// Cada item devuelto tiene:
  ///   - `'tenant'`: [Tenant]
  ///   - `'suscripcion'`: [Suscripcion]? (`null` si el tenant no tiene)
  ///   - `'plan'`: [Plan]? (`null` si no hay suscripción o su plan no existe)
  ///
  /// `suscripciones.tenant_id` tiene índice UNIQUE, así que la relación es
  /// 1:1. Aun así [_normalizarEmbed] tolera las dos formas en las que
  /// PostgREST puede serializar un embed (objeto o array de 1) para no
  /// romper si la detección one-to-one cambia entre versiones.
  Future<List<Map<String, dynamic>>> listarConSuscripcion({
    bool soloActivos = false,
  }) async {
    try {
      final base = _client.from('tenants').select(_selectConPlan);

      final response = soloActivos
          ? await base
              .eq('activo', true)
              .order('created_at', ascending: false)
          : await base.order('created_at', ascending: false);

      return response
          .map(
            (row) {
              final subMap = _normalizarEmbed(row['suscripciones']);
              return {
                'tenant': Tenant.fromMap(row),
                'suscripcion': subMap == null
                    ? null
                    : Suscripcion.fromMap(subMap),
                // `planes` cuelga de la suscripción (plan_id → planes.id).
                'plan': subMap == null
                    ? null
                    : _extraerPlan(subMap['planes']),
              };
            },
          )
          .toList();
    } catch (e, stack) {
      debugPrint(
        '[TenantsRepository] Error listando tenants con suscripción: $e',
      );
      debugPrint('[TenantsRepository] Stack: $stack');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILIDADES
  // ═══════════════════════════════════════════════════════════════

  /// Reduce un embed de PostgREST a un único Map.
  ///
  /// Con UNIQUE en `tenant_id` la relación es 1:1, pero PostgREST puede
  /// devolver un objeto o un array según la versión. Se aceptan ambos.
  Map<String, dynamic>? _normalizarEmbed(dynamic data) {
    if (data == null) return null;

    if (data is List) {
      if (data.isEmpty) return null;
      data = data.first;
    }

    if (data is Map<String, dynamic>) return data;
    return null;
  }

  /// Extrae el plan anidado dentro del embed de la suscripción.
  ///
  /// `suscripciones.plan_id → planes.id` es many-to-one, así que PostgREST
  /// debería devolver un objeto, pero se tolera el array por si acaso.
  Plan? _extraerPlan(dynamic data) {
    final map = _normalizarEmbed(data);
    if (map == null) return null;
    return Plan.fromMap(map);
  }
}
