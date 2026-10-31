-- ============================================================
-- Datos de prueba · modo restaurante (zonas, mesas, estaciones)
--
-- Para qué: llenar el Salón/Caja y la pantalla de Estaciones sin tener
-- que crear 20 mesas a mano en el teléfono.
--
-- ⚠️ ANTES DE CORRER: cambiá `v_local_nombre` por el nombre (o parte del
--    nombre) del local que estás probando. Si lo dejás vacío y hay un
--    solo local, lo toma; si hay varios, aborta y te lista los nombres.
--
-- Idempotente: se puede correr las veces que haga falta. No borra nada:
--   · zonas  → ON CONFLICT del índice parcial (tenant_id, nombre) vivo
--   · mesas  → idem
--   · deptos → WHERE NOT EXISTS por nombre
--
-- Multi-tenant: todo se inserta con el `tenant_id` del local elegido.
-- El sync de la app baja estos registros por `tenant_id` y los adopta
-- por nombre/UUID (sync_service.dart:3584 y :3745).
-- ============================================================

DO $seed$
DECLARE
  -- ⚙️ CAMBIAR ACÁ
  v_local_nombre text := 'JAHTLABS';

  v_tenant  uuid;
  v_total   int;
  v_lista   text;
BEGIN
  -- ── 1. Resolver el tenant ──────────────────────────────────
  IF v_local_nombre IS NULL OR btrim(v_local_nombre) = '' THEN
    SELECT count(*) INTO v_total FROM public.locales;
    IF v_total <> 1 THEN
      SELECT string_agg(nombre, ', ' ORDER BY nombre) INTO v_lista
        FROM public.locales;
      RAISE EXCEPTION
        'Hay % locales. Especificá v_local_nombre. Locales: %',
        v_total, v_lista;
    END IF;
    SELECT id INTO v_tenant FROM public.locales LIMIT 1;
  ELSE
    SELECT id INTO v_tenant
      FROM public.locales
     WHERE nombre ILIKE '%' || v_local_nombre || '%'
     ORDER BY created_at
     LIMIT 1;

    IF v_tenant IS NULL THEN
      SELECT string_agg(nombre, ', ' ORDER BY nombre) INTO v_lista
        FROM public.locales;
      RAISE EXCEPTION
        'No hay local que coincida con "%". Locales: %',
        v_local_nombre, v_lista;
    END IF;
  END IF;

  -- ── 2. Zonas ───────────────────────────────────────────────
  INSERT INTO public.zonas (tenant_id, nombre, orden, activo, eliminado)
  VALUES
    (v_tenant, 'Salón',   0, true, false),
    (v_tenant, 'Terraza', 1, true, false),
    (v_tenant, 'Barra',   2, true, false),
    (v_tenant, 'Patio',   3, true, false)
  ON CONFLICT (tenant_id, nombre) WHERE eliminado = false DO NOTHING;

  -- ── 3. Mesas (nombre único por tenant: "Salón 1", "Terraza 2"…) ──
  INSERT INTO public.mesas
    (tenant_id, zona_id, zona_nombre, nombre, capacidad, orden_grid, eliminado)
  SELECT
    v_tenant,
    z.id,
    z.nombre,
    z.nombre || ' ' || g.n,
    CASE WHEN g.n <= 2 THEN 2 WHEN g.n <= 4 THEN 4 ELSE 6 END,
    (z.orden * 100) + g.n,
    false
  FROM (VALUES
          ('Salón',   6),
          ('Terraza', 4),
          ('Barra',   3),
          ('Patio',   3)
       ) AS cfg(zona, cantidad)
  JOIN public.zonas z
    ON z.tenant_id = v_tenant
   AND z.nombre = cfg.zona
   AND z.eliminado = false
  CROSS JOIN LATERAL generate_series(1, cfg.cantidad) AS g(n)
  ON CONFLICT (tenant_id, nombre) WHERE eliminado = false DO NOTHING;

  -- ── 4. Estaciones de cocina (KDS) ──────────────────────────
  INSERT INTO public.departamentos
    (tenant_id, nombre, descripcion, activo, sincronizado)
  SELECT v_tenant, cfg.nombre, cfg.descripcion, true, true
  FROM (VALUES
          ('Cocina',  'Platos calientes y principales'),
          ('Barra',   'Bebidas, cócteles y café'),
          ('Postres', 'Postres y repostería')
       ) AS cfg(nombre, descripcion)
  WHERE NOT EXISTS (
    SELECT 1 FROM public.departamentos d
     WHERE d.tenant_id = v_tenant
       AND d.nombre = cfg.nombre
  );

  RAISE NOTICE 'Seed OK para tenant % (%). Zonas: %, mesas: %, estaciones: %',
    v_tenant,
    (SELECT nombre FROM public.locales WHERE id = v_tenant),
    (SELECT count(*) FROM public.zonas      WHERE tenant_id = v_tenant AND eliminado = false),
    (SELECT count(*) FROM public.mesas      WHERE tenant_id = v_tenant AND eliminado = false),
    (SELECT count(*) FROM public.departamentos WHERE tenant_id = v_tenant);
END
$seed$;

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

-- Mesas por zona
SELECT z.orden, z.nombre AS zona, count(m.id) AS mesas
  FROM public.zonas z
  LEFT JOIN public.mesas m
    ON m.zona_id = z.id AND m.eliminado = false
 WHERE z.eliminado = false
 GROUP BY z.orden, z.nombre
 ORDER BY z.orden;

-- Estaciones
SELECT nombre, descripcion, activo
  FROM public.departamentos
 ORDER BY nombre;
