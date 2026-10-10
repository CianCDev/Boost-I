-- ═══════════════════════════════════════════════════════════════
-- Overload de ajustar_stock por UUID.
--
-- La firma existente `ajustar_stock(bigint, integer, text)` recibe el
-- `productos.id` de Supabase (secuencia propia). El cliente pasa
-- `mov.productoId`, que es el ID de Isar local. Los dos números NO
-- coinciden: el RPC siempre devolvía false (producto no encontrado →
-- stock_actual NULL → comparación NULL → else → RETURN FALSE).
--
-- Peor: si por casualidad coincidían, el RPC habría ajustado stock
-- del producto EQUIVOCADO.
--
-- Esta overload acepta `uuid` (el `productos.uuid` que sí es estable
-- y cross-machine). El cliente ya valida el UUID antes de invocar.
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.ajustar_stock(
  p_producto_uuid uuid,
  p_cantidad integer,
  p_tipo_movimiento text
) RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  stock_actual INT;
BEGIN
  SELECT stock INTO stock_actual FROM productos
   WHERE uuid = p_producto_uuid FOR UPDATE;

  IF stock_actual IS NULL THEN
    RETURN FALSE;
  END IF;

  IF p_tipo_movimiento = 'salida' AND stock_actual < p_cantidad THEN
    RETURN FALSE;
  END IF;

  IF p_tipo_movimiento = 'salida' THEN
    UPDATE productos SET stock = stock - p_cantidad WHERE uuid = p_producto_uuid;
  ELSIF p_tipo_movimiento = 'entrada' THEN
    UPDATE productos SET stock = stock + p_cantidad WHERE uuid = p_producto_uuid;
  ELSE
    RETURN FALSE;
  END IF;

  RETURN TRUE;
END;
$$;

GRANT EXECUTE ON FUNCTION public.ajustar_stock(uuid, integer, text)
  TO authenticated, anon, public;