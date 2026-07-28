import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Entidades
import '../entities/venta_entity.dart';
import '../entities/producto_entity.dart';
import '../entities/usuario_entity.dart';

class IsarService {
  // Patrón Singleton para evitar abrir la DB múltiples veces
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  Isar? _isarInstance;

  /// Obtiene la instancia activa de Isar o la inicializa de forma segura
  Future<Isar> get db async {
    if (_isarInstance != null && _isarInstance!.isOpen) {
      return _isarInstance!;
    }

    _isarInstance = await _initIsar();
    return _isarInstance!;
  }

  // Inicializa la base de datos local de Isar incluyendo todas las entidades (Venta, Producto, Usuario)
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
      ],
      directory: dir.path,
      inspector: true,
    );

    await _inicializarProductosDemo(isar);
    await _inicializarUsuariosDemo(isar);
    return isar;
  }

  // Inserta productos por defecto la primera vez que se abre la app
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

  // Inicializa usuarios por defecto (Admin y Cajero) si no existen
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

  // ==================== GESTIÓN DE USUARIOS ====================

  /// Obtiene todos los usuarios registrados en la DB local
  Future<List<UsuarioEntity>> obtenerUsuarios() async {
    final isar = await db;
    return await isar.usuarioEntitys.where().findAll();
  }

  /// Actualiza el estado actual del usuario (ej. 'activo', 'inactivo', 'descanso')
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

  /// Cambia el PIN / clave de un usuario por su ID
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

  /// Filtra solo los usuarios con rol 'cajero'
  Future<List<UsuarioEntity>> obtenerEstadoCajeros() async {
    final isar = await db;
    return await isar.usuarioEntitys
        .filter()
        .rolEqualTo('cajero')
        .findAll();
  }

  /// Inicializa un administrador por defecto si la tabla de usuarios está vacía
  Future<void> inicializarUsuarioAdminPorDefecto() async {
    final isar = await db;
    await _inicializarUsuariosDemo(isar);
  }

  /// Valida si el PIN y el nombre corresponden a un usuario válido
  Future<UsuarioEntity?> validarLogin(String nombre, String pin) async {
    final isar = await db;
    try {
      final usuario = await isar.usuarioEntitys
          .filter()
          .nombreEqualTo(nombre, caseSensitive: false)
          .pinEqualTo(pin)
          .and()
          .activoEqualTo(true)
          .findFirst();
      return usuario;
    } catch (_) {
      return null;
    }
  }

  /// Obtiene la lista de todos los usuarios activos para mostrarlos en el login
  Future<List<UsuarioEntity>> obtenerUsuariosActivos() async {
    final isar = await db;
    return await isar.usuarioEntitys.filter().activoEqualTo(true).findAll();
  }

  // ==================== GESTIÓN DE VENTAS ====================
  
  /// Guarda la venta y descuenta automáticamente el stock de los productos de forma segura
  Future<void> guardarVenta(VentaEntity venta) async {
    final isar = await db;
    await isar.writeTxn(() async {
      // 1. Guardar la venta
      await isar.ventaEntitys.put(venta);

      // 2. Descontar el stock de los productos vendidos
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

  /// Obtiene todas las ventas ordenadas por fecha descendente
  Future<List<VentaEntity>> obtenerVentas() async {
    final isar = await db;
    return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
  }

  /// Obtiene ventas filtradas por período ('dia', 'semana', 'mes', 'todos')
  Future<List<VentaEntity>> obtenerVentasPorPeriodo(String periodo) async {
    final isar = await db;
    final now = DateTime.now();

    // Si el periodo es 'todos' o viene vacio, retornamos directamente sin filtrar por fecha
    if (periodo == 'todos') {
      return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
    }

    late DateTime inicioLocal;
    late DateTime finLocal;

    if (periodo == 'dia') {
      inicioLocal = DateTime(now.year, now.month, now.day, 0, 0, 0);
      finLocal = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    } else if (periodo == 'semana') {
      // Obtenemos el lunes de la semana actual
      inicioLocal = DateTime(now.year, now.month, now.day - (now.weekday - 1), 0, 0, 0);
      // Obtenemos el domingo al final del día
      finLocal = inicioLocal.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
    } else if (periodo == 'mes') {
      inicioLocal = DateTime(now.year, now.month, 1, 0, 0, 0);
      finLocal = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    } else {
      return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
    }

    // Usamos fechaBetween convirtiendo los rangos locales a UTC
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

  // ==================== SINCRONIZACIÓN OFFLINE/ONLINE ====================
  
  Future<List<VentaEntity>> obtenerVentasPendientesSync() async {
    final isar = await db;
    return await isar.ventaEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  Future<int> contarVentasPendientesSync() async {
    final isar = await db;
    return await isar.ventaEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .count();
  }

  /// Procesa la sincronización remota de las ventas pendientes
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

  /// Marca manualmente una lista de IDs de ventas como sincronizadas
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

  // ==================== GESTIÓN DE INVENTARIO Y PROVEEDORES ====================
  
  Future<List<ProductoEntity>> obtenerProductos() async {
    final isar = await db;
    return await isar.productoEntitys.where().findAll();
  }

  /// Búsqueda rápida por código o nombre para el POS
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

  /// Obtiene únicamente los productos cuyo stock sea menor o igual al límite mínimo configurado
  Future<List<ProductoEntity>> obtenerProductosStockBajo() async {
    final isar = await db;
    final productos = await isar.productoEntitys.where().findAll();
    return productos.where((p) => p.stock <= p.stockMinimo).toList();
  }

  /// Actualiza de forma directa el stock de un producto específico
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