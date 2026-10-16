-- 20261015000001_cerrar_fuga_locales.sql
--
-- Restaura `locales_tenant_select` a la definición del baseline.
--
-- ⚠️ FUGA DE DATOS ENTRE TENANTS (2026-10-15)
--
-- El baseline define:
--     USING ((id = public.current_tenant_id()))
--
-- Pero en la BD remota había una policy con un brazo `EXISTS` extra:
--
--   USING ((id = current_tenant_id())
--          OR EXISTS (SELECT 1 FROM usuarios_locales ul
--                     WHERE ul.usuario_id = auth.uid()
--                       AND ul.tenant_id = locales.id
--                       AND ul.activo = true))
--
-- Ese brazo hace que un usuario vea TODO local para el que tenga fila en
-- `usuarios_locales`, no solo el local de su claim. Con filas de tenants
-- de prueba acumulados durante el desarrollo, el JWT de un tenant
-- descargaba los 5 locales de los 5 tenants.
--
-- En este modelo `locales.id` ES el `tenant_id`: cada local es un tenant.
-- Ver la fuga con evidencia en `docs/TODO.md` → "Fuga cross-tenant en
-- `locales` (2026-10-15)".
--
-- ⚠️ ESTA ALTERACIÓN NO ESTABA VERSIONADA. El cambio se hizo a mano en
--    el dashboard de Supabase. Por eso el repo y la BD divergieron sin
--    que ninguna migración lo delatara. Esta migración las reconcilia.
--
-- ── Por qué NO rompe el multi-local ──
--
-- Cambiar de local no usa `SELECT` sobre `locales`: usa la RPC
-- `set_active_tenant(tenant)` y después `refreshSession()`, que reemite
-- el JWT con el nuevo claim. El listado de locales del selector viene
-- de la RPC `mis_locales()`, que corre como `SECURITY DEFINER`.
-- Ninguna de las dos depende de esta policy de SELECT.
--
-- Verificado: `pg_policies` devuelve el `EXISTS` con `usuarios_locales`
-- únicamente en `locales`. Las demás tablas usan solo
-- `tenant_id = current_tenant_id()` (categorias, clientes, departamentos,
-- lotes, marcas, pedidos, productos, proveedores, ventas).

BEGIN;

-- Backup defensivo: permite revertir sin volver a construir el EXISTS.
-- La tabla se crea solo la primera vez.
DO $$
BEGIN
  IF to_regclass('public._backup_locales_policies') IS NULL THEN
    EXECUTE 'CREATE TABLE public._backup_locales_policies AS
             SELECT * FROM pg_policies WHERE tablename = ''locales''';
    RAISE NOTICE 'Backup creado: public._backup_locales_policies';
  END IF;
END $$;

DROP POLICY IF EXISTS locales_tenant_select ON public.locales;

CREATE POLICY locales_tenant_select ON public.locales
  FOR SELECT
  TO authenticated
  USING ((id = public.current_tenant_id()));

COMMIT;

-- ══════════════════════════════════════════════════════════════════════
-- VERIFICACIÓN (correr después de aplicar)
-- ══════════════════════════════════════════════════════════════════════
--
-- 1. La policy quedó como el baseline:
-- SELECT policyname, cmd, qual FROM pg_policies
--  WHERE tablename='locales' AND policyname='locales_tenant_select';
--    esperado: qual = "((id = current_tenant_id()))"
--
-- 2. Con un JWT de JAHTLABS, `locales` devuelve SOLO su fila:
--    (log de la app: 🔄 Descargando N locales → debe dar 1)
--
-- 3. `ventas` sigue intacta (nunca tuvo el brazo EXISTS):
-- SELECT policyname, qual FROM pg_policies WHERE tablename='ventas';
--    esperado: "((tenant_id = current_tenant_id()))"
--
-- 4. El multi-local sigue funcionando: en la app, cambiar de local
--    debe seguir 리스트ando los locales del usuario vía `mis_locales()`.
