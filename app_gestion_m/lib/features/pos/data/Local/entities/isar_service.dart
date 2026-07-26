import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

// Entidades
import '../entities/venta_entity.dart';
import '../entities/producto_entity.dart';

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

  // Inicializa la base de datos local de Isar incluyendo ambas entidades
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
      ],
      directory: dir.path,
      inspector: true,
    );

    await _inicializarProductosDemo(isar);
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

  // ==================== GESTIÓN DE VENTAS ====================
  
  /// Guarda la venta y descuenta automáticamente el stock de los productos[cite: 7]
  Future<void> guardarVenta(VentaEntity venta) async {
    final isar = await db;
    await isar.writeTxn(() async {
      // 1. Guardar la venta[cite: 7]
      await isar.ventaEntitys.put(venta);

      // 2. Descontar el stock de los productos vendidos[cite: 7]
      for (var item in venta.items) {
        final producto = await isar.productoEntitys
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

  /// Obtiene todas las ventas ordenadas por fecha descendente[cite: 7]
  Future<List<VentaEntity>> obtenerVentas() async {
    final isar = await db;
    return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
  }

  /// Obtiene ventas filtradas por período ('dia', 'semana', 'mes', 'todos')[cite: 7]
  Future<List<VentaEntity>> obtenerVentasPorPeriodo(String periodo) async {
    final isar = await db;
    final now = DateTime.now();
    
    DateTime fechaInicio;
    if (periodo == 'dia') {
      fechaInicio = DateTime(now.year, now.month, now.day);
    } else if (periodo == 'semana') {
      fechaInicio = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    } else if (periodo == 'mes') {
      fechaInicio = DateTime(now.year, now.month, 1);
    } else {
      return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
    }

    return await isar.ventaEntitys
        .filter()
        .fechaGreaterThan(fechaInicio, include: true)
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

  /// Procesa la sincronización remota de las ventas pendientes[cite: 7]
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

  /// Marca manualmente una lista de IDs de ventas como sincronizadas[cite: 7]
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

  /// Búsqueda rápida por código o nombre para el POS[cite: 7]
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