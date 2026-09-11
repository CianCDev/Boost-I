# app_boosti_v2 - guia de arquitectura, componentes y simbolos

> Inventario generado el 2026-09-07 exclusivamente desde `app_boosti_v2`. Resume responsabilidades por imports, nombres y flujo; para el comportamiento exacto, consultar el archivo fuente enlazado en el explorador.

## 1. Alcance y cifras

- Codigo Dart bajo `lib/`: **247 archivos**.
- Codigo escrito a mano: **225 archivos**.
- Adaptadores Isar generados: **22 archivos `.g.dart`**.
- Funcion serverless incluida: `supabase/functions/create-user/index.ts`.
- Los `.g.dart` son infraestructura generada; las entidades `.dart` son la fuente de los modelos.

## 2. Arquitectura general

```text
main.dart
  -> SharedPreferences + Supabase + DevicePreview
  -> IsarService (persistencia local y operaciones POS)
  -> ProviderScope / Riverpod
  -> Splash/Login -> InventoryCatalogScreen / MainPosScreen
  -> providers/controllers -> screens/widgets
  -> servicios de ventas, sincronizacion, impresion, balanza, PDF, Telegram y backup
  -> Isar local <-> Supabase remoto
```

### Capas reales

- **Core:** tema global y gateway WebSocket para hardware.
- **Data/Local:** entidades Isar y `IsarService`; la mayor parte de CRUD y migraciones reside aqui.
- **Domain:** modelos de carrito, venta, producto, impresoras, enum de errores y repositorio de lotes (minimo).
- **Presentation/providers:** estado Riverpod, algunos `ChangeNotifier` heredados, controladores y providers de invalidacion.
- **Presentation/screens:** pantallas de arranque, autenticacion, POS, inventario, ventas, pedidos, gastos, dashboard y administracion.
- **Presentation/widgets:** dialogos, tarjetas, tablas, barras de busqueda, menus y componentes reutilizables por dominio.
- **Presentation/services:** sincronizacion, ventas, caja, impresion, tickets, etiquetas, balanza, BCV, Telegram, backup, logs y dispositivo.

## 3. Dependencias declaradas y para que sirven

- **isar**: `^3.1.0+1`
- **isar_flutter_libs**: ``
- **supabase_flutter**: `^2.15.2`
- **flutter_riverpod**: `^2.5.1`
- **web_socket_channel**: `^3.0.3`
- **http**: `^1.2.0`
- **connectivity_plus**: `^7.0.0`
- **pdf**: `^3.11.1`
- **printing**: `^5.13.4`
- **path_provider**: `^2.1.5`
- **image**: `^4.3.0`
- **flutter_staggered_animations**: `^1.1.1`
- **cupertino_icons**: `^1.0.8`
- **device_preview**: `^1.3.1`
- **charset_converter**: `2.4.0`
- **esc_pos_printer_lts**: `^4.1.0`
- **esc_pos_utils_plus**: `^2.0.4`
- **fl_chart**: `^0.68.0`
- **flutter_blue_plus**: `^1.32.0`
- **platform_serial**: `^0.2.0`
- **share_plus**: `^10.0.0`
- **device_info_plus**: `^10.1.0`
- **shared_preferences**: `^2.3.2`
- **uuid**: `^4.4.2`
- **mobile_scanner**: `^6.0.2`
- **archive**: `^3.3.7`
- **shimmer**: `^3.0.0`
- **image_picker**: `^1.1.2`
- **permission_handler**: `^11.3.1`
- **barcode_widget**: `^2.0.4`
- **esc_pos_utils_lts**: `^0.0.1`
- **intl**: `^0.20.2`
- **lottie**: `^3.0.0`
- **flutter_svg**: `^2.0.0`
- **open_filex**: `^4.5.0`
- **image_cropper**: `^12.2.1`
- **image_cropper_platform_interface**: `8.0.0`
- **image_cropper_for_web**: `7.0.0`
- **flutter_slidable**: `^3.0.0`
- **collection**: `^1.19.1`
- **provider**: `^6.1.1`
- **flutter_test**: ``
- **flutter_lints**: `^5.0.0`
- **analyzer**: `^5.13.0`
- **build_runner**: `^2.4.13`
- **isar_generator**: `^3.1.0+1`
- **assets**: ``

### Agrupacion funcional

- **Persistencia/backend:** `isar`, `isar_flutter_libs`, `isar_generator`, `build_runner`, `supabase_flutter`, `shared_preferences`.
- **Estado:** `flutter_riverpod`, `provider`.
- **Red:** `http`, `web_socket_channel`, `connectivity_plus`.
- **POS/hardware:** `esc_pos_printer_lts`, `esc_pos_utils_plus`, `esc_pos_utils_lts`, `flutter_blue_plus`, `platform_serial`, `device_info_plus`, `permission_handler`, `charset_converter`.
- **Documentos/media:** `pdf`, `printing`, `image`, `image_picker`, `image_cropper`, `archive`, `open_filex`, `share_plus`.
- **UI:** `fl_chart`, `flutter_staggered_animations`, `shimmer`, `lottie`, `flutter_svg`, `barcode_widget`, `cupertino_icons`, `device_preview`.
- **Utilidades:** `intl`, `uuid`, `collection`, `mobile_scanner`.

## 4. Flujo de ejecucion

1. `main()` prepara Flutter y lee configuracion de empresa, URL y clave de Supabase desde `SharedPreferences`.
2. Supabase se inicializa solo cuando hay credenciales validas; si no, se muestra configuracion.
3. `IsarService` abre la base local por empresa, registra 22 esquemas, crea datos demo y ejecuta migraciones.
4. Se monta `DevicePreview`, `ProviderScope` y el widget raiz `BoostiPOS`.
5. `BoostiPOS` aplica tema, bloqueo por inactividad, realtime de Supabase y sincronizacion por conectividad.
6. `SplashScreen` comprueba permisos y estado; `LoginScreen` valida PIN local y actualiza el usuario.
7. Tras login se navega al catalogo/POS; desde alli se accede a ventas, inventario y menu administrativo.
8. Los servicios guardan localmente y `SyncService` sincroniza usuarios, productos, ventas, pedidos, gastos, lotes y catalogos.

## 5. Servicios principales

- **`lib/features/pos/presentation/services/sync_service.dart`**: Sincronizacion bidireccional con Supabase, realtime, conectividad y envio de pendientes.
- **`lib/features/pos/presentation/services/venta_service.dart`**: Orquesta la transaccion de venta, detalles, stock, cliente y ticket.
- **`lib/features/pos/presentation/services/cash_register_service.dart`**: Calcula cierre diario y totales por metodo de pago.
- **`lib/features/pos/presentation/services/printer_service.dart`**: Descubre y usa impresoras de red/Bluetooth.
- **`lib/features/pos/presentation/services/ticket_service.dart`**: Imprime tickets y usa PDF como alternativa.
- **`lib/features/pos/presentation/services/ticket_generator.dart`**: Construye contenido/formato de ticket.
- **`lib/features/pos/presentation/services/label_generator.dart`**: Genera etiquetas ESC/POS.
- **`lib/features/pos/presentation/services/label_pdf_generator.dart`**: Genera etiquetas PDF.
- **`lib/features/pos/presentation/services/scale_service.dart`**: Integra balanza serial/Bluetooth y lecturas de peso.
- **`lib/features/pos/presentation/services/bcv_service.dart`**: Obtiene y mantiene la tasa BCV.
- **`lib/features/pos/presentation/services/telegram/telegram_service.dart`**: Polling, comandos, alertas de stock y notificaciones Telegram.
- **`lib/features/pos/presentation/services/backup_service.dart`**: Crea y comparte respaldos.
- **`lib/features/pos/presentation/services/logger_service.dart`**: Registra eventos persistentes en Isar.
- **`lib/features/pos/presentation/services/device_info.dart`**: Identifica plataforma/dispositivo.

## 6. Providers y controladores

- **`lib/features/pos/presentation/providers/auth_provider.dart`**: AuthNotifier, AuthState; funciones: cambiarCajero, clearError, inicializarAdminPorDefecto, loadUsuarios, loginWithEmail, loginWithPin, logout, setError.
- **`lib/features/pos/presentation/providers/bcv_provider.dart`**: declaraciones/provider global.
- **`lib/features/pos/presentation/providers/cash_closing_provider.dart`**: CashClosingNotifier, CashClosingState; funciones: _cargarDatos, cerrarCaja, getMetodoIcono, getNeonColor, refrescar.
- **`lib/features/pos/presentation/providers/catalog/catalog_actions.dart`**: CatalogActions; funciones: afiliarCodigo, agregarAlCarrito, buscarProductoPorCodigo, crearProducto, mostrarModalCobro.
- **`lib/features/pos/presentation/providers/catalog/top_products_provider.dart`**: declaraciones/provider global; funciones: for.
- **`lib/features/pos/presentation/providers/catalog/view_mode_provider.dart`**: ViewModeNotifier; funciones: _loadPreference, _savePreference, setMode, toggle.
- **`lib/features/pos/presentation/providers/catalog_provider.dart`**: CatalogNotifier, CatalogState; funciones: _actualizarCategorias, _aplicarFiltros, recargarDesdeSupabase, recargarEnSegundoPlano, setBusqueda, setCategoria.
- **`lib/features/pos/presentation/providers/categorias_provider.dart`**: CategoriasNotifier; funciones: _cargarCategorias, agregarCategoria, editarCategoria, eliminarCategoria, refrescar.
- **`lib/features/pos/presentation/providers/clientes/clientes_provider.dart`**: ClientesNotifier; funciones: buscarClientes, cargarClientes, eliminarCliente, guardarCliente.
- **`lib/features/pos/presentation/providers/dashboard_provider.dart`**: DashboardNotifier, DashboardState; funciones: _formatearMoneda, cargarDatos, refrescar.
- **`lib/features/pos/presentation/providers/departamentos_provider.dart`**: declaraciones/provider global.
- **`lib/features/pos/presentation/providers/esc_pos_provider.dart`**: PrinterStateNotifier, SelectedPrinter; funciones: deseleccionarImpresora, seleccionarImpresora.
- **`lib/features/pos/presentation/providers/invalidation/invalidation_provider.dart`**: InvalidationService; funciones: invalidarStock.
- **`lib/features/pos/presentation/providers/inventory_provider.dart`**: InventoryNotifier, InventoryState; funciones: _aplicarFiltros, limpiarSeleccion, recargarDesdeSupabase, setCategoria, setFiltroBusqueda, setSoloStockBajo, toggleSeleccionProducto.
- **`lib/features/pos/presentation/providers/isar_provider.dart`**: declaraciones/provider global.
- **`lib/features/pos/presentation/providers/local_actual_provider.dart`**: LocalActualNotifier; funciones: cargarLocalActual, setLocalActual.
- **`lib/features/pos/presentation/providers/locales_provider.dart`**: declaraciones/provider global.
- **`lib/features/pos/presentation/providers/lock_provider.dart`**: LockStateNotifier; funciones: _lockScreen, lock, manualRest, unlock.
- **`lib/features/pos/presentation/providers/lotes_provider.dart`**: LotesNotifier, LotesState; funciones: cargarLotes, getLotesPorTab, recargar, refresh, setCategoriaFiltro, setFiltro, setSearch, setTab.
- **`lib/features/pos/presentation/providers/marca_provider.dart`**: MarcasNotifier; funciones: _sincronizarEnSegundoPlano, actualizarMarca, buscarMarcas, cargarMarcas, crearMarca, eliminarMarca, obtenerMarcaPorSupabaseId, sincronizarCompleto.
- **`lib/features/pos/presentation/providers/panel/panel_provider.dart`**: PanelProvider; funciones: closePanel, openPanel, togglePanel.
- **`lib/features/pos/presentation/providers/pedidos_provider.dart`**: PedidosProveedorScreen, _EstadoChip, _EstadoChipState, _PedidosProveedorScreenState; funciones: _buildContadorItem, _buildContent, _buildEmptyState, _buildErrorState, _buildFiltroEstado, _buildFloatingButton, _buildListaPedidos, _buildLoadingState, _buildResumenPedidos, _filtrarPedidos, _perteneceAlPeriodo, build, createState, dispose, initState.
- **`lib/features/pos/presentation/providers/pos_menu_provider.dart`**: PosMenuNotifier, PosMenuState; funciones: abrirTurno, cargarEstadoInicial, cargarEstadoSync, cargarEstadoTurno, cargarTurnoUsuario, cerrarTurno, getTurnoButtonColor, getTurnoButtonText, getTurnoIcon, sincronizarTodo.
- **`lib/features/pos/presentation/providers/productos_provider.dart`**: ProductosNotifier, ProductosState; funciones: _listasSonIguales, cargarProductos, copyWith, eliminarProducto, guardarProducto, recargarDesdeSupabase.
- **`lib/features/pos/presentation/providers/proveedores_provider.dart`**: ProveedoresNotifier; funciones: cargarProveedores, desactivarProveedor, guardarProveedor.
- **`lib/features/pos/presentation/providers/sync_provider.dart`**: declaraciones/provider global.
- **`lib/features/pos/presentation/providers/telegram_provider.dart`**: declaraciones/provider global.
- **`lib/features/pos/presentation/providers/themes/app_colors.dart`**: declaraciones/provider global.
- **`lib/features/pos/presentation/providers/themes/theme.dart`**: declaraciones/provider global; funciones: darkTheme, lightTheme.
- **`lib/features/pos/presentation/providers/themes/theme_provider.dart`**: ThemeNotifier; funciones: _loadTheme, _saveTheme, setTheme, toggleTheme.
- **`lib/features/pos/presentation/providers/usuario_provider.dart`**: UsuariosNotifier; funciones: clearUsuario, setUsuario.

## 7. Entidades Isar y datos persistidos

- **`lib/features/pos/data/Local/entities/categoria_entity.dart`**: tipos `CategoriaEntity`; campos detectados: activo, createdAt, descripcion, id, nombre, supabaseId, syncStatus, updatedAt.
- **`lib/features/pos/data/Local/entities/cliente_entity.dart`**: tipos `ClienteEntity`; campos detectados: activo, cantidadCompras, createdAt, direccion, documento, email, fechaNacimiento, fechaRegistro, frecuente, id, localId, localSupabaseId, nombre, notas, preferenciasMarketing, supabaseId, syncStatus, telefono, totalCompras, ultimaCompra, updatedAt.
- **`lib/features/pos/data/Local/entities/codigo_barra_alia_entity.dart`**: tipos `CodigoBarrasAliasEntity`; campos detectados: activo, codigo, factor, fechaAsignacion, fechaSincronizacion, id, observaciones, productoId, sincronizado.
- **`lib/features/pos/data/Local/entities/departamento_entity.dart`**: tipos `DepartamentoEntity`; campos detectados: activo, createdAt, descripcion, fechaSincronizacion, id, localId, nombre, sincronizado, supabaseId, updatedAt, usuarioId.
- **`lib/features/pos/data/Local/entities/detalle_pedido_entity.dart`**: tipos `DetallePedidoEntity`; campos detectados: cantidad, id, nombreProducto, pedidoId, precioUnidad, productoId, subtotal, supabaseId.
- **`lib/features/pos/data/Local/entities/detalle_venta_entity.dart`**: tipos `DetalleVentaEntity`; campos detectados: cantidad, esDescuentoEspecial, id, nombreProducto, precioOriginal, precioUnidad, productoId, subtotal, syncStatus, ventaIdFk.
- **`lib/features/pos/data/Local/entities/entrega_entity.dart`**: tipos `EntregaEntity`; campos detectados: createdAt, estadoEntrega, fechaEntrega, id, observaciones, pedidoId, supabaseId, usuarioId.
- **`lib/features/pos/data/Local/entities/gasto_entity.dart`**: tipos `GastoEntity`; campos detectados: categoria, descripcion, fecha, id, moneda, monto, supabaseId, syncStatus, tasaBcv, usuarioId, usuarioNombre.
- **`lib/features/pos/data/Local/entities/local_entity.dart`**: tipos `LocalEntity`; campos detectados: activo, createdAt, direccion, email, fechaSincronizacion, id, nombre, rif, sincronizado, supabaseId, telefono, updatedAt.
- **`lib/features/pos/data/Local/entities/log_entity.dart`**: tipos `LogEntity`; campos detectados: accion, detalles, fecha, id, sincronizado, usuarioNombre, usuarioRol.
- **`lib/features/pos/data/Local/entities/lote_entity.dart`**: tipos `LoteEntity`; campos detectados: cantidadInicial, cantidadRestante, codigoBarrasLote, codigoLoteProveedor, costoUnitario, estado, fechaIngreso, fechaSincronizacion, fechaVencimiento, id, productoId, sincronizado, supabaseId.
- **`lib/features/pos/data/Local/entities/marca_entity.dart`**: tipos `MarcaEntity`; campos detectados: activo, createdAt, descripcion, id, logoUrl, nombre, proveedorId, supabaseId, syncStatus, updatedAt.
- **`lib/features/pos/data/Local/entities/movimiento_inventario_entity.dart`**: tipos `MovimientoInventarioEntity`; campos detectados: cantidad, fecha, id, nombreProducto, productoId, stockResultante, syncStatus, tipoMovimiento, usuarioId.
- **`lib/features/pos/data/Local/entities/movimiento_lote_entity.dart`**: tipos `MovimientoLoteEntity`; campos detectados: cantidad, fecha, fechaSincronizacion, id, loteId, observaciones, sincronizado, tipo, usuarioId.
- **`lib/features/pos/data/Local/entities/pedido_entity.dart`**: tipos `EstadoPedido, PedidoEntity`; campos detectados: detalles, estado, fechaPedido, fechaSincronizacion, id, localDestinoId, localOrigenId, observaciones, proveedorCedula, proveedorEmpresa, proveedorNombre, proveedorTelefono, recepcion, sincronizado, supabaseId, total, usuarioId.
- **`lib/features/pos/data/Local/entities/producto_entity.dart`**: tipos `ProductoEntity`; campos detectados: activo, categoria, categoriaId, codigoBarras, createdAt, createdBy, createdByName, esPesado, fechaSincronizacion, id, imagenUrl, marca, marcaSupabaseId, nombre, precioUnidad, proveedorDireccion, proveedorEmail, proveedorId, proveedorNombre, proveedorSupabaseId, proveedorTelefono, sincronizado, stock, stockMinimo, supabaseId, updatedAt, updatedBy, updatedByName, version.
- **`lib/features/pos/data/Local/entities/proveedor_entity.dart`**: tipos `ProveedorEntity`; campos detectados: activo, cedula, direccion, email, empresa, fechaSincronizacion, id, nombre, productos, rif, sincronizado, supabaseId, telefono, updatedAt.
- **`lib/features/pos/data/Local/entities/recepcion_entity.dart`**: tipos `RecepcionEntity`; campos detectados: fechaRecepcion, fechaSincronizacion, id, observaciones, pedidoId, sincronizado, supabaseId, usuarioId.
- **`lib/features/pos/data/Local/entities/telegram_config_entity.dart`**: tipos `TelegramConfigEntity`; campos detectados: botToken, chatId, comandosPermitidos, createdAt, enabled, fechaSincronizacion, id, nombreChat, notificarPedidos, notificarStockBajo, notificarVentas, sincronizado, supabaseId, updatedAt, usuarioId.
- **`lib/features/pos/data/Local/entities/turno_entity.dart`**: tipos `TurnoEntity`; campos detectados: cajaId, cajaNombre, estado, fechaApertura, fechaCierre, id, montoFinal, montoInicial, syncStatus, totalVentas, turnoId, usuarioId, usuarioNombre, ventasCount.
- **`lib/features/pos/data/Local/entities/usuario_entity.dart`**: tipos `UsuarioEntity`; campos detectados: activo, cajaAsignada, createdAt, departamento, departamentoId, deviceId, dynamicId, email, estado, fechaSincronizacion, id, localId, nombre, password, pin, rol, sincronizado, supabaseId, supabaseUid, updatedAt.
- **`lib/features/pos/data/Local/entities/venta_entity.dart`**: tipos `VentaEntity`; campos detectados: documento, empleado, fecha, id, idSupabase, impuesto, items, metodoPago, montoDescuentoTotal, subtotal, syncStatus, tasaBcv, tieneDescuentoEspecial, total, totalBolivares.
- `isar_service.dart`: singleton de acceso a Isar; inicializacion por empresa, CRUD, login, ventas, inventario, pedidos, lotes, gastos, usuarios, logs y migraciones.
- Cada entidad tiene un `.g.dart` generado con schema, serializacion y query builders Isar.

## 8. Pantallas y componentes de UI

- **Arranque/autenticacion:** `splash_screen.dart`, `configuracion_empresa_screen.dart`, `login_screen.dart`, `rest_screen.dart`, `user_settings_screen.dart`.
- **POS/ventas:** `main_pos_screen.dart`, `inventory_catalog_screen.dart`, `sales_history_screen.dart`, `history_root_screen.dart`, `printer_setup_screen.dart`, `printer_selection_screen.dart`.
- **Inventario/catalogo:** `inventory_screen.dart`, `departamentos_screen.dart`, `proveedores_screen.dart`, `locales_screen.dart`, `lotes_screen.dart`.
- **Operacion:** `pedidos_screen.dart`, `gastos_screen.dart`, `cash_closing_screen.dart`, `dashboard_screen.dart`.
- **Administracion/comunicacion:** `audit_log_screen.dart`, `telegram_config_screen.dart`.
- **Widgets:** catalogo, inventario, ventas, pedidos, proveedores, locales, dashboard, caja, menu, lotes, clientes y componentes compartidos; la lista exhaustiva por archivo esta en la seccion 9.

## 9. Inventario exhaustivo por archivo, clases, funciones y variables

La siguiente lista se genera desde el texto de cada archivo. Incluye tambien archivos `.g.dart`; sus nombres son codigo generado y no deben editarse manualmente.

### `lib/core/network/hardware_gateway_client.dart`
- Imports: dart:async, dart:convert, package:flutter/foundation.dart, package:web_socket_channel/web_socket_channel.dart
- Clases/tipos/componentes: class HardwareGatewayClient
- Funciones/metodos: conectarGateway, dispose
- Variables/campos: _channel, _estaConectado, _pesoController, data, peso, url

### `lib/core/themes/app_theme.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class AppTheme
- Variables/campos: accentGreen, backgroundBg, primaryDark, surfaceWhite

### `lib/features/pos/data/Local/entities/categoria_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class CategoriaEntity
- Funciones/metodos: toSupabaseJson
- Variables/campos: activo, createdAt, descripcion, id, nombre, supabaseId, syncStatus, updatedAt

### `lib/features/pos/data/Local/entities/categoria_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetCategoriaEntityCollection, extension CategoriaEntityQueryWhereSort, extension CategoriaEntityQueryWhere, extension CategoriaEntityQueryFilter, extension CategoriaEntityQueryObject, extension CategoriaEntityQueryLinks, extension CategoriaEntityQuerySortBy, extension CategoriaEntityQuerySortThenBy, extension CategoriaEntityQueryWhereDistinct, extension CategoriaEntityQueryProperty
- Funciones/metodos: _categoriaEntityGetId, _categoriaEntityGetLinks
- Variables/campos: CategoriaEntitySchema, bytesCount, caseSensitive, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/cliente_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class ClienteEntity
- Variables/campos: activo, cantidadCompras, createdAt, direccion, documento, email, fechaNacimiento, fechaRegistro, frecuente, id, localId, localSupabaseId, nombre, notas, preferenciasMarketing, supabaseId, syncStatus, telefono, totalCompras, ultimaCompra, updatedAt

### `lib/features/pos/data/Local/entities/cliente_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetClienteEntityCollection, extension ClienteEntityQueryWhereSort, extension ClienteEntityQueryWhere, extension ClienteEntityQueryFilter, extension ClienteEntityQueryObject, extension ClienteEntityQueryLinks, extension ClienteEntityQuerySortBy, extension ClienteEntityQuerySortThenBy, extension ClienteEntityQueryWhereDistinct, extension ClienteEntityQueryProperty
- Funciones/metodos: _clienteEntityGetId, _clienteEntityGetLinks
- Variables/campos: ClienteEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/codigo_barra_alia_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class CodigoBarrasAliasEntity
- Variables/campos: activo, codigo, factor, fechaAsignacion, fechaSincronizacion, id, observaciones, productoId, sincronizado

### `lib/features/pos/data/Local/entities/codigo_barra_alia_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetCodigoBarrasAliasEntityCollection, extension CodigoBarrasAliasEntityByIndex, extension CodigoBarrasAliasEntityQueryWhereSort, extension CodigoBarrasAliasEntityQueryWhere, extension CodigoBarrasAliasEntityQueryFilter, extension CodigoBarrasAliasEntityQueryObject, extension CodigoBarrasAliasEntityQueryLinks, extension CodigoBarrasAliasEntityQuerySortBy, extension CodigoBarrasAliasEntityQuerySortThenBy, extension CodigoBarrasAliasEntityQueryWhereDistinct, extension CodigoBarrasAliasEntityQueryProperty
- Funciones/metodos: _codigoBarrasAliasEntityGetId, activoEqualTo, codigoContains, codigoEqualTo, codigoIsEmpty, codigoIsNotEmpty, codigoMatches, codigoNotEqualTo, deleteAllByCodigo, deleteAllByCodigoSync, deleteByCodigo, deleteByCodigoSync, fechaAsignacionEqualTo, fechaSincronizacionEqualTo, fechaSincronizacionIsNotNull, fechaSincronizacionIsNull, getAllByCodigoSync, getByCodigo, getByCodigoSync, idEqualTo, idGreaterThan, idLessThan, idNotEqualTo, observacionesContains, observacionesIsEmpty, observacionesIsNotEmpty, observacionesIsNotNull, observacionesIsNull, observacionesMatches, productoIdEqualTo, putAllByCodigo, putByCodigo, putByCodigoSync, sincronizadoEqualTo
- Variables/campos: CodigoBarrasAliasEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object, value, values

### `lib/features/pos/data/Local/entities/departamento_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class DepartamentoEntity
- Variables/campos: activo, createdAt, descripcion, fechaSincronizacion, id, localId, nombre, sincronizado, supabaseId, updatedAt, usuarioId

### `lib/features/pos/data/Local/entities/departamento_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetDepartamentoEntityCollection, extension DepartamentoEntityQueryWhereSort, extension DepartamentoEntityQueryWhere, extension DepartamentoEntityQueryFilter, extension DepartamentoEntityQueryObject, extension DepartamentoEntityQueryLinks, extension DepartamentoEntityQuerySortBy, extension DepartamentoEntityQuerySortThenBy, extension DepartamentoEntityQueryWhereDistinct, extension DepartamentoEntityQueryProperty
- Funciones/metodos: _departamentoEntityGetId
- Variables/campos: DepartamentoEntitySchema, bytesCount, caseSensitive, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/detalle_pedido_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class DetallePedidoEntity
- Variables/campos: cantidad, id, nombreProducto, pedidoId, precioUnidad, productoId, subtotal, supabaseId

### `lib/features/pos/data/Local/entities/detalle_pedido_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetDetallePedidoEntityCollection, extension DetallePedidoEntityQueryWhereSort, extension DetallePedidoEntityQueryWhere, extension DetallePedidoEntityQueryFilter, extension DetallePedidoEntityQueryObject, extension DetallePedidoEntityQueryLinks, extension DetallePedidoEntityQuerySortBy, extension DetallePedidoEntityQuerySortThenBy, extension DetallePedidoEntityQueryWhereDistinct, extension DetallePedidoEntityQueryProperty
- Funciones/metodos: _detallePedidoEntityGetId
- Variables/campos: DetallePedidoEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object

### `lib/features/pos/data/Local/entities/detalle_venta_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class DetalleVentaEntity
- Variables/campos: cantidad, esDescuentoEspecial, id, nombreProducto, precioOriginal, precioUnidad, productoId, subtotal, syncStatus, ventaIdFk

### `lib/features/pos/data/Local/entities/detalle_venta_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetDetalleVentaEntityCollection, extension DetalleVentaEntityQueryWhereSort, extension DetalleVentaEntityQueryWhere, extension DetalleVentaEntityQueryFilter, extension DetalleVentaEntityQueryObject, extension DetalleVentaEntityQueryLinks, extension DetalleVentaEntityQuerySortBy, extension DetalleVentaEntityQuerySortThenBy, extension DetalleVentaEntityQueryWhereDistinct, extension DetalleVentaEntityQueryProperty
- Funciones/metodos: _detalleVentaEntityGetId
- Variables/campos: DetalleVentaEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/entrega_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class EntregaEntity
- Variables/campos: createdAt, estadoEntrega, fechaEntrega, id, observaciones, pedidoId, supabaseId, usuarioId

### `lib/features/pos/data/Local/entities/entrega_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetEntregaEntityCollection, extension EntregaEntityQueryWhereSort, extension EntregaEntityQueryWhere, extension EntregaEntityQueryFilter, extension EntregaEntityQueryObject, extension EntregaEntityQueryLinks, extension EntregaEntityQuerySortBy, extension EntregaEntityQuerySortThenBy, extension EntregaEntityQueryWhereDistinct, extension EntregaEntityQueryProperty
- Funciones/metodos: _entregaEntityGetId, _entregaEntityGetLinks
- Variables/campos: EntregaEntitySchema, bytesCount, caseSensitive, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/gasto_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class GastoEntity
- Variables/campos: categoria, descripcion, fecha, id, moneda, monto, supabaseId, syncStatus, tasaBcv, usuarioId, usuarioNombre

### `lib/features/pos/data/Local/entities/gasto_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetGastoEntityCollection, extension GastoEntityQueryWhereSort, extension GastoEntityQueryWhere, extension GastoEntityQueryFilter, extension GastoEntityQueryObject, extension GastoEntityQueryLinks, extension GastoEntityQuerySortBy, extension GastoEntityQuerySortThenBy, extension GastoEntityQueryWhereDistinct, extension GastoEntityQueryProperty
- Funciones/metodos: _gastoEntityGetId, _gastoEntityGetLinks
- Variables/campos: GastoEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/isar_service.dart`
- Imports: ../entities/departamento_entity.dart, ../entities/detalle_pedido_entity.dart, ../entities/detalle_venta_entity.dart, ../entities/log_entity.dart, ../entities/lote_entity.dart, ../entities/movimiento_inventario_entity.dart, ../entities/movimiento_lote_entity.dart, ../entities/pedido_entity.dart, ../entities/producto_entity.dart, ../entities/proveedor_entity.dart, ../entities/recepcion_entity.dart, ../entities/telegram_config_entity.dart, ../entities/turno_entity.dart, ../entities/usuario_entity.dart, ../entities/venta_entity.dart, categoria_entity.dart, cliente_entity.dart, codigo_barra_alia_entity.dart, dart:io, dart:math, gasto_entity.dart, marca_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart, package:flutter/foundation.dart, package:isar/isar.dart, package:path_provider/path_provider.dart, package:shared_preferences/shared_preferences.dart, package:supabase_flutter/supabase_flutter.dart
- Clases/tipos/componentes: class HistorialCodigoItem, class IsarService
- Funciones/metodos: IsarService, _inicializarProductosDemo, _inicializarUsuariosDemo, _initIsar, actualizarEstadisticasCliente, actualizarEstadoPedido, actualizarSyncStatusCliente, actualizarSyncStatusDepartamento, actualizarSyncStatusGasto, actualizarSyncStatusLocal, actualizarSyncStatusMarca, actualizarSyncStatusPedido, actualizarSyncStatusProveedor, actualizarSyncStatusRecepcion, actualizarSyncStatusVenta, asignarSupabaseIdsAFaltantes, buscarClientes, buscarMarcas, buscarProveedores, cambiarClaveUsuario, cambiarRolUsuario, cancelarPedido, cerrarTurno, contarLotes, contarProductos, contarProductosPorDepartamento, desactivarAlias, desactivarProveedor, descontarLote, eliminarCliente, eliminarDepartamento, eliminarDetallesPorPedido, eliminarLocal, eliminarLote, eliminarMarca, eliminarProducto, eliminarProveedor, eliminarTelegramConfig, eliminarUsuario, generarCodigoBarrasUnico, guardarCategoria, guardarCliente, guardarCodigoAlias, guardarDepartamento, guardarDetallePedido, guardarGasto, guardarLocal, guardarLog, guardarLote, guardarMarca, guardarMovimientoLote, guardarPedido, guardarProducto, guardarProveedor, guardarRecepcion, guardarTelegramConfig, guardarTurno, guardarUsuario, inicializarUsuarioAdminPorDefecto, marcarLogsComoSincronizados, marcarTurnoComoSincronizado, migrarStockExistenteALotes, obtenerAliasPendientesSync, obtenerAliasPorCodigo, obtenerCategoriaPorId, obtenerCategoriasPendientesSync, obtenerClientePorId, obtenerClientePorSupabaseId, obtenerClientesPendientesSync, obtenerDepartamentoPorId, obtenerDepartamentosPendientesSync, obtenerDetallesPorVenta, obtenerGastos, obtenerGastosPendientesSync, obtenerHistorialCodigosPorProducto, obtenerLocalActivo, obtenerLocalPorId, obtenerLocalPorSupabaseId, obtenerLocales, obtenerLocalesPendientesSync, obtenerLogs, obtenerLogsPendientesSync, obtenerLotePorId, obtenerLotesHistorial, obtenerLotesPendientes, obtenerLotesPendientesSync, obtenerMarcaPorId, obtenerMarcaPorSupabaseId, obtenerMarcas, obtenerMarcasPendientesSync, obtenerMovimientosLotePendientesSync, obtenerMovimientosPendientesSync, obtenerMovimientosPorLote, obtenerPedidoPorId, obtenerPedidoPorSupabaseId, obtenerPedidosPendientesSync, obtenerProductoPorId, obtenerProductos, obtenerProductosPendientesSync, obtenerProductosStockBajo, obtenerProveedorPorId, obtenerProveedoresPendientesSync, obtenerRecepcionPorPedido, obtenerResumenDashboard, obtenerStockTotalPorProducto, obtenerTelegramConfig, obtenerTelegramConfigPorUsuario, obtenerTelegramConfigs, obtenerTelegramConfigsPendientesSync, obtenerTodasTelegramConfigs, obtenerTodosLosLotes, obtenerTodosLosProductos, obtenerTodosMovimientosLote, obtenerTurnoAbiertoPorUsuario, obtenerTurnos, obtenerTurnosPendientes, obtenerUltimasVentas, obtenerUsuarioPorDynamicId, obtenerUsuarioPorId, obtenerUsuarioPorSupabaseId, obtenerUsuarios, obtenerUsuariosActivos, obtenerVentaPorIdString, obtenerVentas, obtenerVentasPendientesSync, obtenerVentasPorPeriodo, queryMovimientosVentaRecientes, resetearSupabaseIdsIncorrectos, validarLogin
- Variables/campos: _instance, _isarInstance, aTime, actualizados, adminDefault, alias, bTime, cantidad, cliente, codigo, config, configs, count, dbPath, departamento, departamentos, detalles, detallesList, dia, dir, eliminado, empresaId, existente, existing, fallbackPath, false, fecha, fechaIngreso, fechaVencimiento, filter, fin, finDia, finLocal, gasto, gastos, hoy, idIsar, idIsarStr, idsIsar, inicio, inicioHoy, inicioLocal, inicioMes, inicioSemana, intentos, isar, items, key, keys, lista, local, localSincronizado, log, lote, lotes, lotesCreados, lotesExistentes, marca, mov, movimiento, nombreDepartamento, nombreNormalizado, now, nuevoUsuario, null, pedido, pedidos, pinNormalizado, precio, prefs, priorizarVencimiento, producto, productos, productosConLotesPrevios, productosIniciales, productosSinId, productosSinStock, proveedor, proveedorNombre, q, random, randomNum, recepcion, response, resultado, soloActivas, soloActivos, soloFrecuentes, stockBajo, supabase, supabaseId, timestamp, timestampPart, tipo, todosLosLotes, topProductos, total, totalGastosMes, totalHoy, totalMes, totalSemana, totalVentasAyer, true, turno, ultimasVentas, usuario, usuarios, uuid, variacion, venta, ventas, ventasHoy, ventasPorDia, ventasPorEmpleado

### `lib/features/pos/data/Local/entities/local_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class LocalEntity
- Variables/campos: activo, createdAt, direccion, email, fechaSincronizacion, id, nombre, rif, sincronizado, supabaseId, telefono, updatedAt

### `lib/features/pos/data/Local/entities/local_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetLocalEntityCollection, extension LocalEntityQueryWhereSort, extension LocalEntityQueryWhere, extension LocalEntityQueryFilter, extension LocalEntityQueryObject, extension LocalEntityQueryLinks, extension LocalEntityQuerySortBy, extension LocalEntityQuerySortThenBy, extension LocalEntityQueryWhereDistinct, extension LocalEntityQueryProperty
- Funciones/metodos: _localEntityGetId, _localEntityGetLinks
- Variables/campos: LocalEntitySchema, bytesCount, caseSensitive, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/log_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class LogEntity
- Variables/campos: accion, detalles, fecha, id, sincronizado, usuarioNombre, usuarioRol

### `lib/features/pos/data/Local/entities/log_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetLogEntityCollection, extension LogEntityQueryWhereSort, extension LogEntityQueryWhere, extension LogEntityQueryFilter, extension LogEntityQueryObject, extension LogEntityQueryLinks, extension LogEntityQuerySortBy, extension LogEntityQuerySortThenBy, extension LogEntityQueryWhereDistinct, extension LogEntityQueryProperty
- Funciones/metodos: _logEntityAttach, _logEntityGetId, _logEntityGetLinks
- Variables/campos: LogEntitySchema, bytesCount, caseSensitive, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/lote_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class LoteEntity
- Funciones/metodos: toSupabaseJson
- Variables/campos: cantidadInicial, cantidadRestante, codigoBarrasLote, codigoLoteProveedor, costoUnitario, estado, fechaIngreso, fechaSincronizacion, fechaVencimiento, id, productoId, sincronizado, supabaseId

### `lib/features/pos/data/Local/entities/lote_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetLoteEntityCollection, extension LoteEntityQueryWhereSort, extension LoteEntityQueryWhere, extension LoteEntityQueryFilter, extension LoteEntityQueryObject, extension LoteEntityQueryLinks, extension LoteEntityQuerySortBy, extension LoteEntityQuerySortThenBy, extension LoteEntityQueryWhereDistinct, extension LoteEntityQueryProperty
- Funciones/metodos: _loteEntityAttach, _loteEntityGetId, _loteEntityGetLinks
- Variables/campos: LoteEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/marca_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class MarcaEntity
- Funciones/metodos: toSupabaseJson
- Variables/campos: activo, createdAt, descripcion, id, logoUrl, nombre, proveedorId, supabaseId, syncStatus, updatedAt

### `lib/features/pos/data/Local/entities/marca_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetMarcaEntityCollection, extension MarcaEntityByIndex, extension MarcaEntityQueryWhereSort, extension MarcaEntityQueryWhere, extension MarcaEntityQueryFilter, extension MarcaEntityQueryObject, extension MarcaEntityQueryLinks, extension MarcaEntityQuerySortBy, extension MarcaEntityQuerySortThenBy, extension MarcaEntityQueryWhereDistinct, extension MarcaEntityQueryProperty
- Funciones/metodos: _marcaEntityGetId, _marcaEntityGetLinks, deleteAllBySupabaseId, deleteAllBySupabaseIdSync, deleteBySupabaseId, deleteBySupabaseIdSync, getAllBySupabaseIdSync, getBySupabaseId, getBySupabaseIdSync, putAllBySupabaseId, putBySupabaseId, putBySupabaseIdSync
- Variables/campos: MarcaEntitySchema, bytesCount, caseSensitive, include, includeLower, includeUpper, object, value, values

### `lib/features/pos/data/Local/entities/movimiento_inventario_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class MovimientoInventarioEntity
- Variables/campos: cantidad, fecha, id, nombreProducto, productoId, stockResultante, syncStatus, tipoMovimiento, usuarioId

### `lib/features/pos/data/Local/entities/movimiento_inventario_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetMovimientoInventarioEntityCollection, extension MovimientoInventarioEntityQueryWhereSort, extension MovimientoInventarioEntityQueryWhere, extension MovimientoInventarioEntityQueryFilter, extension MovimientoInventarioEntityQueryObject, extension MovimientoInventarioEntityQueryLinks, extension MovimientoInventarioEntityQuerySortBy, extension MovimientoInventarioEntityQuerySortThenBy, extension MovimientoInventarioEntityQueryWhereDistinct, extension MovimientoInventarioEntityQueryProperty
- Funciones/metodos: _movimientoInventarioEntityGetId, anyId, distinctByCantidad, distinctByFecha, distinctByNombreProducto, distinctByProductoId, distinctByStockResultante, distinctBySyncStatus, distinctByTipoMovimiento, distinctByUsuarioId, fechaEqualTo, idEqualTo, idGreaterThan, idLessThan, idNotEqualTo, nombreProductoContains, nombreProductoIsEmpty, nombreProductoIsNotEmpty, nombreProductoMatches, productoIdEqualTo, sortByCantidad, sortByCantidadDesc, sortByFecha, sortByFechaDesc, sortByNombreProducto, sortByNombreProductoDesc, sortByProductoId, sortByProductoIdDesc, sortByStockResultante, sortByStockResultanteDesc, sortBySyncStatus, sortBySyncStatusDesc, sortByTipoMovimiento, sortByTipoMovimientoDesc, sortByUsuarioId, sortByUsuarioIdDesc, syncStatusContains, syncStatusIsEmpty, syncStatusIsNotEmpty, syncStatusMatches, thenByCantidad, thenByCantidadDesc, thenByFecha, thenByFechaDesc, thenById, thenByIdDesc, thenByNombreProducto, thenByNombreProductoDesc, thenByProductoId, thenByProductoIdDesc, thenByStockResultante, thenByStockResultanteDesc, thenBySyncStatus, thenBySyncStatusDesc, thenByTipoMovimiento, thenByTipoMovimientoDesc, thenByUsuarioId, thenByUsuarioIdDesc, tipoMovimientoContains, tipoMovimientoIsEmpty, tipoMovimientoIsNotEmpty, tipoMovimientoMatches, usuarioIdEqualTo
- Variables/campos: MovimientoInventarioEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object

### `lib/features/pos/data/Local/entities/movimiento_lote_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class MovimientoLoteEntity
- Funciones/metodos: toSupabaseJson
- Variables/campos: cantidad, fecha, fechaSincronizacion, id, loteId, observaciones, sincronizado, tipo, usuarioId

### `lib/features/pos/data/Local/entities/movimiento_lote_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetMovimientoLoteEntityCollection, extension MovimientoLoteEntityQueryWhereSort, extension MovimientoLoteEntityQueryWhere, extension MovimientoLoteEntityQueryFilter, extension MovimientoLoteEntityQueryObject, extension MovimientoLoteEntityQueryLinks, extension MovimientoLoteEntityQuerySortBy, extension MovimientoLoteEntityQuerySortThenBy, extension MovimientoLoteEntityQueryWhereDistinct, extension MovimientoLoteEntityQueryProperty
- Funciones/metodos: _movimientoLoteEntityGetId, fechaEqualTo, fechaSincronizacionEqualTo, fechaSincronizacionIsNotNull, fechaSincronizacionIsNull, idEqualTo, loteIdEqualTo, observacionesContains, observacionesIsEmpty, observacionesIsNotEmpty, observacionesIsNotNull, observacionesIsNull, observacionesMatches, sincronizadoEqualTo, tipoContains, tipoIsEmpty, tipoIsNotEmpty, tipoMatches, usuarioIdEqualTo
- Variables/campos: MovimientoLoteEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/pedido_entity.dart`
- Imports: detalle_pedido_entity.dart, package:isar/isar.dart, recepcion_entity.dart
- Clases/tipos/componentes: enum EstadoPedido, class PedidoEntity
- Variables/campos: detalles, estado, fechaPedido, fechaSincronizacion, id, localDestinoId, localOrigenId, observaciones, proveedorCedula, proveedorEmpresa, proveedorNombre, proveedorTelefono, recepcion, sincronizado, supabaseId, total, usuarioId

### `lib/features/pos/data/Local/entities/pedido_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetPedidoEntityCollection, extension PedidoEntityQueryWhereSort, extension PedidoEntityQueryWhere, extension PedidoEntityQueryFilter, extension PedidoEntityQueryObject, extension PedidoEntityQueryLinks, extension PedidoEntityQuerySortBy, extension PedidoEntityQuerySortThenBy, extension PedidoEntityQueryWhereDistinct, extension PedidoEntityQueryProperty
- Funciones/metodos: _pedidoEntityGetId, _pedidoEntityGetLinks
- Variables/campos: PedidoEntitySchema, _PedidoEntityestadoEnumValueMap, _PedidoEntityestadoValueEnumMap, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/producto_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class ProductoEntity
- Funciones/metodos: toJson
- Variables/campos: activo, categoria, categoriaId, codigoBarras, createdAt, createdBy, createdByName, esPesado, fechaSincronizacion, id, imagenUrl, marca, marcaSupabaseId, nombre, precioUnidad, proveedorDireccion, proveedorEmail, proveedorId, proveedorNombre, proveedorSupabaseId, proveedorTelefono, sincronizado, stock, stockMinimo, supabaseId, updatedAt, updatedBy, updatedByName, version

### `lib/features/pos/data/Local/entities/producto_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetProductoEntityCollection, extension ProductoEntityByIndex, extension ProductoEntityQueryWhereSort, extension ProductoEntityQueryWhere, extension ProductoEntityQueryFilter, extension ProductoEntityQueryObject, extension ProductoEntityQueryLinks, extension ProductoEntityQuerySortBy, extension ProductoEntityQuerySortThenBy, extension ProductoEntityQueryWhereDistinct, extension ProductoEntityQueryProperty
- Funciones/metodos: _productoEntityGetId, _productoEntityGetLinks, deleteAllByCodigoBarras, deleteAllByCodigoBarrasSync, deleteByCodigoBarras, deleteByCodigoBarrasSync, getByCodigoBarras, getByCodigoBarrasSync, putAllByCodigoBarras, putByCodigoBarras, putByCodigoBarrasSync
- Variables/campos: ProductoEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object, value, values

### `lib/features/pos/data/Local/entities/proveedor_entity.dart`
- Imports: package:isar/isar.dart, producto_entity.dart
- Clases/tipos/componentes: class ProveedorEntity
- Variables/campos: activo, cedula, direccion, email, empresa, fechaSincronizacion, id, nombre, productos, rif, sincronizado, supabaseId, telefono, updatedAt

### `lib/features/pos/data/Local/entities/proveedor_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetProveedorEntityCollection, extension ProveedorEntityQueryWhereSort, extension ProveedorEntityQueryWhere, extension ProveedorEntityQueryFilter, extension ProveedorEntityQueryObject, extension ProveedorEntityQueryLinks, extension ProveedorEntityQuerySortBy, extension ProveedorEntityQuerySortThenBy, extension ProveedorEntityQueryWhereDistinct, extension ProveedorEntityQueryProperty
- Funciones/metodos: _proveedorEntityGetId, _proveedorEntityGetLinks
- Variables/campos: ProveedorEntitySchema, bytesCount, caseSensitive, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/recepcion_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class RecepcionEntity
- Variables/campos: fechaRecepcion, fechaSincronizacion, id, observaciones, pedidoId, sincronizado, supabaseId, usuarioId

### `lib/features/pos/data/Local/entities/recepcion_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetRecepcionEntityCollection, extension RecepcionEntityQueryWhereSort, extension RecepcionEntityQueryWhere, extension RecepcionEntityQueryFilter, extension RecepcionEntityQueryObject, extension RecepcionEntityQueryLinks, extension RecepcionEntityQuerySortBy, extension RecepcionEntityQuerySortThenBy, extension RecepcionEntityQueryWhereDistinct, extension RecepcionEntityQueryProperty
- Funciones/metodos: _recepcionEntityGetId, _recepcionEntityGetLinks
- Variables/campos: RecepcionEntitySchema, bytesCount, caseSensitive, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/telegram_config_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class TelegramConfigEntity
- Funciones/metodos: toSupabaseJson
- Variables/campos: botToken, chatId, comandosPermitidos, createdAt, enabled, fechaSincronizacion, id, nombreChat, notificarPedidos, notificarStockBajo, notificarVentas, sincronizado, supabaseId, updatedAt, usuarioId

### `lib/features/pos/data/Local/entities/telegram_config_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetTelegramConfigEntityCollection, extension TelegramConfigEntityQueryWhereSort, extension TelegramConfigEntityQueryWhere, extension TelegramConfigEntityQueryFilter, extension TelegramConfigEntityQueryObject, extension TelegramConfigEntityQueryLinks, extension TelegramConfigEntityQuerySortBy, extension TelegramConfigEntityQuerySortThenBy, extension TelegramConfigEntityQueryWhereDistinct, extension TelegramConfigEntityQueryProperty
- Funciones/metodos: _telegramConfigEntityGetId, botTokenContains, botTokenIsEmpty, botTokenIsNotEmpty, botTokenMatches, chatIdContains, chatIdIsEmpty, chatIdIsNotEmpty, chatIdMatches, comandosPermitidosElementIsEmpty, comandosPermitidosElementIsNotEmpty, comandosPermitidosIsEmpty, comandosPermitidosIsNotEmpty, comandosPermitidosLengthEqualTo, createdAtEqualTo, createdAtIsNotNull, createdAtIsNull, enabledEqualTo, fechaSincronizacionEqualTo, fechaSincronizacionIsNotNull, fechaSincronizacionIsNull, idEqualTo, nombreChatContains, nombreChatIsEmpty, nombreChatIsNotEmpty, nombreChatIsNotNull, nombreChatIsNull, nombreChatMatches, notificarPedidosEqualTo, notificarStockBajoEqualTo, notificarVentasEqualTo, sincronizadoEqualTo, supabaseIdContains, supabaseIdIsEmpty, supabaseIdIsNotEmpty, supabaseIdIsNotNull, supabaseIdIsNull, supabaseIdMatches, updatedAtEqualTo, updatedAtIsNotNull, updatedAtIsNull, usuarioIdEqualTo
- Variables/campos: TelegramConfigEntitySchema, bytesCount, caseSensitive, include, includeLower, includeUpper, object, value

### `lib/features/pos/data/Local/entities/turno_entity.dart`
- Imports: package:isar/isar.dart
- Clases/tipos/componentes: class TurnoEntity
- Variables/campos: cajaId, cajaNombre, estado, fechaApertura, fechaCierre, id, montoFinal, montoInicial, syncStatus, totalVentas, turnoId, usuarioId, usuarioNombre, ventasCount

### `lib/features/pos/data/Local/entities/turno_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetTurnoEntityCollection, extension TurnoEntityQueryWhereSort, extension TurnoEntityQueryWhere, extension TurnoEntityQueryFilter, extension TurnoEntityQueryObject, extension TurnoEntityQueryLinks, extension TurnoEntityQuerySortBy, extension TurnoEntityQuerySortThenBy, extension TurnoEntityQueryWhereDistinct, extension TurnoEntityQueryProperty
- Funciones/metodos: _turnoEntityGetId, _turnoEntityGetLinks
- Variables/campos: TurnoEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object

### `lib/features/pos/data/Local/entities/usuario_entity.dart`
- Imports: package:isar/isar.dart, package:uuid/uuid.dart
- Clases/tipos/componentes: class UsuarioEntity
- Variables/campos: activo, cajaAsignada, createdAt, departamento, departamentoId, deviceId, dynamicId, email, estado, fechaSincronizacion, id, localId, nombre, password, pin, rol, sincronizado, supabaseId, supabaseUid, updatedAt

### `lib/features/pos/data/Local/entities/usuario_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetUsuarioEntityCollection, extension UsuarioEntityByIndex, extension UsuarioEntityQueryWhereSort, extension UsuarioEntityQueryWhere, extension UsuarioEntityQueryFilter, extension UsuarioEntityQueryObject, extension UsuarioEntityQueryLinks, extension UsuarioEntityQuerySortBy, extension UsuarioEntityQuerySortThenBy, extension UsuarioEntityQueryWhereDistinct, extension UsuarioEntityQueryProperty
- Funciones/metodos: _usuarioEntityGetId, _usuarioEntityGetLinks, deleteAllByDynamicId, deleteAllByDynamicIdSync, deleteByDynamicId, deleteByDynamicIdSync, getAllByDynamicId, getAllByDynamicIdSync, getByDynamicId, getByDynamicIdSync, putAllByDynamicId, putByDynamicId, putByDynamicIdSync
- Variables/campos: UsuarioEntitySchema, bytesCount, caseSensitive, include, includeLower, includeUpper, object, value, values

### `lib/features/pos/data/Local/entities/venta_entity.dart`
- Imports: detalle_venta_entity.dart, package:isar/isar.dart
- Clases/tipos/componentes: class VentaEntity
- Variables/campos: documento, empleado, fecha, id, idSupabase, impuesto, items, metodoPago, montoDescuentoTotal, subtotal, syncStatus, tasaBcv, tieneDescuentoEspecial, total, totalBolivares

### `lib/features/pos/data/Local/entities/venta_entity.g.dart`
- Imports: ninguno
- Clases/tipos/componentes: extension GetVentaEntityCollection, extension VentaEntityQueryWhereSort, extension VentaEntityQueryWhere, extension VentaEntityQueryFilter, extension VentaEntityQueryObject, extension VentaEntityQueryLinks, extension VentaEntityQuerySortBy, extension VentaEntityQuerySortThenBy, extension VentaEntityQueryWhereDistinct, extension VentaEntityQueryProperty
- Funciones/metodos: _ventaEntityGetId, _ventaEntityGetLinks
- Variables/campos: VentaEntitySchema, bytesCount, caseSensitive, epsilon, include, includeLower, includeUpper, object, value

### `lib/features/pos/domain/enums/printer_error.dart`
- Imports: ninguno
- Clases/tipos/componentes: enum PrinterError, class PrintResult
- Variables/campos: error, message, success

### `lib/features/pos/domain/models/cart_item.dart`
- Imports: product_item.dart
- Clases/tipos/componentes: class CartItem
- Funciones/metodos: toJson
- Variables/campos: cantidad, esDescuentoEspecial, precioOriginal, producto

### `lib/features/pos/domain/models/printer_models.dart`
- Imports: ninguno
- Clases/tipos/componentes: enum PrinterType, class PrinterDevice
- Funciones/metodos: toJson, toString
- Variables/campos: address, name, port, type

### `lib/features/pos/domain/models/product_item.dart`
- Imports: ninguno
- Clases/tipos/componentes: class ProductItem
- Funciones/metodos: toJson
- Variables/campos: categoria, codigoBarras, esPesado, id, nombre, precioUnidad

### `lib/features/pos/domain/models/venta_model.dart`
- Imports: ninguno
- Clases/tipos/componentes: class VentaModel
- Funciones/metodos: toMap
- Variables/campos: cambio, fecha, id, metodoPago, montoRecibido, total

### `lib/features/pos/domain/repositories/lote_respository.dart`
- Imports: ninguno

### `lib/features/pos/presentation/controllers/bcv_controller.dart`
- Imports: ../services/bcv_service.dart, package:flutter/foundation.dart
- Clases/tipos/componentes: class BcvController
- Funciones/metodos: BcvController, actualizarTasa
- Variables/campos: _cargando, _instance, _tasa, _ultimaActualizacion, now, nuevaTasa

### `lib/features/pos/presentation/controllers/cart_controller.dart`
- Imports: ../../domain/models/cart_item.dart, ../../domain/models/product_item.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CartState, class CartNotifier
- Funciones/metodos: _redondearCantidad, _redondearDosDecimales, actualizarCantidad, agregarItem, aplicarDescuentoEspecial, buscarItemIndex, eliminarItem, eliminarItemPorId, limpiarCarrito, restaurarPrecioOriginal, setAplicaIva, sumarCantidad
- Variables/campos: cantidad, cantidadAjustada, cantidadInicial, cartProvider, idStr, index, indexExistente, item, itemActual, itemExistente, items, itemsActualizados, nuevaCantidad, nuevoItem, porcentajeImpuesto, preciosIncluyenImpuesto, productoModificado, productoOriginal, suma, totalBrutoItems

### `lib/features/pos/presentation/controllers/panel_controller.dart`
- Imports: ../providers/themes/theme_provider.dart, ../widgets/dialogos_genericos/succes_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class PanelController
- Funciones/metodos: atajosTeclado, cambiarCajero, cambiarImpresora, cambiarLector, clientesFrecuentes, crearPromocion, descanso, descuentoEspecial, pedidosRemotos, productosInactivos, toggleTheme
- Variables/campos: currentMode, modeText, themeNotifier

### `lib/features/pos/presentation/providers/auth_provider.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/usuario_entity.dart, ../services/device_info.dart, ../services/sync_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:supabase_flutter/supabase_flutter.dart, usuario_provider.dart
- Clases/tipos/componentes: class AuthState, class AuthNotifier
- Funciones/metodos: cambiarCajero, clearError, inicializarAdminPorDefecto, loadUsuarios, loginWithEmail, loginWithPin, logout, setError
- Variables/campos: _isarService, _ref, _syncService, authProvider, currentUser, data, deviceId, errorMessage, false, isLoading, password, response, successNube, supabase, true, userId, userName, usuario, usuarioActual, usuarioValido, usuarios, validado

### `lib/features/pos/presentation/providers/bcv_provider.dart`
- Imports: ../controllers/bcv_controller.dart, package:flutter_riverpod/flutter_riverpod.dart
- Variables/campos: bcvProvider

### `lib/features/pos/presentation/providers/cash_closing_provider.dart`
- Imports: package:app_boosti_v2/features/pos/presentation/services/cash_register_service.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, sync_provider.dart
- Clases/tipos/componentes: class CashClosingState, class CashClosingNotifier
- Funciones/metodos: _cargarDatos, cerrarCaja, getMetodoIcono, getNeonColor, refrescar
- Variables/campos: _cashService, _ref, cashClosingProvider, error, isLoading, isSyncing, lastUpdated, resumen, sync

### `lib/features/pos/presentation/providers/catalog/catalog_actions.dart`
- Imports: dart:async, package:app_boosti_v2/features/pos/data/Local/entities/codigo_barra_alia_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart, package:app_boosti_v2/features/pos/domain/models/product_item.dart, package:app_boosti_v2/features/pos/presentation/controllers/cart_controller.dart, package:app_boosti_v2/features/pos/presentation/providers/bcv_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/catalog_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/productos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:app_boosti_v2/features/pos/presentation/services/sync_service.dart, package:app_boosti_v2/features/pos/presentation/services/venta_service.dart, package:app_boosti_v2/features/pos/presentation/widgets/catalog/quantity_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/cobrar_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/inventory/product_form_dialog.dart, package:flutter/material.dart, package:flutter/services.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CatalogActions
- Funciones/metodos: afiliarCodigo, agregarAlCarrito, buscarProductoPorCodigo, crearProducto, mostrarModalCobro
- Variables/campos: _isar, _ref, _sync, alias, cambio, cartState, catalogActionsProvider, codigoLimpio, factor, isar, metodoPago, montoRecibido, nuevoAlias, nuevoStock, null, p, productItem, producto, productoSeleccionado, productos, productosNotifier, resultado, stock, sync, tasaActual, ultimoFactorProvider, usuario, ventaService

### `lib/features/pos/presentation/providers/catalog/top_products_provider.dart`
- Imports: ../../../data/Local/entities/isar_service.dart, ../../../data/Local/entities/producto_entity.dart, ../productos_provider.dart, package:flutter_riverpod/flutter_riverpod.dart
- Funciones/metodos: for
- Variables/campos: desde, movimientos, productos, productosState, query, top, topProductosProvider, ventasPorProducto

### `lib/features/pos/presentation/providers/catalog/view_mode_provider.dart`
- Imports: package:flutter_riverpod/flutter_riverpod.dart, package:shared_preferences/shared_preferences.dart
- Clases/tipos/componentes: enum ViewMode, class ViewModeNotifier
- Funciones/metodos: _loadPreference, _savePreference, setMode, toggle
- Variables/campos: _key, newMode, prefs, value, viewModeProvider

### `lib/features/pos/presentation/providers/catalog_provider.dart`
- Imports: ../../data/Local/entities/producto_entity.dart, package:flutter/foundation.dart, package:flutter_riverpod/flutter_riverpod.dart, productos_provider.dart
- Clases/tipos/componentes: class CatalogState, class CatalogNotifier
- Funciones/metodos: _actualizarCategorias, _aplicarFiltros, recargarDesdeSupabase, recargarEnSegundoPlano, setBusqueda, setCategoria
- Variables/campos: _subscription, busqueda, catalogProvider, categoria, categoriaSeleccionada, categorias, coincideCategoria, coincideTexto, filtrados, isLoading, notifier, productos, productosFiltrados, productosState, query, ref, setCategorias

### `lib/features/pos/presentation/providers/categorias_provider.dart`
- Imports: ../../data/Local/entities/categoria_entity.dart, isar_provider.dart, package:flutter_riverpod/flutter_riverpod.dart, package:uuid/uuid.dart, sync_provider.dart
- Clases/tipos/componentes: class CategoriasNotifier
- Funciones/metodos: _cargarCategorias, agregarCategoria, editarCategoria, eliminarCategoria, refrescar
- Variables/campos: categoria, categoriasNotifierProvider, categoriasProvider, isar, lista, nueva, ref, todasLasCategoriasProvider

### `lib/features/pos/presentation/providers/clientes/clientes_provider.dart`
- Imports: ../../../data/Local/entities/cliente_entity.dart, ../../../data/Local/entities/isar_service.dart, ../sync_provider.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class ClientesNotifier
- Funciones/metodos: buscarClientes, cargarClientes, eliminarCliente, guardarCliente
- Variables/campos: all, clientes, clientesFrecuentesProvider, clientesProvider, eliminado, guardado, isarServiceProvider, ref

### `lib/features/pos/presentation/providers/dashboard_provider.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/producto_entity.dart, ../../data/Local/entities/venta_entity.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:intl/intl.dart
- Clases/tipos/componentes: class DashboardState, class DashboardNotifier
- Funciones/metodos: _formatearMoneda, cargarDatos, refrescar
- Variables/campos: _isar, ayer, dashboardProvider, dias, error, formato, hoy, isLoading, mesActual, mesAnterior, resumen, semanaActual, semanaAnterior, stockBajo, totalActual, totalAnterior, totalAyer, totalGastosMes, totalHoy, totalMes, totalSemana, ultimaActualizacion, ultimasVentas, v, variacion, ventasHoy

### `lib/features/pos/presentation/providers/departamentos_provider.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:flutter_riverpod/flutter_riverpod.dart
- Variables/campos: departamentoPorIdProvider, departamentosActivosProvider, departamentosConFiltroProvider, departamentosProvider, duplicado, eliminarDepartamentoProvider, exito, filtrados, guardarDepartamentoProvider, isar, isarServiceProvider, nombreNormalizado, productosPorDepartamentoProvider, q, todos, todosDepartamentosProvider

### `lib/features/pos/presentation/providers/esc_pos_provider.dart`
- Imports: ../../domain/models/printer_models.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class SelectedPrinter, class PrinterStateNotifier
- Funciones/metodos: deseleccionarImpresora, seleccionarImpresora
- Variables/campos: device, operator, printerProvider, type

### `lib/features/pos/presentation/providers/invalidation/invalidation_provider.dart`
- Imports: ../catalog_provider.dart, ../dashboard_provider.dart, ../inventory_provider.dart, ../lotes_provider.dart, ../productos_provider.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class InvalidationService
- Funciones/metodos: invalidarStock
- Variables/campos: _ref, invalidationProvider

### `lib/features/pos/presentation/providers/inventory_provider.dart`
- Imports: ../../data/Local/entities/producto_entity.dart, package:flutter/foundation.dart, package:flutter_riverpod/flutter_riverpod.dart, productos_provider.dart
- Clases/tipos/componentes: class InventoryState, class InventoryNotifier
- Funciones/metodos: _aplicarFiltros, limpiarSeleccion, recargarDesdeSupabase, setCategoria, setFiltroBusqueda, setSoloStockBajo, toggleSeleccionProducto
- Variables/campos: categoriaNombre, categoriaSeleccionadaNombre, coincideCategoria, coincideStockBajo, coincideTexto, filtrados, filtroBusqueda, inventoryProvider, isLoading, notifier, nuevos, productos, productosFiltrados, productosSeleccionados, productosState, query, ref, seleccionMultiple, soloStockBajo

### `lib/features/pos/presentation/providers/isar_provider.dart`
- Imports: ../../data/Local/entities/isar_service.dart, package:flutter_riverpod/flutter_riverpod.dart
- Variables/campos: isarServiceProvider

### `lib/features/pos/presentation/providers/local_actual_provider.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:flutter_riverpod/flutter_riverpod.dart, package:shared_preferences/shared_preferences.dart
- Clases/tipos/componentes: class LocalActualNotifier
- Funciones/metodos: cargarLocalActual, setLocalActual
- Variables/campos: id, isar, local, localActualProvider, locales, notifier, prefs

### `lib/features/pos/presentation/providers/locales_provider.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart, package:flutter_riverpod/flutter_riverpod.dart
- Variables/campos: eliminarLocalProvider, exito, guardarLocalProvider, isar, isarServiceProvider, localPorIdProvider, localesProvider

### `lib/features/pos/presentation/providers/lock_provider.dart`
- Imports: auth_provider.dart, dart:async, package:flutter_riverpod/flutter_riverpod.dart, package:supabase_flutter/supabase_flutter.dart
- Clases/tipos/componentes: class LockStateNotifier
- Funciones/metodos: _lockScreen, lock, manualRest, unlock
- Variables/campos: authState, lockProvider, ref, supabase, userId

### `lib/features/pos/presentation/providers/lotes_provider.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class LotesState, class LotesNotifier
- Funciones/metodos: cargarLotes, getLotesPorTab, recargar, refresh, setCategoriaFiltro, setFiltro, setSearch, setTab
- Variables/campos: _isar, activos, categoria, categoriaFiltro, error, estadoFiltro, isLoading, lotes, lotesActivos, lotesHistorial, lotesPendientes, lotesProvider, lotesProximosAVencer, productos, proximos, q, resultado, searchQuery, sinVencimiento, tabIndex, todos

### `lib/features/pos/presentation/providers/marca_provider.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/marca_entity.dart, ../../data/Local/entities/producto_entity.dart, ../services/sync_service.dart, package:flutter/foundation.dart, package:flutter_riverpod/flutter_riverpod.dart, package:isar/isar.dart, package:uuid/uuid.dart
- Clases/tipos/componentes: class MarcasNotifier
- Funciones/metodos: _sincronizarEnSegundoPlano, actualizarMarca, buscarMarcas, cargarMarcas, crearMarca, eliminarMarca, obtenerMarcaPorSupabaseId, sincronizarCompleto
- Variables/campos: false, isar, marca, marcaNombrePorIdProvider, marcaNombrePorSupabaseIdProvider, marcas, marcasNotifierProvider, marcasProvider, null, productos, q, ref, syncService, syncServiceProvider, todasLasMarcasProvider, true

### `lib/features/pos/presentation/providers/panel/panel_provider.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class PanelProvider
- Funciones/metodos: closePanel, openPanel, togglePanel
- Variables/campos: _isOpen

### `lib/features/pos/presentation/providers/pedidos_provider.dart`
- Imports: ../providers/sync_provider.dart, ../utils/responsive_helper.dart, ../widgets/appbar.dart, ../widgets/sales/sales_history_filter_bar.dart, package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/crear_pedido_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalle_pedido_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/pedido_card.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_staggered_animations/flutter_staggered_animations.dart
- Clases/tipos/componentes: class PedidosProveedorScreen, class _PedidosProveedorScreenState, class _EstadoChip, class _EstadoChipState
- Funciones/metodos: _buildContadorItem, _buildContent, _buildEmptyState, _buildErrorState, _buildFiltroEstado, _buildFloatingButton, _buildListaPedidos, _buildLoadingState, _buildResumenPedidos, _filtrarPedidos, _perteneceAlPeriodo, build, createState, dispose, initState
- Variables/campos: _animationController, _anioSeleccionado, _aniosDisponibles, _estadoFiltro, _fadeAnimation, _listaMesesDropdown, _localDestinoId, _mesSeleccionado, _periodoSeleccionado, borderRadius, cancelados, cancelarPedidoProvider, colorScheme, esSeleccionado, fechaDia, fechaLocal, filtrados, finSemana, fontSize, hoy, icon, iconSize, indexMes, inicioSemana, isDark, isHovering, isMobile, isar, isarServiceProvider, label, localDestinoId, now, onTap, paddingHoriz, paddingVert, pedido, pedidos, pedidosAsync, pedidosFiltrados, pedidosListProvider, pendientes, proveedoresActivosProvider, recepcion, recibidos, registrarRecepcionProvider, result, selected, syncServiceProvider, total, true

### `lib/features/pos/presentation/providers/pos_menu_provider.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/turno_entity.dart, ../services/sync_service.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class PosMenuState, class PosMenuNotifier
- Funciones/metodos: abrirTurno, cargarEstadoInicial, cargarEstadoSync, cargarEstadoTurno, cargarTurnoUsuario, cerrarTurno, getTurnoButtonColor, getTurnoButtonText, getTurnoIcon, sincronizarTodo
- Variables/campos: _isarService, _syncService, montoFinal, nuevoTurno, pendientes, posMenuProvider, sincronizando, true, turno, turnoAbierto, turnoExistente, ventasPendientesSync

### `lib/features/pos/presentation/providers/productos_provider.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/movimiento_inventario_entity.dart, ../../data/Local/entities/producto_entity.dart, ../../data/Local/entities/usuario_entity.dart, ../services/sync_service.dart, package:flutter/foundation.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class ProductosState, class ProductosNotifier
- Funciones/metodos: _listasSonIguales, cargarProductos, copyWith, eliminarProducto, guardarProducto, recargarDesdeSupabase
- Variables/campos: _isar, _sync, currentItems, diferencia, isLoading, items, movimiento, nuevoStock, oldProducto, producto, productos, productosProvider, stockAnterior, true

### `lib/features/pos/presentation/providers/proveedores_provider.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart, package:collection/collection.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class ProveedoresNotifier
- Funciones/metodos: cargarProveedores, desactivarProveedor, guardarProveedor
- Variables/campos: coincideEmpresa, coincideNombre, isar, isarServiceProvider, productos, productosPorProveedorProvider, proveedorPorIdAsyncProvider, proveedorPorIdProvider, proveedoresConFiltroProvider, proveedoresIdsConProducto, proveedoresProvider, q, ref, resultado, todos, true

### `lib/features/pos/presentation/providers/sync_provider.dart`
- Imports: ../services/sync_service.dart, catalog_provider.dart, categorias_provider.dart, clientes/clientes_provider.dart, dashboard_provider.dart, departamentos_provider.dart, inventory_provider.dart, locales_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/marca_provider.dart, package:flutter_riverpod/flutter_riverpod.dart, productos_provider.dart, proveedores_provider.dart, usuario_provider.dart
- Variables/campos: syncServiceProvider

### `lib/features/pos/presentation/providers/telegram_provider.dart`
- Imports: isar_provider.dart, package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart, package:app_boosti_v2/features/pos/presentation/services/telegram/telegram_service.dart, package:flutter_riverpod/flutter_riverpod.dart, usuario_provider.dart
- Variables/campos: guardarTelegramConfigProvider, isar, telegramConfigProvider, telegramService, telegramServiceProvider, usuario

### `lib/features/pos/presentation/providers/themes/app_colors.dart`
- Imports: package:flutter/material.dart
- Variables/campos: bgDark, bgLight, blueSoft, brightSnow, cardDark, cardLight, darkBlue, deepSpaceBlue, deepSpaceBlueLight, greenSoft, mintLeaf, primaryGreen, pumpkinSpice, redError, seashell, secondaryBlue, slateGrey, slateGreyLight, textDark, textMuted

### `lib/features/pos/presentation/providers/themes/theme.dart`
- Imports: app_colors.dart, package:flutter/material.dart
- Funciones/metodos: darkTheme, lightTheme

### `lib/features/pos/presentation/providers/themes/theme_provider.dart`
- Imports: package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:shared_preferences/shared_preferences.dart
- Clases/tipos/componentes: class ThemeNotifier
- Funciones/metodos: _loadTheme, _saveTheme, setTheme, toggleTheme
- Variables/campos: _themeKey, newMode, prefs, themeIndex, themeProvider

### `lib/features/pos/presentation/providers/usuario_provider.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/usuario_entity.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class UsuariosNotifier
- Funciones/metodos: clearUsuario, setUsuario
- Variables/campos: empleadosPorLocalProvider, isar, usuarioActualProvider, usuarioPorIdProvider, usuarios, usuariosProvider

### `lib/features/pos/presentation/screens/audit_log_screen.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/log_entity.dart, ../utils/responsive_helper.dart, ../widgets/appbar.dart, package:flutter/material.dart
- Clases/tipos/componentes: class AuditLogScreen, class _AuditLogScreenState
- Funciones/metodos: _buildLogCard, _buildSectionHeader, _cargarLogs, _groupLogsByDate, build, createState
- Variables/campos: _isarService, children, colorIcon, date, fechaFormatted, fechaLocal, grouped, icon, isMobile, logs, logsForDate, sortedDates, theme

### `lib/features/pos/presentation/screens/cash_closing_screen.dart`
- Imports: ../services/cash_register_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/presentation/providers/cash_closing_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/esc_pos_provider.dart, package:app_boosti_v2/features/pos/presentation/services/ticket_service.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart, package:app_boosti_v2/features/pos/presentation/widgets/cash_closing/closing_button.dart, package:app_boosti_v2/features/pos/presentation/widgets/cash_closing/closing_confirm_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/cash_closing/closing_payment_card.dart, package:app_boosti_v2/features/pos/presentation/widgets/cash_closing/closing_summary_card.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CashClosingScreen, class _CashClosingScreenState, class _SummaryItem
- Funciones/metodos: _calcularTiempo, build, createState, dispose, initState
- Variables/campos: _animationController, color, colorScheme, crossAxisCount, diff, gradient, icon, isDark, isMobile, isTablet, itemWidth, local, notifier, now, padding, resumen, selectedPrinter, spacing, sparklineData, state, summaryItems, title, value

### `lib/features/pos/presentation/screens/configuracion_empresa_screen.dart`
- Imports: dart:convert, package:flutter/material.dart, package:shared_preferences/shared_preferences.dart, package:supabase_flutter/supabase_flutter.dart, splash_screen.dart
- Clases/tipos/componentes: class ConfiguracionEmpresaScreen, class _ConfiguracionEmpresaScreenState
- Funciones/metodos: MaterialPageRoute, _cargarConfiguracion, _guardarConfiguracion, build, createState, initState
- Variables/campos: _anonKeyController, _empresaIdController, _isLoading, _obscureKey, _urlController, anonKey, bytes, empresaId, hash, isDesktop, prefs, url

### `lib/features/pos/presentation/screens/dashboard_screen.dart`
- Imports: ../providers/dashboard_provider.dart, ../utils/responsive_helper.dart, ../widgets/appbar.dart, ../widgets/dashboard/dashboard_skeleton.dart, ../widgets/dashboard/employee_activity.dart, ../widgets/dashboard/low_stock_list.dart, ../widgets/dashboard/metric_card.dart, ../widgets/dashboard/recent_sales_list.dart, ../widgets/dashboard/sales_chart.dart, ../widgets/dashboard/top_products_list.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class DashboardScreen, class _DashboardScreenState
- Funciones/metodos: _buildErrorWidget, _buildFooter, _formatFecha, build, createState, initState
- Variables/campos: _cargaInicial, ahora, childAspectRatio, crossAxisCount, diff, estado, horizontalPadding, isDesktop, isMobile, isTablet, metricas, notifier, spacing, theme, verticalPadding

### `lib/features/pos/presentation/screens/departamentos/departamentos_screen.dart`
- Imports: ../../../data/Local/entities/isar_service.dart, ../../../data/Local/entities/usuario_entity.dart, ../../widgets/dialogos_genericos/dialogos_genericos.dart, ../../widgets/dialogos_genericos/error_dialog.dart, ../../widgets/dialogos_genericos/succes_dialog.dart, dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart, package:app_boosti_v2/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/departamentos/detalle_departamento_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_staggered_animations/flutter_staggered_animations.dart
- Clases/tipos/componentes: class DepartamentosScreen, class _DepartamentosScreenState
- Funciones/metodos: _buildBody, _buildEmptyState, _buildErrorState, _buildFiltros, _buildFloatingButton, _buildSearchBar, _eliminarDepartamento, _mostrarDetalle, _navegarACrear, _navegarAEditar, _toggleActivo, build, createState
- Variables/campos: _estado, _localFiltroId, _queryBusqueda, activo, actualizado, colorScheme, confirm, d, departamentosAsync, estadoColor, isDark, isHovered, isMobile, isar, localNameAsync, localesAsync, usuarioAsync, usuarioPorIdProvider

### `lib/features/pos/presentation/screens/gastos_screen.dart`
- Imports: ../../data/Local/entities/gasto_entity.dart, ../../data/Local/entities/isar_service.dart, ../providers/bcv_provider.dart, ../providers/usuario_provider.dart, ../utils/responsive_helper.dart, ../widgets/appbar.dart, ../widgets/gastos/gastos_detail_dialog.dart, ../widgets/gastos/gastos_filter_bar.dart, ../widgets/gastos/gastos_list.dart, ../widgets/gastos/gastos_search_bar.dart, ../widgets/gastos/gastos_summary_cards.dart, dart:async, package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class GastosScreen, class _GastosScreenState
- Funciones/metodos: _aplicarFiltros, _buildRegistroForm, _cargarGastos, _mostrarDetalleGasto, _perteneceAlPeriodo, _registrarGasto, build, createState, dispose, initState
- Variables/campos: _anioSeleccionadoDropdown, _categoriaFiltro, _categoriaSeleccionada, _categorias, _descripcionController, _gastosFiltrados, _isLoading, _isarService, _listKey, _listaAniosDisponibles, _listaMesesDropdown, _mesSeleccionadoDropdown, _monedaSeleccionada, _montoController, _periodoSeleccionado, _searchQuery, _todosLosGastos, _totalBs, _totalUSD, acumuladoBs, acumuladoUSD, anioActual, anioMinimo, anios, body, coincideBusqueda, coincideCategoria, coincideDescripcion, coincidePeriodo, colorScheme, descripcion, fechaDia, fechaLocal, filtrados, finSemana, fontSizeResumen, fontSizeResumenValor, gasto, gastos, gradient, hPadding, hoy, indexMes, inicioSemana, isDark, isMobile, isTablet, monto, montoStr, now, query, showAppBar, spacingWrap, tasaBcv, true, usuario, vPadding

### `lib/features/pos/presentation/screens/history_root_screen.dart`
- Imports: ../utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/screens/gastos_screen.dart, package:app_boosti_v2/features/pos/presentation/screens/sales_history_screen.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class HistoryRootScreen, class _HistoryRootScreenState
- Funciones/metodos: build, createState, dispose, initState
- Variables/campos: _tabController, colorScheme, isDark, isMobile

### `lib/features/pos/presentation/screens/inventory_catalog_screen.dart`
- Imports: ../../data/Local/entities/producto_entity.dart, ../../data/Local/entities/usuario_entity.dart, ../controllers/cart_controller.dart, ../controllers/panel_controller.dart, ../providers/bcv_provider.dart, ../providers/catalog_provider.dart, ../providers/panel/panel_provider.dart, ../providers/themes/app_colors.dart, ../providers/usuario_provider.dart, ../services/scale_service.dart, ../utils/responsive_helper.dart, ../widgets/catalog/cart_sidebar.dart, ../widgets/catalog/category_chips.dart, ../widgets/catalog/fixed_cart_summary.dart, ../widgets/catalog/product_card.dart, ../widgets/catalog/product_card_skeleton.dart, ../widgets/catalog/product_list_tile.dart, ../widgets/catalog/search_bar.dart, ../widgets/catalog/view_mode_toggle.dart, ../widgets/shared/barcode_scanner_dialog.dart, dart:async, package:app_boosti_v2/features/pos/domain/models/product_item.dart, package:app_boosti_v2/features/pos/presentation/providers/catalog/catalog_actions.dart, package:app_boosti_v2/features/pos/presentation/widgets/catalog/catalog_app_bar.dart, package:flutter/material.dart, package:flutter/services.dart, package:flutter_riverpod/flutter_riverpod.dart, package:provider/provider.dart
- Clases/tipos/componentes: class InventoryCatalogScreen, class _InventoryCatalogScreenState
- Funciones/metodos: _buildBody, _buildCatalogPanel, _buildScaffold, _iniciarPolling, _manejarTecladoFisico, _mostrarModalCobro, _scanBarcode, build, createState, dispose, initState
- Variables/campos: _animationController, _panelController, _panelProvider, _pollingTimer, _scaleService, _searchFocusNode, _weightSubscription, action, actions, cantidad, cartNotifier, cartState, childAspectRatio, codigo, colorScheme, contenido, crossAxisCount, existingIndex, factor, false, isDesktop, isEmpty, isLoading, isMobile, isTablet, orientation, producto, productosFiltrados, refreshCatalogCounterProvider, showAppBar, stockBajo, true, useSidebar, usuarioLogueado

### `lib/features/pos/presentation/screens/inventory_screen.dart`
- Imports: ../../data/Local/entities/producto_entity.dart, ../../data/Local/entities/usuario_entity.dart, ../providers/esc_pos_provider.dart, ../providers/inventory_provider.dart, ../providers/productos_provider.dart, ../providers/themes/app_colors.dart, ../providers/usuario_provider.dart, ../services/label_generator.dart, ../services/label_pdf_generator.dart, ../services/printer_service.dart, ../services/sync_service.dart, ../utils/responsive_helper.dart, ../widgets/appbar.dart, ../widgets/inventory/barcode_generator_dialog.dart, ../widgets/inventory/categorias_management_dialog.dart, ../widgets/inventory/inventory_category_chips.dart, ../widgets/inventory/inventory_product_card.dart, ../widgets/inventory/inventory_product_card_skeleton.dart, ../widgets/inventory/inventory_search_bar.dart, ../widgets/inventory/marcas_managment_dialog.dart, ../widgets/inventory/product_detail_dialog.dart, ../widgets/inventory/product_form_dialog.dart, ../widgets/shared/barcode_scanner_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:lottie/lottie.dart
- Clases/tipos/componentes: class InventoryScreen, class _InventoryScreenState
- Funciones/metodos: _buildBody, _buildFAB, _generarPDFEtiquetas, _imprimirEtiquetasSeleccionadas, _mostrarDetalleProducto, _mostrarDialogoCantidadEtiquetas, _mostrarFormularioProducto, _scanBarcode, build, createState, dispose, initState
- Variables/campos: _animationController, cantidad, childAspectRatio, codigo, codigoBarrasInicial, colorScheme, confirm, contenido, count, crossAxisCount, esAdmin, gradient, iconSize, inventoryState, isActionHovered, isAdmin, isDark, isMobile, isSelected, isTablet, labels, p, producto, productos, productosFiltrados, productosNotifier, productosSeleccionados, productosState, result, screenWidth, selectedPrinter, showAppBar, size, state, usuarioLogueado, validCantidades

### `lib/features/pos/presentation/screens/locales/locales_screen.dart`
- Imports: ../../widgets/dialogos_genericos/error_dialog.dart, ../../widgets/dialogos_genericos/succes_dialog.dart, dart:async, dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/local_actual_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:app_boosti_v2/features/pos/presentation/services/sync_service.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart, package:app_boosti_v2/features/pos/presentation/widgets/dialogos_genericos/dialogos_genericos.dart, package:app_boosti_v2/features/pos/presentation/widgets/locales/crear_local_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/locales/detalle_local_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/locales/local_card.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_staggered_animations/flutter_staggered_animations.dart
- Clases/tipos/componentes: class LocalesScreen, class _LocalesScreenState
- Funciones/metodos: _buildEmptyState, _buildErrorState, _buildFiltros, _buildFloatingButton, _buildListaLocales, _buildSearchBar, _eliminarLocal, _mostrarCrear, _mostrarDetalle, _mostrarEditar, _sincronizarLocales, _toggleActivo, build, createState, dispose
- Variables/campos: _debounce, _isSyncing, _mostrarInactivos, _queryBusqueda, actualizado, coincideEstado, coincideNombre, colorScheme, confirm, currentId, currentLocalId, isDark, isLocalActual, isMobile, local, localesAsync, localesFiltrados, sync

### `lib/features/pos/presentation/screens/login_screen.dart`
- Imports: ../../data/Local/entities/usuario_entity.dart, ../providers/auth_provider.dart, ../providers/usuario_provider.dart, ../services/sync_service.dart, ../utils/responsive_helper.dart, dart:ui, inventory_catalog_screen.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:shared_preferences/shared_preferences.dart
- Clases/tipos/componentes: class LoginScreen, class _LoginScreenState
- Funciones/metodos: _buildLoginButton, _buildLogo, _buildPinMode, _loadSelectedUser, _loginWithPin, _saveSelectedUser, _showSnackbar, _validateSelectedUser, build, createState, dispose, initState
- Variables/campos: _animationController, _errorMessage, _fadeAnimation, _isLoading, _obscurePin, _pinController, _scaffoldKey, _selectedUserId, _slideAnimation, authState, buttonHeight, containerWidth, ejemploPins, exists, fontSizeLabel, iconSize, isAdmin, isInitialLoad, isMobile, isTablet, logoSize, paddingSize, pin, prefs, savedId, screenSize, showFeedback, success, user, usuarioSeleccionado, usuariosActualizados, usuariosOrdenados

### `lib/features/pos/presentation/screens/lotes_screen.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/categoria_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/categorias_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/lotes_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/productos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart, package:app_boosti_v2/features/pos/presentation/widgets/lotes/detalle_lote_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/lotes/lotes_card.dart, package:app_boosti_v2/features/pos/presentation/widgets/lotes/traspaso_lote_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/lotes/verificar_lote_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_staggered_animations/flutter_staggered_animations.dart
- Clases/tipos/componentes: class LotesScreen, class _LotesScreenState
- Funciones/metodos: _buildLista, _mostrarDetalle, _mostrarReponer, _mostrarVerificacion, build, createState, dispose, initState
- Variables/campos: _tabController, categoriasAsync, colorScheme, esAdmin, icono, isMobile, items, lote, lotes, mensaje, notifier, state, subtitulo, usuario

### `lib/features/pos/presentation/screens/main_pos_screen.dart`
- Imports: ../../data/Local/entities/usuario_entity.dart, ../providers/bcv_provider.dart, ../utils/responsive_helper.dart, inventory_catalog_screen.dart, inventory_screen.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, pos_menu_screen.dart
- Clases/tipos/componentes: class MainPosScreen, class _MainPosScreenState
- Funciones/metodos: _buildAppBar, _onNavTap, _onPageChanged, build, createState, dispose
- Variables/campos: _currentIndex, _pageController, bcvState, isMobile, isTablet, usuarioLogueado

### `lib/features/pos/presentation/screens/pedido/pedidos_screen.dart`
- Imports: ../../utils/responsive_helper.dart, ../../widgets/appbar.dart, ../../widgets/sales/sales_history_filter_bar.dart, package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/crear_pedido_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalle_pedido_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/pedido_card.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_staggered_animations/flutter_staggered_animations.dart
- Clases/tipos/componentes: class PedidosProveedorScreen, class _PedidosProveedorScreenState, class _EstadoChip, class _EstadoChipState
- Funciones/metodos: _buildContadorItem, _buildContent, _buildEmptyState, _buildErrorState, _buildFiltroEstado, _buildFloatingButton, _buildListaPedidos, _buildLoadingState, _buildResumenPedidos, _filtrarPedidos, _perteneceAlPeriodo, build, createState, dispose, initState
- Variables/campos: _animationController, _anioSeleccionado, _aniosDisponibles, _estadoFiltro, _fadeAnimation, _listaMesesDropdown, _localDestinoId, _mesSeleccionado, _periodoSeleccionado, borderRadius, cancelados, colorScheme, esSeleccionado, fechaDia, fechaLocal, filtrados, finSemana, fontSize, hoy, icon, iconSize, indexMes, inicioSemana, isDark, isHovering, isMobile, label, localDestinoId, now, onTap, paddingHoriz, paddingVert, pedido, pedidos, pedidosAsync, pedidosFiltrados, pendientes, recibidos, result, selected, total, true

### `lib/features/pos/presentation/screens/pos_menu_screen.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/turno_entity.dart, ../../data/Local/entities/usuario_entity.dart, ../../presentation/providers/usuario_provider.dart, ../providers/auth_provider.dart, ../screens/dashboard_screen.dart, ../screens/departamentos/departamentos_screen.dart, ../screens/locales/locales_screen.dart, ../screens/lotes_screen.dart, ../screens/proveedores/proveedores_screen.dart, ../screens/telegram/telegram_config_screen.dart, ../services/backup_service.dart, ../services/sync_service.dart, ../utils/responsive_helper.dart, ../widgets/appbar.dart, ../widgets/gestion_personal_dialog.dart, ../widgets/menu/turno_closing_dialog.dart, ../widgets/menu/turno_status_banner.dart, ../widgets/monitor_empleado_widget.dart, ../widgets/printer_selection_widget.dart, audit_log_screen.dart, cash_closing_screen.dart, configuracion_empresa_screen.dart, gastos_screen.dart, login_screen.dart, package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart, package:app_boosti_v2/features/pos/presentation/screens/pedido/pedidos_screen.dart, package:app_boosti_v2/features/pos/presentation/widgets/menu/diagnostico_lote_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_staggered_animations/flutter_staggered_animations.dart, package:lottie/lottie.dart, package:shared_preferences/shared_preferences.dart, sales_history_screen.dart, user_settings_screen.dart
- Clases/tipos/componentes: class MenuOption, class MenuSection, class PosMenuScreen, class _PosMenuScreenState
- Funciones/metodos: MaterialPageRoute, _abrirTurno, _actualizarProgreso, _buildLottieWithFallback, _buildSectionTitle, _cargarEstadoSync, _cargarEstadoTurno, _cerrarTurno, _crearBackup, _formatearHora, _getMenuSections, _logout, _mostrarDialogoExito, _sincronizarConProgreso, build, createState, dispose, initState
- Variables/campos: _animationController, _isarService, _sincronizando, _syncService, _turnoAbierto, _ventasPendientesSync, accentColor, backupService, cerrarTurno, color, confirm, contenido, crossAxisCount, currentContext, esAdmin, exito, gradient, icon, isAdminOnly, isDark, isHovered, isMobile, isTablet, local, mensaje, mensajeProgreso, montoFinal, nuevoTurno, onTap, opcionSalir, opcionesAdmin, opcionesConfiguracion, opcionesFiltradas, opcionesPrincipales, option, options, pendientes, prefs, result, scaffoldMessenger, secciones, sectionColor, showAppBar, sincronizacionActiva, subtitle, theme, tieneTurno, title, turno, turnoAbierto, turnoExistente, usuario

### `lib/features/pos/presentation/screens/printer_selection_screen.dart`
- Imports: package:permission_handler/permission_handler.dart
- Funciones/metodos: requestAllPermissions
- Variables/campos: allGranted, permissions

### `lib/features/pos/presentation/screens/printer_setup_screen.dart`
- Imports: ../../domain/models/printer_models.dart, ../services/printer_service.dart, ../utils/printer_storage.dart, package:flutter/material.dart, package:permission_handler/permission_handler.dart
- Clases/tipos/componentes: class PrinterSetupScreen, class _PrinterSetupScreenState
- Funciones/metodos: _checkPermissions, _selectPrinter, _showAddNetworkPrinterDialog, _startScan, build, createState
- Variables/campos: _foundPrinters, _isScanning, _printerService, bluetoothConnect, bluetoothScan, ipController, location, nameController, printer, printers

### `lib/features/pos/presentation/screens/proveedores/proveedores_screen.dart`
- Imports: dart:async, dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart, package:app_boosti_v2/features/pos/presentation/services/sync_service.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart, package:app_boosti_v2/features/pos/presentation/widgets/proveedores/crear_proveedor_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/proveedores/detalle_proveedor_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/proveedores/proveedor_card.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:flutter_staggered_animations/flutter_staggered_animations.dart
- Clases/tipos/componentes: class ProveedoresScreen, class _ProveedoresScreenState
- Funciones/metodos: _buildEmptyState, _buildErrorState, _buildFiltros, _buildFloatingButton, _buildListaProveedores, _buildSearchBar, _cargarProductos, _confirmarYEliminar, _desvincularYEliminar, _ejecutarEliminacion, _eliminarProveedor, _navegarACrear, _navegarADetalle, _navegarAEditar, _reasignarYEliminar, _sincronizarProveedores, _sincronizarProveedoresForzada, _toggleActivo, build, createState, dispose, initState
- Variables/campos: _debounce, _isSyncing, _mostrarInactivos, _productoFiltroId, _productos, _queryBusqueda, action, actualizado, cantidadPendientes, colorScheme, confirm, currentContext, exito, exitoLocal, isDark, isMobile, isar, isarService, otrosProveedores, p, pendientes, productos, productosAsociados, proveedor, proveedorDestino, proveedoresAsync, scaffoldMessenger, sync, syncService

### `lib/features/pos/presentation/screens/rest_screen.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/log_entity.dart, ../providers/auth_provider.dart, ../providers/lock_provider.dart, ../services/sync_service.dart, ../utils/responsive_helper.dart, dart:async, package:flutter/material.dart, package:flutter/services.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class RestScreen, class _RestScreenState, class _NumpadButton
- Funciones/metodos: _handleKeyEvent, _onBackspacePressed, _onDigitPressed, _triggerError, _tryUnlock, build, createState, dispose, initState
- Variables/campos: _cargando, _enteredPin, _errorMessage, _failedAttempts, _isLockedOut, _isarService, _keyboardFocus, _shakeAnimation, _shakeController, _syncService, authState, cardWidth, colorScheme, digit, icon, isDark, isDisabled, isFilled, isMobile, label, onPressed, usuarioLogueado

### `lib/features/pos/presentation/screens/sales_history_screen.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/venta_entity.dart, ../services/sync_service.dart, ../utils/responsive_helper.dart, ../widgets/appbar.dart, ../widgets/sales/sales_history_filter_bar.dart, ../widgets/sales/sales_history_list.dart, ../widgets/sales/sales_history_search_bar.dart, ../widgets/sales/sales_history_summary_cards.dart, dart:async, dart:convert, dart:io, package:flutter/material.dart, package:path_provider/path_provider.dart, package:share_plus/share_plus.dart
- Clases/tipos/componentes: class SalesHistoryScreen, class _SalesHistoryScreenState
- Funciones/metodos: _aplicarFiltros, _cargarVentas, _exportarCSV, _perteneceAlPeriodo, build, createState, initState
- Variables/campos: _anioSeleccionadoDropdown, _isLoading, _isarService, _listKey, _listaAniosDisponibles, _listaMesesDropdown, _mesSeleccionadoDropdown, _metodoSeleccionado, _metodos, _periodoSeleccionado, _searchQuery, _todasLasVentas, _totalBs, _totalUSD, _ventasFiltradas, acumuladoBs, acumuladoUSD, anioActual, anioMinimo, anios, body, buffer, coincideBusqueda, coincideCliente, coincideEmpleado, coincideId, coincideMetodo, coincidePeriodo, colorScheme, directory, fechaA, fechaB, fechaDia, fechaLocal, fechaStr, file, fileName, filtradas, finSemana, hPadding, hoy, indexMes, inicioSemana, isMobile, isTablet, now, query, shareResult, showAppBar, tasaValida, tasaVentaValida, totalBsVenta, totalBsVentaValido, true, vPadding, ventas

### `lib/features/pos/presentation/screens/splash_screen.dart`
- Imports: ../../data/Local/entities/isar_service.dart, configuracion_empresa_screen.dart, login_screen.dart, package:flutter/material.dart, package:flutter_svg/flutter_svg.dart, package:permission_handler/permission_handler.dart, package:shared_preferences/shared_preferences.dart
- Clases/tipos/componentes: class SplashScreen, class _SplashScreenState
- Funciones/metodos: MaterialPageRoute, _diagnosticarLogin, _inicializarApp, _pedirPermisos, _verificarConfiguracion, build, createState, initState
- Variables/campos: _isLoading, admin, anonKey, flagKey, isar, permisos, prefs, sync, todos, url, usuario, verificado, yan

### `lib/features/pos/presentation/screens/telegram/telegram_config_screen.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/isar_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:app_boosti_v2/features/pos/presentation/services/telegram/telegram_service.dart, package:app_boosti_v2/features/pos/presentation/utils/input_decoration_helper.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class TelegramConfigScreen, class _TelegramConfigScreenState
- Funciones/metodos: _buildCommandsSection, _buildHeader, _buildNotificationsSection, _buildSaveButton, _buildTestButton, _cargarConfiguracion, _guardarConfiguracion, _mostrarAyuda, _probarConexion, build, createState, dispose, initState
- Variables/campos: _botTokenController, _chatIdController, _chatNameController, _comandosDisponibles, _comandosPermitidos, _enabled, _formKey, _isLoading, _isSaving, _notificarPedidos, _notificarStockBajo, _notificarVentas, botToken, chatId, colorScheme, config, enabled, enviado, gradient, isDark, isMobile, isSelected, isar, maxWidth, mensajePrueba, null, service, usuario

### `lib/features/pos/presentation/screens/user_settings_screen.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/usuario_entity.dart, ../../presentation/providers/usuario_provider.dart, ../providers/auth_provider.dart, ../providers/themes/theme_provider.dart, ../utils/responsive_helper.dart, ../widgets/admin_validation_dialog.dart, ../widgets/appbar.dart, ../widgets/cambiar_pin_dialog.dart, dart:ui, login_screen.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class UserSettingsScreen, class _UserSettingsScreenState
- Funciones/metodos: _cambiarNombre, _cambiarPin, _cerrarSesion, build, createState, dispose, initState
- Variables/campos: _editandoNombre, _guardandoNombre, _isarService, _nombreController, _themeAnimationController, avatarRadius, cardPadding, colorPrimary, confirm, esAdmin, fontSizeBody, fontSizeSubtitle, fontSizeTitle, iconSize, isDark, isMobile, isTablet, maxWidth, nuevoNombre, paddingHorizontal, paddingVertical, sectionSpacing, switchScale, theme, usuarioLogueado

### `lib/features/pos/presentation/services/backup_service.dart`
- Imports: dart:io, package:archive/archive_io.dart, package:flutter/foundation.dart, package:path_provider/path_provider.dart, package:share_plus/share_plus.dart
- Clases/tipos/componentes: class BackupService
- Funciones/metodos: crearBackupYCompartir
- Variables/campos: appDir, encoder, false, isarDir, true, zipFile, zipPath

### `lib/features/pos/presentation/services/bcv_service.dart`
- Imports: dart:convert, package:flutter/foundation.dart, package:http/http.dart
- Clases/tipos/componentes: class BcvService
- Funciones/metodos: obtenerTasaBcv
- Variables/campos: _urlApi, data, response, tasa

### `lib/features/pos/presentation/services/cash_register_service.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/venta_entity.dart, package:isar/isar.dart
- Clases/tipos/componentes: class ResumenCorteCaja, class CashRegisterService
- Funciones/metodos: calcularCorteDelDia
- Variables/campos: _isarService, cantidadTransacciones, inicioDelDia, isar, metodo, now, totalGeneral, totalVentas, ventasHoy

### `lib/features/pos/presentation/services/device_info.dart`
- Imports: dart:developer, dart:io, package:device_info_plus/device_info_plus.dart, package:shared_preferences/shared_preferences.dart, package:uuid/uuid.dart
- Clases/tipos/componentes: class DeviceInfoService
- Funciones/metodos: _isAndroid, _isIOS, _isWindows, getDeviceId, getDeviceInfo
- Variables/campos: _deviceIdKey, _deviceInfo, androidInfo, deviceId, iosInfo, prefs, windowsInfo

### `lib/features/pos/presentation/services/label_generator.dart`
- Imports: package:esc_pos_utils_plus/esc_pos_utils_plus.dart
- Clases/tipos/componentes: class LabelItem, class LabelGenerator
- Funciones/metodos: _generateSingleLabel
- Variables/campos: bytes, cantidad, codigoBarras, generator, nombre, precio, profile

### `lib/features/pos/presentation/services/label_pdf_generator.dart`
- Imports: dart:typed_data, label_generator.dart, package:flutter/material.dart, package:pdf/pdf.dart, package:pdf/widgets.dart, package:printing/printing.dart
- Clases/tipos/componentes: class LabelPdfGenerator
- Variables/campos: labelsPerPage, pageFormat, pageLabels, pdf, pdfBytes, title

### `lib/features/pos/presentation/services/logger_service.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/log_entity.dart
- Clases/tipos/componentes: class LoggerService
- Variables/campos: _isar, log

### `lib/features/pos/presentation/services/printer_service.dart`
- Imports: ../../data/Local/entities/local_entity.dart, ../../domain/enums/printer_error.dart, ../../domain/models/printer_models.dart, label_generator.dart, package:esc_pos_printer_lts/esc_pos_printer_lts.dart, package:esc_pos_utils_lts/esc_pos_utils_lts.dart, package:flutter/foundation.dart, package:flutter_blue_plus/flutter_blue_plus.dart, ticket_generator.dart
- Clases/tipos/componentes: class PrinterService, class PrintResult
- Funciones/metodos: _log, testPrinter
- Variables/campos: allBytes, attempts, bytes, characteristic, connectResult, device, error, esCierre, foundDevices, isPrinter, lastResult, maxRetries, message, name, networkPrinter, paper, profile, services, subscription, success, testItems, timeout, timestamp, uuid

### `lib/features/pos/presentation/services/scale_service.dart`
- Imports: dart:async, package:flutter/foundation.dart, package:platform_serial/platform_serial.dart
- Clases/tipos/componentes: class ScaleService
- Funciones/metodos: _disconnect, _parseWeightFromText, connect, disconnect, dispose
- Variables/campos: _isConnected, _port, _textSubscription, _weightController, false, manager, match, null, peso, portInfo, portName, ports, regex, trimmed, true

### `lib/features/pos/presentation/services/sync_service.dart`
- Imports: ../../data/Local/entities/categoria_entity.dart, ../../data/Local/entities/cliente_entity.dart, ../../data/Local/entities/departamento_entity.dart, ../../data/Local/entities/detalle_pedido_entity.dart, ../../data/Local/entities/detalle_venta_entity.dart, ../../data/Local/entities/gasto_entity.dart, ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/local_entity.dart, ../../data/Local/entities/marca_entity.dart, ../../data/Local/entities/movimiento_inventario_entity.dart, ../../data/Local/entities/movimiento_lote_entity.dart, ../../data/Local/entities/pedido_entity.dart, ../../data/Local/entities/producto_entity.dart, ../../data/Local/entities/proveedor_entity.dart, ../../data/Local/entities/recepcion_entity.dart, ../../data/Local/entities/telegram_config_entity.dart, ../../data/Local/entities/turno_entity.dart, ../../data/Local/entities/usuario_entity.dart, ../../data/Local/entities/venta_entity.dart, dart:async, dart:convert, package:connectivity_plus/connectivity_plus.dart, package:flutter/foundation.dart, package:flutter/services.dart, package:http/http.dart, package:isar/isar.dart, package:supabase_flutter/supabase_flutter.dart, package:uuid/uuid.dart
- Clases/tipos/componentes: class SyncService
- Funciones/metodos: _authHeaders, _detalleToJson, _enviarGastoAlServidor, _enviarMarcaAlServidor, _enviarMovimientoAlServidor, _enviarTurnoAlServidor, _enviarVentaAlServidor, _hasValidSyncConfig, _limpiarNumero, _loadConfig, _obtenerIsarIdLocal, _obtenerIsarIdProducto, _obtenerIsarIdUsuario, _obtenerLocalActualUuid, _obtenerSupabaseIdLocal, _obtenerSupabaseIdProducto, _obtenerSupabaseIdUsuario, _suscribirATabla, _ventaToJson, actualizarEstadoUsuarioEnSupabase, descargarCategoriasDesdeSupabase, descargarClientesDesdeSupabase, descargarDepartamentosDesdeSupabase, descargarGastosDesdeSupabase, descargarLocalesDesdeSupabase, descargarMarcasDesdeSupabase, descargarMovimientosLoteDesdeSupabase, descargarPedidosDesdeSupabase, descargarProductosDesdeSupabase, descargarProveedoresDesdeSupabase, descargarTelegramConfigDesdeSupabase, descargarVentasDesdeSupabase, detenerMonitoreo, detenerSuscripcionesRealtime, dispose, eliminarClienteEnSupabase, eliminarProductoEnSupabase, eliminarProveedorEnSupabase, eliminarUsuarioEnSupabase, iniciarMonitoreo, iniciarSuscripcionesRealtime, obtenerUsuariosDesdeSupabase, repararImagenesFaltantes, sincronizarAliasPendientes, sincronizarCategorias, sincronizarClientesPendientes, sincronizarDepartamentosPendientes, sincronizarGastosPendientes, sincronizarLocalesPendientes, sincronizarLotesPendientes, sincronizarMarcasPendientes, sincronizarMovimientosInventario, sincronizarMovimientosLotePendientes, sincronizarPedidosPendientes, sincronizarProductosASupabase, sincronizarProveedoresPendientes, sincronizarTelegramConfigPendientes, sincronizarTodo, sincronizarTodoConResumen, sincronizarTurnos, sincronizarUsuariosASupabase, sincronizarUsuariosDesdeSupabase, sincronizarVentasPendientes, streamUsuariosEnTiempoReal
- Variables/campos: _channels, _configLoaded, _connectivity, _connectivitySubscription, _isSyncing, _isarService, _supabase, _syncApiKey, _syncServerUrl, actualizados, affected, allFiles, categoria, channel, clienteLocal, clienteNube, codigoBarras, codigoLimpio, codigosEnNube, configNube, creados, data, departamentos, depto, deptoNube, deptosLocales, deptosPend, detalle, detalles, detallesResponse, eliminados, estadoNube, existente, existing, exito, false, fileName, findResponse, gastoLocal, gastoNube, gastosLocales, gastosPend, guardadas, idIsar, idsIsar, imagenUrlFinal, imagenUrlLocal, imagenUrlNube, insertadas, insertados, isar, json, local, localActivo, localActualId, localActualUuid, localDestinoId, localDestinoUuid, localExistente, localIsar, localIsarId, localNube, localOrigenId, localOrigenUuid, localSupabaseId, localUpdated, localUuid, locales, localesConUuid, localesLocales, localesPend, lote, lotesPend, map, marcaNube, marcasPend, movNube, name, newData, newLocal, nubeUpdated, nuevoId, nuevoLocal, nuevoUsuario, null, onDataChanged, payload, pedido, pedidoData, pedidoId, pedidos, pedidosPend, pedidosPendientes, pendientes, producto, productoId, productoIdFk, productoLocal, productoNube, productos, productosLocales, productosPend, proveedorNube, proveedoresPend, publicUrl, raw, recepcion, recepcionData, recepcionJson, reparados, response, resultados, rpcResponse, sincronizadas, sincronizados, supabase, supabaseId, supabasePedidoId, telegramPend, tieneConexion ...

### `lib/features/pos/presentation/services/telegram/telegram_service.dart`
- Imports: dart:async, dart:convert, package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart, package:flutter/foundation.dart, package:http/http.dart
- Clases/tipos/componentes: class TelegramService
- Funciones/metodos: TelegramService, _ayuda, _bienvenida, _checkUpdates, _ejecutarComando, _enviarMensaje, _pedidos, _procesarComando, _resumen, _startPolling, _stock, _ventas, actualizarComandosEnTelegram, actualizarConfig, alertarStockBajo, cambiarUsuario, dispose, enviarMensajePrueba, inicializar
- Variables/campos: _config, _instance, _isarService, _lastUpdateId, _pollingTimer, bajos, chatId, cmd, comandos, comandosPermitidos, data, description, false, fecha, fin, hoy, inicio, lista, listaComandos, mensaje, message, payload, pedidos, productos, registrados, response, respuesta, stockBajo, text, total, totalBs, totalVentas, true, updateId, url, ventas, ventasHoy

### `lib/features/pos/presentation/services/ticket_generator.dart`
- Imports: ../../data/Local/entities/local_entity.dart, package:esc_pos_utils_lts/esc_pos_utils_lts.dart
- Clases/tipos/componentes: class TicketItem, class TicketGenerator
- Variables/campos: bytes, cantidad, cantidadStr, esCierre, esPesado, fechaStr, generator, linea, nombre, nombreTruncado, precio, precioStr, profile

### `lib/features/pos/presentation/services/ticket_service.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/local_entity.dart, ../../domain/enums/printer_error.dart, ../../domain/models/printer_models.dart, dart:developer, dart:io, dart:typed_data, package:flutter/material.dart, package:path_provider/path_provider.dart, package:pdf/pdf.dart, package:pdf/widgets.dart, package:printing/printing.dart, printer_service.dart, ticket_generator.dart
- Clases/tipos/componentes: enum TicketType, class TicketService
- Funciones/metodos: _generarNombreArchivo, _getErrorMessage
- Variables/campos: bytes, directory, errorMessage, fechaStr, file, fileName, folder, folderPath, impuesto, metodo, nombre, now, pageFormat, pdf, prefix, printerService, result, snackBar, subfolder, subtotal, subtotalCalculado, tipo

### `lib/features/pos/presentation/services/venta_service.dart`
- Imports: ../../data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/detalle_venta_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/venta_entity.dart, package:app_boosti_v2/features/pos/presentation/controllers/cart_controller.dart, package:app_boosti_v2/features/pos/presentation/providers/esc_pos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/productos_provider.dart, package:app_boosti_v2/features/pos/presentation/services/ticket_generator.dart, package:app_boosti_v2/features/pos/presentation/services/ticket_service.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:uuid/uuid.dart
- Clases/tipos/componentes: class VentaService
- Variables/campos: _ref, ahora, cantidadPorDescontar, cartNotifier, cartState, descontar, descuento, exito, isar, itemsIsar, local, lote, montoDescuentoTotal, nuevaVenta, nuevoUuidVenta, producto, productoId, productosAfectados, productosNotifier, selectedPrinter, stockTotal, ticketItems, tieneDescuento, totalBsCalculado, ventaServiceProvider

### `lib/features/pos/presentation/utils/input_decoration_helper.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class InputDecorationHelper
- Variables/campos: borderColor, brightness, colorScheme, isDark, isDarkMode, labelColor

### `lib/features/pos/presentation/utils/panel_utils.dart`
- Imports: ../providers/panel/panel_provider.dart, ../widgets/panel/side_panel.dart, package:flutter/material.dart, package:provider/provider.dart
- Funciones/metodos: showSidePanel
- Variables/campos: entry, provider

### `lib/features/pos/presentation/utils/pdf_utils.dart`
- Imports: dart:io, package:flutter/foundation.dart, package:open_filex/open_filex.dart, package:path_provider/path_provider.dart
- Clases/tipos/componentes: class PdfUtils
- Variables/campos: directory, file, fileName, folder, folderPath, result, subcarpeta

### `lib/features/pos/presentation/utils/printer_storage.dart`
- Imports: ../../domain/models/printer_models.dart, dart:convert, package:shared_preferences/shared_preferences.dart
- Clases/tipos/componentes: class PrinterStorage
- Funciones/metodos: clearPrinter, loadPrinter, savePrinter
- Variables/campos: _key, jsonString, null, prefs

### `lib/features/pos/presentation/utils/responsive_helper.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class ResponsiveHelper
- Funciones/metodos: getFontSize, getResponsivePadding, getSize, isDesktop, isMobile, isMobileOrTablet, isTablet
- Variables/campos: desktopBreakpoint, mobileBreakpoint, tabletBreakpoint, width

### `lib/features/pos/presentation/utils/top_product_utils.dart`
- Imports: ../widgets/catalog/top_products_widget.dart, package:flutter/material.dart
- Funciones/metodos: showTopProducts
- Variables/campos: entry

### `lib/features/pos/presentation/widgets/admin_validation_dialog.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/usuario_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class AdminValidationDialog, class _AdminValidationDialogState
- Funciones/metodos: _validarAdmin, build, createState
- Variables/campos: _errorMessage, _isLoading, _isarService, _pinController, adminValido, admins, onCancel, onSuccess, pin

### `lib/features/pos/presentation/widgets/appbar.dart`
- Imports: package:flutter/material.dart, package:flutter_svg/flutter_svg.dart
- Clases/tipos/componentes: class CustomAppBar
- Funciones/metodos: build
- Variables/campos: actions, centerTitle, defaultGradient, gradient, isDark, isSvg, leading, leadingWidth, logoAsset, logoSize, onBackPressed, showBackButton, title, titleWidget

### `lib/features/pos/presentation/widgets/cambiar_pin_dialog.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/usuario_entity.dart, ../utils/responsive_helper.dart, package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class PinChangeDialog, class _PinChangeDialogState, class AdminPinChangeDialog, class CashierPinChangeDialog
- Funciones/metodos: _guardarCambio, _toggleRevealActual, build, createState, dispose
- Variables/campos: _cargando, _confirmPinController, _mostrarPinActual, _newPinController, _obscureConfirmPin, _obscureNewPin, admin, cajero, color, confirmPin, esAdmin, exito, isMobile, isarService, newPin, usuario

### `lib/features/pos/presentation/widgets/cart_table_widget.dart`
- Imports: ../../domain/models/cart_item.dart, ../utils/responsive_helper.dart, package:flutter/material.dart, package:flutter/services.dart
- Clases/tipos/componentes: class CartTableWidget, class _CartTableWidgetState
- Funciones/metodos: _buildDesktopTable, _getController, _updateController, build, createState, dispose
- Variables/campos: controller, esPesado, fontSize, iconSize, index, inputHeight, inputWidth, isDesktop, isMobile, isTablet, item, items, nameFontSize, nuevaCant, paddingX, paddingY, step, text

### `lib/features/pos/presentation/widgets/cash_closing/closing_button.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class ClosingButton, class _ClosingButtonState
- Funciones/metodos: build, createState, dispose, initState
- Variables/campos: _pulseController, isMobile, isSyncing, isTablet, onPress, total

### `lib/features/pos/presentation/widgets/cash_closing/closing_confirm_dialog.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class ClosingConfirmDialog
- Funciones/metodos: build
- Variables/campos: colorScheme, isDark, onCancel, onConfirm, total

### `lib/features/pos/presentation/widgets/cash_closing/closing_payment_card.dart`
- Imports: package:app_boosti_v2/features/pos/presentation/providers/cash_closing_provider.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class ClosingPaymentCard
- Funciones/metodos: build
- Variables/campos: color, icon, isDark, isMobile, isTablet, metodo, monto, notifier

### `lib/features/pos/presentation/widgets/cash_closing/closing_summary_card.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class ClosingSummaryCard, class SparklinePainter
- Funciones/metodos: _buildTrendIndicator, build, paint, shouldRepaint
- Variables/campos: color, colorScheme, data, first, icon, isDark, isMobile, isTablet, isUp, last, lineWidth, maxVal, minVal, paint, path, percent, range, sparklineData, title, value, x, y

### `lib/features/pos/presentation/widgets/catalog/cart_bottom_sheet.dart`
- Imports: ../../controllers/cart_controller.dart, ../../providers/bcv_provider.dart, ../../providers/themes/app_colors.dart, ../../utils/responsive_helper.dart, package:flutter/material.dart, package:flutter/services.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CartBottomSheet
- Funciones/metodos: _buildEmptyState, _confirmarLimpiar, _mostrarDialogoEliminado, build
- Variables/campos: bcvTasa, cartState, colorScheme, confirmado, hasItems, isTablet, item, null, onCobrar, subtotal, tieneDescuento

### `lib/features/pos/presentation/widgets/catalog/cart_sidebar.dart`
- Imports: ../../controllers/cart_controller.dart, ../../providers/bcv_provider.dart, ../../providers/themes/app_colors.dart, ../../utils/responsive_helper.dart, package:flutter/material.dart, package:flutter/services.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CartSidebar
- Funciones/metodos: _confirmarEliminarProducto, build
- Variables/campos: backgroundColor, bcvTasa, borderColor, cartState, confirmado, isDark, isTablet, item, itemBgColor, key, onCobrar, onLimpiar, subtotal, textColor, textSecondaryColor, tieneDescuento

### `lib/features/pos/presentation/widgets/catalog/catalog_app_bar.dart`
- Imports: ../../../data/Local/entities/usuario_entity.dart, ../../controllers/bcv_controller.dart, ../../providers/bcv_provider.dart, ../../providers/catalog_provider.dart, ../../providers/usuario_provider.dart, ../../screens/inventory_screen.dart, ../../screens/pos_menu_screen.dart, ../../utils/panel_utils.dart, ../../utils/responsive_helper.dart, ../../utils/top_product_utils.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, search_bar.dart
- Clases/tipos/componentes: class CatalogAppBar, class _InventoryBadge, class _BcvBadge
- Funciones/metodos: MaterialPageRoute, build
- Variables/campos: _defaultFocusNode, appBar, bcvState, btnSize, focusNode, fontSize, gradient, hover, iSize, isDark, isDesktop, isHovered, isMobile, isTablet, lowStockCount, onPressed, onScanPressed, onTap, safeSearchBar, searchFocusNode, size, usuarioActual, usuarioLogueado

### `lib/features/pos/presentation/widgets/catalog/category_button.dart`
- Imports: ../../providers/themes/app_colors.dart, ../../utils/responsive_helper.dart, package:flutter/material.dart
- Clases/tipos/componentes: class CategoryButton, class _CategoryButtonState
- Funciones/metodos: build, createState
- Variables/campos: _isHovered, backgroundColor, baseColor, borderColor, categoria, esSeleccionada, esStockBajo, fontSize, iconColor, iconData, isDark, isTablet, mostrarIcono, onTap, padding, seleccionado, shadowColor, textColor

### `lib/features/pos/presentation/widgets/catalog/category_chips.dart`
- Imports: ../../providers/catalog_provider.dart, ../../utils/responsive_helper.dart, category_button.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CategoryChips
- Funciones/metodos: build
- Variables/campos: cat, isTablet, state

### `lib/features/pos/presentation/widgets/catalog/fixed_cart_summary.dart`
- Imports: ../../controllers/cart_controller.dart, ../../providers/bcv_provider.dart, ../../providers/themes/app_colors.dart, ../../utils/responsive_helper.dart, cart_bottom_sheet.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class FixedCartSummary
- Funciones/metodos: _openCartBottomSheet, build
- Variables/campos: backgroundColor, bcvTasa, borderColor, cartState, hasItems, isDark, isTablet, onCobrar, textColor, textSecondaryColor

### `lib/features/pos/presentation/widgets/catalog/product_card.dart`
- Imports: ../../../data/Local/entities/producto_entity.dart, ../../providers/marca_provider.dart, ../../providers/themes/app_colors.dart, ../../utils/responsive_helper.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class ProductCard, class _ProductCardState
- Funciones/metodos: build, createState
- Variables/campos: _isHovering, animationController, badgeFontSize, badgePadding, cardBackground, cardBorderColor, cardShadow, colorScheme, end, fontSizeCodigo, fontSizeMarca, fontSizeNombre, fontSizePrecio, fontSizeStock, index, isDark, isMobile, isTablet, marcaNombreAsync, onTap, producto, scale, start, stockBajo, stockDisplay, stockValue, typeBadgeFontSize, typeBadgePadding

### `lib/features/pos/presentation/widgets/catalog/product_card_skeleton.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class ProductCardSkeleton
- Funciones/metodos: build
- Variables/campos: colorScheme

### `lib/features/pos/presentation/widgets/catalog/product_list_tile.dart`
- Imports: ../../../data/Local/entities/producto_entity.dart, ../../providers/themes/app_colors.dart, ../../utils/responsive_helper.dart, package:flutter/material.dart
- Clases/tipos/componentes: class ProductListTile, class _ProductListTileState
- Funciones/metodos: build, createState
- Variables/campos: _isHovered, borderColor, borderWidth, cardBackground, colorScheme, imageSize, index, isDark, isMobile, onTap, producto, stockBajo

### `lib/features/pos/presentation/widgets/catalog/quantity_dialog.dart`
- Imports: ../../../data/Local/entities/producto_entity.dart, ../../services/scale_service.dart, ../admin_validation_dialog.dart, dart:async, dart:ui, package:flutter/material.dart, package:flutter/services.dart
- Clases/tipos/componentes: class QuantityDialog, class _QuantityDialogState
- Funciones/metodos: _agregar, build, createState, dispose, initState
- Variables/campos: _adminValidoParaEstaVenta, _cantidadController, _precioController, _procesando, _scaleService, _usandoPesoAutomatico, _weightSubscription, cantidad, cantidadInicial, inicial, isDark, precioIngresado, precioOriginal, producto, productoConPrecio, topeDescuento, validado

### `lib/features/pos/presentation/widgets/catalog/search_bar.dart`
- Imports: ../../providers/catalog_provider.dart, ../../providers/themes/app_colors.dart, ../../utils/responsive_helper.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CatalogSearchBar, class _ScanButton, class _ScanButtonState
- Funciones/metodos: build, createState
- Variables/campos: backgroundColor, borderColor, borderRadius, busqueda, buttonSize, focusNode, focusedColor, hintColor, iconSize, isDark, isHovered, isMobile, isPressed, onPressed, onScanPressed, scaleFactor, textColor

### `lib/features/pos/presentation/widgets/catalog/top_product_card.dart`
- Imports: ../../../data/Local/entities/producto_entity.dart, ../../providers/themes/app_colors.dart, package:flutter/material.dart
- Clases/tipos/componentes: class TopProductCard, class _TopProductCardState
- Funciones/metodos: build, createState
- Variables/campos: _isHovered, colorScheme, isDark, onAdd, producto

### `lib/features/pos/presentation/widgets/catalog/top_products_widget.dart`
- Imports: ../../../data/Local/entities/producto_entity.dart, ../../controllers/cart_controller.dart, ../../providers/catalog/top_products_provider.dart, ../../providers/themes/app_colors.dart, dart:ui, package:app_boosti_v2/features/pos/domain/models/product_item.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, quantity_dialog.dart, top_product_card.dart
- Clases/tipos/componentes: class TopProductsWidget, class _TopProductsWidgetState
- Funciones/metodos: _agregarAlCarrito, _buildBody, _buildHeader, _close, build, createState, dispose, initState
- Variables/campos: _controller, _fadeAnimation, _slideAnimation, cartNotifier, isDark, isMobile, itemParaCarrito, navigatorContext, onClose, panelWidth, producto, screenWidth, topProducts

### `lib/features/pos/presentation/widgets/catalog/view_mode_toggle.dart`
- Imports: ../../providers/catalog/view_mode_provider.dart, ../../providers/themes/app_colors.dart, ../../utils/responsive_helper.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class ViewModeToggle
- Funciones/metodos: build
- Variables/campos: currentMode, gridChild, isDark, isHovered, isMobile, listChild, selected

### `lib/features/pos/presentation/widgets/clientes/cliente_card.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class ClienteCard, class _ClienteCardState
- Funciones/metodos: _buildInfoRow, build, createState
- Variables/campos: activo, cliente, estadoColor, isDark, isHovered, onDelete, onEdit, onTap

### `lib/features/pos/presentation/widgets/clientes/cliente_form_dialog.dart`
- Imports: ../../providers/clientes/clientes_provider.dart, dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/cliente_entity.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:isar/isar.dart
- Clases/tipos/componentes: class ClienteFormDialog, class _ClienteFormDialogState
- Funciones/metodos: _guardar, build, createState, dispose, initState, mostrar
- Variables/campos: _direccionController, _documentoController, _emailController, _formKey, _isActivo, _isFrecuente, _isGuardando, _nombreController, _notasController, _telefonoController, c, cliente, clienteExistente, isDark, isEdit, isMobile, isar, localActivo, maxLines, screenSize

### `lib/features/pos/presentation/widgets/clientes/clientes_dialog.dart`
- Imports: ../../../data/Local/entities/cliente_entity.dart, ../../providers/clientes/clientes_provider.dart, cliente_card.dart, cliente_form_dialog.dart, dart:ui, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class ClientesDialog, class _ClientesDialogState
- Funciones/metodos: _agregarCliente, _buildList, _editarCliente, _eliminarCliente, build, createState, dispose, getClientesFiltrados, initState, show
- Variables/campos: _searchController, _searchQuery, _tabController, allClientes, base, cliente, doc, frecuentes, isDark, isMobile, nombre, q, screenSize

### `lib/features/pos/presentation/widgets/clientes/clientes_screen.dart`
- Imports: ../../providers/clientes/clientes_provider.dart, cliente_card.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class ClientesScreen, class _ClientesScreenState
- Funciones/metodos: build, createState, dispose
- Variables/campos: _mostrarFrecuentes, _searchController, _searchQuery, cliente, clientesFiltrados, clientesLocales, documento, isDark, nombre, query

### `lib/features/pos/presentation/widgets/cobrar_dialog.dart`
- Imports: ../providers/bcv_provider.dart, ../utils/input_decoration_helper.dart, ../utils/responsive_helper.dart, package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:flutter/material.dart, package:flutter/services.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CobrarDialog, class _CobrarDialogState
- Funciones/metodos: SingleActivator, _buildCamposPorMetodo, _buildDesktopButtons, _buildEfectivoFields, _buildMetodoChip, _buildMobileButtons, _buildPagoMovilFields, _buildPuntoFields, _confirmarPago, _getColorMetodo, _limpiarMetodos, _pagarExactoPagoMovil, _pagarExactoPunto, _pagarExactoUsd, build, createState, dispose, initState
- Variables/campos: _cedulaController, _cedulaFocus, _colorEfectivo, _colorPagoMovil, _colorPunto, _efectivoBsController, _efectivoUsdController, _efectivoUsdFocus, _metodoPagoSeleccionado, _nombreClienteController, _pagoMovilBsController, _puntoBsController, _referenciaController, colorMetodo, colorScheme, dialogWidth, diferenciaUsd, docTexto, documentoFinal, efUsd, efectivoBs, efectivoUsd, faltanteBs, faltanteUsd, isDark, isMobile, isTablet, metodoPrincipal, nombreCliente, pagoCompleto, pagoMovilBs, pmBs, ptBs, puntoBs, referencia, selected, tasaBcv, tasaValida, theme, totalAPagar, totalBs, totalRecibidoUsd, usuario, vueltoBs, vueltoUsd

### `lib/features/pos/presentation/widgets/dashboard/dashboard_skeleton.dart`
- Imports: package:flutter/material.dart, package:shimmer/shimmer.dart
- Clases/tipos/componentes: class DashboardSkeleton
- Funciones/metodos: build
- Variables/campos: baseColor, highlightColor, isDark, isMobile

### `lib/features/pos/presentation/widgets/dashboard/employee_activity.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class EmployeeActivity
- Funciones/metodos: _buildItem, build
- Variables/campos: color, colores, entries, isDark, isMobile, maxTotal, porcentaje

### `lib/features/pos/presentation/widgets/dashboard/low_stock_list.dart`
- Imports: ../../../data/Local/entities/producto_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class LowStockList
- Funciones/metodos: _buildItem, build
- Variables/campos: cantidadColor, colorBar, isDark, isMobile, mostrar, onVerInventario, porcentaje, productos

### `lib/features/pos/presentation/widgets/dashboard/metric_card.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class MetricCard, class _MetricCardState, class SparklinePainter
- Funciones/metodos: _animateEntry, build, createState, dispose, initState, paint, shouldRepaint
- Variables/campos: _controller, _isHovered, _opacity, _sparklineData, badge, color, colorBadge, data, height, iconBadge, icono, index, isMobile, lineWidth, maxValue, minValue, normalizedRange, padding, paint, path, range, subtitulo, subtituloColor, textoBadge, titulo, usableHeight, usableWidth, valor, variacion, variacionPositiva, width, x, y

### `lib/features/pos/presentation/widgets/dashboard/recent_sales_list.dart`
- Imports: ../../../data/Local/entities/venta_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class RecentSalesList
- Funciones/metodos: _buildItem, _getMetodoPagoColor, _getMetodoPagoIcon, build
- Variables/campos: cantidadArticulos, colorMetodo, fecha, hora, iconMetodo, isDark, isMobile, mostrar, onVerTodas, ventas

### `lib/features/pos/presentation/widgets/dashboard/sales_chart.dart`
- Imports: package:fl_chart/fl_chart.dart, package:flutter/material.dart
- Clases/tipos/componentes: class SalesChart, class _SalesChartState
- Funciones/metodos: _agruparPorSemanas, _calcularIntervalo, _calcularMaximo, _generarGhostData, _removeTooltip, _showTooltip, build, createState, dispose, if, initState
- Variables/campos: _animation, _chartKey, _controller, _periodoSeleccionado, _tooltipEntry, barIndex, barWidth, cantidad, chartHeight, color, colores, compacto, datos, datosFiltrados, datosUtiles, dia, diaSemana, dias, diasSemana, fecha, fechaStr, fin, grupo, hoy, index, isDark, isMobile, item, localPosition, max, overlay, renderBox, result, semana, semanas, start, titulo, total, totalSemana, valor

### `lib/features/pos/presentation/widgets/dashboard/top_products_list.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class TopProductsList
- Funciones/metodos: _buildItem, build
- Variables/campos: cantidad, colorRanking, isDark, isMobile, mostrar

### `lib/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart`
- Imports: ../../providers/usuario_provider.dart, ../dialogos_genericos/error_dialog.dart, ../dialogos_genericos/succes_dialog.dart, dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CrearDepartamentoDialog, class _CrearDepartamentoDialogState
- Funciones/metodos: _buildReadOnlyTile, _guardar, _inputDecor, build, createState, dispose, initState, showDialog
- Variables/campos: _activo, _descripcionController, _esDesdeLocal, _formKey, _isSaving, _localIdSeleccionado, _nombreController, _usuarioIdSeleccionado, borderColor, d, departamento, esEdicion, fillColor, isDark, local, localIdPreseleccionado, localesAsync, usuariosAsync, usuariosFiltrados

### `lib/features/pos/presentation/widgets/departamentos/detalle_departamento_dialog.dart`
- Imports: crear_departamento_dialog.dart, dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class DetalleDepartamentoDialog
- Funciones/metodos: _buildActionButtons, _buildDivider, _buildHeader, _buildInfoSection, _buildInfoTile, _buildNote, _toggleActivo, build
- Variables/campos: activo, actualizado, departamento, estadoColor, isDark, isMobile, isUpdating, localAsync, productosCount, usuarioAsync

### `lib/features/pos/presentation/widgets/dialogos_genericos/confirm_dialog.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class ConfirmDialog
- Funciones/metodos: build
- Variables/campos: confirmColor, confirmText, content, title

### `lib/features/pos/presentation/widgets/dialogos_genericos/dialogos_genericos.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class ConfirmDialog
- Funciones/metodos: build
- Variables/campos: confirmColor, confirmText, content, onConfirm, title

### `lib/features/pos/presentation/widgets/dialogos_genericos/error_dialog.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class ErrorDialog
- Funciones/metodos: build
- Variables/campos: content, title

### `lib/features/pos/presentation/widgets/dialogos_genericos/succes_dialog.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class SuccessDialog
- Funciones/metodos: build
- Variables/campos: content, title

### `lib/features/pos/presentation/widgets/gastos/gastos_detail_dialog.dart`
- Imports: ../../../data/Local/entities/gasto_entity.dart, ../../providers/bcv_provider.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class GastosDetailDialog
- Funciones/metodos: _buildListDialog, _buildSingleDetail, build
- Variables/campos: categoryIcon, color, colorScheme, fechaLocal, fechaStr, g, gasto, gastos, montoBs, montoEnBs, montoUSD, tasaBcv, title

### `lib/features/pos/presentation/widgets/gastos/gastos_filter_bar.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class GastosFilterBar, class _PeriodButton, class _PeriodButtonState
- Funciones/metodos: _buildBoxShadow, _buildDateSelectors, build, createState
- Variables/campos: anioSeleccionado, aniosDisponibles, borderColor, borderRadius, colorScheme, fontSize, horizontalPadding, icon, iconSize, isHovering, isMobile, isTablet, label, mesSeleccionado, mesesDropdown, null, onAnioChanged, onMesChanged, onPeriodChanged, onTap, selected, selectedColor, selectedPeriod, verticalPadding

### `lib/features/pos/presentation/widgets/gastos/gastos_item.dart`
- Imports: ../../../data/Local/entities/gasto_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class GastosItem, class _GastosItemState
- Funciones/metodos: build, createState
- Variables/campos: _isHovering, categoryIcon, categoryIconSize, chevronSize, colorMonto, colorScheme, fechaLocal, fechaStr, fontSizeDesc, fontSizeFecha, fontSizeMonto, gasto, horizontalPadding, iconInnerSize, iconSize, isDark, isMobile, isTablet, montoStr, onTap, verticalPadding

### `lib/features/pos/presentation/widgets/gastos/gastos_list.dart`
- Imports: ../../../data/Local/entities/gasto_entity.dart, gastos_item.dart, package:flutter/material.dart
- Clases/tipos/componentes: class GastosList
- Funciones/metodos: build
- Variables/campos: colorScheme, gasto, gastos, isMobile, isTablet, shrinkWrap

### `lib/features/pos/presentation/widgets/gastos/gastos_search_bar.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class GastosSearchBar, class _CategoryChip, class _CategoryChipState
- Funciones/metodos: build, createState
- Variables/campos: borderRadius, categories, colorScheme, esSeleccionado, fontSize, horizontalPadding, isDark, isHovering, isMobile, isTablet, label, onCategorySelected, onSearchChanged, onTap, searchQuery, selected, selectedCategory, verticalPadding

### `lib/features/pos/presentation/widgets/gastos/gastos_summary_cards.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class GastosSummaryCards
- Funciones/metodos: build
- Variables/campos: cardMinWidth, colorScheme, fontSizeResumen, fontSizeResumenValor, fontSizeTitle, fontSizeValue, gastosCount, iconSize, isDark, isMobile, isTablet, padding, spacingWrap, totalBs, totalUSD

### `lib/features/pos/presentation/widgets/gestion_personal_dialog.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/log_entity.dart, ../../data/Local/entities/usuario_entity.dart, ../providers/usuario_provider.dart, ../services/sync_service.dart, ../utils/responsive_helper.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:supabase_flutter/supabase_flutter.dart
- Clases/tipos/componentes: class PersonnelManagementDialog, class _PersonnelManagementDialogState
- Funciones/metodos: _cargarUsuarios, _crearUsuario, _editarUsuario, _eliminarUsuario, _getPasswordColor, _getPasswordIcon, _getPasswordScore, _getPasswordStrength, _limpiarUsuariosHuerfanos, build, createState, dispose, initState
- Variables/campos: _cargando, _emailController, _formKey, _guardando, _isarService, _nombreController, _obscurePassword, _passwordController, _pinController, _rolSeleccionado, _syncService, _tabController, _usuarios, avatarColor, colorScheme, confirm, editando, eliminados, emailController, estadoColor, estadoIcon, estadoTexto, formKey, hasDigits, hasLowercase, hasSpecial, hasUppercase, isActive, isAdmin, isDark, isMobile, isSynced, isTablet, length, limpiados, mensaje, neonColor, newPassword, nombreController, nuevoUsuario, null, obscureEditPassword, password, passwordController, pinController, response, rolSeleccionado, rolTexto, score, strength, supabase, theme, usuario, usuarioActual, usuarios

### `lib/features/pos/presentation/widgets/idle_detector_widget.dart`
- Imports: ../providers/lock_provider.dart, dart:async, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class UserActivityDetector, class _UserActivityDetectorState
- Funciones/metodos: _lockScreen, _resetTimer, _startTimer, build, createState, dispose, initState
- Variables/campos: _inactivityTimer, child, isLocked, timeout

### `lib/features/pos/presentation/widgets/inventory/barcode_generator_dialog.dart`
- Imports: ../../../data/Local/entities/isar_service.dart, ../../services/ticket_service.dart, ../../utils/responsive_helper.dart, dart:io, dart:ui, package:barcode_widget/barcode_widget.dart, package:flutter/material.dart, package:flutter/rendering.dart, package:flutter_riverpod/flutter_riverpod.dart, package:path_provider/path_provider.dart, package:share_plus/share_plus.dart
- Clases/tipos/componentes: class BarcodeGeneratorDialog, class _BarcodeGeneratorDialogState
- Funciones/metodos: _compartirCodigo, _generarCodigo, _imprimirCodigo, build, createState, initState
- Variables/campos: _cargando, _codigo, _previewKey, barcodeHeight, barcodeWidth, boundary, byteData, bytes, codigo, file, image, imageBytes, isMobile, isTablet, tempDir

### `lib/features/pos/presentation/widgets/inventory/categoria_form_dialog.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class CategoriaFormDialog, class _CategoriaFormDialogState
- Funciones/metodos: build, createState, dispose, initState
- Variables/campos: _controller, _focusNode, _formKey, categoriaExistente, colorScheme, isEditing, null

### `lib/features/pos/presentation/widgets/inventory/categorias_management_dialog.dart`
- Imports: ../../../data/Local/entities/isar_service.dart, ../../providers/categorias_provider.dart, ../../providers/productos_provider.dart, categoria_form_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CategoriasManagementDialog, class _CategoriasManagementDialogState
- Funciones/metodos: _migrarCategorias, build, createState, dispose
- Variables/campos: _focusNode, _migrando, _newCategoryController, actualizados, categoria, categorias, colorScheme, idCat, isar, nombreCat, notifier, nuevoNombre, productos, sinCategoria, value

### `lib/features/pos/presentation/widgets/inventory/inventory_category_chips.dart`
- Imports: ../../providers/categorias_provider.dart, ../../providers/inventory_provider.dart, ../../utils/responsive_helper.dart, ../catalog/category_button.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class InventoryCategoryChips
- Funciones/metodos: build
- Variables/campos: categoriaSeleccionadaNombre, categoriasAsync, esSeleccionada, isTablet, items, nombre

### `lib/features/pos/presentation/widgets/inventory/inventory_product_card.dart`
- Imports: ../../../data/Local/entities/producto_entity.dart, ../../providers/marca_provider.dart, ../../providers/themes/app_colors.dart, ../../utils/responsive_helper.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class InventoryProductCard, class _InventoryProductCardState
- Funciones/metodos: build, createState
- Variables/campos: _isHovering, animationController, badgeFontSize, badgePadding, cardBackground, cardBorderColor, cardShadow, child, colorScheme, end, fontSizeCodigo, fontSizeMarca, fontSizeNombre, fontSizePrecio, fontSizeStock, index, isDark, isMobile, isSelected, isTablet, marcaNombreAsync, onLongPress, onTap, producto, scale, start, stockBajo, stockDisplay, stockValue, typeBadgeFontSize, typeBadgePadding

### `lib/features/pos/presentation/widgets/inventory/inventory_product_card_skeleton.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class InventoryProductCardSkeleton
- Funciones/metodos: build
- Variables/campos: colorScheme

### `lib/features/pos/presentation/widgets/inventory/inventory_search_bar.dart`
- Imports: ../../providers/themes/app_colors.dart, ../../utils/responsive_helper.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class InventorySearchBar, class _ScanButton, class _ScanButtonState
- Funciones/metodos: build, createState
- Variables/campos: backgroundColor, borderColor, focusedColor, hintColor, isDark, isHovered, isMobile, isPressed, onPressed, onScanPressed, onSearchChanged, scaleFactor, textColor

### `lib/features/pos/presentation/widgets/inventory/marca_form_dialog.dart`
- Imports: ../../../data/Local/entities/isar_service.dart, ../../../data/Local/entities/marca_entity.dart, ../../../data/Local/entities/proveedor_entity.dart, ../../providers/marca_provider.dart, ../../utils/responsive_helper.dart, ../proveedores/crear_proveedor_dialog.dart, dart:io, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:image_picker/image_picker.dart, package:permission_handler/permission_handler.dart, package:supabase_flutter/supabase_flutter.dart
- Clases/tipos/componentes: class MarcaFormDialog, class _MarcaFormDialogState
- Funciones/metodos: _buildAcciones, _buildHeader, _buildImagenSection, _buildSelectorProveedor, _campoDescripcion, _campoNombre, _cargarProveedorSeleccionado, _cargarProveedores, _checkPermission, _crearProveedorRapido, _guardar, _limpiarImagen, _mostrarError, _seleccionarImagen, _seleccionarProveedor, _uploadLogo, build, createState, dispose, initState
- Variables/campos: _cargandoProveedores, _descripcionController, _formKey, _guardando, _imagenSeleccionada, _logoUrl, _nombreController, _proveedorBusquedaController, _proveedorSeleccionado, _proveedores, _subiendoImagen, buttonPadding, colorScheme, esEdicion, ext, fileName, image, isDark, isMobile, isar, logoUrlFinal, marca, notifier, null, onGuardar, option, picker, proveedor, proveedores, publicUrl, query, result, status, url

### `lib/features/pos/presentation/widgets/inventory/marcas_managment_dialog.dart`
- Imports: ../../../data/Local/entities/isar_service.dart, ../../../data/Local/entities/marca_entity.dart, ../../providers/marca_provider.dart, ../../utils/responsive_helper.dart, marca_form_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class MarcasManagementDialog, class _MarcasManagementDialogState
- Funciones/metodos: _buildActions, _buildFilterChip, _buildHeader, _buildList, _buildMarcaTile, _buildSearchAndFilters, _confirmarEliminacion, _marcasFiltradas, _mostrarFormulario, _mostrarMensaje, _toggleActivo, build, createState, dispose
- Variables/campos: _filter, _searchController, _searchQuery, colorScheme, eliminada, filtered, isActive, isMobile, isSelected, isar, marca, marcas, marcasAsync, notifier, q

### `lib/features/pos/presentation/widgets/inventory/product_detail_dialog.dart`
- Imports: ../../../data/Local/entities/producto_entity.dart, ../../../data/Local/entities/proveedor_entity.dart, ../../providers/esc_pos_provider.dart, ../../providers/proveedores_provider.dart, ../../services/label_generator.dart, ../../services/printer_service.dart, ../../utils/responsive_helper.dart, package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/log_entity.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class ProductDetailDialog
- Funciones/metodos: _buildCategoriaStockMinimo, _buildHeader, _buildImageSection, _buildInfoPrincipal, _buildPlaceholder, _buildPrecioStock, build
- Variables/campos: buttonPadding, colorScheme, confirm, esAdmin, isActivo, isDark, isMobile, label, onEditar, onEliminar, producto, proveedorAsync, result, selectedPrinter

### `lib/features/pos/presentation/widgets/inventory/product_form_dialog.dart`
- Imports: ../../../data/Local/entities/categoria_entity.dart, ../../../data/Local/entities/isar_service.dart, ../../../data/Local/entities/marca_entity.dart, ../../../data/Local/entities/producto_entity.dart, ../../../data/Local/entities/proveedor_entity.dart, ../../../data/Local/entities/usuario_entity.dart, ../../providers/categorias_provider.dart, ../../providers/productos_provider.dart, ../../services/sync_service.dart, ../../utils/responsive_helper.dart, ../proveedores/crear_proveedor_dialog.dart, ../shared/barcode_scanner_dialog.dart, dart:io, package:collection/collection.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:image_picker/image_picker.dart, package:isar/isar.dart, package:lottie/lottie.dart, package:permission_handler/permission_handler.dart, package:shared_preferences/shared_preferences.dart, package:supabase_flutter/supabase_flutter.dart, product_detail_dialog.dart
- Clases/tipos/componentes: class ProductFormDialog, class _ProductFormDialogState, class _ProveedoresPanelDialog, class _ProveedoresPanelDialogState
- Funciones/metodos: _abrirPanelProveedores, _buildAcciones, _buildHeader, _buildImageSection, _buildLottieWithFallback, _buildPrecioStock, _buildProductTab, _buildProveedorSeleccionadoCard, _buildProveedorTab, _buildSelectorProveedor, _buildSwitchActivo, _buildSwitchPesado, _campoCategoriaSelector, _campoCodigoBarras, _campoNombre, _campoPrecio, _campoSelectorMarca, _campoStock, _campoStockMinimo, _cargarMarcas, _cargarProveedores, _checkPermission, _crearProveedorRapido, _escanearCodigoBarras, _generarCodigoBarras, _guardar, _guardarBorrador, _limpiarImagen, _mostrarDialogoExito, _mostrarFormularioEdicion, _recuperarBorrador, _seleccionarImagen, _seleccionarMarca, _seleccionarProveedor, _uploadImage, build, createState, dispose, initState
- Variables/campos: _DRAFT_KEY, _activo, _busqueda, _busquedaController, _cargandoMarcas, _cargandoProveedores, _categoriaIdSeleccionada, _categoriaSeleccionada, _codigoController, _esPesado, _filtroMarca, _filtroMarcaController, _formKey, _generandoCodigo, _guardando, _imagenSeleccionada, _imagenUrlPreview, _marcaBusquedaController, _marcaSeleccionada, _marcas, _nombreController, _precioController, _proveedorBusquedaController, _proveedorNombreController, _proveedorSeleccionado, _proveedorTelController, _proveedores, _stockController, _stockMinController, _subiendoImagen, _tabController, accion, buttonPadding, categoriaSeleccionada, categoriasAsync, codigo, codigoBarrasPrecargado, color, colorScheme, draft, draftStr, esDuplicado, esEdicion, esError, ext, fileName, image, imagenUrlFinal, isActive, isActivo, isDark, isMobile, isar, lista, marcas, nuevo, null, onCrearProveedor, option, p, picker, prefs, producto, productoExistente, productos, productosNotifier, proveedor, proveedorSeleccionado, proveedores, publicUrl, q, query, result, seleccionado, status, stockBase, syncService, url, usuarioActual, val

### `lib/features/pos/presentation/widgets/locales/crear_local_dialog.dart`
- Imports: ../dialogos_genericos/error_dialog.dart, ../dialogos_genericos/succes_dialog.dart, dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/locales_provider.dart, package:app_boosti_v2/features/pos/presentation/services/sync_service.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CrearLocalDialog, class _CrearLocalDialogState
- Funciones/metodos: _guardar, _inputDecor, build, createState, dispose, initState
- Variables/campos: _activo, _direccionController, _emailController, _formKey, _isSaving, _nombreController, _rifController, _telefonoController, borderColor, emailRegExp, esEdicion, fillColor, isDark, l, local, null

### `lib/features/pos/presentation/widgets/locales/detalle_local_dialog.dart`
- Imports: ../../../data/Local/entities/isar_service.dart, ../dialogos_genericos/dialogos_genericos.dart, dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/departamento_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:app_boosti_v2/features/pos/presentation/services/sync_service.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/departamentos/detalle_departamento_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, seleccionar_departamento_dialog.dart, seleccionar_empleados_dialog.dart
- Clases/tipos/componentes: class DetalleLocalDialog, class _DetalleLocalDialogState
- Funciones/metodos: _agregarDepartamento, _agregarEmpleado, _buildDepartamentosTab, _buildDivider, _buildEmpleadosTab, _buildHeader, _buildInfoTab, _buildInfoTile, _buildNote, _buildTabs, _desasignarEmpleado, _mostrarDetalleDepartamento, build, createState, dispose, initState
- Variables/campos: _tabController, confirm, d, departamentosAsync, disponibles, empleado, empleadosAsync, estadoColor, iconOnly, isDark, isMobile, isar, local, locales, localesIds, result, seleccionados, selectedStyle, textStyle, todos, u, usuarioAsync

### `lib/features/pos/presentation/widgets/locales/empleados_departamento_dialogo.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class EmpleadosPorDepartamentoDialog
- Funciones/metodos: build
- Variables/campos: colorScheme, departamentosAsync, deptoId, deptoNombre, empleadosAsync, isMobile, key, keys, lista, localId

### `lib/features/pos/presentation/widgets/locales/local_card.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:flutter/material.dart
- Clases/tipos/componentes: class LocalCard, class _LocalCardState
- Funciones/metodos: build, createState
- Variables/campos: _isHovered, activo, estadoColor, estadoTexto, isDark, isLocalActual, isMobile, local, onDelete, onEdit, onTap, onToggleActivo

### `lib/features/pos/presentation/widgets/locales/seleccionar_departamento_dialog.dart`
- Imports: dart:ui, package:app_boosti_v2/features/pos/presentation/providers/departamentos_provider.dart, package:app_boosti_v2/features/pos/presentation/widgets/departamentos/crear_departamento_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class SeleccionarDepartamentoDialog, class _SeleccionarDepartamentoDialogState
- Funciones/metodos: _crearNuevoDepartamento, build, createState
- Variables/campos: d, departamentosAsync, disponibles, isDark, localId, result

### `lib/features/pos/presentation/widgets/locales/seleccionar_empleados_dialog.dart`
- Imports: dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class SeleccionarEmpleadosDialog, class _SeleccionarEmpleadosDialogState
- Funciones/metodos: build, createState
- Variables/campos: _seleccionados, empleado, empleadosDisponibles, isDark, isSelected, localId

### `lib/features/pos/presentation/widgets/lotes/detalle_lote_dialog.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:app_boosti_v2/features/pos/presentation/widgets/lotes/editar_lote_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/lotes/historial_codigos_dialog.dart, package:app_boosti_v2/features/pos/presentation/widgets/lotes/traspaso_lote_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:intl/intl.dart
- Clases/tipos/componentes: class DetalleLoteDialog, class _DetalleLoteDialogState
- Funciones/metodos: _buildInfoRow, _confirmarEliminar, _getColor, _getIcon, build, createState, initState
- Variables/campos: _isar, _movimientosFuture, colorScheme, esAdmin, exito, lote, m, movimientos, producto, usuario

### `lib/features/pos/presentation/widgets/lotes/editar_lote_dialog.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart, package:app_boosti_v2/features/pos/presentation/widgets/shared/barcode_scanner_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class EditarLoteDialog, class _EditarLoteDialogState
- Funciones/metodos: _applyDateMask, _cargarProductoNombre, _escanearCodigo, _formatDate, _guardar, _parseDate, build, createState, dispose, initState
- Variables/campos: _codigoController, _errorMessage, _isLoading, _isar, _productoNombre, _vencimientoController, _vencimientoFocus, codigo, colorScheme, date, day, digits, formatted, lote, month, nuevaFecha, parts, producto, year

### `lib/features/pos/presentation/widgets/lotes/historial_codigos_dialog.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:intl/intl.dart
- Clases/tipos/componentes: class HistorialCodigosDialog, class _HistorialCodigosDialogState
- Funciones/metodos: build, createState, initState
- Variables/campos: _historialFuture, _isar, colorScheme, isDark, items, productoId, productoNombre

### `lib/features/pos/presentation/widgets/lotes/lotes_card.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart, package:flutter/material.dart, package:intl/intl.dart
- Clases/tipos/componentes: class LoteCard
- Funciones/metodos: _getEstadoColor, _getEstadoIcon, _getEstadoTexto, build
- Variables/campos: colorScheme, dias, diasColor, diasRestantes, esAdmin, estado, estadoColor, estadoIcon, estadoTexto, fechaIngreso, fechaVencimiento, isProximoAVencer, lote, onReponer, onTap, onVerificar, productoNombre

### `lib/features/pos/presentation/widgets/lotes/lotes_category_chips.dart`
- Imports: ../../providers/categorias_provider.dart, ../../providers/lotes_provider.dart, ../../utils/responsive_helper.dart, ../catalog/category_button.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class LotesCategoryChips
- Funciones/metodos: build
- Variables/campos: categoriaSeleccionada, categoriasAsync, esSeleccionada, isTablet, items, nombre

### `lib/features/pos/presentation/widgets/lotes/traspaso_lote_dialog.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/movimiento_lote_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/invalidation/invalidation_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class TraspasoLoteDialog, class _TraspasoLoteDialogState
- Funciones/metodos: _confirmar, build, createState, dispose, initState
- Variables/campos: _cantidadController, _errorMessage, _isLoading, _isar, cantidad, colorScheme, lote, producto, usuario

### `lib/features/pos/presentation/widgets/lotes/verificar_lote_dialog.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/codigo_barra_alia_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/lote_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/invalidation/invalidation_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:app_boosti_v2/features/pos/presentation/utils/input_decoration_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/shared/barcode_scanner_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class VerificarLoteDialog, class _VerificarLoteDialogState
- Funciones/metodos: _confirmarVerificacion, _escanearCodigo, _validarCodigo, build, createState, dispose, initState
- Variables/campos: _cantidadController, _codigoController, _codigoValidado, _codigoValidadoTexto, _errorMessage, _isLoading, _isar, alias, cantidad, codigo, colorScheme, crearAlias, exito, isDark, lote, otroProducto, producto, usuario

### `lib/features/pos/presentation/widgets/menu/diagnostico_lote_dialog.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class DiagnosticoLotesDialog, class _DiagnosticoLotesDialogState
- Funciones/metodos: _cargarDiagnostico, _ejecutarMigracion, _obtenerDiagnostico, build, createState, initState
- Variables/campos: _isMigrating, ancho, cobertura, colorScheme, confirm, data, isDark, isMobile, isar, lotesProducto, porcentaje, productos, productosConStockSinLote, productosSinLote, productosSinLoteCount, result, todosLosLotes, totalLotes, totalProductos

### `lib/features/pos/presentation/widgets/menu/pos_menu_card.dart`
- Imports: ../../utils/responsive_helper.dart, package:flutter/material.dart
- Clases/tipos/componentes: class PosMenuCard
- Funciones/metodos: build
- Variables/campos: color, icon, isMobile, isTablet, onTap, subtitle, theme, title

### `lib/features/pos/presentation/widgets/menu/turno_closing_dialog.dart`
- Imports: package:flutter/material.dart, package:lottie/lottie.dart
- Clases/tipos/componentes: class TurnoClosingDialog
- Funciones/metodos: _buildLottieWithFallback, build
- Variables/campos: colorScheme, fechaApertura, fechaStr, montoFinal, montoInicial, onConfirm

### `lib/features/pos/presentation/widgets/menu/turno_status_banner.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class TurnoStatusBanner
- Funciones/metodos: build
- Variables/campos: baseColor, horaApertura, icon, onAbrirTurno, onCerrarTurno, theme, tieneTurno

### `lib/features/pos/presentation/widgets/monitor_empleado_widget.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/usuario_entity.dart, ../services/sync_service.dart, ../utils/responsive_helper.dart, dart:async, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class EmployeeMonitorDialog, class _EmployeeMonitorDialogState
- Funciones/metodos: _actualizarEstadosDesdeNube, _cargarUsuarios, _cargarUsuariosLocal, _sincronizarYActualizar, build, createState, dispose, initState
- Variables/campos: _departamentoSeleccionado, _departamentos, _error, _isLoading, _isarService, _syncService, _timer, _usuarios, depts, dialogMaxHeight, dialogWidth, estadoColor, estadoIcon, estadoNube, estadoTexto, filtrados, id, isActive, isAdmin, isDescanso, isInactive, isMobile, isTablet, locales, nubeUsuarios, theme, todos, usuario

### `lib/features/pos/presentation/widgets/panel/cambiar_cajero_dialog.dart`
- Imports: ../../../data/Local/entities/usuario_entity.dart, ../../providers/auth_provider.dart, dart:ui, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CambiarCajeroDialog, class _CambiarCajeroDialogState
- Funciones/metodos: _confirmarCambio, _getColorFromString, build, createState, dispose
- Variables/campos: _isLoading, _pinController, _selectedCajero, authNotifier, authState, avatarColor, cajero, cajerosDisponibles, colorScheme, colors, currentUser, index, initial, isDark, isSelected, pin, success

### `lib/features/pos/presentation/widgets/panel/descuentos_especiales_dialog.dart`
- Imports: ../../../domain/models/cart_item.dart, ../../controllers/cart_controller.dart, ../../providers/bcv_provider.dart, ../admin_validation_dialog.dart, ../dialogos_genericos/confirm_dialog.dart, ../dialogos_genericos/error_dialog.dart, ../dialogos_genericos/succes_dialog.dart, dart:ui, package:flutter/material.dart, package:flutter/services.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class DescuentoEspecialDialog, class _DescuentoEspecialDialogState
- Funciones/metodos: _aplicarDescuento, _buildActions, _buildEmptyState, _buildFooter, _buildHeader, _buildPriceField, _buildProductList, _mostrarError, _restaurarPrecioOriginal, _seleccionarProducto, build, createState, dispose, show
- Variables/campos: _isLoading, _precioController, _selectedProductId, adminValidado, ahorro, confirmado, continuar, hasDescuento, hasDiscount, hasItems, isDark, isMobile, isSelected, item, nuevoPrecio, null, original, precio, precioOriginal, priceValid, screenSize, selected, tieneDescuento, total, totalBs, totalConDescuento

### `lib/features/pos/presentation/widgets/panel/keyboard_shortcuts_dialog.dart`
- Imports: dart:ui, package:flutter/material.dart
- Clases/tipos/componentes: class KeyboardShortcutsDialog, class _Shortcut
- Funciones/metodos: _buildShortcutTile, build, show
- Variables/campos: color, description, futureShortcuts, isDark, isFuture, isMobile, key, screenSize, shortcuts

### `lib/features/pos/presentation/widgets/panel/panel_button.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class PanelButton, class _PanelButtonState
- Funciones/metodos: build, createState
- Variables/campos: _isHovered, color, icon, isDark, label, onTap

### `lib/features/pos/presentation/widgets/panel/panel_header.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class PanelHeader
- Funciones/metodos: build
- Variables/campos: isDark, onClose

### `lib/features/pos/presentation/widgets/panel/productos_inactivos_dialog.dart`
- Imports: ../../../data/Local/entities/isar_service.dart, ../../../data/Local/entities/producto_entity.dart, ../../providers/productos_provider.dart, ../../services/sync_service.dart, ../dialogos_genericos/confirm_dialog.dart, ../dialogos_genericos/error_dialog.dart, ../dialogos_genericos/succes_dialog.dart, dart:ui, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class ProductosInactivosDialog, class _ProductosInactivosDialogState, class _ProductoInactivoTile
- Funciones/metodos: _cargarProductosInactivos, _eliminarProducto, _reactivarProducto, build, createState, initState, show
- Variables/campos: _isLoading, _isarService, _productosInactivos, confirmado, inactivos, isDark, isMobile, onEliminar, onReactivar, producto, productos, screenSize

### `lib/features/pos/presentation/widgets/panel/side_panel.dart`
- Imports: ../../../data/Local/entities/isar_service.dart, ../../../data/Local/entities/log_entity.dart, ../../../data/Local/entities/usuario_entity.dart, ../../controllers/panel_controller.dart, ../../providers/auth_provider.dart, ../../providers/lock_provider.dart, ../../providers/usuario_provider.dart, ../../services/sync_service.dart, ../clientes/clientes_dialog.dart, ../printer_selection_widget.dart, cambiar_cajero_dialog.dart, dart:ui, descuentos_especiales_dialog.dart, keyboard_shortcuts_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:provider/provider.dart, panel_button.dart, panel_header.dart, productos_inactivos_dialog.dart, theme_toggle_tile.dart
- Clases/tipos/componentes: class SidePanel, class _SidePanelState, class _Category, class _PanelItem, class _DialogoDescanso
- Funciones/metodos: _buildButtonList, _buildCategoryHeader, _closePanel, _mostrarCambiarCajero, build, createState, dispose, initState
- Variables/campos: _controller, _fadeAnimation, _slideAnimation, action, authState, cat, categories, color, colorScheme, controller, currentUser, icon, isDark, isar, items, label, lockNotifier, onClose, onConfirm, panelWidth, puedeCambiarCajero, ref, screenContext, screenWidth, sync, title, usuario, usuarioActual

### `lib/features/pos/presentation/widgets/panel/theme_toggle_tile.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class ThemeToggleTile
- Funciones/metodos: build
- Variables/campos: isDark, onTap

### `lib/features/pos/presentation/widgets/pedidos/acciones_pedido.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, registrar_recepcion_dialog.dart
- Clases/tipos/componentes: class AccionesPedido
- Funciones/metodos: build
- Variables/campos: confirm, isDark, isMobile, onActualizar, pedido, result

### `lib/features/pos/presentation/widgets/pedidos/crear_pedido_dialog.dart`
- Imports: dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/bcv_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CrearPedidoDialog, class _CrearPedidoDialogState
- Funciones/metodos: _actualizarCantidad, _actualizarCantidadControllerPrincipal, _agregarProducto, _buildBotones, _buildHeader, _buildListaProductosAgregados, _buildProveedorSection, _buildResumenYObservaciones, _buildTotalPagar, _calcularCostoUnitarioEfectivo, _calcularTotalUnidades, _cargarDatosIniciales, _filtrarProveedoresPorCategoria, _guardarPedido, _inputDecor, build, createState, dispose, initState
- Variables/campos: _bultosCantidadController, _bultosPrecioPorBultoController, _bultosUnidadesPorBultoController, _busquedaProveedorController, _cantidadController, _cantidadFocusNode, _categoriaSeleccionada, _categorias, _detalles, _isSaving, _modoBultos, _observacionesController, _productoSeleccionadoId, _proveedorSeleccionado, _unidadesCantidadController, _unidadesPrecioController, bultos, cantidad, categoria, categorias, categoriasList, categoriasSet, costoUnitario, d, detalle, id, index, isDark, isMobile, isar, option, pedido, pedidoId, precioBulto, precioUnitario, producto, productos, productosAsync, productosFiltrados, productosFiltradosAsync, productosOrdenados, provCats, proveedoresAsync, proveedoresFiltrados, subtotalProducto, tasaBcv, totalBs, totalPedido, totalUnidades, undPorBulto

### `lib/features/pos/presentation/widgets/pedidos/detalle_pedido_dialog.dart`
- Imports: dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/acciones_pedido.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalles_list.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/info_pedido.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/info_recepcion.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class DetallePedidoDialog, class _DetallePedidoDialogState
- Funciones/metodos: _buildHeader, _cargarDatos, build, createState, initState
- Variables/campos: _detallesFuture, _pedidoFuture, _recepcionFuture, detalles, isDark, isMobile, isar, pedido, pedidoId, recepcion

### `lib/features/pos/presentation/widgets/pedidos/detalle_producto_card.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class DetalleProductoCard
- Funciones/metodos: build
- Variables/campos: detalle, onEliminar

### `lib/features/pos/presentation/widgets/pedidos/detalles_list.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:flutter/material.dart
- Clases/tipos/componentes: class DetallesList
- Funciones/metodos: build
- Variables/campos: detalles, isDark, isMobile, total

### `lib/features/pos/presentation/widgets/pedidos/estado_chip.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:flutter/material.dart
- Clases/tipos/componentes: class EstadoChip
- Funciones/metodos: _getColor, _getIcon, build
- Variables/campos: color, estado, icon, isMobile

### `lib/features/pos/presentation/widgets/pedidos/info_pedido.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/estado_chip.dart, package:flutter/material.dart, package:intl/intl.dart
- Clases/tipos/componentes: class InfoPedido
- Funciones/metodos: _buildInfoItem, build
- Variables/campos: isDark, isMobile, pedido

### `lib/features/pos/presentation/widgets/pedidos/info_recepcion.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/recepcion_entity.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:flutter/material.dart, package:intl/intl.dart
- Clases/tipos/componentes: class InfoRecepcion
- Funciones/metodos: build
- Variables/campos: isDark, isMobile, recepcion

### `lib/features/pos/presentation/widgets/pedidos/Multi_select_dialog.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class MultiSelectDialog, class _MultiSelectDialogState
- Funciones/metodos: build, createState
- Variables/campos: _selectedIds, cancelText, confirmText, isSelected, items, producto, seleccionados, title

### `lib/features/pos/presentation/widgets/pedidos/pedido_card.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart, package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/estado_chip.dart, package:flutter/material.dart, package:intl/intl.dart
- Clases/tipos/componentes: class PedidoCard
- Funciones/metodos: _getCantidadProductos, _getColor, build
- Variables/campos: cantidad, detalles, isDark, isMobile, isar, onTap, pedido

### `lib/features/pos/presentation/widgets/pedidos/producto_selector.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class ProductoSelector
- Funciones/metodos: build
- Variables/campos: cantidadController, colorScheme, isDark, onAgregar, precioController, productos, valorSeleccionado

### `lib/features/pos/presentation/widgets/pedidos/provedor_autocomplete.dart`
- Imports: ../../../data/Local/entities/proveedor_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class ProveedorAutocomplete
- Funciones/metodos: build
- Variables/campos: colorScheme, isDark, option, proveedores

### `lib/features/pos/presentation/widgets/pedidos/registrar_recepcion_dialog.dart`
- Imports: package:app_boosti_v2/features/pos/presentation/providers/pedidos_provider.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class RegistrarRecepcionDialog, class _RegistrarRecepcionDialogState
- Funciones/metodos: build, createState, dispose
- Variables/campos: _isLoading, _observacionesController, pedidoId, userId

### `lib/features/pos/presentation/widgets/pedidos/resumen_pedido.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/detalle_pedido_entity.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/detalle_producto_card.dart, package:flutter/material.dart
- Clases/tipos/componentes: class ResumenPedido
- Funciones/metodos: build
- Variables/campos: detalles

### `lib/features/pos/presentation/widgets/pos_summary_panel.dart`
- Imports: ../utils/responsive_helper.dart, package:flutter/material.dart
- Clases/tipos/componentes: class PosSummaryPanel
- Funciones/metodos: _buildRow, build
- Variables/campos: buttonFontSize, buttonHeight, fontSize, impuesto, isMobile, isTablet, onLimpiarPressed, onPagarPressed, paddingHorizontal, paddingVertical, subtotal, total

### `lib/features/pos/presentation/widgets/printer_selection_widget.dart`
- Imports: ../../domain/enums/printer_error.dart, ../../domain/models/printer_models.dart, ../providers/esc_pos_provider.dart, ../services/printer_service.dart, ../widgets/dialogos_genericos/confirm_dialog.dart, ../widgets/dialogos_genericos/error_dialog.dart, dialogos_genericos/succes_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class PrinterSelectionDialog, class _PrinterSelectionDialogState
- Funciones/metodos: _confirmDisconnect, _getErrorMessage, _scan, _selectPrinter, _showAddNetworkPrinterDialog, _testPrinter, build, createState, initState
- Variables/campos: _devices, _isScanning, _printerService, _printerType, _selectedAddress, current, currentPrinter, device, errorMessage, ipController, isMobile, isSelected, nameController, printer, result, results

### `lib/features/pos/presentation/widgets/proveedores/crear_proveedor_dialog.dart`
- Imports: dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart, package:app_boosti_v2/features/pos/presentation/services/sync_service.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CrearProveedorDialog, class _CrearProveedorDialogState
- Funciones/metodos: _guardar, _inputDecor, build, createState, dispose, initState
- Variables/campos: _activo, _cedulaController, _direccionController, _emailController, _formKey, _isSaving, _nombreController, _telefonoController, digits, direccion, email, esEdicion, isDark, isMobile, nombre, null, p, proveedor, syncService

### `lib/features/pos/presentation/widgets/proveedores/detalle_proveedor_dialog.dart`
- Imports: dart:ui, package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart, package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart, package:app_boosti_v2/features/pos/presentation/providers/proveedores_provider.dart, package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart, package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart, package:app_boosti_v2/features/pos/presentation/widgets/pedidos/multi_select_dialog.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class DetalleProveedorDialog
- Funciones/metodos: _buildHeader, _buildInfoChip, _buildInfoSection, _mostrarDialogoAsignarProductos, build
- Variables/campos: esAdmin, estadoColor, isDark, isMobile, isar, p, productosAsync, productosSinProveedor, proveedor, seleccionados, todosLosProductos, usuario

### `lib/features/pos/presentation/widgets/proveedores/proveedor_card.dart`
- Imports: package:app_boosti_v2/features/pos/data/Local/entities/proveedor_entity.dart, package:flutter/material.dart
- Clases/tipos/componentes: class ProveedorCard, class _ProveedorCardState
- Funciones/metodos: build, createState
- Variables/campos: activo, estadoColor, isDark, isHovered, onDelete, onEdit, onTap, onToggleActivo, proveedor

### `lib/features/pos/presentation/widgets/responsive_builder.dart`
- Imports: ../utils/responsive_helper.dart, package:flutter/material.dart
- Clases/tipos/componentes: class ResponsiveBuilder
- Funciones/metodos: build
- Variables/campos: isDesktop, isMobile, isTablet

### `lib/features/pos/presentation/widgets/responsive_layout.dart`
- Imports: ../utils/responsive_helper.dart, package:flutter/material.dart
- Clases/tipos/componentes: class ResponsiveLayout
- Funciones/metodos: build
- Variables/campos: desktop, mobile, mobileLarge, tablet, width

### `lib/features/pos/presentation/widgets/rest_button_widget.dart`
- Imports: ../../data/Local/entities/isar_service.dart, ../../data/Local/entities/usuario_entity.dart, ../../presentation/providers/lock_provider.dart, ../../presentation/services/sync_service.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart
- Clases/tipos/componentes: class CajeroRestButton
- Funciones/metodos: build, handleRest
- Variables/campos: isarService, syncService, usuario

### `lib/features/pos/presentation/widgets/sales/sales_history_detail_dialog.dart`
- Imports: ../../../data/Local/entities/detalle_venta_entity.dart, ../../../data/Local/entities/isar_service.dart, ../../../data/Local/entities/venta_entity.dart, ../../utils/responsive_helper.dart, dart:ui, package:flutter/material.dart
- Clases/tipos/componentes: class SalesHistoryDetailDialog, class _SalesHistoryDetailDialogState
- Funciones/metodos: _buildHeaderCell, _cargarDetalles, _shortId, build, createState, initState
- Variables/campos: _detallesFuture, _isarService, alignLeft, colorMetodo, colorScheme, detalles, esBold, esDestacado, esTotal, fechaFormatted, fechaLocal, iconMetodo, index, isDark, isLargeScreen, isMobile, item, tasaVentaValida, tieneDescuento, tieneDescuentoGlobal, totalBsVentaValido, venta, ventaId

### `lib/features/pos/presentation/widgets/sales/sales_history_filter_bar.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class SalesHistoryFilterBar, class _PeriodButton, class _PeriodButtonState
- Funciones/metodos: _buildMonthYearSelectors, _buildYearSelector, build, createState
- Variables/campos: anioSeleccionado, aniosDisponibles, borderRadius, colorScheme, fontSize, horizontalPadding, icon, iconSize, isHovering, isMobile, isTablet, label, mesSeleccionado, mesesDropdown, onAnioChanged, onMesChanged, onPeriodChanged, onTap, selected, selectedPeriod, verticalPadding

### `lib/features/pos/presentation/widgets/sales/sales_history_item.dart`
- Imports: ../../../data/Local/entities/venta_entity.dart, package:flutter/material.dart, sales_history_detail_dialog.dart
- Clases/tipos/componentes: class SalesHistoryItem, class _SalesHistoryItemState
- Funciones/metodos: _shortId, _showDetailDialog, build, createState
- Variables/campos: colorMetodo, colorScheme, fechaLocal, fontSizeFecha, fontSizeId, fontSizeTotalBs, fontSizeTotalUSD, iconContainerSize, iconMetodo, iconSize, isDark, isHovering, isMobile, isTablet, paddingHorizontal, paddingVertical, tasaVentaValida, totalBsVentaValido, venta

### `lib/features/pos/presentation/widgets/sales/sales_history_list.dart`
- Imports: ../../../data/Local/entities/venta_entity.dart, package:flutter/material.dart, sales_history_item.dart
- Clases/tipos/componentes: class SalesHistoryList
- Funciones/metodos: build
- Variables/campos: colorScheme, isMobile, isTablet, shrinkWrap, venta, ventas

### `lib/features/pos/presentation/widgets/sales/sales_history_search_bar.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class SalesHistorySearchBar, class _MethodChip, class _MethodChipState
- Funciones/metodos: build, createState
- Variables/campos: borderRadius, colorScheme, esSeleccionado, fontSize, horizontalPadding, isDark, isHovering, isMobile, isTablet, label, methods, onMethodSelected, onSearchChanged, onTap, searchQuery, selected, selectedMethod, verticalPadding

### `lib/features/pos/presentation/widgets/sales/sales_history_summary_cards.dart`
- Imports: package:flutter/material.dart
- Clases/tipos/componentes: class SalesHistorySummaryCards, class _SummaryCard
- Funciones/metodos: _showDetailDialog, build
- Variables/campos: cards, color, colorBs, colorScheme, colorUSD, colorVentas, icon, isMobile, isTablet, label, maxWidth, minWidth, onTap, screenWidth, totalBs, totalUSD, value, ventasCount

### `lib/features/pos/presentation/widgets/scale_visor_widget.dart`
- Imports: ../utils/responsive_helper.dart, package:flutter/material.dart
- Clases/tipos/componentes: class ScaleVisorWidget
- Funciones/metodos: build
- Variables/campos: estaConectada, fontSize, horizontalPadding, iconSize, isMobile, pesoActual, pesoFontSize, verticalPadding

### `lib/features/pos/presentation/widgets/shared/barcode_scanner_dialog.dart`
- Imports: dart:ui, package:flutter/material.dart, package:mobile_scanner/mobile_scanner.dart
- Clases/tipos/componentes: class BarcodeScannerDialog, class _BarcodeScannerDialogState
- Funciones/metodos: build, createState, dispose, initState
- Variables/campos: _controller, _isProcessing, _isTorchOn, _scanAnimation, _scanPosition, barcodes, isPortrait, rawValue, scanSize, screenSize

### `lib/features/pos/presentation/widgets/transactions_page_view.dart`
- Imports: ../screens/gastos_screen.dart, ../screens/sales_history_screen.dart, package:flutter/material.dart
- Clases/tipos/componentes: class TransactionsPageView, class _TransactionsPageViewState
- Funciones/metodos: build, createState, dispose, initState
- Variables/campos: _currentIndex, _pageController, colorScheme, isDark

### `lib/main.dart`
- Imports: features/pos/data/Local/entities/isar_service.dart, features/pos/presentation/providers/lock_provider.dart, features/pos/presentation/providers/sync_provider.dart, features/pos/presentation/screens/configuracion_empresa_screen.dart, features/pos/presentation/screens/inventory_catalog_screen.dart, features/pos/presentation/screens/login_screen.dart, features/pos/presentation/screens/rest_screen.dart, features/pos/presentation/screens/splash_screen.dart, features/pos/presentation/widgets/idle_detector_widget.dart, package:app_boosti_v2/features/pos/presentation/providers/themes/theme.dart, package:app_boosti_v2/features/pos/presentation/providers/themes/theme_provider.dart, package:device_preview/device_preview.dart, package:flutter/foundation.dart, package:flutter/material.dart, package:flutter_riverpod/flutter_riverpod.dart, package:shared_preferences/shared_preferences.dart, package:supabase_flutter/supabase_flutter.dart
- Clases/tipos/componentes: class BoostiPOS, class _BoostiPOSState
- Funciones/metodos: build, createState, initState, main
- Variables/campos: actualizados, anonKey, isLocked, isarService, prefs, supabaseInitialized, syncService, themeMode, uri, url

## 10. Funcion serverless incluida

### `supabase/functions/create-user/index.ts`

- Runtime: Deno/Supabase Edge Function.
- Dependencias: `serve` de `deno.land/std` y `createClient` de `@supabase/supabase-js`.
- Variables de entorno: `SUPABASE_URL` y `SUPABASE_SERVICE_ROLE_KEY`.
- Funcion principal: callback `serve(async (req) => ...)`.
- Flujo: valida `Authorization`, verifica el token, exige rol `admin` en `public.usuarios`, crea un usuario en `auth.users`, inserta su perfil en `public.usuarios` y elimina el usuario Auth si falla la insercion del perfil.

## 11. Como estudiar la app

1. Leer `main.dart` para entender arranque, rutas y servicios globales.
2. Leer `isar_service.dart` junto a las entidades para entender persistencia y reglas de negocio.
3. Leer `auth_provider.dart`, `usuario_provider.dart`, `login_screen.dart` para autenticacion.
4. Seguir `venta_service.dart` -> `cart_controller.dart` -> dialogos de cobro -> ticket/impresion.
5. Seguir `sync_service.dart` para el contrato local/remoto y sus tablas Supabase.
6. Estudiar un provider y su screen/widget asociado por cada dominio funcional.
7. Revisar las dependencias de `pubspec.yaml` antes de cambiar hardware, web, impresion o persistencia.

## 12. Limitaciones del inventario

- Es un inventario estatico: nombres y firmas se extraen por expresiones regulares y las firmas multilina pueden aparecer resumidas.
- La semantica exacta de cada metodo requiere leer su cuerpo.
- Se excluyen artefactos de `build/` y `.dart_tool`; si se incluyen, no representan codigo fuente mantenible.
- El repositorio mezcla logica de negocio en servicios, providers y pantallas; el repositorio de lotes es minimo.
- Isar, Bluetooth, serial, permisos, impresoras y balanza son dependientes de plataforma y requieren atencion especial en Web.
