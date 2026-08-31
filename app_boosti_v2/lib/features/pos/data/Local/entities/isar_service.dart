import 'dart:io';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Entidades
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
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

/// Servicio singleton para gestionar la base de datos local con Isar.
/// Provee métodos CRUD y de sincronización para todas las entidades.
class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  Isar? _isarInstance;

  /// Obtiene la instancia de la base de datos (inicialización perezosa).
  Future<Isar> get db async {
    if (_isarInstance != null && _isarInstance!.isOpen) {
      return _isarInstance!;
    }
    _isarInstance = await _initIsar();
    return _isarInstance!;
  }

  // ==================== INICIALIZACIÓN ====================

  /// Inicializa la base de datos Isar con todos los esquemas.
  /// Usa el ID de empresa de SharedPreferences para aislar los datos.
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
          PedidoEntitySchema,
          DetallePedidoEntitySchema,
          RecepcionEntitySchema,
          TurnoEntitySchema,
          LocalEntitySchema,
          ProveedorEntitySchema,
          CodigoBarrasAliasEntitySchema,
          LoteEntitySchema,
          DepartamentoEntitySchema,
          TelegramConfigEntitySchema,
          CategoriaEntitySchema,
          MarcaEntitySchema,
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
          CategoriaEntitySchema,
          MarcaEntitySchema,
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

  // ==================== DATOS DEMO ====================

  /// Crea productos de ejemplo si la colección está vacía.
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

  /// Crea usuarios de ejemplo (admin y cajero) si la colección está vacía.
  Future<void> _inicializarUsuariosDemo(Isar isar) async {
    final count = await isar.usuarioEntitys.count();
    if (count == 0) {
      final adminDefault = UsuarioEntity()
        ..nombre = 'Administrador'
        ..pin = '1234'
        ..rol = 'admin'
        ..activo = true
        ..estado = 'inactivo'
        ..cajaAsignada = 'Caja Principal';

      final cajeroDefault = UsuarioEntity()
        ..nombre = 'Cajero 01'
        ..pin = '1111'
        ..rol = 'cajero'
        ..activo = true
        ..estado = 'inactivo'
        ..cajaAsignada = 'Caja 01';

      await isar.writeTxn(() async {
        await isar.usuarioEntitys.putAll([adminDefault, cajeroDefault]);
      });
    }
  }

  // ==================== USUARIOS ====================

  /// Obtiene un usuario por su ID de Supabase.
  Future<UsuarioEntity?> obtenerUsuarioPorSupabaseId(String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    return await isar.usuarioEntitys
        .filter()
        .supabaseIdEqualTo(supabaseId)
        .findFirst();
  }

  /// Obtiene un usuario por su ID interno de Isar.
  Future<UsuarioEntity?> obtenerUsuarioPorId(int id) async {
    final isar = await db;
    return await isar.usuarioEntitys.get(id);
  }

  /// Lista todos los usuarios.
  Future<List<UsuarioEntity>> obtenerUsuarios() async {
    final isar = await db;
    return await isar.usuarioEntitys.where().findAll();
  }

  /// Lista solo los usuarios activos.
  Future<List<UsuarioEntity>> obtenerUsuariosActivos() async {
    final isar = await db;
    return await isar.usuarioEntitys.filter().activoEqualTo(true).findAll();
  }

  /// Guarda (inserta o actualiza) un usuario.
  Future<UsuarioEntity> guardarUsuario(UsuarioEntity usuario) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.usuarioEntitys.put(usuario);
    });
    return usuario;
  }

  /// Obtiene un usuario por su dynamicId (campo adicional).
  Future<UsuarioEntity?> obtenerUsuarioPorDynamicId(String dynamicId) async {
    final isar = await db;
    return await isar.usuarioEntitys
        .where()
        .dynamicIdEqualTo(dynamicId)
        .findFirst();
  }

  /// Crea un nuevo usuario con validación de PIN.
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

  /// Elimina un usuario por ID.
  Future<bool> eliminarUsuario(int id) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      return await isar.usuarioEntitys.delete(id);
    });
  }

  /// Cambia el rol de un usuario.
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

  /// Actualiza el estado (activo/inactivo) de un usuario.
  Future<void> actualizarEstadoUsuario(
    int usuarioId,
    String nuevoEstado,
  ) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final usuario = await isar.usuarioEntitys.get(usuarioId);
      if (usuario != null) {
        usuario.estado = nuevoEstado;
        await isar.usuarioEntitys.put(usuario);
      }
    });
  }

  /// Cambia el PIN de un usuario.
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

  /// Valida las credenciales de login (nombre y PIN).
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

  // ==================== MARCAS ====================

  /// Guarda una marca (crea o actualiza).
  Future<void> guardarMarca(MarcaEntity marca) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.marcaEntitys.put(marca);
    });
  }

  /// Obtiene todas las marcas, opcionalmente solo las activas.
  Future<List<MarcaEntity>> obtenerMarcas({bool soloActivas = true}) async {
    final isar = await db;
    if (soloActivas) {
      return await isar.marcaEntitys.filter().activoEqualTo(true).findAll();
    } else {
      return await isar.marcaEntitys.where().findAll();
    }
  }

  /// Obtiene una marca por su ID de Isar.
  Future<MarcaEntity?> obtenerMarcaPorId(int id) async {
    final isar = await db;
    return await isar.marcaEntitys.get(id);
  }

  /// Obtiene una marca por su UUID de Supabase.
  Future<MarcaEntity?> obtenerMarcaPorSupabaseId(String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    return await isar.marcaEntitys
        .filter()
        .supabaseIdEqualTo(supabaseId)
        .findFirst();
  }

  /// Obtiene marcas pendientes de sincronización (syncStatus = 'pending' o 'failed').
  Future<List<MarcaEntity>> obtenerMarcasPendientesSync() async {
    final isar = await db;
    return await isar.marcaEntitys
        .filter()
        .syncStatusEqualTo('pending')
        .or()
        .syncStatusEqualTo('failed')
        .findAll();
  }

  /// Actualiza el estado de sincronización de una marca.
  Future<void> actualizarSyncStatusMarca(int id, String nuevoEstado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final marca = await isar.marcaEntitys.get(id);
      if (marca != null) {
        marca.syncStatus = nuevoEstado;
        await isar.marcaEntitys.put(marca);
      }
    });
  }

  /// Busca marcas por nombre (para autocomplete).
  Future<List<MarcaEntity>> buscarMarcas(String query) async {
    final isar = await db;
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    return await isar.marcaEntitys
        .filter()
        .nombreContains(q, caseSensitive: false)
        .findAll();
  }

  /// Elimina una marca físicamente solo si no tiene productos asociados.
  /// Si tiene productos, la desactiva en su lugar.
  Future<bool> eliminarMarca(int id) async {
    final isar = await db;

    final marca = await isar.marcaEntitys.get(id);
    if (marca == null) return false;

    final productos = await isar.productoEntitys
        .filter()
        .marcaSupabaseIdEqualTo(marca.supabaseId ?? '')
        .findAll();

    if (productos.isNotEmpty) {
      marca.activo = false;
      await isar.writeTxn(() async {
        await isar.marcaEntitys.put(marca);
      });
      debugPrint(
          '⚠️ Marca ${marca.nombre} desactivada (tiene productos asociados)');
      return false;
    }

    return await isar.writeTxn(() async {
      return await isar.marcaEntitys.delete(id);
    });
  }

  // ==================== CATEGORÍAS ====================

  /// Guarda una categoría (crea o actualiza).
  Future<void> guardarCategoria(CategoriaEntity categoria) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.categoriaEntitys.put(categoria);
    });
  }

  /// Obtiene todas las categorías, opcionalmente solo activas.
  Future<List<CategoriaEntity>> obtenerCategorias({
    bool soloActivas = true,
  }) async {
    final isar = await db;
    if (soloActivas) {
      return await isar.categoriaEntitys.filter().activoEqualTo(true).findAll();
    } else {
      return await isar.categoriaEntitys.where().findAll();
    }
  }

  /// Obtiene una categoría por su ID de Isar.
  Future<CategoriaEntity?> obtenerCategoriaPorId(int id) async {
    final isar = await db;
    return await isar.categoriaEntitys.get(id);
  }

  /// Obtiene una categoría por su UUID de Supabase.
  Future<CategoriaEntity?> obtenerCategoriaPorSupabaseId(
      String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    return await isar.categoriaEntitys
        .filter()
        .supabaseIdEqualTo(supabaseId)
        .findFirst();
  }

  /// Obtiene categorías pendientes de sincronización.
  Future<List<CategoriaEntity>> obtenerCategoriasPendientesSync() async {
    final isar = await db;
    return await isar.categoriaEntitys
        .filter()
        .syncStatusEqualTo('pending')
        .or()
        .syncStatusEqualTo('failed')
        .findAll();
  }

  // ==================== PRODUCTOS ====================

  /// Obtiene un producto por su ID de Supabase.
  Future<ProductoEntity?> obtenerProductoPorSupabaseId(
    String supabaseId,
  ) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    return await isar.productoEntitys
        .filter()
        .supabaseIdEqualTo(supabaseId)
        .findFirst();
  }

  /// Obtiene un producto por su ID de Isar.
  Future<ProductoEntity?> obtenerProductoPorId(int id) async {
    final isar = await db;
    return await isar.productoEntitys.get(id);
  }

  /// Lista todos los productos.
  Future<List<ProductoEntity>> obtenerProductos() async {
    final isar = await db;
    return await isar.productoEntitys.where().findAll();
  }

  /// Busca productos por código de barras o nombre (contiene).
  Future<List<ProductoEntity>> buscarProductoPorCodigoONombre(
    String query,
  ) async {
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

  /// Guarda un producto (crea o actualiza).
  Future<void> guardarProducto(ProductoEntity producto) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.productoEntitys.put(producto);
    });
  }

  /// Elimina un producto por ID.
  Future<void> eliminarProducto(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.productoEntitys.delete(id);
    });
  }

  /// Lista productos con stock por debajo del mínimo.
  Future<List<ProductoEntity>> obtenerProductosStockBajo() async {
    final isar = await db;
    final productos = await isar.productoEntitys.where().findAll();
    return productos.where((p) => p.stock <= p.stockMinimo).toList();
  }

  /// Actualiza el stock de un producto.
  Future<void> actualizarStockProducto(
    int idProducto,
    double nuevoStock,
  ) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final producto = await isar.productoEntitys.get(idProducto);
      if (producto != null) {
        producto.stock = nuevoStock < 0 ? 0.0 : nuevoStock;
        await isar.productoEntitys.put(producto);
      }
    });
  }

  /// Obtiene un producto por código de barras exacto.
  Future<ProductoEntity?> obtenerProductoPorCodigoBarrasExacto(
    String codigo,
  ) async {
    final isar = await db;
    return await isar.productoEntitys
        .filter()
        .codigoBarrasEqualTo(codigo)
        .findFirst();
  }

  /// Genera un código de barras único (no existente en la BD).
  Future<String> generarCodigoBarrasUnico() async {
    final isar = await db;
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

      final existente = await isar.productoEntitys
          .filter()
          .codigoBarrasEqualTo(codigo)
          .findFirst();

      if (existente == null) {
        debugPrint('✅ Código de barras generado: $codigo');
        return codigo;
      }

      await Future.delayed(const Duration(milliseconds: 1));
    } while (intentos < 10);

    codigo = 'B${DateTime.now().microsecondsSinceEpoch}';
    debugPrint('⚠️ Código de barras generado por fallback: $codigo');
    return codigo;
  }

  // ==================== VENTAS Y DETALLES ====================

  /// Guarda una venta completa, incluyendo sus detalles y actualiza el stock de los productos.
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

  /// Lista todas las ventas ordenadas por fecha descendente.
  Future<List<VentaEntity>> obtenerVentas() async {
    final isar = await db;
    return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
  }

  /// Obtiene ventas en un rango de fechas.
  Future<List<VentaEntity>> obtenerVentasPorRango(
    DateTime inicio,
    DateTime fin,
  ) async {
    final isar = await db;
    return await isar.ventaEntitys
        .filter()
        .fechaBetween(inicio, fin, includeLower: true, includeUpper: true)
        .sortByFechaDesc()
        .findAll();
  }

  /// Obtiene las últimas N ventas.
  Future<List<VentaEntity>> obtenerUltimasVentas(int cantidad) async {
    final isar = await db;
    return await isar.ventaEntitys
        .where()
        .sortByFechaDesc()
        .limit(cantidad)
        .findAll();
  }

  /// Obtiene los productos más vendidos (por cantidad) con un límite.
  Future<List<Map<String, dynamic>>> obtenerProductosMasVendidos(
    int limite,
  ) async {
    final isar = await db;
    final detalles = await isar.detalleVentaEntitys.where().findAll();
    final Map<String, double> acumulado = {};
    for (var d in detalles) {
      acumulado[d.nombreProducto] =
          (acumulado[d.nombreProducto] ?? 0) + d.cantidad;
    }
    final lista = acumulado.entries.map((e) {
      return {'nombre': e.key, 'cantidad': e.value};
    }).toList();
    lista.sort(
      (a, b) => (b['cantidad'] as double).compareTo(a['cantidad'] as double),
    );
    if (lista.length > limite) {
      return lista.sublist(0, limite);
    }
    return lista;
  }

  /// Agrupa ventas por empleado en un rango de fechas.
  Future<Map<String, double>> obtenerVentasPorEmpleado(
    DateTime inicio,
    DateTime fin,
  ) async {
    final isar = await db;
    final ventas = await isar.ventaEntitys
        .filter()
        .fechaBetween(inicio, fin, includeLower: true, includeUpper: true)
        .findAll();
    final Map<String, double> resultado = {};
    for (var v in ventas) {
      resultado[v.empleado] = (resultado[v.empleado] ?? 0) + v.total;
    }
    return resultado;
  }

  /// Obtiene el total de ventas en un rango de fechas.
  Future<double> obtenerTotalVentasPorRango(
    DateTime inicio,
    DateTime fin,
  ) async {
    final isar = await db;
    final ventas = await isar.ventaEntitys
        .filter()
        .fechaBetween(inicio, fin, includeLower: true, includeUpper: true)
        .findAll();
    double total = 0;
    for (var v in ventas) {
      total += v.total;
    }
    return total;
  }

  /// Obtiene ventas agrupadas por día para un número de días.
  Future<List<Map<String, dynamic>>> obtenerVentasPorDia(
    int cantidadDias,
  ) async {
    final isar = await db;
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day - cantidadDias + 1);
    final fin = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59, 999);
    final ventas = await isar.ventaEntitys
        .filter()
        .fechaBetween(inicio, fin, includeLower: true, includeUpper: true)
        .findAll();
    final Map<String, double> agrupado = {};
    for (var v in ventas) {
      final dia = DateTime(v.fecha.year, v.fecha.month, v.fecha.day);
      final key = dia.toIso8601String().substring(0, 10);
      agrupado[key] = (agrupado[key] ?? 0) + v.total;
    }
    final keys = agrupado.keys.toList()..sort();
    final List<Map<String, dynamic>> resultado = [];
    for (var key in keys) {
      resultado.add({'fecha': key, 'total': agrupado[key] ?? 0});
    }
    return resultado;
  }

  /// Obtiene los detalles de una venta específica.
  Future<List<DetalleVentaEntity>> obtenerDetallesPorVenta(int ventaId) async {
    final isar = await db;
    return await isar.detalleVentaEntitys
        .filter()
        .ventaIdEqualTo(ventaId)
        .findAll();
  }

  /// Obtiene una venta por su ID en formato string (campo ventaIdString).
  Future<VentaEntity?> obtenerVentaPorIdString(String ventaIdString) async {
    final isar = await db;
    return await isar.ventaEntitys
        .filter()
        .ventaIdStringEqualTo(ventaIdString)
        .findFirst();
  }

  /// Obtiene el total de ventas de un empleado en un rango.
  Future<double> obtenerTotalVentasPorEmpleadoYRango(
    String empleado,
    DateTime inicio,
    DateTime fin,
  ) async {
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

  // ==================== GASTOS ====================

  /// Guarda un gasto (crea o actualiza).
  Future<void> guardarGasto(GastoEntity gasto) async {
    final isar = await db;
    gasto.syncStatus = gasto.syncStatus.isEmpty ? 'pending' : gasto.syncStatus;
    await isar.writeTxn(() async {
      await isar.gastoEntitys.put(gasto);
    });
  }

  /// Lista todos los gastos ordenados por fecha descendente.
  Future<List<GastoEntity>> obtenerGastos() async {
    final isar = await db;
    return await isar.gastoEntitys.where().sortByFechaDesc().findAll();
  }

  /// Obtiene gastos pendientes de sincronización.
  Future<List<GastoEntity>> obtenerGastosPendientesSync() async {
    final isar = await db;
    return await isar.gastoEntitys
        .filter()
        .syncStatusEqualTo('pending')
        .or()
        .syncStatusEqualTo('failed')
        .findAll();
  }

  /// Actualiza el estado de sincronización de un gasto.
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

  /// Obtiene el total de gastos en un rango de fechas.
  Future<double> obtenerTotalGastosPorRango(
    DateTime inicio,
    DateTime fin,
  ) async {
    final isar = await db;
    final gastos = await isar.gastoEntitys
        .filter()
        .fechaBetween(inicio, fin, includeLower: true, includeUpper: true)
        .findAll();
    double total = 0;
    for (var g in gastos) {
      total += g.monto;
    }
    return total;
  }

  // ==================== LOGS ====================

  /// Guarda un log (registro de actividad).
  Future<void> guardarLog(LogEntity log) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.logEntitys.put(log);
    });
  }

  /// Lista todos los logs ordenados por fecha descendente.
  Future<List<LogEntity>> obtenerLogs() async {
    final isar = await db;
    return await isar.logEntitys.where().sortByFechaDesc().findAll();
  }

  /// Obtiene logs pendientes de sincronización.
  Future<List<LogEntity>> obtenerLogsPendientesSync() async {
    final isar = await db;
    return await isar.logEntitys.filter().sincronizadoEqualTo(false).findAll();
  }

  /// Marca múltiples logs como sincronizados.
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

  // ==================== MOVIMIENTOS DE INVENTARIO ====================

  /// Guarda un movimiento de inventario.
  Future<void> guardarMovimientoInventario(
    MovimientoInventarioEntity movimiento,
  ) async {
    final isar = await db;
    await isar.writeTxn(() async {
      movimiento.syncStatus =
          movimiento.syncStatus.isEmpty ? 'pending' : movimiento.syncStatus;
      await isar.movimientoInventarioEntitys.put(movimiento);
    });
  }

  /// Obtiene movimientos pendientes de sincronización.
  Future<List<MovimientoInventarioEntity>>
      obtenerMovimientosPendientesSync() async {
    final isar = await db;
    return await isar.movimientoInventarioEntitys
        .filter()
        .syncStatusEqualTo('pending')
        .or()
        .syncStatusEqualTo('failed')
        .findAll();
  }

  /// Actualiza el estado de sincronización de un movimiento.
  Future<void> actualizarSyncStatusMovimiento(
    int id,
    String nuevoEstado,
  ) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final mov = await isar.movimientoInventarioEntitys.get(id);
      if (mov != null) {
        mov.syncStatus = nuevoEstado;
        await isar.movimientoInventarioEntitys.put(mov);
      }
    });
  }

  // ==================== TURNOS ====================

  /// Guarda un turno.
  Future<void> guardarTurno(TurnoEntity turno) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.turnoEntitys.put(turno);
    });
  }

  /// Lista todos los turnos ordenados por fecha de apertura descendente.
  Future<List<TurnoEntity>> obtenerTurnos() async {
    final isar = await db;
    return await isar.turnoEntitys.where().sortByFechaAperturaDesc().findAll();
  }

  /// Obtiene el turno abierto de un usuario específico.
  Future<TurnoEntity?> obtenerTurnoAbiertoPorUsuario(int usuarioId) async {
    final isar = await db;
    return await isar.turnoEntitys
        .filter()
        .usuarioIdEqualTo(usuarioId)
        .and()
        .estadoEqualTo('abierto')
        .findFirst();
  }

  /// Cierra un turno (actualiza monto final y estado).
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

  /// Obtiene turnos pendientes de sincronización.
  Future<List<TurnoEntity>> obtenerTurnosPendientes() async {
    final isar = await db;
    return await isar.turnoEntitys
        .filter()
        .syncStatusEqualTo('pending')
        .findAll();
  }

  /// Marca un turno como sincronizado.
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

  // ==================== PEDIDOS (PROVEEDORES) ====================

  /// Guarda un pedido y retorna su ID.
  Future<int> guardarPedido(PedidoEntity pedido) async {
    final isar = await db;
    return isar.writeTxn<int>(() async {
      return await isar.pedidoEntitys.put(pedido);
    });
  }

  /// Obtiene pedidos por local destino.
  Future<List<PedidoEntity>> obtenerPedidosPorLocalDestino(
      int localDestinoId) async {
    final isar = await db;
    return await isar.pedidoEntitys
        .where()
        .localDestinoIdEqualTo(localDestinoId)
        .findAll();
  }

  /// Obtiene pedidos por estado, opcionalmente filtrados por local destino.
  Future<List<PedidoEntity>> obtenerPedidosPorEstado(
    EstadoPedido estado, {
    int? localDestinoId,
  }) async {
    final isar = await db;
    if (localDestinoId != null) {
      return await isar.pedidoEntitys
          .where()
          .localDestinoIdEqualTo(localDestinoId)
          .filter()
          .estadoEqualTo(estado)
          .findAll();
    } else {
      return await isar.pedidoEntitys
          .where()
          .filter()
          .estadoEqualTo(estado)
          .findAll();
    }
  }

  /// Obtiene un pedido por ID de Isar.
  Future<PedidoEntity?> obtenerPedidoPorId(int id) async {
    final isar = await db;
    return await isar.pedidoEntitys.get(id);
  }

  /// Obtiene un pedido por su UUID de Supabase.
  Future<PedidoEntity?> obtenerPedidoPorSupabaseId(String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    return await isar.pedidoEntitys
        .filter()
        .supabaseIdEqualTo(supabaseId)
        .findFirst();
  }

  /// Actualiza el estado de un pedido.
  Future<void> actualizarEstadoPedido(int id, EstadoPedido nuevoEstado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final pedido = await isar.pedidoEntitys.get(id);
      if (pedido != null) {
        pedido.estado = nuevoEstado;
        await isar.pedidoEntitys.put(pedido);
      }
    });
  }

  /// Actualiza el estado de sincronización de un pedido.
  Future<void> actualizarSyncStatusPedido(int id, bool sincronizado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final pedido = await isar.pedidoEntitys.get(id);
      if (pedido != null) {
        pedido.sincronizado = sincronizado;
        pedido.fechaSincronizacion = DateTime.now();
        await isar.pedidoEntitys.put(pedido);
      }
    });
  }

  /// Obtiene todos los pedidos pendientes de sincronización.
  Future<List<PedidoEntity>> obtenerPedidosPendientesSync() async {
    final isar = await db;
    return await isar.pedidoEntitys
        .where()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  

  // ==================== DETALLES DE PEDIDO ====================

  /// Guarda un detalle de pedido y retorna su ID.
  Future<int> guardarDetallePedido(DetallePedidoEntity detalle) async {
    final isar = await db;
    return isar.writeTxn<int>(() async {
      return await isar.detallePedidoEntitys.put(detalle);
    });
  }

  /// Obtiene todos los detalles de un pedido.
  Future<List<DetallePedidoEntity>> obtenerDetallesPorPedido(
    int pedidoId,
  ) async {
    final isar = await db;
    return await isar.detallePedidoEntitys
        .filter()
        .pedidoIdEqualTo(pedidoId)
        .findAll();
  }

  /// Elimina todos los detalles de un pedido.
  Future<void> eliminarDetallesPorPedido(int pedidoId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final detalles = await isar.detallePedidoEntitys
          .filter()
          .pedidoIdEqualTo(pedidoId)
          .findAll();
      for (var d in detalles) {
        await isar.detallePedidoEntitys.delete(d.id);
      }
    });
  }

  // ==================== RECEPCIONES ====================

  /// Guarda una recepción y retorna su ID.
  Future<int> guardarRecepcion(RecepcionEntity recepcion) async {
    final isar = await db;
    return isar.writeTxn<int>(() async {
      return await isar.recepcionEntitys.put(recepcion);
    });
  }

  /// Obtiene una recepción por ID de pedido.
  Future<RecepcionEntity?> obtenerRecepcionPorPedido(int pedidoId) async {
    final isar = await db;
    return await isar.recepcionEntitys
        .filter()
        .pedidoIdEqualTo(pedidoId)
        .findFirst();
  }

  /// Actualiza el estado de sincronización de una recepción.
  Future<void> actualizarSyncStatusRecepcion(int id, bool sincronizado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final recepcion = await isar.recepcionEntitys.get(id);
      if (recepcion != null) {
        recepcion.sincronizado = sincronizado;
        recepcion.fechaSincronizacion = DateTime.now();
        await isar.recepcionEntitys.put(recepcion);
      }
    });
  }

  // ==================== PROVEEDORES ====================

  /// Guarda un proveedor y retorna su ID.
  Future<int> guardarProveedor(ProveedorEntity proveedor) async {
    final isar = await db;
    return isar.writeTxn<int>(() async {
      return await isar.proveedorEntitys.put(proveedor);
    });
  }

  /// Lista proveedores, opcionalmente solo activos.
  Future<List<ProveedorEntity>> obtenerProveedores({
    bool soloActivos = true,
  }) async {
    final isar = await db;
    if (soloActivos) {
      return await isar.proveedorEntitys.filter().activoEqualTo(true).findAll();
    } else {
      return await isar.proveedorEntitys.where().findAll();
    }
  }

  /// Obtiene un proveedor por ID de Isar.
  Future<ProveedorEntity?> obtenerProveedorPorId(int id) async {
    final isar = await db;
    return await isar.proveedorEntitys.get(id);
  }

  /// Obtiene un proveedor por UUID de Supabase.
  Future<ProveedorEntity?> obtenerProveedorPorSupabaseId(
    String supabaseId,
  ) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    return await isar.proveedorEntitys
        .filter()
        .supabaseIdEqualTo(supabaseId)
        .findFirst();
  }

  /// Actualiza el estado de sincronización de un proveedor.
  Future<void> actualizarSyncStatusProveedor(int id, bool sincronizado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final proveedor = await isar.proveedorEntitys.get(id);
      if (proveedor != null) {
        proveedor.sincronizado = sincronizado;
        proveedor.fechaSincronizacion = DateTime.now();
        await isar.proveedorEntitys.put(proveedor);
      }
    });
  }

  /// Obtiene proveedores pendientes de sincronización.
  Future<List<ProveedorEntity>> obtenerProveedoresPendientesSync() async {
    final isar = await db;
    return await isar.proveedorEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  /// Desactiva un proveedor (no elimina).
  Future<void> desactivarProveedor(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final proveedor = await isar.proveedorEntitys.get(id);
      if (proveedor != null) {
        proveedor.activo = false;
        await isar.proveedorEntitys.put(proveedor);
      }
    });
  }

  /// Lista productos de un proveedor.
  Future<List<ProductoEntity>> obtenerProductosPorProveedor(
    int proveedorId,
  ) async {
    final isar = await db;
    return await isar.productoEntitys
        .filter()
        .proveedorIdEqualTo(proveedorId)
        .findAll();
  }

  /// Elimina un proveedor solo si no tiene productos asociados.
  Future<bool> eliminarProveedor(int id) async {
    final isar = await db;
    final productos = await isar.productoEntitys
        .filter()
        .proveedorIdEqualTo(id)
        .findAll();
    if (productos.isNotEmpty) {
      return false;
    }
    return await isar.writeTxn(() async {
      return await isar.proveedorEntitys.delete(id);
    });
  }

  /// Busca proveedores por nombre o empresa.
  Future<List<ProveedorEntity>> buscarProveedores(String query) async {
    final isar = await db;
    if (query.trim().isEmpty) return [];
    final q = query.trim().toLowerCase();
    return await isar.proveedorEntitys
        .filter()
        .nombreContains(q, caseSensitive: false)
        .or()
        .empresaContains(q, caseSensitive: false)
        .findAll();
  }

  // ==================== LOCALES ====================

  /// Obtiene un local por ID de Isar.
  Future<LocalEntity?> obtenerLocalPorId(int id) async {
    final isar = await db;
    return await isar.localEntitys.get(id);
  }

  /// Obtiene un local por UUID de Supabase.
  Future<LocalEntity?> obtenerLocalPorSupabaseId(String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    return await isar.localEntitys
        .filter()
        .supabaseIdEqualTo(supabaseId)
        .findFirst();
  }

  /// Guarda un local (crea o actualiza).
  Future<int> guardarLocal(LocalEntity local) async {
    final isar = await db;
    return isar.writeTxn<int>(() async {
      local.updatedAt = DateTime.now();
      local.createdAt ??= DateTime.now();
      return await isar.localEntitys.put(local);
    });
  }

  /// Lista locales, opcionalmente solo activos.
  Future<List<LocalEntity>> obtenerLocales({bool soloActivos = true}) async {
    final isar = await db;
    if (soloActivos) {
      return await isar.localEntitys.filter().activoEqualTo(true).findAll();
    }
    return await isar.localEntitys.where().findAll();
  }
  
  /// Obtiene el primer local activo (prioriza el que tenga activo = true)
Future<LocalEntity?> obtenerLocalActivo() async {
  final isar = await db;
  return await isar.localEntitys.filter().activoEqualTo(true).findFirst();
}

  /// Elimina un local solo si no tiene pedidos asociados.
  Future<bool> eliminarLocal(int id) async {
  final isar = await db;

  // Verificar dependencias (pedidos)
  final pedidos = await isar.pedidoEntitys
      .filter()
      .localOrigenIdEqualTo(id)
      .or()
      .localDestinoIdEqualTo(id)
      .findAll();
  if (pedidos.isNotEmpty) {
    debugPrint('⚠️ No se puede eliminar el local $id porque tiene pedidos asociados.');
    return false;
  }

  // 1. Actualizar usuarios que tenían este local
  final usuarios = await isar.usuarioEntitys.filter().localIdEqualTo(id).findAll();
  if (usuarios.isNotEmpty) {
    for (var u in usuarios) {
      u.localId = null;
    }
    await isar.writeTxn(() async {
      await isar.usuarioEntitys.putAll(usuarios);
    });
    debugPrint('✅ ${usuarios.length} usuarios actualizados (localId → null)');
  }

  // 2. Actualizar departamentos que tenían este local
  final departamentos = await isar.departamentoEntitys.filter().localIdEqualTo(id).findAll();
  if (departamentos.isNotEmpty) {
    for (var d in departamentos) {
      d.localId = null;
    }
    await isar.writeTxn(() async {
      await isar.departamentoEntitys.putAll(departamentos);
    });
    debugPrint('✅ ${departamentos.length} departamentos actualizados (localId → null)');
  }

  // 3. Eliminar local
  final eliminado = await isar.writeTxn(() async {
    return await isar.localEntitys.delete(id);
  });

  if (eliminado) {
    debugPrint('✅ Local $id eliminado correctamente');
  }

  return eliminado;
}

  /// Actualiza el estado de sincronización de un local.
  Future<void> actualizarSyncStatusLocal(int id, bool sincronizado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final local = await isar.localEntitys.get(id);
      if (local != null) {
        local.sincronizado = sincronizado;
        local.fechaSincronizacion = DateTime.now();
        await isar.localEntitys.put(local);
      }
    });
  }

  /// Obtiene locales pendientes de sincronización.
  Future<List<LocalEntity>> obtenerLocalesPendientesSync() async {
    final isar = await db;
    return await isar.localEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  // ==================== DEPARTAMENTOS ====================

  /// Guarda un departamento (crea o actualiza).
  Future<int> guardarDepartamento(DepartamentoEntity departamento) async {
    final isar = await db;
    return isar.writeTxn<int>(() async {
      departamento.updatedAt = DateTime.now();
      departamento.createdAt ??= DateTime.now();
      return await isar.departamentoEntitys.put(departamento);
    });
  }

  /// Lista departamentos, opcionalmente por local y solo activos.
  Future<List<DepartamentoEntity>> obtenerDepartamentos({
    bool soloActivos = true,
    int? localId,
  }) async {
    final isar = await db;
    List<DepartamentoEntity> departamentos;
    if (localId != null) {
      departamentos = await isar.departamentoEntitys
          .filter()
          .localIdEqualTo(localId)
          .findAll();
    } else {
      departamentos = await isar.departamentoEntitys.where().findAll();
    }
    if (soloActivos) {
      departamentos = departamentos.where((d) => d.activo).toList();
    }
    return departamentos;
  }

  /// Obtiene un departamento por ID de Isar.
  Future<DepartamentoEntity?> obtenerDepartamentoPorId(int id) async {
    final isar = await db;
    return await isar.departamentoEntitys.get(id);
  }

  /// Elimina un departamento por ID (sin verificar dependencias).
  Future<bool> eliminarDepartamento(int id) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      return await isar.departamentoEntitys.delete(id);
    });
  }

  /// Actualiza el estado de sincronización de un departamento.
  Future<void> actualizarSyncStatusDepartamento(int id, bool sincronizado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final departamento = await isar.departamentoEntitys.get(id);
      if (departamento != null) {
        departamento.sincronizado = sincronizado;
        departamento.fechaSincronizacion = DateTime.now();
        await isar.departamentoEntitys.put(departamento);
      }
    });
  }

  /// Obtiene departamentos pendientes de sincronización.
  Future<List<DepartamentoEntity>> obtenerDepartamentosPendientesSync() async {
    final isar = await db;
    return await isar.departamentoEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  // ==================== CÓDIGOS DE BARRAS ALIAS ====================

  /// Guarda un alias de código de barras.
  Future<void> guardarCodigoAlias(CodigoBarrasAliasEntity alias) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.codigoBarrasAliasEntitys.put(alias);
    });
  }

  /// Obtiene un alias por su código (activo).
  Future<CodigoBarrasAliasEntity?> obtenerAliasPorCodigo(String codigo) async {
    final isar = await db;
    return await isar.codigoBarrasAliasEntitys
        .filter()
        .codigoEqualTo(codigo.trim())
        .activoEqualTo(true)
        .findFirst();
  }

  /// Lista los alias de un producto.
  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPorProducto(
    int productoId,
  ) async {
    final isar = await db;
    return await isar.codigoBarrasAliasEntitys
        .filter()
        .productoIdEqualTo(productoId)
        .activoEqualTo(true)
        .findAll();
  }

  /// Desactiva un alias (no elimina).
  Future<void> desactivarAlias(int aliasId) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final alias = await isar.codigoBarrasAliasEntitys.get(aliasId);
      if (alias != null) {
        alias.activo = false;
        alias.sincronizado = false;
        await isar.codigoBarrasAliasEntitys.put(alias);
      }
    });
  }

  /// Obtiene alias pendientes de sincronización.
  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPendientesSync() async {
    final isar = await db;
    return await isar.codigoBarrasAliasEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  // ==================== LOTES ====================

  /// Guarda un lote.
  Future<void> guardarLote(LoteEntity lote) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.loteEntitys.put(lote);
    });
  }

  /// Calcula el stock total de un producto sumando sus lotes activos.
  Future<double> obtenerStockTotalPorProducto(int productoId) async {
    final isar = await db;
    final lotes = await isar.loteEntitys
        .filter()
        .productoIdEqualTo(productoId)
        .estadoEqualTo('activo')
        .findAll();
    return lotes.fold<double>(0.0, (sum, lote) => sum + lote.cantidadRestante);
  }

  /// Obtiene los lotes activos de un producto, con opción de priorizar vencimiento.
  Future<List<LoteEntity>> obtenerLotesActivos(
    int productoId, {
    bool priorizarVencimiento = true,
  }) async {
    final isar = await db;
    final lotes = await isar.loteEntitys
        .filter()
        .productoIdEqualTo(productoId)
        .estadoEqualTo('activo')
        .and()
        .cantidadRestanteGreaterThan(0)
        .findAll();

    if (priorizarVencimiento) {
      lotes.sort((a, b) {
        if (a.fechaVencimiento != null && b.fechaVencimiento != null) {
          return a.fechaVencimiento!.compareTo(b.fechaVencimiento!);
        }
        if (a.fechaVencimiento != null) return -1;
        if (b.fechaVencimiento != null) return 1;
        return a.fechaIngreso.compareTo(b.fechaIngreso);
      });
    } else {
      lotes.sort((a, b) => a.fechaIngreso.compareTo(b.fechaIngreso));
    }
    return lotes;
  }

  /// Descuenta una cantidad de un lote específico.
  Future<bool> descontarLote(int loteId, double cantidad) async {
    final isar = await db;
    return await isar.writeTxn(() async {
      final lote = await isar.loteEntitys.get(loteId);
      if (lote == null) return false;
      if (lote.cantidadRestante < cantidad) return false;

      lote.cantidadRestante -= cantidad;
      if (lote.cantidadRestante <= 0) {
        lote.cantidadRestante = 0;
        lote.estado = 'agotado';
      }
      lote.sincronizado = false;
      await isar.loteEntitys.put(lote);
      return true;
    });
  }

  /// Obtiene un lote adecuado para una venta (prioriza vencimiento).
  Future<LoteEntity?> obtenerLoteParaVenta(
    int productoId, {
    bool priorizarVencimiento = true,
  }) async {
    final lotes = await obtenerLotesActivos(
      productoId,
      priorizarVencimiento: priorizarVencimiento,
    );
    return lotes.isNotEmpty ? lotes.first : null;
  }

  /// Lista todos los lotes.
  Future<List<LoteEntity>> obtenerTodosLosLotes() async {
    final isar = await db;
    return await isar.loteEntitys.where().findAll();
  }

  /// Lista todos los productos (alias de obtenerProductos).
  Future<List<ProductoEntity>> obtenerTodosLosProductos() async {
    return await obtenerProductos();
  }

  /// Cuenta el número de lotes.
  Future<int> contarLotes() async {
    final isar = await db;
    return await isar.loteEntitys.where().count();
  }

  /// Cuenta el número de productos.
  Future<int> contarProductos() async {
    final isar = await db;
    return await isar.productoEntitys.where().count();
  }

  /// Migra el stock existente de productos a lotes (uno por producto).
  Future<Map<String, dynamic>> migrarStockExistenteALotes() async {
    try {
      final isar = await db;
      final productos = await isar.productoEntitys.where().findAll();
      final todosLosLotes = await isar.loteEntitys.where().findAll();

      int lotesCreados = 0;
      int productosSinStock = 0;
      int productosConLotesPrevios = 0;

      for (var p in productos) {
        final lotesExistentes = todosLosLotes
            .where((lote) => lote.productoId == p.id)
            .toList();

        if (lotesExistentes.isNotEmpty) {
          productosConLotesPrevios++;
          continue;
        }

        if (p.stock <= 0) {
          productosSinStock++;
          continue;
        }

        final lote = LoteEntity()
          ..productoId = p.id
          ..cantidadInicial = p.stock
          ..cantidadRestante = p.stock
          ..fechaIngreso = DateTime.now()
          ..estado = 'activo'
          ..sincronizado = false;

        await isar.writeTxn(() async {
          await isar.loteEntitys.put(lote);
        });

        lotesCreados++;
      }

      return {
        'success': true,
        'lotesCreados': lotesCreados,
        'productosSinStock': productosSinStock,
        'productosConLotesPrevios': productosConLotesPrevios,
        'totalProductos': productos.length,
        'error': null,
      };
    } catch (e) {
      return {
        'success': false,
        'lotesCreados': 0,
        'productosSinStock': 0,
        'productosConLotesPrevios': 0,
        'totalProductos': 0,
        'error': e.toString(),
      };
    }
  }

  /// Asigna supabaseId a productos que no lo tienen, consultando Supabase.
  Future<int> asignarSupabaseIdsAFaltantes() async {
    final isar = await db;
    final supabase = Supabase.instance.client;

    final productosSinId = await isar.productoEntitys
        .filter()
        .supabaseIdIsNull()
        .findAll();

    if (productosSinId.isEmpty) {
      debugPrint('✅ Todos los productos ya tienen supabaseId.');
      return 0;
    }

    debugPrint('🔄 Asignando supabaseId a ${productosSinId.length} productos...');

    final idsIsar = productosSinId.map((p) => p.id).toList();
    final response = await supabase
        .from('productos')
        .select('id, id_isar')
        .inFilter('id_isar', idsIsar);

    final Map<int, String> mapa = {};
    for (var row in response) {
      final idIsarStr = row['id_isar']?.toString() ?? '';
      final idIsar = int.tryParse(idIsarStr);
      final supabaseId = row['id']?.toString();

      if (idIsar != null && supabaseId != null && supabaseId.isNotEmpty) {
        mapa[idIsar] = supabaseId;
      }
    }

    int actualizados = 0;
    for (var p in productosSinId) {
      final uuid = mapa[p.id];
      if (uuid != null) {
        p.supabaseId = uuid;
        p.sincronizado = true;
        p.fechaSincronizacion = DateTime.now();
        await isar.writeTxn(() async {
          await isar.productoEntitys.put(p);
        });
        actualizados++;
        debugPrint('✅ Producto ${p.nombre} (ID: ${p.id}) → supabaseId: $uuid');
      } else {
        debugPrint(
            '⚠️ Producto ${p.nombre} (ID: ${p.id}) no encontrado en Supabase.');
      }
    }

    debugPrint('✅ $actualizados productos actualizados con supabaseId.');
    return actualizados;
  }

  // ==================== TELEGRAM CONFIG ====================

  /// Guarda una configuración de Telegram (crea o actualiza).
  Future<int> guardarTelegramConfig(TelegramConfigEntity config) async {
    final isar = await db;
    return isar.writeTxn<int>(() async {
      config.updatedAt = DateTime.now();
      config.createdAt ??= DateTime.now();
      return await isar.telegramConfigEntitys.put(config);
    });
  }

  /// Obtiene la primera configuración de Telegram (si existe).
  Future<TelegramConfigEntity?> obtenerTelegramConfig() async {
    final isar = await db;
    return await isar.telegramConfigEntitys.where().findFirst();
  }

  /// Lista todas las configuraciones de Telegram.
  Future<List<TelegramConfigEntity>> obtenerTelegramConfigs() async {
    final isar = await db;
    return await isar.telegramConfigEntitys.where().findAll();
  }

  /// Actualiza el estado de sincronización de una configuración.
  Future<void> actualizarSyncStatusTelegramConfig(
      int id, bool sincronizado) async {
    final isar = await db;
    await isar.writeTxn(() async {
      final config = await isar.telegramConfigEntitys.get(id);
      if (config != null) {
        config.sincronizado = sincronizado;
        config.fechaSincronizacion = DateTime.now();
        await isar.telegramConfigEntitys.put(config);
      }
    });
  }

  /// Obtiene configuraciones de Telegram pendientes de sincronización.
  Future<List<TelegramConfigEntity>> obtenerTelegramConfigsPendientesSync()
      async {
    final isar = await db;
    return await isar.telegramConfigEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  /// Elimina una configuración de Telegram por ID.
  Future<void> eliminarTelegramConfig(int id) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.telegramConfigEntitys.delete(id);
    });
  }

  // ==================== Sincronización general ====================

  /// Obtiene ventas pendientes de sincronización (syncStatus 'pending' o 'failed').
  Future<List<VentaEntity>> obtenerVentasPendientesSync() async {
    final isar = await db;
    return await isar.ventaEntitys
        .filter()
        .syncStatusEqualTo('pending')
        .or()
        .syncStatusEqualTo('failed')
        .findAll();
  }

  /// Actualiza el estado de sincronización de una venta.
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

  /// Obtiene productos pendientes de sincronización.
  Future<List<ProductoEntity>> obtenerProductosPendientesSync() async {
    final isar = await db;
    return await isar.productoEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  /// Obtiene lotes pendientes de sincronización.
  Future<List<LoteEntity>> obtenerLotesPendientesSync() async {
    final isar = await db;
    return await isar.loteEntitys
        .filter()
        .sincronizadoEqualTo(false)
        .findAll();
  }

  /// Guarda los detalles de una venta (reemplaza los existentes).
  Future<void> guardarDetallesVenta(
    int ventaId,
    List<DetalleVentaEntity> detalles,
  ) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.detalleVentaEntitys
          .filter()
          .ventaIdEqualTo(ventaId)
          .deleteAll();
      for (var item in detalles) {
        item.ventaId = ventaId;
        await isar.detalleVentaEntitys.put(item);
      }
    });
  }

  /// Resetea supabaseId incorrectos (aquellos que no son números) de productos.
  Future<void> resetearSupabaseIdsIncorrectos() async {
    final isar = await db;
    final productos = await isar.productoEntitys.where().findAll();
    for (var p in productos) {
      if (p.supabaseId != null && int.tryParse(p.supabaseId!) == null) {
        p.supabaseId = null;
        p.sincronizado = false;
      }
    }
    await isar.writeTxn(() async {
      await isar.productoEntitys.putAll(productos);
    });
  }

  /// Inicializa el usuario administrador por defecto (si no existe).
  Future<void> inicializarUsuarioAdminPorDefecto() async {
    final isar = await db;
    await _inicializarUsuariosDemo(isar);
  }

  // ==================== DASHBOARD / ESTADÍSTICAS ====================

  /// Obtiene un resumen completo para el dashboard.
  Future<Map<String, dynamic>> obtenerResumenDashboard() async {
    final isar = await db;
    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final inicioSemana = inicioHoy.subtract(Duration(days: hoy.weekday - 1));
    final inicioMes = DateTime(hoy.year, hoy.month, 1);
    final finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59, 999);

    final totalHoy = await obtenerTotalVentasPorRango(inicioHoy, finDia);
    final totalSemana = await obtenerTotalVentasPorRango(inicioSemana, finDia);
    final totalMes = await obtenerTotalVentasPorRango(inicioMes, finDia);
    final totalGastosMes = await obtenerTotalGastosPorRango(inicioMes, finDia);
    final totalVentasAyer = await obtenerTotalVentasPorRango(
      inicioHoy.subtract(const Duration(days: 1)),
      inicioHoy.subtract(const Duration(seconds: 1)),
    );
    final variacion = totalHoy > 0 && totalVentasAyer > 0
        ? ((totalHoy - totalVentasAyer) / totalVentasAyer) * 100
        : 0.0;

    final ultimasVentas = await obtenerUltimasVentas(5);
    final topProductos = await obtenerProductosMasVendidos(5);
    final stockBajo = await obtenerProductosStockBajo();
    final ventasPorEmpleado = await obtenerVentasPorEmpleado(
      inicioSemana,
      finDia,
    );
    final ventasPorDia = await obtenerVentasPorDia(7);

    final ventasHoy = await isar.ventaEntitys
        .filter()
        .fechaBetween(inicioHoy, finDia, includeLower: true, includeUpper: true)
        .count();

    return {
      'totalHoy': totalHoy,
      'totalSemana': totalSemana,
      'totalMes': totalMes,
      'totalGastosMes': totalGastosMes,
      'variacion': variacion,
      'ventasHoy': ventasHoy,
      'ultimasVentas': ultimasVentas,
      'topProductos': topProductos,
      'stockBajo': stockBajo,
      'ventasPorEmpleado': ventasPorEmpleado,
      'ventasPorDia': ventasPorDia,
    };
  }

  /// Obtiene ventas filtradas por período ('dia', 'semana', 'mes', 'todos').
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
      inicioLocal = DateTime(
        now.year,
        now.month,
        now.day - (now.weekday - 1),
        0,
        0,
        0,
      );
      finLocal = inicioLocal.add(
        const Duration(
          days: 6,
          hours: 23,
          minutes: 59,
          seconds: 59,
          milliseconds: 999,
        ),
      );
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
}