-- ═══════════════════════════════════════════════════════════════
-- Ajustes a la tabla movimientos_lotes: default de tenant_id + RLS.
--
-- ⚠️ APLICADA AL REMOTO el 2026-10-10. Tracking alineado con:
--     supabase migration repair --status applied 20261010000002
--
-- ⚠️ OJO con ese `repair`: marca el historial pero NO ejecuta SQL. La
--    tabla ya existía (creada a mano) pero SIN RLS. El RLS se aplicó
--    aparte. Para futuros entornos hay que correr este archivo de verdad.
--
-- Idempotente: se puede correr varias veces sin fallar por
-- "policy already exists". El `DO $$` hace la comprobación explicita en
-- vez de un `DROP POLICY IF EXISTS`, que igual serviria pero deja el
-- `CREATE` en un segundo paso y es mas facil de interrumpir a mitad.
-- ═══════════════════════════════════════════════════════════════

-- 1. Default de tenant_id (patrón de lotes: current_tenant_id()).
ALTER TABLE public.movimientos_lotes
  ALTER COLUMN tenant_id SET DEFAULT current_tenant_id();

-- 2. RLS + policy de aislamiento por tenant.
--
--    Sin esto, el sync descargaría los movimientos de TODOS los tenants
--    al mismo dispositivo. Ya pasó con los lotes antes del filtro
--    explícito de tenant en el cliente (ver `descargarLotesDesdeSupabase`).
ALTER TABLE public.movimientos_lotes ENABLE ROW LEVEL SECURITY;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename = 'movimientos_lotes'
      AND policyname = 'tenant_isolation'
  ) THEN
    CREATE POLICY tenant_isolation ON public.movimientos_lotes
      FOR ALL
      USING (tenant_id = current_tenant_id())
      WITH CHECK (tenant_id = current_tenant_id());
  END IF;
END $$;