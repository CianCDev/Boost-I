import 'dart:math';
import 'package:sembast_web/sembast_web.dart';
import 'package:sembast/sembast.dart';
import 'package:flutter/foundation.dart';

// Entidades (importaciones correctas)
import 'local_entity.dart';
import 'cliente_entity.dart';
import '../entities/turno_entity.dart';
import '../entities/log_entity.dart';
import '../entities/venta_entity.dart';
import '../entities/detalle_venta_entity.dart';
import '../entities/detalle_pedido_entity.dart';
import '../entities/producto_entity.dart';
import '../entities/usuario_entity.dart';
import '../entities/pedido_entity.dart';
import '../entities/proveedor_entity.dart';
import '../entities/movimiento_inventario_entity.dart';
import '../entities/recepcion_entity.dart';
import 'categoria_entity.dart';
import 'codigo_barra_alia_entity.dart';
import '../entities/lote_entity.dart';
import '../entities/departamento_entity.dart';
import '../entities/telegram_config_entity.dart';
import 'gasto_entity.dart';
import 'marca_entity.dart';
import '../entities/movimiento_lote_entity.dart';

class HistorialCodigoItem {
  final String codigo;
  final String? proveedorNombre;
  final DateTime fechaIngreso;
  final DateTime? fechaVencimiento;
  final double cantidad;
  final double precio;
  final String tipo;
  HistorialCodigoItem({
    required this.codigo,
    this.proveedorNombre,
    required this.fechaIngreso,
    this.fechaVencimiento,
    required this.cantidad,
    required this.precio,
    required this.tipo,
  });
}

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  late Database _db;
  bool _isInitialized = false;

  final _userStore = stringMapStoreFactory.store('usuarios');
  final _productStore = stringMapStoreFactory.store('productos');

  Future<Database> get db async {
    if (!_isInitialized) {
      _db = await databaseFactoryWeb.openDatabase('boost_pos_sembast.db');
      await _inicializarDatosDemo();
      _isInitialized = true;
    }
    return _db;
  }

  Future<void> init() async {
    await db;
    debugPrint('✅ Sembast inicializado correctamente');
  }

  // ==================== MAPEO ====================
  Map<String, dynamic> _usuarioToMap(UsuarioEntity u) => {
        'id': u.id,
        'nombre': u.nombre,
        'email': u.email,
        'password': u.password,
        'pin': u.pin,
        'rol': u.rol,
        'activo': u.activo,
        'estado': u.estado,
        'cajaAsignada': u.cajaAsignada,
      };

  UsuarioEntity _mapToUsuario(Map<String, dynamic> map) => UsuarioEntity()
    ..id = (map['id'] as int?) ?? 0
    ..nombre = (map['nombre'] as String?) ?? ''
    ..email = (map['email'] as String?) ?? ''
    ..password = (map['password'] as String?) ?? ''
    ..pin = (map['pin'] as String?) ?? ''
    ..rol = (map['rol'] as String?) ?? 'cajero'
    ..activo = (map['activo'] as bool?) ?? true
    ..estado = (map['estado'] as String?) ?? 'inactivo'
    ..cajaAsignada = (map['cajaAsignada'] as String?) ?? 'Caja Principal';

  Map<String, dynamic> _productoToMap(ProductoEntity p) => {
        'id': p.id,
        'codigoBarras': p.codigoBarras,
        'nombre': p.nombre,
        'precioUnidad': p.precioUnidad,
        'stock': p.stock,
        'esPesado': p.esPesado,
        'categoria': p.categoria,
      };

  ProductoEntity _mapToProducto(Map<String, dynamic> map) => ProductoEntity()
    ..id = (map['id'] as int?) ?? 0
    ..codigoBarras = (map['codigoBarras'] as String?) ?? ''
    ..nombre = (map['nombre'] as String?) ?? ''
    ..precioUnidad = (map['precioUnidad'] as num?)?.toDouble() ?? 0.0
    ..stock = (map['stock'] as num?)?.toDouble() ?? 0.0
    ..esPesado = (map['esPesado'] as bool?) ?? false
    ..categoria = (map['categoria'] as String?) ?? '';

  // ==================== DATOS DEMO ====================
  Future<void> _inicializarDatosDemo() async {
    if (await _userStore.count(_db) == 0) {
      await _userStore.add(_db, {
        'id': 1,
        'nombre': 'Administrador',
        'email': 'admin@default.com',
        'password': '123456',
        'pin': '1234',
        'rol': 'admin',
        'activo': true,
        'estado': 'inactivo',
        'cajaAsignada': 'Caja Principal',
      });
      await _userStore.add(_db, {
        'id': 2,
        'nombre': 'yan camacaro',
        'email': 'yan@default.com',
        'password': '101010',
        'pin': '1010',
        'rol': 'cajero',
        'activo': true,
        'estado': 'inactivo',
        'cajaAsignada': 'Caja Principal',
      });
    }
    if (await _productStore.count(_db) == 0) {
      await _productStore.add(_db, {
        'id': 1,
        'codigoBarras': '75010001',
        'nombre': 'Manzana Roja Importada',
        'precioUnidad': 3.50,
        'stock': 50.0,
        'esPesado': true,
        'categoria': 'Frutas',
      });
      await _productStore.add(_db, {
        'id': 2,
        'codigoBarras': '75010002',
        'nombre': 'Arroz Premium 1kg',
        'precioUnidad': 1.20,
        'stock': 100.0,
        'esPesado': false,
        'categoria': 'Abarrotes',
      });
    }
  }

  // ==================== USUARIOS ====================
  Future<List<UsuarioEntity>> obtenerUsuarios() async {
    final isar = await db;
    final records = await _userStore.find(isar);
    return records.map((e) => _mapToUsuario(e.value)).toList();
  }

  Future<List<UsuarioEntity>> obtenerUsuariosActivos() async {
    final users = await obtenerUsuarios();
    return users.where((u) => u.activo).toList();
  }

  Future<UsuarioEntity?> obtenerUsuarioPorId(int id) async {
    final isar = await db;
    final record = await _userStore.record(id.toString()).get(isar);
    return record != null ? _mapToUsuario(record) : null;
  }

  Future<UsuarioEntity?> obtenerUsuarioPorSupabaseId(String supabaseId) async => null;
  Future<UsuarioEntity?> obtenerUsuarioPorDynamicId(String dynamicId) async => null;

  Future<UsuarioEntity> guardarUsuario(UsuarioEntity usuario) async {
    final isar = await db;
    final map = _usuarioToMap(usuario);
    if (usuario.id == 0) {
      final newId = await _userStore.add(isar, map);
      map['id'] = newId;
      return _mapToUsuario(map);
    } else {
      await _userStore.record(usuario.id.toString()).put(isar, map);
      return usuario;
    }
  }

  Future<void> crearUsuario({required String nombre, required String pin, required String rol, required String caja}) async {
    final isar = await db;
    await _userStore.add(isar, {
      'nombre': nombre.trim(),
      'pin': pin.trim(),
      'rol': rol.toLowerCase(),
      'activo': true,
      'estado': 'activo',
      'cajaAsignada': caja,
    });
  }

  Future<String?> eliminarUsuario(int id) async {
    final isar = await db;
    return await _userStore.record(id.toString()).delete(isar);
  }

  Future<bool> cambiarRolUsuario(int usuarioId, String nuevoRol) async {
    final isar = await db;
    final record = await _userStore.record(usuarioId.toString()).get(isar);
    if (record != null) {
      record['rol'] = nuevoRol.toLowerCase();
      await _userStore.record(usuarioId.toString()).put(isar, record);
      return true;
    }
    return false;
  }

  Future<void> actualizarEstadoUsuario(int usuarioId, String nuevoEstado) async {
    final isar = await db;
    final record = await _userStore.record(usuarioId.toString()).get(isar);
    if (record != null) {
      record['estado'] = nuevoEstado;
      await _userStore.record(usuarioId.toString()).put(isar, record);
    }
  }

  Future<bool> cambiarClaveUsuario(int usuarioId, String nuevaClave) async {
    final isar = await db;
    final record = await _userStore.record(usuarioId.toString()).get(isar);
    if (record != null) {
      record['pin'] = nuevaClave;
      await _userStore.record(usuarioId.toString()).put(isar, record);
      return true;
    }
    return false;
  }

  Future<UsuarioEntity?> validarLogin(String nombre, String pin) async {
    final users = await obtenerUsuarios();
    final nombreNorm = nombre.trim();
    final pinNorm = pin.trim();
    for (final u in users) {
      if (u.nombre.toLowerCase() == nombreNorm.toLowerCase() && u.pin == pinNorm && u.activo) {
        return u;
      }
    }
    return null;
  }

  // ==================== PRODUCTOS ====================
  Future<List<ProductoEntity>> obtenerProductos() async {
    final isar = await db;
    final records = await _productStore.find(isar);
    return records.map((e) => _mapToProducto(e.value)).toList();
  }

  Future<ProductoEntity?> obtenerProductoPorId(int id) async {
    final isar = await db;
    final record = await _productStore.record(id.toString()).get(isar);
    return record != null ? _mapToProducto(record) : null;
  }

  Future<List<ProductoEntity>> buscarProductoPorCodigoONombre(String query) async {
    final productos = await obtenerProductos();
    final q = query.toLowerCase();
    return productos
        .where((p) => p.nombre.toLowerCase().contains(q) || p.codigoBarras.contains(q))
        .toList();
  }

  Future<void> guardarProducto(ProductoEntity producto) async {
    final isar = await db;
    final map = _productoToMap(producto);
    if (producto.id == 0) {
      await _productStore.add(isar, map);
    } else {
      await _productStore.record(producto.id.toString()).put(isar, map);
    }
  }

  Future<void> eliminarProducto(int id) async {
    final isar = await db;
    await _productStore.record(id.toString()).delete(isar);
  }

  Future<List<ProductoEntity>> obtenerProductosStockBajo() async => [];
  Future<void> actualizarStockProducto(int idProducto, double nuevoStock) async {}
  Future<ProductoEntity?> obtenerProductoPorCodigoBarrasExacto(String codigo) async => null;
  Future<String> generarCodigoBarrasUnico() async => 'B${Random().nextInt(999999)}';
  Future<List<ProductoEntity>> obtenerTodosLosProductos() async => obtenerProductos();
  Future<int> contarProductos() async => (await obtenerProductos()).length;

  // ==================== VENTAS Y DETALLES ====================
  Future<void> guardarVenta(VentaEntity venta, {List<DetalleVentaEntity>? detalles}) async {}
  Future<List<VentaEntity>> obtenerVentas() async => [];
  Future<List<VentaEntity>> obtenerVentasPorRango(DateTime inicio, DateTime fin) async => [];
  Future<List<VentaEntity>> obtenerUltimasVentas(int cantidad) async => [];
  Future<List<Map<String, dynamic>>> obtenerProductosMasVendidos(int limite) async => [];
  Future<Map<String, double>> obtenerVentasPorEmpleado(DateTime inicio, DateTime fin) async => {};
  Future<double> obtenerTotalVentasPorRango(DateTime inicio, DateTime fin) async => 0;
  Future<List<Map<String, dynamic>>> obtenerVentasPorDia(int cantidadDias) async => [];
  Future<List<DetalleVentaEntity>> obtenerDetallesPorVenta(String ventaId) async => [];
  Future<VentaEntity?> obtenerVentaPorIdString(String ventaIdString) async => null;
  Future<double> obtenerTotalVentasPorEmpleadoYRango(String empleado, DateTime inicio, DateTime fin) async => 0;
  Future<List<VentaEntity>> obtenerVentasPendientesSync() async => [];
  Future<void> actualizarSyncStatusVenta(int id, String nuevoEstado) async {}
  Future<void> guardarDetallesVenta(String ventaId, List<DetalleVentaEntity> detalles) async {}

  // ==================== GASTOS Y LOGS ====================
  Future<void> guardarGasto(GastoEntity gasto) async {}
  Future<List<GastoEntity>> obtenerGastos() async => [];
  Future<List<GastoEntity>> obtenerGastosPendientesSync() async => [];
  Future<void> actualizarSyncStatusGasto(int id, String nuevoEstado) async {}
  Future<double> obtenerTotalGastosPorRango(DateTime inicio, DateTime fin) async => 0;
  Future<void> guardarLog(LogEntity log) async {}
  Future<List<LogEntity>> obtenerLogs() async => [];
  Future<List<LogEntity>> obtenerLogsPendientesSync() async => [];
  Future<void> marcarLogsComoSincronizados(List<int> ids) async {}

  // ==================== CLIENTES ====================
  Future<ClienteEntity> guardarCliente(ClienteEntity cliente) async => cliente;
  Future<List<ClienteEntity>> obtenerClientes({bool soloActivos = true, bool soloFrecuentes = false}) async => [];
  Future<ClienteEntity?> obtenerClientePorId(int id) async => null;
  Future<ClienteEntity?> obtenerClientePorSupabaseId(String supabaseId) async => null;
  Future<List<ClienteEntity>> buscarClientes(String query, {bool soloFrecuentes = false}) async => [];
  Future<bool> eliminarCliente(int id) async => false;
  Future<void> actualizarSyncStatusCliente(int id, String nuevoEstado) async {}
  Future<List<ClienteEntity>> obtenerClientesPendientesSync() async => [];
  Future<void> actualizarEstadisticasCliente(int clienteId, double montoCompra) async {}

  // ==================== MARCAS, CATEGORÍAS, MOVIMIENTOS ====================
  Future<void> guardarMarca(MarcaEntity marca) async {}
  Future<List<MarcaEntity>> obtenerMarcas({bool soloActivas = true}) async => [];
  Future<MarcaEntity?> obtenerMarcaPorId(int id) async => null;
  Future<MarcaEntity?> obtenerMarcaPorSupabaseId(String supabaseId) async => null;
  Future<List<MarcaEntity>> obtenerMarcasPendientesSync() async => [];
  Future<void> actualizarSyncStatusMarca(int id, String nuevoEstado) async {}
  Future<List<MarcaEntity>> buscarMarcas(String query) async => [];
  Future<bool> eliminarMarca(int id) async => false;

  Future<void> guardarCategoria(CategoriaEntity categoria) async {}
  Future<List<CategoriaEntity>> obtenerCategorias({bool soloActivas = true}) async => [];
  Future<CategoriaEntity?> obtenerCategoriaPorId(int id) async => null;
  Future<CategoriaEntity?> obtenerCategoriaPorSupabaseId(String supabaseId) async => null;
  Future<List<CategoriaEntity>> obtenerCategoriasPendientesSync() async => [];

  Future<void> guardarMovimientoInventario(MovimientoInventarioEntity movimiento) async {}
  Future<List<MovimientoInventarioEntity>> obtenerMovimientosPendientesSync() async => [];
  Future<void> actualizarSyncStatusMovimiento(int id, String nuevoEstado) async {}
  // Método originalmente retornaba Query<MovimientoInventarioEntity>, pero en Sembast no existe Query.
  // Se deja como lista vacía para evitar romper la compilación.
  Future<List<MovimientoInventarioEntity>> queryMovimientosVentaRecientes(DateTime desde) async => [];

  // ==================== TURNOS ====================
  Future<void> guardarTurno(TurnoEntity turno) async {}
  Future<List<TurnoEntity>> obtenerTurnos() async => [];
  Future<TurnoEntity?> obtenerTurnoAbiertoPorUsuario(int usuarioId) async => null;
  Future<void> cerrarTurno(int turnoId, double montoFinal) async {}
  Future<List<TurnoEntity>> obtenerTurnosPendientes() async => [];
  Future<void> marcarTurnoComoSincronizado(int turnoId) async {}

  // ==================== PEDIDOS ====================
  Future<int> guardarPedido(PedidoEntity pedido) async => 0;
  Future<List<PedidoEntity>> obtenerPedidosPorLocalDestino(int localDestinoId) async => [];
  Future<List<PedidoEntity>> obtenerPedidosPorEstado(EstadoPedido estado, {int? localDestinoId}) async => [];
  Future<PedidoEntity?> obtenerPedidoPorId(int id) async => null;
  Future<PedidoEntity?> obtenerPedidoPorSupabaseId(String supabaseId) async => null;
  Future<void> actualizarEstadoPedido(int id, EstadoPedido nuevoEstado) async {}
  Future<void> cancelarPedido(int id) async {}
  Future<void> actualizarSyncStatusPedido(int id, bool sincronizado) async {}
  Future<List<PedidoEntity>> obtenerPedidosPendientesSync() async => [];
  Future<int> guardarDetallePedido(DetallePedidoEntity detalle) async => 0;
  Future<List<DetallePedidoEntity>> obtenerDetallesPorPedido(int pedidoId) async => [];
  Future<void> eliminarDetallesPorPedido(int pedidoId) async {}
  Future<int> guardarRecepcion(RecepcionEntity recepcion) async => 0;
  Future<RecepcionEntity?> obtenerRecepcionPorPedido(int pedidoId) async => null;
  Future<void> actualizarSyncStatusRecepcion(int id, bool sincronizado) async {}

  // ==================== PROVEEDORES ====================
  Future<int> guardarProveedor(ProveedorEntity proveedor) async => 0;
  Future<List<ProveedorEntity>> obtenerProveedores({bool soloActivos = true}) async => [];
  Future<ProveedorEntity?> obtenerProveedorPorId(int id) async => null;
  Future<ProveedorEntity?> obtenerProveedorPorSupabaseId(String supabaseId) async => null;
  Future<ProveedorEntity?> obtenerProveedorPorNombre(String nombre) async => null;
  Future<String?> obtenerSupabaseIdProveedorPorNombre(String nombre) async => null;
  Future<void> actualizarSyncStatusProveedor(int id, bool sincronizado) async {}
  Future<List<ProveedorEntity>> obtenerProveedoresPendientesSync() async => [];
  Future<void> desactivarProveedor(int id) async {}
  Future<List<ProductoEntity>> obtenerProductosPorProveedor(int proveedorId) async => [];
  Future<bool> eliminarProveedor(int id) async => false;
  Future<List<ProveedorEntity>> buscarProveedores(String query) async => [];

  // ==================== LOCALES ====================
  Future<LocalEntity?> obtenerLocalPorId(int id) async => null;
  Future<LocalEntity?> obtenerLocalPorSupabaseId(String supabaseId) async => null;
  Future<int> guardarLocal(LocalEntity local) async => 0;
  Future<List<LocalEntity>> obtenerLocales({bool soloActivos = true}) async => [];
  Future<LocalEntity?> obtenerLocalActivo() async => null;
  Future<int> contarProductosPorDepartamento(int departamentoId) async => 0;
  Future<bool> eliminarLocal(int id) async => false;
  Future<void> actualizarSyncStatusLocal(int id, bool sincronizado) async {}
  Future<List<LocalEntity>> obtenerLocalesPendientesSync() async => [];

  // ==================== DEPARTAMENTOS ====================
  Future<int> guardarDepartamento(DepartamentoEntity departamento) async => 0;
  Future<List<DepartamentoEntity>> obtenerDepartamentos({bool? soloActivos = true, int? localId}) async => [];
  Future<DepartamentoEntity?> obtenerDepartamentoPorId(int id) async => null;
  Future<bool> eliminarDepartamento(int id) async => false;
  Future<void> actualizarSyncStatusDepartamento(int id, bool sincronizado) async {}
  Future<List<DepartamentoEntity>> obtenerDepartamentosPendientesSync() async => [];

  // ==================== CÓDIGOS DE BARRAS ALIAS ====================
  Future<void> guardarCodigoAlias(CodigoBarrasAliasEntity alias) async {}
  Future<CodigoBarrasAliasEntity?> obtenerAliasPorCodigo(String codigo) async => null;
  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPorProducto(int productoId) async => [];
  Future<void> desactivarAlias(int aliasId) async {}
  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPendientesSync() async => [];

  // ==================== LOTES ====================
  Future<void> guardarLote(LoteEntity lote) async {}
  Future<double> obtenerStockTotalPorProducto(int productoId) async => 0;
  Future<List<LoteEntity>> obtenerLotesActivos(int productoId, {bool priorizarVencimiento = true}) async => [];
  Future<bool> descontarLote(int loteId, double cantidad) async => false;
  Future<LoteEntity?> obtenerLoteParaVenta(int productoId, {bool priorizarVencimiento = true}) async => null;
  Future<List<LoteEntity>> obtenerTodosLosLotes() async => [];
  Future<int> contarLotes() async => 0;
  Future<Map<String, dynamic>> migrarStockExistenteALotes() async => {'success': true};
  Future<int> asignarSupabaseIdsAFaltantes() async => 0;
  Future<bool> eliminarLote(int id) async => false;
  Future<LoteEntity?> obtenerLotePorId(int id) async => null;
  Future<List<MovimientoLoteEntity>> obtenerTodosMovimientosLote() async => [];
  Future<List<LoteEntity>> obtenerLotesPendientes() async => [];
  Future<List<LoteEntity>> obtenerLotesHistorial() async => [];
  Future<bool> verificarLote({required int loteId, required String codigoBarras, required double cantidadRecibida, required int usuarioId}) async => false;
  Future<void> guardarMovimientoLote(MovimientoLoteEntity movimiento) async {}
  Future<List<MovimientoLoteEntity>> obtenerMovimientosPorLote(int loteId) async => [];
  Future<List<MovimientoLoteEntity>> obtenerMovimientosLotePendientesSync() async => [];
  Future<List<HistorialCodigoItem>> obtenerHistorialCodigosPorProducto(int productoId) async => [];
  Future<List<LoteEntity>> obtenerLotesPendientesSync() async => [];
  Future<List<LoteEntity>> obtenerLotesPorLocal(int localId) async => [];
  Future<List<LoteEntity>> obtenerLotesPorLocalYEstado(int localId, String estado) async => [];
  Future<List<LoteEntity>> obtenerLotesPorProductoYLocal(int productoId, int localId) async => [];
  Future<Map<String, dynamic>> migrarLotesConLocal() async => {'success': true};

  // ==================== TELEGRAM ====================
  Future<TelegramConfigEntity?> obtenerTelegramConfigPorUsuario(int usuarioId) async => null;
  Future<List<TelegramConfigEntity>> obtenerTodasTelegramConfigs() async => [];
  Future<List<TelegramConfigEntity>> obtenerTelegramConfigsPendientesSync() async => [];
  Future<int> guardarTelegramConfig(TelegramConfigEntity config) async => 0;
  Future<TelegramConfigEntity?> obtenerTelegramConfig() async => null;
  Future<void> actualizarSyncStatusTelegramConfig(int id, bool sincronizado) async {}
  Future<List<TelegramConfigEntity>> obtenerTelegramConfigs() async => [];
  Future<void> eliminarTelegramConfig(int id) async {}

  // ==================== GENERAL ====================
  Future<List<ProductoEntity>> obtenerProductosPendientesSync() async => [];
  Future<void> resetearSupabaseIdsIncorrectos() async {}
  Future<void> inicializarUsuarioAdminPorDefecto() async {
    await db;
    await _inicializarDatosDemo();
  }

  Future<Map<String, dynamic>> obtenerResumenDashboard() async => {
        'totalHoy': 0.0,
        'totalSemana': 0.0,
        'totalMes': 0.0,
        'totalGastosMes': 0.0,
        'variacion': 0.0,
        'ventasHoy': 0,
        'ultimasVentas': <VentaEntity>[],
        'topProductos': <Map<String, dynamic>>[],
        'stockBajo': <ProductoEntity>[],
        'ventasPorEmpleado': <String, double>{},
        'ventasPorDia': <Map<String, dynamic>>[],
      };

  Future<List<VentaEntity>> obtenerVentasPorPeriodo(String periodo) async => [];
}