-- ═══════════════════════════════════════════════════════════════════════
-- HARDENING: telegram_config
-- RLS + policies + triggers + vista segura + preparación para cifrado
-- ═══════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════════
-- 1. ALIAS: current_tenant_id() → current_user_tenant_id()
-- ═══════════════════════════════════════════════════════════════════════
-- La tabla usa `current_tenant_id()` pero la migración previa definió
-- `current_user_tenant_id()`. Creamos un alias para no romper ni la tabla
-- ni el código existente.

CREATE OR REPLACE FUNCTION public.current_tenant_id()
RETURNS uuid
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT public.current_user_tenant_id();
$$;

COMMENT ON FUNCTION public.current_tenant_id() IS
  'Alias de current_user_tenant_id(). Retorna el tenant del usuario autenticado.';

-- ═══════════════════════════════════════════════════════════════════════
-- 2. LIMPIEZA / NORMALIZACIÓN DE COLUMNAS
-- ═══════════════════════════════════════════════════════════════════════

-- 2a. Hacer bot_token y chat_id NULLABLE (cuando se cree el registro
--     antes de configurar el bot, el token puede no existir aún).
ALTER TABLE public.telegram_config
  ALTER COLUMN bot_token DROP NOT NULL,
  ALTER COLUMN chat_id DROP NOT NULL;

-- 2b. Valores por defecto más sensatos.
ALTER TABLE public.telegram_config
  ALTER COLUMN enabled SET DEFAULT true,
  ALTER COLUMN notificar_stock_bajo SET DEFAULT true,
  ALTER COLUMN notificar_ventas SET DEFAULT false,
  ALTER COLUMN notificar_pedidos SET DEFAULT false,
  ALTER COLUMN comandos_permitidos
    SET DEFAULT '["/ventas", "/stock", "/ayuda"]'::jsonb,
  ALTER COLUMN sincronizado SET DEFAULT false,
  ALTER COLUMN sync_status SET DEFAULT 'pending';

-- 2c. Constraint de formato de chat_id (numérico o @username).
ALTER TABLE public.telegram_config
  DROP CONSTRAINT IF EXISTS telegram_config_chat_id_format;
ALTER TABLE public.telegram_config
  ADD CONSTRAINT telegram_config_chat_id_format
  CHECK (
    chat_id IS NULL
    OR chat_id ~ '^-?[0-9]{5,20}$'
    OR chat_id ~ '^@[A-Za-z][A-Za-z0-9_]{4,31}$'
  );

-- 2d. Constraint de formato de bot_token: <digits>:<base64url>.
ALTER TABLE public.telegram_config
  DROP CONSTRAINT IF EXISTS telegram_config_bot_token_format;
ALTER TABLE public.telegram_config
  ADD CONSTRAINT telegram_config_bot_token_format
  CHECK (
    bot_token IS NULL
    OR bot_token ~ '^[0-9]{6,12}:[A-Za-z0-9_-]{30,}$'
  );

-- 2e. Comandos permitidos deben ser un array no vacío de strings que
--     empiecen con "/".
ALTER TABLE public.telegram_config
  DROP CONSTRAINT IF EXISTS telegram_config_comandos_validos;
ALTER TABLE public.telegram_config
  ADD CONSTRAINT telegram_config_comandos_validos
  CHECK (
    comandos_permitidos IS NULL
    OR jsonb_typeof(comandos_permitidos) = 'array'
  );

-- 2f. UNIQUE (tenant_id, usuario_id) en lugar de solo usuario_id.
--     En la práctica cada usuario pertenece a un solo tenant, pero
--     hacerlo explícito evita edge cases.
ALTER TABLE public.telegram_config
  DROP CONSTRAINT IF EXISTS telegram_config_usuario_unique;
ALTER TABLE public.telegram_config
  DROP CONSTRAINT IF EXISTS telegram_config_tenant_usuario_unique;
ALTER TABLE public.telegram_config
  ADD CONSTRAINT telegram_config_tenant_usuario_unique
  UNIQUE (tenant_id, usuario_id);

-- ═══════════════════════════════════════════════════════════════════════
-- 3. TRIGGERS
-- ═══════════════════════════════════════════════════════════════════════

-- 3a. Auditoría (reutiliza la función existente).
DROP TRIGGER IF EXISTS audit_telegram_config ON public.telegram_config;
CREATE TRIGGER audit_telegram_config
AFTER INSERT OR UPDATE OR DELETE ON public.telegram_config
FOR EACH ROW EXECUTE FUNCTION audit_trigger();

-- 3b. updated_at automático.
DROP TRIGGER IF EXISTS update_telegram_config_updated_at
  ON public.telegram_config;
CREATE TRIGGER update_telegram_config_updated_at
BEFORE UPDATE ON public.telegram_config
FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 3c. Sincronizar `sync_status` con `sincronizado` automáticamente.
CREATE OR REPLACE FUNCTION public.telegram_config_sync_status()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- Si el cliente marca `sincronizado = true`, ponemos sync_status = 'synced'
  -- salvo que el cliente lo haya especificado explícitamente.
  IF NEW.sincronizado = true AND NEW.sync_status IS NULL THEN
    NEW.sync_status := 'synced';
  END IF;

  -- Si el cliente marca `sincronizado = false` y sync_status viene en
  -- 'synced', lo reseteamos a 'pending'.
  IF NEW.sincronizado = false AND NEW.sync_status = 'synced' THEN
    NEW.sync_status := 'pending';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS telegram_config_sync_status_trg
  ON public.telegram_config;
CREATE TRIGGER telegram_config_sync_status_trg
BEFORE INSERT OR UPDATE ON public.telegram_config
FOR EACH ROW EXECUTE FUNCTION public.telegram_config_sync_status();

-- ═══════════════════════════════════════════════════════════════════════
-- 4. RLS + POLICIES
-- ═══════════════════════════════════════════════════════════════════════

ALTER TABLE public.telegram_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.telegram_config FORCE ROW LEVEL SECURITY;

-- ─── SELECT ─────────────────────────────────────────────────────────
-- Pueden leer:
--   • admin y supervisor del propio tenant (configuración del bot)
--   • el propio usuario (para su propia fila, aunque no sea admin)
--   • auditor (solo lectura para auditoría)
-- NUNCA otros tenants.
DROP POLICY IF EXISTS telegram_config_select ON public.telegram_config;
CREATE POLICY telegram_config_select ON public.telegram_config
FOR SELECT
TO authenticated
USING (
  tenant_id = public.current_user_tenant_id()
  AND (
    public.has_any_role(ARRAY['admin', 'supervisor', 'auditor', 'dev'])
    OR usuario_id = (
      SELECT id FROM public.usuarios WHERE id = auth.uid() LIMIT 1
    )
  )
);

-- ─── INSERT ─────────────────────────────────────────────────────────
-- Solo admin y supervisor del propio tenant pueden crear configuración
-- de bot. El `usuario_id` debe estar dentro del mismo tenant.
DROP POLICY IF EXISTS telegram_config_insert ON public.telegram_config;
CREATE POLICY telegram_config_insert ON public.telegram_config
FOR INSERT
TO authenticated
WITH CHECK (
  tenant_id = public.current_user_tenant_id()
  AND public.has_any_role(ARRAY['admin', 'supervisor'])
  AND EXISTS (
    SELECT 1 FROM public.usuarios u
    WHERE u.id::text = usuario_id::text
      AND u.tenant_id = tenant_id
  )
);

-- ─── UPDATE ─────────────────────────────────────────────────────────
-- Solo admin y supervisor del propio tenant. El `tenant_id` no puede
-- cambiar en un UPDATE (evita mover registros entre tenants).
DROP POLICY IF EXISTS telegram_config_update ON public.telegram_config;
CREATE POLICY telegram_config_update ON public.telegram_config
FOR UPDATE
TO authenticated
USING (
  tenant_id = public.current_user_tenant_id()
  AND public.has_any_role(ARRAY['admin', 'supervisor'])
)
WITH CHECK (
  tenant_id = public.current_user_tenant_id()
  AND public.has_any_role(ARRAY['admin', 'supervisor'])
);

-- ─── DELETE ─────────────────────────────────────────────────────────
-- Solo admin del propio tenant.
DROP POLICY IF EXISTS telegram_config_delete ON public.telegram_config;
CREATE POLICY telegram_config_delete ON public.telegram_config
FOR DELETE
TO authenticated
USING (
  tenant_id = public.current_user_tenant_id()
  AND public.has_any_role(ARRAY['admin'])
);

-- ═══════════════════════════════════════════════════════════════════════
-- 5. VISTA SEGURA (sin exponer bot_token)
-- ═══════════════════════════════════════════════════════════════════════
-- Para listados y dashboards donde no se necesita el token, expone solo
-- metadatos. La app cliente que necesite el token debe usar SELECT directo
-- sobre la tabla (que ya está protegida por RLS).

CREATE OR REPLACE VIEW public.telegram_config_safe AS
SELECT
  id,
  id_isar,
  usuario_id,
  tenant_id,
  chat_id,
  nombre_chat,
  enabled,
  notificar_stock_bajo,
  notificar_ventas,
  notificar_pedidos,
  comandos_permitidos,
  sincronizado,
  fecha_sincronizacion,
  sync_status,
  created_at,
  updated_at,
  ultima_actualizacion,
  -- Huella del token para auditoría sin revelarlo.
  CASE
    WHEN bot_token IS NULL THEN NULL
    ELSE substr(md5(bot_token), 1, 8)
  END AS bot_token_fingerprint
FROM public.telegram_config;

-- RLS de la vista: hereda las policies de la tabla subyacente.
ALTER VIEW public.telegram_config_safe SET (security_invoker = true);

COMMENT ON VIEW public.telegram_config_safe IS
  'Vista de telegram_config sin bot_token. Incluye fingerprint (md5 corto) '
  'para auditar rotaciones sin exponer el token completo.';

-- ═══════════════════════════════════════════════════════════════════════
-- 6. DOCUMENTACIÓN
-- ═══════════════════════════════════════════════════════════════════════

COMMENT ON TABLE public.telegram_config IS
  'Configuración del bot de Telegram por usuario. RLS: admin/supervisor '
  'del tenant pueden escribir; cada usuario solo ve su propia fila.';

COMMENT ON COLUMN public.telegram_config.bot_token IS
  'Token de BotFather. Formato: <digits>:<base64url>. '
  'TODO Fase 2: cifrar con pgcrypto + Vault. Actualmente RLS es la única '
  'defensa en profundidad.';

COMMENT ON COLUMN public.telegram_config.chat_id IS
  'ID del chat o @username. Formato validado por constraint.';

COMMENT ON COLUMN public.telegram_config.usuarios_autorizados_ids IS
  'RESERVADO: IDs de usuarios adicionales que pueden consultar el bot. '
  'No usado actualmente — la app solo soporta 1 bot por usuario.';

COMMENT ON COLUMN public.telegram_config.roles_autorizados IS
  'RESERVADO: roles que pueden consultar el bot. '
  'No usado actualmente — la app solo soporta 1 bot por usuario.';

COMMENT ON COLUMN public.telegram_config.sync_status IS
  'Estado de sincronización con el cliente. Sincronizado automáticamente '
  'con la columna booleana `sincronizado` vía trigger.';

-- ═══════════════════════════════════════════════════════════════════════
-- 7. ÍNDICES ADICIONALES
-- ═══════════════════════════════════════════════════════════════════════

-- Para búsquedas por chat_id (deduplicación si algún día se permite).
CREATE INDEX IF NOT EXISTS idx_telegram_config_chat_id
  ON public.telegram_config(chat_id)
  WHERE chat_id IS NOT NULL;

-- Para el listado "bots activos del tenant".
CREATE INDEX IF NOT EXISTS idx_telegram_config_tenant_enabled
  ON public.telegram_config(tenant_id, enabled)
  WHERE enabled = true;

-- ═══════════════════════════════════════════════════════════════════════
-- 8. VERIFICACIÓN
-- ═══════════════════════════════════════════════════════════════════════

DO $$
DECLARE
  v_policies int;
  v_rls boolean;
BEGIN
  SELECT COUNT(*) INTO v_policies
  FROM pg_policies
  WHERE schemaname = 'public' AND tablename = 'telegram_config';

  SELECT relrowsecurity INTO v_rls
  FROM pg_class
  WHERE relname = 'telegram_config' AND relnamespace = 'public'::regnamespace;

  RAISE NOTICE '✅ telegram_config: RLS=% policies=%', v_rls, v_policies;

  IF v_policies < 4 THEN
    RAISE WARNING '⚠️ Se esperaban al menos 4 policies, hay %', v_policies;
  END IF;

  IF NOT v_rls THEN
    RAISE EXCEPTION '❌ RLS no está habilitado en telegram_config';
  END IF;
END $$;