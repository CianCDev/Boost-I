-- ═══════════════════════════════════════════════════════════════
-- R.4 · G.1 · Recetas en Supabase: `recetas` + `receta_ingredientes`.
--
-- Hasta hoy la receta era 100% local: `sync_service` no la empujaba y
-- `isar_service` no tenía `toSupabaseJson` / `fromSupabase`. Consecuencia:
-- una receta capturada en un dispositivo no existía en el otro, y una
-- reinstalación se la llevaba por delante. Esta migración crea el destino y
-- la RPC que la escribe de forma ATÓMICA.
--
-- ⚠️ QUÉ HACE FALTA APLICAR (owner)
--   1. Correr este archivo en el SQL Editor de Supabase.
--   2. Verificar (queries al final del archivo).
--   3. `supabase migration repair --status applied 20261027000001`
--      ⚠️ `repair` NO ejecuta SQL: solo alinea el historial. Nunca al revés.
--
-- ⚠️ POR QUÉ UNA RPC Y NO 3 LLAMADAS DESDE EL CLIENTE
--
-- Una receta es una fila + N ingredientes. Si el cliente hace
-- "upsert receta → delete ingredientes → insert ingredientes" son 3 viajes
-- sin transacción: un corte de red entre el DELETE y el INSERT deja la
-- receta SIN ingredientes en la nube, y esa versión vacía se propaga a los
-- demás dispositivos en el siguiente pull. Descontar stock de un plato cuya
-- receta se vació sola es peor que no sincronizar.
--
-- `guardar_receta()` hace el reemplazo completo en UNA transacción: o queda
-- la receta nueva entera, o no queda nada.
--
-- ⚠️ POR QUÉ SECURITY INVOKER (no DEFINER)
--
-- Corre con los permisos del usuario autenticado, así que la RLS se aplica
-- de verdad. Un `SECURITY DEFINER` habría que blindarlo a mano contra
-- `p_receta->>'tenant_id'`; aquí el tenant sale SIEMPRE de
-- `current_tenant_id()` (el JWT) y el cliente no puede elegirlo. Es la
-- misma lección que dejó el bug de los lotes subidos al tenant equivocado
-- durante la ventana del hot-switch.
--
-- ⚠️ SIN FK EN `ingrediente_id_fk`
--
-- `producto_id_fk` sí referencia `productos(id_isar)`: una receta sin plato
-- no significa nada. El ingrediente es distinto: es un dato de la receta y
-- viaja con ella aunque ese producto todavía no haya subido (o se haya
-- borrado). `ingrediente_nombre` es el snapshot que la mantiene legible, así
-- que la FK solo serviría para bloquear el push entero por un ingrediente.
-- ═══════════════════════════════════════════════════════════════

-- ── 1. Tabla recetas ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.recetas (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    id_isar integer NOT NULL,
    tenant_id uuid NOT NULL DEFAULT public.current_tenant_id(),
    -- productos.id_isar (bigint, UNIQUE global en la nube).
    producto_id_fk bigint NOT NULL,
    nombre_plato text NOT NULL DEFAULT '',
    rinde_porciones numeric NOT NULL DEFAULT 1,
    activo boolean NOT NULL DEFAULT true,
    sincronizado boolean NOT NULL DEFAULT true,
    fecha_sincronizacion timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT recetas_id_isar_tenant_uk UNIQUE (tenant_id, id_isar),
    CONSTRAINT recetas_rinde_porciones_ck CHECK (rinde_porciones > 0),
    CONSTRAINT recetas_tenant_fk FOREIGN KEY (tenant_id)
        REFERENCES public.locales(id) ON DELETE CASCADE,
    CONSTRAINT recetas_producto_fk FOREIGN KEY (producto_id_fk)
        REFERENCES public.productos(id_isar) ON DELETE CASCADE
);

COMMENT ON TABLE public.recetas IS
  'Receta de un plato (R.4 G.1). id_isar = id de Isar del dispositivo que '
  'la creó; la clave de cruce real es (tenant_id, id_isar).';
COMMENT ON COLUMN public.recetas.producto_id_fk IS
  'productos.id_isar del plato. Sin FK compuesta: id_isar es UNIQUE global.';
COMMENT ON COLUMN public.recetas.rinde_porciones IS
  'Cuántas porciones rinde la receta. 1 = las cantidades son por plato.';

-- ── 2. Tabla receta_ingredientes ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.receta_ingredientes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    receta_id uuid NOT NULL,
    tenant_id uuid NOT NULL DEFAULT public.current_tenant_id(),
    -- Orden de captura: la UI los pinta en este orden y el pull lo respeta.
    orden integer NOT NULL DEFAULT 0,
    -- productos.id_isar del ingrediente. Sin FK a propósito (ver cabecera).
    ingrediente_id_fk bigint,
    ingrediente_nombre text NOT NULL DEFAULT '',
    cantidad numeric NOT NULL DEFAULT 0,
    unidad text NOT NULL DEFAULT 'unidad',
    es_opcional boolean NOT NULL DEFAULT false,
    CONSTRAINT receta_ingredientes_receta_fk FOREIGN KEY (receta_id)
        REFERENCES public.recetas(id) ON DELETE CASCADE,
    CONSTRAINT receta_ingredientes_tenant_fk FOREIGN KEY (tenant_id)
        REFERENCES public.locales(id) ON DELETE CASCADE
);

COMMENT ON TABLE public.receta_ingredientes IS
  'Ingredientes de una receta. Se reemplazan COMPLETOS en cada push: la '
  'receta se edita como un todo, no ingrediente por ingrediente.';
COMMENT ON COLUMN public.receta_ingredientes.unidad IS
  'Unidad en que está escrita la cantidad (kg, g, lt, ml, unidad). Se '
  'convierte a la del inventario al descontar stock.';
COMMENT ON COLUMN public.receta_ingredientes.ingrediente_id_fk IS
  'productos.id_isar del ingrediente. Sin FK: la receta tiene que poder '
  'viajar aunque ese producto aún no haya subido.';

-- ── 3. Índices ───────────────────────────────────────────────────
-- El pull filtra por tenant y ordena por plato; el push resuelve por
-- (tenant, id_isar) con la UNIQUE de arriba.
CREATE INDEX IF NOT EXISTS idx_recetas_tenant
    ON public.recetas USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_recetas_producto
    ON public.recetas USING btree (producto_id_fk);
CREATE INDEX IF NOT EXISTS idx_receta_ingredientes_receta
    ON public.receta_ingredientes USING btree (receta_id);
CREATE INDEX IF NOT EXISTS idx_receta_ingredientes_tenant
    ON public.receta_ingredientes USING btree (tenant_id);

-- ── 4. RLS ───────────────────────────────────────────────────────
-- Idempotente con `DO $$`: se puede correr dos veces sin "already exists".
ALTER TABLE public.recetas ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.receta_ingredientes ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'recetas'
      AND policyname = 'tenant_isolation'
  ) THEN
    CREATE POLICY tenant_isolation ON public.recetas
      FOR ALL
      USING (tenant_id = current_tenant_id())
      WITH CHECK (tenant_id = current_tenant_id());
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'receta_ingredientes'
      AND policyname = 'tenant_isolation'
  ) THEN
    CREATE POLICY tenant_isolation ON public.receta_ingredientes
      FOR ALL
      USING (tenant_id = current_tenant_id())
      WITH CHECK (tenant_id = current_tenant_id());
  END IF;
END $$;

-- ── 5. RPC de escritura atómica ──────────────────────────────────
CREATE OR REPLACE FUNCTION public.guardar_receta(
  p_receta jsonb,
  p_ingredientes jsonb
) RETURNS uuid
LANGUAGE plpgsql
SET search_path = public
AS $$
DECLARE
  v_tenant uuid := public.current_tenant_id();
  v_id_isar integer := NULLIF(p_receta->>'id_isar', '')::integer;
  v_id uuid;
  v_rinde numeric;
BEGIN
  IF v_id_isar IS NULL OR v_id_isar <= 0 THEN
    RAISE EXCEPTION 'guardar_receta: id_isar inválido (%).', p_receta->>'id_isar'
      USING ERRCODE = '22023';
  END IF;

  IF v_tenant IS NULL THEN
    RAISE EXCEPTION 'guardar_receta: el JWT no trae tenant_id.'
      USING ERRCODE = '42501';
  END IF;

  -- `rinde_porciones` es divisor en el descuento de stock. 0 o negativo
  -- cae a 1 en el cliente; aquí se normaliza igual para que la constraint
  -- CHECK no tumbe el push entero por un dato que el cliente ya tolera.
  v_rinde := COALESCE(NULLIF(p_receta->>'rinde_porciones', '')::numeric, 1);
  IF v_rinde <= 0 THEN
    v_rinde := 1;
  END IF;

  INSERT INTO public.recetas (
    id_isar, tenant_id, producto_id_fk, nombre_plato,
    rinde_porciones, activo, sincronizado, fecha_sincronizacion, updated_at
  ) VALUES (
    v_id_isar,
    v_tenant,
    NULLIF(p_receta->>'producto_id_fk', '')::bigint,
    COALESCE(p_receta->>'nombre_plato', ''),
    v_rinde,
    COALESCE((p_receta->>'activo')::boolean, true),
    true,
    now(),
    now()
  )
  ON CONFLICT (tenant_id, id_isar) DO UPDATE SET
    producto_id_fk = EXCLUDED.producto_id_fk,
    nombre_plato = EXCLUDED.nombre_plato,
    rinde_porciones = EXCLUDED.rinde_porciones,
    activo = EXCLUDED.activo,
    sincronizado = true,
    fecha_sincronizacion = now(),
    updated_at = now()
  RETURNING id INTO v_id;

  -- Reemplazo completo: la receta se edita como un todo. Borrar e insertar
  -- dentro de la misma transacción es lo que evita la receta sin
  -- ingredientes a medio camino.
  DELETE FROM public.receta_ingredientes WHERE receta_id = v_id;

  INSERT INTO public.receta_ingredientes (
    receta_id, tenant_id, orden, ingrediente_id_fk,
    ingrediente_nombre, cantidad, unidad, es_opcional
  )
  SELECT
    v_id,
    v_tenant,
    COALESCE((e.item->>'orden')::integer, 0),
    NULLIF(e.item->>'ingrediente_id_fk', '')::bigint,
    COALESCE(e.item->>'ingrediente_nombre', ''),
    COALESCE(NULLIF(e.item->>'cantidad', '')::numeric, 0),
    COALESCE(NULLIF(e.item->>'unidad', ''), 'unidad'),
    COALESCE((e.item->>'es_opcional')::boolean, false)
  FROM jsonb_array_elements(
    COALESCE(p_ingredientes, '[]'::jsonb)
  ) WITH ORDINALITY AS e(item, posicion)
  ORDER BY e.posicion;

  RETURN v_id;
END;
$$;

COMMENT ON FUNCTION public.guardar_receta(jsonb, jsonb) IS
  'Upsert de una receta + reemplazo completo de sus ingredientes, en una '
  'sola transacción. El tenant sale de current_tenant_id(), nunca del '
  'payload. Devuelve el uuid de la fila en recetas.';

GRANT EXECUTE ON FUNCTION public.guardar_receta(jsonb, jsonb)
  TO authenticated;

-- ── 6. Refrescar la caché de esquema de PostgREST ────────────────
-- Sin esto, `select('*, receta_ingredientes(*)')` puede responder
-- "Could not find a relationship" durante unos minutos tras crear las
-- tablas.
NOTIFY pgrst, 'reload schema';

-- ═══════════════════════════════════════════════════════════════
-- VERIFICACIÓN (correr a mano después de aplicar)
--
--   Resultado esperado de 1-3 (verificado el 2026-10-27 en el remoto):
--     recetas             → rowsecurity = true
--     receta_ingredientes → rowsecurity = true
--     policy `tenant_isolation` (cmd = ALL) en cada una
--     guardar_receta      → security_definer = false
--
--   -- 1. Las 2 tablas existen y tienen RLS
--   SELECT tablename, rowsecurity FROM pg_tables
--    WHERE schemaname = 'public'
--      AND tablename IN ('recetas', 'receta_ingredientes');
--
--   -- 2. Las policies (1 por tabla: una sola policy FOR ALL)
--   SELECT tablename, policyname, cmd FROM pg_policies
--    WHERE schemaname = 'public'
--      AND tablename IN ('recetas', 'receta_ingredientes');
--
--   -- 3. La RPC y sus permisos
--   SELECT p.proname, pg_get_function_identity_arguments(p.oid) AS args,
--          p.prosecdef AS security_definer
--     FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
--    WHERE n.nspname = 'public' AND p.proname = 'guardar_receta';
--   -- prosecdef debe ser FALSE (invoker).
--
--   -- 4. Prueba de la RPC. ⚠️ Dos trampas que ya hicieron fallar esta
--   --    consulta:
--   --
--   --    a) Los placeholders `<...>` NO son JSON válido: el editor
--   --       intenta castear el texto tal cual y responde
--   --         22P02: invalid input syntax for type json ... Token "<" is invalid
--   --       Por eso aquí los ids se resuelven con subselects dentro de
--   --       `jsonb_build_object`, en vez de escribirlos a mano.
--   --
--   --    b) El SQL Editor corre como `service_role` y NO trae JWT, así
--   --       que `current_tenant_id()` devuelve NULL y la RPC aborta con
--   --         42501: guardar_receta: el JWT no trae tenant_id.
--   --       Hay que simular el claim en la sesión con `SET LOCAL`.
--   --
--   --    El `BEGIN ... ROLLBACK` deja la base como estaba: no queda la
--   --    receta de prueba ni sus ingredientes.
--
--   BEGIN;
--   SET LOCAL request.jwt.claims =
--     '{"tenant_id":"<uuid-del-tenant>"}';
--
--   SELECT public.guardar_receta(
--     jsonb_build_object(
--       'id_isar', 999001,
--       'producto_id_fk', (
--         SELECT id_isar FROM public.productos
--          WHERE tenant_id = '<uuid-del-tenant>' AND activo
--          ORDER BY id_isar LIMIT 1
--       ),
--       'nombre_plato', 'Prueba',
--       'rinde_porciones', 1,
--       'activo', true
--     ),
--     jsonb_build_array(
--       jsonb_build_object(
--         'orden', 0,
--         'ingrediente_id_fk', (
--           SELECT id_isar FROM public.productos
--            WHERE tenant_id = '<uuid-del-tenant>'
--            ORDER BY id_isar DESC LIMIT 1
--         ),
--         'ingrediente_nombre', 'Queso',
--         'cantidad', 0.15,
--         'unidad', 'kg',
--         'es_opcional', false
--       )
--     )
--   );
--
--   -- Tiene que devolver 1 fila con la receta y 1 ingrediente:
--   SELECT r.id, r.nombre_plato, count(i.id) AS ingredientes
--     FROM public.recetas r
--     LEFT JOIN public.receta_ingredientes i ON i.receta_id = r.id
--    WHERE r.id_isar = 999001
--    GROUP BY r.id, r.nombre_plato;
--
--   ROLLBACK;
--
--   Errores típicos de esta prueba:
--     42501 → falta el `SET LOCAL request.jwt.claims`.
--     23503 → el `producto_id_fk` no existe en `productos.id_isar`
--             (la FK es contra esa columna, no contra el uuid).
--     23514 → `rinde_porciones <= 0`. La RPC ya normaliza a 1, así que
--             solo aparece si se toca la función.
-- ═══════════════════════════════════════════════════════════════
