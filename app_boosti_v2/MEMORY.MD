# MEMORY.md

## Visión General del Proyecto
- **Nombre de la App:** `app_boosti_v2`
- **Propósito:** Sistema de gestión empresarial y punto de venta (POS) multi-tenant con soporte offline-first.
- **Arquitectura:** Clean Architecture por características (`lib/features/<módulo>/`), dividida en capas `data`, `domain` y `presentation`.

---

## Pila Técnica y Versiones Base
- **Flutter SDK:** 3.47.2 (Channel stable)
- **Versión de la app:** `1.1.1+7` (`pubspec.yaml`)
- **Nombre visible:** `BoostiPos` — vive en `android:label`, `inno_bundle.name`
  y 10 textos Dart. ⛔ `pubspec.yaml: name:` sigue siendo `app_boosti_v2`
  (es el paquete Dart; cambiarlo rompe todos los imports).
- **Color de marca / adaptive icon:** `#2F81D3` (era `#10B981` verde)
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
| `2026-10-12 · Logo en creación de local` | El `UPDATE locales SET logo_path` post-RPC lo rechaza `locales_tenant_update` (solo el tenant **activo**; el JWT sigue apuntando al anterior). El `_LogoField` solo se mostraba en edición. | Migración `20261012000001`: la RPC acepta `p_logo_path`. El logo entra en el mismo `INSERT`, dentro de una función `SECURITY DEFINER`, que es el único punto donde la escritura pasa. ⚠️ Requiere `DROP FUNCTION` de la firma vieja: cambiar los argumentos crea una **sobrecarga**, y PostgREST resuelve por nombre de parámetro → "function is not unique" |
| `2026-10-12 · Íconos del form de local` | `_field()` recibía `required IconData icon` y **no lo usaba**: `prefixIcon: const Icon(Icons.circle, size: 0)`. Los callers pasaban los íconos correctos y se veían planos. `analyze` no lo marca: un parámetro requerido no cuenta como código muerto | Se dibuja el ícono real. Se mantienen las variantes `_rounded` porque son las mismas que usa `detalle_local_dialog.dart`; pasarlas a `_outlined` rompía esa consistencia |
| `2026-10-12 · Arquitectura multi-local` | No hay modelo multi-sucursal: cada "local" es un tenant independiente. Tampoco hay forma de asociar un usuario a un tenant **existente**; la RPC crea tenant + asignación juntos | Se mantiene Camino A. "Código de asociación" y multi-sucursal (Camino C) quedan post-v1, documentados en `TODO.md` |
| `2026-10-12 · Versión 1.0.0+4` | Release candidate. El bump ya estaba en el working tree sin commitear | Commiteado con los cambios de locales. Tag `v1.0.0` pendiente del smoke test |
| `assets/logo.svg` | Duplicado **byte a byte** de `logoboosti300px.svg` (mismo SHA256 `343FA29D...`, 1826 bytes). No lo usa ningún archivo y no está en `pubspec.yaml`, así que no está en el bundle. Declararlo metía una copia muerta | No declarado. Queda pendiente borrarlo o renombrarlo (`AGENTS.md` prohíbe borrar sin confirmación) |
| `.sentry-native/` | Estaba **trackeado**: `installation_id` es un identificador de máquina y los `.run/` son sesiones efímeras. `AGENTS.md §10.1` prohíbe subir identificadores | Agregado a `.gitignore` + `git rm -r --cached`. `git ls-files | grep sentry-native` → 0 |
| `CustomAppBar` (`widgets/appbar.dart`) | Se intentó agregar una variante clara (fondo blanco, contenido oscuro). El widget lo usan **~30 pantallas** y tiene el contenido hardcodeado a blanco (`foregroundColor`, `iconTheme`, `ColorFilter` del logo): tocarlo rompía las otras 30 | Revertido (`git diff` vacío). La variante clara quedó **local en `main_pos_screen.dart`**, que es la única pantalla con `extendBodyBehindAppBar: true` sobre `_WelcomeBackground` |

---

## Cierre sesión 2026-10-15 — fuga cross-tenant + menú vacío

**Tags:** `v1.1.1` (`79c46e9`) · release Android `1.1.1+7` + Windows `1.1.1+7`

Cuatro fallas encadenadas hacían que el menú mostrara 9 de ~20 módulos y
que el badge del AppBar mostrara el local equivocado.

### 1. Policy de `locales` con brazo `EXISTS` no versionada

El baseline dice `USING ((id = current_tenant_id()))`. La BD tenía un
`OR EXISTS (SELECT 1 FROM usuarios_locales ul WHERE ul.usuario_id =
auth.uid() AND ul.tenant_id = locales.id …)`. Eso hace que un usuario vea
todo local del que tenga fila, no solo el del claim. **En este modelo
`locales.id` ES el `tenant_id`.**

Modificado a mano en el dashboard, sin migración → el repo y la BD
divergieron en silencio. Con el JWT de JAHTLABS se descargaron los 5
locales de 5 tenants.

**Auditoría:** el `EXISTS` solo estaba en `locales`. `ventas`,
`productos`, `pedidos`, `lotes`, `marcas`, `categorias`, `departamentos`,
`clientes` y `proveedores` usan solo `tenant_id = current_tenant_id()`.
**No hubo fuga de datos operativos**, solo de metadatos de local.

**Fix:** `20261015000001_cerrar_fuga_locales.sql`.

### 2. `planActivo` es un `&&` corto: sin suscripción no se ve nada

```dart
bool _plan(String f, {bool defaultVisible = false}) =>
    planActivo && (featuresHabilitadas.contains(f) || defaultVisible);
```

El log decía `Sin suscripción para 9c7380a4…`. `suscripciones` no está
versionada y la EF `create-tenant` solo empezó a poblarla el 2026-10-13:
**los tenants anteriores no tienen fila.** El fail-closed es correcto
para no regalar producto sin plan, pero el síntoma es un menú vacío sin
explicación en pantalla.

### 3. Las claves de `FeatureFlags` no existían en `planes.features`

La tabla tenía 4 claves y el menú consultaba ~20. Las getters huérfanas
tenían `defaultVisible: true` + `TODO(R.0)`, pero con `planActivo = false`
nunca se activaban. **Aunque se arreglara la suscripción, el Dashboard
seguiría sin aparecer.**

**Fix:** `20261015000002_plan_features.sql`. Producto: básico ve el
dashboard; básico NO ve proveedores, pedidos ni locales.

### 4. `'proveedores'` no consultaba ningún flag de plan

`menu_config.dart` tenía `'proveedores' => !flags.esServicios`, solo
modo. El plan básico veía Proveedores. Ahora usa
`flags.proveedores && !flags.esServicios` (flag nuevo).

### 5. El wipe borraba catálogo global de la plataforma

`wipeAll()` incluía `planEntitys.clear()` y `suscripcionEntitys.clear()`.
Los **planes son catálogo global**, no datos del negocio. Corregido: el
wipe ya no toca ninguna de las dos.

---

### 6. `SuscripcionEntity.activa` comparaba contra un valor imposible

El getter comparaba `estado == 'activa'` (femenino). El
`suscripciones_estado_check` solo admite:

```
('trial','activo','vencido','cancelado','expirado')
```

**`'activa'` no puede existir en la base.** El getter caía siempre en
`return false` → `planActivo = false` para **todos los tenants desde el
día uno**. Con `planActivo &&` cortocircuiteando, el POS se quedaba
vacío con la suscripción pagada y el log diciendo `pro (activo)`.

Era el bug de fondo del menú. El diagnosticado por un log nuevo:
`🔎 [featureFlags] DENEGADO · suscripcion=pro(activo) activa=false`.

### 7. `defaultVisible: true` volvía inoperante el gate por plan

```dart
planActivo && (featuresHabilitadas.contains(f) || defaultVisible)
```

Con `defaultVisible: true` el `||` es siempre verdadero: da igual si
el plan contrató la feature. **9 getters** lo usaban (dashboard,
historial de ventas, historial de gastos, proveedores, pedidos a
proveedores, departamentos, lotes, monitor, ventas al mayor).

Se justificó porque las claves no existían en `planes.features`. Ya
existen (`20261015000002`) → todos a `defaultVisible: false`.

`basico` tiene `proveedores`, `pedidos_proveedores`, `multi_local` y
`ventas_mayor` en `false`: el básico efectivamente no los ve.

⚠️ Efecto colateral: `trial` tenía `{offline, reports}` y se quedaba
**sin producto entero**. De ahí `20261015000003`, que sube `trial` al
catálogo de `basico`. Un trial es un básico con fecha de vencimiento.

### 8. `obtenerPlanes()` servía caché vieja con refresh fire-and-forget

```dart
final locales = await obtenerPlanesLocal();
if (locales.isEmpty) return descargarPlanesDesdeSupabase();
descargarPlanesDesdeSupabase(); // actualiza Isar…
return locales;                  // …pero devuelve la vieja
```

Supabase tenía **12** features en `true` y Dart veía **3** (`offline`,
`reports`, `multi_local`). `planPorIdProvider` daba esa lista por buena
toda la sesión. Ahora `obtenerPlanes()` delega en
`descargarPlanesDesdeSupabase()`, que ya cae a Isar en el `catch`.

### 9. `super_admin_read_locales` era un OR que gainsaba el gate

`locales` tenía 2 policies de SELECT y Postgres las combina con **OR**:

```
locales_tenant_select     {authenticated}  (id = current_tenant_id())  → 1
super_admin_read_locales  {public}        is_super_admin()             → todas
```

`current_tenant_id()` devolvía bien el tenant; perdía el segundo brazo.
El POS y el `admin_console` comparten `Supabase.instance.client` → mismo
JWT → el owner con `is_superadmin = true` veía los 5 locales.

Dropeada en `20261015000004`: sin consumidor (`admin_console` usa
`tenants`) y `service_role` ya bypasea RLS. Para la Subfase 3.3.3 del
Control Center: RPC `SECURITY DEFINER` con validación explícita.

### 10. `prefs['localActualId']` es un int de Isar, no un tenant

La prioridad 1 de `cargarLocalActual()` aceptaba cualquier id guardado
sin validar a qué tenant pertenecía. El id 1 (`pruebapostdeploy`) quedó
guardado cuando el RLS bajaba los 5 locales, y el badge lo mostraba
mientras el JWT era JAHTLABS. Ahora se descarta si `supabaseId` no
coincide con el claim y se cae a la prioridad 2.

No rompe el hot-switch: `setLocalActual()` escribe `state` directo y ya
awaited `cambiarLocal()`, así que el JWT ya es el nuevo.

---

### Reglas que quedan

| Regla | Por qué |
|---|---|
| Toda policy tocada en el dashboard va en una migración el día mismo | El drift no delata nada hasta que un usuario ve datos de otro tenant |
| El nombre de la clave de un flag tiene que existir en `planes.features` | Si no existe, el getter es código muerto con appearance de feature |
| `planActivo == false` esconde el producto entero, no solo un módulo | Es fail-closed, pero hay que tenerlo presente al dar de alta tenants |
| `wipeAll()` nunca toca `planEntitys` / `suscripcionEntitys` | Planes son catálogo global; suscripciones ya se filtran por `tenantId` |
| **El valor de un enum en Dart tiene que existir en la base** | `'activa'` estaba en el getter y el CHECK lo prohíbe: `planActivo` fue `false` para todos, siempre |
| **`defaultVisible: true` anula el gate** | `\|\| defaultVisible` es siempre verdadero: 9 módulos se veían en cualquier plan |
| **Un fire-and-forget que escribe caché tiene que re-disparar el provider** | `obtenerPlanes()` dejaba 9 de 12 features afuera toda la sesión |
| **Las policies permisivas se ORean** | Una policy `{public}` gana sobre una `{authenticated}` bien escrita |
| **POS y `admin_console` comparten JWT** | Un `is_superadmin` del owner se colaba al POS; por eso el filtro por `claim` en `sync_service` |
| **La rama que denies tiene que loguear** | Los 3 bugs eran invisibles por una rama sin `debugPrint`; el log nuevo los destapó en cadena |

### Pendiente de datos (no lo arregla código)

```sql
-- tenants sin suscripción
SELECT l.nombre, l.id FROM locales l
  LEFT JOIN suscripciones s ON s.tenant_id = l.id
 WHERE s.tenant_id IS NULL;

-- alta de JAHTLABS en pro
INSERT INTO public.suscripciones (tenant_id, plan_id, estado, iniciado_en, auto_renovar)
 VALUES ('9c7380a4-14be-41c2-88db-07606c2a6489','pro','activo',now(),true)
 ON CONFLICT (tenant_id) DO UPDATE SET plan_id=EXCLUDED.plan_id, estado='activo';
```

---

## Solución al bug de Gradle en CI (octubre 2026)

- **Problema:** el build de Android fallaba en local con `Could not move
  temporary workspace`, sin dejar compilar ni un patch de Shorebird.
- **Causa:** bug de Gradle 8.x en Windows (gradle/gradle#27844). No hay
  fix en la línea 8.x, y Flutter 3.47 exige Gradle >= 8.14, así que no
  hay versión intermedia posible.
- **Lo que se descartó, con evidencia y no por suposición:**

  | Hipótesis | Resultado |
  |---|---|
  | Caché corrupta | `.gradle\caches` y `daemon` borrados al 100%, falla igual |
  | Versión de Gradle | Probado 8.13 (Flutter lo rechaza) y 8.14 (falla) |
  | JDK | `Files.move(ATOMIC_MOVE)` OK en 21.0.2 y en el JBR 21.0.10 de Android Studio |
  | Filesystem | `Directory.Move` de .NET OK, incluso dentro de `.gradle\caches` |
  | Antivirus | Avast desactivado, sin cambio |
  | Daemons / watcher | Detenidos y deshabilitados, sin cambio |

- **Solución:** migrar los builds de release y patch a GitHub Actions
  con `ubuntu-latest`. Para el AAB da igual el runner: Dart compila
  igual en cualquier OS.
- **Robustez en el workflow:** los secretos llegan por `env:` y no
  interpolados con `${{ }}`, porque un `$` dentro del JSON lo expandiría
  bash. Se materializan con `printf '%s'` en vez de `echo`, y se validan
  con `jq empty` y el magic number `0xFEEDFEED` del keystore. Todo falla
  en 1 segundo en vez de a los 10 minutos.
- **Trampa real que costó un run:** `gh secret set X -b "$(Get-Content
  -Raw f)"` ejecutado en **bash** deja el secret **vacío** sin error
  visible, porque `Get-Content` no existe ahí. El síntoma es un JSON
  inválido tres pasos más tarde, en el build. En bash va `cat`.

## Cierre sesión 2026-10-13 (Shorebird + identidad visual)

**Tags:** `v1.0.2` (`2e0b5c7`) · `v1.0.3` (`c303fda`)

### Estado de Supabase al cierre (2026-10-13)

- Migraciones `20261012000001`, `...0002`, `...0003` **aplicadas**.
- Edge Function `create-tenant` **deployada** (ya sin `pin: "1234"`).
- `supabase secrets set TRIAL_PLAN_ID=trial` — ⚠️ es **FK a `planes.id`**,
  no una etiqueta. Si no existe esa fila, el `INSERT INTO suscripciones`
  falla por FK y el tenant queda sin plan en la consola SaaS **sin que
  nada falle visiblemente** (la EF no aborta el signup a propósito).
  Verificar con `SELECT id, nombre FROM planes;`.

### Regla que costó 2 releases: los patches son POR RELEASE

Un patch de Shorebird solo empaqueta **código Dart + assets**. Los
**recursos Android** (`android:label`, íconos de `mipmap-*`, `colors.xml`)
quedan congelados en el APK base.

Por eso, cambiar el ícono del launcher o el nombre visible **exige un
release nuevo**, no un patch:

| ID | Versión | Contenido |
|---|---|---|
| `894041` | 1.0.1+5 | Base + patches #1, #2, #3 |
| — | 1.1.0+6 | Ícono azul (nuevo release) |
| — | 1.1.1+7 | Nombre `BoostiPos` (otro release) |

Un tablet con `894041` + patch 3 **no migra solo** a `1.1.1+7`: hay que
instalar el APK encima. Y `shorebird releases get-apks` hay que volver a
correrlo por cada release, no devuelve el "latest".

### El ícono del app son 3 archivos, no uno

| Archivo | Para qué |
|---|---|
| `assets/icon/app_icon.png` | Legacy (Android < 8), Windows, web |
| `assets/icon/app_icon_foreground.png` | **Adaptive icon, Android 8+** |
| `assets/icon/app_icon.ico` | Instalador Windows |

En Android 8+ el launcher **ignora `app_icon.png`**: usa
`adaptive_icon_background` (color) + `adaptive_icon_foreground` (imagen).
Cambiar solo el PNG deja el ícono viejo en pantalla.

El foreground va al **62%** del lienzo: zona segura 66/108 (61%), máscara
visible 72/108 (67%). Un logo más grande se recorta.
`tools\gen_launcher_foreground.ps1` y `tools\gen_ico.ps1` regeneran ambos.

⚠️ Borrar un asset declarado en `pubspec.yaml: assets:` rompe el build.
⚠️ Borrar `app_icon.ico` rompe `dart run inno_bundle` sin error claro.

### Bug que casi pasa: `''.split(regex)` devuelve `['']`, nunca `[]`

`EmployeeCard._initials` hacía:

```dart
final parts = u.nombre.trim().split(RegExp(r'\s+'));
if (parts.isEmpty) return '?';                        // ← nunca se cumplía
if (parts.length == 1) return parts[0].substring(0, 1);  // ← RangeError
```

`split` **siempre** devuelve al menos un elemento. Para `''` devuelve `['']`,
así que caía en el `substring` y lanzaba `RangeError`. Como
`_initialsAvatar` se llama siempre (con foto o sin foto), **cualquier
empleado con `nombre == ''` reventaba la pantalla**.

El `if (parts.isEmpty)` sobre un `split` es un no-op silencioso: lee como
una guarda y no protege nada.

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
---

## Cierre sesión 2026-10-20 — OTA real en Android y Windows

**Commits:** `f2fc1af`, `a00e25c`, `b6d959f`, `d1eb38d`, `497d300`, `2643cd5`, `6ee5b14`, `39ae444`.

### El APK que se iba a vender no tenía OTA

Se compilaba con `flutter build apk`, que usa el motor **estándar** de Flutter.
Verificado leyendo el binario: su `libflutter.so` pesa 11,20 MB y no contiene la
cadena `shorebird`; el del AAB pesa 13,37 MB y sí la contiene. Un cliente con ese
APK nunca habría recibido un patch, aunque el AAB publicado sí los recibiera.

**Arreglo:** paso `Obtener APK instalable con OTA` en `shorebird.yml:185`.
`shorebird releases get-apks` descarga el AAB publicado y lo convierte en APK
universal, pero **firma con la llave de debug** (`CN=Android Debug`), así que el
paso lo re-firma con `boostikeystore.jks` (zipalign + apksigner). No publica y no
gasta número de versión. Verificado: firma `8a189763…`, idéntica al AAB, y
`versionCode` 11 igual al anterior, así que se instala encima sin desinstalar.

### Windows con OTA

Workflow nuevo `.github/workflows/shorebird-windows.yml`. Usa
`shorebird release windows` (y `shorebird patch windows` para parches) **sin
`--flavor`**: Shorebird no soporta flavors en Windows, el punto de entrada va por
`--target`. Falla a propósito si `flutter_windows.dll` no contiene la cadena
`shorebird`, para no entregar un `.exe` sin OTA sin darse cuenta.

Release `1.1.5+11` de Windows publicado el 2026-10-20. El binario pasó de 20,29 MB
de motor a 22,46 MB: esos ~2 MB son el updater.

### Trampas confirmadas

- `shorebird build apk` **no existe** en la CLI 1.6.128 (falla con "Could not find an option named --release").
- `get-apks` entrega el APK firmado en debug: hay que re-firmar siempre.
- `flutter analyze` devuelve exit 1 con solo infos; el CI usa `--no-fatal-infos`.
- `releases list` en Windows solo muestra las releases de Windows (1.1.1+7 y 1.0.1+5).

### Migración aplicada y limpieza de artefactos (2026-10-20)

- `20261018000001_legal_acceptance` **aplicada en producción** por el owner.
  Verificada desde el cliente anónimo: `GET /rest/v1/legal_acceptance` → 200,
  y `POST /rest/v1/rpc/registrar_legal_acceptance` → 401 (existe y está
  protegida contra el rol anónimo), mientras una función inexistente
  devuelve 404 `PGRST202`.
- Se borraron ~923 MB de artefactos sin OTA: los ZIP de Windows de 17,58 y
  19,48 MB, la carpeta `Boosti_POS_Windows_1.1.5+11`, el APK `1.1.2+8`, el
  APK y la carpeta de Windows de `1.1.5+11`, y las copias de trabajo del APK.
- Entregables vigentes: `Boosti_POS_1.1.5+11_OTA.apk`,
  `Boosti_POS_1.1.5+11_windows_OTA.zip` y `Boosti_POS_Windows_1.1.5+11_OTA\`.

## Cierre sesión 2026-10-23 — Entorno de pruebas reales

**Estado:** cambios sin commitear (dashboard + herramientas de seed).

### Datos de prueba inyectados en la base local

- `tool/seed_demo.dart` puebla la base Isar **sin tocar Supabase**: todo lo
  creado lleva `syncStatus/sincronizado = synced`, así que `SyncService` no
  lo sube. Antes de abrir Isar copia `default.isar` a
  `default.isar.bak-<fecha>`.
- Aplicado sobre el local JAHTLABS (id 2): modo `restaurante`, estaciones
  Cocina/Barra/Postres, 14 productos de menú, 8 mesas, 3 comandas abiertas
  (una sin enviar, dos en cocina con estados distintos), 8 clientes y 120
  ventas repartidas en 30 días.
- `tool/db_dump.dart` audita la base (conteos, locales, usuarios, planes,
  suscripciones, mesas) sin abrir la app.

### Dashboard: de 4 métricas a 8 + 3 paneles

- **Bug corregido:** `variacionSemana` y `variacionMes` pedían 14 y 60 días
  a `ventasPorDia`, que devuelve 7 → **siempre 0%**. Ahora comparan contra
  `totalSemanaAnterior` / `totalMesAnterior`, calculados en `IsarService`
  con `obtenerTotalVentasPorRango`.
- **Bug corregido:** `variacion` devolvía 0 cuando ayer no hubo ventas.
  Ahora devuelve +100% si hoy sí hubo: 0% mentía diciendo "sin cambios".
- **Bug corregido:** el "top de productos" sumaba **toda la historia**.
  Ahora existe `obtenerProductosMasVendidosEnRango()` y el dashboard usa
  el mes en curso.
- Métricas nuevas: ticket promedio (hoy y mes), gastos de hoy, anulaciones
  del mes, ocupación del salón (o productos sin rotación en retail).
- Paneles nuevos: ventas por hora con hora pico, métodos de pago del mes y
  estado del salón (solo aparece si el local tiene mesas).
- Widgets nuevos en `widgets/dashboard/`: `dashboard_card.dart`,
  `hourly_sales_chart.dart`, `payment_methods_card.dart`,
  `restaurant_status_card.dart`.
- Los mapas nuevas del resumen se castean explícitamente en el provider:
  un `resumen['x'] ?? []` sobre un `dynamic` revienta con TypeError cuando
  el servicio devuelve `{}` en su rama de error.

### Hallazgo pendiente (no corregido)

`VentaEntity` **no tiene `localId` ni `tenantId`** y las consultas del
dashboard filtran solo por fecha. Con varios locales en la misma base
(`isar_default`), los totales suman ventas de todos. En el esquema real
cada tenant debería usar su propio dispositivo/base; con multi-local en
un mismo equipo sí mezcla. Corregirlo exige migración de entidad + sync,
no es un cambio de UI.

### Reglas que quedan

| Regla | Por qué |
|---|---|
| Un seed de pruebas escribe `syncStatus: 'synced'` | Si no, `SyncService` sube data falsa a producción |
| Respaldar el `.isar` antes de inyectar | Isar no tiene rollback: el archivo es la única copia |
| `ventasPorDia` devuelve 7 días: no sirve para comparar semanas | Dos getters murieron por asumir 14 y 60 |
| Un `?? []` sobre `dynamic` no infiere el tipo | El cast de `List<dynamic>` a `List<T>` falla en runtime |

---

## Cierre sesión 2026-10-26 · Bugs del modo restaurante

**Estado:** cambios sin commitear (Lotties + bugs de comanda/KDS).

### Bug A · Comanda en blanco (solo appbar + total)

`ComandaScreen._barraAcciones` envolvía la barra en un `Center` dentro de
`bottomNavigationBar`. `Scaffold` mide ese slot con **ancho tight y alto
loose**, así que el `Center` se expandía hasta el alto completo de la
ventana: el `body` quedaba con 0 px y no se pintaba ni el header ni la
lista (el total y los botones sí, centrados verticalmente). Arreglado con
`Center(heightFactor: 1)`. **Regla:** en `bottomNavigationBar` /
`bottomNavigationBar` de cualquier `Scaffold`, un `Center`/`Align` sin
`heightFactor` se come la pantalla.

⚠️ El body se veía vacío pero `comanda.items` SÍ tenía datos (el total
mostraba $3.50): era layout, no provider.

### Bug B · KDS no mostraba las comandas nuevas

`enviarACocina()` seguía este orden:

1. `marcarPendientesComoEnCola()` → abre su propio `writeTxn`, lee la
   comanda, pone los items en `enCola` y hace `put`.
2. `activa.comandaEstado = enviada; guardarComanda(activa)` → pero
   `activa` es la instancia del **estado del provider**, todavía con los
   items en `pendiente`. El `put` pisaba el `enCola` del paso 1.

Resultado: el PDF de cocina se imprimía (usa la lista en memoria) y la
comanda quedaba `enviada`, pero sus platos volvían a `pendiente`, que NO
es visible en el KDS. Arreglado releyendo con `obtenerComandaPorId` antes
de guardar.

**Regla:** `CartSessionItem` es `@embedded`. Ningún método puede escribir
dos veces seguidas la misma comanda desde dos instancias distintas: la
segunda pisa la primera. Después de un `marcar*`/`actualizar*Item` de
`IsarService`, **releer** antes de volver a guardar.

### Bug C · `cambiarMesa` dejaba comandas fantasma

Movía `mesaId` pero no `sessionId` (`mesa:<id>`, índice ÚNICO), así que
la comanda quedaba ligada a la mesa vieja. La BD del usuario tenía una
comanda `mesa:3` con `mesaId=8`. Ahora se recalcula `sessionId` y se
rechaza mover a una mesa que ya tiene comanda viva (el `replace: true`
del índice único borraría una de las dos en silencio).

### Mejora · Re-volcar el carrito ya no resetea la cocina

`guardarDesdeCarrito` reconstruía todos los items en `pendiente`. Si el
mesero agregaba una bebida a una comanda ya enviada, los platos en
`enCola`/`enPreparacion`/`entregado` volvían a la cola (se cocinaban dos
veces). Ahora `_conservarTrazabilidadCocina` copia estado, timestamps de
cocina, pausa, nota y estación del item previo del mismo `productoId`.

### Bug D · Aviso de lotes vencidos (inventario)

`IsarService.obtenerLotesVencidosConStock()` (`cantidadRestante > 0` y
`fechaVencimiento < inicio de hoy`) + diálogo al abrir inventario.

### Herramientas de diagnóstico

- `tool/db_dump.dart` ahora imprime **comandas** con el estado de cada
  plato: es lo que permitió ver que la comanda estaba `enviada` con el
  item en `pendiente`.
- Se puede dumpear con la app ABIERTA copiando `default.isar` a otra
  carpeta y pasándola como argumento (Isar no permite dos procesos sobre
  el mismo archivo).
- Tests nuevos: `test/features/pos/kds_envio_test.dart` (3 casos contra
  Isar real; fallan si vuelve el doble `put` sobre la comanda).

---

## Cierre sesión 2026-10-26 · Caja del cajero (Fase 1)

### Avisos: SnackBar → diálogo

El SnackBar tapaba la barra de Total/Enviar/Cobrar y se iba solo en 4 s.
Ahora `ComandaScreen._enviar` abre `ResultadoEnvioCocinaDialog` (lista de
platos con estación) y `_aviso` usa `ErrorDialog`. Se mantiene `AlertDialog`
plano y no `GlassDialog`: mismo criterio que
`confirmar_cobro_pendientes_dialog.dart` (legibilidad bajo luz de cocina).

De paso se corrigió el resumen: antes decía `enviados.length`, que es
cuántos items entraron en ESE envío, no los platos de la comanda.

### Caja Fase 1 · tablero de cobro

Pantalla nueva `screens/caja/caja_screen.dart` con tres pestañas
(**Mesas**, **Por cobrar**, **Cocina de solo lectura**) y un resumen de
métricas (libres / ocupadas / por cobrar / platos en cocina).

Decisiones:

- **No hay provider nuevo.** Las fuentes son `mesasProvider` y
  `comandasProvider`; el índice `mesaId → comanda` se deriva en cada build.
  Un `CajaNotifier` sería un tercer sitio que refrescar.
- **El cobro reutiliza el flujo del POS**: `mostrarModalCobro` +
  `procesarVenta`, igual que el mesero. Antes de volcar la comanda al
  carrito se guarda el carrito de retail; si el cajero cancela, se
  restaura. Sin eso, cobrar desde la caja pisaba una venta a medias.
- **`ComandaCobroUtils`** (`utils/comanda_cobro_utils.dart`) concentra
  `enCocina`, `listos`, `sinEnviar`, `listaParaCobrar` y `aCarrito`, para
  que mesero y cajero no dupliquen el criterio. `ComandaScreen._cobrar` ya
  lo usa. Tests: `test/features/pos/comanda_cobro_utils_test.dart` (11).
- **Avisos antes de cobrar**: `ConfirmarCobroPendientesDialog` (en cocina /
  listos) y un diálogo extra si hay platos `pendiente` que nunca salieron.
- **Aterrizaje del cajero**: `utils/home_por_rol.dart` es el punto único
  (`app.dart`, `login_screen`, `splash_screen`). Cajero + `requiereMesa` →
  `CajaScreen`; roles de solo-personal → `EmployeesScreen`; resto → POS.
  En `splash` se hace `businessModeProvider.recargar()` antes de decidir
  porque el modo se carga en async y en frío llegaría como `retail`.
- Menú: nueva opción `caja_operativa` ("Caja · Mesas, cocina y cobros").
  `caja` sigue siendo **Cierre de caja** (arqueo), no operación.

### Pendiente

- Reservas (Fase 2): no existe `ReservaEntity`; `MesaEstado.reservada` y
  `Mesa.reservaId` están declarados desde R.1 esperando esa fase.
- Turno por cajero (Fase 3): `TurnoEntity` y `pos_menu_provider.abrirTurno`
  existen, pero la caja no exige turno abierto para cobrar.

## Cierre sesión 2026-10-26 · Limpieza demo, lotes vencidos y diálogo de ingrediente

### Comandas de demostración borradas

La caja mostraba 8 comandas del seed del 23/10 en mesas que ya nadie ocupaba.
Se creó `tool/limpiar_demo.dart` (simulación por defecto, `--apply` escribe).

Reglas del script: borra comandas con **0 items** o creadas **antes de
`--antes`** (default: hoy) y después libera las mesas que se quedaron sin
comanda viva. No toca ventas, detalles, lotes, productos, clientes ni usuarios.

Resultado real: **8 comandas borradas, 4 mesas liberadas**. Estado final
verificado con `tool/db_dump.dart`: `comandas: 0` y las 8 mesas en `libre`.

Por qué sobrevivían al catálogo: `CartSessionItem` es `@embedded` y guarda
snapshot (nombre, precio, estación), así que la comanda no depende de que el
producto siga existiendo (`cart_session_entity.dart:153`).

### Lotes vencidos: el `null` ordena primero

`IsarService.obtenerLotesVencidosConStock` ya filtraba con
`fechaVencimientoIsNotNull()`; el diálogo de `inventory_screen.dart` volvió a
hacer `lote.fechaVencimiento!` sobre una lista que podía traer nulos. Ahora
filtra `conFecha` **antes** de contar (un `SizedBox.shrink()` en el
`itemBuilder` dejaría huecos y descuadraría el "… y N más") y usa
`fechaVencimiento!` con seguridad. Test de regresión:
`test/features/pos/lotes_vencidos_test.dart` (2).

Contexto de la base real: 18 de 19 lotes tienen `fechaVencimiento == null`
y solo el `id=1` vencía el 2026-10-20.

### Diálogo "Agregar ingrediente" con buscador

Un restaurante puede tener 100 ingredientes, así que el desplegable se
cambió por una lista con scroll y buscador (`product_data_tab.dart:~1549`):

- Ancho hasta 560 px y lista de 140–380 px de alto.
- Búsqueda por nombre, categoría y código de barras, sin tildes ni
  mayúsculas (`_normalizar`): "cesar" encuentra "Ensalada César".
- Contador "N de M ingrediente(s)" y botón para limpiar la búsqueda.
- Filas seleccionables con categoría y stock abreviado.
- Al elegir, arrastra el `ProductoEntity.unidad` del ingrediente.
- Panel inferior con cantidad + unidad + switch de opcional; el botón
  "Agregar" queda deshabilitado hasta que hay selección.

### Entorno de tests tras `flutter clean`

`flutter clean` dejó el hook de `objective_c` atascado y **todo** `flutter
test` moría en "loading" (incluso tests que no tocan Isar). Se arregló
apartando (renombrando, no borrando) `.dart_tool/hooks_runner`,
`.dart_tool/native_assets` y `build/native_assets` con `Move-Item` y ruta
absoluta; `Rename-Item` con subcarpeta en el destino falla en PowerShell.

⚠️ Además, el runner de la herramienta mata cualquier comando que pase más
de ~1 s sin escribir en stdout. Para pruebas largas hay que lanzarlas
**desprendidas**:

```powershell
Start-Process -FilePath "$env:ComSpec" -ArgumentList '/c',
  'cd /d <proyecto> && flutter test <archivo> > %TEMP%\t.txt 2>&1' -WindowStyle Hidden
```

### Recetas: dos huecos conocidos (no se tocaron)

- **No sincronizan con Supabase.** `RecetaEntity` no tiene
  `toSupabaseJson`/`fromSupabase` y `sync_service.dart` no la empuja
  (`receta_entity.dart:18-24`). Faltan las tablas `recetas` y
  `receta_ingredientes`.
- **No hay conversión de unidades.** `_descontarRecetaDeItem` usa
  `item.cantidad * recItem.cantidad` 1:1 (`comanda_provider.dart:1449`): si
  la receta pide 150 g y el stock está en kg, descuenta 150 kg
  (`receta_entity.dart:129-132`).

Ambos están ya listados en `docs/TODO.md` (líneas 434-451).

## Cierre sesión 2026-10-26 · Propina y mesero antes del cobro

### Modelo: sin tocar entidades

La propina se decide al cobrar, no al abrir la mesa, así que no vive en la
comanda. Viaja como parámetro del cobro y termina en la venta:

- **Propina** → una línea más de `DetalleVentaEntity` con
  `nombreProducto = 'Propina'` y `productoId = null`.
  `detalle_ventas.producto_id` es `bigint` **sin NOT NULL**
  (`20260912213435_baseline.sql:508`), así que sincroniza sin cambiar el
  esquema. Cero migraciones.
- **Mesero** → `VentaEntity.empleado`, que el sync ya empuja como
  `empleado_nombre` (`sync_service.dart:2017`).
- `VentaEntity.total` **incluye** la propina; `subtotal` e `impuesto`
  siguen siendo los del consumo. Consecuencia aceptada: "ventas del día"
  y "productos más vendidos" suman la propina. El IVA queda correcto
  porque los reportes leen `venta.impuesto`.

Se descartó añadir `propina`/`meseroNombre` a `VentaEntity` porque exigía
`build_runner` + `ALTER TABLE` y el usuario pidió expresamente no tocar
entidades. Si algún día se quiere separar consumo de propina en reportes,
ese es el camino.

### Dónde vive el flujo

| Pieza | Archivo | Nota |
|---|---|---|
| Diálogo | `widgets/restaurante/propina_mesero_dialog.dart` | chips 0/5/10/15 %, monto libre, total en vivo, selector de mesero obligatorio |
| Orquestación | `catalog_actions.dart:449-487` | único embudo de cobro; solo abre el diálogo si `flags.requiereMesa && comanda != null` |
| Persistencia | `venta_service.dart:114-190` | `propina`, `meseroNombre`; línea "Propina" en el detalle |
| Callers | `caja_screen.dart:217`, `comanda_screen.dart:330` | pasan `comanda:` |

Reglas que quedaron:

- **El paso se omite entero** si el local no tiene empleados habilitados.
  El mesero es obligatorio, y pedir uno inexistente dejaría la mesa sin
  poder cobrarse. `_meserosDelLocal()` (`catalog_actions.dart:520`) filtra
  por `activo` (provider) **y** por `estado == 'activo'`, y si el segundo
  filtro vacía la lista devuelve los `activo` para no bloquear el cobro.
- **Cancelar el diálogo de propina aborta el cobro**, igual que cancelar
  `CobrarDialog`. La caja restaura el carrito de retail por su camino de
  siempre.
- **El POS de mostrador no pregunta**: no hay `comanda`, no hay mesa que
  atender.
- En restaurante `empleado` pasa a decir **quién atendió**, no quién cobró.
  No hay campo para ambos sin tocar la entidad.
- La propina se **normaliza** (negativa/NaN → 0) y se redondea a 2
  decimales antes de sumar, para que `total - subtotal - impuesto` dé el
  monto exacto.

### Tests

- `test/services/ventas_service_test.dart` +4: total con propina, línea
  "Propina" (producto nulo, `ventaIdFk`, `syncStatus`), sin propina, monto
  negativo ignorado y `empleado` según haya mesero o no.
- `test/features/pos/propina_mesero_dialog_test.dart` (nuevo, 4 tests):
  sin mesero no se puede continuar, porcentaje calcula y actualiza el
  total, monto libre reemplaza al porcentaje, `Sin propina` limpia.

## Cierre sesión 2026-10-27 · Unidades de receta y verificación final

### Bug: gramos restados como kilos

`ComandasNotifier._descontarRecetaDeItem` restaba `RecetaItemEntity.cantidad`
tal cual, sin mirar `RecetaItemEntity.unidad` ni `ProductoEntity.unidad`. Una
receta de "150 g de queso" con el stock en kg descontaba **150 kg**.

La conversión vive ahora en un único sitio:

- `presentation/services/conversion_unidades.dart` — clase pura (sin Flutter
  ni Isar) con `normalizar`, `factor` y `convertir`. Cubre `kg`↔`g`,
  `lt`↔`ml`, sinónimos (`kilos`, `gr`, `lts`, `und`…) y devuelve `null`
  cuando las dimensiones no coinciden (masa ↔ volumen ↔ conteo).
- `comanda_provider.dart:~1440` lee el ingrediente con
  `obtenerProductoPorId(recItem.ingredienteId)` y aplica el factor. Si no
  hay factor posible cae al 1:1 de antes y deja `debugPrint`, porque
  bloquear la entrega de un plato ya cocinado está descartado (Q3).
- `receta_entity.dart:129-132` documenta el comportamiento en el campo
  `unidad`. En `docs/TODO.md` el ítem quedó marcado `[x]`; sigue pendiente
  **normalizar el valor al guardarlo**, para que la UI no acepte texto libre.

Nota práctica: en el caso normal no hay conversión que hacer, porque
`product_data_tab.dart:1618-1619` inicializa `unidad` con
`producto.unidad`. La conversión cubre el caso en que el ingrediente cambió
de unidad después de escribirse la receta.

### Tests nuevos

- `test/services/conversion_unidades_test.dart` (13 tests): misma unidad,
  sinónimos, `g`↔`kg`, `ml`↔`lt`, mayúsculas/espacios, dimensiones
  incompatibles, `normalizar` con vacío y unidad desconocida, `convertir`.
- `test/features/pos/descuento_receta_test.dart` caso **2b**: receta en
  gramos descuenta `0.15` kg (no 150) y el movimiento queda por `0.15`.
  Los helpers `crearProducto` / `ingrediente` ahora aceptan `unidad`.

### Aviso de stock del KDS: Snackbar → AlertDialog

El aviso de "se descontó lo que había" compartía `ScaffoldMessenger` con el
aviso de pedido nuevo, así que **el segundo Snackbar pisaba al primero** y el
faltante se perdía. Ahora es un `AlertDialog`:

- `widgets/restaurante/aviso_stock_receta_dialog.dart` — deduplica los
  ingredientes (el provider los manda repetidos cuando un ingrediente se
  queda corto en varios lotes), los lista y no se cierra solo. Mismo patrón
  que `ResultadoEnvioCocinaDialog`: `AlertDialog` plano, no `GlassDialog`.
- `kds_screen.dart:217` — `_avisarStockInsuficiente` ahora es `Future` con
  guard `_avisoStockVisible` para no apilar diálogos si llegan dos entregas
  seguidas. El `ref.listenManual` lo lanza con `unawaited(...)`.
- `test/features/pos/aviso_stock_receta_dialog_test.dart` (4 tests): título
  y lista, deduplicado, no se cierra solo a los 10 s, "Entendido" cierra.

### Docs saneados

`docs/TODO.md` tenía entradas que ya no eran ciertas y se marcaron:

- "Sin tests de G.3" → hay 21 tests en `descuento_receta_test.dart`.
- "El aviso comparte Snackbar" → resuelto con el diálogo.
- Las dos listas de "tests pre-existentes fallando" (líneas ~339 y ~884,
  ~60 fallos entre las dos) → la suite está verde.

### Verificación de cierre

- `flutter analyze` → **17 issues, todos `info` preexistentes**, cero
  errores ni warnings nuevos.
- Suite completa → **920 pasan, 1 omitida, 0 fallos** (antes 902: +18 de
  conversión de unidades, caso 2b y el diálogo del KDS).
- `flutter test test/services/conversion_unidades_test.dart
  test/features/pos/descuento_receta_test.dart` → **34 pasan**.
- Commiteado el 2026-10-27 (ver el cierre (3) al final del archivo).

## Cierre sesión 2026-10-27 (2) · Recetas en Supabase

### El bloqueo

`RecetaEntity` era 100% local: `sync_service` no la empujaba y la entidad no
tenía `toSupabaseJson` / `fromSupabase`. Una receta capturada en un
dispositivo no existía en el otro y una reinstalación se la llevaba.

### Migración (el owner la corre)

`supabase/migrations/20261027000001_recetas.sql`:

| Objeto | Para qué |
|---|---|
| `recetas` | fila del plato: `producto_id_fk`, `nombre_plato`, `rinde_porciones`, `activo`. `UNIQUE (tenant_id, id_isar)` como `lotes`. |
| `receta_ingredientes` | hijos con `orden`, `ingrediente_id_fk`, `ingrediente_nombre`, `cantidad`, `unidad`, `es_opcional`. FK a `recetas` `ON DELETE CASCADE`. |
| `guardar_receta(jsonb, jsonb)` | upsert de la fila + REEMPLAZO COMPLETO de ingredientes, en una transacción. |
| RLS `tenant_isolation` | `FOR ALL` en ambas tablas. |

Decisiones que importan:

- **RPC y no 3 llamadas del cliente.** Un corte entre el `DELETE` y el
  `INSERT` de ingredientes dejaría la receta vacía en la nube, y esa versión
  se propaga a los otros dispositivos al hacer pull. Descontar stock con una
  receta vacía es peor que no sincronizar.
- **`SECURITY INVOKER`**, así la RLS aplica de verdad. El tenant sale siempre
  de `current_tenant_id()` (JWT); el cliente NO lo manda. Es la lección del
  bug de lotes subidos al tenant equivocado durante el hot-switch.
- **Sin FK en `ingrediente_id_fk`**: la receta tiene que viajar aunque ese
  producto no haya subido. El snapshot `ingrediente_nombre` la mantiene
  legible. El plato (`producto_id_fk`) sí lleva FK: una receta sin plato no
  significa nada.
- `rinde_porciones` se normaliza a 1 si llega 0 o negativo, en el cliente
  **y** en la RPC, porque la columna tiene `CHECK (> 0)`.

### Lado Dart

- `RecetaEntity.toSupabaseJson()` / `ingredientesToSupabaseJson()` /
  `fromSupabase(json, localIdResuelto:)` y
  `RecetaItemEntity.toSupabaseJson({orden})` / `fromSupabase`.
- El `orden` de los ingredientes es implícito en Isar (posición del array);
  en la nube hay columna y el pull reordena con `sort` porque PostgREST no
  garantiza el orden de las filas embebidas.
- `IsarService`: `obtenerRecetaPorId`, `obtenerRecetasPendientesSync`,
  `marcarRecetaSincronizada` y `guardarReceta(..., marcarPendiente:)`.
- `SyncService`: `sincronizarRecetasPendientes` (RPC) y
  `descargarRecetasDesdeSupabase` (`select('*, receta_ingredientes(*)')`),
  enganchados en `sincronizarTodo` (después de productos y locales) y en
  `sincronizarTodoConResumen` (contador `recetas`).

### El bug que casi se cuela

`guardarReceta` **no** marcaba la receta como pendiente. Editar una receta ya
sincronizada dejaba `sincronizado = true`, así que el push la ignoraba para
siempre: el cambio se veía en el dispositivo que lo hizo y en ningún otro.
Ahora `guardarReceta` pone `sincronizado = false` y el pull escribe con
`marcarPendiente: false` (si no, cada receta bajada se re-subiría en bucle).

### Conflictos y límites conocidos

- **Cruce por `id_isar`** (el id de Isar del dispositivo que creó la receta),
  igual que lotes. Si el id ya existe apuntando a OTRO plato, la fila se
  descarta y se cuenta como conflicto: son dos dispositivos creando recetas
  en paralelo y el autoincrement chocó. Pisar la receta del plato B con la
  del plato A sería peor que no sincronizar.
- Si no hay fila con ese id pero el local ya tiene receta para ese plato,
  también se descarta (si no, quedarían dos recetas del mismo plato).
- **Borrados no sincronizados**: `eliminarReceta` no tiene callers (la UI
  marca `activo = false`). El día que se use hace falta un tombstone.
- **Sin LWW por `updated_at`**: gana el que sube último.

### Si el owner todavía no aplicó el SQL

El push detecta "tabla/función ausente" (`42P01`, `PGRST205`, `PGRST202`,
`schema cache`), avisa **una vez** y aborta el bucle, sin mandar el ruido a
Sentry ni repetir el error por cada receta. La app sigue funcionando igual:
la receta se queda pendiente en Isar.

## Cierre sesión 2026-10-27 (3) · Commits del trabajo pendiente

Se cerró el working tree que llevaba varias sesiones sin commitear, en 7
commits temáticos (los tres primeros son los de esta sesión):

| Commit | Contenido |
|---|---|
| `2d3b4ad` `feat(assets)` | Lotties nuevos (`clock`, `error`, `Clock Alarm`, `success.json`), `pubspec.yaml` y `tool/` (seed, dump, limpieza, verificación de Lotties). |
| `b343c61` `feat(restaurante)` | Caja del cajero (`caja_screen`, `panel_cobro_comanda`, `comanda_cobro_utils`), acciones de mesa en `salon_screen` y `home_por_rol` (el cajero aterriza en la caja); login/splash/menu_config/app. |
| `29dc6bc` `feat(dashboard)` | `dashboard_provider` (comparativos, ventas por hora, métodos de pago, sin rotación, anulaciones, salón) y los 4 widgets de `widgets/dashboard`. |
| `07c04fe` `fix(inventario)` | `obtenerLotesVencidosConStock` + aviso de lotes vencidos al abrir inventario; buscador de ingredientes en `product_data_tab`. |
| `c8499f3` `feat(restaurante)` | Propina + mesero antes del cobro, `resultado_envio_cocina_dialog` y el aviso de stock del KDS en `AlertDialog`. |
| `80e152a` `feat(recetas)` | Conversión de unidades, sync de recetas a Supabase y su migración. |
| (este) `docs(memoria)` | Este cierre. |

### Verificación antes de commitear

- `flutter analyze` → **17 issues, todos `info` preexistentes**.
- Suite completa → **946 pasan, 1 omitida, 0 fallos**.
- Escaneo de secretos sobre las líneas añadidas de cada commit: sin
  hallazgos.
- `isar_service.dart` se repartió por hunks (`git apply --cached` con un
  patch filtrado) para que cada commit llevara solo sus métodos.

### Pendiente del owner

1. ~~Correr `supabase/migrations/20261027000001_recetas.sql`~~ → **aplicada el
   2026-10-27**.
2. ~~Verificar tablas, policies y RPC~~ → **verificado**: `recetas` y
   `receta_ingredientes` con `rowsecurity = true`, una policy
   `tenant_isolation` (`cmd = ALL`) en cada una, y `guardar_receta(p_receta
   jsonb, p_ingredientes jsonb)` con `prosecdef = false`.
3. `supabase migration repair --status applied 20261027000001` si el
   historial todavía no la tiene (el `repair` no ejecuta SQL; va después).
4. ~~Borrar `succes.json` y las 3 carpetas `.bak-202610261858`~~ → **hecho**
   (2026-10-27, con permiso del owner).

### La consulta 4 de verificación estaba rota

Al correrla en el SQL Editor falló con `22P02: invalid input syntax for type
json ... Token "<" is invalid`. Dos causas, las dos del propio snippet:

- Los placeholders `<id_isar_de_un_plato>` viajaban dentro del literal JSON.
  **No son JSON válido.** Ahora los ids se resuelven con subselects sobre
  `productos` dentro de `jsonb_build_object`.
- El SQL Editor corre como `service_role` y **no trae JWT**, así que
  `current_tenant_id()` es NULL y la RPC habría abortado con `42501`. Ahora
  el snippet abre `BEGIN`, hace `SET LOCAL request.jwt.claims =
  '{"tenant_id":"..."}'` y cierra con `ROLLBACK`, así no deja la receta de
  prueba en la base.

### Plan 2026-10-28 (orden propuesto)

1. **Cerrar recetas de punta a punta** (30 min): crear una receta en la app,
   sincronizar, verla en Supabase y comprobar que el pull la deja en otro
   local. Es lo único que falta para dar por cerrado el frente.
2. **`procesarVenta` sin transacción** (`venta_service.dart:31`). Hoy descuenta
   lotes en `writeTxn` separados (`:93`, `:106`) y recién después inserta la
   venta: si falla en el medio, el stock queda descontado sin venta. Plan:
   mover el descuento + inserción a un único `writeTxn` en `IsarService`
   (método nuevo, p. ej. `registrarVentaConDescuento`), con los helpers de
   lote recibiendo el `Isar` en vez de abrir su propia transacción. Requiere
   confirmación porque toca un camino caliente.
3. **Rotar credenciales expuestas** (TODO:85): PAT de Supabase, password de
   la base y DSN de Sentry. Es del owner y no bloquea código.
4. **Sanear lotes + CHECK `restante <= inicial`** (TODO:71, :90): migración de
   limpieza de las 6 filas corruptas y después el `ALTER TABLE ... CHECK`.
   Toca datos, así que necesita OK explícito.
5. **Estaciones de cocina** (TODO:266, :270, :316): seed de Cocina/Barra/
   Postres con `orden` 0/1/2, selector "Sin estación (N)" en el KDS y
   `agregarItem` propagando `estacionId`.
6. **`productos.departamento_id` a Supabase** (TODO:312): columna + los 3
   sitios del sync.
7. Si sobra tiempo: `ProductDataTab` sin sección de receta en retail
   (TODO:891) y los confirmadores duplicados (TODO:98).

## Cierre 2026-10-28 — bugs resueltos, seguridad y release prep

### Commits del día (sobre `2d3b4ad`…`04068ff` previos)

| Commit | Contenido |
|---|---|
| `4e98916` | fix(inventario): descuento de stock ATÓMICO (TODO:38). 2 pasos en `IsarService`: `planificarDescuentoLotes` (lectura, FEFO, respeta local activo) + `registrarVentaConDescuento`/`aplicarDescuentosLotes` en UNA `writeTxn` con `StockInsuficienteException`. 11 tests nuevos (`test/services/descuento_lotes_plan_test.dart`). |
| `aa75920` | fix(productos): sección Receta oculta en retail/servicios — gate `_buildSeccionReceta` con `FeatureFlags.mostrarRecetas` (TODO:891). |
| `253d845` | refactor(carrito): confirmadores de ventas al mayor reusan `cart_dialogs.dart` (TODO:98). |
| `cc1332b` | test(ventas): fijador de TODO:901 — venta retail CON receta no genera 'Consumo receta' ni toca el ingrediente. |
| `643ba15` | feat(kds): seed de estaciones (primera versión, solo Settings). |
| `b4b26ae` | refactor(kds): seed movido a `BusinessModeNotifier.cambiarModo` + `seed_estaciones_service.dart` — cubre onboarding Y Settings; invalida providers de departamentos. |
| `8aba75d` | fix(sync): `.eq('tenant_id', tenantUuid)` + guard de local activo en las 10 descargas a secas de `sync_service.dart` (usuarios, proveedores, productos, ventas, detalle_ventas, marcas, gastos, departamentos, movimientos_lotes). Migración `20261028000001_backups_storage_policies.sql` PENDIENTE de aplicar por el owner. |

Ratificado en los commits: TODO:270 (chip "Sin estación" en KDS, ya existía en `kds_screen.dart:357`) y TODO:316 (`agregarItem` ya propaga `estacionId` en los 3 call sites).

### Estado de seguridad

- `service_role`: solo comentario (`supabase_config.dart:20`), sin clave en cliente.
- `env.json` y `sentry.properties`: NO trackeados (`.gitignore:64`/`:75`), nunca en el historial (`git log --all` vacío).
- Escaneo de secretos en trackeados: 0 candidatos (patrones api_key/secret/token/eyJ/JDBC/sentry-ingest/ghp_/sk-).
- Pendiente del owner: **rotar DSN de Sentry** (expuesto hasta 2026-10-10) y aplicar la migración de `backups`.

### Calidad

- Suite completa: **All tests passed! +958 ~1** (dos corridas; la segunda con el refuerzo de sync).
- `flutter analyze`: 0 errores / 0 warnings (17 infos preexistentes: `deprecated_member_use` en `pii_scrubber` + `avoid_print` en `check_lottie*.dart`).

### Versión

- `pubspec.yaml`: bump a **`1.1.6+12`** — siguiente release (Shorebird quemadas hasta `1.1.5+11`).
- Release vía GitHub Actions (Android `shorebird.yml`, Windows aparte `shorebird-windows.yml`); el owner dispara a mano. NO tag.

### Sigue abierto

1. Owner: correr `20261028000001_backups_storage_policies.sql` + repair.
2. Owner: rotar credenciales (TODO:85).
3. TODO:312 (`productos.departamento_id` a Supabase, columna + 3 sitios del sync).
4. TODO:71/:90 saneo de filas corruptas (toca datos, necesita OK).
5. `FiltroChip` target táctil 48px (TODO KDS), `DepartamentoSelector` sin test de widget.


---

## R.1b - Zonas y mesas multi-dispositivo (2026-10-28)

- **Esquema**: `supabase/migrations/20261028000002_zonas_mesas.sql` crea
  `zonas` y `mesas` con RLS `tenant_id = current_tenant_id()`, triggers
  `updated_at`, borrado logico (`eliminado`) e indice unico parcial
  `(tenant_id, nombre) WHERE eliminado = false`. Ambas entran a
  `supabase_realtime`. **El owner debe correr el SQL** y verificar con la
  query del final del archivo.
- **Modelo**: las zonas son editables (`ZonaEntity`, orden + activo). La
  mesa guarda `zonaNombre` como snapshot (funciona offline, sin JOIN) y
  `zonaSupabaseId` cuando la zona ya subio. `MesaEntity.zona` (enum) queda
  solo como fallback de mesas anteriores a R.1b; la UI lee siempre
  `zonaEfectiva`.
- **Borrado logico**: `eliminarMesa`/`eliminarZona` marcan `eliminado` y
  dejan `sincronizado = false`; el tombstone se sube a Supabase. La
  `claveUnica` de un tombstone lleva sufijo `#del<id>` para liberar el
  nombre en el indice unico local.
- **Sync**: `descargarZonasDesdeSupabase` -> `sincronizarZonasPendientes` ->
  `descargarMesasDesdeSupabase` -> `sincronizarMesasPendientes`. El pull de
  zonas va primero porque adopta por nombre lo sembrado en el dispositivo
  (evita choque con `(tenant_id, nombre)`); el pull de mesas resuelve
  `unidaConMesaId` en una segunda pasada por UUID.
- **Seed**: `SeedZonasRestaurante` siembra las 5 zonas historicas solo si el
  local es `restaurante` y no tiene ninguna, y completa `zonaNombre` en las
  mesas viejas. Se ejecuta de forma perezosa en `MesasNotifier.cargar`.
- **UI**: `zonas_dialog.dart` gestiona zonas (crear, renombrar con cascada,
  reordenar, eliminar si no tiene mesas). El filtro del salon y de caja usa
  el NOMBRE de la zona.
- **Fase B**: cerrada en la seccion siguiente (R.1c).
- **Calidad**: 9 tests nuevos en `test/integration/zonas_mesas_isar_test.dart`
  (clave unica, tombstones, orden de zonas, helpers de `MesaEntity`).

---

## R.1c - Comandas y KDS multi-dispositivo (2026-10-28)

- **Esquema**: `supabase/migrations/20261028000003_comandas.sql` crea
  `comandas` con `items` JSONB, `UNIQUE (tenant_id, sync_key)`, indice unico
  parcial `(tenant_id, mesa_id) WHERE estado IN ('abierta','enviada')`, RLS
  por `tenant_id`, trigger de `updated_at` y alta en `supabase_realtime`.
  **El owner debe correr el SQL** y verificar con la query del final.
- **Identidad**: `sync_key` (UUID generado en el primer push) es la
  identidad de sync. `id_isar` y `sessionId` NO sirven: son por dispositivo
  (`sessionId` vale `mesa:<idIsar>`). La unicidad es `(tenant_id, sync_key)`.
- **Una viva por mesa**: si dos cajas abren la misma mesa, la segunda recibe
  `23505` y su comanda se degrada a historico local (cancelada +
  `sessionId = mesa:<id>#<8 chars del syncKey>`) en vez de duplicar la mesa.
  El historico no choca con el indice parcial ni con `sessionId` unico.
- **Push antes del pull** en `sincronizarComandasPendientes` ->
  `descargarComandasDesdeSupabase`: la identidad la genera este dispositivo.
  El push sube vivas + cerradas/canceladas de los ultimos 2 dias (evita
  subir meses de historico en el primer sync); el pull trae vivas + tocadas
  en los ultimos 3 dias en dos consultas (sin `or()` de PostgREST).
- **Items**: viajan como JSONB con `producto_id` y `estacion_id` en UUID;
  al bajar se resuelven a ids locales (`obtenerProductoPorSupabaseId`,
  `obtenerDepartamentoPorSupabaseId`). `CartSessionItem` es `@embedded`, no
  puede ser tabla hija.
- **Estado de mesa**: NO se sincroniza. `MesasNotifier.cargar` lo deriva de
  las comandas vivas (viva -> ocupada; sin viva y ocupada -> libre;
  `reservada`/`porLimpiar` se respetan) y persiste con
  `marcarPendiente: false`. `_marcarMesaOcupada`/`_liberarMesa` idem.
- **KDS**: los 3 `put` directos de `IsarService` marcan `sincronizado =
  false`, asi el avance de cocina sube en el siguiente ciclo.
- **Provider**: `sync_provider` refresca `mesasProvider` y `comandasProvider`
  en cada `onDataChanged` (realtime de `comandas` incluido).
- **Calidad**: 11 tests nuevos en `test/integration/comandas_isar_test.dart`
  (identidad de sync, ventana de pendientes, busquedas del pull, `sessionId`
  de historicas, avance de KDS). Suite completa: **All tests passed!
  +978 ~1**; `flutter analyze` 0 errores / 0 warnings (17 infos
  preexistentes).
