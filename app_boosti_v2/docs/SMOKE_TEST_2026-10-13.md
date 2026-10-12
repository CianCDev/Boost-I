# Smoke test v1 — 2026-10-13

Usuario: [COMPLETAR]
Rama: main
Commit: `724cddf`
Build: `flutter run --flavor client --target lib/main_client.dart --dart-define-from-file=env.json -d <device>`

> ⚠️ **Sin `env.json` el build arranca degradado en silencio**: las variables
> quedan vacías y no hay error visible. Si falla la conexión, sospechá esto primero.

## 0. Preparación

- [ ] App instalada con build de debug
- [ ] `env.json` presente y con el flag `--dart-define-from-file`
- [ ] Usuario con acceso a 2 locales (JAHTLABS + centro)
- [ ] Plan activo con multi_local
- [ ] Conexión estable

## 1. BCV

- [ ] 1.1 Fresco: abrir app → badge muestra tasa del día, sin aviso ámbar
- [ ] 1.2 Obsoleto: forzar cache >24h → aviso correcto
- [ ] 1.3 Manual: tasa manual muestra "ingresada manualmente" en azul

## 2. Ventas

- [ ] 2.1 Venta simple (1 producto, efectivo exacto)
- [ ] 2.2 Venta multi-item (3 productos)
- [ ] 2.3 Venta con cliente
- [ ] 2.4 Venta multipago (efectivo + Pago Móvil)
- [ ] 2.5 Venta con descuento especial

## 3. Anulación

- [ ] 3.1 Anular venta simple → stock restaurado
- [ ] 3.2 Anular venta multi-item → todos los stocks restaurados

## 4. Hot-switch

- [ ] 4.1 JAHTLABS → centro → venta en centro → `tenant_id`=centro en Supabase
- [ ] 4.2 centro → JAHTLABS → venta → `tenant_id`=JAHTLABS
- [ ] 4.3 Con el JWT desalineado, el banner de vista previa aparece y
      `GuardTenantActivo` bloquea cobrar / descuento / crear pedido / activar lote

## 5. Sync

- [ ] 5.1 Forzar sync completo → sin errores 42P10 / 23503 / duplicate key
- [ ] 5.2 `SUM(lotes activos)` == `productos.stock`
- [ ] 5.3 Logo del ticket impreso sale con el del local (o cae al fallback
      sin romper el ticket)

## 6. UI nueva

- [ ] 6.1 Badge de vencimiento en **grid** — pill con icono. **Ojo:** la
      vista de **lista** sigue con el chip viejo, es esperado.
- [ ] 6.2 Ticket con logo del local
- [ ] 6.3 AppBar de Inicio **sin barra**: fondo transparente, base blanca en
      logo/avatar/logout, pill BCV violeta. Hover y squash al presionar.
- [ ] 6.4 `LocalActivoChip` en Menú POS → tap abre el selector y cambia de local
- [ ] 6.5 Productos aparecen al abrir la app sin hacer hot-switch
      ⚠️ **Este es el que más probablemente falle**: el fix de `isLoading`
      cubre el caso "Isar vacío". Si falla, registrar el síntoma exacto:
      ¿spinner eterno o grilla vacía con datos?

## 7. Responsive

- [ ] 7.1 AppBar sin cortes en ~360px
- [ ] 7.2 `LocalActivoChip` con nombre de local largo ("Sucursal Norte -
      Valencia") → recorta con ellipsis, no desborda
- [ ] 7.3 Grilla de productos: el pill de vencimiento no se solapa con
      "¡Stock bajo!" en móvil

## Resultado

| # | Estado | Observación |
|---|--------|-------------|
|   | ✅/❌  |             |

Errores encontrados:
-

---

## Notas de interpretación

- **Un fallo en 6.5 no invalida el commit.** El fix de `isLoading` se aplicó
  sin device: entra en el smoke test precisamente para confirmarlo.
- **Los 4 puntos de `GuardTenantActivo` (4.3)** son el corazón del cambio de
  seguridad. Si el guard no bloquea, es un hallazgo crítico: significaría que
  se puede escribir en el tenant del JWT viendo otro local.
