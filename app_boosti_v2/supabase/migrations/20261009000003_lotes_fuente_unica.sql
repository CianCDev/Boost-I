-- ═══════════════════════════════════════════════════════════════
-- Rediseño: lotes como fuente única de verdad del stock.
--
-- Antes convivían 2 modelos contradictorios:
--   · productos.stock (campo desnormalizado, escrito por 14 sitios)
--   · SUM(lotes.cantidad_restante) (calculado, escrito por 3)
--
-- Familia A recalculaba productos.stock desde lotes; Familia B escribía
-- a ciegas. Los lotes incluso llegaron a tener cantidad_restante >
-- cantidad_inicial, señal de que 3 sitios sumaban a restante sin
-- control.
--
-- Este archivo:
--   1. Limpia los lotes corruptos.
--   2. Recalcula productos.stock desde lotes.
--   3. Reescribe ajustar_stock_uuid para que mueva lotes (FEFO) y luego
--      recalcule productos.stock. Antes solo tocaba productos.stock, lo
--      que divergía con los lotes en la nube.
--
-- ⚠️ SCHEMA VERIFICADO (2026-10-08) contra la base real:
--   lotes.id               uuid        gen_random_uuid()
--   lotes.id_isar          integer     (no es la PK)
--   lotes.producto_id_fk   bigint      → productos(id_isar)
--   lotes.cantidad_inicial numeric
--   lotes.cantidad_restante numeric
--   lotes.estado           text        ('activo' | 'pendiente')
--   lotes.fecha_vencimiento timestamp without time zone
--   productos.stock        numeric
--
-- ⚠️ CORRECCIÓN 1 — tipos de movimiento.
--   El enunciado original comparaba p_tipo_movimiento contra
--   'salida' / 'entrada'. Los valores que REALMENTE envía el cliente son
--   largos y en español. Verificado en la nube:
--       movimientos_inventarios.tipo_movimiento → 'Venta' (43),
--                                                 'Edición de stock' (1)
--   y en el código Dart: 'Venta', 'Venta al mayor', 'Consumo receta',
--   'Ajuste manual', 'Eliminación', 'Creación producto',
--   'Edición de stock', 'ajuste_anulacion'.
--   Con la comparación original el RPC caía siempre en el ELSE y
--   devolvía FALSE: nunca movía stock. Aquí se mapean AMBOS juegos de
--   valores para que funcione con lo que el cliente manda hoy.
--
-- ⚠️ CORRECCIÓN 2 — truncamiento de decimales (NO corregido aquí).
--   p_cantidad es `integer` y el cliente manda `mov.cantidad.toInt()`.
--   Para productos pesados (esPesado) una cantidad de 0.5 kg llega como
--   0. Corregirlo exige cambiar la firma a numeric Y el lado Dart; se
--   deja fuera de este archivo a propósito. Ver reporte.
-- ═══════════════════════════════════════════════════════════════

-- ── 1. Limpieza: lotes con restante > inicial ──────────────────────
--   Imposible por decremento puro: señal de que algún escritor sumaba
--   a cantidad_restante sin tocar cantidad_inicial.
UPDATE public.lotes
   SET cantidad_restante = cantidad_inicial
 WHERE cantidad_restante > cantidad_inicial
   AND estado = 'activo';

-- ── 2. Recalcular productos.stock desde lotes (todos los productos) ──
--   ⚠️ ORDEN IMPORTA: la limpieza de arriba debe correr primero, o el
--   recalculo hereda la corrupción.
UPDATE public.productos p
   SET stock = COALESCE((
     SELECT SUM(l.cantidad_restante)
       FROM public.lotes l
      WHERE l.producto_id_fk = p.id_isar
        AND l.estado = 'activo'
   ), 0);

-- ── 3. Reemplazar ajustar_stock_uuid: FEFO sobre lotes + recalc ──────
DROP FUNCTION IF EXISTS public.ajustar_stock_uuid(uuid, integer, text);

CREATE OR REPLACE FUNCTION public.ajustar_stock_uuid(
  p_producto_uuid uuid,
  p_cantidad integer,
  p_tipo_movimiento text
) RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_producto_id_isar integer;
  v_restante numeric;
  v_lote record;
  v_salida boolean;
  v_entrada boolean;
BEGIN
  IF p_cantidad IS NULL OR p_cantidad <= 0 THEN
    RETURN FALSE;
  END IF;

  -- Ver los tipos que realmente manda el cliente (ver CORRECCIÓN 1).
  v_salida := p_tipo_movimiento IN (
      'salida', 'Venta', 'Venta al mayor', 'Consumo receta',
      'Eliminación', 'descuento');
  v_entrada := p_tipo_movimiento IN (
      'entrada', 'Edición de stock', 'Creación producto',
      'Ajuste manual', 'anulacion', 'ajuste_anulacion');

  IF NOT v_salida AND NOT v_entrada THEN
    RETURN FALSE;
  END IF;

  SELECT id_isar INTO v_producto_id_isar
    FROM public.productos WHERE uuid = p_producto_uuid;
  IF v_producto_id_isar IS NULL THEN
    RETURN FALSE;
  END IF;

  IF v_salida THEN
    v_restante := p_cantidad;

    -- Descontar FEFO (vencimiento más próximo primero, nulls al final).
    FOR v_lote IN
      SELECT id, cantidad_restante
        FROM public.lotes
       WHERE producto_id_fk = v_producto_id_isar
         AND estado = 'activo'
         AND cantidad_restante > 0
       ORDER BY fecha_vencimiento ASC NULLS LAST, id ASC
       FOR UPDATE
    LOOP
      EXIT WHEN v_restante <= 0;
      IF v_lote.cantidad_restante >= v_restante THEN
        UPDATE public.lotes
           SET cantidad_restante = cantidad_restante - v_restante
         WHERE id = v_lote.id;
        v_restante := 0;
      ELSE
        UPDATE public.lotes
           SET cantidad_restante = 0,
               estado = 'agotado'
         WHERE id = v_lote.id;
        v_restante := v_restante - v_lote.cantidad_restante;
      END IF;
    END LOOP;

    IF v_restante > 0 THEN
      RETURN FALSE;  -- stock insuficiente
    END IF;

  ELSE
    -- Sumar al lote activo más antiguo; si no hay, el recalc de abajo
    -- deja productos.stock en 0 y no hay dónde depositar la entrada.
    UPDATE public.lotes
       SET cantidad_restante = cantidad_restante + p_cantidad
     WHERE id = (
       SELECT id FROM public.lotes
        WHERE producto_id_fk = v_producto_id_isar
          AND estado = 'activo'
        ORDER BY id ASC
        LIMIT 1
     );
  END IF;

  -- Recalcular productos.stock desde lotes activos (fuente única).
  UPDATE public.productos
     SET stock = COALESCE((
       SELECT SUM(cantidad_restante) FROM public.lotes
        WHERE producto_id_fk = v_producto_id_isar
          AND estado = 'activo'
     ), 0)
   WHERE uuid = p_producto_uuid;

  RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.ajustar_stock_uuid(uuid, integer, text)
  TO authenticated, anon, public;

COMMENT ON FUNCTION public.ajustar_stock_uuid(uuid, integer, text) IS
  'Mueve lotes FEFO y recalcula productos.stock desde lotes activos. '
  'Modelo: lotes es la fuente única de verdad. Acepta tipos largos '
  '(Venta, Edición de stock, ...) y cortos (salida, entrada).';