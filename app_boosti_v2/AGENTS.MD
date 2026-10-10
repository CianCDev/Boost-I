# AGENTS.md — Reglas para agentes IA trabajando en Boosti POS

> Este documento define las reglas de engagement, convenciones de código y
> workflows esperados al modificar el repositorio. Cualquier agente IA
> (Copilot, Cursor, Claude Code, etc.) debe leerlo antes de hacer cambios.

## 1. Filosofía del proyecto

Boosti POS es un sistema POS offline-first multi-tenant. Los clientes
(tenants) son dueños absolutos de sus datos operativos. **La privacidad y
la inmutabilidad de datos son requisitos no negociables**.

- **Offline-first**: la app funciona sin internet. El sync con Supabase
  es eventual.
- **Multi-tenant**: cada local (tenant) tiene datos aislados por RLS.
- **Multi-modo**: cada local opera en `mercado`, `restaurante` o `servicios`.
- **Auditable**: toda acción sensible queda registrada.

## 2. Reglas de engagement para agentes IA

### 2.1. Antes de editar

1. **Lee siempre antes de editar.** Si vas a modificar un archivo, primero
   léelo para confirmar su estado real.
2. **Si un `Edit` falla una vez, NO reintentes con el mismo `oldString`.**
   Lee el archivo y reporta el estado actual.
3. **Máximo 2 intentos de Edit por línea.** Al segundo fallo, para y reporta.
4. **Usa `oldString` mínimos.** Prefiere 1-2 líneas sobre bloques grandes.

### 2.2. Al reportar

1. **Nunca digas "listo" sin haber corrido `flutter analyze`.**
2. Si `flutter analyze` tiene errores, para y reporta.
3. Los warnings (`unused_import`, `unused_field`) son aceptables pero
   debes listarlos.
4. Si un cambio puede romper algo, dilo ANTES de aplicarlo.

### 2.3. Qué NO hacer sin autorización explícita

- ❌ **Borrar archivos** (solo renombrar a `.bak` o comentar).
- ❌ **Refactorizar código no relacionado** con la tarea.
- ❌ **Cambiar la estructura de entidades Isar** existentes.
- ❌ **Modificar RLS de Supabase** (eso es manual del owner).
- ❌ **Añadir dependencias** sin consultar.
- ❌ **Rename de métodos públicos** de servicios clave.
- ❌ **Touch `main.dart`** sin autorización.
- ❌ **Modificar `SyncService`** sin contexto completo.

## 3. Reglas de datos — INMUTABILIDAD

### 3.1. Entidades inmutables

Estas entidades **no pueden ser editadas ni eliminadas** (ni por admin
del tenant ni por super admin):

| Entidad | Isar | Supabase |
|---------|------|----------|
| Ventas | Solo INSERT | Solo INSERT + SELECT |
| Detalle de ventas | Solo INSERT | Solo INSERT + SELECT |
| Movimientos de inventario | Solo INSERT | Solo INSERT + SELECT |
| Pagos de venta | Solo INSERT | Solo INSERT + SELECT |
| Logs de auditoría | Solo INSERT | Solo INSERT + SELECT |

**Anulación**: se hace por **contra-registro** (`VentaAnuladaEntity`,
`GastoAnuladoEntity`), nunca editando el original.

### 3.2. Entidades con ventana de edición

| Entidad | Ventana | Comportamiento |
|---------|---------|----------------|
| Gastos | 24h | Editable durante 24h, después inmutable |
| Turnos | Hasta cierre | Editable hasta `fechaCierre`, después inmutable |

### 3.3. Verificación antes de escribir métodos de edición

Antes de añadir un método `actualizarX` o `eliminarX` en `IsarService`:

1. Verifica si la entidad es inmutable (tabla 3.1).
2. Si es inmutable, **no añadas el método**. Usa contra-registros.
3. Si es editable, verifica la ventana.

## 4. Estructura del proyecto

```
lib/
├── core/
│   ├── config/          → supabase_config, env vars
│   ├── network/         → hardware gateway
│   └── security/        → telegram_crypto
├── features/pos/
│   ├── data/Local/entities/     → Isar entities + .g.dart
│   ├── data/remote/             → repositorios Supabase
│   ├── domain/                  → modelos, permisos, feature flags
│   └── presentation/
│       ├── providers/           → Riverpod
│       ├── screens/             → UI
│       ├── services/            → lógica de negocio
│       ├── widgets/             → componentes
│       └── utils/               → helpers
└── main.dart
```

## 5. Convenciones de código

### 5.1. Entidades Isar

```dart
import 'package:isar/isar.dart';

part 'mi_entidad.g.dart';   // ⚠️ part con el nombre completo del archivo

@collection
class MiEntidad {
  Id id = Isar.autoIncrement;
  // ...
  @ignore
  Map<String, dynamic> get miHelper => ...;  // helpers van con @ignore
}
```

**Regla**: el `part` siempre debe coincidir con el nombre del archivo +
`.g.dart`.

### 5.2. Providers Riverpod

- **`Provider`**: dependencias puras (servicios, repositorios).
- **`FutureProvider`**: fetch asíncrono cacheado.
- **`StreamProvider`**: escucha reactiva de Isar o Supabase.
- **`StateNotifierProvider`**: estado mutable complejo.
- **`StateProvider`**: estado simple (contadores, filtros).

**Nunca** uses `invalidate` sobre `StateNotifier` — pierde estado interno.
Llama a un método `.refrescar()` del notifier.

### 5.3. Servicios

- Un servicio = una responsabilidad. `SyncService` sincroniza.
  `VentaAnulacionService` anula. No mezcles.
- Los servicios públicos deben tener métodos pequeños y enfocados.
- Los métodos privados van con prefijo `_`.

### 5.4. Sync con Supabase

- **Anti-eco**: toda tabla que se suba debe tener un flag `_escribiendoX`
  que bloquee los eventos realtime mientras escribimos.
- **Last-Write-Wins**: usa `updated_at` para resolver conflictos.
- **Nunca envíes `updated_at` desde el cliente** en tablas con trigger
  server-side (usuarios, locales).
- **Debounce** de 5s en realtime para agrupar ráfagas.

### 5.5. UI

- `ResponsiveHelper.isMobile/isTablet/isDesktop` para layouts.
- Componentes reutilizables en `widgets/common/`.
- Diálogos con `GlassDialog` + `DialogHeader` + `FormActions`.
- Cards con `GlassCard` o `PosMenuCard`.
- Hover con `MouseRegion` + `AnimatedContainer` (200ms, easeOutCubic).

## 6. Modo de negocio (business mode)

### 6.1. Modos soportados

- `mercado` — default, retail.
- `restaurante` — mesas, comandas.
- `servicios` — citas, profesionales.

### 6.2. Reglas

- Vive en `LocalEntity.businessMode` + `locales.business_mode`.
- **Solo admin** puede cambiarlo.
- `featureFlagsProvider` deriva el modo + el plan y expone getters.
- **Nunca** hagas `if (mode == 'restaurante')` directo en UI.
  Usa `flags.mostrarMesas`, `flags.requiereMesa`, etc.

## 7. Super admin / Dev Mode

### 7.1. Principios

- **NO acceso a datos operativos del tenant** (ventas, gastos, productos).
- **Solo metadata contractual** (nombre, RIF, plan, estado).
- **Read-only** sobre datos del tenant.
- **Auditoría obligatoria** de cada acción.
- **Sin impersonación**.

### 7.2. Cómo verificar is_super_admin

- En Supabase: `SELECT is_super_admin();`
- En Dart: `ref.read(superAdminProvider)` (a futuro).
- El JWT debe tener el claim correspondiente.

### 7.3. Nunca añadas policies RLS permisivas

Si un super admin necesita algo, se hace vía **RPC con validación
explícita**, no vía policy abierta.

## 8. Comandos útiles

```bash
# Análisis estático
flutter analyze

# Regenerar código Isar
dart run build_runner build --delete-conflicting-outputs

# Limpiar
flutter clean

# Release Android (Shorebird)
shorebird release android

# Release Windows (Shorebird + Inno)
shorebird release windows
dart run inno_bundle --no-app --release

# Parche OTA
shorebird patch android --release-version=X.Y.Z+B
```

## 9. Errores comunes y cómo evitarlos

| Error | Causa | Solución |
|-------|-------|----------|
| `referenced_before_declaration` | Uso antes de declarar | Mover declaración arriba |
| `undefined_getter` en Isar | Falta `part` o schema no registrado | Verificar `part` + `Isar.open` |
| `Edit` falla con oldString | Whitespace invisible | Leer archivo y reportar |
| `SyncService` en bucle | Anti-eco mal puesto | Verificar `_escribiendoX` |
| `Realtime` no dispara | Tabla no suscrita | Añadir `_suscribirATabla` |
| RLS bloquea 42501 | Sin JWT o policy mal | Verificar `current_tenant_id()` |

## 10. Git y versionado

- **Nunca** subas `env.json`, `.env`, `sentry.properties`, o
  `key.properties`.
- Los `.g.dart` **sí** se suban (son necesarios para compilar).
- Bump de versión en `pubspec.yaml` **antes** de cada release.
- Un commit por feature/refactor. Mensajes en español.

## 11. Contacto

Yan Camacaro — camacaroyan@gmail.com — JAHTLABS

---

## 13. Actualizaciones desde 2026-09-30

> Este delta documenta los cambios arquitectónicos posteriores a la
> generación inicial del inventario. Para regenerar el inventario
> completo, correr el script correspondiente.

### 13.1. Nuevas entidades Isar

#### `plan_entity.dart`
- **Tipos**: `PlanEntity`
- **Campos**: planId, nombre, descripcion, precioMensual, precioAnual,
  modosHabilitados (`List<String>`), featuresJson, orden, updatedAt
- **Helpers**: `featuresMap`, `tieneFeature(String)`, `fromSupabase()`
- **Caché local** de la tabla `planes` de Supabase.

#### `suscripcion_entity.dart`
- **Tipos**: `SuscripcionEntity`
- **Campos**: tenantId, planId, estado, trialHasta, periodoInicio,
  periodoFin, addonsActivosJson, verificadoEn, updatedAt
- **Helpers**: `activa` (getter bool), `addonsMap`, `fromSupabase()`
- **Caché local** de la tabla `suscripciones` de Supabase.

#### `venta_anulada_entity.dart`
- **Tipos**: `VentaAnuladaEntity`
- **Campos**: ventaIdOriginal, tenantId, motivo, usuarioId, usuarioNombre,
  usuarioRol, fechaAnulacion, montoOriginal, sincronizado,
  fechaSincronizacion
- **Propósito**: registrar anulaciones de ventas sin tocar la venta original.

#### `gasto_anulado_entity.dart`
- **Tipos**: `GastoAnuladoEntity`
- **Campos**: gastoIdOriginal, tenantId, motivo, usuarioId, usuarioNombre,
  fechaAnulacion, montoOriginal, sincronizado, fechaSincronizacion
- **Propósito**: registrar anulaciones de gastos.

#### Cambios en `local_entity.dart`
- **Nuevos campos**: `businessMode` (String, default 'mercado'),
  `modoConfiguradoEn` (DateTime?), `planIdCache`, `planVerificadoEn`.

### 13.2. Nuevos providers

- **`business_mode_provider.dart`**: `BusinessModeNotifier`, enum
  `BusinessMode`, clase `FeatureFlags`, `businessModeProvider`,
  `featureFlagsProvider`.
- **`suscripcion_provider.dart`**: `SuscripcionesRepository`,
  `planesProvider`, `planPorIdProvider`, `suscripcionProvider`,
  `suscripcionRefreshProvider`.

### 13.3. Nuevos servicios

- **`venta_anulacion_service.dart`**: `VentaAnulacionService`,
  `ventaAnulacionServiceProvider`. Orquesta anulación + contra-movimientos
  de stock.

### 13.4. Nuevas pantallas

- **`seleccionar_modo_negocio_screen.dart`**: onboarding de modo de negocio.
- **`configuracion_modo_negocio_screen.dart`**: cambio de modo desde Settings.

### 13.5. Nuevos widgets

- **`widgets/business_mode/modo_negocio_card.dart`**: card reutilizable
  del modo de negocio, usado en onboarding + settings.

### 13.6. Cambios en `SyncService`

- **Nuevo flag anti-eco**: `_escribiendoLocales`.
- **Nuevo callback**: `onLocalCambiado`.
- **Nueva suscripción Realtime**: tabla `locales`.
- **Nuevo handler**: `_onLocalesCambiaronDesdeNube`.
- **Sync de `business_mode`**: se sube y se lee desde Supabase.
- **Helper**: `_parseBusinessMode(dynamic)`.

### 13.7. Cambios en `sync_provider.dart`

- `onDataChanged` se mantiene igual.
- Nuevo `onLocalCambiado` que recarga `businessModeProvider`.

### 13.8. Cambios en `main_pos_screen.dart`

- `_quickItemsForRole(role, flags)` filtra por modo + plan.
- `_QuickAccessGrid` recibe `FeatureFlags`.

### 13.9. Cambios en `side_panel.dart`

- `_buildButtonList` filtra categorías por `FeatureFlags`.
- Categoría Local solo aparece si `flags.multiLocal`.
- Productos y Pedidos se ocultan en modo servicios.

### 13.10. Cambios en `menu_config.dart`

- `MenuBuilder.puedeVerOpcion(role, id, flags)` combina permisos de rol +
  feature flags.
- `_flagPermite(id, flags)` filtra por plan/modo.

### 13.11. Cambios en `user_settings_screen.dart`

- Nueva sección "Negocio" con card de modo actual.
- Botón "Cambiar modo" (solo admin).
- Diseño mejorado con blobs animados, hover cards, staggered entries.

### 13.12. Base de datos Supabase — nuevas tablas

| Tabla | Propósito |
|-------|-----------|
| `super_admins` | Super admins (dev mode) |
| `tenant_notas` | Notas internas por tenant |
| `pagos_recibidos` | Registro interno de pagos (sin factura) |
| `super_admin_audit_log` | Log de acciones del super admin |

### 13.13. Policies RLS nuevas

- **Super admin**: `super_admin_read_locales`, `super_admin_all_suscripciones`,
  `super_admin_write_planes`, `super_admin_read_log`,
  `super_admin_read_self`, `super_admin_all_pagos`,
  `super_admin_all_notas`.
- **Inmutabilidad**: se dropearon `tenant_isolation` (ALL) en ventas,
  detalle_ventas, movimientos_inventarios, pagos_ventas, gastos y
  audit_log. En su lugar hay pares SELECT + INSERT (gastos también UPDATE).
- **audit_log**: policies explícitas de bloqueo (`audit_no_delete`,
  `audit_no_update` con `qual: false`).

### 13.14. Funciones y helpers SQL

- `is_super_admin()` — valida que el JWT pertenezca a un super admin activo.
- `log_super_admin_action(accion, tenant, payload)` — RPC para loggear.
- Vista `tenant_metadata` — metadata contractual sin datos operativos.
- `modos_disponibles(tenant_id)` — devuelve array de modos habilitados.

### 13.15. Reglas de inmutabilidad — resumen

| Entidad | SELECT | INSERT | UPDATE | DELETE |
|---------|:------:|:------:|:------:|:------:|
| ventas | ✅ | ✅ | ❌ | ❌ |
| detalle_ventas | ✅ | ✅ | ❌ | ❌ |
| movimientos_inventarios | ✅ | ✅ | ❌ | ❌ |
| pagos_ventas | ✅ | ✅ | ❌ | ❌ |
| audit_log | ✅ | ✅ | ❌ | ❌ |
| gastos | ✅ | ✅ | ✅ (24h) | ❌ |

### 13.16. Datos inmutables en Isar

`IsarService` **no expone** métodos `eliminarVenta`, `actualizarVenta`,
`eliminarDetalleVenta`, `eliminarMovimiento`, `eliminarGasto`. Si necesitas
anular, usa los servicios de anulación (`VentaAnulacionService`).

### 13.17. Roadmap de implementación

| Fase | Estado |
|------|--------|
| Fase 1 — Modos de negocio | ✅ Completada |
| Fase 2 — Dev Mode Fase A (auth + tenants) | ⏳ Pendiente |
| Fase 3 — Legal & Onboarding (T&C, Privacy) | ⏳ Pendiente |
| Fase 4 — Dev Mode Fase B (detalle + plan) | ⏳ Pendiente |
| Fase 5 — Landing + Pagos + Soft launch | ⏳ Pendiente |
