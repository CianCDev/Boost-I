-- 20261015000004_cerrar_super_admin_read_locales.sql
--
-- CIERRA LA CAUSA RAÍZ DE LA FUGA CROSS-TENANT EN `locales`
-- ============================================================
--
-- SÍNTOMA
-- --------
-- El RLS de `locales` está habilitado (`relrowsecurity = true`) y aun
-- así un SELECT con el JWT de un tenant devuelve los 5 locales de los
-- 5 tenants. Verificado el 2026-10-15:
--
--   SET role authenticated;
--   SET request.jwt.claims = '{"tenant_id":"9c7380a4-…", …}';
--   SELECT count(*) FROM locales;   →  5     (esperado: 1)
--
-- `current_tenant_id()` devuelve bien el tenant. El problema es que las
-- policies PERMISIVAS se combinan con OR, y `locales` tenía DOS:
--
--   locales_tenant_select     roles={authenticated}  (id = current_tenant_id()) → 1 fila
--   super_admin_read_locales  roles={public}        is_super_admin()           → todas
--
-- El claim correcto no cambiaba nada: el segundo brazo ganaba.
--
-- POR QUÉ SE PUDO VER
-- --------------------
-- El POS y el `admin_console` comparten `Supabase.instance.client`, o
-- sea la MISMA sesión y el MISMO JWT (ver docs/TODO.md:115). El owner
-- del SaaS tiene `is_superadmin = true`, así que dentro del POS veía
-- los 5 locales.
--
-- NO ES QUE EL DISEÑO ESTUVIERA MAL
-- ----------------------------------
-- AGENTS.MD §7.1 legitima que un super admin lea METADATA CONTRACTUAL
-- (nombre, RIF, plan, estado). `locales` es exactamente eso. El
-- problema no era la policy: era que el POS heredaba una sesión de
-- super admin sin necesitarla.
--
-- POR QUÉ SE DROPEA Y NO SE RESTRINGE
-- -----------------------------------
-- 1. No hay consumidor. `admin_console` NO consulta `locales`: usa
--    `tenants`, que tiene su propia policy. Las 9 coincidencias de
--    "locales" en ese módulo son la columna `planes.max_locales` y
--    comentarios que dicen que la pantalla todavía no existe
--    (`client_detail_screen.dart:474`, `:523`).
--
-- 2. Una policy `TO service_role` sería un no-op: en Supabase
--    `service_role` tiene `BYPASSRLS`, así que no necesita ninguna.
--    Recreate la policy solo para dejar un `USING (true)` decorativo.
--
-- 3. AGENTS.MD §7.3: "Nunca añadas policies RLS permisivas. Si un
--    super admin necesita algo, se hace vía RPC con validación
--    explícita, no vía policy abierta."
--
-- CUÁNDO HACERLA FALTA DE NUEVO
-- ------------------------------
-- Cuando se implemente la Subfase 3.3.3 del Control Center (la que hoy
-- dice "Rif, locales y usuarios no están disponibles en esta versión"),
-- NO hay que reactivar esta policy. El camino es una RPC
-- SECURITY DEFINER que valide `is_super_admin()` y registre en
-- `super_admin_audit_log` — que es literalmente lo que AGENTS.MD §7.3
-- pide y lo que ya hacen `log_super_admin_action()` y `mis_locales()`.

-- ═══════════════════════════════════════════════════════════════
-- 1. BACKUP (idempotente)
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public._backup_locales_policies (
  id           bigserial PRIMARY KEY,
  taken_at     timestamptz NOT NULL DEFAULT now(),
  policyname   text NOT NULL,
  cmd          text NOT NULL,
  roles        text[] NOT NULL,
  qual         text,
  with_check   text,
  note         text
);

INSERT INTO public._backup_locales_policies
  (policyname, cmd, roles, qual, with_check, note)
SELECT
  policyname, cmd, roles, qual, with_check,
  'Backup previo a 20261015000004'
FROM pg_policies
WHERE schemaname = 'public' AND tablename = 'locales';

-- ═══════════════════════════════════════════════════════════════
-- 2. DROP de la policy abierta
-- ═══════════════════════════════════════════════════════════════

DROP POLICY IF EXISTS super_admin_read_locales ON public.locales;

-- ═══════════════════════════════════════════════════════════════
-- 3. VERIFICACIONES (correr a mano)
-- ═══════════════════════════════════════════════════════════════

-- 3.1 · Ya no debe existir ninguna policy de `locales` que se aplique a
--      `authenticated` por fuera de `current_tenant_id()`.
--
-- SELECT policyname, cmd, roles, qual FROM pg_policies
--  WHERE schemaname='public' AND tablename='locales';
--
-- Esperado: solo `locales_tenant_select` (+ las de INSERT/UPDATE que
-- ya existían).
--
-- 3.2 · La prueba que fallaba antes. Ahora debe dar 1.
--
-- SET role authenticated;
-- SET request.jwt.claims = '{"tenant_id":"9c7380a4-14be-41c2-88db-07606c2a6489","sub":"604e9b98-354b-4fd6-b816-af97b47c1b0e","role":"authenticated"}';
-- SELECT id, nombre FROM locales ORDER BY nombre;
-- RESET ROLE;
--
-- 3.3 · Que el RLS siga habilitado y NO forzado. Si
--      `relforcerowsecurity = true`, el owner de la tabla también
--      obeyece las policies y `mis_locales()` (SECURITY DEFINER)
--      podría empezar a devolver 0 filas.
--
-- SELECT relrowsecurity, relforcerowsecurity
--   FROM pg_class WHERE oid = 'public.locales'::regclass;
--
-- 3.4 · Que el selector multi-local siga vivo. `mis_locales()`
--      corre como owner y bypasea RLS, así que no debería verse afectado.
--      Si devuelve 0 filas, revisar 3.3.
--
-- SELECT * FROM mis_locales();

-- ═══════════════════════════════════════════════════════════════
-- 4. RESTAURAR (solo si algo se rompe)
-- ═══════════════════════════════════════════════════════════════
--
-- INSERT INTO public._backup_locales_policies (policyname, note)
--   VALUES ('super_admin_read_locales', 'RESTAURADO manualmente');
--
-- DROP POLICY IF EXISTS super_admin_read_locales ON public.locales;
-- CREATE POLICY super_admin_read_locales ON public.locales
--   FOR SELECT TO public
--   USING (is_super_admin());
--
-- ⚠️ Restaurarla reintroduce la fuga: el POS del owner vuelve a ver
--    los 5 locales. Antes de hacerlo, confirmar qué la necesita.