## 🔴 BLOQUEANTE PRE-PRODUCCIÓN (agregado 2026-10-09)

> Nada de esto lo inventó esta sesión: es el estado real. Ordenado por criticidad.

- [ ] **Aplicar 7 migraciones de Supabase, EN ORDEN.** La app local funciona pero la nube
      queda inconsistente. Es lo único que bloquea de verdad el lanzamiento.
      ```
      20261009000000_sync_venta_completa.sql      RPC atómico de venta
      20261009000001_ajustar_stock_uuid.sql
      20261009000002_ajustar_stock_uuid_rename.sql  renombra a ajustar_stock_uuid
      20261009000003_lotes_fuente_unica.sql        lotes = fuente de verdad
      20261009000004_ajustar_stock_numeric.sql     p_cantidad integer → numeric
      20261009000005_reset_inventario_pruebas.sql
      20261009000006_lotes_unique.sql              UNIQUE (tenant_id, id_isar)
      ```
      `00001` y `00002` van juntos y en ese orden: `00001` crea la función con la firma
      vieja, `00002` la renombra. `movimientos_lote` **no** está en ninguna de estas (es
      una tabla no versionada), así que el rename `'traspaso'` → `'baja'` no depende de
      migraciones.
- [x] **`local_switching_test.dart` fallaba en la suite completa** (pasa 8/8 aislado).
      `IsarError: Isar instance has already been closed`, vía
      `local_actual_provider.dart:227` → `invalidate(marcasProvider)` → `IsarService().db`.
      **Resuelto el 2026-10-09.** Causa: `MockIsarService` solo se inyecta en el
      `LocalActualNotifier` por constructor, pero `IsarService()` es un singleton de
      proceso (`isar_service.dart:79`), así que cualquier otro provider lo ignora. El
      `tearDown` del archivo anterior (`test_helpers.dart:59-66`) cierra todas las
      instancias de Isar del proceso, y el primer provider que se monta crashea.
      **Fix**: sustituir en los `overrides` los tres que alcanzan Isar —
      `isarServiceProvider` (cubre `clientesProvider`), `marcasProvider` y
      `empleadosProvider`. Verificado con el par que lo disparaba
      (`isar_service_integration_test` + `local_switching_test`): 40/40.
- [ ] **`procesarVenta` no tiene transacción.** Si falla después de §1 (consumir lotes), el
      stock queda descontado sin venta registrada. Pérdida silenciosa.
- [ ] **Datos corruptos en producción que hay que sanear a mano:**
      - 2 lotes con `restante > inicial` (tenant JAHTLABS, `id_isar=1`).
      - 4 lotes del Arroz (`id_isar=2`) con `cantidad_inicial=100` y `restante` 512–519.
      - `productos_id_isar` es UNIQUE **global**, no por tenant: bug latente multi-tenant.
- [ ] **`inventory_catalog_screen_test.dart` — 4 fallos** (`BcvController used after
      disposed`) y **`rebuild_audit_test.dart` — `TimeoutException` 30s**. Heredados.

## 🔶 Deuda abierta de esta sesión (2026-10-09)

- [ ] **La app no refresca la tasa BCV sola al arrancar.** `bcv_provider` llama `init()`,
      que solo lee SharedPreferences; el primer `actualizarTasa()` depende de que se
      construya `main_pos_screen`. Con el fix del mensaje ya no miente, pero la tasa real
      puede tener 24 h sin actualizarse si el usuario no abre esa pantalla. Fix:
      disparar un fetch de fondo desde `init()`.
- [ ] **El badge de vencimiento solo existe en el catálogo.** `InventoryProductCard`
      (`inventory_screen.dart`) y `WholesaleProductCard` no lo tienen.
      `ProductCard` y `ProductListTile` sí.
- [ ] **La colisión de badges en la card no se verificó en device.** El label compacto
      (`clasificarCompacto`) se activa con `isMobile && stockBajo`, pero la colisión real
      depende del **ancho** de la card, que depende del `crossAxisCount` del
      `ViewModeToggle`, no del dispositivo. Con `ViewModeToggle` un usuario en desktop
      puede tener cards angostas con el label largo. Fix: `LayoutBuilder` sobre el ancho.
- [ ] **`marcaNombresPorSupabaseIdProvider` depende de `marcasProvider`** (un
      `StreamProvider`). Si el hot-switch invalida `marcasProvider` con Isar ya cerrado, el
      provider se monta y falla. Hoy no dispara porque ningún test monta `ProductCard`,
      pero es el mismo patrón que rompe `local_switching_test`. Fix robusto: leer la
      colección directo en vez de `watch`ear el stream.
- [ ] **Falta confirmar que el polling de Telegram sigue fncionando** tras pasarlo de
      `Timer.periodic` a loop secuencial. El cambio elimina requests apilados pero
      cambia el ritmo: ahora el intervalo se mide entre el fin de un request y el
      arranque del siguiente (con long-poll de 10 s, el ciclo real queda en ~13 s).
- [ ] **Quedan confirmadores duplicados** fuera de `cart_dialogs.dart`:
      `inventory_catalog_screen._limpiarCarritoConConfirmacion` ya usa el helper, pero
      `crear_pedido_dialog` y otros siguen con copies propios.

## KDS · R.3 pendientes

- [ ] **`mesa_chip.dart:82` promete "Ver" y abre "Asignar".** Cuando hay
      comandas vivas, el chip muestra "N mesas abiertas · Ver" pero su
      `onTap` llama a `AsignarMesaDialog.mostrar`. El mesero toca esperando
      una lista y recibe el formulario de asignar. No hay ninguna pantalla
      que liste comandas: `ComandaScreen` solo se empuja desde
      `salon_screen.dart:122`, y `ComandasState.activas` no tiene consumidor
      de UI (solo se usa `.length` para el contador del chip).
      **Fix**: un `ComandasListaScreen` agrupado por mesa, al que el chip
      debe ir cuando el texto dice "Ver". Deuda de R.2.
- [ ] **`cargar()` lee TODAS las comandas del local en cada cambio.**
      `cambiarCantidadItem`, `actualizarNotaItem`, `pausarItem`,
      `marcarEnPreparacion`… terminan con `await cargar()`, que llama a
      `obtenerComandasDeLocal(localId)` (30-100 comandas en un local grande).
      Con 100 items en pantalla se nota. R.3.2 lo dejó tal cual a
      propósito. **Fix**: actualizar solo la comanda tocada en `state`, sin
      recargar el resto.
- [x] ~~`ComandasNotifier` no es testeable end-to-end~~ → **RESUELTO en
      R.3.2**: `ComandasNotifier(this._ref, {IsarService? isar})` +
      `comandasProviderConIsar` para tests. Cubiertos `pausarItem`,
      `reanudarItem`, `itemsEnColaPorEstacion` y `marcarEnPreparacion`.
- [x] ~~`ProductoEntity.departamentoId` sin UI de asignacion~~ →
      **RESUELTO en R.3.2 PASO D**: `DepartamentoSelector` en la sección
      "Identificación" del form de producto + bulk "Asignar estaciones por
      categoría" en `departamentos_screen.dart` + fila de solo lectura en
      `product_detail_dialog.dart`.
- [ ] **Sincronizar `productos.departamento_id` a Supabase (R.1b).** Sigue
      local-only por decisión D2a: el campo NO está en `toJson`/`fromJson`.
      Hay un test (`NO aparece en toJson`) que blinda esa decisión. El bulk
      ya marca `sincronizado = false` para forzar el push cuando exista la
      columna. **No añadirlo antes de que la columna exista**, o el push de
      productos falla.
- [ ] **Seed de estaciones de cocina.** `DepartamentoSelector` abre
      `mostrarDialogoCrearEstacion`, que crea UNA estación con el nombre
      que se escriba. El seed de "Cocina / Barra / Postres" marcados por
      defecto con `orden` 0/1/2 es de PASO E.
- [ ] **Selector "Sin estacion (N)" en el KDS (PASO E).** `ticketsEnCola`
      y `totalItemsEnKds` ya cuentan los items con `estacionId == null`
      (ajuste 1 del usuario). Falta el chip que los filtre.
- [ ] **`DepartamentoSelector` sin test de widget.** Es el único componente
      de `common/` que lee providers; montarlo exige `ProviderContainer` +
      Isar temporal. PASO D lo cubre indirectamente (los tests del bulk
      verifican `departamentoId` sobre Isar real), pero el dropdown en sí no
      se monta.
- [ ] **Onboarding sin stations creadas.** Si el local no tiene ninguna, el
      bulk muestra filas con el `DepartamentoSelector` en su estado vacío
      ("Este local no tiene estaciones") y el botón de crear. Falta el
      seed de PASO E para que un local nuevo arranque con algo.
- [ ] **Migrar los 6 helpers privados de duracion.** Son `static` privados
      (`comanda_screen._duracion`, `mesa_card._duracion`,
      `asignar_mesa_dialog._duracion`, `parked_carts_dialog`,
      `cash_closing_screen._calcularTiempo`, `empleado_card`) con formatos
      distintos entre si. R.3.2 creo `DuracionUtils` para los componentes
      nuevos pero **no toco esas pantallas**: dos estan en `admin_console`,
      fuera del alcance del POS.
- [ ] **StickyNote movible (v2).** R.3.2 lo entrega estatico. El drag & drop
      con posicion persistida es una fase aparte.
- [ ] **`QuantityControl` con target tactil de 36 px.** Material recomienda
      48 px. Se eligio 36 para que una fila del KDS no desborde en
      telefono. Si en la prueba sale dificil de tocar, `compacto: false`
      sube a 44 px (no a 48: habria que tocar el layout).
- [ ] **`ProductThumbnail` en los 13 `Image.network` del repo.** El widget
      centraliza el placeholder y anade `loadingBuilder`, pero el catalogo
      sigue con su copia. Migrarlos es una pasada de refactor aparte.

- [ ] **D4a · `contarProductosPorDepartamento()` sigue siendo un hack.**
      `isar_service.dart` compara `producto.categoria` (texto libre) contra
      `departamento.nombre`, porque hasta R.3.1 `ProductoEntity` no tenía
      relación real con `DepartamentoEntity`. Ahora SÍ existe
      `ProductoEntity.departamentoId`, así que hay DOS vías de relación y
      este método usa la vieja. Migrar a `producto.departamentoId == id`
      cuando haya onboarding para "asignar departamento a producto".
      **No migrar antes**: hoy devuelve el conteo que la UI de
      departamentos muestra, y cambiarlo a 0 rompería esa pantalla.
- [ ] **R.3.2 · `DepartamentoEntity.orden` y `prefijoTicket`.** El
      selector de estación (P3a) necesita `orden` para ordenar el menú, y
      el ticket de cocina (R.3.3) necesita `prefijoTicket` para
      "COCINA-01". No se añadieron en R.3.1 a propósito.
- [ ] **R.1b · `productos.departamento_id` en Supabase.** Por decisión D2a
      el campo es local-only: está en Isar pero NO en `toJson()`/`fromJson()`
      de `ProductoEntity`. Añadirlo al par solo cuando exista la columna,
      o el push de productos escribirá una clave inexistente.
- [ ] **`agregarItem` desde el catálogo no propaga `estacionId`.**
      Solo lo hace `CatalogActions.agregarProducto` (escáner de código de
      barras / búsqueda). Los otros 3 puntos de entrada construyen el
      `CartItem` sin estación, así que sus líneas llegan al KDS con
      `estacionId = null`:
      · `inventory_catalog_screen.dart:393` (agregar un "reciente")
      · `inventory_catalog_screen.dart:561` (tap en la grilla)
      · `top_products_widget.dart:90` (top de productos)
      Todos tienen un `ProductoEntity` en scope, así que el fix es pasar
      `estacionId: producto.departamentoId`. Pendiente de decidir si entra
      en R.3.2 o se acepta que solo el escáner asigne estación.

## R.2 Fase 2 — Flujo del mesero (pendiente)
- [ ] Tap en mesa **libre** desde el Salón → asignar mesa + navegar al POS
      directo (en vez de abrir `ComandaScreen` read-only).
- [ ] `ComandaScreen` es read-only desde R.2 Fase 1 (B1): el mesero ve la
      comanda, pero ya no añade productos (el botón "Añadir producto" y el
      método `_anadirProducto` se eliminaron). El cobro sigue disponible.
      Si en Fase 2 el tap va al POS, esta pantalla queda solo para consulta
      y quizá se elimina.
- [ ] Notas y estación de la comanda siguen sin llegar a `DetalleVentaEntity`
      (TODO R.3/R.5).

## Deuda técnica — Clientes
- [ ] Dividir `client_detail_screen.dart` (1042 líneas) en sub-archivos por tab
- [ ] Mover llamada a `cargar()` de `client_detail_screen.initState` al constructor del notifier en `client_detail_provider.dart`
- [ ] `suscripcion_historial`: exponer historial de cambios en el tab Suscripción
- [ ] Implementar lógica real de extenderTrial / cambiarPlan / cancelar / registrarPago / agregarNota (actualmente stubs)

## Tests pre-existentes fallando (heredado, no bloquea)
- [ ] local_catalog_test.dart / local_switching_test.dart — **RESUELTO en hot-switch**: eran placeholders que nunca esperaban la carga async. Reescritos con `IsarService` inyectable. Pendiente confirmar que pasan.
- [ ] inventory_catalog_screen_test.dart × 4 — `BcvController used after disposed`
- [ ] rebuild_audit_test.dart — `TimeoutException` 30s
- Riesgo: los 2 de hot-switch podían indicar bug en multi-local. **Confirmado: sí lo había** (`state = id` se aplicaba después de los `invalidate`). Corregido.

## 📌 Otros pendientes acumulados

### JWT tenant claim fijo (post-R.5)
El claim `tenant_id` del JWT siempre devuelve el tenant de
`usuarios.tenant_id` (columna fija). El RPC `set_active_tenant` solo
mueve `usuarios_locales.es_default`, que el hook del JWT no lee.

**Fix de respaldo ya aplicado**: prioridad `prefs` > JWT en
`cargarLocalActual()` (`local_actual_provider.dart`).

**Raíz pendiente** (post-R.5, cuando multi-local esté completo):
- **Opción 2**: cambiar `custom_access_token_hook` para leer
  `usuarios_locales.es_default` en vez de `usuarios.tenant_id`.
- **Impacto si no se hace**: `usuario_provider.dart:70,84` y
  `auth_provider.dart:112,208` pueden filtrar/validar con el tenant viejo.
- **No bloquea R.2–R.5.**

### Otros
- [ ] 6 bugs de sync_service (chat DeepSeek) — timestamps, UUIDs, usuario eliminado
- [ ] precio_anual (ya tiene valores 250/600/2200 en BD)
- [ ] Realtime de locales con 'retail' — pendiente verificación runtime
- [ ] Telegram: ocultar en restaurante cuando exista onboarding (R.9)
- [ ] `.bak` files: `pedidos_provider.dart.bak`, `diagnostico_lote_dialog.dart.bak`
      — se conservan hasta cerrar el smoke test de PASO 2.3
- [ ] Bugs A1–A8 del admin_console (Clientes)

### Notas / estación no llegan a la venta (R.3/R.5)
`CartSessionItem.nota` y `.estacionId` son informativos en R.2: al restaurar
la comanda al carrito vivo se pierden, porque `ProductItem` y
`DetalleVentaEntity` no tienen esos campos. Requiere `build_runner` y tocar
retail (~15 archivos usan `ProductItem`).

### Notas y estación por ítem
`CartSessionItem.nota`/`estacionId` se pierden al restaurar la comanda al carrito vivo en R.2 (`ProductItem` y `DetalleVentaEntity` no tienen esos campos). Requieren `build_runner` + tocar retail.
### R.3.2 PASO E · Deuda del KDS

- [ ] `FiltroChip.style` es un parametro MUERTO (`filtro_chip_template.dart:30`).
      El `build` (líneas 82-94) solo mira `selected` y `_hovered`; `outlined`
      y `solid` producen el mismo chip. El KDS es su primer consumidor
      (PASO E) y lo deja sin tocar a proposito. Decidir si se implementa o
      se borra.
- [ ] Seed de estaciones "Cocina / Barra / Postres" con `orden` 0/1/2
      (pendiente de PASO E.3). `KdsScreen` ya muestra el aviso
      "Este local no tiene estaciones" cuando el local no tiene ninguna,
      pero no las crea.
- [ ] `FiltroChip` NO tiene target tactil de 48 px: sus botones miden
      `hPad 12 / vPad 8` en tamano `small`. En el KDS es el selector de
      estacion, que se usa con el dedo y en movimiento.
- [ ] `KdsTicket.minutosEnCola` (`kds_ticket.dart:109`) llama a
      `DateTime.now()` por su cuenta, sin `ahora` inyectado, al contrario
      que `TimeBadge`. El KDS NO lo usa en el render (calcula con
      `DuracionUtils.minutosDesde(..., ahora: _ahora)`), pero cualquier
      consumidor futuro que lo lea puede discrepar un minuto del badge.
- [ ] El conteo de items por estacion se calcula en la pantalla
      (`_contar`), no en `ComandasState`. Con una o dos mesas esta bien;
      con cientos de platos en cola recorre la lista entera en cada
      `build`. Cuando duela, promoted a getter del state devolviendo un
      `Map<int?, int>` (OJO: Riverpod compara con `==`, un Map nuevo
      nunca es igual -> hace falta `==`/`hashCode` propio o un `int`).
- [ ] Sin sonido ni aviso al llegar un plato nuevo (eso es PASO F).
- [ ] El KDS no permite editar cantidades ni notas. Es intencionado
      (el plato ya esta pedido), pero si el cocinero necesita "salsa
      aparte" hay que abrir la comanda desde el salon.
- [ ] `_PausaItemDialog` es privado en `kds_ticket_card.dart`: se testea
      a traves del boton "Pausar", no directamente.
- [ ] El `Timer.periodic(30s)` de `KdsScreen` obliga a los tests de widget
      a montar un arbol vacio al final (`cerrarPantalla`) o
      `flutter_test` aborta con "A Timer is still pending".

### R.3.4 F.2.4 · No testeable sin refactor mayor

- [ ] `ComandaScreen._cobrar` COMPLETO. El camino vuelca la comanda a
      `cartProvider` (via `ProductItem`/`CartItem`), llama a
      `mostrarModalCobro` y de ahi a `procesarVenta`, y luego cierra la
      comanda y libera la mesa. Probarlo exigiria Isar real dentro de un
      `testWidgets`, que es el deadlock conocido (`FakeAsync` + isolate
      real = cuelgue). Ver la nota de cabecera de `kds_pantalla_test.dart`.
- [ ] Que pulsar [Esperar] en el dialogo deje el boton de cobrar
      HABILITADO. Requiere montar la pantalla entera por el
      `setState(_procesando = ...)` de `_cobrar`, con lo mismo de arriba.
- [ ] `ComandaScreen._buscarTicket`. Se sabe que funciona por construccion
      (bucle con `break` sobre `ticketsEnCola`); un test seria trivial y no
      anadiria confianza real.
- [ ] `_avisarPedidoNuevo` de `KdsScreen`. Dispara `SystemSound.play` +
      `HapticFeedback` + Snackbar, que no tienen assert en un entorno de
      test. Se podria cubrir inyectando el sonido, pero no compensa.

### R.4 G.1 · Recetas · deuda

- [ ] `RecetaEntity` NO viaja a Supabase. `sync_service` no la empuja y
      `isar_service` no tiene `toSupabaseJson`/`fromSupabase` para ella.
      Requiere crear `recetas` + `receta_ingredientes` en Supabase, igual
      que hizo `LoteEntity`.
- [ ] `ProductoEntity.esIngrediente` y `.unidad` son LOCAL-ONLY, igual que
      `departamentoId` (D2a). Cuando existan las columnas
      `es_ingrediente` y `unidad` en `productos`, anadirlas al par
      `toJson`/`fromJson`. Hasta entonces NO meterlas: el push
      escribiria claves inexistentes.
- [ ] `stockMinimoAlerta` NO se anadio en G.1 (decision del usuario).
      `ProductoEntity.stockMinimo` YA existe y significa otra cosa: "avisar
      de cualquier producto". `stockMinimoAlerta` seria "cuanto
      ingrediente debe quedar para no quedarse sin platos". Si se anade
      sin documentar la diferencia, la UI acabara usando el equivocado.
- [ ] `RecetaItemEntity.unidad` no tiene validacion: es `String` libre. Y
      `ProductoEntity.unidad` acaba de nacer, asi que la conversion de
      unidades para el descuento de stock de G.3 se asume 1:1. Si un
      ingrediente se guarda en `kg` y la receta pide `g`, G.3 restara mal.
      Hace falta un factor de conversion.
- [ ] `MovimientoInventarioEntity.localId` se anadio con default 0. Los
      movimientos legacy (anteriores a R.4) siguen en 0 = "local
      desconocido". Habria que migrarlos al local real si se quiere que el
      historico por sucursal sea fiable.
- [ ] Sustitucion de ingredientes (Q2) y validacion de disponibilidad
      bloqueante (Q5): a TODO. En G.3 solo se AVISA, nunca se bloquea.
- [ ] `obtenerIngredientes(localId)` recibe `localId` pero NO lo usa en la
      query: `ProductoEntity` no tiene `localId`. Mismo limite que
      `obtenerComandasDeLocal`. Si se quiere aislamiento real por local en
      productos, hace falta el campo.

### R.4 G.3 · Descuento de receta al entregar · deuda

- [ ] `RecetaEntity.rindePorciones` NO se valida en la UI de G.2.2: se
      puede guardar `0` o negativo. G.3 lo defiende con
      `divisor = rinde > 0 ? rinde : 1.0` (si no, dividiría por cero y el
      bucle FEFO no terminaría), pero el dato sigue siendo basura en la BD.
      Anadir validacion `> 0` en el campo.
- [ ] El descuento NO es atomico. Son N `writeTxn` independientes (uno por
      lote), heredado de `venta_service.procesarVenta`. Si el 3.er
      ingrediente falla, los 2 primeros quedan descontados sin rollback.
      Ademas `_avanzarEstado` avanza el estado ANTES de descontar, asi que
      un reintento del cocinero ya no reintenta el descuento (la
      transicion `listo -> entregado` solo es valida una vez).
- [ ] El fallo del descuento se traga con `try/catch` + `debugPrint`:
      si el KDS esta cerrado no hay aviso de ningun tipo. Considerar un
      badge persistente de "avisos no vistos" en el KDS.
- [ ] `obtenerLoteParaVenta` NO filtra por `localId` (mismo limite que
      `obtenerIngredientes`): con multi-local, el FEFO de G.3 puede
      descontar de un lote de otra sucursal.
- [ ] `MovimientoInventarioEntity.tipoMovimiento` sigue siendo `String`
      libre y ahora tiene un valor mas ('Consumo receta'). No hay
      constantes ni enum. Con 6 valores ya merece la pena.
- [ ] Sin tests de G.3. `_descontarRecetaDeItem` es privado y no hay
      cobertura de: FEFO multi-lote, `rindePorciones`, falta parcial,
      ingredientes opcionales, ni el calculo
      `cantidad * cantidad / rindePorciones`.
- [ ] El aviso va en `ComandasState.avisoReceta` y comparte
      `ScaffoldMessenger` con el aviso de pedido nuevo: si llegan juntos,
      el segundo Snackbar pisa al primero.

## Exponer recetas como productos retail

Al crear una receta, poder marcarla como "disponible en retail". El
plato pasa a ser producto vendible en modo retail (pizzerías takeout,
restaurantes con venta por unidad preparada).

- [ ] Campo tipo `esProductoRetail` en `RecetaEntity` (local-only, patrón
      `departamentoId`) o, mejor, en `ProductoEntity` si aplica también a
      productos sin receta.
- [ ] Al vender en retail una receta con ese flag, ¿se descuenta stock por
      receta (como G.3) o por lote del producto padre? Son dos caminos y
      ahora mismo solo existe el de G.3 (restaurante, al entregar).
- [ ] El flag NO debe ser implícito: hoy `RecetaEntity` no sabe nada del
      modo de negocio y `FeatureFlags` no se lee desde Isar.

## Modo retail = productos completos sin recetas

En retail, los productos se tratan como unidades completas: el editor de
receta se oculta o se muestra read-only. Los ingredientes y lotes siguen
funcionando para stock real, pero las recetas no descuentan.

- [ ] En `ProductDataTab`, la sección "Receta" (G.2) no se pinta en retail,
      o se pinta sin los campos de ingrediente.
- [ ] G.3 (`_descontarRecetaDeItem`) ya está acotado al KDS, así que no
      descuenta en retail por construcción. Conviene un test que lo fije:
      una receta + una venta retail NO deben generar movimiento de
      'Consumo receta'.
- [ ] El editor de receta es el mismo widget para ambos modos: hoy no
      tiene acceso a `FeatureFlags`, así que el gate va en
      `ProductDataTab` o en `ProductFormDialog`, no dentro del editor.

## Colchón de stock offline (CRÍTICO pre-producción)
- [ ] Fase 1 — Umbral progresivo de reconexión:
      · >50% stock: venta libre offline
      · 20-50%: banner ámbar discreto en caja
      · 5-20%: banner persistente + badge en producto
      · <5%: bloqueo suave (requiere conexión para vender)
- [ ] Modelo de stock en 4 capas (real, local, comprometido, vendible)
- [ ] Al sincronizar: detectar sobreventa → marcar ventas como conflicto
- [ ] UI admin: revisar ventas en conflicto + ajuste manual
- [ ] Fase 2 (post-producción): reserva proactiva de stock por dispositivo
- [ ] Tests: escenario 2 dispositivos offline + sincronización

## 📌 Deuda detectada — suite completo (fuera de G.3.3)
- [ ] BcvController disposed en cobrar_dialog_test e inventory_catalog_screen_test (~40 fallos).
      Riverpod scope roto. Ciclo de vida del provider.
- [ ] Textos/widgets desactualizados en parked_carts_dialog, save_cart_dialog, quantity_dialog (~12).
- [ ] CircularDependencyError en local_actual_provider.dart:219 (9 fallos, BUG REAL).
- [ ] lote_tenant_id_contract_test.dart: path hardcodeado c:\Users\torre\... — no portable.
- [ ] sync_services_test.dart: mock HTTP no intercepta (~5).
- [ ] Test colgado: "... guarda 1 venta + N detalles en Isar" (integración Isar).