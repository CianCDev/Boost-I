# Reglas de Negocio — Suscripciones y Planes

## 1. Ciclo de vida de un trial

- **Duración**: 15 días desde la creación del tenant.
- **Al vencer sin conversión**: el tenant pasa a estado `expirado`.
- **Comportamiento durante trial**: acceso completo a todas las funcionalidades según el plan Trial.
- **Alerta temprana**: 3 días antes del vencimiento, mostrar banner de alerta en la app del cliente.

## 2. Ciclo de vida de una suscripción activa

### Pago vencido
- **Días de gracia**: 5 días.
- **Durante la gracia**: el tenant sigue operativo pero con banner persistente "Pago pendiente".
- **Al cumplir los 5 días sin pago**: bloqueo total del tenant. El usuario solo puede:
  - Ver un mensaje de bloqueo.
  - **Exportar sus datos** (backup descargable en JSON/CSV).
  - Contactar al admin.
- **Reactivación**: al registrar el pago, se reactiva automáticamente.

### Cancelación voluntaria
- El tenant pasa a `cancelado`.
- **Período de gracia**: 5 días para exportar datos.
- Después de 5 días: bloqueo total.
- Los datos NO se eliminan automáticamente (se conservan por si el cliente vuelve).

## 3. Planes

### Reglas generales
- **Usuarios por tenant**: ILIMITADOS en todos los planes.
- **Productos / categorías / proveedores**: ILIMITADOS en todos los planes.
- **Locales**: única restricción.

### Límites por plan

| Plan | Locales | Usuarios | Productos |
|------|---------|----------|-----------|
| trial | ∞ | ∞ | ∞ |
| basico | **2** | ∞ | ∞ |
| pro | ∞ | ∞ | ∞ |
| enterprise | ∞ | ∞ | ∞ |

- Si un tenant en plan Básico intenta crear un 3er local: mostrar diálogo "Actualiza a Pro para agregar más locales".

## 4. Cambios de plan

### Upgrade (Básico → Pro)
- **Prorrateo**: cobrar la diferencia proporcional a los días restantes del ciclo actual.
- Ejemplo: ciclo de 30 días, día 15, cambio de Básico ($10) a Pro ($25):
  - Diferencia diaria: ($25 - $10) / 30 = $0.50/día
  - Días restantes: 15
  - Cobro inmediato: $7.50
- Se registra en `suscripcion_historial` con `tipo_cambio = 'upgrade'`.
- El nuevo plan aplica inmediatamente.

### Downgrade (Pro → Básico)
- **Prorrateo**: NO se reembolsa la diferencia.
- Se aplica al **inicio del siguiente ciclo**.
- Si el tenant tiene más locales que el nuevo plan permite:
  - **Opción 3 (advertencia)**: mostrar advertencia al hacer downgrade.
  - El cliente tiene **7 días** para decidir qué hacer con los locales extra.
  - Pasado el plazo, los locales excedentes se desactivan automáticamente (no se eliminan).
  - Se registra en `suscripcion_historial` con `tipo_cambio = 'downgrade'`.

### Cancelación
- **Sin prorrateo**: el servicio sigue activo hasta el fin del período pagado.
- Se registra en `suscripcion_historial` con `tipo_cambio = 'cancelled'`.

### Reactivación
- Si cancela y vuelve antes de 30 días: mismo plan, mismo precio.
- Si vuelve después de 30 días: se re-evalúa el plan actual (puede haber cambiado de precio).
- Se registra en `suscripcion_historial` con `tipo_cambio = 'reactivated'`.

## 5. Reglas de bloqueo

Cuando un tenant está bloqueado (`expirado` o `cancelado` con gracia vencida):
- **Login permitido**: sí, pero redirige a pantalla de "Cuenta bloqueada".
- **Operaciones de venta**: bloqueadas.
- **Configuración**: bloqueada.
- **Exportación de datos**: permitida durante los 5 días de gracia.
- **Reactivación**: cualquier superadmin puede reactivar manualmente (registrado en `suscripcion_historial`).

## 6. Notificaciones automáticas

### Al cliente (futuro, en TODO)
- Día 12 del trial: "Tu trial vence en 3 días".
- Día 14 del trial: "Tu trial vence mañana".
- Día 1 post-vencimiento: "Tu cuenta expiró, exporta tus datos".
- Día 3 de gracia: "Últimos 2 días para exportar".

### Al admin (superadmin)
- Trial por vencer en 3 días (dashboard).
- Cliente con pago vencido (dashboard).
- Cliente inactivo >15 días (dashboard).

## 7. Datos personales y retención

- Los datos de un tenant bloqueado se conservan **indefinidamente** hasta que el cliente solicite su eliminación.
- El cliente puede exportar sus datos en cualquier momento durante los 5 días de gracia.
- Después de 90 días de bloqueo sin reactivación, el superadmin puede marcar el tenant para eliminación (aún no automatizado).

## 8. KPIs v1 (Dashboard)

- MRR
- Clientes activos
- Trials activos
- Trials por vencer (3 días)
- Cancelaciones últimos 30 días
- ARR

## 9. TODO (v2+)

- Integración con pasarela legal de pagos (Stripe, MercadoPago, etc.).
- Facturación automática.
- Recordatorios por email/WhatsApp.
- Cohortes de retención.
- LTV / CAC.
- Predicción de churn.
- Integración con email (Gmail/Outlook) en notas CRM.
- 2FA para superadmin.

---

# Reglas de Negocio — Inventario y Lotes

> Agregadas en la sesión del 2026-10-09. Estas reglas **no** viven en el modelo de
> planes: son invariantes del modelo de datos que, si se rompen, corrompen stock.

## 10. Los lotes son la fuente única de verdad del stock

- `productos.stock` es un **cache derivado**, escrito únicamente por
  `IsarService.recalcularStockDe([...])`.
- **Prohibido** escribir `producto.stock` a mano. Toda operación que cambie existencias
  mueve `lotes.cantidad_restante` y recién después recalcula.
- `ProductosNotifier.actualizarStock` está `@Deprecated` y no tiene callers: existe solo
  para que un refactor futuro no la reintroduzca.
- **Por qué**: la duplicación de fuentes produjo el incidente del Arroz (165 → 175), donde
  el stock subió sin que el inventario real cambiara.

### consuming stock en la venta

- El carrito **NO** descuenta stock (Fase 1). Se descuenta recién al confirmar el cobro,
  en `VentaService.procesarVenta`.
- El consumo es **FEFO** (First Expired, First Out): `IsarService.obtenerLotesActivos`
  ordena por `fechaVencimiento` ascendente, con los lotes sin fecha al final.
- ⚠️ `procesarVenta` **no tiene transacción**: si falla después de consumir los lotes, el
  stock queda descontado sin venta registrada. Deuda conocida.

## 11. Vencimientos

- `lote.fecha_vencimiento` es **nullable** y así se mantiene: un producto no perecedero
  legítimamente no tiene fecha.
- El vencimiento más próximo por producto se calcula con estos filtros, y en este orden
  (`vencimientosProvider` en `lotes_provider.dart`):
  1. `estado == 'activo'` — excluye `agotado`, `vencido` y `pendiente`.
  2. `cantidad_restante > 0` — un lote agotado que vence mañana no es una urgencia.
  3. `fecha_vencimiento != null`.
- Si un producto tiene 3 lotes y solo 1 con fecha, **se usa ese**. El mínimo absoluto entre
  los que tienen fecha, así que un lote ya vencido gana y sale como `VENCIDO`.
- Umbrales de alerta (`expiry_utils.dart`): rojo ≤3 días, ámbar ≤7, ámbar atenuado ≤15,
  oculto >15.
- La **fecha que cuenta es la de la tasa/lote, no la del fetch**: la BCV publica una vez
  por día, así que "actualizado a las 21:22" puede ser una tasa de la madrugada.

## 12. Baja de lote (antes mal llamada "Reponer")

`TraspasoLoteDialog` saca unidades **de un lote**. El nombre viejo ("Reponer inventario",
tipo de movimiento `'traspaso'`) describía la inversa de lo que hace, y por eso el
Snackbar anunciaba "unidades repuestas" mientras el stock **bajaba**.

- Nombre en UI: **"Dar de baja del lote"**.
- Tipo de movimiento: **`'baja'`** (antes `'traspaso'`).
- Observación: `'Baja manual de lote'`.
- **No existe un "inventario general"**: no hay una segunda ubicación a la que mover
  stock. Un traspaso entre dos lotes sería otra operación y no está implementada.
- `'traspaso'` se conserva como valor histórico en `MovimientoLoteEntity.tipo`: hay
  movimientos ya escritos con ese valor en Isar y en la nube. Los 3 switches de historial
  mapean ambos.

## 13. Locales y planes

- El plan es **único por tenant** (`SuscripcionEntity.tenantId` es `@Index(unique: true)`).
  No existe plan por local. `LocalEntity.supabaseId` **es** el `tenant_id`.
- `productos_id_isar` es UNIQUE **global**, no por tenant: bug latente multi-tenant.
- **Cambiar de local no está gateado por plan.** Es navegación, no un módulo de negocio.
  El botón "Cambiar local" del panel lateral se muestra solo si hay >1 local
  (`obtenerMisLocales()`), nunca por `flags.multiLocal`.
  - **Por qué**: gatearlo creaba un deadlock. Al cambiar a un local sin plan se apagaba
    `multi_local`, y con él desaparecían a la vez la entrada "Locales" del menú y el
    botón de volver. No había salida sin cerrar sesión.
- Gating de pantallas que sí corresponde al plan: `Pedidos` y `Lotes` vía `planActivo`,
  con `ModuleGate` como red de seguridad a nivel de pantalla (el menú solo no alcanza,
  porque las pantallas se abren con `Navigator.push` sin guarda).

## 14. Tasa de cambio

- La app **nunca** debe reportar "Sin conexión" si la tasa es correcta y fresca.
  `BcvController.desdeCache` es `true` **solo** para `cacheObsoleta` (>24 h).
- Tasa manual **no** es un fallo de conexión: es una decisión del usuario y se informa con
  otro mensaje y otro color.
- Si el fetch de suscripción falla por red, `featureFlagsProvider` usa el último
  `planActivo` cacheado en prefs (`plan_activo_cache`). Si nunca hubo caché, **deniega**
  (fail-closed): abrir módulos sin poder verificar el plan es el peor error posible en un
  gate de monetización.
