-- ═══════════════════════════════════════════════════════════════════
-- productos.departamento_id
--
-- FK al departamento (estación) donde se prepara el producto. `null`
-- significa "no requiere preparación" (retail / productos servidos
-- directo sin pasar por el KDS).
--
-- ON DELETE SET NULL: si se borra físicamente un departamento, los
-- productos quedan sin estación, no desaparecen. La app usa soft-delete
-- (`departamentos.activo = false`), así que este brazo casi nunca dispara.
--
-- RLS: la tabla `productos` ya tiene su `tenant_isolation`. La FK NO
-- agrega brazo cross-tenant: el cliente solo puede setear el UUID de un
-- departamento que ya ve por RLS.
-- ═══════════════════════════════════════════════════════════════════

ALTER TABLE public.productos
  ADD COLUMN IF NOT EXISTS departamento_id uuid
  REFERENCES public.departamentos(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_productos_departamento
  ON public.productos (departamento_id);

-- Verificación:
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'productos'
--   AND column_name = 'departamento_id';
-- Debe devolver 1 fila: uuid | YES