-- ═══════════════════════════════════════════════════════════════
-- Policies de Storage para los buckets de la app.
--
-- ⚠️ Crear el bucket en el dashboard NO alcanza. `storage.objects` tiene
--    RLS activo por defecto y sin policies TODAS las operaciones fallan
--    (upload, download, signed URL). El error se ve como "row-level
--    security violation", que en el cliente se traduce en un catch
--    silencioso.
--
-- ⚠️ ESTADO: Aplicada al remoto el 2026-10-10 (confirmado por el usuario).
--    Tracking alineado con:
--      supabase migration repair --status applied 20261010000006
--
-- ⚠️ OJO con el repair: `supabase migration repair` SOLO actualiza
--    `supabase_migrations.schema_migrations`. NO ejecuta el SQL de este
--    archivo. Si se corrió el repair sin haber corrido antes el SQL, el
--    historial miente: dice "aplicada" mientras las policies no existen.
--    Orden correcto: (1) correr el SQL, (2) verificar con la query de
--    abajo, (3) recién ahí el repair. Ver la regla en `AGENTS.MD`.
--
-- Idempotente: los DROP POLICY IF EXISTS permiten re-correr sin fallar.
-- El ON CONFLICT DO NOTHING de los buckets tampoco pisa lo existente.
--
-- PATRÓN DE AISLAMIENTO
-- El path de cada objeto empieza con el tenant_id:
--     {tenant_id}/archivo.png
-- El aislamiento se hace sobre el primer segmento del path, no sobre una
-- columna: los buckets no tienen tabla asociada.
--
--     (storage.foldername(name))[1]
--
-- `storage.foldername` devuelve un text[] con las carpetas del objeto.
--
-- ⚠️ DÓNDE ESTÁ EL RIESGO REAL: `current_tenant_id()` es una función que
--    las policies de `public.*` ya usan. Si esa función devuelve NULL
--    (sin sesión), la comparación da NULL y `USING` niega el acceso. Es
--    el comportamiento deseado.
-- ═══════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────
-- 1. Buckets (idempotente; no borra ni toca los existentes)
-- ───────────────────────────────────────────────────────────────

INSERT INTO storage.buckets (id, name, public)
VALUES
  ('marcas',  'marcas',  false),
  ('locales', 'locales', false)
ON CONFLICT (id) DO NOTHING;

-- ⚠️ `public = false`: los buckets son PRIVADOS. Las imágenes se leen
-- con `createSignedUrl`, no con `getPublicUrl`.
--
-- Si algún bucket ya existe con `public = true`, esta línea no lo
-- corrige (el ON CONFLICT DO NOTHING no actualiza). Hay que revisarlo a
-- mano:
--
--   UPDATE storage.buckets SET public = false WHERE id IN ('marcas','locales');

-- ───────────────────────────────────────────────────────────────
-- 2. Policies: 4 por bucket (SELECT, INSERT, UPDATE, DELETE)
-- ───────────────────────────────────────────────────────────────

-- SELECT: leer los logos del propio tenant
DO $$
DECLARE
  b text;
BEGIN
  FOREACH b IN ARRAY ARRAY['marcas', 'locales'] LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b || '_select_tenant');
    EXECUTE format($f$
      CREATE POLICY %I ON storage.objects
        FOR SELECT
        USING (
          bucket_id = %L
          AND (storage.foldername(name))[1] = current_tenant_id()::text
        )
    $, b || '_select_tenant', b);

    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b || '_insert_tenant');
    EXECUTE format($f$
      CREATE POLICY %I ON storage.objects
        FOR INSERT
        WITH CHECK (
          bucket_id = %L
          AND (storage.foldername(name))[1] = current_tenant_id()::text
        )
    $, b || '_insert_tenant', b);

    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b || '_update_tenant');
    EXECUTE format($f$
      CREATE POLICY %I ON storage.objects
        FOR UPDATE
        USING (
          bucket_id = %L
          AND (storage.foldername(name))[1] = current_tenant_id()::text
        )
        WITH CHECK (
          bucket_id = %L
          AND (storage.foldername(name))[1] = current_tenant_id()::text
        )
    $, b || '_update_tenant', b, b);

    EXECUTE format('DROP POLICY IF EXISTS %I ON storage.objects', b || '_delete_tenant');
    EXECUTE format($f$
      CREATE POLICY %I ON storage.objects
        FOR DELETE
        USING (
          bucket_id = %L
          AND (storage.foldername(name))[1] = current_tenant_id()::text
        )
    $, b || '_delete_tenant', b);
  END LOOP;
END $$;

-- ───────────────────────────────────────────────────────────────
-- VERIFICACIÓN
--
--   -- 8 policies (4 por bucket)
--   SELECT policyname, cmd FROM pg_policies
--    WHERE schemaname = 'storage' AND tablename = 'objects'
--      AND policyname LIKE '%marcas%' OR policyname LIKE '%locales%'
--    ORDER BY policyname;
--
--   -- Los buckets existen y son privados
--   SELECT id, public FROM storage.buckets
--    WHERE id IN ('marcas', 'locales');
--
-- ───────────────────────────────────────────────────────────────
-- PENDIENTE ANTES DE APLICAR
--
-- ⚠️ El bucket `productos` y el bucket `avatars` NO están en esta
--    migración. `productos` se sube desde varios sitios y `avatars` está
--    congelado. Hay que revisar sus policies por separado: pueden
--    seguir con el patrón viejo o no tener ninguna.
-- ───────────────────────────────────────────────────────────────