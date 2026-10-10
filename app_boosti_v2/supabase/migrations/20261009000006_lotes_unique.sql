-- ═══════════════════════════════════════════════════════════════
-- UNIQUE (tenant_id, id_isar) en lotes.
--
-- Bug: `sincronizarLotesPendientes` confía en un try/catch de
-- "duplicate key" para caer al update. Sin constraint, el insert
-- NUNCA falla y el lote se duplica en cada sync.
--
-- Mismo patrón que tiene `productos` con `productos_id_isar_unique`.
-- Aquí lo hacemos por tenant (no global) para no chocar cuando
-- productos de tenants distintos tengan el mismo id local.
--
-- Antes de añadir la constraint, limpia los duplicados existentes
-- conservando el más reciente por fecha_sincronizacion.
--
-- ⚠️ VERIFICADO contra la base real (2026-10-08) antes de escribir esto.
--
--   Constraints actuales de `lotes`:
--     · lotes_pkey                      PRIMARY KEY (id)   ← id es uuid
--     · lotes_producto_id_fk_fkey       FK → productos(id_isar) SET NULL
--     · lotes_tenant_fk                 FK → locales(id) CASCADE
--   → NO existía ninguna UNIQUE sobre `id_isar`. Por eso el
--     `insert` + catch "duplicate key" nunca caía al update.
--
--   Duplicado real encontrado (tenant JAHTLABS, `id_isar` = 1):
--     133cf99a…  inicial=100  restante=200  activo  sync 21:16:50
--     20680fa5…  inicial=100  restante=150  activo  sync 21:15:28
--   El más reciente (133cf99a) es el que se conserva.
--
--   Nota: ambas filas tienen `restante > inicial`, el mismo patrón de
--   corrupción que suffers el Arroz (4 lotes). La migración 00005 borra
--   los lotes del tenant de pruebas antes que ésta, así que probablemente
--   el cleanup de abajo no encuentre nada. Se mantiene por idempotencia:
--   si se aplica 00006 sin 00005, igual repara.
--
-- ⚠️ SE DEBE APLICAR DESPUÉS de 20261009000005_reset_inventario_pruebas.sql
--    si se quiere limpiar ese tenant; en cualquier otro orden funciona.
-- ═══════════════════════════════════════════════════════════════

-- 1. Limpiar duplicados: conservar 1 por (tenant_id, id_isar).
--    Se conserva el de `fecha_sincronizacion` más reciente, con desempate
--    estable por `id` (uuid) para que la migración sea determinista.
WITH ranked AS (
  SELECT id, tenant_id, id_isar,
         ROW_NUMBER() OVER (
           PARTITION BY tenant_id, id_isar
           ORDER BY fecha_sincronizacion DESC NULLS LAST, id
         ) AS rn
  FROM public.lotes
  WHERE id_isar IS NOT NULL
)
DELETE FROM public.lotes
WHERE id IN (SELECT id FROM ranked WHERE rn > 1);

-- 2. Añadir la constraint.
ALTER TABLE public.lotes
  DROP CONSTRAINT IF EXISTS lotes_id_isar_tenant_uk;
ALTER TABLE public.lotes
  ADD CONSTRAINT lotes_id_isar_tenant_uk UNIQUE (tenant_id, id_isar);

COMMENT ON CONSTRAINT lotes_id_isar_tenant_uk ON public.lotes IS
  'Clave de cruce lote local↔nube. Permite ON CONFLICT en el upsert de '
  'sincronizarLotesPendientes. Por tenant: id_isar es el autoincrement de '
  'Isar local y colisiona entre tenants.';