-- ═══════════════════════════════════════════════════════════════
-- Crea cashier_logs, que lock_provider.dart consultaba sin que existiera.
--
-- El catch era mudo (`catch (e) { // Error silencioso }`, sin
-- debugPrint ni ErrorService), así que los eventos de descanso de caja
-- nunca se registraron y nadie lo supo. Si la tabla no existe, el insert
-- falla, el catch se come el error y la app sigue como si nada.
--
-- Columnas tomadas del insert real:
--   lock_provider.dart:21-34 → user_id, event_type, reason, timestamp
--   lock_provider.dart:50-62 → user_id, event_type, timestamp (sin reason)
--
-- `reason` es nullable porque el evento `rest_end` no lo manda.
-- Idempotente: se puede correr más de una vez sin fallar.
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.cashier_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL,
  event_type text NOT NULL,
  reason text,
  timestamp timestamp with time zone NOT NULL,
  -- Default de tenant: mismo patrón que lotes y marcas. El cliente no
  -- manda tenant_id, lo pone el server. Enviarlo desde el móvil
  -- escribiría en el tenant equivocado si hay hot-switch a mitad del
  -- insert.
  tenant_id uuid NOT NULL DEFAULT current_tenant_id(),
  created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Índice para leer el historial de un usuario concreto, del más reciente
-- al más antiguo.
CREATE INDEX IF NOT EXISTS cashier_logs_tenant_user_idx
  ON public.cashier_logs (tenant_id, user_id, timestamp DESC);

ALTER TABLE public.cashier_logs ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'cashier_logs'
      AND policyname = 'tenant_isolation'
  ) THEN
    CREATE POLICY tenant_isolation ON public.cashier_logs
      FOR ALL
      USING (tenant_id = current_tenant_id())
      WITH CHECK (tenant_id = current_tenant_id());
  END IF;
END $$;

-- ───────────────────────────────────────────────────────────────
-- VERIFICACIÓN
--
--   \d public.cashier_logs
--   select count(*) from public.cashier_logs;   -- debe dar 0 al inicio
--
-- Después de aplicar, disparar un lock manual desde la app y volver a
-- contar: debería dar 1. Si sigue en 0, el insert sigue fallando.
-- ───────────────────────────────────────────────────────────────