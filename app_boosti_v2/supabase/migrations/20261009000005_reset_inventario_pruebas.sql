-- ═══════════════════════════════════════════════════════════════
-- Reset de inventario para el tenant de pruebas.
--
-- Borra lotes y movimientos del tenant, y pone stock = 0.
-- Ejecutar SOLO en fase de pruebas. Una vez aplicado, el sync local
-- bajará el estado limpio y la app arrancará con stock = 0.
--
-- Para limpiar otro tenant, cambia `v_tenant_id`.
--
-- ⚠️ VERIFICADO contra la base (2026-10-08) antes de escribir esto:
--
--   locales 9c7380a4-14be-41c2-88db-07606c2a6489 = 'JAHTLABS'  ✅ existe
--   (la otra local es 'centro', fd3dee41-54b0-40b7-b83b-5f9f1b3cc3f8)
--
--   Impacto para este tenant:
--     · 44 filas en movimientos_inventarios  → borradas
--     · 25 filas en lotes                   → borradas
--     ·  3 filas en productos               → stock = 0
--     ·  0 filas en movimiento_lotes        → no existe esa tabla en la nube
--
-- ⚠️ `productos.id_isar` es UNIQUE GLOBAL (no por tenant) y las FKs
-- de `lotes.producto_id_fk` son `ON DELETE SET NULL`. Poner stock = 0
-- no rompe ninguna FK; solo se pierden los lotes de este tenant.
-- ═══════════════════════════════════════════════════════════════

DO $$
DECLARE
  v_tenant_id uuid := '9c7380a4-14be-41c2-88db-07606c2a6489';
  v_movs integer;
  v_lotes integer;
  v_prods integer;
BEGIN
  SELECT count(*) INTO v_movs
    FROM public.movimientos_inventarios WHERE tenant_id = v_tenant_id;

  SELECT count(*) INTO v_lotes
    FROM public.lotes WHERE tenant_id = v_tenant_id;

  SELECT count(*) INTO v_prods
    FROM public.productos WHERE tenant_id = v_tenant_id;

  DELETE FROM public.movimientos_inventarios WHERE tenant_id = v_tenant_id;
  DELETE FROM public.lotes WHERE tenant_id = v_tenant_id;
  UPDATE public.productos SET stock = 0 WHERE tenant_id = v_tenant_id;

  RAISE NOTICE '✅ Reset aplicado para tenant % (JAHTLABS): % movimientos, % lotes borrados; % productos con stock = 0',
    v_tenant_id, v_movs, v_lotes, v_prods;
END $$;