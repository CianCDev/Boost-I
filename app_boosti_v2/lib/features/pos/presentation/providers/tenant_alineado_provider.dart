// lib/features/pos/presentation/providers/tenant_alineado_provider.dart
//
// Detecta el estado "hot-switch cross-tenant": el local activo en Isar
// pertenece a un tenant distinto del que trae el JWT de la sesión.
//
// POR QUÉ EXISTE
//
// El claim `tenant_id` del JWT se genera en `custom_access_token_hook`
// (baseline.sql:243-303), que lo resuelve en este orden:
//   1. `claims->>'active_tenant_id'` — un claim temporal que el cliente
//      puede pedir al refrescar.
//   2. `usuarios_locales.es_default = true`.
//   3. El primer local activo del usuario.
//
// `set_active_tenant(p_tenant_id)` (esquema.sql:514) mueve `es_default`, así
// que **sí** cambia lo que devuelve el hook... pero SOLO si el refresco
// llega a emitir un JWT nuevo. Mientras tanto, `cargarLocalActual()`
// (`local_actual_provider.dart:83`) prioriza `prefs['localActualId']`, que
// se escribe de inmediato. Resultado: hay una ventana en la que el local
// visible es uno y el JWT sigue apuntando al anterior.
//
// En esa ventana:
//   - La lectura funciona (RLS filtra por JWT).
//   - La escritura NO: inserts y RPCs aterrizan en el tenant del JWT, no en
//     el local que el usuario está viendo. Una venta creada viendo "centro"
//     con sesión de JAHTLABS se sube como venta de JAHTLABS.
//
// QUÉ HACE ESTE PROVIDER
//
// Devuelve `true` cuando están alineados (estado normal) y `false` cuando
// no. La UI consume `tenantAlineadoProvider` para bloquear acciones de
// escritura y mostrar el banner de "modo vista previa".
//
// ⚠️ `false` NO es un error: es un estado legítimo de multi-tenant donde el
//    usuario tiene acceso a varios locales. Lo incorrecto sería dejarlo
//    escribir en el tenant equivocado sin avisar.
//
// ⚠️ Sin sesión o sin local resuelto devuelve `true`: no hay nada que
//    comparar, y bloquear la UI en ese estado dejaría la app inservible
//    durante el arranque.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locales_provider.dart';
import '../utils/tenant_utils.dart';

/// `true` cuando el tenant del JWT coincide con el tenant del local activo.
///
/// `false` = modo vista previa: la UI debe bloquear escrituras.
final tenantAlineadoProvider = Provider<bool>((ref) {
  final tenantJwt = getTenantIdFromJWT();

  // Sin claim de tenant no se puede comparar. No se bloquea.
  if (tenantJwt == null || tenantJwt.isEmpty) return true;

  // `localActualUuidProvider` es async: mientras resuelve devuelve
  // AsyncLoading, y su valor todavía no es autoritativo. Tratar el estado
  // de carga como desalineado bloquearía la UI en cada arranque.
  final localUuid = ref.watch(localActualUuidProvider);
  if (localUuid is! AsyncData<String?>) return true;

  final tenantLocal = localUuid.value;
  if (tenantLocal == null || tenantLocal.isEmpty) return true;

  // ✅ Alineado.
  return tenantLocal == tenantJwt;
});

/// Motivo legible del desalineado, para el banner y los diálogos.
///
/// Devuelve `null` cuando está alineado, así el caller puede hacer
/// `if (motivo != null)` sin repetir la comparación.
final tenantDesalineadoMotivoProvider = Provider<String?>((ref) {
  if (ref.watch(tenantAlineadoProvider)) return null;

  return 'Tu sesión pertenece a otro negocio. Lo que veas acá es de solo '
      'lectura: para operar, cerrá sesión y entrá con la cuenta de este local.';
});
