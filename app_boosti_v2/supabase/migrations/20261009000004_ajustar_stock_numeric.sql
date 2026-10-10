-- ═══════════════════════════════════════════════════════════════
-- Cambiar p_cantidad de integer a numeric en ajustar_stock_uuid.
--
-- El cliente mandaba `mov.cantidad.toInt()`, truncando productos
-- esPesado (0.5 kg -> 0). Al descontar lotes de verdad, eso rompía:
-- una venta de 0.5 kg no descontaba nada y devolvía TRUE.
--
-- ⚠️ Doble fix coordinado:
--   · SQL: p_cantidad pasa a numeric.
--   · Dart: `sync_service.dart` manda `mov.cantidad` (double), no
--     `mov.cantidad.toInt()`.
--   Aplicar SOLO este archivo sin el cambio Dart deja el truncamiento.
--
-- ⚠️ SE DEBE APLICAR DESPUÉS de 20261009000003_lotes_fuente_unica.sql.
-- ═══════════════════════════════════════════════════════════════

DROP FUNCTION IF EXISTS public.ajustar_stock_uuid(uuid, integer, text);

CREATE OR REPLACE FUNCTION public.ajustar_stock_uuid(
  p_producto_uuid uuid,
  p_cantidad numeric,
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

  -- Ver los tipos que realmente manda el cliente.
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
    -- Sumar al lote activo más antiguo.
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

GRANT EXECUTE ON FUNCTION public.ajustar_stock_uuid(uuid, numeric, text)
  TO authenticated, anon, public;

COMMENT ON FUNCTION public.ajustar_stock_uuid(uuid, numeric, text) IS
  'Mueve lotes FEFO y recalcula productos.stock desde lotes activos. '
  'Acepta cantidades decimales (productos esPesado). Modelo: lotes es '
  'la fuente única de verdad.';