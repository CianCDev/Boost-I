// lib/features/pos/data/remote/suscripciones_repository.dart
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Local/entities/isar_service.dart';
import '../Local/entities/plan_entity.dart';
import '../Local/entities/suscripcion_entity.dart';

/// Repositorio que centraliza el acceso a `planes` y `suscripciones` en
/// Supabase + la caché local en Isar.
///
/// Patrón:
///   1. Intentar leer desde Isar (rápido, offline-friendly).
///   2. Refrescar desde Supabase en background si hay red.
///   3. Actualizar la caché local con lo último.
class SuscripcionesRepository {
  final IsarService _isarService = IsarService();

  // ══════════════════════════════════════════════════════════════
  // PLANES
  // ══════════════════════════════════════════════════════════════

  /// Devuelve los planes cacheados en Isar.
  /// Si no hay caché, devuelve lista vacía.
  Future<List<PlanEntity>> obtenerPlanesLocal() async {
    final isar = await _isarService.db;
    return isar.planEntitys.where().sortByOrden().findAll();
  }

  /// Descarga los planes desde Supabase y actualiza la caché local.
  /// Retorna los planes descargados.
  Future<List<PlanEntity>> descargarPlanesDesdeSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('planes')
          .select()
          .eq('activo', true)
          .order('orden', ascending: true);

      final planes = (response as List)
          .map((json) => PlanEntity.fromSupabase(json as Map<String, dynamic>))
          .toList();

      // Persistir en Isar
      final isar = await _isarService.db;
      await isar.writeTxn(() async {
        // Estrategia: borrar los existentes y volver a insertar.
        // Son 3 planes, no hay problema de performance.
        await isar.planEntitys.clear();
        await isar.planEntitys.putAll(planes);
      });

      debugPrint('✅ [SuscripcionesRepository] ${planes.length} planes cacheados');
      return planes;
    } catch (e) {
      debugPrint('❌ [SuscripcionesRepository] Error descargando planes: $e');
      // Fallback: devolver lo que haya en caché local
      return obtenerPlanesLocal();
    }
  }

  /// Sincroniza planes: descarga desde Supabase y devuelve la lista
  /// más fresca. Si falla la red, devuelve caché local.
  Future<List<PlanEntity>> obtenerPlanes() async {
    final locales = await obtenerPlanesLocal();
    if (locales.isEmpty) {
      return descargarPlanesDesdeSupabase();
    }

    // Hay caché → devolver rápido + refrescar en background
    descargarPlanesDesdeSupabase(); // fire-and-forget
    return locales;
  }

  // ══════════════════════════════════════════════════════════════
  // SUSCRIPCIONES
  // ══════════════════════════════════════════════════════════════

  /// Devuelve la suscripción cacheada del tenant.
  Future<SuscripcionEntity?> obtenerSuscripcionLocal(String tenantId) async {
    if (tenantId.isEmpty) return null;
    final isar = await _isarService.db;
    return isar.suscripcionEntitys
        .filter()
        .tenantIdEqualTo(tenantId)
        .findFirst();
  }

  /// Descarga la suscripción del tenant desde Supabase y actualiza caché.
  Future<SuscripcionEntity?> descargarSuscripcionDesdeSupabase(
    String tenantId,
  ) async {
    if (tenantId.isEmpty) return null;

    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('suscripciones')
          .select()
          .eq('tenant_id', tenantId)
          .maybeSingle();

      if (response == null) {
        debugPrint('ℹ️ [SuscripcionesRepository] Sin suscripción para $tenantId');
        return null;
      }

      final suscripcion =
          SuscripcionEntity.fromSupabase(response)
            ..verificadoEn = DateTime.now();

      // Persistir en Isar (upsert por tenantId)
      final isar = await _isarService.db;
      final existente = await isar.suscripcionEntitys
          .filter()
          .tenantIdEqualTo(tenantId)
          .findFirst();

      if (existente != null) {
        suscripcion.id = existente.id;
      }

      await isar.writeTxn(() async {
        await isar.suscripcionEntitys.put(suscripcion);
      });

      debugPrint(
          '✅ [SuscripcionesRepository] Suscripción cacheada: ${suscripcion.planId} (${suscripcion.estado})');
      return suscripcion;
    } catch (e) {
      debugPrint('❌ [SuscripcionesRepository] Error descargando suscripción: $e');
      // Fallback: devolver lo que haya en caché
      return obtenerSuscripcionLocal(tenantId);
    }
  }

  /// Sincroniza suscripción: devuelve caché rápido + refresca en background.
  /// Si no hay caché, espera la descarga.
  Future<SuscripcionEntity?> obtenerSuscripcion(String tenantId) async {
    final local = await obtenerSuscripcionLocal(tenantId);
    if (local != null) {
      // Refrescar en background
      descargarSuscripcionDesdeSupabase(tenantId);
      return local;
    }

    // Sin caché → esperar descarga
    return descargarSuscripcionDesdeSupabase(tenantId);
  }
}