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

-- 2. Policies: 4 (SELECT, INSERT, UPDATE, DELETE), una carpeta por
--    tenant. Nota: los backups son sensibles al contener TODO el
--    Isar del local — el SELECT también queda limitado al tenant.
DO $$
DECLARE
  b text;
BEGIN
  b := 'backups';

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
END $$;

-- ============================================================
-- VERIFICACIÓN
--
-- Debe listar las 4 del bucket `backups` (y las 8 de marcas/locales):
--
--   SELECT policyname, cmd FROM pg_policies
--    WHERE schemaname = 'storage' AND tablename = 'objects'
--    ORDER BY policyname;
-- ============================================================
