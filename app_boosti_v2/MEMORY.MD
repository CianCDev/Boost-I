# MEMORY.md

## Visión General del Proyecto
- **Nombre de la App:** `app_boosti_v2`
- **Propósito:** Sistema de gestión empresarial y punto de venta (POS) multi-tenant con soporte offline-first.
- **Arquitectura:** Clean Architecture por características (`lib/features/<módulo>/`), dividida en capas `data`, `domain` y `presentation`.

---

## Pila Técnica y Versiones Base
- **Flutter SDK:** 3.47.2 (Channel stable)
- **Dart SDK:** 3.13.2
- **Lenguaje Kotlin:** 2.1.10 (KGP)
- **Android Gradle Plugin (AGP):** 8.11.1
- **Gradle Wrapper:** 8.14.0 (`gradle-8.14-bin.zip`)
- **Java / JDK:** Java 21 (OpenJDK 21.0.2 / Android Studio JBR)
- **Target / Compile SDK:** Android API 36 (`compileSdk 36`)
- **Base de Datos Local:** Isar Database (Offline Cache)
- **Backend / Realtime:** Supabase (Auth, Postgres, Realtime Sync)
- **Gestión de Estado:** Riverpod / Notifiers

---

## Decisiones de Arquitectura y Lógica de Negocio

### 1. Estrategia Offline-First y Sincronización
- **Soft Deletes:** Las eliminaciones en la app local (ej. marcas/asistencias en `MarcasNotifier`) no hacen un `DELETE` duro inmediato en la base de datos para evitar conflictos de sincronización con Supabase. Se marca el registro con un estado `deleted` para la sincronización posterior.
- **Isar Local Caching:**
  - Las entidades Isar (`PlanEntity`, `SuscripcionEntity`, etc.) deben incluir siempre un **constructor por defecto explícito** (`Entity()`) cuando utilicen `factory constructors` como `fromSupabase`.
  - Todo `getter` que retorne un tipo de dato no nativo soportado por Isar (como `Map<String, dynamic>`) **debe incluir la anotación `@ignore`** para evitar fallos en `isar_generator`.
  - Nombre de archivos de entidades en minúsculas y `snake_case` (ej. `suscripcion_entity.dart`).

### 2. UI/UX y Componentes Reutilizables
- En `EmployeeCard` se utilizan avatares ampliados y distribución compacta para evitar *overflows* en pantallas móviles.
- Las acciones de menú emergente (*PopupMenus*) en tarjetas dentro de un `GridView` o `ListView` deben envolverse en un `Builder` con `HitTestBehavior` para prevenir el bug de "ghost click" (donde presionar el menú de la tarjeta izquierda activaba la derecha).

### 3. Estado de Riverpod — igualdad estructural es OBLIGATORIA

- **Todo `State` de un `StateNotifierProvider` debe implementar `operator ==` y `hashCode`
  estructurales.** `items` es una lista freshly-allocated en cada lectura, así que la
  identidad nunca da igual.
- Sin `==`, cada carga emite y cada emisión dispara los `ref.listen` que dependen de él.
  `catalogProvider._aplicarFiltros` e `inventoryProvider.aplicarFiltros` recorren TODOS los
  productos: 2 pasadas O(n) por carga, × 15 call sites de `cargarProductos()`.
- **Patrón: si nada cambió, no tocar `state`.** Un `copyWith(isLoading: false)` en la rama
  "sin cambios" emite un estado nuevo e inequivalente y cuesta un filtrado completo.
- Referencia: `ProductosState` recibió `==` en la sesión del 2026-10-09.
  `InventoryState` y `CatalogState` ya lo tenían; la asimetría era el bug.

### 4. N+1 de providers en listas — PROHIBIDO

- **Nunca usar un `FutureProvider.family` dentro de un `itemBuilder`.** Con 200 ítems son
  200 providers, 200 round-trips y 200 transiciones `loading → data` = ~400 rebuilds.
- Patrón correcto: un provider que lee la colección **una vez** y devuelve un `Map` para
  lookup O(1). Ver `marcaNombresPorSupabaseIdProvider`.
- La tentación de usar `FutureBuilder`/`AsyncValue.when` en un ítem es exactamente la que
  causa el problema: cada ítem gestiona su propio ciclo de carga.

### 5. Timers: nunca `Timer.periodic` con un callback async más lento que el período

- `Timer.periodic` dispara cada N segundos **sin esperar** a que termine el callback. Si el
  callback tarda más que N, se apilan requests concurrentes.
- Para trabajo async se usa un loop `while` con `await` + `Future.delayed` entre vueltas.
- Cancelar el `Timer` **no alcanza** para detener el loop: si está dentro del `await`, sigue
  vivo. Hace falta un flag explícito. Ver `TelegramService._activo`.

### 6. El plan es por TENANT, no por local

- `SuscripcionEntity.tenantId` es `@Index(unique: true)`: una suscripción por tenant.
- `LocalEntity.supabaseId` **es** el `tenant_id`. Cambiar de local cambia de tenant y, por
  lo tanto, de plan.
- **Cambiar de local nunca se gatea por plan.** Es navegación. Gatearlo crea un deadlock:
  al cambiar a un local sin plan se apaga el flag, y con él desaparecen tanto la entrada
  de menú como el botón de volver.
- Gating de módulos: `ModuleGate` a nivel de pantalla, no solo en el menú. Las pantallas se
  abren con `Navigator.push` y el gate de menú no las cubre.

### 7. Hot-switch: `prefs` gana al JWT

- El claim `tenant_id` del JWT viene de `usuarios.tenant_id` (columna fija). El RPC
  `set_active_tenant` solo mueve `usuarios_locales.es_default`, que el hook del JWT no lee.
  Es decir: `refreshSession()` devuelve **siempre** el tenant del login original.
- Por eso la elección explícita del usuario (`prefs['localActualId']`, escrita por
  `setLocalActual` **antes** de pedir el cambio de tenant) tiene prioridad sobre el JWT, en
  `IsarService.obtenerLocalActivo` y en `LocalActualNotifier.cargarLocalActual`.
- Raíz pendiente: cambiar `custom_access_token_hook` para leer `es_default`.

### 8. La tasa BCV: la fecha que cuenta es la de la tasa

- `EstadoTasa.cacheReciente` es el estado *normal* al abrir la app, porque
  `main_pos_screen._ensureFreshBcvRate` no re-consulta si la caché tiene menos de 6 h.
  Reportarlo como "sin conexión" es mentir: el dato es correcto y fresco.
- Se guarda la **fecha de la tasa** (`fechaActualizacion` de la API), no `DateTime.now()`
  del fetch. La BCV publica una vez por día: sin esto la app declara una frescura de hasta
  24 h mayor que la real.
- `BcvService` mantiene los métodos `double` por compatibilidad con los tests y agrega
  variantes con fecha. No cambiar firmas que estén cubiertas por tests: agregar al lado.

### 9. Limpieza: código inerte que miente

- `AutomaticKeepAliveClientMixin` + `wantKeepAlive` **no hacen nada** en una pantalla
  abierta con `MaterialPageRoute`. El mixin solo se consulta dentro de un `PageView` o un
  `IndexedStack`, que son los únicos que emiten `KeepAliveNotification`.
- Mantenerlos hace creer que la pantalla sobrevive al pop, lo que desincentiva buscar fugas
  reales. Se eliminaron de `InventoryCatalogScreen`.
- Mismo criterio con los doc comments que describen un comportamiento ya corregido: si
  mienten, son peores que el código muerto.

### 10. `IsarService` es un singleton de proceso — el mock no se propaga solo

- `IsarService()` devuelve un `static final _instance` (`isar_service.dart:79`). Inyectar
  un mock **por constructor en un solo notifier** no alcanza: cualquier otro provider
  que llame a `IsarService()` directo lo ignora por completo.
- **Por eso existe `isarServiceProvider`** (`clientes_provider.dart:6`): es el punto de
  inyección correcto. Un provider que necesite ser mockeable debe leer el servicio por
  ese provider, no por constructor de `IsarService()`.
- Los que NO tienen punto de inyección hay que sustituirlos en los `overrides` del
  `ProviderContainer`: `marcasProvider` (`marca_provider.dart:38`) y `empleadosProvider`
  (`empleados_provider.dart:17`) llaman `IsarService().db` directo.
- Trampa asociada: `invalidate(p)` hace que Riverpod **monte** `p` para recorrer su grafo.
  `setLocalActual()` invalida 21 providers (`local_actual_provider.dart:224-248`), así que
  un test de hot-switch los monta todos de verdad. Por eso un test que mockea Isar tiene
  que sustituir también a los providers, no solo al notifier.
- `test_helpers.dart:59-66` cierra **todas** las instancias de Isar del proceso, de forma
  global. Un archivo de test puede romper el siguiente sin tocarlo.


---

## Configuración del Entorno de Compilación (Android)

- **`android/build.gradle` (Raíz):**
  - Aplica un listener seguro vía `project.plugins.withId('com.android.library')` para forzar `compileSdk = 36` y asignar `namespace` fallback en todas las librerías/plugins de terceros, evitando errores de ciclo de vida con `afterEvaluate`.
- **`android/gradle.properties`:**
  - `android.useAndroidX=true`
  - `android.newDsl=false` (requerido para compatibilidad con las extensiones de Flutter en AGP 8.x)
  - `android.skipBuildDependencyValidation=true`
  - `android.builtInKotlin=false`

---

## Historial de Soluciones e Incompatibilidades Resueltas

| Módulo / Archivo | Problema / Error | Solución Aplicada |
| :--- | :--- | :--- |
| `android/build.gradle` | Error `Cannot run Project.afterEvaluate(Closure) when the project is already evaluated` | Reemplazado `afterEvaluate` por `plugins.withId('com.android.library')`. |
| `PlanEntity` / `SuscripcionEntity` | Error de `isar_generator` (`Unsupported type` en `addonsMap` / `featuresMap`) | Agregada la anotación `@ignore` sobre los getters calculados y añadido constructor por defecto. |
| `SuscripcionEntity.dart` | Advertencia de linter `file_names` | Renombrado el archivo a `suscripcion_entity.dart`. |
| Entorno Gradle / AGP | Desalineación de versiones entre Flutter 3.47, Java 21, AGP y Gradle | Alineado AGP a `8.11.1`, KGP a `2.1.10` y Gradle a `8.14.0`. |
| `EmployeeCard` | Overflow y evento de clic fantasma en menú desplegable | Refactorizado layout con `Builder` y optimizado espacio vertical. |
| `ProductosState` | Sin `operator ==`: cada `cargarProductos()` emitía 2 veces y disparaba 2 filtrados O(n), × 15 call sites | Añadidos `==`/`hashCode` estructurales + rama "sin cambios" que no emite |
| `marcaNombrePorSupabaseIdProvider` | `FutureProvider.family` dentro del `itemBuilder`: ~200 queries a Isar y ~400 rebuilds al abrir la grilla | Reemplazado por `marcaNombresPorSupabaseIdProvider` (un `Map`, 1 lectura) |
| `TelegramService._startPolling` | `Timer.periodic(3s)` con long-poll de hasta 15 s: 3–5 requests concurrentes permanentes | Loop secuencial con `await` + flag `_activo` |
| `InventoryCatalogScreen` | `AutomaticKeepAliveClientMixin` inerte en un route pushed (hacía creer que la pantalla sobrevivía al pop) | Mixin, `wantKeepAlive` y `super.build` eliminados, con nota explicativa |
| `BcvController` | `desdeCache` incluía `cacheReciente`/`manual` → "Sin conexión" con tasa fresca (falso positivo) | `desdeCache` = solo `cacheObsoleta`; `tasaEsManual` aparte |
| `BcvService` / `BcvController` | Se guardaba `DateTime.now()` del fetch como fecha de la tasa (hasta 24 h de frescura inventada) | Se usa `fechaActualizacion` de la API, con fallback a `DateTime.now()` |
| `obtenerLocalActivo` | Prioridad JWT > prefs: el JWT va delayed tras el hot-switch y además *reactivaba* el local que el usuario acababa de desactivar | Invertido a prefs > JWT |
| `sincronizarPedidosPendientes` | Reescribía `pedido.localOrigenId` al local activo: corrupción de origen entre locales | Eliminado; si el local no tiene UUID se omite el ciclo, nunca se reasigna |
| `TraspasoLoteDialog` | Se llamaba "Reponer" pero **bajaba** el stock; el tipo `'traspaso'` sugería mover entre lotes | Renombrado a "Dar de baja del lote", tipo `'baja'`. `'traspaso'` se conserva como histórico |
| `buscarItemIndex` | Comparaba `String == int`: siempre devolvía `-1` | Convierte a String; agregada `buscarItemIndex` correcta |