-- ============================================================
-- Datos de prueba · catálogo de restaurante (opcional)
--
-- Solo si el local de pruebas no tiene productos. Crea 4 categorías y
-- 10 productos con precios de restaurante.
--
-- ⚠️ ANTES: cambiá `v_local_nombre` igual que en
--    `20261030000001_datos_prueba_restaurante.sql`.
--
-- ⚠️ `productos.id_isar` es UNIQUE **global** en este esquema (bug
--    latente multi-tenant, ver docs/TODO.md). Por eso el seed usa
--    990001+ y `ON CONFLICT DO NOTHING`: si otro tenant ya usó esos
--    números, no inserta y no rompe.
--
-- ⚠️ `productos.departamento_id` NO existe en Supabase (es local-only,
--    decisión D2a). Los productos inyectados nacen SIN estación: para
--    probar el KDS asigná la estación desde Productos → editar.
-- ============================================================

DO $seed$
DECLARE
  -- ⚙️ CAMBIAR ACÁ (mismo valor que el otro seed)
  v_local_nombre text := 'JAHTLABS';

  v_tenant uuid;
  v_total  int;
  v_lista  text;
BEGIN
  IF v_local_nombre IS NULL OR btrim(v_local_nombre) = '' THEN
    SELECT count(*) INTO v_total FROM public.locales;
    IF v_total <> 1 THEN
      SELECT string_agg(nombre, ', ' ORDER BY nombre) INTO v_lista
        FROM public.locales;
      RAISE EXCEPTION 'Hay % locales. Especificá v_local_nombre. Locales: %',
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
      RAISE EXCEPTION 'No hay local que coincida con "%". Locales: %',
        v_local_nombre, v_lista;
    END IF;
  END IF;

  -- ── Categorías ─────────────────────────────────────────────
  INSERT INTO public.categorias (tenant_id, nombre, descripcion)
  SELECT v_tenant, cfg.nombre, cfg.descripcion
  FROM (VALUES
          ('Entradas', 'Para compartir'),
          ('Platos',   'Platos principales'),
          ('Bebidas',  'Fríos y calientes'),
          ('Postres',  'Dulces')
       ) AS cfg(nombre, descripcion)
  WHERE NOT EXISTS (
    SELECT 1 FROM public.categorias c
     WHERE c.tenant_id = v_tenant AND c.nombre = cfg.nombre
  );

  -- ── Productos ──────────────────────────────────────────────
  INSERT INTO public.productos
    (codigo_barras, nombre, precio_unidad, stock, stock_minimo,
     es_pesado, categoria, id_isar, uuid, tenant_id, activo)
  SELECT
    cfg.codigo, cfg.nombre, cfg.precio, 999, 5,
    false, cfg.categoria, cfg.id_isar, gen_random_uuid(), v_tenant, true
  FROM (VALUES
          ('REST-001', 'Hamburguesa Clásica',  5.50, 'Platos',  990001),
          ('REST-002', 'Pizza Margarita',      8.00, 'Platos',  990002),
          ('REST-003', 'Pollo a la Brasa',     7.50, 'Platos',  990003),
          ('REST-004', 'Ensalada César',       4.50, 'Entradas',990004),
          ('REST-005', 'Papas Fritas',         3.00, 'Entradas',990005),
          ('REST-006', 'Refresco',             1.50, 'Bebidas', 990006),
          ('REST-007', 'Jugo Natural',         2.00, 'Bebidas', 990007),
          ('REST-008', 'Café',                 1.20, 'Bebidas', 990008),
          ('REST-009', 'Cerveza',              2.50, 'Bebidas', 990009),
          ('REST-010', 'Postre del Día',       3.50, 'Postres', 990010)
       ) AS cfg(codigo, nombre, precio, categoria, id_isar)
  ON CONFLICT DO NOTHING;

  RAISE NOTICE 'Catálogo OK para tenant %: % categorías, % productos',
    v_tenant,
    (SELECT count(*) FROM public.categorias WHERE tenant_id = v_tenant),
    (SELECT count(*) FROM public.productos  WHERE tenant_id = v_tenant);
END
$seed$;

-- Verificación
SELECT p.categoria, count(*) AS productos
  FROM public.productos p
 GROUP BY p.categoria
 ORDER BY p.categoria;
