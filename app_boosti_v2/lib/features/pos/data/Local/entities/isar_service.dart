import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Entidades
import '../entities/turno_entity.dart';
import '../entities/log_entity.dart';
import '../entities/venta_entity.dart';
import '../entities/detalle_venta_entity.dart';
import '../entities/producto_entity.dart';
import '../entities/usuario_entity.dart';
import '../entities/movimiento_inventario_entity.dart';
import 'gasto_entity.dart';

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

  // ==================== INICIALIZACIÓN ====================
  Future<Isar> _initIsar() async {
    if (_isarInstance != null && _isarInstance!.isOpen) {
      return _isarInstance!;
    }

    final dir = await getApplicationDocumentsDirectory();
    final prefs = await SharedPreferences.getInstance();
    final empresaId = prefs.getString('empresa_id') ?? 'default';
    final dbPath = '${dir.path}/isar_$empresaId';

    await Directory(dbPath).create(recursive: true);
    late Isar isar;

    try {
      isar = await Isar.open(
        [
          VentaEntitySchema,
          DetalleVentaEntitySchema,
          ProductoEntitySchema,
          UsuarioEntitySchema,
          MovimientoInventarioEntitySchema,
          GastoEntitySchema,
          LogEntitySchema,
          TurnoEntitySchema, // ✅ Incluido
        ],
        directory: dbPath,
        inspector: true,
      );
      debugPrint('✅ Isar abierto en: $dbPath');
    } catch (e) {
      debugPrint('⚠️ Error abriendo Isar en $dbPath: $e');
      final fallbackPath = '${dir.path}/isar_default';
      await Directory(fallbackPath).create(recursive: true);

      for (final name in Isar.instanceNames) {
        final existing = Isar.getInstance(name);
        if (existing != null && existing.isOpen) {
          await existing.close();
          debugPrint('🔄 Instancia anterior cerrada: $name');
        }
      }

      isar = await Isar.open(
        [
          VentaEntitySchema,
          DetalleVentaEntitySchema,
          ProductoEntitySchema,
          UsuarioEntitySchema,
          MovimientoInventarioEntitySchema,
          GastoEntitySchema,
          LogEntitySchema,
          TurnoEntitySchema,
        ],
        directory: fallbackPath,
        inspector: true,
      );
      debugPrint('✅ Isar abierto en ruta por defecto: $fallbackPath');
    }

    try {
      await _inicializarProductosDemo(isar);
      await _inicializarUsuariosDemo(isar);
    } catch (e) {
      debugPrint('⚠️ Error inicializando datos demo: $e');
    }

    _isarInstance = isar;
    return isar;
  }

  // ==================== DEMO DATA ====================
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
          ..stockMinimo = 10.0
          ..imagenUrl = '',
        ProductoEntity()
          ..codigoBarras = '75010002'
          ..nombre = 'Arroz Premium 1kg'
          ..precioUnidad = 1.20
          ..stock = 100.0
          ..esPesado = false
          ..categoria = 'Abarrotes'
          ..proveedorNombre = 'Distribuidora Alimentos S.A.'
          ..proveedorTelefono = '0414-9876543'
          ..stockMinimo = 15.0
          ..imagenUrl = '',
        ProductoEntity()
          ..codigoBarras = '75010003'
          ..nombre = 'Queso Blanco Duro'
          ..precioUnidad = 6.80
          ..stock = 25.0
          ..esPesado = true
          ..categoria = 'Lácteos'
          ..proveedorNombre = 'Quesera La Llanerita'
          ..proveedorTelefono = '0424-5558899'
          ..stockMinimo = 5.0
          ..imagenUrl = '',
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
        ..pin = '1111'
        ..rol = 'cajero'
        ..activo = true
        ..estado = 'activo'
        ..cajaAsignada = 'Caja 01';

      await isar.writeTxn(() async {
        await isar.usuarioEntitys.putAll([adminDefault, cajeroDefault]);
      });
    }
  }



  Future<double> obtenerTotalVentasPorEmpleadoYRango(String empleado, DateTime inicio, DateTime fin) async {
  final isar = await db;
  final ventas = await isar.ventaEntitys
      .filter()
      .empleadoEqualTo(empleado)
      .and()
      .fechaBetween(inicio, fin, includeLower: true, includeUpper: true)
      .findAll();
  double total = 0;
  for (var v in ventas) {
    total += v.total;
  }
  return total;
}

  // ==================== GESTIÓN DE USUARIOS ====================
  Future<void> inicializarUsuarioAdminPorDefecto() async {
    final isar = await db;
    await _inicializarUsuariosDemo(isar);
  }

  Future<UsuarioEntity?> obtenerUsuarioPorId(int id) async {
    final isar = await db;
    return await isar.usuarioEntitys.get(id);
  }

  Future<ProductoEntity?> obtenerProductoPorId(int id) async {
  final isar = await db;
  return await isar.productoEntitys.get(id);
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

  Future<void> crearUsuario({
    required String nombre,
    required String pin,
    required String rol,
    required String caja,
  }) async {
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
    } catch (_) {
      return null;
    }
  }

  // ==================== GESTIÓN DE GASTOS ====================
  Future<void> guardarGasto(GastoEntity gasto) async {
    final isar = await db;
    gasto.syncStatus = gasto.syncStatus.isEmpty ? 'pending' : gasto.syncStatus;
    await isar.writeTxn(() async {
      await isar.gastoEntitys.put(gasto);
    });
  }

  Future<List<GastoEntity>> obtenerGastos() async {
    final isar = await db;
    return await isar.gastoEntitys.where().sortByFechaDesc().findAll();
  }

  Future<List<GastoEntity>> obtenerGastosPendientesSync() async {
    final isar = await db;
    return await isar.gastoEntitys
        .filter()
        .syncStatusEqualTo('pending')
        .or()
        .syncStatusEqualTo('failed')
        .findAll();
  }

  Future<void> actualizarSyncStatusGasto(int id, String nuevoEstado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final gasto = await isar.gastoEntitys.get(id);
      if (gasto != null) {
        gasto.syncStatus = nuevoEstado;
        await isar.gastoEntitys.put(gasto);
      }
    });
  }

  // ==================== LOGS ====================
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

  // ==================== GESTIÓN DE VENTAS ====================
  Future<void> guardarVenta(VentaEntity venta) async {
    final isar = await db;
    await isar.writeTxn(() async {
      venta.syncStatus = venta.syncStatus.isEmpty ? 'pending' : venta.syncStatus;
      await isar.ventaEntitys.put(venta);

      for (var item in venta.items) {
        item.ventaId = venta.id;
        await isar.detalleVentaEntitys.put(item);
      }

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
      finLocal = inicioLocal.add(
          const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
    } else if (periodo == 'mes') {
      inicioLocal = DateTime(now.year, now.month, 1, 0, 0, 0);
      finLocal = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    } else {
      return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
    }
    return await isar.ventaEntitys
        .filter()
        .fechaBetween(
          inicioLocal.toUtc(),
          finLocal.toUtc(),
          includeLower: true,
          includeUpper: true,
        )
        .sortByFechaDesc()
        .findAll();
  }

  // ==================== GESTIÓN DE DETALLES DE VENTA ====================

/// Obtiene todos los detalles de una venta por su ID
Future<List<DetalleVentaEntity>> obtenerDetallesPorVenta(int ventaId) async {
  final isar = await db;
  return await isar.detalleVentaEntitys
      .filter()
      .ventaIdEqualTo(ventaId)
      .findAll();
}

  // ==================== MÉTODOS DE SINCRONIZACIÓN ====================
  Future<List<VentaEntity>> obtenerVentasPendientesSync() async {
    final isar = await db;
    return await isar.ventaEntitys
        .filter()
        .syncStatusEqualTo('pending')
        .or()
        .syncStatusEqualTo('failed')
        .findAll();
  }

  Future<List<MovimientoInventarioEntity>> obtenerMovimientosPendientesSync() async {
    final isar = await db;
    return await isar.movimientoInventarioEntitys
        .filter()
        .syncStatusEqualTo('pending')
        .or()
        .syncStatusEqualTo('failed')
        .findAll();
  }

  Future<void> actualizarSyncStatusVenta(int id, String nuevoEstado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final venta = await isar.ventaEntitys.get(id);
      if (venta != null) {
        venta.syncStatus = nuevoEstado;
        await isar.ventaEntitys.put(venta);
      }
    });
  }

  Future<void> actualizarSyncStatusMovimiento(int id, String nuevoEstado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final mov = await isar.movimientoInventarioEntitys.get(id);
      if (mov != null) {
        mov.syncStatus = nuevoEstado;
        await isar.movimientoInventarioEntitys.put(mov);
      }
    });
  }

  // ==================== GESTIÓN DE MOVIMIENTOS ====================
  Future<void> guardarMovimientoInventario(MovimientoInventarioEntity movimiento) async {
    final isar = await db;
    await isar.writeTxn(() async {
      movimiento.syncStatus = movimiento.syncStatus.isEmpty ? 'pending' : movimiento.syncStatus;
      await isar.movimientoInventarioEntitys.put(movimiento);
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

  // ==================== GESTIÓN DE TURNOS (COMPLETA) ====================

  Future<void> guardarTurno(TurnoEntity turno) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.turnoEntitys.put(turno);
    });
  }

  Future<List<TurnoEntity>> obtenerTurnos() async {
    final isar = await db;
    return await isar.turnoEntitys.where().sortByFechaAperturaDesc().findAll();
  }

  Future<TurnoEntity?> obtenerTurnoAbiertoPorUsuario(int usuarioId) async {
    final isar = await db;
    return await isar.turnoEntitys
        .filter()
        .usuarioIdEqualTo(usuarioId)
        .and()
        .estadoEqualTo('abierto')
        .findFirst();
  }

  Future<void> cerrarTurno(int turnoId, double montoFinal) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final turno = await isar.turnoEntitys.get(turnoId);
      if (turno != null) {
        turno.fechaCierre = DateTime.now();
        turno.montoFinal = montoFinal;
        turno.estado = 'cerrado';
        turno.syncStatus = 'pending';
        await isar.turnoEntitys.put(turno);
      }
    });
  }

  // ✅ Método necesario para sincronización
  Future<List<TurnoEntity>> obtenerTurnosPendientes() async {
    final isar = await db;
    return await isar.turnoEntitys
        .filter()
        .syncStatusEqualTo('pending')
        .findAll();
  }

  // ✅ Método para marcar turno como sincronizado
  Future<void> marcarTurnoComoSincronizado(int turnoId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final turno = await isar.turnoEntitys.get(turnoId);
      if (turno != null) {
        turno.syncStatus = 'synced';
        await isar.turnoEntitys.put(turno);
      }
    });
  }
}