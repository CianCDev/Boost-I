import 'package:flutter/foundation.dart';
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
    // Si Isar ya está abierto pero faltan esquemas o queremos reiniciar la conexión
    if (Isar.instanceNames.isNotEmpty) {
      final existingInstance = Isar.getInstance();
      if (existingInstance != null && existingInstance.isOpen) {
        // Cerramos para forzar la apertura con la lista completa de esquemas
        await existingInstance.close();
      }
    }
    // Abrimos la base de datos pasando explícitamente los esquemas
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [
        VentaEntitySchema, 
        ProductoEntitySchema,
      ],
      directory: dir.path,
      inspector: true,
    );

    // Cargar productos iniciales si el inventario está vacío
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
          ..categoria = 'Frutas',
        ProductoEntity()
          ..codigoBarras = '75010002'
          ..nombre = 'Arroz Premium 1kg'
          ..precioUnidad = 1.20
          ..stock = 100.0
          ..esPesado = false
          ..categoria = 'Abarrotes',
        ProductoEntity()
          ..codigoBarras = '75010003'
          ..nombre = 'Queso Blanco Duro'
          ..precioUnidad = 6.80
          ..stock = 25.0
          ..esPesado = true
          ..categoria = 'Lácteos',
      ];

      await isar.writeTxn(() async {
        await isar.productoEntitys.putAll(productosIniciales);
      });
    }
  }

  // ==================== INYECCIÓN DIRECTA DE PRUEBA ====================
  /// Fuerza el guardado de productos y ventas reales para probar la persistencia
  Future<void> inyectarDatosPruebaReales() async {
    final isar = await db;

    // 1. Crear Productos
    final prod1 = ProductoEntity()
      ..codigoBarras = '75099001'
      ..nombre = 'Harina PAN 1kg'
      ..precioUnidad = 1.20
      ..stock = 50.0
      ..esPesado = false
      ..categoria = 'Abarrotes';

    final prod2 = ProductoEntity()
      ..codigoBarras = '75099002'
      ..nombre = 'Café Molido 250g'
      ..precioUnidad = 2.50
      ..stock = 30.0
      ..esPesado = false
      ..categoria = 'Abarrotes';

    // 2. Crear Venta con Ítems
    final itemVenta = VentaItemEntity()
      ..nombreProducto = 'Harina PAN 1kg'
      ..precioUnidad = 1.20
      ..cantidad = 2.0
      ..subtotal = 2.40;

    final ventaReal = VentaEntity()
      ..ventaIdString = 'V-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
      ..fecha = DateTime.now()
      ..total = 2.40
      ..subtotal = 2.07
      ..impuesto = 0.33
      ..metodoPago = 'Efectivo'
      ..cedulaCliente = 'V-12345678'
      ..empleado = 'Administrador'
      ..items = [itemVenta]
      ..sincronizado = false;

    // Guardar transacción
    await isar.writeTxn(() async {
      await isar.productoEntitys.put(prod1);
      await isar.productoEntitys.put(prod2);
      await isar.ventaEntitys.put(ventaReal);
    });

    // 3. Verificación inmediata en consola
    final productos = await isar.productoEntitys.where().findAll();
    final ventas = await isar.ventaEntitys.where().findAll();

    debugPrint('==================================================');
    debugPrint('🔍 COMPROBACIÓN DE INYECCIÓN DE DATOS EN ISAR');
    debugPrint('Total Productos en DB: ${productos.length}');
    for (var p in productos) {
      debugPrint(' -> [Producto] ${p.nombre} | Stock: ${p.stock} | Precio: \$${p.precioUnidad}');
    }

    debugPrint('Total Ventas en DB: ${ventas.length}');
    for (var v in ventas) {
      debugPrint(' -> [Venta ID] ${v.ventaIdString} | Total: \$${v.total} | Fecha: ${v.fecha}');
    }
    debugPrint('==================================================');
  }

  // ==================== GESTIÓN DE VENTAS ====================
  Future<void> guardarVenta(VentaEntity venta) async {
    final isar = await db;
    await isar.writeTxn(() async {
      // 1. Guardar la venta
      await isar.ventaEntitys.put(venta);

      // 2. Descontar el stock automáticamente de cada producto vendido
      for (var item in venta.items) {
        final producto = await isar.productoEntitys
            .filter()
            .nombreEqualTo(item.nombreProducto)
            .findFirst();

        if (producto != null) {
          producto.stock = (producto.stock - item.cantidad).clamp(0.0, 999999.0);
          await isar.productoEntitys.put(producto);
        }
      }
    });
  }

  Future<List<VentaEntity>> obtenerVentasPorPeriodo(String periodo) async {
    final isar = await db;
    final now = DateTime.now();
    
    DateTime fechaInicio;
    if (periodo == 'dia') {
      fechaInicio = DateTime(now.year, now.month, now.day);
    } else if (periodo == 'semana') {
      fechaInicio = now.subtract(const Duration(days: 7));
    } else {
      fechaInicio = now.subtract(const Duration(days: 30));
    }

    return await isar.ventaEntitys
        .filter()
        .fechaGreaterThan(fechaInicio)
        .sortByFechaDesc()
        .findAll();
  }

  // ==================== SINCRONIZACIÓN OFFLINE/ONLINE ====================
  /// Obtiene todas las ventas pendientes de sincronizar con el backend
  Future<List<VentaEntity>> obtenerVentasPendientesSync() async {
    final isar = await db;
    return await isar.ventaEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  /// Retorna el conteo rápido de ventas pendientes sin cargarlas a memoria
  Future<int> contarVentasPendientesSync() async {
    final isar = await db;
    return await isar.ventaEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .count();
  }

  // ==================== GESTIÓN DE INVENTARIO ====================
  Future<List<ProductoEntity>> obtenerProductos() async {
    final isar = await db;
    return await isar.productoEntitys.where().findAll();
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
}