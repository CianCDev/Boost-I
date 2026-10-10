-- ═══════════════════════════════════════════════════════════════
-- Renombrar ajustar_stock(uuid, integer, text) → ajustar_stock_uuid
--
-- Motivo: PostgREST no distingue overloads con el mismo nombre y la
-- misma aridad de forma fiable. Cuando existen `ajustar_stock(bigint,
-- integer, text)` y `ajustar_stock(uuid, integer, text)`, PostgREST
-- elige la primera (por orden de creación). El cliente manda
-- `p_producto_uuid` (uuid), PostgREST lo pasa a la firma bigint,
-- PostgreSQL intenta el cast y devuelve FALSE sin encontrar producto.
--
-- Renombrar elimina la ambigüedad por completo.
-- ═══════════════════════════════════════════════════════════════

-- 1. Drop la overload previa con nombre antiguo (por si quedó).
DROP FUNCTION IF EXISTS public.ajustar_stock(uuid, integer, text);

-- 2. Crear con nombre único.
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

GRANT EXECUTE ON FUNCTION public.ajustar_stock_uuid(uuid, integer, text)
  TO authenticated, anon, public;

COMMENT ON FUNCTION public.ajustar_stock_uuid(uuid, integer, text) IS
  'Ajusta stock por UUID. Reemplaza a ajustar_stock(uuid,...) que '
  'colisionaba con la overload bigint en PostgREST.';