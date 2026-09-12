--
-- PostgreSQL database dump
--

\restrict ucHayyfqVAcBCpN4wk401zzfr137Rl9EfUS3umDqasVodKpHNoYp4cbcXaTTR0O

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
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO public.usuarios (id, nombre, rol, pin, email, estado)
  VALUES (
    NEW.id,
    NEW.raw_user_meta_data->>'nombre',
    NEW.raw_user_meta_data->>'rol',
    NEW.raw_user_meta_data->>'pin',
    NEW.email,
    'inactivo'
  );
  RETURN NEW;
END;
$$;


--
-- Name: is_admin(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.is_admin() RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.usuarios
    WHERE id = auth.uid() AND LOWER(rol) = 'admin'
  );
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
-- Name: cajas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cajas (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    nombre character varying(50) NOT NULL,
    estado public.estado_caja DEFAULT 'cerrada'::public.estado_caja,
    creado_en timestamp with time zone DEFAULT now()
);


--
-- Name: categorias; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categorias (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    creado_en timestamp with time zone DEFAULT now()
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
    local_id uuid,
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
    updated_at timestamp with time zone DEFAULT now()
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
    fecha_sincronizacion timestamp without time zone
);


--
-- Name: departamentos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departamentos (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    local_id uuid,
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
    producto_id bigint
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
    id_isar bigint
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
    updated_at timestamp with time zone DEFAULT now()
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
    proveedor_nombre text
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
    updated_at timestamp with time zone DEFAULT now()
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
    sync_status text DEFAULT 'pending'::text
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
    venta_id uuid
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
    local_destino_id uuid,
    proveedor_nombre text,
    proveedor_telefono text,
    usuario_id uuid,
    local_id bigint,
    id_isar bigint,
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
    activo boolean DEFAULT true
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
    id_isar integer
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
    CONSTRAINT recepciones_estado_recepcion_check CHECK ((estado_recepcion = ANY (ARRAY['completa'::text, 'parcial'::text, 'pendiente'::text])))
);


--
-- Name: telegram_config; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.telegram_config (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bot_token text NOT NULL,
    chat_id text NOT NULL,
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
    usuario_id integer
);


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
    usuario_nombre text
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
    local_id bigint
);

ALTER TABLE ONLY public.usuarios REPLICA IDENTITY FULL;


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
    monto_descuento_total numeric(12,2) DEFAULT 0.00
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
-- Name: cajas cajas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cajas
    ADD CONSTRAINT cajas_pkey PRIMARY KEY (id);


--
-- Name: categorias categorias_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categorias
    ADD CONSTRAINT categorias_nombre_key UNIQUE (nombre);


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
-- Name: codigos_barras_alias codigos_barras_alias_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codigos_barras_alias
    ADD CONSTRAINT codigos_barras_alias_codigo_key UNIQUE (codigo);


--
-- Name: codigos_barras_alias codigos_barras_alias_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codigos_barras_alias
    ADD CONSTRAINT codigos_barras_alias_pkey PRIMARY KEY (id);


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
-- Name: gastos gastos_id_isar_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.gastos
    ADD CONSTRAINT gastos_id_isar_key UNIQUE (id_isar);


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
-- Name: locales locales_id_isar_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.locales
    ADD CONSTRAINT locales_id_isar_key UNIQUE (id_isar);


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
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id);


--
-- Name: productos productos_codigo_barras_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_codigo_barras_key UNIQUE (codigo_barras);


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
-- Name: telegram_config telegram_config_id_isar_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_config
    ADD CONSTRAINT telegram_config_id_isar_key UNIQUE (id_isar);


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
-- Name: telegram_config telegram_config_usuario_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.telegram_config
    ADD CONSTRAINT telegram_config_usuario_unique UNIQUE (usuario_id);


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
-- Name: usuarios usuarios_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_pkey PRIMARY KEY (id);


--
-- Name: ventas ventas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_pkey PRIMARY KEY (id);


--
-- Name: idx_clientes_documento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_documento ON public.clientes USING btree (documento);


--
-- Name: idx_clientes_local_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_local_id ON public.clientes USING btree (local_id);


--
-- Name: idx_clientes_telefono; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_clientes_telefono ON public.clientes USING btree (telefono);


--
-- Name: idx_codigos_barras_alias_codigo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_codigos_barras_alias_codigo ON public.codigos_barras_alias USING btree (codigo);


--
-- Name: idx_codigos_barras_alias_producto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_codigos_barras_alias_producto ON public.codigos_barras_alias USING btree (producto_id_fk);


--
-- Name: idx_departamentos_usuario_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_departamentos_usuario_id ON public.departamentos USING btree (usuario_id);


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
-- Name: idx_marcas_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marcas_nombre ON public.marcas USING btree (nombre);


--
-- Name: idx_pedidos_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pedidos_estado ON public.pedidos USING btree (estado);


--
-- Name: idx_pedidos_local_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pedidos_local_id ON public.pedidos USING btree (local_id);


--
-- Name: idx_pedidos_sync_status; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_pedidos_sync_status ON public.pedidos USING btree (sync_status);


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
-- Name: idx_recepciones_pedido_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recepciones_pedido_id ON public.recepciones USING btree (pedido_id);


--
-- Name: idx_telegram_config_enabled; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_telegram_config_enabled ON public.telegram_config USING btree (enabled);


--
-- Name: idx_telegram_config_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_telegram_config_id_isar ON public.telegram_config USING btree (id_isar);


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
-- Name: idx_usuarios_id_isar; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_usuarios_id_isar ON public.usuarios USING btree (id_isar);


--
-- Name: idx_usuarios_local_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuarios_local_id ON public.usuarios USING btree (local_id);


--
-- Name: idx_ventas_cliente_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_cliente_id ON public.ventas USING btree (cliente_id);


--
-- Name: idx_ventas_empleado_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ventas_empleado_id ON public.ventas USING btree (empleado_id);


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
-- Name: usuarios update_usuarios_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_usuarios_updated_at BEFORE UPDATE ON public.usuarios FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: clientes clientes_local_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.clientes
    ADD CONSTRAINT clientes_local_id_fkey FOREIGN KEY (local_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: codigos_barras_alias codigos_barras_alias_producto_id_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.codigos_barras_alias
    ADD CONSTRAINT codigos_barras_alias_producto_id_fk_fkey FOREIGN KEY (producto_id_fk) REFERENCES public.productos(id) ON DELETE CASCADE;


--
-- Name: departamentos departamentos_local_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamentos
    ADD CONSTRAINT departamentos_local_id_fkey FOREIGN KEY (local_id) REFERENCES public.locales(id) ON DELETE CASCADE;


--
-- Name: detalle_ventas detalle_ventas_venta_id_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_ventas
    ADD CONSTRAINT detalle_ventas_venta_id_fk_fkey FOREIGN KEY (venta_id_tk) REFERENCES public.ventas(id) ON DELETE CASCADE;


--
-- Name: detalles_pedido detalles_pedido_pedido_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalles_pedido
    ADD CONSTRAINT detalles_pedido_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos(id) ON DELETE CASCADE;


--
-- Name: entregas entregas_pedido_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entregas
    ADD CONSTRAINT entregas_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos(id) ON DELETE CASCADE;


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
-- Name: pagos fk_pagos_venta; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pagos
    ADD CONSTRAINT fk_pagos_venta FOREIGN KEY (venta_id) REFERENCES public.ventas(id) ON DELETE CASCADE;


--
-- Name: pedidos fk_pedidos_local_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_pedidos_local_id FOREIGN KEY (local_id) REFERENCES public.locales(id_isar) ON DELETE SET NULL;


--
-- Name: productos fk_productos_marca_supabase_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT fk_productos_marca_supabase_id FOREIGN KEY (marca_supabase_id) REFERENCES public.marcas(id) ON DELETE SET NULL;


--
-- Name: usuarios fk_usuarios_local_id; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT fk_usuarios_local_id FOREIGN KEY (local_id) REFERENCES public.locales(id_isar) ON DELETE SET NULL;


--
-- Name: ventas fk_ventas_usuario; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT fk_ventas_usuario FOREIGN KEY (empleado_id) REFERENCES public.usuarios(id) ON DELETE SET NULL;


--
-- Name: lotes lotes_producto_id_fk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lotes
    ADD CONSTRAINT lotes_producto_id_fk_fkey FOREIGN KEY (producto_id_fk) REFERENCES public.productos(id_isar) ON DELETE SET NULL;


--
-- Name: marcas marcas_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marcas
    ADD CONSTRAINT marcas_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(id) ON DELETE SET NULL;


--
-- Name: pedidos pedidos_local_destino_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_local_destino_id_fkey FOREIGN KEY (local_destino_id) REFERENCES public.locales(id);


--
-- Name: productos productos_proveedor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.productos
    ADD CONSTRAINT productos_proveedor_id_fkey FOREIGN KEY (proveedor_id) REFERENCES public.proveedores(id) ON DELETE SET NULL;


--
-- Name: recepciones recepciones_pedido_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recepciones
    ADD CONSTRAINT recepciones_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedidos(id) ON DELETE CASCADE;


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
-- Name: usuarios usuarios_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuarios
    ADD CONSTRAINT usuarios_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: ventas ventas_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ventas
    ADD CONSTRAINT ventas_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.clientes(id) ON DELETE SET NULL;


--
-- Name: categorias Admins pueden sincronizar/modificar categorias; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Admins pueden sincronizar/modificar categorias" ON public.categorias TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- Name: departamentos Departamentos: insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Departamentos: insert" ON public.departamentos FOR INSERT WITH CHECK (true);


--
-- Name: departamentos Departamentos: select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Departamentos: select" ON public.departamentos FOR SELECT USING (true);


--
-- Name: departamentos Departamentos: update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Departamentos: update" ON public.departamentos FOR UPDATE USING (true);


--
-- Name: turnos Enable inserts for authenticated users; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Enable inserts for authenticated users" ON public.turnos FOR INSERT WITH CHECK (true);


--
-- Name: categorias Lectura publica de categorias; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Lectura publica de categorias" ON public.categorias FOR SELECT USING (true);


--
-- Name: usuarios Lectura pública de datos básicos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Lectura pública de datos básicos" ON public.usuarios FOR SELECT USING (true);


--
-- Name: locales Locales: insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Locales: insert" ON public.locales FOR INSERT WITH CHECK (true);


--
-- Name: locales Locales: select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Locales: select" ON public.locales FOR SELECT USING (true);


--
-- Name: locales Locales: update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Locales: update" ON public.locales FOR UPDATE USING (true);


--
-- Name: usuarios Permitir actualización de estado; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir actualización de estado" ON public.usuarios FOR UPDATE USING (true) WITH CHECK (true);


--
-- Name: categorias Permitir escritura en categorias; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir escritura en categorias" ON public.categorias USING (true) WITH CHECK (true);


--
-- Name: detalle_ventas Permitir insercion detalle; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir insercion detalle" ON public.detalle_ventas FOR INSERT TO authenticated, anon WITH CHECK (true);


--
-- Name: ventas Permitir insercion ventas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir insercion ventas" ON public.ventas FOR INSERT TO authenticated, anon WITH CHECK (true);


--
-- Name: detalle_ventas Permitir lectura detalle; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir lectura detalle" ON public.detalle_ventas FOR SELECT TO authenticated, anon USING (true);


--
-- Name: ventas Permitir lectura ventas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir lectura ventas" ON public.ventas FOR SELECT TO authenticated, anon USING (true);


--
-- Name: telegram_config Permitir todas las operaciones desde la app; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir todas las operaciones desde la app" ON public.telegram_config USING (true) WITH CHECK (true);


--
-- Name: categorias Permitir todo en categorias; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir todo en categorias" ON public.categorias USING (true);


--
-- Name: productos Permitir todo en productos; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir todo en productos" ON public.productos USING (true);


--
-- Name: turnos Permitir todo en turno_cajas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Permitir todo en turno_cajas" ON public.turnos USING (true);


--
-- Name: departamentos Todos pueden todo; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Todos pueden todo" ON public.departamentos USING (true) WITH CHECK (true);


--
-- Name: marcas Usuarios autenticados pueden actualizar; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios autenticados pueden actualizar" ON public.marcas FOR UPDATE USING ((auth.role() = 'authenticated'::text));


--
-- Name: lotes Usuarios autenticados pueden actualizar lotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios autenticados pueden actualizar lotes" ON public.lotes FOR UPDATE TO authenticated USING (true) WITH CHECK (true);


--
-- Name: marcas Usuarios autenticados pueden eliminar; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios autenticados pueden eliminar" ON public.marcas FOR DELETE USING ((auth.role() = 'authenticated'::text));


--
-- Name: marcas Usuarios autenticados pueden insertar; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios autenticados pueden insertar" ON public.marcas FOR INSERT WITH CHECK ((auth.role() = 'authenticated'::text));


--
-- Name: lotes Usuarios autenticados pueden insertar lotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios autenticados pueden insertar lotes" ON public.lotes FOR INSERT TO authenticated WITH CHECK (true);


--
-- Name: marcas Usuarios autenticados pueden leer marcas; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios autenticados pueden leer marcas" ON public.marcas FOR SELECT USING ((auth.role() = 'authenticated'::text));


--
-- Name: lotes Usuarios autenticados pueden ver lotes; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios autenticados pueden ver lotes" ON public.lotes FOR SELECT TO authenticated USING (true);


--
-- Name: pedidos Usuarios pueden insertar pedidos en su local; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios pueden insertar pedidos en su local" ON public.pedidos FOR INSERT WITH CHECK ((local_id = ( SELECT usuarios.id_isar
   FROM public.usuarios
  WHERE (usuarios.id = auth.uid()))));


--
-- Name: usuarios Usuarios pueden ver su propio registro; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios pueden ver su propio registro" ON public.usuarios FOR SELECT TO authenticated USING ((auth.uid() = id));


--
-- Name: pedidos Usuarios solo ven pedidos de su local; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios solo ven pedidos de su local" ON public.pedidos FOR SELECT USING ((local_id = ( SELECT usuarios.id_isar
   FROM public.usuarios
  WHERE (usuarios.id = auth.uid()))));


--
-- Name: usuarios Usuarios: insert; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios: insert" ON public.usuarios FOR INSERT WITH CHECK (true);


--
-- Name: usuarios Usuarios: select; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios: select" ON public.usuarios FOR SELECT USING (true);


--
-- Name: usuarios Usuarios: update; Type: POLICY; Schema: public; Owner: -
--

CREATE POLICY "Usuarios: update" ON public.usuarios FOR UPDATE USING (true);


--
-- PostgreSQL database dump complete
--

\unrestrict ucHayyfqVAcBCpN4wk401zzfr137Rl9EfUS3umDqasVodKpHNoYp4cbcXaTTR0O

