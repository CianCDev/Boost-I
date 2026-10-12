-- ═══════════════════════════════════════════════════════════════
-- Crea la tabla movimientos_lotes, que faltaba en el baseline.
--
-- ⚠️ ESTA TABLA YA EXISTE EN EL REMOTO. Este archivo la versiona para que
--    otros entornos (dev, staging) la obtengan al aplicar migraciones.
--    Alinear el tracking local con:
--        supabase migration repair --status applied 20261010000001
--
-- Incluye stock_antes y stock_despues: campos de auditoría del fix EDIT-
-- (el clamp de Opción A en `ajustarStockDesdeEditor`).
--
-- Mapeo contra `MovimientoLoteEntity` (Isar), 9 campos + 2 de auditoría:
--   Isar                  →  Supabase
--   id (autoIncrement)    →  id_isar          (id uuid es el PK remoto)
--   loteId                →  lote_id_isar
--   tipo                  →  tipo
--   cantidad              →  cantidad
--   fecha                 →  fecha
--   usuarioId             →  usuario_id
--   observaciones         →  observaciones
--   stockAntes            →  stock_antes
--   stockDespues          →  stock_despues
--   sincronizado          →  sincronizado
--   fechaSincronizacion   →  fecha_sincronizacion
--   (no existe en Isar)   →  tenant_id       ← lo llena current_tenant_id()
--
-- `tenant_id` no tiene columna en Isar a propósito: el tenant se resuelve
-- en el server. Si el cliente lo mandara, un hot-switch de local a mitad
-- del sync escribiría movimientos en el tenant equivocado.
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE public.movimientos_lotes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_isar bigint NOT NULL,
  lote_id_isar bigint NOT NULL,
  tipo text NOT NULL,
  cantidad numeric NOT NULL,
  fecha timestamp with time zone NOT NULL,
  usuario_id integer,
  observaciones text,
  stock_antes numeric,
  stock_despues numeric,
  sincronizado boolean NOT NULL DEFAULT false,
  fecha_sincronizacion timestamp with time zone,
  tenant_id uuid NOT NULL,
  created_at timestamp with time zone NOT NULL DEFAULT now(),
  updated_at timestamp with time zone NOT NULL DEFAULT now(),

  CONSTRAINT movimientos_lotes_tenant_id_isar_uk
    UNIQUE (tenant_id, id_isar),
  CONSTRAINT movimientos_lotes_tenant_fk
    FOREIGN KEY (tenant_id) REFERENCES public.locales(id) ON DELETE CASCADE
);

-- Índice del historial: se consulta por tenant, luego por lote, y el más
-- reciente primero. Cubre el ORDER BY de `descargarMovimientosLoteDesdeSupabase`.
CREATE INDEX movimientos_lotes_lote_idx
  ON public.movimientos_lotes (tenant_id, lote_id_isar, fecha DESC);

-- Índice parcial de los pendientes: `subirMovimientosLotePendientes` filtra
-- por `sincronizado = false`. Al ser parcial, es chico: solo indexa las
-- filas que realmente se van a subir.
CREATE INDEX movimientos_lotes_pendientes_idx
  ON public.movimientos_lotes (tenant_id, sincronizado)
  WHERE sincronizado = false;