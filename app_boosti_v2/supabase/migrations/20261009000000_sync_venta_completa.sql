-- ═══════════════════════════════════════════════════════════════
-- RPC: sync_venta_completa
--
-- Reemplaza los 2 inserts no-atómicos de sync_service.dart:1871/1906.
-- Inserta venta + detalles en 1 transacción PL/pgSQL. Si falla
-- cualquier detalle, rollback completo (no quedan ventas huérfanas).
--
-- SECURITY DEFINER bypasea las policies RLS de ventas/detalle_ventas
-- (que solo permiten SELECT + INSERT al rol `public`). Sin esto, el
-- UPSERT y el DELETE-then-INSERT serían bloqueados.
--
-- SET search_path obligatorio (patrón del repo, evita hijacking).
-- ═══════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.sync_venta_completa(
  p_venta jsonb,
  p_detalles jsonb
) RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_venta_id uuid;
  v_tenant_id uuid;
BEGIN
  v_venta_id := (p_venta->>'id')::uuid;
  IF v_venta_id IS NULL THEN
    RAISE EXCEPTION 'sync_venta_completa: p_venta.id es obligatorio';
  END IF;

  v_tenant_id := current_tenant_id();
  IF v_tenant_id IS NULL THEN
    RAISE EXCEPTION 'sync_venta_completa: tenant_id no disponible en el JWT';
  END IF;

  -- 1. UPSERT venta (idempotente por id).
  INSERT INTO public.ventas (
    id, fecha, subtotal, impuesto, total, tasa_bcv, total_bolivares,
    metodo_pago, documento, empleado_nombre, cliente_id, empleado_id,
    empleado, sync_status, tiene_descuento_especial, monto_descuento_total,
    tenant_id, tipo_venta, tipo_documento, requiere_autorizacion,
    autorizado_por_nombre, autorizado_por_rol, fecha_autorizacion,
    monto_descuento_porcentaje, tipo_pago, es_multipago,
    cliente_rif, cliente_razon_social, cliente_nombre, cliente_documento
  ) VALUES (
    v_venta_id,
    COALESCE((p_venta->>'fecha')::timestamptz, now()),
    COALESCE((p_venta->>'subtotal')::numeric, 0),
    COALESCE((p_venta->>'impuesto')::numeric, 0),
    COALESCE((p_venta->>'total')::numeric, 0),
    COALESCE((p_venta->>'tasa_bcv')::numeric, 0),
    COALESCE((p_venta->>'total_bolivares')::numeric, 0),
    p_venta->>'metodo_pago',
    COALESCE((p_venta->>'documento')::bigint, 0),
    p_venta->>'empleado_nombre',
    NULLIF(p_venta->>'cliente_id', '')::uuid,
    NULLIF(p_venta->>'empleado_id', '')::uuid,
    p_venta->>'empleado',
    COALESCE(p_venta->>'sync_status', 'synced'),
    COALESCE((p_venta->>'tiene_descuento_especial')::boolean, false),
    COALESCE((p_venta->>'monto_descuento_total')::numeric, 0),
    v_tenant_id,
    COALESCE(p_venta->>'tipo_venta', 'detal'),
    p_venta->>'tipo_documento',
    COALESCE((p_venta->>'requiere_autorizacion')::boolean, false),
    p_venta->>'autorizado_por_nombre',
    p_venta->>'autorizado_por_rol',
    NULLIF(p_venta->>'fecha_autorizacion', '')::timestamptz,
    COALESCE((p_venta->>'monto_descuento_porcentaje')::numeric, 0),
    COALESCE(p_venta->>'tipo_pago', 'contado'),
    COALESCE((p_venta->>'es_multipago')::boolean, false),
    p_venta->>'cliente_rif',
    p_venta->>'cliente_razon_social',
    p_venta->>'cliente_nombre',
    p_venta->>'cliente_documento'
  )
  ON CONFLICT (id) DO UPDATE SET
    sync_status = EXCLUDED.sync_status;

  -- 2. DELETE-then-INSERT detalles (idempotente por venta).
  DELETE FROM public.detalle_ventas
   WHERE venta_id_tk = v_venta_id AND tenant_id = v_tenant_id;

  IF p_detalles IS NOT NULL
     AND jsonb_typeof(p_detalles) = 'array'
     AND jsonb_array_length(p_detalles) > 0 THEN
    INSERT INTO public.detalle_ventas (
      venta_id_tk, nombre_producto, precio_unidad, cantidad, subtotal,
      precio_original, es_descuento_especial, producto_id, tenant_id,
      precio_detal_original, precio_mayor_aplicado, tipo_precio,
      descuento_porcentaje_linea, unidad_empaque, unidades_por_empaque,
      autorizado_por_linea, costo_unitario_snapshot, lote_id_isar,
      sync_status
    )
    SELECT
      v_venta_id,
      d->>'nombre_producto',
      (d->>'precio_unidad')::numeric,
      (d->>'cantidad')::numeric,
      (d->>'subtotal')::numeric,
      (d->>'precio_original')::numeric,
      COALESCE((d->>'es_descuento_especial')::boolean, false),
      (d->>'producto_id')::bigint,
      v_tenant_id,
      (d->>'precio_detal_original')::numeric,
      (d->>'precio_mayor_aplicado')::numeric,
      d->>'tipo_precio',
      COALESCE((d->>'descuento_porcentaje_linea')::numeric, 0),
      COALESCE(d->>'unidad_empaque', 'unidad'),
      COALESCE((d->>'unidades_por_empaque')::integer, 1),
      d->>'autorizado_por_linea',
      (d->>'costo_unitario_snapshot')::numeric,
      (d->>'lote_id_isar')::bigint,
      COALESCE(d->>'sync_status', 'synced')
    FROM jsonb_array_elements(p_detalles) AS d;
  END IF;

  RETURN v_venta_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.sync_venta_completa(jsonb, jsonb)
  TO authenticated, anon, public;