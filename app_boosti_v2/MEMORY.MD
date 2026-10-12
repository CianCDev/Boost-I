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

### 7. El tenant del JWT sale de `usuarios_locales.es_default`

El hook `custom_access_token_hook` (`baseline.sql:243-303`) resuelve el claim
`tenant_id` en tres pasos:

1. Si el cliente pide `active_tenant_id` en los claims, y el usuario
   tiene acceso a ese tenant, se usa ese.
2. Si no, se usa el tenant de `usuarios_locales.es_default = true`.
3. Si no, el primer tenant activo del usuario.

⚠️ **NO lee de `usuarios.tenant_id`.** La documentación anterior de este
   archivo decía eso y era falsa. El error no era académico: indujo a
   concluir que el JWT no se podía refrescar en caliente, cuando
   `set_active_tenant(p_tenant_id)` (que mueve `es_default`) +
   `refreshSession()` **sí** reemiten el JWT con el claim nuevo.

Lo que sí es real, y es lo que justifica las prioridades de abajo: entre
que `setLocalActual` escribe `prefs` (instantáneo) y que `refreshSession`
emite el JWT nuevo (red) hay una **ventana** en la que el local visible y
el tenant de la sesión no coinciden. Ahí es donde aparecen
`tenantAlineadoProvider` y el modo vista previa.

- Por eso la elección explícita del usuario (`prefs['localActualId']`, escrita por
  `setLocalActual` **antes** de pedir el cambio de tenant) tiene prioridad sobre el JWT, en
  `IsarService.obtenerLocalActivo` y en `LocalActualNotifier.cargarLocalActual`.

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

### 11. Prohibido exponer credenciales en git

- **Ningún secreto va al código ni a un `.md`.** Ni siquiera a un archivo que esté en
  `.gitignore`: eso evita que se suba, pero no que termine en un backup, en un `.bak`, o
  en la pantalla de otra persona.
- Todo valor sensible (URL de conexión, clave de API, PAT, password, DSN) vive en
  `env.json`, que además está gitignored, y se inyecta con
  `--dart-define-from-file=env.json` hacia `String.fromEnvironment`.
- **No hay cargador runtime.** `env.json` no se lee en ejecución: se compila dentro del
  binario. Consecuencia a tener presente: compilar sin el flag deja TODAS las variables
  vacías y la app arranca degradada en silencio.
- **Antes de cada commit**, revisar `git diff --cached` buscando strings que parezcan
  credenciales. Si aparece una, parar y reportar antes de continuar.
- Incidente real (2026-10-10): un `HANDOFF_CONTROL_CENTER.md` tenía un PAT `sbp_…`, una
  cadena de conexión completa de Postgres con password, y un `$env:PGPASSWORD=` con la
  contraseña en claro. GitHub push protection solo detectó **el PAT**: la cadena de
  conexión y el password habrían entrado al remoto sin aviso. **El escaneo propio tiene que
  ir más allá de lo que detecta la herramienta.**
- Rotar una credencial que estuvo en un archivo es obligatorio aunque el archivo nunca se
  haya subido: puede haberse copiado a otro lado.

#### ⚠️ Verificación obligatoria después de mover un secreto

Un `grep` con **0 resultados no prueba que el secreto se fue**: puede faltar el sitio, o
buscar el patrón equivocado. La verificación es parte del movimiento, no un paso opcional.

```powershell
grep -rn "<fragmento único del secreto>" lib/
```

Si devuelve **0 fuera de `env.json`**, está bien. Si devuelve **≥ 1**, el secreto sigue en
el fuente y el movimiento no está hecho.

⚠️ **2026-10-10, segundo incidente el mismo día:** `error_service.dart:22` tenía el DSN de
Sentry hardcodeado mientras `MEMORY.md` y `docs/TODO.md` afirmaban que ya estaba en
`env.json`. La afirmación era falsa y estuvo vigente un turno entero. **Corregido:** se
eliminó el `SentryFlutter.init` duplicado de `ErrorService.init()` (bootstrap ya
inicializa Sentry con `beforeSend`, `release` y `environment`), y ahora el DSN se lee solo
desde `String.fromEnvironment('SENTRY_DSN')` en `bootstrap.dart` §4.
**Lección:** al mover un secreto, el grep de verificación va en el mismo turno.

### 12. `cantidad_restante <= cantidad_inicial` es un invariante, no una coincidencia

- Un lote nace con `cantidad_inicial == cantidad_restante`. Cada vez que entra mercadería
  suben **los dos**; cada vez que sale, solo baja `cantidad_restante`.
- Por eso Opción A (subir `cantidad_inicial` junto con `cantidad_restante` al reponer) es
  la corrección correcta: `cantidad_inicial` deja de ser "el acta de recepción" y pasa a
  ser "lo recibido más las reposiciones". El lote es un acumulador del producto, que es lo
  que el modelo "lotes = fuente única" implica.
- **Cualquier escritor futuro de `cantidad_restante` tiene que respetar el invariante.**
  Los tres sitios que lo violaban están corregidos, pero el patrón se repite: buscar con
  `cantidadRestante\s*(\+=|-=|=)` antes de tocar un lote.
- Todavía **no hay CHECK en la BD**. Sin él, nada impide que el siguiente escritor lo
  rompa. Ver `docs/TODO.md`.


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

## Notas de entorno (harness Windows)

- **`flutter analyze` y `flutter test` hay que lanzarlos desacoplados** cuando pueden tardar más de ~5s. El harness corta el comando con *exit 255* sin dejar output, y mata el proceso hijo si se lo deja en background. El patrón que sí funciona:

  ```powershell
  $out="C:\Users\Yan\AppData\Local\Temp\opencode\out.txt"
  $a = "/c flutter analyze --no-pub > `"$out`" 2>&1"
  $p = Start-Process -FilePath "cmd.exe" -ArgumentList $a `
        -WorkingDirectory "<repo>" -WindowStyle Hidden -PassThru
  Get-Content $out      # leer el archivo: Wait-Process también se corta
  ```

- **Antes de correr la suite, matar procesos `dart` huérfanos.** Quedan de corridas previas, acumulan CPU y bloquean los locks de Isar y del pub cache:

  ```powershell
  Get-Process -Name dart,dartaotruntime -ErrorAction SilentlyContinue |
    Stop-Process -Force -ErrorAction SilentlyContinue
  ```

- **El reporter `compact` usa `\r`, no `\n`.** `Get-Content` ve 1-2 "líneas" con todo el progreso pegado atrás, así que `tail` no sirve y parece que el test no avanza. Para el progreso real hay que parsear el archivo crudo:

  ```powershell
  $raw = Get-Content $out -Raw
  $m=[regex]::Matches($raw,'\+(\d+) ~(\d+)')
  "+$($m[$m.Count-1].Groups[1].Value)"    # tests ok
  ```

- **La suite completa son ~800 tests / ~3 min.** El cierre válido es `"All tests passed!"`, o `"All other tests passed!"` cuando hubo skips. Conviene además comprobar 0 ocurrencias de `Expected:` y de `[E]`.

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
| `empleado_form_dialog` + `sync_service.dart:534` | Reincidencia del patrón "grep por nombre equivocado, conclusion falsa". Se buscó `avatarUrl` cuando el campo es `fotoUrl`; se reportó la feature de fotos como muerta cuando estaba viva en 3 pantallas y en el sync | Congelada 2026-10-10: callers comentados, botón muestra "Próximamente", subida de `foto_url` pausada. Lectura de fotos existentes intacta. **Reversible** |
| `sync_service.dart` (mapeo de `movimiento_lote`) | El mapeo Isar a Supabase estaba duplicado: `toSupabaseJson()` en la entity y el Map armado a mano en el download. Podían divergir sin que nada lo detectara | Un solo lugar: el download usa `MovimientoLoteEntity.fromSupabase(data)` |
| `sync_service.dart` (`descargarMovimientosLoteDesdeSupabase`) | Método escrito y nunca conectado: 0 callers. El historial de movimientos de lote nunca se descargaba de la nube | Conectado en `sincronizarTodo()`, despues de lotes (FK `lote_id_isar`) |
| `sync_service.dart` (nuevo `subirMovimientosLotePendientes`) | No existía método de subida: los movimientos de lote solo se leían, nunca se subían | Nuevo, con `toSupabaseJson()` como payload y marcado selectivo de `sincronizado` (solo lo que sí subió) |
| `marca_form_dialog.dart:203` | **Segundo error de grep en 2 turnos.** Se buscó `storage.from('...')` sobre líneas individuales; la llamada real está partida en 2 (`Supabase.instance.client.storage` + `.from('marcas')`). El bucket `marcas` no apareció y el bug de la URL firmada pasó un turno entero sin detectarse | Corregido 2026-10-10: `MarcaEntity.logoUrl` → `logoPath`, se guarda el path y la URL se firma al renderizar (`_SignedUrlCache` en `marcas_managment_dialog.dart`). Migración `20261010000004` limpia las URLs caducadas |
| Supabase Storage (concepto) | `createSignedUrl(path, 3600)` devuelve una URL **caducable**. Guardarla en la entity y subirla a la nube deja el objeto huérfano: existe en el bucket pero la única referencia está expirada. Solo pasaba con el bucket `marcas` (los otros 3 usan `getPublicUrl` sobre buckets públicos) | Regla: **guardar siempre el path**, firmar en el render. Cache en memoria con margen de expiración |
| `isar_service.dart:4263` (`ajustarStockDesdeEditor`) | Sumaba el delta solo sobre `cantidadRestante`, nunca sobre `cantidadInicial` → `restante > inicial`. Lotes `EDIT-` del 2026-10-08 con `inicial=100` y `restante` 512/200/150, los tres con `inicial` idéntico | Clamp de Opción A: `cantidadInicial += delta` + movimiento `'reposicion'` |
| `isar_service.dart:4345` (`devolverALote`) | Mismo patrón: `+= cantidad` sin clamp. Una devolución repetida dejaba `restante > inicial` | Clamp aplicado. Sin movimiento: la venta anulada ya dejó su rastro |
| `asignar_codigo_lote_dialog.dart:301` | Asignaba `cantidadRestante` sin tocar `cantidadInicial`: tipear más de la inicial nacía el lote ya violando el invariante | `cantidadInicial` sube a `cantidad` si queda por debajo + movimiento `'reposicion'` si la cantidad cambió |
| `movimientos_tab.dart` x2, `detalle_lote_dialog.dart` | 8 switches (color/icono/label) sin caso para `'reposicion'`; sin mapear, el movimiento nuevo salía gris con `Icons.circle_rounded` y el label crudo | Caso agregado: `Colors.lightGreen` / `Color(0xFF34D399)`, `Icons.add_shopping_cart_rounded`, "Reposición" |
| `lib/core/bootstrap.dart:91` | DSN de Sentry hardcodeado en el fuente | `String.fromEnvironment('SENTRY_DSN')`, valor movido a `env.json` |
| `2026-10-10 · error_service.dart:22` | El DSN de Sentry se volvió a hardcodear mientras los docs afirmaban que estaba en `env.json. Además `SentryFlutter.init` se llamaba DOS veces (bootstrap + ErrorService), con dos configuraciones distintas | Eliminado el init de `ErrorService.init()`; bootstrap es el único que inicializa Sentry (tiene `beforeSend`, `release`, `environment`). Verificado con grep: 0 hits en `lib/` |
| `2026-10-10 · ticket térmico con logo` | El ticket no llevaba logo del local. `TicketGenerator` es síncrono y la descarga de Storage es async | `printer_service._resolverLogoDelLocal` descarga y cachea por path, y pasa los bytes a `ticket_generator._appendLogo` (máx. 512 px; `PaperSize.mm80` = 558 dots). Fallback: logo corrupto o ausente no rompe el ticket. **Deuda:** resuelve bajo el tenant del JWT, así que el hot-switch a otro tenant deja el ticket sin logo |
| `2026-10-10 · modo vista previa cross-tenant` | El JWT y el local activo de Isar podían diferir tras un hot-switch. Las escrituras (ventas, RPCs) caían en el tenant del JWT sin aviso: una venta creada viendo "centro" con sesión de JAHTLABS se subía a JAHTLABS | `tenantAlineadoProvider` compara `getTenantIdFromJWT()` vs `localActualUuidProvider`; banner `VistaPreviaBanner` + `GuardTenantActivo` en 4 botones críticos (cobrar, descuento, crear pedido, activar lote). **"Cambiar de cuenta" → `_realinarTenant`, NO `logout()`:** `AuthNotifier.logout()` preserva la sesión de Supabase a propósito (varios cajeros comparten tablet), así que no reemitiría el JWT. **Hallazgo:** §7 decía que el hook lee `usuarios.tenant_id`; es falso, lee `usuarios_locales.es_default`. Corregido |
| `android/app/build.gradle` | `applicationId` y `app_name` de ejemplo (`com.tuempresa.tuapp.*`, "TuApp") | Flavor client → `com.jahtlabs.boostipos.client` / "Boosti POS"; admin → `...admin` / "Boosti POS Admin" |
| `docs/HANDOFF_CONTROL_CENTER.md` | PAT de Supabase, cadena de conexión de Postgres con password y `$env:PGPASSWORD` en texto plano. GitHub solo detectó el PAT | Los tres redactados; sección reescrita como "Rotar YA" con el procedimiento |
| `20261009000005_reset_inventario_pruebas.sql` | Sus 25 lotes de JAHTLABS nunca se borraron porque **la migración no se aplicó nunca** | Pendiente: aplicarla con la app cerrada, antes de `00006` |
| `assets/logo.svg` | Duplicado **byte a byte** de `logoboosti300px.svg` (mismo SHA256 `343FA29D...`, 1826 bytes). No lo usa ningún archivo y no está en `pubspec.yaml`, así que no está en el bundle. Declararlo metía una copia muerta | No declarado. Queda pendiente borrarlo o renombrarlo (`AGENTS.md` prohíbe borrar sin confirmación) |
| `.sentry-native/` | Estaba **trackeado**: `installation_id` es un identificador de máquina y los `.run/` son sesiones efímeras. `AGENTS.md §10.1` prohíbe subir identificadores | Agregado a `.gitignore` + `git rm -r --cached`. `git ls-files | grep sentry-native` → 0 |
| `CustomAppBar` (`widgets/appbar.dart`) | Se intentó agregar una variante clara (fondo blanco, contenido oscuro). El widget lo usan **~30 pantallas** y tiene el contenido hardcodeado a blanco (`foregroundColor`, `iconTheme`, `ColorFilter` del logo): tocarlo rompía las otras 30 | Revertido (`git diff` vacío). La variante clara quedó **local en `main_pos_screen.dart`**, que es la única pantalla con `extendBodyBehindAppBar: true` sobre `_WelcomeBackground` |

---

## Cierre sesión 2026-10-12

**Commit único:** `724cddf` — *feat(pos): lote acumulado de fixes de sesion - tenant, storage, logo, UI*

63 archivos: 42 modificados, 15 nuevos, 9 borrados (`.sentry-native/`). Todo verificado con
`flutter analyze` (No issues found!) y `flutter test` (800 OK, 1 skip, 0 fallos).

### Pendiente para mañana

Smoke test + inyección de datos → `docs/SMOKE_TEST_2026-10-13.md`.

### Sobre `LocalActualBadge` vs `LocalActivoChip` — no unificar

| Widget | Clickeable | Dónde | Por qué |
|---|---|---|---|
| `LocalActualBadge` | **No** | Pantallas con estado de local propio (`PedidosProveedor`) | Nació de un bug real: el selector propio de esa pantalla usaba `_localDestinoUuid` mientras el diálogo leía `localActualProvider`, así que lista y alta filtraban por locales distintos |
| `LocalActivoChip` | **Sí** | Hub de navegación sin estado propio (Menú POS) | No repite el bug porque todo lo de abajo lee `localActualProvider`: no hay segunda fuente que pueda divergir |

El docstring de `LocalActualBadge` dice "deliberadamente NO es pulsable", lo que parece
contradecir al chip nuevo. **No lo contradice**: la prohibición era para pantallas con
doble fuente de verdad, no para el hub. Unificarlos en un widget parametrizado
(`accionable: bool`) haría esa distinción explícita en el código en vez de implícita en
la elección del archivo.

### Sobre el `isLoading` de `productos_provider.dart`

Cierra el caso "Isar devuelve vacío". **No verificado en device.** Si el síntoma real
era "datos presentes en Isar pero no aparecen", este fix no lo resuelve y el ítem 6.5
del smoke test va a fallar. El paso 2.5 del smoke test registra el síntoma exacto para
no volver a diagnosticar a ciegas.