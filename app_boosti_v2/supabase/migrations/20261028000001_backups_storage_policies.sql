-- ============================================================
-- Policies de Storage para el bucket `backups`.
--
-- El bucket `backups` se crea desde el CLIENTE en runtime
-- (`backup_service.dart:242`), así que NO pasó por esta carpeta de
-- migraciones y nació SIN policies: con RLS activo por defecto en
-- `storage.objects`, el upload/download falla silenciosamente (o, con
-- un JWT que oree policies, podría cruzar tenants).
--
-- Path de cada backup: `{tenant_id}/backup_{ts}_{motivo}.zip`
-- (`backup_service.dart:253`) — el aislamiento va sobre el primer
-- segmento del path, igual que en `marcas`/`locales`
-- (`20261010000006_storage_policies.sql`).
--
-- ⚠️ v2 (2026-10-28): la primera versión falló en el SQL Editor con
-- `42601: syntax error at or near "CREATE"` — se cerró la cadena de
-- `format` con `$` a secas en vez de `$f$`, y el parser ejecutaba el
-- cuerpo literal. Versión nueva SIN dollar-quotes anidados ni
-- `format`: al ser UN solo bucket, las 4 policies van planas.
--
-- ⚠️ Orden correcto (regla de AGENTS.MD): (1) correr este SQL en el
-- SQL Editor, (2) verificar con la query del final, (3) recién ahí
-- `supabase migration repair --status applied 20261028000001`.
--
-- Idempotente: DROP POLICY IF EXISTS antes de cada CREATE.
-- ============================================================

-- 1. Bucket por si el runtime todavía no lo creó (no borra ni toca
--    el existente; `public = false` como los demás).
INSERT INTO storage.buckets (id, name, public)
VALUES ('backups', 'backups', false)
ON CONFLICT (id) DO NOTHING;

-- 2. SELECT: descargar backups del propio tenant. Son sensibles al
--    contener TODO el Isar del local — quedan limitados al tenant.
DROP POLICY IF EXISTS backups_select_tenant ON storage.objects;
CREATE POLICY backups_select_tenant ON storage.objects
  FOR SELECT
  USING (
    bucket_id = 'backups'
    AND (storage.foldername(name))[1] = current_tenant_id()::text
  );

-- 3. INSERT: subir backups
DROP POLICY IF EXISTS backups_insert_tenant ON storage.objects;
CREATE POLICY backups_insert_tenant ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'backups'
    AND (storage.foldername(name))[1] = current_tenant_id()::text
  );

-- 4. UPDATE: reemplazar/renombrar backups
DROP POLICY IF EXISTS backups_update_tenant ON storage.objects;
CREATE POLICY backups_update_tenant ON storage.objects
  FOR UPDATE
  USING (
    bucket_id = 'backups'
    AND (storage.foldername(name))[1] = current_tenant_id()::text
  )
  WITH CHECK (
    bucket_id = 'backups'
    AND (storage.foldername(name))[1] = current_tenant_id()::text
  );

-- 5. DELETE: purga de backups antiguos
DROP POLICY IF EXISTS backups_delete_tenant ON storage.objects;
CREATE POLICY backups_delete_tenant ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'backups'
    AND (storage.foldername(name))[1] = current_tenant_id()::text
  );

-- ============================================================
-- VERIFICACIÓN
--
-- Debe listar las 4 del bucket `backups` (y las 8 de marcas/locales):
--
--   SELECT policyname, cmd FROM pg_policies
--    WHERE schemaname = 'storage' AND tablename = 'objects'
--    ORDER BY policyname;
-- ============================================================
