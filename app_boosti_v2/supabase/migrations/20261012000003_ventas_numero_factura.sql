-- ═══════════════════════════════════════════════════════════════
-- Agrega `numero_factura` a `ventas`.
--
-- MOTIVACIÓN
--
-- La factura legal exige numeración fiscal correlativa. No se puede
-- reusar el campo `documento`:
--
--   1. Es `bigint` (en Isar, `int`). Cambiarlo a `text` es migración
--      mayor: hay que alterar la columna, migrar las filas existentes
--      y bumpear el schema de Isar.
--   2. `documento` tiene DOBLE significado. En `venta_service.dart`
--      se llena con el documento del CLIENTE (`..documento =
--      cliente.documento`, y `= 0` cuando no hay cliente), no con un
--      número de factura. Pisar eso con la numeración fiscal
--      destruiría el dato del cliente.
--
-- Por eso es un campo NUEVO y no una reasignación. El campo `documento`
-- queda como está, con su ambigüedad, como deuda post-v1.
--
-- ───────────────────────────────────────────────────────────────
-- ⚠️ LO QUE ESTA MIGRACIÓN **NO** RESUELVE
--
-- La numeración es POR DISPOSITIVO (`{deviceId}-{year}-{counter}`),
-- válida bajo Providencia 00071 para un punto de emisión. Dos
-- dispositivos del mismo negocio generan secuencias que pueden
-- colisionar. Secuencia server-side es post-v1.
--
-- Nullable a propósito: las ventas anteriores a esta migración no
-- tienen número, y `NULL` las distingue de un número mal formado.
-- El ticket imprime "pendiente" en ese caso, para que la falencia se
-- vea en el papel.
--
-- Idempotente: `IF NOT EXISTS` permite correrla más de una vez.
-- ═══════════════════════════════════════════════════════════════

ALTER TABLE public.ventas
  ADD COLUMN IF NOT EXISTS numero_factura text;

-- ───────────────────────────────────────────────────────────────
-- ÍNDICE PARCIAL
--
-- Solo indexa las ventas que TIENEN número. Indexar el NULL no
-- sirve para buscar y ensucia el índice con todas las ventas
-- históricas que quedaron sin numerar.
-- ───────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_ventas_numero_factura
  ON public.ventas (numero_factura)
  WHERE numero_factura IS NOT NULL;

-- ───────────────────────────────────────────────────────────────
-- VERIFICACIÓN
--
--   select column_name, data_type
--     from information_schema.columns
--    where table_name = 'ventas' and column_name = 'numero_factura';
--
-- Y el chequeo de duplicados una vez que haya ventas numeradas:
--
--   select numero_factura, count(*)
--     from public.ventas
--    where numero_factura is not null
--    group by numero_factura
--   having count(*) > 1;
--
-- Si eso devuelve filas, hay dos dispositivos con la misma
-- secuencia → hay que migrar a numeración server-side antes de
-- seguir vendiendo.
-- ═══════════════════════════════════════════════════════════════
