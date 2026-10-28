-- ============================================================
-- R.1c · Comandas y KDS multi-dispositivo (restaurante).
--
-- Hasta acá las comandas vivían SOLO en Isar
-- (`cart_session_entity.dart`). El desktop abría la mesa 1 y el teléfono
-- no la veía. Este esquema las lleva a Supabase.
--
-- Decisiones:
--
--   · `sync_key` es la identidad de sync, NO `id_isar`.
--     `id_isar` es el id de Isar del dispositivo que la creó: dos
--     dispositivos pueden tener el mismo número apuntando a filas
--     distintas. `sync_key` es un UUID que se genera en el primer push y
--     no cambia nunca. La unicidad es `(tenant_id, sync_key)`.
--
--   · `session_id` NO se sube. En Isar vale `mesa:<idIsar>`, que es
--     específico del dispositivo. La identidad de negocio es la MESA.
--
--   · Una sola comanda VIVA por mesa y tenant: índice único parcial
--     sobre `(tenant_id, mesa_id)` limitado a `abierta`/`enviada`. Si dos
--     cajas abren la misma mesa, la segunda recibe 23505 y su comanda se
--     degrada a histórico local en vez de duplicar la mesa ocupada.
--
--   · Los ítems van como JSONB (`items`): `CartSessionItem` es
--     `@embedded`, sin id propio ni colección. Se serializan a un array
--     de objetos con `producto_id` (UUID de Supabase) y `estacion_id`
--     (UUID de `departamentos`); el id LOCAL de Isar se resuelve al bajar.
--
--   · El ESTADO operativo de la mesa NO se guarda en `mesas`: se deriva
--     de las comandas vivas (una sola fuente de verdad).
--
-- Multi-tenant: `locales.id` ES el `tenant_id` (AGENTS §7.4). RLS por
-- `tenant_id = current_tenant_id()` en USING y WITH CHECK.
--
-- ⚠️ Orden correcto (regla de AGENTS.MD):
--   1. Correr este SQL en el SQL Editor.
--   2. Verificar con la query del final.
--   3. Recién ahí:
--      supabase migration repair --status applied 20261028000003
--
-- Idempotente: IF NOT EXISTS en tablas/índices, DROP POLICY/TRIGGER IF
-- EXISTS antes de cada CREATE.
-- ============================================================

CREATE TABLE IF NOT EXISTS public.comandas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,

    -- Identidad de sync (UUID generado por el cliente).
    sync_key text NOT NULL,

    -- Id local de Isar. Solo para depurar; NO es único.
    id_isar bigint,

    mesa_id uuid,
    mesa_nombre text,
    nombre text DEFAULT 'Comanda'::text NOT NULL,

    -- 'abierta' | 'enviada' | 'cerrada' | 'cancelada'
    estado text DEFAULT 'abierta'::text NOT NULL,

    -- Array JSON con las líneas de la comanda.
    items jsonb DEFAULT '[]'::jsonb NOT NULL,

    comensales integer DEFAULT 1 NOT NULL,
    mesero_nombre text,
    notas text,
    total numeric(12, 2) DEFAULT 0 NOT NULL,

    enviada_cocina_at timestamp with time zone,
    cerrada_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    sync_status text DEFAULT 'synced'::text,
    sincronizado boolean DEFAULT false,
    fecha_sincronizacion timestamp with time zone,

    CONSTRAINT comandas_pkey PRIMARY KEY (id),
    CONSTRAINT comandas_tenant_sync_key_unique UNIQUE (tenant_id, sync_key),
    CONSTRAINT comandas_estado_check CHECK (
        estado = ANY (ARRAY['abierta'::text, 'enviada'::text,
                            'cerrada'::text, 'cancelada'::text])
    ),
    CONSTRAINT comandas_comensales_check CHECK (comensales >= 1),
    CONSTRAINT comandas_items_check CHECK (jsonb_typeof(items) = 'array'::text),
    CONSTRAINT comandas_tenant_fk FOREIGN KEY (tenant_id)
        REFERENCES public.locales(id) ON DELETE CASCADE,
    CONSTRAINT comandas_mesa_fk FOREIGN KEY (mesa_id)
        REFERENCES public.mesas(id) ON DELETE SET NULL
);

-- Una sola comanda viva por mesa. Un cierre o una cancelación liberan la
-- mesa sin borrar el histórico.
CREATE UNIQUE INDEX IF NOT EXISTS comandas_tenant_mesa_viva_unique
    ON public.comandas (tenant_id, mesa_id)
    WHERE estado = ANY (ARRAY['abierta'::text, 'enviada'::text])
      AND mesa_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_comandas_tenant
    ON public.comandas USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_comandas_mesa
    ON public.comandas USING btree (mesa_id);
CREATE INDEX IF NOT EXISTS idx_comandas_estado
    ON public.comandas USING btree (tenant_id, estado);
CREATE INDEX IF NOT EXISTS idx_comandas_updated
    ON public.comandas USING btree (tenant_id, updated_at DESC);

ALTER TABLE public.comandas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tenant_isolation ON public.comandas;
CREATE POLICY tenant_isolation ON public.comandas
    TO authenticated
    USING ((tenant_id = public.current_tenant_id()))
    WITH CHECK ((tenant_id = public.current_tenant_id()));

DROP TRIGGER IF EXISTS update_comandas_updated_at ON public.comandas;
CREATE TRIGGER update_comandas_updated_at
    BEFORE UPDATE ON public.comandas
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ────────────────────────────────────────────────────────────
-- REALTIME
--
-- Sin esto el segundo dispositivo solo vería la comanda en el próximo
-- sync manual, no cuando el mesero la envía a cocina.
-- ────────────────────────────────────────────────────────────

DO $guard$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime'
        AND schemaname = 'public'
        AND tablename = 'comandas'
    ) THEN
      EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.comandas';
    END IF;
  END IF;
END
$guard$;

-- ────────────────────────────────────────────────────────────
-- VERIFICACIÓN (correr aparte después del SQL)
-- ────────────────────────────────────────────────────────────
--
-- SELECT tablename, policyname, cmd, qual, with_check
--   FROM pg_policies
--  WHERE schemaname = 'public' AND tablename = 'comandas';
--
-- SELECT relname, relrowsecurity
--   FROM pg_class WHERE relname = 'comandas';
--
-- SELECT indexname, indexdef
--   FROM pg_indexes WHERE tablename = 'comandas';
--
-- SELECT tablename FROM pg_publication_tables
--  WHERE pubname = 'supabase_realtime' AND tablename = 'comandas';
