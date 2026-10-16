// lib/features/pos/presentation/providers/local_actual_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/auth_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/suscripcion_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/catalog_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/inventory_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/productos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/categorias_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/marca_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/clientes/clientes_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/dashboard_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/pos_menu_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/cash_closing_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/empleados/empleados_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/telegram_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/bcv_provider.dart';
import '../utils/tenant_utils.dart';

class LocalActualNotifier extends StateNotifier<int?> {
  final Ref _ref;

  /// Isar inyectable.
  ///
  /// Antes se llamaba a `IsarService()` dentro de cada método, lo que hacía
  /// la clase **imposible de testear**: los mocks no se podían inyectar
  /// porque no pasaba por ningún provider. Ahora se puede pasar una
  /// instancia falsa desde los tests.
  final IsarService _isar;

  LocalActualNotifier(this._ref, {IsarService? isar})
      : _isar = isar ?? IsarService(),
        super(null);

  /// Último error de `setLocalActual`, o `null` si el último intento
  /// funcionó (o si aún no se intentó nada).
  ///
  /// Existe para que la UI pueda avisar al usuario en vez de dejar que
  /// el fallo se pierda en un `debugPrint`.
  String? _ultimoError;

  String? get ultimoError => _ultimoError;

  void limpiarError() => _ultimoError = null;

  /// Carga el local actual.
  ///
  /// Prioridad (de mayor a menor):
  ///   1. El local cuyo `id` coincide con `prefs['localActualId']`.
  ///   1. El local cuyo `supabaseId` coincide con el `tenant_id` del JWT.
  ///   2. El local cuyo `supabaseId` coincide con el `tenant_id` del JWT.
  ///   3. El primer local `activo = true`.
  ///
  /// ⚠️ POR QUÉ `prefs` GANA AL JWT (fix del hot-switch):
  ///
  /// El hook `custom_access_token_hook` resuelve el claim `tenant_id`
  /// desde `usuarios_locales.es_default` (o el claim temporal
  /// `active_tenant_id`). `set_active_tenant(tenant)` + `refreshSession()`
  /// reemiten el JWT con el nuevo tenant.
  ///
  /// Pero `refreshSession()` es una llamada de red: entre que el usuario
  /// elige el local y que el JWT se reemite hay una ventana en la que las
  /// dos fuentes no coinciden.
  ///
  /// La versión anterior de este comentario decía que el hook leía de
  /// `usuarios.tenant_id`, lo que era falso y hacía creer que el JWT no se
  /// podía refrescar en caliente.
  ///
  /// Por eso la ELECCIÓN EXPLÍCITA del usuario (`prefs['localActualId']`,
  /// escrita por `setLocalActual`) tiene prioridad sobre el claim.
  ///
  /// ⚠️ Cada rama hace `await` sobre Isar, así que el notifier puede
  /// haberse disposed cuando la respuesta llega (hot-switch encadenado,
  /// logout, o un `ProviderContainer` que se cierra al final de un test).
  /// Escribir `state` después de `dispose()` lanza. Por eso hay un
  /// `if (!mounted) return;` antes de CADA asignación.
  Future<void> cargarLocalActual() async {
    final prefs = await SharedPreferences.getInstance();

    // ── Prioridad 1: prefs (elección explícita del usuario) ──
    //
    // 🔴 VALIDACIÓN DE TENANT (2026-10-15)
    //
    // Antes esta rama aceptaba CUALQUIER `localActualId` guardado, sin
    // comprobar a qué tenant pertenece. `prefs` es un `int` de Isar, no
    // un uuid de Supabase: cuando el RLS de `locales` devolvió los 5
    // locales de los 5 tenants (ver `sync_service.dart:3071`), el id 1
    // —`pruebapostdeploy`— quedó guardado como "local actual" y el badge
    // del AppBar lo mostraba mientras el JWT y `locales.id` eran
    // `9c7380a4` (JAHTLABS).
    //
    // La preferencia solo es válida si su `supabaseId` es el tenant del
    // claim. Si no lo es, es residue de otro tenant: se descarta y se
    // cae a la prioridad 2, que sí usa el JWT.
    //
    // ⚠️ No rompe el hot-switch: `setLocalActual()` NO pasa por acá
    // (escribe `state` directo en el paso 3, línea ~205), y a esta
    // altura ya awaited `cambiarLocal()`, o sea el JWT ya es el nuevo.
    final tenantJwt = getTenantIdFromJWT();
    final idPreferido = prefs.getInt('localActualId');
    if (idPreferido != null) {
      final local = await _isar.obtenerLocalPorId(idPreferido);
      if (!mounted) return;
      if (local != null && local.activo) {
        final esDeOtroTenant = tenantJwt != null &&
            tenantJwt.isNotEmpty &&
            local.supabaseId != null &&
            local.supabaseId!.isNotEmpty &&
            local.supabaseId != tenantJwt;

        if (esDeOtroTenant) {
          debugPrint(
            '🔀 [localActual] prefs apunta a "${local.nombre}" '
            '(supabaseId=${local.supabaseId}), pero el claim es '
            '$tenantJwt. Se descarta la preferencia.',
          );
        } else {
          state = idPreferido;
          return;
        }
      }
    }

    // ── Prioridad 2: JWT ──
    if (tenantJwt != null && tenantJwt.isNotEmpty) {
      final local = await _isar.obtenerLocalPorSupabaseId(tenantJwt);
      if (!mounted) return;
      if (local != null && local.activo) {
        state = local.id;
        await prefs.setInt('localActualId', local.id);
        return;
      }
    }

    // ── Prioridad 3: primer activo ──
    //
    // Se filtra por el claim antes de elegir. `obtenerLocales()` no mira
    // el tenant, y en este dispositivo hay más de un local cacheado:
    // sin este filtro, un claim ilegible o ausente elegía el primero de
    // la lista y el badge mostraba el local equivocado — que es
    // justamente el síntoma que se 보고 el 2026-10-15.
    final todos = await _isar.obtenerLocales(soloActivos: true);
    if (!mounted) return;

    final locales = (tenantJwt != null && tenantJwt.isNotEmpty)
        ? todos.where((l) => l.supabaseId == tenantJwt).toList(growable: false)
        : todos;

    if (locales.isEmpty) {
      // Sin claim legible y sin local que coincida: es preferible
      // quedarse sin local activo que apuntar a otro tenant.
      if (tenantJwt != null && tenantJwt.isNotEmpty) {
        debugPrint(
          '⚠️ [localActual] Ningún local local coincide con el claim '
          '$tenantJwt. Se deja sin local activo.',
        );
        state = null;
        return;
      }
    }

    if (locales.isNotEmpty) {
      state = locales.first.id;
      // Usa el valor local, no `state!`: si el notifier se disposed entre
      // la asignación y este await, `state` puede ser null.
      await prefs.setInt('localActualId', locales.first.id);
    } else {
      state = null;
    }
  }

  /// Cambia el local activo SIN reiniciar la app (hot-switch).
  ///
  /// Secuencia:
  ///   1. Guardar el nuevo localId en prefs.
  ///   2. Cambiar el tenant en Supabase (JWT + es_default).
  ///   3. Marcar el nuevo local como activo en Isar.
  ///   4. Invalidar providers dependientes del local.
  ///   5. Actualizar el estado del provider.
  ///
  /// 🎯 FIX: eliminado el reinicio de app. La app sigue viva tras el cambio.
  Future<void> setLocalActual(int id) async {
    debugPrint('🔄 [Hot-switch] Iniciando cambio de local...');
    _ultimoError = null;

    final local = await _isar.obtenerLocalPorId(id);

    if (local == null || !local.activo) {
      const msg = 'El local seleccionado no está disponible en este '
          'dispositivo o está inactivo.';
      debugPrint('⚠️ [Hot-switch] $msg');
      _ultimoError = msg;
      return;
    }

    final supabaseId = local.supabaseId;
    if (supabaseId == null || supabaseId.isEmpty) {
      final msg = 'El local "${local.nombre}" no está sincronizado con la '
          'nube. Sincroniza e inténtalo de nuevo.';
      debugPrint('⚠️ [Hot-switch] $msg');
      _ultimoError = msg;
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('localActualId', id);
    debugPrint('✅ [Hot-switch] localActualId guardado en prefs: $id');

    // ── Paso 1: Cambiar tenant en Supabase ──
    try {
      final ok =
          await _ref.read(authProvider.notifier).cambiarLocal(supabaseId);

      if (!ok) {
        final msg = 'No se pudo cambiar el tenant en Supabase.';
        debugPrint('❌ [Hot-switch] $msg');
        _ultimoError = msg;
        return;
      }
      debugPrint('✅ [Hot-switch] Tenant cambiado en Supabase: $supabaseId');
    } catch (e) {
      final msg = 'Error cambiando el tenant: $e';
      debugPrint('❌ [Hot-switch] $msg');
      _ultimoError = msg;
      return;
    }

    // ── Paso 2: Marcar el nuevo local como activo en Isar ──
    try {
      await _isar.marcarLocalComoActivo(id);
      debugPrint('✅ [Hot-switch] Isar actualizado: local $id es el único activo');
    } catch (e) {
      final msg = 'No se pudo actualizar el local en la base local: $e';
      debugPrint('⚠️ [Hot-switch] $msg');
      _ultimoError = msg;
      return;
    }

    // ── Paso 3: Actualizar el estado del provider ──
    //
    // ⚠️ ESTE ORDEN ES CRÍTICO Y NO SE DEBE INVERTIR.
    //
    // `state = id` va ANTES de cualquier `_ref.invalidate(...)`.
    // `invalidate` provoca que los providers recreados se construyan y
    // lean `localActualProvider` en su constructor/factory. Si el estado
    // todavía fuera el viejo, leerían el local anterior.
    //
    // Sintoma observado antes de este fix: `LotesNotifier` se creaba con
    // "Cargando lotes para localId: 2" cuando se acababa de cambiar a 1.
    //
    // ⚠️ Hay dos `await` antes de aquí (`setLocalActual` y
    // `marcarLocalComoActivo`), así que el notifier puede haberse
    // disposed mientras tanto.
    if (!mounted) return;
    state = id;
    debugPrint('✅ [Hot-switch] Estado actualizado: localId=$id');

    _ultimoError = null;

    // ── Paso 4: Invalidar los providers dependientes del local ──
    //
    // ⚠️ `lotesProvider` y `mesasProvider` NO se invalidan aquí aunque
    // dependan del local: ambos tienen un `ref.listen(localActualProvider)`
    // en su propio constructor que los recarga cuando el estado cambia.
    // Invalidarlos desde fuera creaba un CICLO en el grafo de Riverpod
    // (`_debugAssertCanDependOn` recorre las suscripciones de `listen`, no
    // solo los `watch`) y disparaba `CircularDependencyError` en debug. En
    // release los asserts se eliminan, pero el ciclo provocaba doble carga
    // (una por `listen`, otra por `invalidate`).
    //
    // Patrón a seguir: si un provider necesita reaccionar al cambio de local,
    // que se suscriba con `ref.listen` desde dentro. No que le invaliden desde
    // fuera. `comandasProviderConIsar` ya lo hace así
    // (comanda_provider.dart:282).
    //
    // Catálogo y productos
    _ref.invalidate(catalogProvider);
    _ref.invalidate(productosProvider);
    _ref.invalidate(categoriasProvider);
    _ref.invalidate(marcasProvider);
    _ref.invalidate(proveedoresProvider);

    // Inventario y ventas
    _ref.invalidate(inventoryProvider);
    _ref.invalidate(pedidosListProvider);

    // Clientes y dashboard
    _ref.invalidate(clientesProvider);
    _ref.invalidate(dashboardProvider);

    // Configuración y menú
    _ref.invalidate(posMenuProvider);
    _ref.invalidate(cashClosingProvider);
    _ref.invalidate(departamentosProvider);
    _ref.invalidate(empleadosProvider);
    _ref.invalidate(telegramConfigProvider);
    _ref.invalidate(bcvProvider);

    // Negocio y suscripción
    _ref.invalidate(businessModeProvider);
    _ref.invalidate(suscripcionProvider);

    debugPrint('✅ [Hot-switch] TODOS los providers invalidados');

    // ── Paso 5: Resetear navegación a Home/Dashboard ──
    // Nota: La navegación se resetea desde el widget que llama a setLocalActual
    // usando Navigator.pushAndRemoveUntil o similar. Esto evita que el usuario
    // quede en una pantalla con datos del local anterior.
    debugPrint('✅ [Hot-switch] Navegación debe resetearse desde el caller');
    debugPrint('🎉 [Hot-switch] Completado: "${local.nombre}" ($supabaseId)');
  }
}

final localActualProvider =
    StateNotifierProvider<LocalActualNotifier, int?>((ref) {
  final notifier = LocalActualNotifier(ref);
  notifier.cargarLocalActual();
  return notifier;
});
