-- ═══════════════════════════════════════════════════════════════
-- Agrega logo_path a locales.
--
-- La columna guarda el PATH del objeto en el bucket `locales` de Supabase
-- Storage, NO una URL. Mismo principio que `MarcaEntity.logoPath`: guardar
-- una signed URL es un bug, porque caduca a la hora y el objeto queda
-- huerfano.
--
-- La columna se llama `logo_path` (a diferencia de marcas, donde la
-- heredada `logo_url` guarda un path por historico).
--
-- ⚠️ El BUCKET `locales` en Supabase Storage NO se crea con SQL: Storage
--    se administra aparte. Hay que crearlo desde el dashboard:
--      Supabase Dashboard > Storage > New bucket > nombre: locales
--    y configurar las policies de acceso por tenant a mano.
--
-- Idempotente: `IF NOT EXISTS` permite correrla mas de una vez.
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE public.locales
  ADD COLUMN IF NOT EXISTS logo_path text;

-- ───────────────────────────────────────────────────────────────
-- PENDIENTE HASTA QUE EXISTA EL BUCKET
--
-- Mientras el bucket `locales` no exista, el upload falla. La columna no
-- molesta: es nullable y el sync manda null.
--
-- Cuando se cree el bucket, hay que agregar la policy de lectura por
-- tenant, siguiendo el patrón de marcas. Sin RLS en el bucket, cualquier
-- sesión autenticada podría leer los logos de todos los tenants.
--
-- VERIFICACIÓN:
--   select column_name, data_type
--     from information_schema.columns
--    where table_name = 'locales' and column_name = 'logo_path';
-- ───────────────────────────────────────────────────────────────