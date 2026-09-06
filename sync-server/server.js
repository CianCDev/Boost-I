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


// Endpoint: crear/actualizar usuario y opcionalmente crear cuenta en Supabase Auth
app.post('/api/usuarios', async (req, res) => {
  try {
    if (!verifyApiKey(req)) return res.status(401).json({ error: 'Unauthorized' });

    const { nombre, rol, email, password, activo } = req.body || {};

    if (!nombre) return res.status(400).json({ error: 'nombre es requerido' });

    let supabaseUser = null;
    if (email && password) {
      // crear usuario en Supabase Auth mediante la key de administrador
      try {
        const { data: created, error: createErr } = await supabase.auth.admin.createUser({
          email: email,
          password: password,
          email_confirm: true,
          user_metadata: { nombre, rol }
        });
        if (createErr) {
          console.error('Error creando usuario auth:', createErr);
          return res.status(500).json({ error: createErr.message });
        }
        supabaseUser = created;
      } catch (e) {
        console.error('Error admin.createUser:', e);
        return res.status(500).json({ error: 'error_crear_usuario_auth' });
      }
    }

    const row = {
      nombre: nombre || '',
      rol: rol || 'cajero',
      email: email || null,
      activo: activo === undefined ? true : !!activo,
      supabase_uid: supabaseUser?.id ?? null
    };

    const { data, error } = await supabase.from('usuarios').upsert([row], { onConflict: ['email'] });

    if (error) {
      console.error('Error upsert usuarios:', error);
      return res.status(500).json({ error: error.message });
    }

    return res.status(201).json({ ok: true, user: data, supabaseUser });
  } catch (e) {
    console.error('Server error /api/usuarios', e);
    return res.status(500).json({ error: 'server_error' });
  }
});

app.post('/api/ventas/sync', async (req, res) => {
  try {
    if (!verifyApiKey(req)) return res.status(401).json({ error: 'Unauthorized' });

    const venta = req.body || {};
    if (!venta.id || !Array.isArray(venta.detalles)) {
      return res.status(400).json({ error: 'id y detalles requeridos' });
    }

    const ventaRow = {
      id: venta.id,
      fecha: venta.fecha ?? new Date().toISOString(),
      subtotal: venta.subtotal ?? 0,
      impuesto: venta.impuesto ?? 0,
      total: venta.total ?? 0,
      tasa_bcv: venta.tasa_bcv ?? 0,
      total_bolivares: venta.total_bolivares ?? 0,
      metodo_pago: venta.metodo_pago ?? 'Efectivo',
      documento: venta.documento ?? null,
      empleado_nombre: venta.empleado_nombre ?? venta.empleado ?? 'Sin asignar',
      sync_status: 'synced',
      tiene_descuento_especial: !!venta.tiene_descuento_especial,
      monto_descuento_total: venta.monto_descuento_total ?? 0,
    };

    const { error: ventaError } = await supabase.from('ventas').upsert([ventaRow], { onConflict: 'id' });
    if (ventaError) return res.status(500).json({ error: ventaError.message });

    await supabase.from('detalle_ventas').delete().eq('venta_id_fk', venta.id);
    if (venta.detalles.length > 0) {
      const detalles = venta.detalles.map((detalle) => ({
        venta_id_fk: venta.id,
        nombre_producto: detalle.nombre_producto,
        precio_unidad: detalle.precio_unidad ?? 0,
        cantidad: detalle.cantidad ?? 0,
        subtotal: detalle.subtotal ?? 0,
        precio_original: detalle.precio_original ?? null,
        es_descuento_especial: !!detalle.es_descuento_especial,
      }));
      const { error: detalleError } = await supabase.from('detalle_ventas').insert(detalles);
      if (detalleError) return res.status(500).json({ error: detalleError.message });
    }

    return res.status(201).json({ ok: true, id: venta.id, detalles: venta.detalles.length });
  } catch (e) {
    console.error('Server error /api/ventas/sync', e);
    return res.status(500).json({ error: 'server_error' });
  }
});

app.listen(PORT, () => {
  console.log(`Sync server listening on :${PORT}`);
});