-- ============================================================
-- R.1b · Persistencia real de zonas y mesas (restaurante).
--
-- Hasta hoy:
--   · Las zonas eran el enum `MesaZona` (5 valores fijos, hardcodeados).
--   · Las mesas vivían SOLO en Isar (`mesa_entity.dart`), sin tabla ni
--     sync. El teléfono no veía las mesas del desktop.
--
-- Este esquema agrega:
--   · `zonas`  → zonas editables por tenant (Salón, Terraza, Patio…).
--   · `mesas`  → configuración de la mesa (nombre, zona, capacidad,
--                orden, unión). El ESTADO operativo (libre/ocupada) NO
--                se guarda acá: se deriva de las comandas vivas para
--                tener una sola fuente de verdad entre dispositivos.
--
-- Multi-tenant: `locales.id` ES el `tenant_id` (AGENTS §7.4). RLS por
-- `tenant_id = current_tenant_id()` en USING y WITH CHECK.
--
-- ⚠️ NO copiar el patrón `UNIQUE (id_isar)` del baseline: es global y
--    colisiona entre tenants. Acá la unicidad es compuesta con
--    `tenant_id`.
--
-- ⚠️ Orden correcto (regla de AGENTS.MD):
--   1. Correr este SQL en el SQL Editor.
--   2. Verificar con la query del final.
--   3. Recién ahí:
--      supabase migration repair --status applied 20261028000002
--
-- Idempotente: IF NOT EXISTS en tablas/índices, DROP POLICY/TRIGGER IF
-- EXISTS antes de cada CREATE.
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. ZONAS
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.zonas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    nombre text NOT NULL,
    orden integer DEFAULT 0 NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    id_isar integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    sync_status text DEFAULT 'synced'::text,
    sincronizado boolean DEFAULT false,
    fecha_sincronizacion timestamp with time zone,
    eliminado boolean DEFAULT false NOT NULL,
    CONSTRAINT zonas_pkey PRIMARY KEY (id),
    CONSTRAINT zonas_tenant_id_isar_unique UNIQUE (tenant_id, id_isar),
    CONSTRAINT zonas_tenant_fk FOREIGN KEY (tenant_id)
        REFERENCES public.locales(id) ON DELETE CASCADE
);

-- Unicidad por nombre SOLO entre zonas vivas. Un borrado lógico no debe
-- impedir volver a crear una zona con el mismo nombre.
CREATE UNIQUE INDEX IF NOT EXISTS zonas_tenant_nombre_vivo_unique
    ON public.zonas (tenant_id, nombre)
    WHERE eliminado = false;

CREATE INDEX IF NOT EXISTS idx_zonas_tenant ON public.zonas USING btree (tenant_id);

ALTER TABLE public.zonas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tenant_isolation ON public.zonas;
CREATE POLICY tenant_isolation ON public.zonas
    TO authenticated
    USING ((tenant_id = public.current_tenant_id()))
    WITH CHECK ((tenant_id = public.current_tenant_id()));

DROP TRIGGER IF EXISTS update_zonas_updated_at ON public.zonas;
CREATE TRIGGER update_zonas_updated_at
    BEFORE UPDATE ON public.zonas
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ────────────────────────────────────────────────────────────
-- 2. MESAS
-- ────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.mesas (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id uuid DEFAULT public.current_tenant_id() NOT NULL,
    zona_id uuid,
    zona_nombre text DEFAULT ''::text NOT NULL,
    nombre text NOT NULL,
    capacidad integer DEFAULT 4 NOT NULL,
    orden_grid integer DEFAULT 0 NOT NULL,
    unida_con_mesa_id uuid,
    id_isar integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    sync_status text DEFAULT 'synced'::text,
    sincronizado boolean DEFAULT false,
    fecha_sincronizacion timestamp with time zone,
    eliminado boolean DEFAULT false NOT NULL,
    CONSTRAINT mesas_pkey PRIMARY KEY (id),
    CONSTRAINT mesas_tenant_id_isar_unique UNIQUE (tenant_id, id_isar),
    CONSTRAINT mesas_capacidad_check CHECK ((capacidad >= 1) AND (capacidad <= 50)),
    CONSTRAINT mesas_tenant_fk FOREIGN KEY (tenant_id)
        REFERENCES public.locales(id) ON DELETE CASCADE,
    CONSTRAINT mesas_zona_fk FOREIGN KEY (zona_id)
        REFERENCES public.zonas(id) ON DELETE SET NULL,
    CONSTRAINT mesas_unida_fk FOREIGN KEY (unida_con_mesa_id)
        REFERENCES public.mesas(id) ON DELETE SET NULL
);

CREATE UNIQUE INDEX IF NOT EXISTS mesas_tenant_nombre_vivo_unique
    ON public.mesas (tenant_id, nombre)
    WHERE eliminado = false;

CREATE INDEX IF NOT EXISTS idx_mesas_tenant ON public.mesas USING btree (tenant_id);
CREATE INDEX IF NOT EXISTS idx_mesas_zona ON public.mesas USING btree (zona_id);

ALTER TABLE public.mesas ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS tenant_isolation ON public.mesas;
CREATE POLICY tenant_isolation ON public.mesas
    TO authenticated
    USING ((tenant_id = public.current_tenant_id()))
    WITH CHECK ((tenant_id = public.current_tenant_id()));

DROP TRIGGER IF EXISTS update_mesas_updated_at ON public.mesas;
CREATE TRIGGER update_mesas_updated_at
    BEFORE UPDATE ON public.mesas
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();

-- ────────────────────────────────────────────────────────────
-- 3. REALTIME
--
-- Las tablas nuevas no entran solas a la publicación. Sin esto, el
-- segundo dispositivo solo vería los cambios en el próximo sync
-- manual, no al instante.
-- ────────────────────────────────────────────────────────────

DO $guard$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime'
        AND schemaname = 'public'
        AND tablename = 'zonas'
    ) THEN
      EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.zonas';
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM pg_publication_tables
      WHERE pubname = 'supabase_realtime'
        AND schemaname = 'public'
        AND tablename = 'mesas'
    ) THEN
      EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE public.mesas';
    END IF;
  END IF;
END
$guard$;

-- ────────────────────────────────────────────────────────────
-- 4. VERIFICACIÓN (correr aparte después del SQL)
-- ────────────────────────────────────────────────────────────
--
-- SELECT tablename, policyname, cmd, qual, with_check
--   FROM pg_policies
--  WHERE schemaname = 'public' AND tablename IN ('zonas', 'mesas')
--  ORDER BY tablename, policyname;
--
-- SELECT relname, relrowsecurity
--   FROM pg_class
--  WHERE relname IN ('zonas', 'mesas');
--
-- SELECT tablename FROM pg_publication_tables
--  WHERE pubname = 'supabase_realtime'
--    AND tablename IN ('zonas', 'mesas');
