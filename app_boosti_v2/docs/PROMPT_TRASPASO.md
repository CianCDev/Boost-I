# Contexto de trabajo — POS `app_boosti_v2`

> Prompt de traspaso. Copiar todo este bloque al agente siguiente.
> Última actualización: sesión del 2026-10-10.

---

## 1. Identidad del proyecto

- **Repo:** `C:\Users\Yan\app_gestion_m` (este es el root de git; `app_boosti_v2/` es el paquete Flutter dentro).
- **App Flutter:** `C:\Users\Yan\app_gestion_m\app_boosti_v2`
- **Qué es:** POS multi-tenant, offline-first, con inventario por lotes, ventas al
  mayor, restaurante (mesas/comandas/KDS), proveedores y suscripciones.
- **Pila:** Flutter 3.47.2 / Dart 3.13.2 · Isar (cache local) · Supabase (Auth +
  Postgres + Realtime) · Riverpod · Kotlin 2.1.10 · AGP 8.11.1 · Java 21 · API 36.
- **Versión actual:** `1.0.0+3` en `pubspec.yaml`.
- **Arquitectura:** Clean Architecture por característica en
  `lib/features/pos/{data,domain,presentation}/`.
- **Idioma:** TODO en español. Código, comentarios, docs y respuestas.

---

## 2. Estado de git — importante

**Prácticamente todo el trabajo de la sesión está SIN COMMIT.** Además
`test/local_switching_test.dart` ni siquiera está trackeado (aparece como `??`),
por lo que `git diff` sobre ese archivo no muestra nada aunque el archivo tenga
cambios. Para verificar cambios en él, leer el archivo, no usar `git diff`.

No hacer `git stash` ni `git checkout`: el working tree tiene ~91 archivos
modificados de varias sesiones y es fácil perder trabajo.

---

## 3. Reglas que el usuario impone (respetar siempre)

1. **Antes de tocar un archivo, leerlo COMPLETO** y reportar la firma real con
   `archivo:línea`. Si difiere de lo asumido, decirlo ANTES de editar.
2. **Diagnóstico antes de editar.** Si algo no está claro, preguntar.
3. **No añadir dependencias.**
4. **No tocar `*.g.dart` a mano** — usar `build_runner`.
5. **No borrar archivos, carpetas ni tablas sin confirmación explícita.**
6. **No dejar logs `DIAG`.** Verificación obligatoria al terminar cada turno:
   balance `{}` `()` `[]` = 0, líneas nuevas >80 = 0, CJK = 0, imports resuelven.
7. **Los tests son spec.** Si un cambio rompe un test, reportar el error exacto y
   decidir juntos. No editar tests a ciegas.
7b. Chequear CJK y palabras en inglés: se colaron varias veces.
8. **Reportes en español con diffs literales.**
9. Una sub-tarea por turno (el usuario lately aplica varios).

---

## 4. Cómo correr las herramientas en este entorno

Los `.bat` de PATH se cuelgan. Usar el snapshot de `flutter_tools` directamente:

```powershell
$dart = "C:\Users\Yan\dev\flutter\bin\cache\dart-sdk\bin\dart.exe"
$snap = "C:\Users\Yan\dev\flutter\bin\cache\flutter_tools.snapshot"
$pkg  = "C:\Users\Yan\dev\flutter\packages\flutter_tools\.dart_tool\package_config.json"
& $dart --packages=$pkg $snap analyze --no-pub
& $dart --packages=$pkg $snap test    --no-pub
```

- **Patrón obligatorio:** 2 llamadas. Lanzar desacoplado con
  `Start-Process -NoNewWindow` + `-RedirectStandardOutput`, y leer el log en la
  llamada siguiente. El harness mata scripts con `Start-Sleep` largo (exit 255).
- `flutter analyze` y `flutter test` se pelean por el startup lock: no lanzarlos
  a la vez.
- Suite completa ≈ 3.5 min. `analyze` completo ≈ 12–60 s.
- Encoding: leer siempre con `Get-Content -Encoding UTF8`.
- Hay procesos `dart` filtrados de corridas previas que consumen CPU. No se han
  limpiado; el usuario nunca dijo si se cierran.

---

## 5. Estado verificado a la entrega

```
flutter analyze  →  No issues found!
flutter test     →  792 pasaron · 1 skip · 0 fallos   (03:29)
```

**Suite completamente en verde.** Esto incluye dos tests que antes fallaban
(`rebuild_audit_test.dart` con `TimeoutException` y
`inventory_catalog_screen_test.dart` con 4 × `BcvController used after disposed`).

Cuidado: hay procesos `dart`/`flutter` huérfanos de corridas previas. Antes de
confiar en un log, verificar que sea de la corrida actual.

---

## 6. Decisiones de arquitectura ya tomadas - NO revertirlas sin razón

Estas están codificadas y documentadas. Cambiarlas reintroduce bugs ya cerrados.

| Decisión | Por qué |
|---|---|
| **La BD remota es la fuente de verdad.** `esquema.sql` está DESCARTADO (29 tablas vs 39 reales). | El archivo local quedó desactualizado. |
| **Los lotes son la fuente única del stock.** `productos.stock` es cache derivado, escrito solo por `IsarService.recalcularStockDe()`. Escribir a mano `producto.stock` está prohibido. | La duplicación causó el incidente del Arroz (165→175) sin cambio real de inventario. |
| **El carrito NO descuenta stock.** El descuento real ocurre en `VentaService.procesarVenta` vía FEFO. | El carrito reserva, no consume. |
| **Nunca reasignar `localOrigenId` de un pedido.** Si el local no tiene UUID se omite el ciclo y se reintenta. | El fallback destructivo causaba corrupción cross-local. |
| **`obtenerLocalActivo`: prefs ANTES que JWT.** | El hot-switch escribe prefs antes de refrescar tenant; el JWT siempre devuelve el tenant original. |
| **`marcarLocalComoActivo` NO desactiva los otros locales.** `activo` = "habilitado", no "es el actual". | Ya corregido. |
| **Cambiar de local NO se gatea por plan.** Solo en la pantalla/diálogo de Locales; en Pedidos/Lotes/Proveedores/Departamentos solo un badge de lectura. | Gatearlo creaba un deadlock: al cambiar a un local sin plan desaparecían a la vez la entrada de menú y el botón de volver. |
| **`ModuleGate` gatea por `planActivo`**, no por `flags.lotes` / `flags.pedidosProveedores` (ambos `defaultVisible: true`). | Se reducen a `planActivo`. |
| **Fallback de `planActivo` cacheado** vive en `suscripcion_provider.dart`, no en `bootstrap.dart`. | Evita dependencia `core → presentation`. Si nunca hubo caché, **deniega** (fail-closed). |
| **Vencido de lote = BAJA**, no reposición. Se conserva el valor legacy `'traspaso'` en `MovimientoLoteEntity.tipo`. | Hay movimientos ya escritos con ese valor. Los 3 switches de historial mapean ambos. |
| **Umbrales de vencimiento 3/7/15 días**, tomando la escala más rica de `lotes_group_card.dart:386-397`. VENCIDO = rojo `#DC2626`. | El violeta colisionaba con "próximo a vencer". |
| **`desdeCache` del BCV = solo `cacheObsoleta`.** Se usa `fechaActualizacion` de la API, no `DateTime.now()`. | Era falso positivo de "Sin conexión". `cacheReciente` es el estado NORMAL al abrir la app. |
| **`localActualUuidProvider` va en `locales_provider.dart`**, no en `local_actual_provider.dart`. | Evitar criss-cross de imports. |
| **`isarServiceProvider` es el punto de inyección correcto de Isar.** | `IsarService()` es singleton de proceso; inyectar por constructor en un solo notifier no alcanza. |

---

## 7. Reglas de performance que quedaron como norma del repo

Documentadas en `MEMORY.MD` §§3–5. Aplicarlas al escribir código nuevo:

1. **Todo `State` de un `StateNotifierProvider` lleva `==` y `hashCode`**
   estructurales. `items` es una lista freshly-allocated, así que la identidad nunca
   da igual. Sin `==`, cada carga emite y dispara los `ref.listen` que recorren
   todos los productos: 2 pasadas O(n) por carga, × 15 call sites.
   **Patrón: si nada cambió, no tocar `state`.**
2. **Prohibido un `FutureProvider.family` dentro de un `itemBuilder`.** Con 200
   ítems son 200 providers y ~400 rebuilds. Usar un provider que lea la colección
   una vez y devuelva un `Map` para lookup O(1) (`marcaNombresPorSupabaseIdProvider`).
3. **Nunca `Timer.periodic` con un callback async más lento que el período.**
   Dispara sin esperar y apila requests. Usar loop `while` con `await`, más un flag
   explícito: cancelar el `Timer` no alcanza si el loop está dentro del `await`.
4. **`AutomaticKeepAliveClientMixin` es inerte en un route abierto con
   `MaterialPageRoute`.** Solo funciona dentro de `PageView`/`IndexedStack`. El
   código inerte que miente es peor que el código muerto.

---

## 8. Trabajo completado en la última sesión (4 fixes de performance)

| # | Fix | Archivo |
|---|---|---|
| 1 | Marca por producto: de **200 queries a Isar por card** a 1 `Map` único. Eliminó también el `CircularProgressIndicator` que hacía saltar el layout. | `marca_provider.dart` (nuevo `marcaNombresPorSupabaseIdProvider`), `product_card.dart` |
| 2 | `ProductosState` sin `operator ==` → ahora estructural + la rama "sin cambios" **no emite**. De 2 filtrados O(n) a **0** por carga sin cambios. | `productos_provider.dart` |
| 3 | `Timer.periodic(3s)` de Telegram con long-poll de hasta 15 s → **3–5 requests concurrentes permanentes**. Ahora loop secuencial + flag `_activo`. | `telegram_service.dart` |
| 4 | `AutomaticKeepAliveClientMixin` inerte eliminado (era código muerto que mentía). | `inventory_catalog_screen.dart` |

**Corrección importante registrada:** en el diagnóstico anterior se afirmó que
"la pantalla nunca se destruce por `wantKeepAlive`". **Era falso**:
`main_pos_screen.dart:1085` la abre con `MaterialPageRoute`, y un route pushed no
recibe `KeepAliveNotification`. La pantalla sí se destruye al hacer pop.

### El test que quedaba rojo — ya resuelto

`local_switching_test.dart` fallaba solo en la suite completa con
`IsarError: Isar instance has already been closed`.

Causa: `MockIsarService` solo se inyecta en el `LocalActualNotifier` por
constructor; `IsarService()` es singleton de proceso. `setLocalActual()` hace 21
`invalidate` y Riverpod **monta** los providers para recorrer su grafo. De esos 21,
tres alcanzan Isar en su factory: `marcasProvider`, `clientesProvider` (vía
`isarServiceProvider`) y `empleadosProvider`. `test_helpers.dart:59-66` cierra
**todas** las instancias de Isar del proceso en el `tearDown`, y el archivo anterior
al testeado corre justo antes.

Fix (en los `overrides` del `ProviderContainer`):

```dart
isarServiceProvider.overrideWithValue(mockIsar),
marcasProvider.overrideWith((ref) => Stream.value(const [])),
empleadosProvider.overrideWith((ref) => Future.value(const [])),
```

+ stub de `obtenerClientes` (el `ClientesNotifier` lo pide en su constructor).

**Los tres hacen falta.** Parchear solo `marcasProvider` mueve el error al
siguiente, porque el `invalidate` de la línea 227 aborta el resto del `setLocalActual`.

⚠️ **Intento fallido, no repetir:** la primera versión del fix fue abrir un Isar
real y temporal en el `setUp` en vez de sustituir providers. **No funciona**: con
base real los tres providers se montan de verdad, dejan streams abiertos, y el
`resetForTesting()` del siguiente `setUp` ya no completa → los 8 tests quedan en
`did not complete`. Se revirtió completo antes de aplicar la versión final.

---

## 9. 🔴 BLOQUEANTE PRE-PRODUCCIÓN

### 9.1 Las 7 migraciones de Supabase sin aplicar

Es **lo único que bloquea de verdad el lanzamiento**. La app local funciona; la nube
queda inconsistente. Van **en orden**:

```
supabase/migrations/
  20261009000000_sync_venta_completa.sql       RPC atómico de venta
  20261009000001_ajustar_stock_uuid.sql
  20261009000002_ajustar_stock_uuid_rename.sql  renombra a ajustar_stock_uuid
  20261009000003_lotes_fuente_unica.sql        lotes = fuente de verdad
  20261009000004_ajustar_stock_numeric.sql     p_cantidad integer -> numeric
  20261009000005_reset_inventario_pruebas.sql
  20261009000006_lotes_unique.sql              UNIQUE (tenant_id, id_isar)
```

`00001` y `00002` **van juntos y en ese orden**: `00001` crea la función con la
firma vieja, `00002` la renombra.

`movimientos_lote` **no está en ninguna** (es tabla no versionada), así que el
rename `'traspaso'` → `'baja'` no depende de migraciones.

### 9.2 `procesarVenta` no tiene transacción

Si falla después de consumir los lotes (FEFO), el stock queda descontado sin venta
registrada. Pérdida silenciosa de datos.

### 9.3 Datos corruptos en producción — sanear a mano

- 2 lotes con `restante > inicial` (tenant JAHTLABS, `id_isar=1`).
- 4 lotes del Arroz (`id_isar=2`) con `cantidad_inicial=100` y `restante` 512–519.
- `productos_id_isar` es UNIQUE **global**, no por tenant → bug latente multi-tenant.

---

## 10. Deuda abierta

En `docs/TODO.md`, con los dos bloques nuevos al tope (🔴 bloqueantes /
🔶 deuda de sesión). Lo más relevante:

- **La app no refresca la tasa BCV sola al arrancar.** `bcv_provider` llama
  `init()`, que solo lee SharedPreferences; el primer `actualizarTasa()` depende de
  que se construya `main_pos_screen`. Con el fix del mensaje ya no miente, pero la
  tasa real puede tener 24 h sin actualizarse.
- **El badge de vencimiento solo existe en el catálogo.** `InventoryProductCard`
  y `WholesaleProductCard` no lo tienen.
- **La colisión de badges en la card no se verificó en device.** `clasificarCompacto`
  se activa con `isMobile && stockBajo`, pero la colisión real depende del **ancho**
  de la card (depende del `crossAxisCount` del `ViewModeToggle`, no del dispositivo).
  Fix: `LayoutBuilder` sobre el ancho.
- **`marcaNombresPorSupabaseIdProvider` depende de `marcasProvider`** (un
  `StreamProvider`). Si el hot-switch invalida `marcasProvider` con Isar ya cerrado,
  el provider se monta y falla. Hoy no dispara porque ningún test monta
  `ProductCard`, pero es el mismo patrón que rompía `local_switching_test`.
- **Falta confirmar que el polling de Telegram sigue funcionando** tras pasarlo a
  loop secuencial. El ritmo cambió: con long-poll de 10 s, el ciclo real queda en ~13 s.
- **Deadlock abierto:** `menu_config.dart:181` sigue con
  `'locales' => flags.multiLocal`. El escape hatch del panel lateral ya no está
  gateado (`side_panel.dart:314`), pero la entrada de menú del hub de Configuración
  sigue siéndolo.

### Funcionalidades incompletas

| Módulo | % |
|---|---|
| POS retail (carrito, cobro, atajos) | 95% |
| Inventario y lotes (FEFO) | 90% |
| Ventas al mayor | 85% |
| Pedidos a proveedores | 85% |
| Proveedores / Departamentos | 85% |
| Backup / OTA / Sentry | 85% |
| Lotes ↔ BCV | 80% |
| Offline-first | 75% |
| Multi-tenant + planes | 70% |
| WhatsApp / Telegram | 70% |
| Restaurante (mesas, comandas, KDS) | 60% |
| Servicios (citas, agenda) | 40% |
| Impresión fiscal | 30% |

**Global ~78%.** Lo que frena el lanzamiento a 100% son las migraciones (9.1),
la transacción de `procesarVenta` (9.2) y los datos corruptos (9.3).

---

## 11. Documentos técnicos

| Archivo | Contenido |
|---|---|
| `MEMORY.MD` (160 líneas) | Decisiones de arquitectura. **§§3–5** performance, **§6** plan por tenant, **§7** prefs>JWT, **§8** fecha BCV, **§9** código inerte, **§10** singleton de Isar. Tabla de historial de soluciones al final. |
| `docs/business_rules.md` (204 líneas) | §§1–9 suscripciones/planes. **§§10–14** agregadas: lotes = fuente única, FEFO, vencimientos, baja de lote, locales y planes, tasa de cambio. |
| `docs/TODO.md` (386 líneas) | Bloques 🔴 y 🔶 al tope, luego KDS/R.3 y deuda histórica. |
| `docs/REPORTE_SESION_PERFORMANCE.md` (248 líneas) | Informe de la sesión de performance: los 4 fixes, los errores propios, el diagnóstico del test rojo, el intento fallido. |
| `docs/HANDOFF_CONTROL_CENTER.md` (418 líneas) | Handoff del control center. |
| `AGENTS.MD` (398 líneas) | Reglas del agente. |

Todos verificados: balance `{}`/`()`/`[]` = 0, CJK = 0.

---

## 12. Estado mental del proyecto — leer antes de tocar

**Vamos a producción.** El usuario está listo para lanzar. La prioridad ahora es
**aplicar las migraciones (9.1)**, no agregar funcionalidad.

Trampas del terreno, ya pisadas:

- `esquema.sql` miente. La BD remota tiene 39 tablas; el archivo, 29.
- Los IDEogramas CJK se me colaron 3 veces en comentarios y 1 vez en un doc. El
  chequeo automático es lo único que las agarró.
- `Select-String` sin límites de palabra contó subcadenas y me|reportó call sites
  inexistentes. Usar regex con `\b`.
- Greps con filtro de path excluyendo `inventory_catalog_screen.dart` borraron al
  único caller real. Ya me costó una falsa alarma.
- Afirmé dos cosas falsas sobre `ProductCard` y `wantKeepAlive` antes de
  verificarlas. **Verificar antes de afirmar.**
- No hay forma de medir en runtime: no se puede abrir la app ni DevTools desde acá.
  El impacto de los fixes de performance está estimado por conteo estático
  (200 queries → 1, 2 filtrados → 0), que es sólido pero no es medición.