// lib/features/pos/data/Local/entities/isar_service_web.dart
// ⚠️ Versión web: usa almacenamiento en memoria (sin FFI, sin path_provider)
import 'dart:math';
import 'package:flutter/foundation.dart';

// Entidades
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
import 'local_entity.dart';

// ============================================================
// CLASE AUXILIAR
// ============================================================
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

// ============================================================
// SERVICIO WEB (EN MEMORIA)
// ============================================================

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal() {
    _initDemoData();
  }

  // ==================== ALMACENAMIENTO EN MEMORIA ====================

  final List<UsuarioEntity> _usuarios = [];
  final List<ProductoEntity> _productos = [];
  final List<VentaEntity> _ventas = [];
  final List<DetalleVentaEntity> _detallesVenta = [];
  final List<ClienteEntity> _clientes = [];
  final List<GastoEntity> _gastos = [];
  final List<LogEntity> _logs = [];
  final List<TurnoEntity> _turnos = [];
  final List<PedidoEntity> _pedidos = [];
  final List<DetallePedidoEntity> _detallesPedido = [];
  final List<RecepcionEntity> _recepciones = [];
  final List<ProveedorEntity> _proveedores = [];
  final List<LocalEntity> _locales = [];
  final List<CodigoBarrasAliasEntity> _alias = [];
  final List<LoteEntity> _lotes = [];
  final List<DepartamentoEntity> _departamentos = [];
  final List<TelegramConfigEntity> _telegramConfigs = [];
  final List<CategoriaEntity> _categorias = [];
  final List<MarcaEntity> _marcas = [];
  final List<MovimientoLoteEntity> _movimientosLote = [];
  final List<MovimientoInventarioEntity> _movimientosInventario = [];

  int _nextId = 1;

  void _initDemoData() {
    // Usuario admin
    final admin = UsuarioEntity()
      ..id = _nextId++
      ..nombre = 'Administrador'
      ..pin = '1234'
      ..rol = 'admin'
      ..activo = true
      ..estado = 'activo'
      ..cajaAsignada = 'Caja Principal'
      ..email = 'admin@demo.com'
      ..password = '123456'
      ..dynamicId = 'demo-admin-001';
    _usuarios.add(admin);

    // Usuario cajero
    final cajero = UsuarioEntity()
      ..id = _nextId++
      ..nombre = 'Cajero Demo'
      ..pin = '0000'
      ..rol = 'cajero'
      ..activo = true
      ..estado = 'activo'
      ..cajaAsignada = 'Caja 01'
      ..email = 'cajero@demo.com'
      ..password = '0000'
      ..dynamicId = 'demo-cajero-001';
    _usuarios.add(cajero);

    // Productos demo
    _productos.addAll([
      _createProducto('75010001', 'Manzana Roja Importada', 3.50, 50.0, true, 'Frutas'),
      _createProducto('75010002', 'Arroz Premium 1kg', 1.20, 100.0, false, 'Abarrotes'),
      _createProducto('75010003', 'Queso Blanco Duro', 6.80, 25.0, true, 'Lácteos'),
      _createProducto('75010004', 'Harina PAN', 2.00, 30.0, false, 'Abarrotes'),
    ]);

    // Categorías demo
    _categorias.addAll([
      _createCategoria('Frutas', 'Frutas frescas'),
      _createCategoria('Abarrotes', 'Productos de despensa'),
      _createCategoria('Lácteos', 'Lácteos y derivados'),
    ]);

    // Local por defecto
    final local = LocalEntity()
      ..id = _nextId++
      ..nombre = 'Local Principal'
      ..direccion = 'Av. Principal 123'
      ..telefono = '0412-1234567'
      ..email = 'local@demo.com'
      ..activo = true
      ..sincronizado = true
      ..supabaseId = '00000000-0000-0000-0000-000000000001';
    _locales.add(local);

    debugPrint('🌐 IsarServiceWeb: datos demo inicializados (${_productos.length} productos)');
  }

  ProductoEntity _createProducto(String codigo, String nombre, double precio, double stock, bool pesado, String categoria) {
    return ProductoEntity()
      ..id = _nextId++
      ..codigoBarras = codigo
      ..nombre = nombre
      ..precioUnidad = precio
      ..stock = stock
      ..esPesado = pesado
      ..categoria = categoria
      ..activo = true
      ..stockMinimo = 5.0
      ..sincronizado = true;
  }

  CategoriaEntity _createCategoria(String nombre, String descripcion) {
    return CategoriaEntity(
      nombre: nombre,
      descripcion: descripcion,
      activo: true,
      syncStatus: 'synced',
    )..id = _nextId++;
  }

  // ==================== USUARIOS ====================

  Future<UsuarioEntity?> obtenerUsuarioPorSupabaseId(String supabaseId) async {
    try {
      return _usuarios.firstWhere((u) => u.supabaseId == supabaseId);
    } catch (_) {
      return null;
    }
  }

  Future<UsuarioEntity?> obtenerUsuarioPorId(int id) async {
    try {
      return _usuarios.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<UsuarioEntity>> obtenerUsuarios() async {
    return _usuarios;
  }

  Future<List<UsuarioEntity>> obtenerUsuariosActivos() async {
    return _usuarios.where((u) => u.activo == true).toList();
  }

  Future<UsuarioEntity> guardarUsuario(UsuarioEntity usuario) async {
    if (usuario.id == 0) {
      usuario.id = _nextId++;
    }
    final index = _usuarios.indexWhere((u) => u.id == usuario.id);
    if (index >= 0) {
      _usuarios[index] = usuario;
    } else {
      _usuarios.add(usuario);
    }
    return usuario;
  }

  Future<UsuarioEntity?> obtenerUsuarioPorDynamicId(String dynamicId) async {
    try {
      return _usuarios.firstWhere((u) => u.dynamicId == dynamicId);
    } catch (_) {
      return null;
    }
  }

  Future<void> crearUsuario({
    required String nombre,
    required String pin,
    required String rol,
    required String caja,
  }) async {
    final nuevo = UsuarioEntity()
      ..id = _nextId++
      ..nombre = nombre
      ..pin = pin
      ..rol = rol
      ..activo = true
      ..estado = 'activo'
      ..cajaAsignada = caja;
    _usuarios.add(nuevo);
  }

  Future<bool> eliminarUsuario(int id) async {
    _usuarios.removeWhere((u) => u.id == id);
    return true;
  }

  Future<bool> cambiarRolUsuario(int usuarioId, String nuevoRol) async {
    final u = await obtenerUsuarioPorId(usuarioId);
    if (u != null) {
      u.rol = nuevoRol;
      return true;
    }
    return false;
  }

  Future<void> actualizarEstadoUsuario(int usuarioId, String nuevoEstado) async {
    final u = await obtenerUsuarioPorId(usuarioId);
    if (u != null) {
      u.estado = nuevoEstado;
    }
  }

  Future<bool> cambiarClaveUsuario(int usuarioId, String nuevaClave) async {
    final u = await obtenerUsuarioPorId(usuarioId);
    if (u != null) {
      u.pin = nuevaClave;
      return true;
    }
    return false;
  }

  Future<UsuarioEntity?> validarLogin(String nombre, String pin) async {
    try {
      return _usuarios.firstWhere(
        (u) => u.nombre.toLowerCase() == nombre.toLowerCase() && u.pin == pin && u.activo == true,
      );
    } catch (_) {
      return null;
    }
  }

  // ==================== MARCAS ====================

  Future<void> guardarMarca(MarcaEntity marca) async {
    if (marca.id == 0) marca.id = _nextId++;
    final index = _marcas.indexWhere((m) => m.id == marca.id);
    if (index >= 0) {
      _marcas[index] = marca;
    } else {
      _marcas.add(marca);
    }
  }

  Future<List<MarcaEntity>> obtenerMarcas({bool soloActivas = true}) async {
    return soloActivas ? _marcas.where((m) => m.activo).toList() : _marcas;
  }

  Future<MarcaEntity?> obtenerMarcaPorId(int id) async {
    try {
      return _marcas.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<MarcaEntity?> obtenerMarcaPorSupabaseId(String supabaseId) async {
    try {
      return _marcas.firstWhere((m) => m.supabaseId == supabaseId);
    } catch (_) {
      return null;
    }
  }

  Future<List<MarcaEntity>> obtenerMarcasPendientesSync() async => [];
  Future<void> actualizarSyncStatusMarca(int id, String nuevoEstado) async {}
  Future<List<MarcaEntity>> buscarMarcas(String query) async {
    final q = query.toLowerCase();
    return _marcas.where((m) => m.nombre.toLowerCase().contains(q)).toList();
  }

  Future<bool> eliminarMarca(int id) async {
    final m = await obtenerMarcaPorId(id);
    if (m != null) {
      final tieneProductos = _productos.any((p) => p.marcaSupabaseId == m.supabaseId);
      if (tieneProductos) {
        m.activo = false;
        return false;
      }
      _marcas.removeWhere((m2) => m2.id == id);
      return true;
    }
    return false;
  }

  // ==================== CATEGORÍAS ====================

  Future<void> guardarCategoria(CategoriaEntity categoria) async {
    if (categoria.id == 0) categoria.id = _nextId++;
    final index = _categorias.indexWhere((c) => c.id == categoria.id);
    if (index >= 0) {
      _categorias[index] = categoria;
    } else {
      _categorias.add(categoria);
    }
  }

  Future<List<CategoriaEntity>> obtenerCategorias({bool soloActivas = true}) async {
    return soloActivas ? _categorias.where((c) => c.activo).toList() : _categorias;
  }

  Future<CategoriaEntity?> obtenerCategoriaPorId(int id) async {
    try {
      return _categorias.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<CategoriaEntity?> obtenerCategoriaPorSupabaseId(String supabaseId) async {
    try {
      return _categorias.firstWhere((c) => c.supabaseId == supabaseId);
    } catch (_) {
      return null;
    }
  }

  Future<List<CategoriaEntity>> obtenerCategoriasPendientesSync() async => [];

  // ==================== PRODUCTOS ====================

  Future<ProductoEntity?> obtenerProductoPorSupabaseId(String supabaseId) async {
    try {
      return _productos.firstWhere((p) => p.supabaseId == supabaseId);
    } catch (_) {
      return null;
    }
  }

  Future<ProductoEntity?> obtenerProductoPorId(int id) async {
    try {
      return _productos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<ProductoEntity>> obtenerProductos() async {
    return _productos.where((p) => p.activo).toList();
  }

  Future<List<ProductoEntity>> buscarProductoPorCodigoONombre(String query) async {
    final q = query.toLowerCase();
    return _productos.where((p) =>
      p.codigoBarras.toLowerCase().contains(q) ||
      p.nombre.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> guardarProducto(ProductoEntity producto) async {
    if (producto.id == 0) producto.id = _nextId++;
    final index = _productos.indexWhere((p) => p.id == producto.id);
    if (index >= 0) {
      _productos[index] = producto;
    } else {
      _productos.add(producto);
    }
  }

  Future<void> eliminarProducto(int id) async {
    _productos.removeWhere((p) => p.id == id);
  }

  Future<List<ProductoEntity>> obtenerProductosStockBajo() async {
    return _productos.where((p) => p.stock <= p.stockMinimo).toList();
  }

  Future<void> actualizarStockProducto(int idProducto, double nuevoStock) async {
    final p = await obtenerProductoPorId(idProducto);
    if (p != null) {
      p.stock = nuevoStock < 0 ? 0 : nuevoStock;
    }
  }

 Future<ProductoEntity?> obtenerProductoPorCodigoBarrasExacto(String codigo) async {
  try {
    return _productos.firstWhere((p) => p.codigoBarras == codigo);
  } catch (_) {
    return null;
  }
}

  Future<String> generarCodigoBarrasUnico() async {
  final random = Random();
  String codigo;
  int intentos = 0;
  do {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final timestampPart = timestamp.length > 10
        ? timestamp.substring(timestamp.length - 10)
        : timestamp;
    final randomNum = (100 + random.nextInt(899)).toString();
    codigo = 'B$timestampPart$randomNum';
    intentos++;
    try {
      _productos.firstWhere((p) => p.codigoBarras == codigo);
      // Si se encuentra, continuamos
    } catch (_) {
      // No se encontró, podemos usar este código
      return codigo;
    }
  } while (intentos < 10);
  codigo = 'B${DateTime.now().microsecondsSinceEpoch}';
  return codigo;
}

  // ==================== VENTAS Y DETALLES ====================

  Future<void> guardarVenta(
    VentaEntity venta, {
    List<DetalleVentaEntity>? detalles,
  }) async {
    if (venta.id == 0) venta.id = _nextId++;
    venta.syncStatus ??= 'pending';
    final index = _ventas.indexWhere((v) => v.id == venta.id);
    if (index >= 0) {
      _ventas[index] = venta;
    } else {
      _ventas.add(venta);
    }
    if (detalles != null) {
      for (var item in detalles) {
        if (item.id == 0) item.id = _nextId++;
        item.ventaIdFk = venta.idSupabase;
        final dIndex = _detallesVenta.indexWhere((d) => d.id == item.id);
        if (dIndex >= 0) {
          _detallesVenta[dIndex] = item;
        } else {
          _detallesVenta.add(item);
        }
      }
    }
    debugPrint('✅ Venta guardada en web (memoria). ID: ${venta.id}');
  }

  Future<List<VentaEntity>> obtenerVentas() async {
    _ventas.sort((a, b) => (b.fecha ?? DateTime.now()).compareTo(a.fecha ?? DateTime.now()));
    return _ventas;
  }

  Future<List<VentaEntity>> obtenerVentasPorRango(DateTime inicio, DateTime fin) async {
    return _ventas.where((v) =>
      v.fecha != null &&
      v.fecha!.isAfter(inicio) &&
      v.fecha!.isBefore(fin)
    ).toList();
  }

  Future<List<VentaEntity>> obtenerUltimasVentas(int cantidad) async {
    final sorted = _ventas.toList()
      ..sort((a, b) => (b.fecha ?? DateTime.now()).compareTo(a.fecha ?? DateTime.now()));
    return sorted.take(cantidad).toList();
  }

  Future<List<Map<String, dynamic>>> obtenerProductosMasVendidos(int limite) async {
    final Map<String, double> acumulado = {};
    for (var d in _detallesVenta) {
      acumulado[d.nombreProducto] = (acumulado[d.nombreProducto] ?? 0) + d.cantidad;
    }
    final lista = acumulado.entries.map((e) => {'nombre': e.key, 'cantidad': e.value}).toList();
    lista.sort((a, b) => (b['cantidad'] as double).compareTo(a['cantidad'] as double));
    return lista.take(limite).toList();
  }

  Future<Map<String, double>> obtenerVentasPorEmpleado(DateTime inicio, DateTime fin) async {
    final Map<String, double> resultado = {};
    for (var v in _ventas) {
      if (v.fecha != null && v.fecha!.isAfter(inicio) && v.fecha!.isBefore(fin)) {
        resultado[v.empleado] = (resultado[v.empleado] ?? 0) + v.total;
      }
    }
    return resultado;
  }

  Future<double> obtenerTotalVentasPorRango(DateTime inicio, DateTime fin) async {
    double total = 0;
    for (var v in _ventas) {
      if (v.fecha != null && v.fecha!.isAfter(inicio) && v.fecha!.isBefore(fin)) {
        total += v.total;
      }
    }
    return total;
  }

  Future<List<Map<String, dynamic>>> obtenerVentasPorDia(int cantidadDias) async {
    final Map<String, double> agrupado = {};
    for (var v in _ventas) {
      if (v.fecha == null) continue;
      final dia = DateTime(v.fecha!.year, v.fecha!.month, v.fecha!.day);
      final key = dia.toIso8601String().substring(0, 10);
      agrupado[key] = (agrupado[key] ?? 0) + v.total;
    }
    final keys = agrupado.keys.toList()..sort();
    return keys.map((k) => {'fecha': k, 'total': agrupado[k] ?? 0}).toList();
  }

  Future<List<DetalleVentaEntity>> obtenerDetallesPorVenta(String ventaId) async {
    return _detallesVenta.where((d) => d.ventaIdFk == ventaId).toList();
  }

  Future<VentaEntity?> obtenerVentaPorIdString(String ventaIdString) async {
    try {
      return _ventas.firstWhere((v) => v.idSupabase == ventaIdString);
    } catch (_) {
      return null;
    }
  }

  Future<double> obtenerTotalVentasPorEmpleadoYRango(
    String empleado,
    DateTime inicio,
    DateTime fin,
  ) async {
    double total = 0;
    for (var v in _ventas) {
      if (v.empleado == empleado && v.fecha != null && v.fecha!.isAfter(inicio) && v.fecha!.isBefore(fin)) {
        total += v.total;
      }
    }
    return total;
  }

  // ==================== GASTOS ====================

  Future<void> guardarGasto(GastoEntity gasto) async {
    if (gasto.id == 0) gasto.id = _nextId++;
    final index = _gastos.indexWhere((g) => g.id == gasto.id);
    if (index >= 0) {
      _gastos[index] = gasto;
    } else {
      _gastos.add(gasto);
    }
  }

  Future<List<GastoEntity>> obtenerGastos() async {
    _gastos.sort((a, b) => b.fecha.compareTo(a.fecha));
    return _gastos;
  }

  Future<List<GastoEntity>> obtenerGastosPendientesSync() async => [];
  Future<void> actualizarSyncStatusGasto(int id, String nuevoEstado) async {}

  Future<double> obtenerTotalGastosPorRango(DateTime inicio, DateTime fin) async {
    double total = 0;
    for (var g in _gastos) {
      if (g.fecha.isAfter(inicio) && g.fecha.isBefore(fin)) {
        total += g.monto;
      }
    }
    return total;
  }

  // ==================== LOGS ====================

  Future<void> guardarLog(LogEntity log) async {
    if (log.id == 0) log.id = _nextId++;
    _logs.add(log);
  }

  Future<List<LogEntity>> obtenerLogs() async {
    _logs.sort((a, b) => b.fecha.compareTo(a.fecha));
    return _logs;
  }

  Future<List<LogEntity>> obtenerLogsPendientesSync() async => [];
  Future<void> marcarLogsComoSincronizados(List<int> ids) async {}

  // ==================== CLIENTES ====================

  Future<ClienteEntity> guardarCliente(ClienteEntity cliente) async {
    if (cliente.id == 0) cliente.id = _nextId++;
    final index = _clientes.indexWhere((c) => c.id == cliente.id);
    if (index >= 0) {
      _clientes[index] = cliente;
    } else {
      _clientes.add(cliente);
    }
    return cliente;
  }

  Future<List<ClienteEntity>> obtenerClientes({
    bool soloActivos = true,
    bool soloFrecuentes = false,
  }) async {
    var result = _clientes;
    if (soloActivos) {
      result = result.where((c) => c.activo).toList();
    }
    if (soloFrecuentes) {
      result = result.where((c) => c.frecuente).toList();
    }
    return result;
  }

  Future<ClienteEntity?> obtenerClientePorId(int id) async {
    try {
      return _clientes.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ClienteEntity?> obtenerClientePorSupabaseId(String supabaseId) async {
    try {
      return _clientes.firstWhere((c) => c.supabaseId == supabaseId);
    } catch (_) {
      return null;
    }
  }

  Future<List<ClienteEntity>> buscarClientes(String query, {bool soloFrecuentes = false}) async {
    final q = query.toLowerCase();
    var result = _clientes.where((c) =>
      c.nombre.toLowerCase().contains(q) ||
      (c.documento?.toLowerCase().contains(q) ?? false) ||
      (c.telefono?.toLowerCase().contains(q) ?? false)
    ).toList();
    if (soloFrecuentes) {
      result = result.where((c) => c.frecuente).toList();
    }
    return result;
  }

  Future<bool> eliminarCliente(int id) async {
    _clientes.removeWhere((c) => c.id == id);
    return true;
  }

  Future<void> actualizarSyncStatusCliente(int id, String nuevoEstado) async {}
  Future<List<ClienteEntity>> obtenerClientesPendientesSync() async => [];

  Future<void> actualizarEstadisticasCliente(int clienteId, double montoCompra) async {
    final c = await obtenerClientePorId(clienteId);
    if (c != null) {
      c.totalCompras += montoCompra;
      c.cantidadCompras += 1;
      c.ultimaCompra = DateTime.now();
      if (c.cantidadCompras >= 5) {
        c.frecuente = true;
      }
    }
  }

  // ==================== MOVIMIENTOS DE INVENTARIO ====================

  Future<void> guardarMovimientoInventario(MovimientoInventarioEntity movimiento) async {
    if (movimiento.id == 0) movimiento.id = _nextId++;
    _movimientosInventario.add(movimiento);
  }

  Future<List<MovimientoInventarioEntity>> obtenerMovimientosPendientesSync() async => [];
  Future<void> actualizarSyncStatusMovimiento(int id, String nuevoEstado) async {}

  // ==================== TURNOS ====================

  Future<void> guardarTurno(TurnoEntity turno) async {
    if (turno.id == 0) turno.id = _nextId++;
    final index = _turnos.indexWhere((t) => t.id == turno.id);
    if (index >= 0) {
      _turnos[index] = turno;
    } else {
      _turnos.add(turno);
    }
  }

  Future<List<TurnoEntity>> obtenerTurnos() async {
    _turnos.sort((a, b) => b.fechaApertura.compareTo(a.fechaApertura));
    return _turnos;
  }

  Future<TurnoEntity?> obtenerTurnoAbiertoPorUsuario(int usuarioId) async {
    try {
      return _turnos.firstWhere(
        (t) => t.usuarioId == usuarioId && t.estado == 'abierto',
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> cerrarTurno(int turnoId, double montoFinal) async {
    final t = await obtenerTurnoPorId(turnoId);
    if (t != null) {
      t.fechaCierre = DateTime.now();
      t.montoFinal = montoFinal;
      t.estado = 'cerrado';
      t.syncStatus = 'pending';
    }
  }

  Future<List<TurnoEntity>> obtenerTurnosPendientes() async => [];
  Future<void> marcarTurnoComoSincronizado(int turnoId) async {}

  Future<TurnoEntity?> obtenerTurnoPorId(int id) async {
    try {
      return _turnos.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  // ==================== PEDIDOS ====================

  Future<int> guardarPedido(PedidoEntity pedido) async {
    if (pedido.id == 0) pedido.id = _nextId++;
    final index = _pedidos.indexWhere((p) => p.id == pedido.id);
    if (index >= 0) {
      _pedidos[index] = pedido;
    } else {
      _pedidos.add(pedido);
    }
    return pedido.id;
  }

  Future<List<PedidoEntity>> obtenerPedidosPorLocalDestino(int localDestinoId) async {
    return _pedidos.where((p) => p.localDestinoId == localDestinoId).toList();
  }

  Future<List<PedidoEntity>> obtenerPedidosPorEstado(EstadoPedido estado, {int? localDestinoId}) async {
    var result = _pedidos.where((p) => p.estado == estado).toList();
    if (localDestinoId != null) {
      result = result.where((p) => p.localDestinoId == localDestinoId).toList();
    }
    return result;
  }

  Future<PedidoEntity?> obtenerPedidoPorId(int id) async {
    try {
      return _pedidos.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<PedidoEntity?> obtenerPedidoPorSupabaseId(String supabaseId) async {
    try {
      return _pedidos.firstWhere((p) => p.supabaseId == supabaseId);
    } catch (_) {
      return null;
    }
  }

  Future<void> actualizarEstadoPedido(int id, EstadoPedido nuevoEstado) async {
    final p = await obtenerPedidoPorId(id);
    if (p != null) {
      p.estado = nuevoEstado;
    }
  }

  Future<void> cancelarPedido(int id) async {
    final p = await obtenerPedidoPorId(id);
    if (p != null) {
      p.estado = EstadoPedido.cancelado;
      p.sincronizado = false;
    }
  }

  Future<void> actualizarSyncStatusPedido(int id, bool sincronizado) async {
    final p = await obtenerPedidoPorId(id);
    if (p != null) {
      p.sincronizado = sincronizado;
      p.fechaSincronizacion = DateTime.now();
    }
  }

  Future<List<PedidoEntity>> obtenerPedidosPendientesSync() async => [];

  // ==================== DETALLES DE PEDIDO ====================

  Future<int> guardarDetallePedido(DetallePedidoEntity detalle) async {
    if (detalle.id == 0) detalle.id = _nextId++;
    _detallesPedido.add(detalle);
    return detalle.id;
  }

  Future<List<DetallePedidoEntity>> obtenerDetallesPorPedido(int pedidoId) async {
    return _detallesPedido.where((d) => d.pedidoId == pedidoId).toList();
  }

  Future<void> eliminarDetallesPorPedido(int pedidoId) async {
    _detallesPedido.removeWhere((d) => d.pedidoId == pedidoId);
  }

  // ==================== RECEPCIONES ====================

  Future<int> guardarRecepcion(RecepcionEntity recepcion) async {
    if (recepcion.id == 0) recepcion.id = _nextId++;
    _recepciones.add(recepcion);
    return recepcion.id;
  }

  Future<RecepcionEntity?> obtenerRecepcionPorPedido(int pedidoId) async {
    try {
      return _recepciones.firstWhere((r) => r.pedidoId == pedidoId);
    } catch (_) {
      return null;
    }
  }

  Future<void> actualizarSyncStatusRecepcion(int id, bool sincronizado) async {}

  // ==================== PROVEEDORES ====================

  Future<int> guardarProveedor(ProveedorEntity proveedor) async {
    if (proveedor.id == 0) proveedor.id = _nextId++;
    final index = _proveedores.indexWhere((p) => p.id == proveedor.id);
    if (index >= 0) {
      _proveedores[index] = proveedor;
    } else {
      _proveedores.add(proveedor);
    }
    return proveedor.id;
  }

  Future<List<ProveedorEntity>> obtenerProveedores({bool soloActivos = true}) async {
    return soloActivos ? _proveedores.where((p) => p.activo).toList() : _proveedores;
  }

  Future<ProveedorEntity?> obtenerProveedorPorId(int id) async {
    try {
      return _proveedores.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<ProveedorEntity?> obtenerProveedorPorSupabaseId(String supabaseId) async {
    try {
      return _proveedores.firstWhere((p) => p.supabaseId == supabaseId);
    } catch (_) {
      return null;
    }
  }

  Future<void> actualizarSyncStatusProveedor(int id, bool sincronizado) async {
    final p = await obtenerProveedorPorId(id);
    if (p != null) {
      p.sincronizado = sincronizado;
      p.fechaSincronizacion = DateTime.now();
    }
  }

  Future<List<ProveedorEntity>> obtenerProveedoresPendientesSync() async => [];

  Future<void> desactivarProveedor(int id) async {
    final p = await obtenerProveedorPorId(id);
    if (p != null) {
      p.activo = false;
    }
  }

  Future<List<ProductoEntity>> obtenerProductosPorProveedor(int proveedorId) async {
    return _productos.where((p) => p.proveedorId == proveedorId).toList();
  }

  Future<bool> eliminarProveedor(int id) async {
    final tieneProductos = _productos.any((p) => p.proveedorId == id);
    if (tieneProductos) return false;
    _proveedores.removeWhere((p) => p.id == id);
    return true;
  }

  Future<List<ProveedorEntity>> buscarProveedores(String query) async {
    final q = query.toLowerCase();
    return _proveedores.where((p) =>
      p.nombre.toLowerCase().contains(q) ||
      (p.empresa?.toLowerCase().contains(q) ?? false)
    ).toList();
  }

  // ==================== LOCALES ====================

  Future<LocalEntity?> obtenerLocalPorId(int id) async {
    try {
      return _locales.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<LocalEntity?> obtenerLocalPorSupabaseId(String supabaseId) async {
    try {
      return _locales.firstWhere((l) => l.supabaseId == supabaseId);
    } catch (_) {
      return null;
    }
  }

  Future<int> guardarLocal(LocalEntity local) async {
    if (local.id == 0) local.id = _nextId++;
    final index = _locales.indexWhere((l) => l.id == local.id);
    if (index >= 0) {
      _locales[index] = local;
    } else {
      _locales.add(local);
    }
    return local.id;
  }

  Future<List<LocalEntity>> obtenerLocales({bool soloActivos = true}) async {
    return soloActivos ? _locales.where((l) => l.activo).toList() : _locales;
  }

  Future<LocalEntity?> obtenerLocalActivo() async {
    try {
      return _locales.firstWhere((l) => l.activo);
    } catch (_) {
      return null;
    }
  }

  Future<int> contarProductosPorDepartamento(int departamentoId) async => 0;

  Future<bool> eliminarLocal(int id) async {
    _locales.removeWhere((l) => l.id == id);
    return true;
  }

  Future<void> actualizarSyncStatusLocal(int id, bool sincronizado) async {}
  Future<List<LocalEntity>> obtenerLocalesPendientesSync() async => [];

  // ==================== DEPARTAMENTOS ====================

  Future<int> guardarDepartamento(DepartamentoEntity departamento) async {
    if (departamento.id == 0) departamento.id = _nextId++;
    _departamentos.add(departamento);
    return departamento.id;
  }

  Future<List<DepartamentoEntity>> obtenerDepartamentos({
    bool? soloActivos = true,
    int? localId,
  }) async {
    var result = _departamentos;
    if (localId != null) {
      result = result.where((d) => d.localId == localId).toList();
    }
    if (soloActivos == true) {
      result = result.where((d) => d.activo).toList();
    }
    return result;
  }

  Future<DepartamentoEntity?> obtenerDepartamentoPorId(int id) async {
    try {
      return _departamentos.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> eliminarDepartamento(int id) async {
    _departamentos.removeWhere((d) => d.id == id);
    return true;
  }

  Future<void> actualizarSyncStatusDepartamento(int id, bool sincronizado) async {}
  Future<List<DepartamentoEntity>> obtenerDepartamentosPendientesSync() async => [];

  // ==================== CÓDIGOS DE BARRAS ALIAS ====================

  Future<void> guardarCodigoAlias(CodigoBarrasAliasEntity alias) async {
    if (alias.id == 0) alias.id = _nextId++;
    _alias.add(alias);
  }

  Future<CodigoBarrasAliasEntity?> obtenerAliasPorCodigo(String codigo) async {
    try {
      return _alias.firstWhere((a) => a.codigo == codigo && a.activo);
    } catch (_) {
      return null;
    }
  }

  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPorProducto(int productoId) async {
    return _alias.where((a) => a.productoId == productoId && a.activo).toList();
  }

  Future<void> desactivarAlias(int aliasId) async {
  try {
    final a = _alias.firstWhere((a) => a.id == aliasId);
    a.activo = false;
  } catch (_) {
    // Si falla el firstWhere no hace nada, reemplazando el if (a != null)
  }
}
  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPendientesSync() async => [];

  // ==================== LOTES ====================

  Future<void> guardarLote(LoteEntity lote) async {
    if (lote.id == 0) lote.id = _nextId++;
    _lotes.add(lote);
  }

  Future<double> obtenerStockTotalPorProducto(int productoId) async {
    double total = 0;
    for (var l in _lotes) {
      if (l.productoId == productoId && l.estado == 'activo') {
        total += l.cantidadRestante;
      }
    }
    return total;
  }

  Future<List<LoteEntity>> obtenerLotesActivos(
    int productoId, {
    bool priorizarVencimiento = true,
  }) async {
    var lotes = _lotes.where((l) =>
      l.productoId == productoId &&
      l.estado == 'activo' &&
      l.cantidadRestante > 0
    ).toList();
    if (priorizarVencimiento) {
      lotes.sort((a, b) {
        if (a.fechaVencimiento != null && b.fechaVencimiento != null) {
          return a.fechaVencimiento!.compareTo(b.fechaVencimiento!);
        }
        if (a.fechaVencimiento != null) return -1;
        if (b.fechaVencimiento != null) return 1;
        return a.fechaIngreso.compareTo(b.fechaIngreso);
      });
    }
    return lotes;
  }

  Future<bool> descontarLote(int loteId, double cantidad) async {
  try {
    final l = _lotes.firstWhere((l) => l.id == loteId);
    
    if (l.cantidadRestante < cantidad) return false;
    
    l.cantidadRestante -= cantidad;
    if (l.cantidadRestante <= 0) {
      l.cantidadRestante = 0;
      l.estado = 'agotado';
    }
    l.sincronizado = false;
    return true;
  } catch (_) {
    // Retorna false si no encuentra el lote, reemplazando el if (l == null) return false;
    return false;
  }
}
  Future<LoteEntity?> obtenerLoteParaVenta(
    int productoId, {
    bool priorizarVencimiento = true,
  }) async {
    final lotes = await obtenerLotesActivos(productoId, priorizarVencimiento: priorizarVencimiento);
    return lotes.isNotEmpty ? lotes.first : null;
  }

  Future<List<LoteEntity>> obtenerTodosLosLotes() async => _lotes;
  Future<List<ProductoEntity>> obtenerTodosLosProductos() async => _productos;
  Future<int> contarLotes() async => _lotes.length;
  Future<int> contarProductos() async => _productos.length;

  Future<Map<String, dynamic>> migrarStockExistenteALotes() async {
    return {
      'success': true,
      'lotesCreados': 0,
      'productosSinStock': 0,
      'productosConLotesPrevios': 0,
      'totalProductos': _productos.length,
      'error': null,
    };
  }

  Future<int> asignarSupabaseIdsAFaltantes() async => 0;

  Future<bool> eliminarLote(int id) async {
    _lotes.removeWhere((l) => l.id == id);
    return true;
  }

  Future<LoteEntity?> obtenerLotePorId(int id) async {
    try {
      return _lotes.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<MovimientoLoteEntity>> obtenerTodosMovimientosLote() async => _movimientosLote;
  Future<List<LoteEntity>> obtenerLotesPendientes() async => [];
  Future<List<LoteEntity>> obtenerLotesHistorial() async => [];

  Future<bool> verificarLote({
    required int loteId,
    required String codigoBarras,
    required double cantidadRecibida,
    required int usuarioId,
  }) async {
    final l = await obtenerLotePorId(loteId);
    if (l == null || l.estado != 'pendiente') return false;
    l.codigoLoteProveedor = codigoBarras;
    l.cantidadRestante = cantidadRecibida;
    l.estado = 'activo';
    l.sincronizado = false;
    final movimiento = MovimientoLoteEntity()
      ..loteId = l.id
      ..tipo = 'activacion'
      ..cantidad = cantidadRecibida
      ..fecha = DateTime.now()
      ..usuarioId = usuarioId
      ..observaciones = 'Lote activado desde pedido'
      ..sincronizado = false;
    _movimientosLote.add(movimiento);
    return true;
  }

  Future<void> guardarMovimientoLote(MovimientoLoteEntity movimiento) async {
    if (movimiento.id == 0) movimiento.id = _nextId++;
    _movimientosLote.add(movimiento);
  }

  Future<List<MovimientoLoteEntity>> obtenerMovimientosPorLote(int loteId) async {
    return _movimientosLote.where((m) => m.loteId == loteId).toList();
  }

  Future<List<MovimientoLoteEntity>> obtenerMovimientosLotePendientesSync() async => [];

  // ==================== HISTORIAL DE CÓDIGOS ====================

  Future<List<HistorialCodigoItem>> obtenerHistorialCodigosPorProducto(int productoId) async {
    final items = <HistorialCodigoItem>[];
    final alias = _alias.where((a) => a.productoId == productoId && a.activo).toList();
    for (var a in alias) {
      items.add(HistorialCodigoItem(
        codigo: a.codigo,
        fechaIngreso: a.fechaAsignacion,
        cantidad: 0,
        precio: 0,
        tipo: 'alias',
      ));
    }
    final lotes = _lotes.where((l) => l.productoId == productoId).toList();
    for (var l in lotes) {
      if (l.codigoLoteProveedor != null && l.codigoLoteProveedor!.isNotEmpty) {
        items.add(HistorialCodigoItem(
          codigo: l.codigoLoteProveedor!,
          fechaIngreso: l.fechaIngreso,
          fechaVencimiento: l.fechaVencimiento,
          cantidad: l.cantidadInicial,
          precio: l.costoUnitario ?? 0,
          tipo: 'lote',
        ));
      }
    }
    items.sort((a, b) => b.fechaIngreso.compareTo(a.fechaIngreso));
    return items;
  }

  // ==================== TELEGRAM CONFIG ====================

  Future<TelegramConfigEntity?> obtenerTelegramConfigPorUsuario(int usuarioId) async {
    try {
      return _telegramConfigs.firstWhere((c) => c.usuarioId == usuarioId);
    } catch (_) {
      return null;
    }
  }

  Future<List<TelegramConfigEntity>> obtenerTodasTelegramConfigs() async => _telegramConfigs;
  Future<List<TelegramConfigEntity>> obtenerTelegramConfigsPendientesSync() async => [];

  Future<int> guardarTelegramConfig(TelegramConfigEntity config) async {
    if (config.id == 0) config.id = _nextId++;
    _telegramConfigs.add(config);
    return config.id;
  }

  Future<TelegramConfigEntity?> obtenerTelegramConfig() async {
    return _telegramConfigs.isNotEmpty ? _telegramConfigs.first : null;
  }

  Future<void> actualizarSyncStatusTelegramConfig(int id, bool sincronizado) async {}
  Future<List<TelegramConfigEntity>> obtenerTelegramConfigs() async => _telegramConfigs;
  Future<void> eliminarTelegramConfig(int id) async {
    _telegramConfigs.removeWhere((c) => c.id == id);
  }

  // ==================== Sincronización general ====================

  Future<List<VentaEntity>> obtenerVentasPendientesSync() async => [];
  Future<void> actualizarSyncStatusVenta(int id, String nuevoEstado) async {}
  Future<List<ProductoEntity>> obtenerProductosPendientesSync() async => [];
  Future<List<LoteEntity>> obtenerLotesPendientesSync() async => [];

  Future<void> guardarDetallesVenta(String ventaId, List<DetalleVentaEntity> detalles) async {
    _detallesVenta.removeWhere((d) => d.ventaIdFk == ventaId);
    for (var item in detalles) {
      if (item.id == 0) item.id = _nextId++;
      item.ventaIdFk = ventaId;
      _detallesVenta.add(item);
    }
  }

  Future<void> resetearSupabaseIdsIncorrectos() async {}

  Future<void> inicializarUsuarioAdminPorDefecto() async {
    if (_usuarios.isEmpty) {
      _initDemoData();
    }
  }

  // ==================== DASHBOARD ====================

  Future<Map<String, dynamic>> obtenerResumenDashboard() async {
    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59, 999);
    final totalHoy = await obtenerTotalVentasPorRango(inicioHoy, finDia);
    final ultimasVentas = await obtenerUltimasVentas(5);
    final topProductos = await obtenerProductosMasVendidos(5);
    final stockBajo = await obtenerProductosStockBajo();
    return {
      'totalHoy': totalHoy,
      'totalSemana': totalHoy,
      'totalMes': totalHoy,
      'totalGastosMes': 0,
      'variacion': 0,
      'ventasHoy': _ventas.length,
      'ultimasVentas': ultimasVentas,
      'topProductos': topProductos,
      'stockBajo': stockBajo,
      'ventasPorEmpleado': {},
      'ventasPorDia': [],
    };
  }

  Future<List<VentaEntity>> obtenerVentasPorPeriodo(String periodo) async => _ventas;

  // ==================== MÉTODO EXTRA ====================

  // Ya tenemos obtenerTurnoPorId más arriba, pero lo dejamos para compatibilidad
}