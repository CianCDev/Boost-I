import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Entidades
import '../entities/log_entity.dart';
import '../entities/venta_entity.dart';
import '../entities/producto_entity.dart';
import '../entities/usuario_entity.dart';
import '../entities/movimiento_inventario_entity.dart';

class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  Isar? _isarInstance;

  Future<Isar> get db async {
    if (_isarInstance != null && _isarInstance!.isOpen) {
      return _isarInstance!;
    }
    _isarInstance = await _initIsar();
    return _isarInstance!;
  }

  // ==================== INICIALIZACIÓN DE BASE DE DATOS ====================
  Future<Isar> _initIsar() async {
    if (Isar.instanceNames.isNotEmpty) {
      final existingInstance = Isar.getInstance();
      if (existingInstance != null && existingInstance.isOpen) {
        await existingInstance.close();
      }
    }
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        VentaEntitySchema,
        ProductoEntitySchema,
        UsuarioEntitySchema,
        MovimientoInventarioEntitySchema,
      ],
      directory: dir.path,
      inspector: true,
    );

    await _inicializarProductosDemo(isar);
    await _inicializarUsuariosDemo(isar);
    return isar;
  }

  Future<void> _inicializarProductosDemo(Isar isar) async {
    final count = await isar.productoEntitys.count();
    if (count == 0) {
      final productosIniciales = [
        ProductoEntity()
          ..codigoBarras = '75010001'
          ..nombre = 'Manzana Roja Importada'
          ..precioUnidad = 3.50
          ..stock = 50.0
          ..esPesado = true
          ..categoria = 'Frutas'
          ..proveedorNombre = 'Frutas del Campo C.A.'
          ..proveedorTelefono = '0412-1234567'
          ..stockMinimo = 10.0,
        ProductoEntity()
          ..codigoBarras = '75010002'
          ..nombre = 'Arroz Premium 1kg'
          ..precioUnidad = 1.20
          ..stock = 100.0
          ..esPesado = false
          ..categoria = 'Abarrotes'
          ..proveedorNombre = 'Distribuidora Alimentos S.A.'
          ..proveedorTelefono = '0414-9876543'
          ..stockMinimo = 15.0,
        ProductoEntity()
          ..codigoBarras = '75010003'
          ..nombre = 'Queso Blanco Duro'
          ..precioUnidad = 6.80
          ..stock = 25.0
          ..esPesado = true
          ..categoria = 'Lácteos'
          ..proveedorNombre = 'Quesera La Llanerita'
          ..proveedorTelefono = '0424-5558899'
          ..stockMinimo = 5.0,
      ];
      await isar.writeTxn(() async {
        await isar.productoEntitys.putAll(productosIniciales);
      });
    }
  }

  Future<void> _inicializarUsuariosDemo(Isar isar) async {
    final count = await isar.usuarioEntitys.count();
    if (count == 0) {
      final adminDefault = UsuarioEntity()
        ..nombre = 'Administrador'
        ..pin = '1234'
        ..rol = 'admin'
        ..activo = true
        ..estado = 'activo'
        ..cajaAsignada = 'Caja Principal';

      final cajeroDefault = UsuarioEntity()
        ..nombre = 'Cajero 01'
        ..pin = '0000'
        ..rol = 'cajero'
        ..activo = true
        ..estado = 'activo'
        ..cajaAsignada = 'Caja 01';

      await isar.writeTxn(() async {
        await isar.usuarioEntitys.putAll([adminDefault, cajeroDefault]);
      });
    }
  }

  // ==================== GESTIÓN DE USUARIOS (COMPLETA) ====================
  Future<void> inicializarUsuarioAdminPorDefecto() async {
    final isar = await db;
    await _inicializarUsuariosDemo(isar);
  }

  Future<List<UsuarioEntity>> obtenerUsuarios() async {
    final isar = await db;
    return await isar.usuarioEntitys.where().findAll();
  }

  Future<List<UsuarioEntity>> obtenerUsuariosActivos() async {
    final isar = await db;
    return await isar.usuarioEntitys.filter().activoEqualTo(true).findAll();
  }

  Future<UsuarioEntity> guardarUsuario(UsuarioEntity usuario) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.usuarioEntitys.put(usuario);
    });
    return usuario;
  }

  /// Crea un nuevo usuario con validaciones
  Future<void> crearUsuario({required String nombre, required String pin, required String rol, required String caja}) async {
    final isar = await db;
    if (pin.trim().length != 4) throw Exception('El PIN debe tener 4 dígitos.');
    await isar.writeTxn(() async {
      final nuevoUsuario = UsuarioEntity()
        ..nombre = nombre.trim()
        ..pin = pin.trim()
        ..rol = rol.toLowerCase()
        ..activo = true
        ..estado = 'activo'
        ..cajaAsignada = caja;
      await isar.usuarioEntitys.put(nuevoUsuario);
    });
  }

  Future<bool> eliminarUsuario(int id) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      return await isar.usuarioEntitys.delete(id);
    });
  }

  Future<bool> cambiarRolUsuario(int usuarioId, String nuevoRol) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      final usuario = await isar.usuarioEntitys.get(usuarioId);
      if (usuario != null) {
        usuario.rol = nuevoRol.toLowerCase();
        await isar.usuarioEntitys.put(usuario);
        return true;
      }
      return false;
    });
  }



  Future<void> guardarLog(LogEntity log) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.logEntitys.put(log);
    });
  }

  Future<List<LogEntity>> obtenerLogs() async {
    final isar = await db;
    return await isar.logEntitys.where().sortByFechaDesc().findAll();
  }

  Future<List<LogEntity>> obtenerLogsPendientesSync() async {
    final isar = await db;
    return await isar.logEntitys.filter().sincronizadoEqualTo(false).findAll();
  }

  Future<void> marcarLogsComoSincronizados(List<int> ids) async {
    final isar = await db;
    await isar.writeTxn(() async {
      for (var id in ids) {
        final log = await isar.logEntitys.get(id);
        if (log != null) {
          log.sincronizado = true;
          await isar.logEntitys.put(log);
        }
      }
    });
  }

  Future<void> actualizarEstadoUsuario(int usuarioId, String nuevoEstado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final usuario = await isar.usuarioEntitys.get(usuarioId);
      if (usuario != null) {
        usuario.estado = nuevoEstado;
        await isar.usuarioEntitys.put(usuario);
      }
    });
  }

  Future<bool> cambiarClaveUsuario(int usuarioId, String nuevaClave) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      final usuario = await isar.usuarioEntitys.get(usuarioId);
      if (usuario != null) {
        usuario.pin = nuevaClave;
        await isar.usuarioEntitys.put(usuario);
        return true;
      }
      return false;
    });
  }

  Future<UsuarioEntity?> validarLogin(String nombre, String pin) async {
    final isar = await db;
    try {
      return await isar.usuarioEntitys
          .filter()
          .nombreEqualTo(nombre, caseSensitive: false)
          .pinEqualTo(pin)
          .and()
          .activoEqualTo(true)
          .findFirst();
    } catch (_) { return null; }
  }

  // ==================== GESTIÓN DE VENTAS ====================
  Future<void> guardarVenta(VentaEntity venta) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.ventaEntitys.put(venta);
      for (var item in venta.items) {
        ProductoEntity? producto;
        if (item.productoId != null) {
          producto = await isar.productoEntitys.get(item.productoId!);
        }
        producto ??= await isar.productoEntitys
            .filter()
            .nombreEqualTo(item.nombreProducto, caseSensitive: false)
            .findFirst();

        if (producto != null) {
          final nuevoStock = producto.stock - item.cantidad;
          producto.stock = nuevoStock < 0 ? 0.0 : nuevoStock;
          await isar.productoEntitys.put(producto);
        }
      }
    });
  }

  Future<List<VentaEntity>> obtenerVentas() async {
    final isar = await db;
    return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
  }

  Future<List<VentaEntity>> obtenerVentasPorPeriodo(String periodo) async {
    final isar = await db;
    final now = DateTime.now();
    if (periodo == 'todos') {
      return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
    }
    late DateTime inicioLocal;
    late DateTime finLocal;
    if (periodo == 'dia') {
      inicioLocal = DateTime(now.year, now.month, now.day, 0, 0, 0);
      finLocal = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    } else if (periodo == 'semana') {
      inicioLocal = DateTime(now.year, now.month, now.day - (now.weekday - 1), 0, 0, 0);
      finLocal = inicioLocal.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
    } else if (periodo == 'mes') {
      inicioLocal = DateTime(now.year, now.month, 1, 0, 0, 0);
      finLocal = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    } else {
      return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
    }
    return await isar.ventaEntitys
        .filter()
        .fechaBetween(inicioLocal.toUtc(), finLocal.toUtc(), includeLower: true, includeUpper: true)
        .sortByFechaDesc()
        .findAll();
  }

  // ==================== SINCRONIZACIÓN ====================
  Future<List<VentaEntity>> obtenerVentasPendientesSync() async {
    final isar = await db;
    return await isar.ventaEntitys.filter().sincronizadoEqualTo(false).findAll();
  }

  Future<int> contarVentasPendientesSync() async {
    final isar = await db;
    return await isar.ventaEntitys.filter().sincronizadoEqualTo(false).count();
  }

  Future<int> sincronizarVentasConServidor() async {
    final pendientes = await obtenerVentasPendientesSync();
    if (pendientes.isEmpty) return 0;
    await Future.delayed(const Duration(seconds: 1));
    final isar = await db;
    await isar.writeTxn(() async {
      for (var venta in pendientes) {
        venta.sincronizado = true;
        await isar.ventaEntitys.put(venta);
      }
    });
    return pendientes.length;
  }

  Future<void> marcarVentasComoSincronizadas(List<int> ids) async {
    final isar = await db;
    await isar.writeTxn(() async {
      for (var id in ids) {
        final venta = await isar.ventaEntitys.get(id);
        if (venta != null) {
          venta.sincronizado = true;
          await isar.ventaEntitys.put(venta);
        }
      }
    });
  }

  // ==================== GESTIÓN DE MOVIMIENTOS ====================
  Future<void> guardarMovimientoInventario(MovimientoInventarioEntity movimiento) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.movimientoInventarioEntitys.put(movimiento);
    });
  }

  Future<List<MovimientoInventarioEntity>> obtenerMovimientosPendientesSync() async {
    final isar = await db;
    return await isar.movimientoInventarioEntitys.filter().sincronizadoEqualTo(false).findAll();
  }

  Future<void> marcarMovimientosComoSincronizados(List<int> ids) async {
    final isar = await db;
    await isar.writeTxn(() async {
      for (var id in ids) {
        final mov = await isar.movimientoInventarioEntitys.get(id);
        if (mov != null) {
          mov.sincronizado = true;
          await isar.movimientoInventarioEntitys.put(mov);
        }
      }
    });
  }

  // ==================== GESTIÓN DE INVENTARIO ====================
  Future<List<ProductoEntity>> obtenerProductos() async {
    final isar = await db;
    return await isar.productoEntitys.where().findAll();
  }

  Future<List<ProductoEntity>> buscarProductoPorCodigoONombre(String query) async {
    if (query.trim().isEmpty) return [];
    final isar = await db;
    final q = query.trim().toLowerCase();
    return await isar.productoEntitys
        .filter()
        .codigoBarrasContains(q, caseSensitive: false)
        .or()
        .nombreContains(q, caseSensitive: false)
        .findAll();
  }

  Future<void> guardarProducto(ProductoEntity producto) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.productoEntitys.put(producto);
    });
  }

  Future<void> eliminarProducto(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.productoEntitys.delete(id);
    });
  }

  Future<List<ProductoEntity>> obtenerProductosStockBajo() async {
    final isar = await db;
    final productos = await isar.productoEntitys.where().findAll();
    return productos.where((p) => p.stock <= p.stockMinimo).toList();
  }

  Future<void> actualizarStockProducto(int idProducto, double nuevoStock) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final producto = await isar.productoEntitys.get(idProducto);
      if (producto != null) {
        producto.stock = nuevoStock < 0 ? 0.0 : nuevoStock;
        await isar.productoEntitys.put(producto);
      }
    });
  }
}