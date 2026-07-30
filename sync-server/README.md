Sync Server (bridge to Supabase)

This lightweight Node.js/Express server accepts inventory/product sync payloads from the Flutter app and writes them into Supabase using the service role key.

Security
- Protect SYNC_API_KEY; do NOT embed the service role key or SYNC_API_KEY in the mobile app for production.
- Deploy on a trusted server (Vercel, Heroku, Cloud Run) and set environment variables there.

Endpoints
- POST /api/inventario/movimientos
  - Authorization: Bearer <SYNC_API_KEY>
  - Body: { productoId, nombreProducto, tipoMovimiento, cantidad, stockResultante, fecha, usuarioId, usuarioUid }

- POST /api/productos/sync
  - Authorization: Bearer <SYNC_API_KEY>
  - Body: { productos: [ { codigo_barras, nombre, precio_unidad, stock, es_pesado, categoria, proveedor_nombre, proveedor_telefono, stock_minimo } ] }

Deploy
1. Copy .env.example to .env and fill values.
2. npm install
3. npm start

Notes
- The server uses the Supabase service role key to perform inserts/upserts on behalf of the app.
- Keep the SYNC_API_KEY secret and rotate periodically.
