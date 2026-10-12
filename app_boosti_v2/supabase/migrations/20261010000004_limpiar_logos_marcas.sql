-- ═══════════════════════════════════════════════════════════════
-- Limpia los logos de marca corruptos.
--
-- ⚠️ Los logos guardados hasta el 2026-10-10 son URLs FIRMADAS
--    (`createSignedUrl(path, 3600)`) que se guardaban como si fueran
--    permanentes. Caducan 1 hora despues de generarse, asi que a dia de
--    hoy TODOS estan expirados: el objeto sigue existiendo en el bucket,
--    pero la unica referencia guardada ya no resuelve.
--
-- Se limpian para que la UI no muestre imagenes rotas ni una URL
-- caducada que React/Flutter intente descargar en cada render.
--
-- El negocio tiene que volver a subir sus logos desde el formulario de
-- marca. Es el costo de haber guardado una URL firmada.
--
-- Idempotente: correrla dos veces no hace nada la segunda vez.
-- ═══════════════════════════════════════════════════════════════

UPDATE public.marcas
   SET logo_url = NULL
 WHERE logo_url LIKE 'http%';

-- ───────────────────────────────────────────────────────────────
-- VERIFICACIÓN
--
--   -- Debe devolver 0
--   select count(*) from public.marcas where logo_url like 'http%';
--
--   -- Los objetos siguen en el bucket, para poder recuperarlos:
--   supabase storage list --bucket marcas --recursive
--
--   -- Cuántos logos se perdieron:
--   select count(*) from public.marcas where logo_url is not null;
-- ───────────────────────────────────────────────────────────────