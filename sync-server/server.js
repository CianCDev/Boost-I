require('dotenv').config();
const express = require('express');
const { createClient } = require('@supabase/supabase-js');

const app = express();
app.use(express.json({ limit: '1mb' }));

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_ROLE = process.env.SUPABASE_SERVICE_ROLE;
const SYNC_API_KEY = process.env.SYNC_API_KEY; // secreto para autenticar clientes
const PORT = process.env.PORT || 3000;

if (!SUPABASE_URL || !SUPABASE_SERVICE_ROLE || !SYNC_API_KEY) {
  console.error('Faltan variables de entorno. Revisa .env');
  process.exit(1);
}

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE, {
  auth: { persistSession: false },
});

function verifyApiKey(req) {
  const hdr = req.header('Authorization') || '';
  if (!hdr.startsWith('Bearer ')) return false;
  const key = hdr.slice('Bearer '.length).trim();
  return key === SYNC_API_KEY;
}

app.post('/api/inventario/movimientos', async (req, res) => {
  try {
    if (!verifyApiKey(req)) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    const movimiento = req.body;
    // Validaciones básicas
    if (!movimiento.productoId || !movimiento.nombreProducto) {
      return res.status(400).json({ error: 'productoId y nombreProducto requeridos' });
    }

    const row = {
      producto_id: movimiento.productoId ?? '',
      nombre_producto: movimiento.nombreProducto ?? '',
      tipo_movimiento: movimiento.tipoMovimiento ?? 'AJUSTE_MANUAL',
      cantidad: movimiento.cantidad ?? 0,
      stock_resultante: movimiento.stockResultante ?? 0,
      fecha: movimiento.fecha ?? new Date().toISOString(),
      usuario_id: movimiento.usuarioId ?? '',
      sincronizado: true,
      usuario_uid: movimiento.usuarioUid ?? null,
    };

    const { data, error } = await supabase.from('movmientos_inventarios').insert([row]);

    if (error) {
      console.error('Supabase insert error:', error);
      return res.status(500).json({ error: error.message });
    }

    return res.status(201).json({ ok: true, inserted: data });
  } catch (e) {
    console.error('Server error', e);
    return res.status(500).json({ error: 'server_error' });
  }
});

// Optional endpoint to accept bulk product sync if needed
app.post('/api/productos/sync', async (req, res) => {
  try {
    if (!verifyApiKey(req)) return res.status(401).json({ error: 'Unauthorized' });

    const body = req.body;
    if (!body || !Array.isArray(body.productos)) return res.status(400).json({ error: 'productos array required' });

    // This naive approach attempts upserts for products based on codigo_barras
    const productos = body.productos.map(p => ({
      codigo_barras: p['codigo_barras'] ?? '',
      nombre: p['nombre'] ?? '',
      precio_unidad: p['precio_unidad'] ?? 0,
      stock: p['stock'] ?? 0,
      es_pesado: p['es_pesado'] ?? false,
      categoria: p['categoria'] ?? '',
      proveedor_nombre: p['proveedor_nombre'] ?? '',
      proveedor_telefono: p['proveedor_telefono'] ?? '',
      stock_minimo: p['stock_minimo'] ?? 0,
    }));

    // Supabase upsert requires unique constraint; using codigo_barras unique in entity
    const { data, error } = await supabase.from('productos').upsert(productos, { onConflict: ['codigo_barras'] });

    if (error) {
      console.error('Productos sync error:', error);
      return res.status(500).json({ error: error.message });
    }

    return res.status(200).json({ ok: true, processed: data?.length ?? 0 });
  } catch (e) {
    console.error('Server error', e);
    return res.status(500).json({ error: 'server_error' });
  }
});

app.listen(PORT, () => {
  console.log(`Sync server listening on :${PORT}`);
});