-- 20261018000001_legal_acceptance.sql
--
-- Registro de aceptacion de Terminos y Privacidad.
--
-- POR QUE EXISTE
-- La app guarda la aceptacion en SharedPreferences (offline-first, el alta
-- no puede depender de la nube). Eso demuestra que el texto se mostro en
-- ESE dispositivo, pero no que sea el que JAHTLABS publico ese dia: la
-- marca de tiempo la controla el cliente y un usuario con acceso al
-- almacenamiento puede alterarla.
--
-- Esta tabla es la contraparte con valor probatorio: el INSERT lo hace el
-- servidor, con su propia marca de tiempo, y el registro queda ligado al
-- usuario autenticado por el JWT. Un usuario no puede firmar aceptaciones
-- de otro ni inventarse la fecha.
--
-- APLICAR: es una migracion del owner. Correr el SQL en el editor de
-- Supabase o con `supabase db push`, y SOLO despues:
--
--   supabase migration repair --status applied 20261018000001
--
-- (ver AGENTS.md: `migration repair` NO ejecuta el SQL).
--
-- ESTADO: aplicada en produccion el 2026-10-20 por el owner.
-- Verificada desde el cliente anonimo:
--   GET  /rest/v1/legal_acceptance          -> 200 (la tabla existe)
--   POST /rest/v1/rpc/registrar_legal_acceptance -> 401 (existe y esta
--        protegida; una funcion inexistente devuelve 404 PGRST202)

-- ─────────────────────────────────────────────────────────────
-- Tabla
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.legal_acceptance (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Vinculada al usuario autenticado. On delete cascade: si se borra la
  -- cuenta, se borra su aceptacion. Los datos personales no se
  -- retienen de mas de lo necesario.
  usuario_id    uuid        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  tenant_id     uuid,

  -- 'terminos' | 'privacidad' | 'ambos'
  documento     text        NOT NULL CHECK (documento IN
                            ('terminos', 'privacidad', 'ambos')),

  -- Version del texto que se mostro. Cambia el texto, cambia el valor.
  version       text        NOT NULL,

  -- Marca de tiempo del SERVIDOR, no del cliente. Esta es la que vale.
  aceptado_en   timestamptz NOT NULL DEFAULT now(),

  -- IP y agente: evidencia de contexto. Opcionales porque en un dispositivo
  -- compartido no siempre hay IP util detrás de una NAT.
  ip            inet,
  user_agent    text,

  -- Texto exacto que se aceptó. Es lo que realmente cierra el caso: si el
  -- documento cambia, la version no alcanza y este campo desempata.
  texto_hash    text        NOT NULL,

  CONSTRAINT legal_acceptance_unico
    UNIQUE (usuario_id, documento, version)
);

COMMENT ON TABLE public.legal_acceptance IS
  'Aceptacion de terminos y politica de privacidad. Evidencia con marca de '
  'tiempo del servidor. La LOPDP exige informar al titular sobre el '
  'tratamiento; este registro es la constancia de que se le introdujo.';

-- ─────────────────────────────────────────────────────────────
-- Indice
-- ─────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_legal_acceptance_usuario
  ON public.legal_acceptance (usuario_id, documento, aceptado_en DESC);

CREATE INDEX IF NOT EXISTS idx_legal_acceptance_tenant
  ON public.legal_acceptance (tenant_id, aceptado_en DESC)
  WHERE tenant_id IS NOT NULL;

-- ─────────────────────────────────────────────────────────────
-- RLS
-- ─────────────────────────────────────────────────────────────
ALTER TABLE public.legal_acceptance ENABLE ROW LEVEL SECURITY;

-- El usuario solo LEE sus propias aceptaciones.
--
-- NO hay policy de INSERT para el cliente. La escritura tiene que pasar por
-- una RPC SECURITY DEFINER con validacion explicita (ver AGENTS.md seccion 7.3
-- "Nunca anadas policies RLS permisivas"). Si se dejara un INSERT abierto,
-- un usuario podria firmar la aceptacion de otro usuario soloRAFT con un
-- UPDATE, que es justo lo que la RLS debe impedir.
CREATE POLICY legal_acceptance_select_propio
  ON public.legal_acceptance
  FOR SELECT
  TO authenticated
  USING (usuario_id = (auth.uid()));

-- ─────────────────────────────────────────────────────────────
-- RPC de escritura
-- ─────────────────────────────────────────────────────────────
-- El cliente nunca escribe directo: llama a esta funcion. El servidor pone
-- `usuario_id` desde el JWT, no desde lo que mande el cliente, y pone
-- `aceptado_en` con `now()`.
CREATE OR REPLACE FUNCTION public.registrar_legal_acceptance(
  p_documento   text,
  p_version     text,
  p_texto_hash  text,
  p_user_agent  text DEFAULT NULL
)
RETURNS public.legal_acceptance
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_uid        uuid := auth.uid();
  v_tenant     uuid;
  v_ip         inet;
  v_aceptado   public.legal_acceptance;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Se requiere sesion autenticada'
      USING ERRCODE = '42501';
  END IF;

  IF p_documento NOT IN ('terminos', 'privacidad', 'ambos') THEN
    RAISE EXCEPTION 'Documento desconocido: %', p_documento
      USING ERRCODE = '22023';
  END IF;

  IF p_version IS NULL OR length(btrim(p_version)) = 0 THEN
    RAISE EXCEPTION 'La version del documento es obligatoria'
      USING ERRCODE = '22023';
  END IF;

  IF p_texto_hash IS NULL OR length(btrim(p_texto_hash)) = 0 THEN
    RAISE EXCEPTION 'El hash del texto es obligatorio'
      USING ERRCODE = '22023';
  END IF;

  -- tenant_id sale del JWT, no de un parametro del cliente.
  SELECT current_tenant_id() INTO v_tenant;

  -- IP de la conexion, si el entorno la expone en el header.
  BEGIN
    v_ip := NULLIF(
      current_setting('request.headers', true)::jsonb ->> 'x-forwarded-for',
      ''
    )::inet;
  EXCEPTION WHEN OTHERS THEN
    v_ip := NULL;   -- sin IP disponible: no es motivo para fallar
  END;

  INSERT INTO public.legal_acceptance
    (usuario_id, tenant_id, documento, version, texto_hash,
     ip, user_agent)
  VALUES
    (v_uid, v_tenant, p_documento, btrim(p_version), btrim(p_texto_hash),
     v_ip, left(coalesce(p_user_agent, ''), 512))
  ON CONFLICT (usuario_id, documento, version)
  DO UPDATE SET aceptado_en = now()
  RETURNING * INTO v_aceptado;

  RETURN v_aceptado;
END;
$$;

REVOKE ALL ON FUNCTION public.registrar_legal_acceptance(text, text, text, text)
  FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.registrar_legal_acceptance(text, text, text, text)
  TO authenticated;

-- ─────────────────────────────────────────────────────────────
-- Consulta de soporte
-- ─────────────────────────────────────────────────────────────
-- El super admin NO tiene policy sobre esta tabla a proposito. AGENTS.md
-- seccion 7.1: el super admin no accede a datos del tenant. La evidencia de
-- aceptacion se consulta por el propio usuario con la policy de SELECT, o
-- por el owner desde el dashboard con service_role, que bypasea RLS.
--
-- Verificacion tras aplicar:
--
--   SELECT documento, version, aceptado_en
--     FROM public.legal_acceptance
--    WHERE usuario_id = auth.uid()
--    ORDER BY aceptado_en DESC;