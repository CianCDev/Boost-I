-- ═══════════════════════════════════════════════════════════════
-- Agrega `p_logo_path` a `crear_nuevo_local_para_usuario`.
--
-- MOTIVACIÓN
--
-- El flujo de creación de local deja subir un logo, pero no hay forma de
-- persistirlo: el `_LogoField` solo se mostraba en edición.
--
-- El intento obvious — hacer `UPDATE locales SET logo_path` desde el
-- cliente después del RPC — NO funciona:
--
--   CREATE POLICY locales_tenant_update ON public.locales FOR UPDATE
--     USING ((id = public.current_tenant_id()))
--
-- El UPDATE solo permite el tenant ACTIVO, y el local recién creado
-- todavía no lo es: el JWT sigue apuntando al local anterior. El RPC sí
-- funciona porque es SECURITY DEFINER y no pasa por RLS.
--
-- Por eso el logo se mueve DENTRO del RPC: es el único punto donde la
-- escritura es atómica y está permitida.
--
-- ───────────────────────────────────────────────────────────────
-- ⚠️ POR QUÉ HAY UN `DROP FUNCTION` ANTES DEL `CREATE OR REPLACE`
--
-- Se cambia la firma de 5 a 6 parámetros. En PostgreSQL, cambiar la
-- lista de argumentos NO hace replace: crea una SOBRECARGA nueva y deja
-- la función vieja viva. Quedarían dos funciones:
--
--   (... text, text, text, text, text)        ← vieja, sin logo
--   (... text, text, text, text, text, text)  ← nueva
--
-- PostgREST resuelve el RPC por NOMBRE de parámetro, y ambos tienen
-- `p_nombre`, `p_rif`, etc. → la llamada queda AMBIGUA y devuelve
-- "function ... is not unique". El RPC quedaría roto para todo el
-- cliente, no solo para la creación de local.
--
-- El DROP va primero y con la firma exacta de 5 parámetros.
-- ───────────────────────────────────────────────────────────────

-- ───────────────────────────────────────────────────────────────
-- ORDEN DE DEPENDENCIA
--
-- `logo_path` lo agrega 20261010000005_locales_logo.sql. Se repite el
-- `ADD COLUMN IF NOT EXISTS` para que esta migración sea autocontenida
-- y no rompa si 000005 todavía no se aplicó. Es idempotente.
-- ───────────────────────────────────────────────────────────────
ALTER TABLE public.locales
  ADD COLUMN IF NOT EXISTS logo_path text;

-- ───────────────────────────────────────────────────────────────
-- LIMPIAR LA SOBRECARGA VIEJA
-- ───────────────────────────────────────────────────────────────
DROP FUNCTION IF EXISTS public.crear_nuevo_local_para_usuario(
  text, text, text, text, text
);

-- ───────────────────────────────────────────────────────────────
-- FUNCIÓN CON LOGO
--
-- Todo lo demás se conserva IDÉNTICO a la versión anterior:
--
--   • `SET search_path TO ''`  — imprescindible en SECURITY DEFINER.
--     Sin esto la función corre con el `search_path` del caller, que es
--     el vector clásico de escalada de privilegios: alguien crea un
--     schema con un `trim()` malicioso y lo ejecuta dentro de la
--     función con permisos de DEFINER.
--   • `v_usuario_id` + validación de sesión, y la validación de
--     `p_nombre`. Sin esto cualquiera podría llamar la RPC.
--   • `trim()` + `NULLIF(trim(x), '')` en cada parámetro de texto: un
--     campo opcional vacío tiene que quedar NULL, no ''.
--   • `id = gen_random_uuid()` explícito.
--   • `rol = 'admin'` en `usuarios_locales` — **lo más importante de
--     esta lista**. La columna tiene `DEFAULT 'cajero'`, así que omitir
--     el valor NO da error: crea el local y deja al creador con rol
--     cajero, es decir, sin permisos sobre el local que acaba de crear.
--     Falla en silencio y se descubre cuando el usuario no puede editar
--     nada.
-- ───────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.crear_nuevo_local_para_usuario(
  p_nombre text,
  p_direccion text DEFAULT NULL::text,
  p_telefono text DEFAULT NULL::text,
  p_email text DEFAULT NULL::text,
  p_rif text DEFAULT NULL::text,
  p_logo_path text DEFAULT NULL::text
) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE
  v_nuevo_tenant_id uuid;
  v_usuario_id uuid := auth.uid();
BEGIN
  IF v_usuario_id IS NULL THEN
    RAISE EXCEPTION 'No hay usuario autenticado.';
  END IF;

  IF p_nombre IS NULL OR length(trim(p_nombre)) = 0 THEN
    RAISE EXCEPTION 'El nombre del local es obligatorio.';
  END IF;

  INSERT INTO public.locales (id, nombre, direccion, telefono, email, rif, logo_path)
  VALUES (
    gen_random_uuid(),
    trim(p_nombre),
    NULLIF(trim(p_direccion), ''),
    NULLIF(trim(p_telefono), ''),
    NULLIF(trim(p_email), ''),
    NULLIF(trim(p_rif), ''),
    NULLIF(trim(p_logo_path), '')
  )
  RETURNING id INTO v_nuevo_tenant_id;

  INSERT INTO public.usuarios_locales (usuario_id, tenant_id, rol, es_default, activo)
  VALUES (v_usuario_id, v_nuevo_tenant_id, 'admin', false, true);

  RETURN v_nuevo_tenant_id;
END;
$$;

-- ═══════════════════════════════════════════════════════════════
-- VERIFICACIÓN (correr después de aplicar)
--
-- 1) Solo debe existir UNA sobrecarga:
--    SELECT p.proname, pg_get_function_identity_arguments(p.oid)
--      FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
--     WHERE n.nspname = 'public' AND p.proname = 'crear_nuevo_local_para_usuario';
--    → 1 fila, con 6 argumentos. Si salen 2, el DROP no corrió.
--
-- 2) La columna existe:
--    SELECT column_name, data_type FROM information_schema.columns
--     WHERE table_name = 'locales' AND column_name = 'logo_path';
--
-- 3) Prueba funcional (desde la app, no desde SQL): crear un local con
--    logo y confirmar
--      SELECT nombre, logo_path FROM public.locales ORDER BY created_at DESC LIMIT 1;
--    con logo_path poblado, y que el usuario quede como admin:
--      SELECT rol FROM public.usuarios_locales
--       WHERE tenant_id = (SELECT id FROM public.locales
--                           ORDER BY created_at DESC LIMIT 1);
--    → 'admin'
-- ═══════════════════════════════════════════════════════════════
