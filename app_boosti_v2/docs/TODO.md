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
      ⚠️ **Lista desactualizada desde 2026-10-27**: después de `00006` hay migraciones
      versionadas posteriores (`20261010*`, `20261012*`, `20261015*`, `20261018*` y
      `20261027000001_recetas.sql`). Antes de asumir que el remoto está al día:
      ```sql
      SELECT version FROM supabase_migrations.schema_migrations ORDER BY version;
      ```
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
- [ ] **CHECK `(cantidad_restante <= cantidad_inicial)` en `public.lotes`.** Invariante
      documentado en `MEMORY.MD` §12. **Requiere una migración de limpieza previa**:
      hoy hay filas que lo violan (2 con `id_isar=1` en JAHTLABS, 4 del Arroz) y el
      `ALTER TABLE` fallaría. Aplicar **después** de cerrar el fix de
      `ajustarStockDesdeEditor` y **después** de aplicar `00005`.
- [x] **DSN de Sentry sacado del fuente** (2026-10-10, 2.º intento). El primero afirmó
      que estaba movido a `env.json` y era falso: seguía hardcodeado en
      `error_service.dart:22`. Corregido eliminando el `SentryFlutter.init` duplicado de
      `ErrorService.init()`; ahora se lee solo desde `bootstrap.dart` §4 vía
      `String.fromEnvironment('SENTRY_DSN')`. Verificado con grep: 0 hits en `lib/`.
- [x] **Credenciales redactadas de `HANDOFF_CONTROL_CENTER.md`** (2026-10-10). Contenía
      un PAT `sbp_…`, una cadena de conexión de Postgres con password y un
      `$env:PGPASSWORD`. GitHub push protection solo detectó el PAT; los otros dos
      habrían entrado al remoto sin aviso.
- [ ] **Rotar las credenciales expuestas**: PAT de Supabase, password de la base y
      DSN de Sentry. Redactar no basta: si estuvieron en un archivo, están comprometidas.
      Procedimiento en `HANDOFF_CONTROL_CENTER.md` §11.
      ⚠️ El DSN de Sentry **sigue pendiente de rotar**: aunque ya no está en el fuente,
      estuvo committeado hasta el 2026-10-10.
- [ ] **Sanear las filas que violan el invariante** antes del CHECK: 2 lotes con
      `id_isar=1` (inicial=100, restante=200/150) y 4 del Arroz (inicial=100,
      restante=512–519). El clamp future los evita pero no repara los que ya están.
- [ ] **Rediseño conceptual "almacén vs estantería" (Camino 2)** — evaluar post-v1.
      Hoy `lotes == stock`: un lote es un acumulador de un producto, no un depósito con
      ubicación física. El modelo asume que todo el stock de un producto está disponible
      para vender sin preguntar por la ubicación. Si alguna vez hay dos almacenes, este
      modelo no lo representa.
- [ ] **Quedan confirmadores duplicados** fuera de `cart_dialogs.dart`:
      `inventory_catalog_screen._limpiarCarritoConConfirmacion` ya usa el helper, pero
      `crear_pedido_dialog` y otros siguen con copies propios.

## 🔶 Drift de schema (tablas en remoto sin versionar)

**7 tablas existen en Supabase pero NO están en ninguna migración.** Las 7 se
detectaron el 2026-10-10 auditando los `.from(...)` del código contra los
`CREATE TABLE` de `supabase/migrations/`.

**Riesgo:** si alguien regenera el schema desde las migraciones, estas tablas
desaparecen. El baseline solo versiona 24 tablas contra las ~39 del remoto.

| Tabla | Consultada desde |
|---|---|
| `autorizaciones_descuento` | `sync_service.dart:2268` |
| `pagos_ventas` | `sync_service.dart:2192` |
| `planes` | `admin_console/data/repositories/plans_repository.dart`, `pos/data/remote/suscripciones_repository.dart:37` |
| `suscripciones` | `admin_console/.../subscriptions_repository.dart`, `pos/data/remote/suscripciones_repository.dart:100` |
| `tenants` | `admin_console/data/repositories/tenants_repository.dart` |
| `notas_cliente` | `admin_console/data/repositories/notes_repository.dart` |
| `suscripcion_historial` | `admin_console/data/repositories/subscriptions_repository.dart` |

⚠️ **El `admin_console` usa el MISMO cliente que el POS** (`Supabase.instance.client`),
así que no es un proyecto Supabase aparte: todo esto cae sobre el mismo schema.

**Acción:** generar una migración "snapshot" que las versione tal como están,
sin cambiar definiciones.

## 🔶 Fantasmas reales (el código consulta, la tabla no existe)

A diferencia del bloque anterior, aquí **no se pudo confirmar que la tabla exista**.
Los tres se consultan desde un `try/catch` que traga el error, así que la app
funciona igual y el problema es invisible.

| Tabla | Consultada desde | Decisión |
|---|---|---|
| `avatars` | `empleado_form_dialog.dart` | Crear o eliminar |
| `cashier_logs` | `lock_provider.dart` | Crear o eliminar |
| `saas_metrics` | `admin_console/data/repositories/metrics_repository.dart` | Crear o eliminar |

**Caso aparte:** `movimientos_lotes` (`sync_service.dart:3851`) tampoco está
versionada, pero además **`descargarMovimientosLoteDesdeSupabase()` no tiene
ningún caller**: el historial de movimientos de lote nunca se descarga de la
nube. Hay que decidir si se conecta o se elimina el método.

- [ ] **`pagos_venta` (singular, legacy)** — el código ya lee
      `data['lote_id'] ?? data['lote_id_fk']` en `sync_service.dart:3869-3875`, o
      sea que hay columnas con dos nombres históricos. Limpiar los fallbacks cuando
      se confirme cuál es el bueno.
- [ ] **`movimientos_lotes`** — tabla creada y aplicada al remoto 2026-10-10.
      Backfill de versión en `20261010000001_create_movimientos_lotes.sql` para que
      dev/staging la obtengan. **Pendiente:**
      `supabase migration repair --status applied 20261010000001`.
- [ ] **`usuarios.foto_url`** — columna REAL, sincronizada en
      `sync_service.dart` y leída en 3 pantallas (`empleado_card`,
      `employees_detail_screen`, `empleado_form_dialog`). No está versionada en el
      baseline. Incluir en la migración snapshot del drift.
      **Sin bug de URL firmada:** el bucket `avatars` es PÚBLICO y usa
      `getPublicUrl`, que no caduca. A diferencia de `marcas`, acá la URL
      guardada es estable.
- [x] **Fotos de empleados — congelada** 2026-10-10 por política de datos
      sensibles. Callers comentados, el botón muestra "Próximamente", la subida de
      `foto_url` está pausada. La lectura de fotos existentes quedó intacta.
      **Reversible:** descomentar los 2 bloques + revertir el diálogo del botón.
- [ ] **`saas_metrics`** (vista materializada) + RPC `refresh_saas_metrics()`
      — feature viva: `admin_console/admin_dashboard_screen.dart:229` la consume vía
      `admin_dashboard_provider`. Ni la vista ni la RPC están versionadas. Bloque
      propio. ⚠️ El catch de `metrics_repository.dart:37` devuelve
      `SaasMetrics.empty()`: si la vista falla, el dashboard muestra ceros sin
      avisar que no hay datos.
- [x] **`cashier_logs`** — tabla aplicada al remoto 2026-10-10
      (`000003` + `migration repair`). Catch mudo de `lock_provider.dart`
      reemplazado por `ErrorService.captureError`.
      **Pendiente verificar:** disparar un lock manual y confirmar que
      aparece una fila.
- [x] **Bucket `locales`** — 4 policies aplicadas 2026-10-10 (migración
      `20261010000006_storage_policies.sql` sobre `storage.objects`, path
      con `tenant_id` como primera carpeta).
- [x] **Bucket `marcas`** — 4 policies aplicadas 2026-10-10 (misma migración
      `000006`, bloque `ARRAY['marcas', 'locales']`).
- [ ] Verificar en Storage que el upload desde la app funciona end-to-end
      (probado manualmente en dispositivo). Las policies están, pero la
      app todavía no subió ni un logo real contra el bucket nuevo.
- [ ] **PDF de venta** — no existe. Solo etiquetas. Post-v1.
- [ ] **58mm en impresora** — hoy 80mm hardcodeado (`PaperSize.mm80`).
      Post-v1.
- [x] **Logo del local en el ticket — CERRADO 2026-10-10.** Sync de
      `logo_path` completo en los 4 puntos (push, pull, merge, create), UI
      de upload (`widgets/common/logo_upload_field.dart`) y render en el
      encabezado del ticket térmico. Ver `ticket_generator._appendLogo` y
      `printer_service._resolverLogoDelLocal`.
- [ ] **Logo de marca (`marca_form_dialog.dart`)** — sube al bucket `marcas` y se
      muestra en 1 widget (`marcas_management_dialog.dart:547`). `logo_url` **sí**
      está versionada en el baseline. **Pendiente de decisión**, pero hay un bug
      que lo anula: usa `createSignedUrl(3600)` y guarda esa URL caducable en
      `MarcaEntity.logoUrl`, que además se sincroniza a la nube. Al expirar, todos
      los logos guardados quedan muertos.
- [ ] **Logo del ticket resuelve con tenant del JWT, no del local
      impreso.** Con hot-switch a un local de otro tenant, el claim
      sigue siendo el del login y el logo no baja del bucket.
      Impacto: ticket sale sin logo (no rompe). Decisión: post-v1, a
      menos que el negocio imprima cross-tenant con logos distintos.
      Aplicable a: printer_service.dart `_resolverLogoDelLocal`.
- [ ] **UX: después de realinear el JWT con "Cambiar de cuenta", no hay
      botón para volver al tenant anterior.** El usuario tiene que usar
      el hot-switch y volver a tocar "Cambiar de cuenta".
      Impacto: bajo (funciona). Post-v1.
      Aplicable a: main_pos_screen.dart `_realinarTenant`.
- [ ] **Logo de marca no se muestra en el catálogo** — `product_card.dart` y
      `product_list_tile.dart` no usan `logoUrl`. Solo aparece en el gestor.

## 🔴 v1 — Logo del local en comprobantes

El logo de **marca** existe, pero no es lo que el negocio necesita. Para
tickets y recibos hace falta el logo del **LOCAL**, y hoy no existe en
ningún lado.

`LocalEntity` hoy tiene: `supabaseId`, `nombre`, `direccion`, `telefono`,
`email`, `rif`, `activo`, `sincronizado`, `businessMode`, `planIdCache`.
**Ningún campo de imagen.**

- [ ] `LocalEntity.logoPath` + columna `locales.logo_path` en Supabase
      (guardar el **path**, no una URL firmada: ver el bug de
      `marca_form_dialog.dart`).
- [ ] Bucket `locales` en Storage, con policies por tenant.
- [ ] UI de upload en el formulario de local. **Reutilizar el flujo de
      marcas ya corregido**, no escribir uno nuevo.
- [ ] Mostrar en el comprobante: impresion termica + PDF.

Decisión pendiente (U54): **v1 o post-v1**. Depende de si los comprobantes
con logo son requisito de lanzamiento.

Prioridad: esto es lo que pidió el negocio. El logo de marca es accesorio.

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

## Tests pre-existentes fallando (RESUELTO · suite verde 2026-10-27)
- [x] local_catalog_test.dart / local_switching_test.dart — **RESUELTO en hot-switch**: eran placeholders que nunca esperaban la carga async. Reescritos con `IsarService` inyectable. Confirmado: pasan en la suite completa (902 pasan, 1 omitida, 0 fallos).
- [x] inventory_catalog_screen_test.dart × 4 — `BcvController used after disposed`. Ya no falla.
- [x] rebuild_audit_test.dart — `TimeoutException` 30s. Ya no falla.
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

- [x] `RecetaEntity` viaja a Supabase (2026-10-27).
      `supabase/migrations/20261027000001_recetas.sql` crea `recetas` +
      `receta_ingredientes`, su RLS por tenant y la RPC
      `guardar_receta(p_receta, p_ingredientes)`, que hace el upsert de la
      fila y el REEMPLAZO COMPLETO de los ingredientes en una transacción.
      Lado Dart: `RecetaEntity.toSupabaseJson` / `ingredientesToSupabaseJson`
      / `fromSupabase`, `IsarService.obtenerRecetasPendientesSync` /
      `marcarRecetaSincronizada` y
      `SyncService.sincronizarRecetasPendientes` /
      `descargarRecetasDesdeSupabase` (enganchados en `sincronizarTodo` y en
      `sincronizarTodoConResumen`).
      ✅ **Aplicada y verificada en el remoto el 2026-10-27**: las 2 tablas con
      `rowsecurity = true`, una policy `tenant_isolation` (`cmd = ALL`) en cada
      una y `guardar_receta` con `prosecdef = false` (invoker).
      ⚠️ La consulta de prueba de la RPC del final del archivo NO sirve tal
      cual: los placeholders `<...>` no son JSON válido (22P02) y el SQL
      Editor no trae JWT, así que `current_tenant_id()` es NULL (42501). El
      bloque de verificación ya trae la versión corregida con
      `SET LOCAL request.jwt.claims` + `BEGIN/ROLLBACK`.
      ⚠️ Los borrados NO se sincronizan: `eliminarReceta` no tiene callers
      (la UI marca `activo = false`). El día que se use hace falta un
      tombstone, o el pull la resucita.
      ⚠️ Sin control de conflictos por `updated_at`: gana el que sube último.
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
- [x] `RecetaItemEntity.unidad` no tiene validacion: es `String` libre. La
      conversion a la unidad del inventario vive en
      `presentation/services/conversion_unidades.dart` (`kg`↔`g`,
      `lt`↔`ml`, sinonimos y fallback 1:1 avisado cuando las dimensiones no
      coinciden). Los tests estan en `test/services/conversion_unidades_test.dart`
      y `descuento_receta_test.dart` (caso 2b: 150 g descuentan 0.15 kg).
      Sigue pendiente normalizar el valor al GUARDARLO, para que la UI no
      acepte texto libre arbitrario.
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
- [x] Tests de G.3. `_descontarRecetaDeItem` es privado, así que se prueba
      por la puerta pública `marcarEntregado` en
      `test/features/pos/descuento_receta_test.dart` (21 tests): FEFO
      multi-lote, `rindePorciones`, falta parcial, ingredientes opcionales,
      idempotencia, movimiento de auditoría y conversión de unidades
      (caso 2b).
- [x] El aviso va en `ComandasState.avisoReceta` y antes compartía
      `ScaffoldMessenger` con el aviso de pedido nuevo: si llegaban juntos,
      el segundo Snackbar pisaba al primero. Ahora es un `AlertDialog`
      (`widgets/restaurante/aviso_stock_receta_dialog.dart`), no se cierra
      solo y no compite con nada.

## Exponer recetas como productos retail

Al crear una receta, poder marcarla como "disponible en retail". El
plato pasa a ser producto vendible en modo retail (pizzerías takeout,
restaurantes con venta por unidad preparada).

## Cerrado en 2026-10-12 (sesión AppBar + chip de local)

- [x] **`sync_service.dart:2390`** — el log decía `RPC ajustar_stock` pero la
      RPC real es `ajustar_stock_uuid`. Diagnóstico engañoso en producción.
- [x] **Badge de local activo en el Menú POS** — `LocalActivoChip`, chip
      informativo (NO un guard). Tocar abre `LocalSelectorDialog`.
- [x] **AppBar del POS principal sin barra** — transparente, con base
      blanca en logo/botones y pill BCV violeta. `CustomAppBar` quedó
      intacto: lo usan ~30 pantallas y tiene el contenido hardcodeado a
      blanco.

## Deuda abierta de 2026-10-12

- [ ] **`assets/logo.svg` es un duplicado exacto de `logoboosti300px.svg`.**
      Mismo SHA256 (`343FA29D...`), 1826 bytes. `logo.svg` no lo usa ningún
      archivo y NO está declarado en `pubspec.yaml`, así que no está en el
      bundle. Se decidió **no declararlo** (sería una copia muerta). Queda
      pendiente borrarlo o renombrarlo — `AGENTS.md` prohíbe borrar sin
      confirmación explícita.
- [ ] **El chip de local no tiene test de widget.** Es el único indicador
      de "dónde estoy operando" en el Menú POS.
- [ ] **El chip de local no se verificó en device.** El `Flexible` +
      `TextOverflow.ellipsis` es preventivo: no se comprobó con nombres
      largos en móvil (~360px).
- [ ] **La supresión de `isLoading` en `productos_provider.dart` sigue sin
      verificar en dispositivo.** Cierra el caso "Isar vacío"; si el
      síntoma real era "datos presentes pero no aparecen", no lo arregla.
- [ ] **Ejecutar `docs/SMOKE_TEST_2026-10-13.md` con usuario real.**
      Es el gate para v1.0.1. Si todo verde → tag + release.

## Cerrado en 2026-10-12 (locales)

- [x] **Logo del local en creación**: se sube vía el RPC con `p_logo_path`
      (migración `20261012000001`). El camino directo —`UPDATE locales SET
      logo_path` desde el cliente— no servía: `locales_tenant_update` solo
      permite actualizar el tenant **activo**, y el local recién creado
      todavía no lo es.
- [x] **Íconos en el form de crear/editar local.** No era que faltaran:
      `_field()` recibía el parámetro `icon` y lo tiraba, con un
      `prefixIcon: Icon(Icons.circle, size: 0)` de placeholder invisible.
- [x] **Bump a `1.0.0+4`.**
- [ ] **Tag v1.0.0**: pendiente smoke test verde.

## Cerrado en 2026-10-12 (fiscal)

- [x] **Numeración fiscal (`numero_factura`)** — migración
      `20261012000003` **escrita, PENDIENTE de aplicar en Supabase**.
      `DocumentoFiscalService` con cola serial (el `read → +1 → write`
      sobre `SharedPreferences` no es atómico), contador por año y
      device id aleatorio. El ticket imprime `N° pendiente` cuando la
      venta no tiene número, para que la falencia se vea en el papel.
- [x] **Detalle del local**: logo read-only con signed URL (firmada en
      `initState`, no en cada `build`) + razón social.
- [x] **Vendedor eliminado del ticket.** El parámetro `vendedor` se
      conserva en la firma para no romper 5 call sites; el bloque viejo
      quedó comentado con el motivo. Un test fija la eliminación.
- [x] **Razón social**: migración `20261012000002`, campo en
      `LocalEntity`, los 4 sitios del sync, y campo en el form.

## Deuda post-v1 (fiscal)

- [ ] **`ventas.documento` es `int` con doble significado.** En
      `VentaEntity` guarda el documento del CLIENTE (`..documento =
      cliente.documento`, o `0` si no hay), no un número de factura.
      Por eso la numeración fiscal vive en `numero_factura` y no ahí.
      Limpiar: renombrar `documento` a `cliente_documento` y dejar
      `numero_factura` como único número de venta.
- [ ] **Secuencia fiscal server-side.** Hoy es **por dispositivo**
      (`{deviceId}-{year}-{counter}`), válida bajo Providencia 00071
      para un punto de emisión. Dos tablets del mismo negocio pueden
      generar el mismo número. Chequeo de duplicados:
      ```sql
      select numero_factura, count(*) from public.ventas
       where numero_factura is not null
       group by numero_factura having count(*) > 1;
      ```
      Si devuelve filas, hay que migrar a secuencia server-side antes
      de seguir vendiendo.
- [ ] **Diagnóstico temporal del logo.** `_resolverLogoDelLocal` tiene
      `debugPrint` en los 4 puntos (path vacío / cache miss / descarga
      OK / error). Es para el smoke test: separa "no hay logo" de "el
      path no llega" de "RLS lo rechaza". **Sacar tras el smoke test**,
      o el log se llena de ruido en cada impresión.

## Deuda de arquitectura multi-local (post-v1)

- [ ] **Código de asociación.** Hoy un usuario solo puede crear un tenant
      nuevo desde la app. No hay forma de asociar a un usuario a un tenant
      **existente** (el típico "invitame a mi local"). El RPC crea tenant +
      asignación en el mismo paso, y eso es justamente lo que no permite
      ese caso de uso.
- [ ] **No hay modelo multi-sucursal.** Cada "local" es un tenant
      independiente (Camino A). El dueño navega con hot-switch, pero
      catálogos, stock y ventas son de cada tenant: dos sucursales del
      mismo negocio no comparten inventario. Post-v1 evaluar Camino C
      (varios locales por tenant, con `local_id`).

## 🔴 Fuga cross-tenant en `locales` (2026-10-15) — CORREGIDA

**Síntoma:** el menú mostraba solo 9 módulos (Punto de venta, Cierre de
caja, Productos, Proveedores, Empleados, Personal, Impresoras, Telegram,
Backup, Sincronizar, Mi perfil). Faltaban Dashboard, Historial de ventas,
Gastos, Locales, Departamentos. Además el badge del AppBar mostraba
`pruebapostdeploy` en vez del local del usuario.

### Causa 1 — policy con brazo `EXISTS` no versionada

El repo (`baseline.sql:2380`) define:
```sql
USING ((id = public.current_tenant_id()))
```

La BD remota tenía:
```sql
USING ((id = current_tenant_id())
       OR EXISTS (SELECT 1 FROM usuarios_locales ul
                  WHERE ul.usuario_id = auth.uid()
                    AND ul.tenant_id = locales.id
                    AND ul.activo = true))
```

Ese brazo deja ver **todo local del que el usuario tenga fila en
`usuarios_locales`**, no solo el del claim. Con filas de tenants de
prueba acumuladas, el JWT de un tenant descargaba los 5 locales:

```
✅ Tenant cargado de prefs: TenantState(tenantId: 9c7380a4-…)   ← JAHTLABS
🔄 Descargando 5 locales desde Supabase...
🔄 Local centro / JAHTLABS / prueba 2 / prueba 3 / pruebapostdeploy
```

**La modificación se hizo a mano en el dashboard. Ninguna migración la
registró**, por eso repo y BD divergieron en silencio.

**Fix:** `20261015000001_cerrar_fuga_locales.sql` (restaura el baseline).

⚠️ **No rompe multi-local:** cambiar de local usa la RPC
`set_active_tenant()` + `refreshSession()`, y el listado del selector
viene de `mis_locales()` (`SECURITY DEFINER`). Ninguna usa `SELECT`
directo sobre `locales`.

**Verificado que el `EXISTS` solo estaba en `locales`:**
```sql
SELECT tablename, policyname FROM pg_policies WHERE qual ILIKE '%usuarios_locales%';
-- → solo locales.locales_tenant_select
```
Y `ventas`, `productos`, `pedidos`, `lotes`, `marcas`, `categorias`,
`departamentos`, `clientes`, `proveedores` usan solo
`tenant_id = current_tenant_id()`. **No hubo fuga de datos operativos.**

### Causa 2 — el menú vacío era fail-closed por suscripción ausente

```
ℹ️ [SuscripcionesRepository] Sin suscripción para 9c7380a4-…
```

```dart
// business_mode_provider.dart:208
bool _plan(String f, {bool defaultVisible = false}) =>
    planActivo && (featuresHabilitadas.contains(f) || defaultVisible);
```

`planActivo` es un `&&` corto: sin suscripción activa **no se ve nada**,
ni siquiera las features con `defaultVisible: true`. Por eso los 9 módulos
que sí aparecían son los que no pasan por `_plan()`.

`suscripciones` no está versionada y la EF `create-tenant` solo empezó a
poblarla el 2026-10-13. **Los tenants anteriores no tienen fila.**

### Causa 3 — las claves de `FeatureFlags` no existían en `planes.features`

La tabla tenía 4 claves: `offline`, `reports`, `multi_local`,
`priority_support`. El menú consulta ~20. Las huérfanas (cada getter
tenía un `TODO(R.0)`) nunca se activaban.

**Fix:** `20261015000002_plan_features.sql` agrega las claves y las
reparte. Producto (2026-10-15): **básico SÍ ve el dashboard; básico NO
ve proveedores, pedidos ni locales.**

| clave | trial | basico | pro | corporativo |
|---|:--:|:--:|:--:|:--:|
| `offline`, `reports` | ✅ | ✅ | ✅ | ✅ |
| `dashboard`, `historial_ventas`, `historial_gastos` | ✅ | ✅ | ✅ | ✅ |
| `departamentos`, `lotes`, `monitor_empleados` | ✅ | ✅ | ✅ | ✅ |
| `proveedores`, `pedidos_proveedores`, `ventas_mayor`, `multi_local` | ❌ | ❌ | ✅ | ✅ |
| `priority_support` | ❌ | ❌ | ❌ | ✅ |

### Causa 4 — `'proveedores'` no consultaba ningún flag de plan

```dart
// menu_config.dart — antes
'proveedores' => !flags.esServicios,     // solo modo, nada de plan
```

El plan básico veía Proveedores. Ahora es
`flags.proveedores && !flags.esServicios` (flag nuevo en `FeatureFlags`).

### Causa 5 — el wipe borraba catálogo global (error mío)

`wipeAll()` incluía `planEntitys.clear()` y `suscripcionEntitys.clear()`.
Los **planes son catálogo global de la plataforma**, no datos del
negocio. Corregido: el wipe ya no toca ninguna de las dos.

### Causa 6 — `activa` comparaba contra un valor que el CHECK prohíbe

```dart
// suscripcion_entity.dart — antes
if (estado == 'activa') { ... }   // femenino
```

```sql
CHECK (estado = ANY (ARRAY['trial','activo','vencido','cancelado','expirado']))
```

**`'activa'` es imposible en la base.** El getter caía siempre en
`return false` → `planActivo = false` para todos los tenants. Esta era
la causa real del menú vacío; las causas 2 y 3 lo agravaban.

Se detectó recién el 2026-10-15 con un log nuevo:
`🔎 [featureFlags] DENEGADO · suscripcion=pro(activo) activa=false`.

### Causa 7 — `defaultVisible: true` volvía inoperante el gate

`planActivo && (features.contains(f) || defaultVisible)` con
`defaultVisible: true` es `planActivo` y nada más. Los **9 getters** de
la tabla de arriba lo traían, así que la columna ❌ no ocultaba nada.

Ahora los 9 usan `defaultVisible: false` y el reparto de la tabla se
respeta de verdad. `test/features/pos/feature_flags_plan_test.dart`
fija el contrato con los valores reales de `planes`.

### Causa 8 — `obtenerPlanes()` devolvía caché vieja para toda la sesión

```dart
descargarPlanesDesdeSupabase(); // fire-and-forget, actualiza Isar
return locales;                  // ← el valor viejo
```

Supabase tenía **12** features en `true` y Dart veía **3**. El menú no
se notaba por el `defaultVisible` de la causa 7: se veían todos, pero
por casualidad y no por el plan.

### Causa 9 — `super_admin_read_locales` era un OR que ganaba

`locales` tenía 2 policies de SELECT y Postgres las une con **OR**:

```
locales_tenant_select     {authenticated}  (id = current_tenant_id())  → 1
super_admin_read_locales  {public}        is_super_admin()             → todas
```

El POS y el `admin_console` comparten `Supabase.instance.client` → mismo
JWT → el owner veía los 5 locales. Dropeada en `20261015000004`.

⚠️ Mientras esa policy exista, el filtro por `claim` de
`sync_service.dart:3071` es **defensa en profundidad**, no el fix.

### Causa 10 — `prefs['localActualId']` es un int de Isar, no un tenant

La prioridad 1 de `cargarLocalActual()` no validaba el tenant del id
guardado. Quedó el `1` = `pruebapostdeploy` de cuando el RLS bajaba
los 5 locales, y el badge lo mostraba con el JWT de JAHTLABS.

### Verificación — simular PostgREST

La query que destapó todo. Antes daba **5 locales** con un tenant
correcto; después de `20261015000004` debe dar **1**:

```sql
SET role authenticated;
SET request.jwt.claims = '{"tenant_id":"9c7380a4-14be-41c2-88db-07606c2a6489","sub":"604e9b98-354b-4fd6-b816-af97b47c1b0e","role":"authenticated"}';
SELECT id, nombre FROM locales ORDER BY nombre;
RESET ROLE;
```

## 🔴 Datos pendientes en Supabase (2026-10-15)

Las migraciones arreglan el código pero **no los datos**. Falta:

```sql
-- 1. ¿Qué tenants siguen sin suscripción?
SELECT l.nombre, l.id FROM locales l
  LEFT JOIN suscripciones s ON s.tenant_id = l.id
 WHERE s.tenant_id IS NULL;

-- 2. Alta de JAHTLABS (9c7380a4-14be-41c2-88db-07606c2a6489) en pro
INSERT INTO public.suscripciones (tenant_id, plan_id, estado,
    iniciado_en, auto_renovar)
  VALUES ('9c7380a4-14be-41c2-88db-07606c2a6489', 'pro', 'activo',
          now(), true)
  ON CONFLICT (tenant_id) DO UPDATE
    SET plan_id = EXCLUDED.plan_id, estado = 'activo';

-- 3. Filas de prueba en usuarios_locales (CON BACKUP ya creado:
--    _backup_usuarios_locales). Auditar antes de borrar.
SELECT ul.usuario_id, u.email, ul.tenant_id, l.nombre, ul.es_default
FROM usuarios_locales ul
JOIN locales  l ON l.id = ul.tenant_id
JOIN usuarios u ON u.id = ul.usuario_id
ORDER BY u.email, l.nombre;
```

⚠️ El paso 3 borra datos. **No ejecutarlo sin revisar el SELECT primero.**
La query del paso 1 es la que confirma si el menú se va a llenar.

## Aplicado en Supabase (2026-10-15) ✅

- [x] **`20261012000001_crear_local_con_logo.sql`** — RPC con `p_logo_path`.
      Incluía el `DROP FUNCTION` de la firma vieja de 5 args, que sin él
      dejaba una sobrecarga ambigua y PostgREST devolvía *"function is not
      unique"*. Verificar igual que
      `pg_get_function_identity_arguments` devuelve **una sola fila con 6 args**.
- [x] **`20261012000002_locales_razon_social.sql`** — sin esto el logo del
      comprobante sale sin razón social.
- [x] **`20261012000003_ventas_numero_factura.sql`** — sin esto todas las
      ventas salen con `N° pendiente`.
- [x] **Edge Function `create-tenant` deployada.** Lleva el alta en
      `tenants` + `suscripciones` y ya **no** hardcodea `pin: "1234"`
      (que dejaba a todo tenant nuevo del SaaS con un PIN adivinable).
- [x] **`supabase secrets set TRIAL_PLAN_ID=trial`**

### ⚠️ Verificar que `TRIAL_PLAN_ID` sea un id real de `planes`

La EF inserta en `suscripciones.plan_id`, que es **FK a `planes.id`**. Si el
valor `trial` no existe en `planes`, el insert falla por violación de FK y el
tenant queda **sin suscripción**. La EF lo loguea y NO aborta el signup, a
propósito, así que el síntoma es invisible: el alta funciona pero la consola
SaaS no muestra plan.

```sql
-- Si no devuelve filas, usar el id real:
SELECT id, nombre FROM planes;
-- Verificar el plan_id que se está guardando:
SELECT tenant_id, estado, plan_id, trial_vence_en FROM suscripciones;
```

## Pendiente de aplicar en Supabase

- [ ] **`20261012000001_crear_local_con_logo.sql`** — redefine la RPC con
      `p_logo_path`. **Sin el `DROP FUNCTION` previo quedaría una sobrecarga
      ambigua** y PostgREST devolvería "function is not unique", rompiendo la
      creación de local para todos los usuarios. Verificar con
      `pg_get_function_identity_arguments` que hay **una sola** función.

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

## 📌 Deuda detectada — suite completo (RESUELTO · verde 2026-10-27)
- [x] BcvController disposed en cobrar_dialog_test e inventory_catalog_screen_test (~40 fallos).
      Riverpod scope roto. Ciclo de vida del provider. Ya no falla.
- [x] Textos/widgets desactualizados en parked_carts_dialog, save_cart_dialog, quantity_dialog (~12). Ya no fallan.
- [x] CircularDependencyError en local_actual_provider.dart:219 (9 fallos, BUG REAL). Ya no falla.
- [x] lote_tenant_id_contract_test.dart: path hardcodeado c:\Users\torre\... — no portable. Ya no falla.
- [x] sync_services_test.dart: mock HTTP no intercepta (~5). Ya no falla.
- [x] Test colgado: "... guarda 1 venta + N detalles en Isar" (integración Isar). Ya no se cuelga.
- Verificación: `flutter test` completo → 902 pasan, 1 omitida, 0 fallos.

## Cerrado en 2026-10-12 (Shorebird)

- [x] **Shorebird configurado 2026-10-12 (init --force).**
      app_id base (Windows): 66db3549-d408-4006-a746-c67ad7f711ca
      flavors:
        client: 0738ce2f-4460-4079-9f1d-38b6cc3daf64
        admin:  2ac7198d-03f1-4d9e-bc66-0a4faedbd76c
- [x] **Release 1.0.1+5 emitido SOLO vía Shorebird** (Android APK + Windows exe).
      Release IDs:
        · Android client: 894041
        · Windows:        894068
      U6 = B: distribución exclusiva por Shorebird (OTA).
      El APK de `flutter build apk --release` (108 MB, sin OTA) queda
      como artefacto histórico pero NO se distribuye.
- [x] **Instalador de Windows generado con inno_bundle.**
      Comando: `flutter build windows --release --target lib/main_client.dart`
               + `dart run inno_bundle --skip-app`
      ⚠️ `inno_bundle` NO acepta `--target`. El build de Flutter va por separado.
- [ ] Validar flujo de `shorebird patch` en la próxima iteración.

- ⚠️ **Notas operativas sobre Shorebird en Windows:**
  · `shorebird.bat` no quotea args (`%1..%9`) y rompe `--dart-define-from-file`.
    Usar `shorebird.ps1` directo desde PowerShell.
  · Cada flavor necesita su propia app en Shorebird. El valor en
    `flavors:` es el UUID (no el path al entrypoint).
  · Windows usa el app_id base (no tiene flavors).
  · `shorebird init --force` es interactivo: pipe `"y`n"` para confirmar.
  · **La ExecutionPolicy bloquea la invocación directa.** Hay que llamar
    `powershell.exe -NoProfile -ExecutionPolicy Bypass -File shorebird.ps1 …`
    o el comando falla en silencio (exit 0, output vacío).
  · `shorebird patch` **siempre** reporta `MaterialIcons-Regular.otf` como
    asset diff (es el tree-shaking de íconos, no un cambio real). Sin
    `--allow-asset-diffs` se cuelga pidiendo confirmación por stdin y
    aborta con "Input was required … non-interactive context".
    **Pasar la flag siempre.**
  · `shorebird releases get-apks` genera el APK **del release pedido**, no
    un "latest". Cada release nuevo hay que volver a correrlo.

## Cerrado en 2026-10-13 (patches + identidad visual)

### Releases y patches Android (client `0738ce2f-…`)

| ID | Versión | Qué contiene |
|---|---|---|
| `894041` | 1.0.1+5 | Release base. Patches #1, #2 y #3 encima |
| — | 1.1.0+6 | Ícono nuevo (azul `#2F81D3`). Sin patches |
| — | 1.1.1+7 | Nombre `BoostiPos`. Sin patches |

⚠️ **Los patches son POR RELEASE.** El #1/#2/#3 quedaron atados a `894041`
y **no** se aplican a `1.1.0+6` ni a `1.1.1+7`. Un tablet con `894041` +
patch 3 **no migra solo** a un release nuevo: hay que instalar el APK
encima. Por eso se hicieron 2 releases seguidos en vez de patches: cambiar
el ícono y el `android:label` son **recursos Android**, y un patch solo
empaqueta código Dart + assets.

### APK distribuible

```powershell
shorebird releases get-apks --flavor client --release-version 1.1.1+7 --out build\apks
```

→ `build\apks\universal.apk` (~114 MB, arm32+arm64+x86_64). Es
**autocontenida**: no necesita red ni patches. `build/` está en
`.gitignore`, así que nunca se commitea por accidente.

⚠️ **Android no refresca ícono ni label de una app ya instalada.** Para ver
el ícono azul y el nombre `BoostiPos` hay que **desinstalar la app vieja**
primero. No tocar "borrar datos" si querés conservar Isar.

### Identidad visual — `BoostiPos`

Nombre unificado en `android:label` (AndroidManifest), `inno_bundle.name`
(instalador Windows) y 10 textos Dart (splash, login, welcome, registro,
export CSV, bot de Telegram, tutorial).

⛔ **NO se toca `pubspec.yaml: name:`** (`app_boosti_v2`): es el nombre del
paquete Dart. Cambiarlo rompe todos los imports `package:app_boosti_v2/…`.

### 🔴 El secret `TRIAL_PLAN_ID` es una FK, no una etiqueta

`supabase secrets set TRIAL_PLAN_ID=trial` — si la tabla `planes` no tiene
una fila con `id = 'trial'`, el `INSERT INTO suscripciones` falla por
violación de FK. La EF **no aborta el signup** por diseño (el local y el
usuario ya están creados; perder el alta del cliente sería peor), así que
el tenant queda sin suscripción y nadie se entera hasta que se mira la
consola SaaS.

```sql
SELECT id, nombre FROM planes;   -- ← confirmar el id real
```

### Pendiente de commitear

El release `1.1.1+7` ya está publicado y la APK generada, pero los 54
archivos del ícono + nombre **siguen sin commitear**:
`android/app/src/main/res/**`, `assets/icon/**`, `ios/…/AppIcon*`, `web/**`,
`windows/runner/resources/app_icon.ico`, `pubspec.yaml`, 7 `.dart` con los
textos, los 3 `.md` y `tools/` (nuevo).

### 3 archivos de ícono, no uno

| Archivo | Para qué | Cómo se genera |
|---|---|---|
| `assets/icon/app_icon.png` | Legacy (Android < 8), Windows, web | A mano (1025×1025) |
| `assets/icon/app_icon_foreground.png` | **Adaptive icon, Android 8+** | `tools\gen_launcher_foreground.ps1` |
| `assets/icon/app_icon.ico` | Instalador Windows / accesos directos | `tools\gen_ico.ps1` |

⚠️ **En Android 8+ el launcher NO usa `app_icon.png`.** Usa
`adaptive_icon_background` (un color) + `adaptive_icon_foreground` (la
imagen). Cambiar solo el PNG deja el ícono viejo en el launcher.

⚠️ **El foreground va al ~62% del lienzo.** Los adaptive icons tienen zona
segura 66/108 (61%) y máscara visible 72/108 (67%). Un logo más grande se
recorta. `tools\gen_launcher_foreground.ps1` transparenta el fondo y
reescala solo.

⚠️ **`assets/icon/app_icon.ico` está declarado en
`inno_bundle.installer_icon`. Borrarlo rompe `dart run inno_bundle`**, y el
error no dice qué archivo falta.

⚠️ Borrar cualquier asset declarado en `pubspec.yaml: assets:` **rompe el
build de Flutter**. Si se elimina el archivo, sacar la línea también.

### Fotos de empleados — ocultas en TODAS las superficies

- [x] **Subida** congelada (política de datos sensibles). El botón abre un
      diálogo "Próximamente" (`empleado_form_dialog.dart`).
- [x] **Lectura** también apagada desde 2026-10-13. `empleado_card`,
      `employees_detail_screen` y `empleado_form_dialog` siempre pintan
      iniciales. El `Image.network` quedó comentado en los 3.
- `UsuarioEntity.fotoUrl` **sigue poblándose y sincronizándose** (push
  comentado, pull activo). Es lo que hace la decisión reversible sin
  volver a subir nada.
- Bug de paso: `_initials` hacía `''.split(RegExp(r'\s+'))`, que devuelve
  `['']` y nunca `[]`. El `if (parts.isEmpty)` no se cumplía nunca y
  `''.substring(0, 1)` lanzaba `RangeError`: **cualquier empleado sin
  nombre reventaba la pantalla de empleados.** Ahora devuelve `'?'`.

### Bug abierto — lock screen exige 4 dígitos, el PIN admite hasta 6

`rest_screen.dart:88` → `if (_enteredPin.length != 4) return;` y `:152` →
`if (_enteredPin.length < 4)`. Pero `SecureCredentials.validatePin` acepta
4-6 y `cambiar_pin_dialog` deja elegir. **Un usuario con PIN de 5 o 6
dígitos queda soft-loqueado en cada descanso**, sin mensaje que lo explique.
El mismo bug se corrige cambiando el bound de `RestScreen` a 6.