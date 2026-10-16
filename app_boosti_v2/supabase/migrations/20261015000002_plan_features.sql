-- 20261015000002_plan_features.sql
--
-- Agrega las claves que `FeatureFlags` consulta pero que no existen en
-- `planes.features`, y reparte los módulos por plan.
--
-- ⚠️ POR QUÉ (2026-10-15)
--
-- `business_mode_provider.dart` define ~20 feature flags. La mayoría son
-- getters huérfanos marcados `defaultVisible: true`, pero `_plan()` los
-- gatea igual:
--
--   bool _plan(String f, {bool defaultVisible = false}) =>
--       planActivo && (featuresHabilitadas.contains(f) || defaultVisible);
--
-- `planActivo` es un `&&` curto: si el tenant no tiene suscripción
-- activa, NADA se ve — ni siquiera las huérfanas.
--
-- Antes de esta migración, la tabla `planes` solo tenía 4 claves:
--   offline, reports, multi_local, priority_support
--
-- Es decir: los getters sin `defaultVisible` (dashboard, historial_ventas,
-- historial_gastos, departamentos, lotes, ventas_mayor,
-- pedidos_proveedores, monitor_empleados) NO se activaban nunca. El
-- código tenía un `TODO(R.0)` en cada uno esperando esta migración.
--
-- ── Reparto acordado (producto, 2026-10-15) ──
--
--   · básico      → SÍ ve el dashboard
--   · básico      → NO ve proveedores, pedidos ni locales
--   · pro         → lo de básico + proveedores, pedidos, locales, mayor
--   · corporativo → todo
--
-- ── Por qué esto no alcanza solo ──
--
-- Aunque las claves existan, si el tenant no tiene fila en
-- `suscripciones` el menú sigue vacío (fail-closed). Los tenants creados
-- antes del deploy de `create-tenant` NO tienen fila: la EF que la crea
-- se deployó el 2026-10-13 y solo pobló suscripciones de altas nuevas.

BEGIN;

-- ══════════════════════════════════════════════════════════════════════
-- 1. trial — paridad con básico
-- ══════════════════════════════════════════════════════════════════════
UPDATE public.planes
   SET features = features::jsonb
                  || '{"dashboard":true,"historial_ventas":true,
                      "historial_gastos":true,"departamentos":true,
                      "lotes":true,"monitor_empleados":true,
                      "ventas_mayor":false,"pedidos_proveedores":false,
                      "proveedores":false,"multi_local":false}'::jsonb
 WHERE id = 'trial';

-- ══════════════════════════════════════════════════════════════════════
-- 2. basico — ve dashboard, NO ve proveedores/pedidos/locales
-- ══════════════════════════════════════════════════════════════════════
UPDATE public.planes
   SET features = features::jsonb
                  || '{"dashboard":true,"historial_ventas":true,
                      "historial_gastos":true,"departamentos":true,
                      "lotes":true,"monitor_empleados":true,
                      "ventas_mayor":false,"pedidos_proveedores":false,
                      "proveedores":false,"multi_local":false}'::jsonb
 WHERE id = 'basico';

-- ══════════════════════════════════════════════════════════════════════
-- 3. pro — todo lo de básico + proveedores, pedidos, locales, mayor
-- ══════════════════════════════════════════════════════════════════════
UPDATE public.planes
   SET features = features::jsonb
                  || '{"dashboard":true,"historial_ventas":true,
                      "historial_gastos":true,"departamentos":true,
                      "lotes":true,"monitor_empleados":true,
                      "ventas_mayor":true,"pedidos_proveedores":true,
                      "proveedores":true,"multi_local":true}'::jsonb
 WHERE id = 'pro';

-- ══════════════════════════════════════════════════════════════════════
-- 4. corporativo — todo
-- ══════════════════════════════════════════════════════════════════════
UPDATE public.planes
   SET features = features::jsonb
                  || '{"dashboard":true,"historial_ventas":true,
                      "historial_gastos":true,"departamentos":true,
                      "lotes":true,"monitor_empleados":true,
                      "ventas_mayor":true,"pedidos_proveedores":true,
                      "proveedores":true,"multi_local":true,
                      "priority_support":true}'::jsonb
 WHERE id = 'corporativo';

COMMIT;

-- ══════════════════════════════════════════════════════════════════════
-- VERIFICACIÓN
-- ══════════════════════════════════════════════════════════════════════
-- SELECT id, features FROM public.planes ORDER BY id;
--
-- Ojo: el `||` de jsonb es una unión superficial por clave, así que
-- sobrescribe las claves repetidas y conserva el resto. Verificar que
-- `offline` y `reports` sigan en true en los 4 planes.

-- ══════════════════════════════════════════════════════════════════════
-- PENDIENTE DE DATOS (no lo hace esta migración)
-- ══════════════════════════════════════════════════════════════════════
--
-- Los tenants creados antes del 2026-10-13 no tienen fila en
-- `suscripciones`. Con `planActivo = false` el menú sigue vacío aunque
-- las claves existan. Para cada tenant afectado:
--
--   INSERT INTO public.suscripciones (tenant_id, plan_id, estado,
--       iniciado_en, auto_renovar)
--   VALUES ('<tenant-uuid>', 'pro', 'activo', now(), true)
--   ON CONFLICT (tenant_id) DO UPDATE
--     SET plan_id = EXCLUDED.plan_id, estado = 'activo';
--
-- (`tenant_id` es UNIQUE en esa tabla: la relación con `tenants` es 1:1.)
--
-- Verificable con:
--   SELECT l.nombre, s.plan_id, s.estado
--   FROM locales l LEFT JOIN suscripciones s ON s.tenant_id = l.id
--   WHERE s.tenant_id IS NULL;
--   → cada fila es un tenant sin suscripción.
