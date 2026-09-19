--
-- PostgreSQL database dump
--

\restrict wVPHaBD7Rq7nRoQXezFTM5K6rN2Cy20kcz4w2Wt9XbJCfyj9zeodRpAD7qB1SYD

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: estado_caja; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_caja AS ENUM (
    'abierta',
    'cerrada'
);


--
-- Name: estado_cajero; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_cajero AS ENUM (
    'activo',
    'en_descanso',
    'desconectado',
    'inactivo'
);


--
-- Name: metodo_pago; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.metodo_pago AS ENUM (
    'efectivo',
    'tarjeta',
    'transferencia',
    'credito'
);


--
-- Name: tipo_documento_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_documento_enum AS ENUM (
    'V',
    'E'
);


--
-- Name: tipo_movimiento; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_movimiento AS ENUM (
    'entrada',
    'salida',
    'ajuste'
);


--
-- Name: actualizar_estado_usuario(integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.actualizar_estado_usuario(p_id_isar integer, p_nuevo_estado text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  -- Validar que el estado sea válido
  IF p_nuevo_estado NOT IN ('activo', 'descanso', 'inactivo') THEN
    RAISE EXCEPTION 'Estado no válido';
  END IF;

  -- Actualizar solo el estado del usuario
  UPDATE public.usuarios
  SET estado = p_nuevo_estado
  WHERE id_isar = p_id_isar;
END;
$$;


--
-- Name: actualizar_stock_producto(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.actualizar_stock_producto() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE productos
  SET stock = (
    SELECT COALESCE(SUM(cantidad_restante), 0)
    FROM lotes
    WHERE producto_id_fk = NEW.producto_id_fk AND estado = 'activo'
  )
  WHERE id = NEW.producto_id_fk;
  RETURN NEW;
END;
$$;


--
-- Name: ajustar_stock(uuid, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ajustar_stock(p_producto_id uuid, p_cantidad integer) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    stock_actual INT;
BEGIN
    -- Bloquear la fila para evitar condiciones de carrera
    SELECT stock INTO stock_actual FROM productos WHERE id = p_producto_id FOR UPDATE;
    
    -- Verificar si hay suficiente stock
    IF stock_actual >= p_cantidad THEN
        -- Actualizar stock
        UPDATE productos 
        SET stock = stock - p_cantidad 
        WHERE id = p_producto_id;
        RETURN TRUE;
    ELSE
        -- No hay suficiente stock
        RETURN FALSE;
    END IF;
END;
$$;


--
-- Name: ajustar_stock(uuid, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.ajustar_stock(p_producto_id uuid, p_cantidad integer, p_tipo_movimiento text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  stock_actual INT;
BEGIN
  -- Bloquear la fila para evitar condiciones de carrera
  SELECT stock INTO stock_actual FROM productos WHERE id = p_producto_id FOR UPDATE;

  -- Validar si hay stock suficiente (solo para salidas)
  IF p_tipo_movimiento = 'salida' AND stock_actual < p_cantidad THEN
    RETURN FALSE;
  END IF;

  -- Actualizar stock según el tipo de movimiento
  IF p_tipo_movimiento = 'salida' THEN
    UPDATE productos SET stock = stock - p_cantidad WHERE id = p_producto_id;
  ELSIF p_tipo_movimiento = 'entrada' THEN
    UPDATE productos SET stock = stock + p_cantidad WHERE id = p_producto_id;
  ELSE
    RETURN FALSE; -- tipo inválido
  END IF;

  RETURN TRUE;
END;
$$;


--
-- Name: audit_trigger(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.audit_trigger() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
BEGIN
  INSERT INTO public.audit_log (
    tenant_id, usuario_id, accion, tabla, registro_id, datos_antes, datos_despues
  ) VALUES (
    COALESCE(NEW.tenant_id, OLD.tenant_id),
    auth.uid(),
    LOWER(TG_OP),
    TG_TABLE_NAME,
    COALESCE(NEW.id::text, OLD.id::text),
    CASE WHEN TG_OP IN ('UPDATE','DELETE') THEN to_jsonb(OLD) END,
    CASE WHEN TG_OP IN ('UPDATE','INSERT') THEN to_jsonb(NEW) END
  );
  RETURN COALESCE(NEW, OLD);
END $$;


--
-- Name: crear_nuevo_local_para_usuario(text, text, text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crear_nuevo_local_para_usuario(p_nombre text, p_direccion text DEFAULT NULL::text, p_telefono text DEFAULT NULL::text, p_email text DEFAULT NULL::text, p_rif text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
DECLARE
  v_nuevo_tenant_id uuid;
  v_usuario_id uuid := auth.uid();
BEGIN
  IF v_usuario_id IS NULL THEN
    RAISE EXCEPTION 'No hay usuario autenticado.';
  END IF;

  IF p_nombre IS NULL OR length(trim(p_nombre)) = 0 THEN
    RAISE EXCEPTION 'El nombre del local es obligatorio.';
  END IF;

  INSERT INTO public.locales (id, nombre, direccion, telefono, email, rif)
  VALUES (
    gen_random_uuid(),
    trim(p_nombre),
    NULLIF(trim(p_direccion), ''),
    NULLIF(trim(p_telefono), ''),
    NULLIF(trim(p_email), ''),
    NULLIF(trim(p_rif), '')
  )
  RETURNING id INTO v_nuevo_tenant_id;

  INSERT INTO public.usuarios_locales (usuario_id, tenant_id, rol, es_default, activo)
  VALUES (v_usuario_id, v_nuevo_tenant_id, 'admin', false, true);

  RETURN v_nuevo_tenant_id;
END;
$$;


--
-- Name: current_tenant_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_tenant_id() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  SELECT COALESCE(
    (auth.jwt() ->> 'tenant_id')::uuid,
    (auth.jwt() -> 'user_metadata' ->> 'tenant_id')::uuid
  );
$$;


--
-- Name: current_user_tenant_id(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.current_user_tenant_id() RETURNS uuid
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT tenant_id
  FROM public.usuarios
  WHERE id = auth.uid()
  LIMIT 1;
$$;


--
-- Name: FUNCTION current_user_tenant_id(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.current_user_tenant_id() IS 'Retorna el tenant_id del usuario autenticado (auth.uid()). Base para todas las RLS policies del sistema.';


--
-- Name: custom_access_token_hook(jsonb); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.custom_access_token_hook(event jsonb) RETURNS jsonb
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
  claims jsonb;
  v_tenant_id uuid;
  v_user_id uuid;
BEGIN
  -- user_id del evento
  v_user_id := (event->>'user_id')::uuid;
  claims := event->'claims';

  -- Buscar tenant_id en public.usuarios
  SELECT tenant_id INTO v_tenant_id
  FROM public.usuarios
  WHERE id = v_user_id
  LIMIT 1;

  -- Si no lo encuentra, intentar con user_metadata
  IF v_tenant_id IS NULL THEN
    v_tenant_id := (event->'claims'->'user_metadata'->>'tenant_id')::uuid;
  END IF;

  -- Inyectar tenant_id en el claim raíz
  IF v_tenant_id IS NOT NULL THEN
    claims := jsonb_set(claims, '{tenant_id}', to_jsonb(v_tenant_id));
  END IF;

  RETURN jsonb_set(event, '{claims}', claims);
END;
$$;


--
-- Name: decrypt_telegram_token(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.decrypt_telegram_token(p_encrypted text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'vault', 'extensions', 'pg_temp'
    AS $$
DECLARE
  v_key text;
BEGIN
  IF p_encrypted IS NULL OR p_encrypted = '' THEN RETURN NULL; END IF;
  v_key := public.get_telegram_key();
  IF v_key IS NULL THEN RAISE EXCEPTION 'Clave no disponible en Vault'; END IF;
  BEGIN
    RETURN extensions.pgp_sym_decrypt(decode(p_encrypted, 'base64'), v_key);
  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END;
END;
$$;


--
-- Name: encrypt_telegram_token(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.encrypt_telegram_token(p_plain text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'vault', 'extensions', 'pg_temp'
    AS $$
DECLARE
  v_key text;
BEGIN
  IF p_plain IS NULL OR p_plain = '' THEN RETURN NULL; END IF;
  v_key := public.get_telegram_key();
  IF v_key IS NULL THEN RAISE EXCEPTION 'Clave no disponible en Vault'; END IF;
  RETURN encode(extensions.pgp_sym_encrypt(p_plain, v_key), 'base64');
END;
$$;


--
-- Name: get_telegram_key(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_telegram_key() RETURNS text
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public', 'vault', 'extensions', 'pg_temp'
    AS $$
  SELECT decrypted_secret
  FROM vault.decrypted_secrets
  WHERE name = 'telegram_token_key'
  LIMIT 1;
$$;


--
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_tenant_id uuid;
  v_rol       text;
  v_nombre    text;
  v_pin       text;
  v_id_isar   bigint;
BEGIN
  -- ✅ Valores con fallback seguro para evitar NULLs
  v_tenant_id := NULLIF(NEW.raw_user_meta_data->>'tenant_id', '')::uuid;
  v_rol       := COALESCE(NULLIF(NEW.raw_user_meta_data->>'rol', ''), 'cajero');
  v_nombre    := COALESCE(
                   NULLIF(NEW.raw_user_meta_data->>'nombre', ''),
                   split_part(NEW.email, '@', 1)
                 );
  v_pin       := COALESCE(NULLIF(NEW.raw_user_meta_data->>'pin', ''), '1234');
  v_id_isar   := nextval('public.usuarios_id_isar_seq');

  IF v_tenant_id IS NULL THEN
    RAISE NOTICE 'Usuario % sin tenant_id → perfil NO creado', NEW.id;
    RETURN NEW;
  END IF;

  -- ✅ Bloque 1: insertar perfil con try/except aislado
  BEGIN
    INSERT INTO public.usuarios (
      id, nombre, rol, pin, email, estado, tenant_id, id_isar
    )
    VALUES (
      NEW.id, v_nombre, v_rol, v_pin, NEW.email,
      'inactivo', v_tenant_id, v_id_isar
    )
    ON CONFLICT (id) DO NOTHING;
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING '⚠️ handle_new_user: fallo INSERT public.usuarios para % → %',
      NEW.id, SQLERRM;
  END;

  -- ✅ Bloque 2: insertar relación local (aislado, no rompe auth si falla)
  BEGIN
    INSERT INTO public.usuarios_locales (
      usuario_id, tenant_id, rol, es_default, activo
    )
    VALUES (NEW.id, v_tenant_id, v_rol, true, true)
    ON CONFLICT (usuario_id, tenant_id) DO NOTHING;
  EXCEPTION WHEN OTHERS THEN
    RAISE WARNING '⚠️ handle_new_user: fallo INSERT usuarios_locales para % → %',
      NEW.id, SQLERRM;
  END;

  RETURN NEW;
END;
$$;


--
-- Name: has_any_role(text[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.has_any_role(roles text[]) RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.usuarios
    WHERE id = auth.uid()
      AND rol = ANY(roles)
  );
$$;


--
-- Name: FUNCTION has_any_role(roles text[]); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.has_any_role(roles text[]) IS 'Retorna true si el usuario autenticado tiene alguno de los roles del array. Uso: has_any_role(ARRAY[''admin'', ''supervisor''])';


--
-- Name: is_tenant_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_tenant_admin() RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.usuarios
    WHERE id = auth.uid()
      AND tenant_id = public.current_tenant_id()
      AND LOWER(rol) = 'admin'
  );
$$;


--
-- Name: mis_locales(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.mis_locales() RETURNS TABLE(tenant_id uuid, nombre text, direccion text, rol text, es_default boolean)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  SELECT 
    ul.tenant_id,
    l.nombre,
    l.direccion,
    ul.rol,
    ul.es_default
  FROM usuarios_locales ul
  JOIN locales l ON l.id = ul.tenant_id
  WHERE ul.usuario_id = auth.uid()
    AND ul.activo = true
  ORDER BY ul.es_default DESC, l.nombre ASC;
$$;


--
-- Name: set_active_tenant(uuid); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.set_active_tenant(p_tenant_id uuid) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_access boolean;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'No autenticado';
  END IF;

  -- Verificar que el usuario tiene acceso al tenant objetivo
  SELECT EXISTS (
    SELECT 1 FROM usuarios_locales
    WHERE usuario_id = v_user_id
      AND tenant_id = p_tenant_id
      AND activo = true
  ) INTO v_access;

  IF NOT v_access THEN
    RAISE EXCEPTION 'No tienes acceso a este local';
  END IF;

  -- Quitar es_default de todos
  UPDATE usuarios_locales
  SET es_default = false
  WHERE usuario_id = v_user_id AND es_default = true;

  -- Poner es_default en el nuevo
  UPDATE usuarios_locales
  SET es_default = true
  WHERE usuario_id = v_user_id AND tenant_id = p_tenant_id;

  RETURN true;
END;
$$;


--
-- Name: telegram_config_encrypt_token(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.telegram_config_encrypt_token() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'vault', 'extensions', 'pg_temp'
    AS $_$
BEGIN
  IF NEW.bot_token IS NOT NULL
     AND NEW.bot_token <> ''
     AND NEW.bot_token ~ '^[0-9]{6,12}:[A-Za-z0-9_-]{30,}$' THEN
    NEW.bot_token := public.encrypt_telegram_token(NEW.bot_token);
  END IF;
  RETURN NEW;
END;
$_$;


--
-- Name: telegram_config_sync_status(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.telegram_config_sync_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.sincronizado = true AND (NEW.sync_status IS NULL OR NEW.sync_status = 'pending') THEN
    NEW.sync_status := 'synced';
  ELSIF NEW.sincronizado = false AND (NEW.sync_status IS NULL OR NEW.sync_status = 'synced') THEN
    NEW.sync_status := 'pending';
  END IF;
  RETURN NEW;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audit_log (
    id bigint NOT NULL,
    tenant_id uuid NOT NULL,
    usuario_id uuid,
    accion text NOT NULL,
    tabla text NOT NULL,
    registro_id text,
    datos_antes jsonb,
    datos_despues jsonb,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: audit_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audit_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audit_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audit_log_id_seq OWNED BY public.audit_log.id;


--
-- Name: autorizaciones_descuento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.autorizaciones_descuento (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    id_isar bigint,
    venta_id uuid,
    producto_id_isar bigint,
    producto_nombre text,
    es_global boolean DEFAULT false NOT NULL,
    descuento_solicitado numeric(5,2) NOT NULL,
    tope_rol_solicitante numeric(5,2) NOT NULL,
    solicitado_por_id bigint,
    solicitado_por_nombre text NOT NULL,
    solicitado_por_rol text NOT NULL,
    autorizado_por_id bigint,
    autorizado_por_nombre text,
    autorizado_por_rol text,
    aprobado boolean NOT NULL,
    motivo_rechazo text,
    fecha timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cajas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cajas (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    nombre character varying(50) NOT NULL,
    estado public.estado_caja DEFAULT 'cerrada'::public.estado_caja,
    creado_en timestamp with time zone DEFAULT now(),
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL
);


--
-- Name: categorias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categorias (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    created_at timestamp with time zone DEFAULT now(),
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone
);


--
-- Name: clientes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.clientes (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    nombre character varying(150) NOT NULL,
    email character varying(100),
    telefono character varying(50),
    direccion text,
    creado_en timestamp with time zone DEFAULT now(),
    documento bigint,
    fecha_registro timestamp with time zone DEFAULT now(),
    frecuente boolean DEFAULT false,
    total_compras numeric(12,2) DEFAULT 0,
    ultima_compra timestamp with time zone,
    cantidad_compras integer DEFAULT 0,
    activo boolean DEFAULT true,
    preferencias_marketing boolean DEFAULT true,
    fecha_nacimiento date,
    notas text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    razon_social text,
    rif text,
    es_mayorista boolean DEFAULT false NOT NULL,
    limite_credito numeric,
    dias_credito integer,
    descuento_preferencial numeric,
    tipo_documento text
);


--
-- Name: codigos_barras_alias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.codigos_barras_alias (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_isar integer NOT NULL,
    codigo text NOT NULL,
    producto_id_fk bigint NOT NULL,
    factor numeric DEFAULT 1.0 NOT NULL,
    activo boolean DEFAULT true,
    fecha_asignacion timestamp without time zone DEFAULT now(),
    observaciones text,
    sincronizado boolean DEFAULT false,
    fecha_sincronizacion timestamp without time zone,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL
);


--
-- Name: config_descuentos_mayoristas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.config_descuentos_mayoristas (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    id_isar bigint,
    nombre text NOT NULL,
    categoria_id_isar bigint,
    categoria_supabase_id uuid,
    cantidad_minima integer NOT NULL,
    cantidad_maxima integer,
    descuento_porcentaje numeric(5,2) NOT NULL,
    requiere_autorizacion boolean DEFAULT false NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cotizaciones_mayor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cotizaciones_mayor (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    id_isar bigint,
    numero text NOT NULL,
    cliente_id uuid,
    cliente_rif text,
    cliente_razon_social text,
    items_json jsonb DEFAULT '[]'::jsonb NOT NULL,
    subtotal numeric(12,2) DEFAULT 0 NOT NULL,
    descuento_global numeric(12,2) DEFAULT 0 NOT NULL,
    impuesto numeric(12,2) DEFAULT 0 NOT NULL,
    total numeric(12,2) DEFAULT 0 NOT NULL,
    total_bolivares numeric(14,2),
    tasa_bcv numeric(12,4),
    estado text DEFAULT 'borrador'::text NOT NULL,
    fecha_emision timestamp with time zone DEFAULT now() NOT NULL,
    fecha_vencimiento timestamp with time zone,
    observaciones text,
    usuario_id bigint,
    usuario_nombre text,
    venta_convertida_id uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: departamentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departamentos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    nombre text NOT NULL,
    descripcion text,
    activo boolean DEFAULT true,
    id_isar integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    sync_status text DEFAULT 'pending'::text,
    sincronizado boolean DEFAULT false,
    fecha_sincronizacion timestamp with time zone,
    usuario_id bigint
);


--
-- Name: detalle_ventas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.detalle_ventas (
    id bigint NOT NULL,
    venta_id_tk uuid,
    nombre_producto text NOT NULL,
    precio_unidad numeric(12,2) NOT NULL,
    cantidad numeric(12,3) NOT NULL,
    subtotal numeric(12,2) NOT NULL,
    precio_original numeric,
    es_descuento_especial boolean DEFAULT false,
    producto_id bigint,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    precio_detal_original numeric,
    precio_mayor_aplicado numeric,
    tipo_precio text,
    descuento_porcentaje_linea numeric DEFAULT 0 NOT NULL,
    unidad_empaque text DEFAULT 'unidad'::text NOT NULL,
    unidades_por_empaque integer DEFAULT 1 NOT NULL,
    autorizado_por_linea text,
    costo_unitario_snapshot numeric,
    lote_id_isar bigint,
    sync_status text DEFAULT 'synced'::text
);


--
-- Name: detalle_ventas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.detalle_ventas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: detalle_ventas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.detalle_ventas_id_seq OWNED BY public.detalle_ventas.id;


--
-- Name: detalles_pedido; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.detalles_pedido (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    pedido_id uuid,
    producto_id bigint,
    nombre_producto text NOT NULL,
    cantidad numeric(10,2) NOT NULL,
    precio_unidad numeric(10,2) NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    producto_id_isar bigint,
    id_isar bigint,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL
);


--
-- Name: entregas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entregas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    pedido_id uuid,
    fecha_entrega timestamp with time zone DEFAULT now(),
    usuario_id uuid NOT NULL,
    estado_entrega text DEFAULT 'entregado'::text,
    observaciones text,
    created_at timestamp with time zone DEFAULT now(),
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    CONSTRAINT entregas_estado_entrega_check CHECK ((estado_entrega = ANY (ARRAY['entregado'::text, 'parcial'::text, 'fallido'::text])))
);


--
-- Name: gastos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.gastos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_isar integer,
    descripcion text NOT NULL,
    monto numeric(12,2) NOT NULL,
    moneda text DEFAULT 'USD'::text,
    tasa_bcv numeric(12,4),
    categoria text DEFAULT 'General'::text,
    usuario_id uuid,
    usuario_nombre text,
    fecha timestamp with time zone DEFAULT now() NOT NULL,
    sync_status text DEFAULT 'pending'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL
);


--
-- Name: locales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.locales (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre text NOT NULL,
    direccion text,
    telefono text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    id_isar bigint,
    activo boolean DEFAULT true,
    sync_status text DEFAULT 'pending'::text,
    sincronizado boolean DEFAULT false,
    fecha_sincronizacion timestamp with time zone,
    email text,
    rif text
);


--
-- Name: lotes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lotes (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    id_isar integer NOT NULL,
    codigo_lote_proveedor text,
    cantidad_inicial numeric NOT NULL,
    cantidad_restante numeric NOT NULL,
    fecha_ingreso timestamp without time zone DEFAULT now(),
    fecha_vencimiento timestamp without time zone,
    estado text DEFAULT 'activo'::text,
    costo_unitario numeric,
    sincronizado boolean DEFAULT false,
    fecha_sincronizacion timestamp without time zone,
    producto_id_fk bigint,
    local_id integer DEFAULT 1,
    proveedor_id uuid,
    proveedor_nombre text,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL
);


--
-- Name: marcas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marcas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre text NOT NULL,
    descripcion text,
    logo_url text,
    proveedor_id uuid,
    activo boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL
);


--
-- Name: movimientos_inventarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.movimientos_inventarios (
    id integer NOT NULL,
    producto_id bigint,
    nombre_producto text,
    tipo_movimiento text,
    cantidad numeric,
    stock_resultante numeric,
    fecha timestamp with time zone,
    usuario_id bigint,
    sync_status text DEFAULT 'pending'::text,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL
);


--
-- Name: movimientos_inventarios_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.movimientos_inventarios_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: movimientos_inventarios_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.movimientos_inventarios_id_seq OWNED BY public.movimientos_inventarios.id;


--
-- Name: pagos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pagos (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    metodo public.metodo_pago NOT NULL,
    monto numeric(10,2) NOT NULL,
    fecha_pago timestamp with time zone DEFAULT now(),
    venta_id uuid,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL
);


--
-- Name: pagos_venta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pagos_venta (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    venta_id uuid NOT NULL,
    id_isar bigint,
    metodo text NOT NULL,
    monto numeric(12,2) NOT NULL,
    moneda text NOT NULL,
    monto_usd_equivalente numeric(12,2) NOT NULL,
    tasa_bcv numeric(12,4),
    referencia text,
    ultimos_digitos text,
    wallet_destino text,
    hash_transaccion text,
    banco_emisor text,
    titular text,
    fecha timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pagos_ventas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pagos_ventas (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    venta_id uuid NOT NULL,
    id_isar integer,
    metodo text NOT NULL,
    monto numeric DEFAULT 0 NOT NULL,
    moneda text DEFAULT 'USD'::text NOT NULL,
    monto_usd_equivalente numeric DEFAULT 0 NOT NULL,
    tasa_bcv numeric,
    referencia text,
    ultimos_digitos text,
    wallet_destino text,
    hash_transaccion text,
    banco_emisor text,
    titular text,
    fecha timestamp with time zone DEFAULT now() NOT NULL,
    sync_status text DEFAULT 'synced'::text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: pedidos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pedidos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    cliente_nombre text,
    cliente_telefono text,
    cliente_direccion text,
    fecha_pedido timestamp with time zone DEFAULT now(),
    fecha_entrega_estimada timestamp with time zone,
    estado text DEFAULT 'pendiente'::text,
    total numeric(10,2) NOT NULL,
    metodo_pago text,
    observaciones text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    sync_status text DEFAULT 'pending'::text,
    tipo_pedido text DEFAULT 'cliente'::text NOT NULL,
    cliente_cedula text,
    proveedor_cedula text,
    proveedor_empresa text,
    proveedor_nombre text,
    proveedor_telefono text,
    usuario_id uuid,
    id_isar bigint,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    CONSTRAINT pedidos_estado_check CHECK ((estado = ANY (ARRAY['pendiente'::text, 'en_proceso'::text, 'listo_para_entregar'::text, 'entregado'::text, 'pagado'::text, 'cancelado'::text, 'cerrado'::text, 'recibido'::text, 'completo'::text]))),
    CONSTRAINT pedidos_tipo_pedido_check CHECK ((tipo_pedido = ANY (ARRAY['cliente'::text, 'proveedor'::text])))
);


--
-- Name: productos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.productos (
    id bigint NOT NULL,
    codigo_barras text NOT NULL,
    nombre text NOT NULL,
    precio_unidad numeric(12,2) DEFAULT 0.00 NOT NULL,
    stock numeric(12,3) DEFAULT 0.00 NOT NULL,
    stock_minimo numeric(12,3) DEFAULT 5.00 NOT NULL,
    es_pesado boolean DEFAULT false,
    categoria text DEFAULT 'General'::text,
    proveedor_nombre text DEFAULT ''::text,
    proveedor_telefono text DEFAULT ''::text,
    updated_at timestamp with time zone DEFAULT now(),
    imagen_url text,
    sync_status text DEFAULT 'synced'::text,
    id_isar integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    marca text,
    created_by integer,
    marca_supabase_id uuid,
    proveedor_email text,
    proveedor_direccion text,
    updated_by integer,
    created_by_name text,
    updated_by_name text,
    version integer DEFAULT 0,
    proveedor_id uuid,
    uuid uuid NOT NULL,
    activo boolean DEFAULT true,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    permite_venta_mayor boolean DEFAULT false NOT NULL,
    precio_mayor numeric,
    cantidad_minima_mayor integer,
    precio_medio_mayor numeric,
    cantidad_minima_medio_mayor integer,
    unidades_por_bulto integer DEFAULT 1 NOT NULL,
    costo_unitario_promedio numeric
);


--
-- Name: productos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.productos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: productos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.productos_id_seq OWNED BY public.productos.id;


--
-- Name: proveedores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.proveedores (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    nombre text NOT NULL,
    cedula text,
    telefono text,
    direccion text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    empresa text,
    activo boolean DEFAULT true,
    sync_status text DEFAULT 'pending'::text,
    email text,
    id_isar integer,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL
);


--
-- Name: recepciones; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recepciones (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    pedido_id uuid,
    fecha_recepcion timestamp with time zone DEFAULT now(),
    usuario_id integer NOT NULL,
    estado_recepcion text DEFAULT 'completa'::text,
    observaciones text,
    created_at timestamp with time zone DEFAULT now(),
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    CONSTRAINT recepciones_estado_recepcion_check CHECK ((estado_recepcion = ANY (ARRAY['completa'::text, 'parcial'::text, 'pendiente'::text])))
);


--
-- Name: telegram_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telegram_config (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bot_token text,
    chat_id text,
    enabled boolean DEFAULT true,
    usuarios_autorizados_ids integer[],
    roles_autorizados text[],
    notificar_stock_bajo boolean DEFAULT true,
    notificar_ventas boolean DEFAULT false,
    ultima_actualizacion timestamp with time zone,
    id_isar integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    notificar_pedidos boolean DEFAULT false,
    nombre_chat text,
    comandos_permitidos jsonb DEFAULT '["/ventas", "/stock", "/ayuda"]'::jsonb,
    sincronizado boolean DEFAULT false,
    fecha_sincronizacion timestamp with time zone,
    sync_status text DEFAULT 'pending'::text,
    usuario_id integer,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    CONSTRAINT telegram_config_chat_id_format CHECK (((chat_id IS NULL) OR (chat_id ~ '^-?[0-9]{5,20}$'::text) OR (chat_id ~ '^@[A-Za-z][A-Za-z0-9_]{4,31}$'::text))),
    CONSTRAINT telegram_config_comandos_validos CHECK (((comandos_permitidos IS NULL) OR (jsonb_typeof(comandos_permitidos) = 'array'::text)))
);

ALTER TABLE ONLY public.telegram_config FORCE ROW LEVEL SECURITY;


--
-- Name: telegram_config_safe; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.telegram_config_safe WITH (security_invoker='true') AS
 SELECT id,
    id_isar,
    usuario_id,
    tenant_id,
    chat_id,
    nombre_chat,
    enabled,
    notificar_stock_bajo,
    notificar_ventas,
    notificar_pedidos,
    comandos_permitidos,
    sincronizado,
    fecha_sincronizacion,
    sync_status,
    created_at,
    updated_at,
    COALESCE(updated_at, created_at) AS ultima_actualizacion,
        CASE
            WHEN (bot_token IS NULL) THEN NULL::text
            ELSE substr(md5(bot_token), 1, 8)
        END AS bot_token_fingerprint
   FROM public.telegram_config;


--
-- Name: VIEW telegram_config_safe; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.telegram_config_safe IS 'Vista sin bot_token. Incluye fingerprint (md5 corto) para auditar rotaciones.';


--
-- Name: turnos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.turnos (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    caja_id uuid,
    usuario_id uuid,
    monto_inicial numeric(10,2) DEFAULT 0.00 NOT NULL,
    monto_final numeric(10,2),
    fecha_apertura timestamp with time zone DEFAULT now(),
    fecha_cierre timestamp with time zone,
    estado text DEFAULT 'abierto'::text,
    sync_status text DEFAULT 'pending'::text,
    id_isar integer,
    usuario_id_int integer,
    usuario_nombre text,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL
);


--
-- Name: usuarios; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuarios (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    nombre character varying(100) NOT NULL,
    rol character varying(50) NOT NULL,
    estado public.estado_cajero DEFAULT 'desconectado'::public.estado_cajero,
    inicio_descanso timestamp with time zone,
    minutos_descanso integer,
    creado_en timestamp with time zone DEFAULT now(),
    id_isar bigint,
    device_id text,
    ultima_actividad timestamp with time zone DEFAULT now(),
    caja_asignada text DEFAULT 'Caja Principal'::text,
    email text,
    pin text,
    departamento text,
    "ultimaActualizacion" date,
    updated_at timestamp with time zone DEFAULT now(),
    tenant_id uuid NOT NULL,
    tipo_documento public.tipo_documento_enum,
    numero_documento character varying(20),
    telefono character varying(20),
    direccion text,
    foto_url text,
    supervisor_id uuid,
    CONSTRAINT usuarios_numero_documento_format CHECK (((numero_documento IS NULL) OR ((numero_documento)::text ~ '^[0-9]{1,15}$'::text)))
);

ALTER TABLE ONLY public.usuarios REPLICA IDENTITY FULL;


--
-- Name: usuarios_id_isar_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuarios_id_isar_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuarios_locales; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuarios_locales (
    usuario_id uuid NOT NULL,
    tenant_id uuid NOT NULL,
    rol text DEFAULT 'cajero'::text NOT NULL,
    es_default boolean DEFAULT false,
    activo boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: v_usuarios_publicos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_usuarios_publicos AS
 SELECT id_isar,
    nombre,
    rol,
    estado
   FROM public.usuarios;


--
-- Name: ventas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ventas (
    id uuid NOT NULL,
    fecha timestamp with time zone DEFAULT now(),
    subtotal numeric(12,2) DEFAULT 0.00 NOT NULL,
    impuesto numeric(12,2) DEFAULT 0.00 NOT NULL,
    total numeric(12,2) DEFAULT 0.00 NOT NULL,
    tasa_bcv numeric(12,4) DEFAULT 0.00 NOT NULL,
    total_bolivares numeric(12,2) DEFAULT 0.00 NOT NULL,
    metodo_pago text NOT NULL,
    documento bigint DEFAULT 0,
    empleado_nombre text NOT NULL,
    cliente_id uuid,
    empleado_id uuid,
    empleado text,
    sync_status text,
    tiene_descuento_especial boolean DEFAULT false,
    monto_descuento_total numeric(12,2) DEFAULT 0.00,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    tipo_venta text DEFAULT 'detal'::text NOT NULL,
    tipo_documento text,
    requiere_autorizacion boolean DEFAULT false NOT NULL,
    autorizado_por_nombre text,
    autorizado_por_rol text,
    fecha_autorizacion timestamp with time zone,
    monto_descuento_porcentaje numeric DEFAULT 0 NOT NULL,
    tipo_pago text DEFAULT 'contado'::text NOT NULL,
    es_multipago boolean DEFAULT false NOT NULL,
    cliente_rif text,
    cliente_razon_social text,
    cliente_nombre text,
    cliente_documento text
);


--
-- Name: ventas_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ventas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ventas_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ventas_id_seq OWNED BY public.ventas.id;


--
-- Name: audit_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log ALTER COLUMN id SET DEFAULT nextval('public.audit_log_id_seq'::regclass);


--
-- Name: detalle_ventas id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_ventas ALTER COLUMN id SET DEFAULT nextval('public.detalle_ventas_id_seq'::regclass);


--
-- Name: movimientos_inventarios id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimientos_inventarios ALTER COLUMN id SET DEFAULT nextval('public.movimientos_inventarios_id_seq'::regclass);


--
-- Name: productos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos ALTER COLUMN id SET DEFAULT nextval('public.productos_id_seq'::regclass);


--
-- Name: audit_log audit_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_pkey PRIMARY KEY (id);


--
-- Name: autorizaciones_descuento autorizaciones_descuento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autorizaciones_descuento
    ADD CONSTRAINT autorizaciones_descuento_pkey PRIMARY KEY (id);


--
-- Name: cajas cajas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_pkey PRIMARY KEY (id);


--
-- Name: categorias categorias_nombre_tenant_uk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_tenant_uk UNIQUE (tenant_id, nombre);


--
-- Name: categorias categorias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_pkey PRIMARY KEY (id);


--
-- Name: clientes clientes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_pkey PRIMARY KEY (id);


--
-- Name: codigos_barras_alias codigos_barras_alias_codigo_tenant_uk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codigos_barras_alias
    ADD CONSTRAINT codigos_barras_alias_codigo_tenant_uk UNIQUE (tenant_id, codigo);


--
-- Name: codigos_barras_alias codigos_barras_alias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codigos_barras_alias
    ADD CONSTRAINT codigos_barras_alias_pkey PRIMARY KEY (id);


--
-- Name: config_descuentos_mayoristas config_descuentos_mayoristas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.config_descuentos_mayoristas
    ADD CONSTRAINT config_descuentos_mayoristas_pkey PRIMARY KEY (id);


--
-- Name: cotizaciones_mayor cotizaciones_mayor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cotizaciones_mayor
    ADD CONSTRAINT cotizaciones_mayor_pkey PRIMARY KEY (id);


--
-- Name: cotizaciones_mayor cotizaciones_numero_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cotizaciones_mayor
    ADD CONSTRAINT cotizaciones_numero_unique UNIQUE (tenant_id, numero);


--
-- Name: departamentos departamentos_id_isar_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_id_isar_unique UNIQUE (id_isar);


--
-- Name: departamentos departamentos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_pkey PRIMARY KEY (id);


--
-- Name: detalle_ventas detalle_ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_ventas
    ADD CONSTRAINT detalle_ventas_pkey PRIMARY KEY (id);


--
-- Name: detalles_pedido detalles_pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalles_pedido
    ADD CONSTRAINT detalles_pedido_pkey PRIMARY KEY (id);


--
-- Name: entregas entregas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entregas
    ADD CONSTRAINT entregas_pkey PRIMARY KEY (id);


--
-- Name: gastos gastos_id_isar_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gastos
    ADD CONSTRAINT gastos_id_isar_unique UNIQUE (id_isar);


--
-- Name: gastos gastos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gastos
    ADD CONSTRAINT gastos_pkey PRIMARY KEY (id);


--
-- Name: locales locales_id_isar_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locales
    ADD CONSTRAINT locales_id_isar_unique UNIQUE (id_isar);


--
-- Name: locales locales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locales
    ADD CONSTRAINT locales_pkey PRIMARY KEY (id);


--
-- Name: lotes lotes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_pkey PRIMARY KEY (id);


--
-- Name: marcas marcas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_pkey PRIMARY KEY (id);


--
-- Name: movimientos_inventarios movimientos_inventarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimientos_inventarios
    ADD CONSTRAINT movimientos_inventarios_pkey PRIMARY KEY (id);


--
-- Name: pagos pagos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_pkey PRIMARY KEY (id);


--
-- Name: pagos_venta pagos_venta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagos_venta
    ADD CONSTRAINT pagos_venta_pkey PRIMARY KEY (id);


--
-- Name: pagos_ventas pagos_ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagos_ventas
    ADD CONSTRAINT pagos_ventas_pkey PRIMARY KEY (id);


--
-- Name: pedidos pedidos_id_tenant_uk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_id_tenant_uk UNIQUE (id, tenant_id);


--
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id);


--
-- Name: productos productos_codigo_barras_tenant_uk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_codigo_barras_tenant_uk UNIQUE (tenant_id, codigo_barras);


--
-- Name: productos productos_id_isar_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_id_isar_unique UNIQUE (id_isar);


--
-- Name: productos productos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_pkey PRIMARY KEY (id);


--
-- Name: productos productos_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_uuid_unique UNIQUE (uuid);


--
-- Name: proveedores proveedores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_pkey PRIMARY KEY (id);


--
-- Name: recepciones recepciones_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recepciones
    ADD CONSTRAINT recepciones_pkey PRIMARY KEY (id);


--
-- Name: telegram_config telegram_config_id_isar_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_config
    ADD CONSTRAINT telegram_config_id_isar_unique UNIQUE (id_isar);


--
-- Name: telegram_config telegram_config_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_config
    ADD CONSTRAINT telegram_config_pkey PRIMARY KEY (id);


--
-- Name: telegram_config telegram_config_tenant_usuario_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_config
    ADD CONSTRAINT telegram_config_tenant_usuario_unique UNIQUE (tenant_id, usuario_id);


--
-- Name: turnos turno_cajas_id_isar_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turnos
    ADD CONSTRAINT turno_cajas_id_isar_key UNIQUE (id_isar);


--
-- Name: turnos turno_cajas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turnos
    ADD CONSTRAINT turno_cajas_pkey PRIMARY KEY (id);


--
-- Name: proveedores unique_id_isar; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT unique_id_isar UNIQUE (id_isar);


--
-- Name: usuarios usuarios_id_isar_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_isar_unique UNIQUE (id_isar);


--
-- Name: usuarios_locales usuarios_locales_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios_locales
    ADD CONSTRAINT usuarios_locales_pkey PRIMARY KEY (usuario_id, tenant_id);


--
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: ventas ventas_id_tenant_uk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_id_tenant_uk UNIQUE (id, tenant_id);


--
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);


--
-- Name: idx_audit_tabla; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_tabla ON public.audit_log USING btree (tabla, created_at DESC);


--
-- Name: idx_audit_tenant_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_tenant_fecha ON public.audit_log USING btree (tenant_id, created_at DESC);


--
-- Name: idx_audit_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_audit_usuario ON public.audit_log USING btree (usuario_id, created_at DESC);


--
-- Name: idx_autorizaciones_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_autorizaciones_id_isar ON public.autorizaciones_descuento USING btree (id_isar);


--
-- Name: idx_autorizaciones_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_autorizaciones_tenant ON public.autorizaciones_descuento USING btree (tenant_id);


--
-- Name: idx_autorizaciones_venta_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_autorizaciones_venta_id ON public.autorizaciones_descuento USING btree (venta_id);


--
-- Name: idx_autz_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_autz_fecha ON public.autorizaciones_descuento USING btree (tenant_id, fecha DESC);


--
-- Name: idx_autz_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_autz_id_isar ON public.autorizaciones_descuento USING btree (id_isar);


--
-- Name: idx_autz_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_autz_tenant ON public.autorizaciones_descuento USING btree (tenant_id);


--
-- Name: idx_autz_venta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_autz_venta ON public.autorizaciones_descuento USING btree (venta_id);


--
-- Name: idx_cajas_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cajas_tenant ON public.cajas USING btree (tenant_id);


--
-- Name: idx_categorias_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_categorias_tenant ON public.categorias USING btree (tenant_id);


--
-- Name: idx_clientes_documento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_documento ON public.clientes USING btree (documento);


--
-- Name: idx_clientes_es_mayorista; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_es_mayorista ON public.clientes USING btree (es_mayorista);


--
-- Name: idx_clientes_mayorista; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_mayorista ON public.clientes USING btree (tenant_id) WHERE (es_mayorista = true);


--
-- Name: idx_clientes_rif; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_rif ON public.clientes USING btree (tenant_id, rif) WHERE (rif IS NOT NULL);


--
-- Name: idx_clientes_telefono; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_telefono ON public.clientes USING btree (telefono);


--
-- Name: idx_clientes_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_tenant ON public.clientes USING btree (tenant_id);


--
-- Name: idx_clientes_tipo_doc; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_tipo_doc ON public.clientes USING btree (tipo_documento);


--
-- Name: idx_codigos_barras_alias_codigo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_codigos_barras_alias_codigo ON public.codigos_barras_alias USING btree (codigo);


--
-- Name: idx_codigos_barras_alias_producto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_codigos_barras_alias_producto ON public.codigos_barras_alias USING btree (producto_id_fk);


--
-- Name: idx_codigos_barras_alias_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_codigos_barras_alias_tenant ON public.codigos_barras_alias USING btree (tenant_id);


--
-- Name: idx_config_descuentos_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_config_descuentos_activo ON public.config_descuentos_mayoristas USING btree (tenant_id) WHERE (activo = true);


--
-- Name: idx_config_descuentos_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_config_descuentos_tenant ON public.config_descuentos_mayoristas USING btree (tenant_id);


--
-- Name: idx_cotizaciones_cliente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cotizaciones_cliente ON public.cotizaciones_mayor USING btree (cliente_id);


--
-- Name: idx_cotizaciones_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cotizaciones_estado ON public.cotizaciones_mayor USING btree (tenant_id, estado);


--
-- Name: idx_cotizaciones_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cotizaciones_id_isar ON public.cotizaciones_mayor USING btree (id_isar);


--
-- Name: idx_cotizaciones_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_cotizaciones_tenant ON public.cotizaciones_mayor USING btree (tenant_id);


--
-- Name: idx_departamentos_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_departamentos_tenant ON public.departamentos USING btree (tenant_id);


--
-- Name: idx_departamentos_usuario_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_departamentos_usuario_id ON public.departamentos USING btree (usuario_id);


--
-- Name: idx_detalle_ventas_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_detalle_ventas_tenant ON public.detalle_ventas USING btree (tenant_id);


--
-- Name: idx_detalles_pedido_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_detalles_pedido_tenant ON public.detalles_pedido USING btree (tenant_id);


--
-- Name: idx_entregas_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_entregas_tenant ON public.entregas USING btree (tenant_id);


--
-- Name: idx_gastos_categoria; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gastos_categoria ON public.gastos USING btree (categoria);


--
-- Name: idx_gastos_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gastos_fecha ON public.gastos USING btree (fecha);


--
-- Name: idx_gastos_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gastos_id_isar ON public.gastos USING btree (id_isar);


--
-- Name: idx_gastos_sync; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gastos_sync ON public.gastos USING btree (sync_status);


--
-- Name: idx_gastos_sync_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gastos_sync_status ON public.gastos USING btree (sync_status);


--
-- Name: idx_gastos_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gastos_tenant ON public.gastos USING btree (tenant_id);


--
-- Name: idx_gastos_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_gastos_usuario ON public.gastos USING btree (usuario_id);


--
-- Name: idx_lotes_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lotes_estado ON public.lotes USING btree (estado);


--
-- Name: idx_lotes_producto_id_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lotes_producto_id_fk ON public.lotes USING btree (producto_id_fk);


--
-- Name: idx_lotes_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_lotes_tenant ON public.lotes USING btree (tenant_id);


--
-- Name: idx_marcas_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marcas_nombre ON public.marcas USING btree (nombre);


--
-- Name: idx_marcas_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marcas_tenant ON public.marcas USING btree (tenant_id);


--
-- Name: idx_movimientos_inventarios_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimientos_inventarios_tenant ON public.movimientos_inventarios USING btree (tenant_id);


--
-- Name: idx_pagos_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pagos_tenant ON public.pagos USING btree (tenant_id);


--
-- Name: idx_pagos_venta_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pagos_venta_id_isar ON public.pagos_venta USING btree (id_isar);


--
-- Name: idx_pagos_venta_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pagos_venta_tenant ON public.pagos_venta USING btree (tenant_id);


--
-- Name: idx_pagos_venta_venta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pagos_venta_venta ON public.pagos_venta USING btree (venta_id);


--
-- Name: idx_pagos_ventas_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pagos_ventas_id_isar ON public.pagos_ventas USING btree (id_isar);


--
-- Name: idx_pagos_ventas_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pagos_ventas_tenant ON public.pagos_ventas USING btree (tenant_id);


--
-- Name: idx_pagos_ventas_venta_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pagos_ventas_venta_id ON public.pagos_ventas USING btree (venta_id);


--
-- Name: idx_pedidos_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pedidos_estado ON public.pedidos USING btree (estado);


--
-- Name: idx_pedidos_sync_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pedidos_sync_status ON public.pedidos USING btree (sync_status);


--
-- Name: idx_pedidos_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pedidos_tenant ON public.pedidos USING btree (tenant_id);


--
-- Name: idx_pedidos_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pedidos_tipo ON public.pedidos USING btree (tipo_pedido);


--
-- Name: idx_productos_categoria; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_categoria ON public.productos USING btree (categoria);


--
-- Name: idx_productos_codigo_barras; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_codigo_barras ON public.productos USING btree (codigo_barras);


--
-- Name: idx_productos_marca_supabase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_marca_supabase_id ON public.productos USING btree (marca_supabase_id);


--
-- Name: idx_productos_permite_mayor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_permite_mayor ON public.productos USING btree (tenant_id) WHERE (permite_venta_mayor = true);


--
-- Name: idx_productos_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_productos_tenant ON public.productos USING btree (tenant_id);


--
-- Name: idx_proveedores_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_proveedores_tenant ON public.proveedores USING btree (tenant_id);


--
-- Name: idx_recepciones_pedido_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recepciones_pedido_id ON public.recepciones USING btree (pedido_id);


--
-- Name: idx_recepciones_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recepciones_tenant ON public.recepciones USING btree (tenant_id);


--
-- Name: idx_telegram_config_chat_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_telegram_config_chat_id ON public.telegram_config USING btree (chat_id) WHERE (chat_id IS NOT NULL);


--
-- Name: idx_telegram_config_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_telegram_config_enabled ON public.telegram_config USING btree (enabled);


--
-- Name: idx_telegram_config_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_telegram_config_id_isar ON public.telegram_config USING btree (id_isar);


--
-- Name: idx_telegram_config_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_telegram_config_tenant ON public.telegram_config USING btree (tenant_id);


--
-- Name: idx_telegram_config_tenant_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_telegram_config_tenant_enabled ON public.telegram_config USING btree (tenant_id, enabled) WHERE (enabled = true);


--
-- Name: idx_telegram_config_usuario_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_telegram_config_usuario_id ON public.telegram_config USING btree (usuario_id);


--
-- Name: idx_turno_cajas_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_turno_cajas_estado ON public.turnos USING btree (estado);


--
-- Name: idx_turno_cajas_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_turno_cajas_id_isar ON public.turnos USING btree (id_isar);


--
-- Name: idx_turno_cajas_sync_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_turno_cajas_sync_status ON public.turnos USING btree (sync_status);


--
-- Name: idx_turnos_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_turnos_tenant ON public.turnos USING btree (tenant_id);


--
-- Name: idx_usuarios_documento_global; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_usuarios_documento_global ON public.usuarios USING btree (tipo_documento, numero_documento) WHERE ((tipo_documento IS NOT NULL) AND (numero_documento IS NOT NULL));


--
-- Name: idx_usuarios_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_usuarios_id_isar ON public.usuarios USING btree (id_isar);


--
-- Name: idx_usuarios_locales_default_unico; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_usuarios_locales_default_unico ON public.usuarios_locales USING btree (usuario_id) WHERE (es_default = true);


--
-- Name: idx_usuarios_locales_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_locales_tenant ON public.usuarios_locales USING btree (tenant_id);


--
-- Name: idx_usuarios_locales_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_locales_usuario ON public.usuarios_locales USING btree (usuario_id);


--
-- Name: idx_usuarios_rol; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_rol ON public.usuarios USING btree (rol);


--
-- Name: idx_usuarios_supervisor; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_supervisor ON public.usuarios USING btree (supervisor_id);


--
-- Name: idx_usuarios_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_tenant ON public.usuarios USING btree (tenant_id);


--
-- Name: idx_ventas_cliente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_cliente ON public.ventas USING btree (cliente_id) WHERE (cliente_id IS NOT NULL);


--
-- Name: idx_ventas_cliente_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_cliente_id ON public.ventas USING btree (cliente_id);


--
-- Name: idx_ventas_empleado_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_empleado_id ON public.ventas USING btree (empleado_id);


--
-- Name: idx_ventas_tenant; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_tenant ON public.ventas USING btree (tenant_id);


--
-- Name: idx_ventas_tipo_venta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_tipo_venta ON public.ventas USING btree (tenant_id, tipo_venta);


--
-- Name: cajas audit_cajas; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_cajas AFTER INSERT OR DELETE OR UPDATE ON public.cajas FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: categorias audit_categorias; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_categorias AFTER INSERT OR DELETE OR UPDATE ON public.categorias FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: clientes audit_clientes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_clientes AFTER INSERT OR DELETE OR UPDATE ON public.clientes FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: gastos audit_gastos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_gastos AFTER INSERT OR DELETE OR UPDATE ON public.gastos FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: lotes audit_lotes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_lotes AFTER INSERT OR DELETE OR UPDATE ON public.lotes FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: marcas audit_marcas; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_marcas AFTER INSERT OR DELETE OR UPDATE ON public.marcas FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: pagos audit_pagos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_pagos AFTER INSERT OR DELETE OR UPDATE ON public.pagos FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: pedidos audit_pedidos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_pedidos AFTER INSERT OR DELETE OR UPDATE ON public.pedidos FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: productos audit_productos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_productos AFTER INSERT OR DELETE OR UPDATE ON public.productos FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: proveedores audit_proveedores; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_proveedores AFTER INSERT OR DELETE OR UPDATE ON public.proveedores FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: telegram_config audit_telegram_config; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_telegram_config AFTER INSERT OR DELETE OR UPDATE ON public.telegram_config FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: turnos audit_turnos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_turnos AFTER INSERT OR DELETE OR UPDATE ON public.turnos FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: usuarios audit_usuarios; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_usuarios AFTER INSERT OR DELETE OR UPDATE ON public.usuarios FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: ventas audit_ventas; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER audit_ventas AFTER INSERT OR DELETE OR UPDATE ON public.ventas FOR EACH ROW EXECUTE FUNCTION public.audit_trigger();


--
-- Name: telegram_config telegram_config_encrypt_trg; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER telegram_config_encrypt_trg BEFORE INSERT OR UPDATE ON public.telegram_config FOR EACH ROW EXECUTE FUNCTION public.telegram_config_encrypt_token();


--
-- Name: telegram_config telegram_config_sync_status_trg; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER telegram_config_sync_status_trg BEFORE INSERT OR UPDATE ON public.telegram_config FOR EACH ROW EXECUTE FUNCTION public.telegram_config_sync_status();


--
-- Name: lotes trigger_actualizar_stock; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_actualizar_stock AFTER INSERT OR DELETE OR UPDATE ON public.lotes FOR EACH ROW EXECUTE FUNCTION public.actualizar_stock_producto();


--
-- Name: gastos update_gastos_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_gastos_updated_at BEFORE UPDATE ON public.gastos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: marcas update_marcas_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_marcas_updated_at BEFORE UPDATE ON public.marcas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: productos update_productos_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_productos_updated_at BEFORE UPDATE ON public.productos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: telegram_config update_telegram_config_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_telegram_config_updated_at BEFORE UPDATE ON public.telegram_config FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: usuarios update_usuarios_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON public.usuarios FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: audit_log audit_log_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.locales(id);


--
-- Name: audit_log audit_log_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audit_log
    ADD CONSTRAINT audit_log_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id);


--
-- Name: autorizaciones_descuento autorizaciones_descuento_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autorizaciones_descuento
    ADD CONSTRAINT autorizaciones_descuento_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: autorizaciones_descuento autorizaciones_descuento_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autorizaciones_descuento
    ADD CONSTRAINT autorizaciones_descuento_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id) ON DELETE CASCADE;


--
-- Name: cajas cajas_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: categorias categorias_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: clientes clientes_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: codigos_barras_alias codigos_barras_alias_producto_id_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codigos_barras_alias
    ADD CONSTRAINT codigos_barras_alias_producto_id_fk_fkey FOREIGN KEY (producto_id_fk) REFERENCES public.productos(id) ON DELETE CASCADE;


--
-- Name: codigos_barras_alias codigos_barras_alias_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codigos_barras_alias
    ADD CONSTRAINT codigos_barras_alias_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: config_descuentos_mayoristas config_descuentos_mayoristas_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.config_descuentos_mayoristas
    ADD CONSTRAINT config_descuentos_mayoristas_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: cotizaciones_mayor cotizaciones_mayor_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cotizaciones_mayor
    ADD CONSTRAINT cotizaciones_mayor_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE SET NULL;


--
-- Name: cotizaciones_mayor cotizaciones_mayor_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cotizaciones_mayor
    ADD CONSTRAINT cotizaciones_mayor_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: cotizaciones_mayor cotizaciones_mayor_venta_convertida_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cotizaciones_mayor
    ADD CONSTRAINT cotizaciones_mayor_venta_convertida_id_fkey FOREIGN KEY (venta_convertida_id) REFERENCES public.ventas(id) ON DELETE SET NULL;


--
-- Name: departamentos departamentos_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: detalle_ventas detalle_ventas_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_ventas
    ADD CONSTRAINT detalle_ventas_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: detalle_ventas detalle_ventas_venta_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_ventas
    ADD CONSTRAINT detalle_ventas_venta_tenant_fk FOREIGN KEY (venta_id_tk, tenant_id) REFERENCES public.ventas(id, tenant_id) ON DELETE CASCADE;


--
-- Name: detalles_pedido detalles_pedido_pedido_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalles_pedido
    ADD CONSTRAINT detalles_pedido_pedido_tenant_fk FOREIGN KEY (pedido_id, tenant_id) REFERENCES public.pedidos(id, tenant_id) ON DELETE CASCADE;


--
-- Name: detalles_pedido detalles_pedido_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalles_pedido
    ADD CONSTRAINT detalles_pedido_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: entregas entregas_pedido_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entregas
    ADD CONSTRAINT entregas_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos(id) ON DELETE CASCADE;


--
-- Name: entregas entregas_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entregas
    ADD CONSTRAINT entregas_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: detalles_pedido fk_detalles_pedido_producto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalles_pedido
    ADD CONSTRAINT fk_detalles_pedido_producto FOREIGN KEY (producto_id) REFERENCES public.productos(id);


--
-- Name: detalles_pedido fk_detalles_pedido_producto_id_isar; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalles_pedido
    ADD CONSTRAINT fk_detalles_pedido_producto_id_isar FOREIGN KEY (producto_id_isar) REFERENCES public.productos(id_isar);


--
-- Name: entregas fk_entregas_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entregas
    ADD CONSTRAINT fk_entregas_usuario FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id);


--
-- Name: gastos fk_gastos_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gastos
    ADD CONSTRAINT fk_gastos_usuario FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id);


--
-- Name: productos fk_productos_marca_supabase_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT fk_productos_marca_supabase_id FOREIGN KEY (marca_supabase_id) REFERENCES public.marcas(id) ON DELETE SET NULL;


--
-- Name: ventas fk_ventas_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT fk_ventas_usuario FOREIGN KEY (empleado_id) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: gastos gastos_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gastos
    ADD CONSTRAINT gastos_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: lotes lotes_producto_id_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_producto_id_fk_fkey FOREIGN KEY (producto_id_fk) REFERENCES public.productos(id_isar) ON DELETE SET NULL;


--
-- Name: lotes lotes_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: marcas marcas_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(id) ON DELETE SET NULL;


--
-- Name: marcas marcas_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: movimientos_inventarios movimientos_inventarios_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimientos_inventarios
    ADD CONSTRAINT movimientos_inventarios_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: pagos pagos_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: pagos pagos_venta_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT pagos_venta_tenant_fk FOREIGN KEY (venta_id, tenant_id) REFERENCES public.ventas(id, tenant_id) ON DELETE CASCADE;


--
-- Name: pagos_venta pagos_venta_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagos_venta
    ADD CONSTRAINT pagos_venta_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: pagos_venta pagos_venta_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagos_venta
    ADD CONSTRAINT pagos_venta_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id) ON DELETE CASCADE;


--
-- Name: pagos_ventas pagos_ventas_venta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagos_ventas
    ADD CONSTRAINT pagos_ventas_venta_id_fkey FOREIGN KEY (venta_id) REFERENCES public.ventas(id) ON DELETE CASCADE;


--
-- Name: pedidos pedidos_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: productos productos_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(id) ON DELETE SET NULL;


--
-- Name: productos productos_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: proveedores proveedores_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.proveedores
    ADD CONSTRAINT proveedores_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: recepciones recepciones_pedido_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recepciones
    ADD CONSTRAINT recepciones_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos(id) ON DELETE CASCADE;


--
-- Name: recepciones recepciones_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recepciones
    ADD CONSTRAINT recepciones_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: telegram_config telegram_config_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_config
    ADD CONSTRAINT telegram_config_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: turnos turno_cajas_caja_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turnos
    ADD CONSTRAINT turno_cajas_caja_id_fkey FOREIGN KEY (caja_id) REFERENCES public.cajas(id) ON DELETE CASCADE;


--
-- Name: turnos turno_cajas_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turnos
    ADD CONSTRAINT turno_cajas_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE RESTRICT;


--
-- Name: turnos turnos_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turnos
    ADD CONSTRAINT turnos_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: usuarios usuarios_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: usuarios_locales usuarios_locales_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios_locales
    ADD CONSTRAINT usuarios_locales_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: usuarios_locales usuarios_locales_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios_locales
    ADD CONSTRAINT usuarios_locales_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuarios(id) ON DELETE CASCADE;


--
-- Name: usuarios usuarios_supervisor_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_supervisor_fk FOREIGN KEY (supervisor_id) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: usuarios usuarios_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: ventas ventas_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE SET NULL;


--
-- Name: ventas ventas_tenant_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_tenant_fk FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: usuarios_locales Permitir lectura a auth_admin para hook; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir lectura a auth_admin para hook" ON public.usuarios_locales FOR SELECT TO supabase_auth_admin USING (true);


--
-- Name: audit_log; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.audit_log ENABLE ROW LEVEL SECURITY;

--
-- Name: audit_log audit_no_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY audit_no_delete ON public.audit_log FOR DELETE TO authenticated USING (false);


--
-- Name: audit_log audit_no_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY audit_no_update ON public.audit_log FOR UPDATE TO authenticated USING (false);


--
-- Name: audit_log audit_tenant_read; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY audit_tenant_read ON public.audit_log FOR SELECT TO authenticated USING (((tenant_id = public.current_tenant_id()) AND public.is_tenant_admin()));


--
-- Name: usuarios auth_admin_read_usuarios; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY auth_admin_read_usuarios ON public.usuarios FOR SELECT TO supabase_auth_admin USING (true);


--
-- Name: autorizaciones_descuento; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.autorizaciones_descuento ENABLE ROW LEVEL SECURITY;

--
-- Name: autorizaciones_descuento autorizaciones_descuento_tenant_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY autorizaciones_descuento_tenant_all ON public.autorizaciones_descuento USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: cajas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cajas ENABLE ROW LEVEL SECURITY;

--
-- Name: categorias; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.categorias ENABLE ROW LEVEL SECURITY;

--
-- Name: clientes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.clientes ENABLE ROW LEVEL SECURITY;

--
-- Name: codigos_barras_alias; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.codigos_barras_alias ENABLE ROW LEVEL SECURITY;

--
-- Name: config_descuentos_mayoristas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.config_descuentos_mayoristas ENABLE ROW LEVEL SECURITY;

--
-- Name: cotizaciones_mayor; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.cotizaciones_mayor ENABLE ROW LEVEL SECURITY;

--
-- Name: departamentos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.departamentos ENABLE ROW LEVEL SECURITY;

--
-- Name: detalle_ventas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.detalle_ventas ENABLE ROW LEVEL SECURITY;

--
-- Name: detalles_pedido; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.detalles_pedido ENABLE ROW LEVEL SECURITY;

--
-- Name: entregas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.entregas ENABLE ROW LEVEL SECURITY;

--
-- Name: gastos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.gastos ENABLE ROW LEVEL SECURITY;

--
-- Name: locales; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.locales ENABLE ROW LEVEL SECURITY;

--
-- Name: locales locales_tenant_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY locales_tenant_select ON public.locales FOR SELECT TO authenticated USING (((id = public.current_tenant_id()) OR (EXISTS ( SELECT 1
   FROM public.usuarios_locales ul
  WHERE ((ul.usuario_id = auth.uid()) AND (ul.tenant_id = locales.id) AND (ul.activo = true))))));


--
-- Name: locales locales_tenant_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY locales_tenant_update ON public.locales FOR UPDATE TO authenticated USING ((id = public.current_tenant_id())) WITH CHECK ((id = public.current_tenant_id()));


--
-- Name: lotes; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.lotes ENABLE ROW LEVEL SECURITY;

--
-- Name: marcas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.marcas ENABLE ROW LEVEL SECURITY;

--
-- Name: movimientos_inventarios; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.movimientos_inventarios ENABLE ROW LEVEL SECURITY;

--
-- Name: pagos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.pagos ENABLE ROW LEVEL SECURITY;

--
-- Name: pagos_venta; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.pagos_venta ENABLE ROW LEVEL SECURITY;

--
-- Name: pagos_ventas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.pagos_ventas ENABLE ROW LEVEL SECURITY;

--
-- Name: pagos_ventas pagos_ventas_tenant_all; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY pagos_ventas_tenant_all ON public.pagos_ventas USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: pedidos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.pedidos ENABLE ROW LEVEL SECURITY;

--
-- Name: productos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.productos ENABLE ROW LEVEL SECURITY;

--
-- Name: proveedores; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.proveedores ENABLE ROW LEVEL SECURITY;

--
-- Name: recepciones; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.recepciones ENABLE ROW LEVEL SECURITY;

--
-- Name: telegram_config; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.telegram_config ENABLE ROW LEVEL SECURITY;

--
-- Name: telegram_config telegram_config_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY telegram_config_delete ON public.telegram_config FOR DELETE TO authenticated USING (((tenant_id = public.current_user_tenant_id()) AND public.has_any_role(ARRAY['admin'::text])));


--
-- Name: telegram_config telegram_config_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY telegram_config_insert ON public.telegram_config FOR INSERT TO authenticated WITH CHECK (((tenant_id = public.current_user_tenant_id()) AND public.has_any_role(ARRAY['admin'::text, 'supervisor'::text])));


--
-- Name: telegram_config telegram_config_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY telegram_config_select ON public.telegram_config FOR SELECT TO authenticated USING (((tenant_id = public.current_user_tenant_id()) AND (public.has_any_role(ARRAY['admin'::text, 'supervisor'::text, 'auditor'::text, 'dev'::text]) OR (EXISTS ( SELECT 1
   FROM public.usuarios u
  WHERE ((u.id = auth.uid()) AND (u.id_isar IS NOT NULL) AND (u.id_isar = telegram_config.usuario_id)))))));


--
-- Name: telegram_config telegram_config_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY telegram_config_update ON public.telegram_config FOR UPDATE TO authenticated USING (((tenant_id = public.current_user_tenant_id()) AND public.has_any_role(ARRAY['admin'::text, 'supervisor'::text]))) WITH CHECK (((tenant_id = public.current_user_tenant_id()) AND public.has_any_role(ARRAY['admin'::text, 'supervisor'::text])));


--
-- Name: autorizaciones_descuento tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.autorizaciones_descuento TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: cajas tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.cajas TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: categorias tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.categorias TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: clientes tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.clientes TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: codigos_barras_alias tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.codigos_barras_alias TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: config_descuentos_mayoristas tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.config_descuentos_mayoristas TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: cotizaciones_mayor tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.cotizaciones_mayor TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: departamentos tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.departamentos TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: detalle_ventas tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.detalle_ventas TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: detalles_pedido tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.detalles_pedido TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: entregas tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.entregas TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: gastos tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.gastos TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: lotes tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.lotes TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: marcas tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.marcas TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: movimientos_inventarios tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.movimientos_inventarios TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: pagos tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.pagos TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: pagos_venta tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.pagos_venta TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: pedidos tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.pedidos TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: productos tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.productos TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: proveedores tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.proveedores TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: recepciones tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.recepciones TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: telegram_config tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.telegram_config AS RESTRICTIVE TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: turnos tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.turnos TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: ventas tenant_isolation; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY tenant_isolation ON public.ventas TO authenticated USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: turnos; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.turnos ENABLE ROW LEVEL SECURITY;

--
-- Name: usuarios; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.usuarios ENABLE ROW LEVEL SECURITY;

--
-- Name: usuarios_locales; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.usuarios_locales ENABLE ROW LEVEL SECURITY;

--
-- Name: usuarios_locales usuarios_locales_admin; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY usuarios_locales_admin ON public.usuarios_locales TO authenticated USING (((tenant_id = public.current_tenant_id()) AND public.is_tenant_admin())) WITH CHECK (((tenant_id = public.current_tenant_id()) AND public.is_tenant_admin()));


--
-- Name: usuarios_locales usuarios_locales_self; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY usuarios_locales_self ON public.usuarios_locales FOR SELECT TO authenticated USING ((usuario_id = auth.uid()));


--
-- Name: usuarios usuarios_self_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY usuarios_self_select ON public.usuarios FOR SELECT USING ((id = auth.uid()));


--
-- Name: usuarios usuarios_tenant_delete; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY usuarios_tenant_delete ON public.usuarios FOR DELETE USING ((tenant_id = public.current_tenant_id()));


--
-- Name: usuarios usuarios_tenant_insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY usuarios_tenant_insert ON public.usuarios FOR INSERT WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: usuarios usuarios_tenant_select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY usuarios_tenant_select ON public.usuarios FOR SELECT USING ((tenant_id = public.current_tenant_id()));


--
-- Name: usuarios usuarios_tenant_update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY usuarios_tenant_update ON public.usuarios FOR UPDATE USING ((tenant_id = public.current_tenant_id())) WITH CHECK ((tenant_id = public.current_tenant_id()));


--
-- Name: ventas; Type: ROW SECURITY; Schema: public; Owner: -
--

ALTER TABLE public.ventas ENABLE ROW LEVEL SECURITY;

--
-- PostgreSQL database dump complete
--

\unrestrict wVPHaBD7Rq7nRoQXezFTM5K6rN2Cy20kcz4w2Wt9XbJCfyj9zeodRpAD7qB1SYD

