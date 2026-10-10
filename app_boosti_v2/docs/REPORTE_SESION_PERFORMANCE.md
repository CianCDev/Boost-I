# Reporte de sesión — Performance de catálogo y pre-auditoría de producción

**Fecha:** 2026-10-09
**Alcance:** 4 fixes de performance, auditoría de completitud, actualización de docs.
**Versión:** `1.0.0+3` (Android build `+3`, era `+2`)

---

## 1. Resumen ejecutivo

El problema reportado era "el catálogo y el inventario se refrescan muchas veces al abrirlos".
El diagnóstico encontró **4 causas independientes**, de las cuales dos eran bugs estructurales
y no sólo ineficiencias.

| # | Causa | Tipo | Impacto |
|---|---|---|---|
| 1 | Una query a Isar **por cada card** del catálogo | Bug estructural | ~400 rebuilds + 200 round-trips al abrir la grilla |
| 2 | `ProductosState` sin `operator ==` | Bug estructural | 2 filtrados O(n) por cada `cargarProductos()`, × 15 call sites |
| 3 | `Timer.periodic` de 3 s con requests de 15 s | Bug estructural | 3–5 requests concurrentes permanentes a Telegram |
| 4 | `AutomaticKeepAliveClientMixin` inerte | Código muerto | 0 (engañoso, no costoso) |

**Todos aplicados.** `flutter analyze` limpio, **792 tests en verde, 0 fallos**.

---

## 2. Los fixes, en detalle

### 2.1 Marca por producto: de N queries a 1

**Antes** (`product_card.dart`):

```dart
ref.watch(marcaNombrePorSupabaseIdProvider(widget.producto.marcaSupabaseId!))
```

`marcaNombrePorSupabaseIdProvider` es un `FutureProvider.family` que hace
`isar.marcaEntitys.filter().supabaseIdEqualTo(...).findFirst()` — **una query por card**.
Con 200 productos: 200 providers, 200 round-trips, y como cada uno es un `AsyncValue`,
200 transiciones `loading → data` = **~400 rebuilds de card** solo por el nombre de la
marca, en cada apertura y en cada rebuild de la grilla.

Además la card pintaba un `CircularProgressIndicator` mientras esperaba, así que el
layout saltaba al llegar el dato.

**Ahora** (`marca_provider.dart`): un provider único que lee la colección **una vez** y
la indexa en un `Map<String, String>`:

```dart
final marcaNombresPorSupabaseIdProvider =
    FutureProvider<Map<String, String>>((ref) async {
  final marcasAsync = ref.watch(marcasProvider);
  // ...indexa en un Map
});
```

La card hace un lookup O(1), sin transiciones de estado y sin spinner.

**Por qué la grilla suffering más que la lista:** `ProductListTile` (vista lista) **no**
consultaba la marca. Solo `ProductCard` (vista grid). De ahí la asimetría que se notaba.

### 2.2 `ProductosState` sin `==`

Este era el hallazgo más importante, porque era una **asimetría dentro del propio repo**:

| State | `operator ==` | `hashCode` |
|---|---|---|
| `InventoryState` | sí (línea 51) | sí (63) |
| `CatalogState` | sí (52) | sí |
| **`ProductosState`** | **NO** | **NO** |

`items` es una lista freshly-allocated por `obtenerProductos()` en cada llamada, así que
comparar por identidad nunca daba igual. Consecuencia: `cargarProductos()` emitía **dos
veces siempre** (loading true → loading false), y la segunda época incluso cuando
`_listasSonIguales` detectaba que no había cambios.

Cada emisión disparaba los dos `ref.listen` que corren filtrado O(n) sobre todos los
productos (`catalog_provider.dart:139` e `inventory_provider.dart:113`).

Aplicado en dos partes:

1. `ProductosState` ahora tiene `==` y `hashCode` **estructurales**, con la misma lista de
   campos que chequea `_listasSonIguales` para que la comparación sea coherente.
2. `cargarProductos()` ya no emite cuando nada cambió:
   - `isLoading: true` solo si veníamos de un estado estable.
   - el `else` (nada cambió) **no toca el estado** si ya estamos en `isLoading: false`.

Resultado: un `cargarProductos()` sin cambios pasó de 2 filtrados O(n) a **0**.

### 2.3 Poll de Telegram con requests apilados

```dart
// ANTES
_pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
  await _checkUpdates();     // el request dura hasta 15 s
});
```

`getUpdates` se llama con `timeout=10` (long-polling) y el cliente tiene timeout de 15 s.
El timer disparaba cada 3 s **mientras el request anterior seguía en vuelo** → 3–5
requests concurrentes de forma permanente. Telegram entrega cada update a un solo
consumidor, así que los duplicados además se perdían.

Ahora es un loop secuencial con `await`, más un flag `_activo` porque **cancelar el
`Timer` no alcanza**: si el loop está dentro de `_checkUpdates()`, sigue vivo y pide el
ciclo siguiente.

```dart
while (_activo && _config != null && _config!.enabled) {
  await _checkUpdates();
  if (!_activo || ...) break;
  await Future.delayed(_intervaloPolling);
}
```

### 2.4 `wantKeepAlive` inerte (corrección de un error mío)

En el diagnóstico anterior afirmé que "la pantalla nunca se destruye". **Era falso** y lo
corregí. `main_pos_screen.dart:1085` abre la pantalla con `MaterialPageRoute`, y un route
pushed no recibe `KeepAliveNotification`, que es lo único que hace que
`AutomaticKeepAliveClientMixin` actúe. Flutter solo lo consulta dentro de un `PageView` o
un `IndexedStack`.

O sea: la pantalla **sí** se destruye al hacer pop, y los timers y suscripciones del
`dispose()` corren bien. El mixin solo mantenía la idea contraria.

Se eliminó el mixin, el `wantKeepAlive` y el `super.build(context)` que dependía de él,
con una nota en la cabecera de la clase explicando por qué.

---

## 3. Correcciones y errores de esta sesión

Se registran porque son parte del estado real del código.

| Tipo | Qué pasó |
|---|---|
| **Claim falso** | Afirmé que la pantalla nunca se destruye por `wantKeepAlive`. Era inerte: un route pushed no recibe `KeepAliveNotification`. Corregido y documentado en el código. |
| **Claim falso** | Dije que `ProductCard` "no se instanciaba en ningún lado". Era un error de filtro: excluí `inventory_catalog_screen.dart` porque su path contiene "inventory". El grep borró al único caller real. |
| **Regresión** | Quitar `AutomaticKeepAliveClientMixin` dejó `super.build(context)` huérfano y rompió la compilación. Detectado por `analyze` y corregido. |
| **Regresión** | `marcaNombresPorSupabaseIdProvider` es `AsyncValue`, no `Map`. Faltaba `.valueOrNull`. Detectado por `analyze`. |
| **Autocorrecciones** | Se colaron ideogramas CJK en comentarios dos veces, y una palabra china dentro de este reporte. Detectados por el chequeo automático y reescritos. |
| **Falsa alarma** | Reporté que los tests de `cart_controller` no existían. Era un `workdir` ausente en la shell. |
| **Grep engañoso** | `Select-String` sin límites de palabra contó subcadenas (`_confirmarLimpiar` dentro de `_confirmarLimpiarCarrito`) y me hizo reportar 3 call sites inexistentes. Corregido con regex de límites. |

---

## 4. Estado de verificación

```
flutter analyze   →  No issues found!
flutter test      →  792 pasaron, 1 skip, 0 fallos   (03:29)
```

### El último test rojo: `local_switching_test.dart`

La suite tenía **un** test que fallaba, y solo en la corrida completa:
`local_switching_test.dart:190`, "un cambio encadenado A→B→A funciona".

```
IsarError: Isar instance has already been closed
  marca_provider.dart:38          marcasProvider  → await IsarService().db
  local_actual_provider.dart:227   setLocalActual → _ref.invalidate(marcasProvider)
```

**Diagnóstico.**

- El test sí mockea Isar, pero solo por constructor, en el `LocalActualNotifier`.
  `IsarService()` es un singleton de proceso (`isar_service.dart:79`), así que cualquier
  otro provider que lo llame directo ignora el mock por completo.
- `setLocalActual()` hace **21 `invalidate`** (`local_actual_provider.dart:224-248`).
  Riverpod monta el provider invalidado para recorrer su grafo, así que todos los que
  quedan con listener se construyen de verdad durante el hot-switch.
- De esos 21, al menos **tres** alcanzan Isar en su factory: `marcasProvider`
  (`marca_provider.dart:38`), `clientesProvider` (`clientes_provider.dart:26`, vía
  `isarServiceProvider`) y `empleadosProvider` (`empleados_provider.dart:17`).
- `test_helpers.dart:59-66` cierra **todas** las instancias de Isar del proceso de forma
  global en el `tearDown`. El archivo anterior al que testea corre justo antes, así que el
  primer provider que se monta lo encuentra cerrado.

**Fix aplicado** (`test/local_switching_test.dart`): sustituir en los `overrides` del
`ProviderContainer` los tres que alcanzan Isar, más el stub de `obtenerClientes` que el
`ClientesNotifier` pide en su constructor.

```dart
isarServiceProvider.overrideWithValue(mockIsar),
marcasProvider.overrideWith((ref) => Stream.value(const [])),
empleadosProvider.overrideWith((ref) => Future.value(const [])),
```

**Un intento fallido en el camino, registrado.** La primera versión del fix fue abrir un
Isar real y temporal en el `setUp`, en vez de sustituir providers. La idea era general:
en vez de parchear de a uno, garantizar que la base exista. **No funciona**: con base
real, `marcasProvider`, `clientesProvider` y `empleadosProvider` se montan de verdad y
dejan streams abiertos; el `resetForTesting()` del siguiente `setUp` ya no puede
completar y los 8 tests quedan en `did not complete`. Se revirtió completo (el archivo
volvió a su estado de HEAD, verificado con `git diff`) antes de aplicar la versión
final.

**Verificación.**

| Corrida | Resultado |
|---|---|
| `local_switching_test.dart` aislado | 8/8 |
| `isar_service_integration_test` + `local_switching_test` (el par que fallaba, en orden) | **40/40** |
| Suite completa | **792 / 1 skip / 0 fallos** |

### Dos tests heredados que también pasaron

`docs/TODO.md` listaba estos dos como fallando. Hoy pasan:

| Test | Fallo que figuraba |
|---|---|
| `rebuild_audit_test.dart` | `TimeoutException` a los 30 s |
| `inventory_catalog_screen_test.dart` | 4 × `BcvController used after disposed` |

El primero es una medición de rebuilds, y los fixes 2.1 y 2.2 de este reporte lo hacen
terminar sin timeout. Eso es **evidencia indirecta** de que los fixes funcionan, aunque no
sea una medición del antes/después.

Los `TimeoutException` que aparecen en el log de la suite son los avisos del propio
`tearDownIsarForTest`, que los captura y no son fallos.

---

## 5. Verificaciones estáticas

| Archivo | Líneas | Balance `{}` `()` `[]` | CJK |
|---|---|---|---|
| `productos_provider.dart` | 380 | 0/0/0 | 0 |
| `marca_provider.dart` | 304 | 0/0/0 | 0 |
| `product_card.dart` | 452 | 0/0/0 | 0 |
| `telegram_service.dart` | 566 | 0/0/0 | 0 |
| `inventory_catalog_screen.dart` | 918 | 0/0/0 | 0 |
| `test/local_switching_test.dart` | 339 | 0/0/0 | 0 |

Ningún log `DIAG`, ninguna dependencia nueva.

---

## 6. Lo que queda para producción

Nada de lo hecho acá bloquea el lanzamiento. Lo que sigue abierto, en orden de
criticidad:

1. **7 migraciones de Supabase sin aplicar.** Es lo único que bloquea de verdad: la app
   local funciona pero la nube queda inconsistente. Ver sección siguiente.
2. **El fallo de red de BCV ya no miente**, pero la app **no refresca sola al arrancar**:
   `init()` solo lee SharedPreferences y el primer fetch depende de que se construya
   `main_pos_screen`.
