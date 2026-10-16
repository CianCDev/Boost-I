-- 20261015000003_trial_hereda_basico.sql
--
-- POR QUÉ ESTA MIGRACIÓN TIENE QUE IR ANTES DEL CAMBIO EN DART
-- ===========================================================
--
-- `FeatureFlags._plan()` es:
--
--   bool _plan(String f, {bool defaultVisible = false}) =>
--       planActivo && (featuresHabilitadas.contains(f) || defaultVisible);
--
-- Los getters de menú usaban `defaultVisible: true` porque las claves no
-- existían en `planes.features` (ver AGENTS.MD §7.3, TODO(R.0)). Con la
-- migración `20261015000002` las claves ya existen, así que el
-- `defaultVisible` se va a pasar a `false`: a partir de ahí el gate
-- VALE, y un plan que no contrató la feature deja de verla.
--
-- ⚠️ El plan `trial` tiene SOLO `{offline, reports}`. Con el gate
-- efectivo perdería lotes, dashboard, historial, gastos, proveedores,
-- departamentos, monitor, pedidos y ventas al mayor — o sea, el POS
-- entero, para 4 tenants que hoy lo usan.
--
-- Un trial es un básico con fecha de vencimiento. El error fue de
-- carga de datos, no de diseño: la migración 0002 pobló `basico`,
-- `pro` y `corporativo` y se dejó `trial` con el catálogo original.
--
-- ESTA migración copia el catálogo de `basico` a `trial`. Es el mismo
-- criterio que ya aplica el resto del código: un trial debe poder
-- probar el producto.
--
-- Si en el futuro `trial` debe differentiatingarse (p. ej. sin
-- `ventas_mayor` para no exponer el B2B en pruebas), se ajusta ESTA
-- fila, no el getter de Dart.

-- ─────────────────────────────────────────────────────────────
-- 1. Backfill: `trial` hereda el catálogo de `basico`
-- ─────────────────────────────────────────────────────────────

UPDATE public.planes AS t
SET features = b.features,
    updated_at = now()
FROM public.planes AS b
WHERE t.id = 'trial'
  AND b.id = 'basico'
  AND t.features IS DISTINCT FROM b.features;

-- ─────────────────────────────────────────────────────────────
-- 2. Sanear grafías de estado
-- ─────────────────────────────────────────────────────────────
--
-- El CHECK `suscripciones_estado_check` YA existe y solo admite
--   ('trial','activo','vencido','cancelado','expirado')
--
-- Es decir: `'activa'` (femenino) está PROHIBIDO en la base. El
-- getter `SuscripcionEntity.activa` comparaba contra exactamente esa
-- grafía, así que devolvió `false` para todos los tenants desde el
-- día uno, sin excepción. Se corrigió en Dart el 2026-10-15.
--
-- Este bloque NO agrega el CHECK (ya existe): solo normaliza filas
-- que hubieran quedado fuera del catálogo por un bypass anterior.
-- Es un no-op si la base está sana.

UPDATE public.suscripciones
SET estado = 'activo'
WHERE estado = 'activa';

-- ─────────────────────────────────────────────────────────────
-- 3. Verificación (correr a mano, no hace falta en producción)
-- ─────────────────────────────────────────────────────────────

-- SELECT id, features FROM public.planes ORDER BY orden;
--
-- Esperado: `trial` idéntico a `basico`.
--
-- SELECT estado, count(*) FROM public.suscripciones GROUP BY estado;
--
-- SELECT conname, pg_get_constraintdef(oid)
--   FROM pg_constraint
--  WHERE conrelid = 'public.suscripciones'::regclass;