import 'dart:io';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Entidades
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
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
import '../../../presentation/services/error_service.dart'; // ✅ NUEVO

// ============================================================
// CLASE AUXILIAR PARA HISTORIAL DE CÓDIGOS
// ============================================================
class HistorialCodigoItem {
  final String codigo;
  final String? proveedorNombre;
  final DateTime fechaIngreso;
  final DateTime? fechaVencimiento;
  final double cantidad;
  final double precio;
  final String tipo; // 'alias' o 'lote'

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
    try {
      _isarInstance = await _initIsar();
      return _isarInstance!;
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'isar_db_init_fallo');
      rethrow;
    }
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
          MovimientoLoteEntitySchema,
          ClienteEntitySchema,
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
          MovimientoLoteEntitySchema,
          ClienteEntitySchema,
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
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'inicializarProductosDemo_fallo');
    }
  }

  /// Crea usuarios de ejemplo (admin y cajero) si la colección está vacía.
  Future<void> _inicializarUsuariosDemo(Isar isar) async {
    try {
      final count = await isar.usuarioEntitys.count();
      if (count == 0) {
        final adminDefault = UsuarioEntity()
          ..nombre = 'Administrador'
          ..email = 'admin@default.com'
          ..password = '123456'
          ..pin = '1234'
          ..rol = 'admin'
          ..activo = true
          ..estado = 'inactivo'
          ..cajaAsignada = 'Caja Principal';

        await isar.writeTxn(() async {
          await isar.usuarioEntitys.put(adminDefault);
        });
      }
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'inicializarUsuariosDemo_fallo');
    }
  }

  // ==================== USUARIOS ====================

  Future<UsuarioEntity?> obtenerUsuarioPorSupabaseId(String supabaseId) async {
    try {
      final isar = await db;
      if (supabaseId.isEmpty) return null;
      return await isar.usuarioEntitys
          .filter()
          .supabaseIdEqualTo(supabaseId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerUsuarioPorSupabaseId_fallo',
          extras: {'supabaseId': supabaseId});
      return null;
    }
  }

  Future<UsuarioEntity?> obtenerUsuarioPorId(int id) async {
    try {
      final isar = await db;
      return await isar.usuarioEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerUsuarioPorId_fallo', extras: {'id': id});
      return null;
    }
  }

  Future<List<UsuarioEntity>> obtenerUsuarios() async {
    try {
      final isar = await db;
      return await isar.usuarioEntitys.where().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'obtenerUsuarios_fallo');
      return [];
    }
  }

  Future<List<UsuarioEntity>> obtenerUsuariosActivos() async {
    try {
      final isar = await db;
      return await isar.usuarioEntitys.filter().activoEqualTo(true).findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerUsuariosActivos_fallo');
      return [];
    }
  }

  Future<UsuarioEntity> guardarUsuario(UsuarioEntity usuario) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.usuarioEntitys.put(usuario);
      });
      return usuario;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarUsuario_fallo',
          extras: {'usuarioId': usuario.id, 'nombre': usuario.nombre});
      rethrow;
    }
  }

  Future<UsuarioEntity?> obtenerUsuarioPorDynamicId(String dynamicId) async {
    try {
      final isar = await db;
      return await isar.usuarioEntitys
          .where()
          .dynamicIdEqualTo(dynamicId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerUsuarioPorDynamicId_fallo',
          extras: {'dynamicId': dynamicId});
      return null;
    }
  }

  Future<void> crearUsuario({
    required String nombre,
    required String pin,
    required String rol,
    required String caja,
  }) async {
    try {
      final isar = await db;
      if (pin.trim().length != 4)
        throw Exception('El PIN debe tener 4 dígitos.');
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'crearUsuario_fallo',
          extras: {'nombre': nombre, 'rol': rol});
      rethrow;
    }
  }

  Future<bool> eliminarUsuario(int id) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        return await isar.usuarioEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarUsuario_fallo', extras: {'id': id});
      return false;
    }
  }

  Future<bool> cambiarRolUsuario(int usuarioId, String nuevoRol) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'cambiarRolUsuario_fallo',
          extras: {'usuarioId': usuarioId, 'nuevoRol': nuevoRol});
      return false;
    }
  }

  Future<void> actualizarEstadoUsuario(
      int usuarioId, String nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final usuario = await isar.usuarioEntitys.get(usuarioId);
        if (usuario != null) {
          usuario.estado = nuevoEstado;
          await isar.usuarioEntitys.put(usuario);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarEstadoUsuario_fallo',
          extras: {'usuarioId': usuarioId, 'nuevoEstado': nuevoEstado});
      rethrow;
    }
  }

  Future<bool> cambiarClaveUsuario(int usuarioId, String nuevaClave) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'cambiarClaveUsuario_fallo',
          extras: {'usuarioId': usuarioId});
      return false;
    }
  }

  Future<UsuarioEntity?> validarLogin(String nombre, String pin) async {
    try {
      final isar = await db;
      final nombreNormalizado = nombre.trim();
      final pinNormalizado = pin.trim();

      if (nombreNormalizado.isEmpty || pinNormalizado.isEmpty) {
        return null;
      }

      return await isar.usuarioEntitys
          .filter()
          .nombreEqualTo(nombreNormalizado, caseSensitive: false)
          .pinEqualTo(pinNormalizado)
          .and()
          .activoEqualTo(true)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'validarLogin_fallo', extras: {'nombre': nombre});
      return null;
    }
  }

  // ==================== MARCAS ====================

  Future<void> guardarMarca(MarcaEntity marca) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.marcaEntitys.put(marca);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarMarca_fallo',
          extras: {'marcaId': marca.id, 'nombre': marca.nombre});
      rethrow;
    }
  }

  Future<List<MarcaEntity>> obtenerMarcas({bool soloActivas = true}) async {
    try {
      final isar = await db;
      if (soloActivas) {
        return await isar.marcaEntitys.filter().activoEqualTo(true).findAll();
      } else {
        return await isar.marcaEntitys.where().findAll();
      }
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'obtenerMarcas_fallo');
      return [];
    }
  }

  Future<MarcaEntity?> obtenerMarcaPorId(int id) async {
    try {
      final isar = await db;
      return await isar.marcaEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerMarcaPorId_fallo', extras: {'id': id});
      return null;
    }
  }

  Future<MarcaEntity?> obtenerMarcaPorSupabaseId(String supabaseId) async {
    try {
      final isar = await db;
      if (supabaseId.isEmpty) return null;
      return await isar.marcaEntitys
          .filter()
          .supabaseIdEqualTo(supabaseId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerMarcaPorSupabaseId_fallo',
          extras: {'supabaseId': supabaseId});
      return null;
    }
  }

  Future<List<MarcaEntity>> obtenerMarcasPendientesSync() async {
    try {
      final isar = await db;
      return await isar.marcaEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .or()
          .syncStatusEqualTo('failed')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerMarcasPendientesSync_fallo');
      return [];
    }
  }

  Future<void> actualizarSyncStatusMarca(int id, String nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final marca = await isar.marcaEntitys.get(id);
        if (marca != null) {
          marca.syncStatus = nuevoEstado;
          await isar.marcaEntitys.put(marca);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusMarca_fallo',
          extras: {'id': id, 'nuevoEstado': nuevoEstado});
      rethrow;
    }
  }

  Future<List<MarcaEntity>> buscarMarcas(String query) async {
    try {
      final isar = await db;
      if (query.trim().isEmpty) return [];
      final q = query.trim().toLowerCase();
      return await isar.marcaEntitys
          .filter()
          .nombreContains(q, caseSensitive: false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'buscarMarcas_fallo', extras: {'query': query});
      return [];
    }
  }

  Future<bool> eliminarMarca(int id) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarMarca_fallo', extras: {'id': id});
      return false;
    }
  }

  // ==================== CATEGORÍAS ====================

  Future<void> guardarCategoria(CategoriaEntity categoria) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.categoriaEntitys.put(categoria);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarCategoria_fallo',
          extras: {'categoriaId': categoria.id, 'nombre': categoria.nombre});
      rethrow;
    }
  }

  Future<List<CategoriaEntity>> obtenerCategorias(
      {bool soloActivas = true}) async {
    try {
      final isar = await db;
      if (soloActivas) {
        return await isar.categoriaEntitys
            .filter()
            .activoEqualTo(true)
            .findAll();
      } else {
        return await isar.categoriaEntitys.where().findAll();
      }
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerCategorias_fallo');
      return [];
    }
  }

  Future<CategoriaEntity?> obtenerCategoriaPorId(int id) async {
    try {
      final isar = await db;
      return await isar.categoriaEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerCategoriaPorId_fallo',
          extras: {'id': id});
      return null;
    }
  }

  Future<CategoriaEntity?> obtenerCategoriaPorSupabaseId(
      String supabaseId) async {
    try {
      final isar = await db;
      if (supabaseId.isEmpty) return null;
      return await isar.categoriaEntitys
          .filter()
          .supabaseIdEqualTo(supabaseId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerCategoriaPorSupabaseId_fallo',
          extras: {'supabaseId': supabaseId});
      return null;
    }
  }

  Future<List<CategoriaEntity>> obtenerCategoriasPendientesSync() async {
    try {
      final isar = await db;
      return await isar.categoriaEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .or()
          .syncStatusEqualTo('failed')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerCategoriasPendientesSync_fallo');
      return [];
    }
  }

  // ==================== PRODUCTOS ====================

  Future<ProductoEntity?> obtenerProductoPorSupabaseId(
      String supabaseId) async {
    try {
      final isar = await db;
      if (supabaseId.isEmpty) return null;
      return await isar.productoEntitys
          .filter()
          .supabaseIdEqualTo(supabaseId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerProductoPorSupabaseId_fallo',
          extras: {'supabaseId': supabaseId});
      return null;
    }
  }

  Future<ProductoEntity?> obtenerProductoPorId(int id) async {
    try {
      final isar = await db;
      return await isar.productoEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerProductoPorId_fallo', extras: {'id': id});
      return null;
    }
  }

  Future<List<ProductoEntity>> obtenerProductos() async {
    try {
      final isar = await db;
      return await isar.productoEntitys.where().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerProductos_fallo');
      return [];
    }
  }

  Future<List<ProductoEntity>> buscarProductoPorCodigoONombre(
      String query) async {
    try {
      if (query.trim().isEmpty) return [];
      final isar = await db;
      final q = query.trim().toLowerCase();
      return await isar.productoEntitys
          .filter()
          .codigoBarrasContains(q, caseSensitive: false)
          .or()
          .nombreContains(q, caseSensitive: false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'buscarProductoPorCodigoONombre_fallo',
          extras: {'query': query});
      return [];
    }
  }

  Future<void> guardarProducto(ProductoEntity producto) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.put(producto);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarProducto_fallo',
          extras: {'productoId': producto.id, 'nombre': producto.nombre});
      rethrow;
    }
  }

  Future<void> eliminarProducto(int id) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.productoEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarProducto_fallo', extras: {'id': id});
      rethrow;
    }
  }

  Future<List<ProductoEntity>> obtenerProductosStockBajo() async {
    try {
      final isar = await db;
      final productos = await isar.productoEntitys.where().findAll();
      return productos.where((p) => p.stock <= p.stockMinimo).toList();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerProductosStockBajo_fallo');
      return [];
    }
  }

  Future<void> actualizarStockProducto(
      int idProducto, double nuevoStock) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final producto = await isar.productoEntitys.get(idProducto);
        if (producto != null) {
          producto.stock = nuevoStock < 0 ? 0.0 : nuevoStock;
          await isar.productoEntitys.put(producto);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarStockProducto_fallo',
          extras: {'idProducto': idProducto, 'nuevoStock': nuevoStock});
      rethrow;
    }
  }

  Future<ProductoEntity?> obtenerProductoPorCodigoBarrasExacto(
      String codigo) async {
    try {
      final isar = await db;
      return await isar.productoEntitys
          .filter()
          .codigoBarrasEqualTo(codigo)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerProductoPorCodigoBarrasExacto_fallo',
          extras: {'codigo': codigo});
      return null;
    }
  }

  Future<String> generarCodigoBarrasUnico() async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'generarCodigoBarrasUnico_fallo');
      rethrow;
    }
  }

  // ==================== VENTAS Y DETALLES ====================

  Future<void> guardarVenta(
    VentaEntity venta, {
    List<DetalleVentaEntity>? detalles,
  }) async {
    try {
      final isar = await db;
      final detallesList = detalles ?? venta.items.toList();

      await isar.writeTxn(() async {
        venta.syncStatus = venta.syncStatus =
            (venta.syncStatus?.isEmpty ?? true) ? 'pending' : venta.syncStatus;
        await isar.ventaEntitys.put(venta);

        for (var item in detallesList) {
          item.ventaIdFk ??= venta.idSupabase;
        }

        if (detallesList.isNotEmpty) {
          await isar.detalleVentaEntitys.putAll(detallesList);
        }
      });

      debugPrint('✅ Venta guardada con éxito. ID: ${venta.id}');
    } catch (e, stackTrace) {
      ErrorService.captureError(
        e,
        stack: stackTrace,
        hint: 'guardarVenta_fallo',
        extras: {
          'ventaId': venta.id,
          'total': venta.total,
          'detallesCount': detalles?.length ?? 0,
          'usuario': venta.empleado,
        },
      );
      debugPrint('❌ Error crítico al guardar la venta: $e');
      rethrow;
    }
  }

  Future<List<VentaEntity>> obtenerVentas() async {
    try {
      final isar = await db;
      return await isar.ventaEntitys.where().sortByFechaDesc().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'obtenerVentas_fallo');
      return [];
    }
  }

  Future<List<VentaEntity>> obtenerVentasPorRango(
      DateTime inicio, DateTime fin) async {
    try {
      final isar = await db;
      return await isar.ventaEntitys
          .filter()
          .fechaBetween(inicio, fin, includeLower: true, includeUpper: true)
          .sortByFechaDesc()
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerVentasPorRango_fallo');
      return [];
    }
  }

  Future<List<VentaEntity>> obtenerUltimasVentas(int cantidad) async {
    try {
      final isar = await db;
      return await isar.ventaEntitys
          .where()
          .sortByFechaDesc()
          .limit(cantidad)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerUltimasVentas_fallo',
          extras: {'cantidad': cantidad});
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> obtenerProductosMasVendidos(
      int limite) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerProductosMasVendidos_fallo',
          extras: {'limite': limite});
      return [];
    }
  }

  Future<Map<String, double>> obtenerVentasPorEmpleado(
      DateTime inicio, DateTime fin) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerVentasPorEmpleado_fallo');
      return {};
    }
  }

  Future<double> obtenerTotalVentasPorRango(
      DateTime inicio, DateTime fin) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerTotalVentasPorRango_fallo');
      return 0.0;
    }
  }

  Future<List<Map<String, dynamic>>> obtenerVentasPorDia(
      int cantidadDias) async {
    try {
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
        final fecha = v.fecha;
        if (fecha == null) continue;
        final dia = DateTime(fecha.year, fecha.month, fecha.day);
        final key = dia.toIso8601String().substring(0, 10);
        agrupado[key] = (agrupado[key] ?? 0) + v.total;
      }
      final keys = agrupado.keys.toList()..sort();
      final List<Map<String, dynamic>> resultado = [];
      for (var key in keys) {
        resultado.add({'fecha': key, 'total': agrupado[key] ?? 0});
      }
      return resultado;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerVentasPorDia_fallo',
          extras: {'cantidadDias': cantidadDias});
      return [];
    }
  }

  Future<List<DetalleVentaEntity>> obtenerDetallesPorVenta(
      String ventaId) async {
    try {
      final isar = await db;
      return await isar.detalleVentaEntitys
          .filter()
          .ventaIdFkEqualTo(ventaId)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerDetallesPorVenta_fallo',
          extras: {'ventaId': ventaId});
      return [];
    }
  }

  Future<VentaEntity?> obtenerVentaPorIdString(String ventaIdString) async {
    try {
      final isar = await db;
      return await isar.ventaEntitys
          .filter()
          .idSupabaseEqualTo(ventaIdString)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerVentaPorIdString_fallo',
          extras: {'ventaIdString': ventaIdString});
      return null;
    }
  }

  Future<double> obtenerTotalVentasPorEmpleadoYRango(
      String empleado, DateTime inicio, DateTime fin) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerTotalVentasPorEmpleadoYRango_fallo',
          extras: {'empleado': empleado});
      return 0.0;
    }
  }

  // ==================== GASTOS ====================

  Future<void> guardarGasto(GastoEntity gasto) async {
    try {
      final isar = await db;
      gasto.syncStatus =
          gasto.syncStatus.isEmpty ? 'pending' : gasto.syncStatus;
      await isar.writeTxn(() async {
        await isar.gastoEntitys.put(gasto);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarGasto_fallo',
          extras: {'gastoId': gasto.id, 'descripcion': gasto.descripcion});
      rethrow;
    }
  }

  Future<List<GastoEntity>> obtenerGastos() async {
    try {
      final isar = await db;
      return await isar.gastoEntitys.where().sortByFechaDesc().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'obtenerGastos_fallo');
      return [];
    }
  }

  Future<List<GastoEntity>> obtenerGastosPendientesSync() async {
    try {
      final isar = await db;
      return await isar.gastoEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .or()
          .syncStatusEqualTo('failed')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerGastosPendientesSync_fallo');
      return [];
    }
  }

  Future<void> actualizarSyncStatusGasto(int id, String nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final gasto = await isar.gastoEntitys.get(id);
        if (gasto != null) {
          gasto.syncStatus = nuevoEstado;
          await isar.gastoEntitys.put(gasto);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusGasto_fallo',
          extras: {'id': id, 'nuevoEstado': nuevoEstado});
      rethrow;
    }
  }

  Future<double> obtenerTotalGastosPorRango(
      DateTime inicio, DateTime fin) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerTotalGastosPorRango_fallo');
      return 0.0;
    }
  }

  // ==================== LOGS ====================

  Future<void> guardarLog(LogEntity log) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.logEntitys.put(log);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarLog_fallo',
          extras: {'accion': log.accion});
      rethrow;
    }
  }

  Future<List<LogEntity>> obtenerLogs() async {
    try {
      final isar = await db;
      return await isar.logEntitys.where().sortByFechaDesc().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'obtenerLogs_fallo');
      return [];
    }
  }

  Future<List<LogEntity>> obtenerLogsPendientesSync() async {
    try {
      final isar = await db;
      return await isar.logEntitys
          .filter()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerLogsPendientesSync_fallo');
      return [];
    }
  }

  Future<void> marcarLogsComoSincronizados(List<int> ids) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'marcarLogsComoSincronizados_fallo',
          extras: {'ids': ids});
      rethrow;
    }
  }

  // ==================== CLIENTES ====================

  Future<ClienteEntity> guardarCliente(ClienteEntity cliente) async {
    try {
      final isar = await db;
      cliente.updatedAt = DateTime.now();
      cliente.createdAt ??= DateTime.now();
      await isar.writeTxn(() async {
        await isar.clienteEntitys.put(cliente);
      });
      return cliente;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarCliente_fallo',
          extras: {'clienteId': cliente.id, 'nombre': cliente.nombre});
      rethrow;
    }
  }

  Future<List<ClienteEntity>> obtenerClientes(
      {bool soloActivos = true, bool soloFrecuentes = false}) async {
    try {
      final isar = await db;
      return await isar.clienteEntitys
          .filter()
          .optional(soloActivos, (q) => q.activoEqualTo(true))
          .optional(soloFrecuentes, (q) => q.frecuenteEqualTo(true))
          .sortByFechaRegistroDesc()
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'obtenerClientes_fallo');
      return [];
    }
  }

  Future<ClienteEntity?> obtenerClientePorId(int id) async {
    try {
      final isar = await db;
      return await isar.clienteEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerClientePorId_fallo', extras: {'id': id});
      return null;
    }
  }

  Future<ClienteEntity?> obtenerClientePorSupabaseId(String supabaseId) async {
    try {
      final isar = await db;
      if (supabaseId.isEmpty) return null;
      return await isar.clienteEntitys
          .filter()
          .supabaseIdEqualTo(supabaseId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerClientePorSupabaseId_fallo',
          extras: {'supabaseId': supabaseId});
      return null;
    }
  }

  Future<List<ClienteEntity>> buscarClientes(String query,
      {bool soloFrecuentes = false}) async {
    try {
      final isar = await db;
      if (query.trim().isEmpty) return [];
      final q = query.trim().toLowerCase();
      var filter = isar.clienteEntitys
          .filter()
          .nombreContains(q, caseSensitive: false)
          .or()
          .documentoContains(q, caseSensitive: false)
          .or()
          .telefonoContains(q, caseSensitive: false);
      if (soloFrecuentes) {
        filter = filter.and().frecuenteEqualTo(true);
      }
      return await filter.findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'buscarClientes_fallo', extras: {'query': query});
      return [];
    }
  }

  Future<bool> eliminarCliente(int id) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        return await isar.clienteEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarCliente_fallo', extras: {'id': id});
      return false;
    }
  }

  Future<void> actualizarSyncStatusCliente(int id, String nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final cliente = await isar.clienteEntitys.get(id);
        if (cliente != null) {
          cliente.syncStatus = nuevoEstado;
          await isar.clienteEntitys.put(cliente);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusCliente_fallo',
          extras: {'id': id, 'nuevoEstado': nuevoEstado});
      rethrow;
    }
  }

  Future<List<ClienteEntity>> obtenerClientesPendientesSync() async {
    try {
      final isar = await db;
      return await isar.clienteEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .or()
          .syncStatusEqualTo('failed')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerClientesPendientesSync_fallo');
      return [];
    }
  }

  Future<void> actualizarEstadisticasCliente(
      int clienteId, double montoCompra) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final cliente = await isar.clienteEntitys.get(clienteId);
        if (cliente != null) {
          cliente.totalCompras += montoCompra;
          cliente.cantidadCompras += 1;
          cliente.ultimaCompra = DateTime.now();
          if (cliente.cantidadCompras >= 5) {
            cliente.frecuente = true;
          }
          cliente.updatedAt = DateTime.now();
          await isar.clienteEntitys.put(cliente);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarEstadisticasCliente_fallo',
          extras: {'clienteId': clienteId});
      rethrow;
    }
  }

  // ==================== MOVIMIENTOS DE INVENTARIO ====================

  Future<void> guardarMovimientoInventario(
      MovimientoInventarioEntity movimiento) async {
    try {
      final isar = await db;
      movimiento.syncStatus =
          movimiento.syncStatus.isEmpty ? 'pending' : movimiento.syncStatus;
      await isar.writeTxn(() async {
        await isar.movimientoInventarioEntitys.put(movimiento);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarMovimientoInventario_fallo',
          extras: {
            'movimientoId': movimiento.id,
            'tipo': movimiento.tipoMovimiento
          });
      rethrow;
    }
  }

  Future<Query<MovimientoInventarioEntity>> queryMovimientosVentaRecientes(
      DateTime desde) async {
    try {
      final isar = await db;
      return isar.movimientoInventarioEntitys
          .filter()
          .tipoMovimientoEqualTo('Venta')
          .fechaGreaterThan(desde)
          .build();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'queryMovimientosVentaRecientes_fallo');
      rethrow;
    }
  }

  Future<List<MovimientoInventarioEntity>>
      obtenerMovimientosPendientesSync() async {
    try {
      final isar = await db;
      return await isar.movimientoInventarioEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .or()
          .syncStatusEqualTo('failed')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerMovimientosPendientesSync_fallo');
      return [];
    }
  }

  Future<void> actualizarSyncStatusMovimiento(
      int id, String nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final mov = await isar.movimientoInventarioEntitys.get(id);
        if (mov != null) {
          mov.syncStatus = nuevoEstado;
          await isar.movimientoInventarioEntitys.put(mov);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusMovimiento_fallo',
          extras: {'id': id, 'nuevoEstado': nuevoEstado});
      rethrow;
    }
  }

  // ==================== TURNOS ====================

  Future<void> guardarTurno(TurnoEntity turno) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.turnoEntitys.put(turno);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarTurno_fallo',
          extras: {'turnoId': turno.id, 'usuarioId': turno.usuarioId});
      rethrow;
    }
  }

  Future<List<TurnoEntity>> obtenerTurnos() async {
    try {
      final isar = await db;
      return await isar.turnoEntitys
          .where()
          .sortByFechaAperturaDesc()
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'obtenerTurnos_fallo');
      return [];
    }
  }

  Future<TurnoEntity?> obtenerTurnoAbiertoPorUsuario(int usuarioId) async {
    try {
      final isar = await db;
      return await isar.turnoEntitys
          .filter()
          .usuarioIdEqualTo(usuarioId)
          .and()
          .estadoEqualTo('abierto')
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerTurnoAbiertoPorUsuario_fallo',
          extras: {'usuarioId': usuarioId});
      return null;
    }
  }

  Future<void> cerrarTurno(int turnoId, double montoFinal) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'cerrarTurno_fallo',
          extras: {'turnoId': turnoId});
      rethrow;
    }
  }

  Future<List<TurnoEntity>> obtenerTurnosPendientes() async {
    try {
      final isar = await db;
      return await isar.turnoEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerTurnosPendientes_fallo');
      return [];
    }
  }

  Future<void> marcarTurnoComoSincronizado(int turnoId) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final turno = await isar.turnoEntitys.get(turnoId);
        if (turno != null) {
          turno.syncStatus = 'synced';
          await isar.turnoEntitys.put(turno);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'marcarTurnoComoSincronizado_fallo',
          extras: {'turnoId': turnoId});
      rethrow;
    }
  }

  // ==================== PEDIDOS ====================

  Future<int> guardarPedido(PedidoEntity pedido) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        return await isar.pedidoEntitys.put(pedido);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarPedido_fallo',
          extras: {'pedidoId': pedido.id, 'total': pedido.total});
      rethrow;
    }
  }

  Future<List<PedidoEntity>> obtenerPedidosPorLocalDestino(
      int localDestinoId) async {
    try {
      final isar = await db;
      return await isar.pedidoEntitys
          .where()
          .localDestinoIdEqualTo(localDestinoId)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerPedidosPorLocalDestino_fallo',
          extras: {'localDestinoId': localDestinoId});
      return [];
    }
  }

  Future<List<PedidoEntity>> obtenerPedidosPorEstado(EstadoPedido estado,
      {int? localDestinoId}) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerPedidosPorEstado_fallo',
          extras: {'estado': estado.name});
      return [];
    }
  }

  Future<PedidoEntity?> obtenerPedidoPorId(int id) async {
    try {
      final isar = await db;
      return await isar.pedidoEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerPedidoPorId_fallo', extras: {'id': id});
      return null;
    }
  }

  Future<PedidoEntity?> obtenerPedidoPorSupabaseId(String supabaseId) async {
    try {
      final isar = await db;
      if (supabaseId.isEmpty) return null;
      return await isar.pedidoEntitys
          .filter()
          .supabaseIdEqualTo(supabaseId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerPedidoPorSupabaseId_fallo',
          extras: {'supabaseId': supabaseId});
      return null;
    }
  }

  Future<void> actualizarEstadoPedido(int id, EstadoPedido nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final pedido = await isar.pedidoEntitys.get(id);
        if (pedido != null) {
          pedido.estado = nuevoEstado;
          await isar.pedidoEntitys.put(pedido);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarEstadoPedido_fallo',
          extras: {'id': id, 'nuevoEstado': nuevoEstado.name});
      rethrow;
    }
  }

  Future<void> cancelarPedido(int id) async {
    try {
      await actualizarEstadoPedido(id, EstadoPedido.cancelado);
      final isar = await db;
      await isar.writeTxn(() async {
        final pedido = await isar.pedidoEntitys.get(id);
        if (pedido != null) {
          pedido.sincronizado = false;
          await isar.pedidoEntitys.put(pedido);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'cancelarPedido_fallo', extras: {'id': id});
      rethrow;
    }
  }

  Future<void> actualizarSyncStatusPedido(int id, bool sincronizado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final pedido = await isar.pedidoEntitys.get(id);
        if (pedido != null) {
          pedido.sincronizado = sincronizado;
          pedido.fechaSincronizacion = DateTime.now();
          await isar.pedidoEntitys.put(pedido);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusPedido_fallo',
          extras: {'id': id});
      rethrow;
    }
  }

  Future<List<PedidoEntity>> obtenerPedidosPendientesSync() async {
    try {
      final isar = await db;
      return await isar.pedidoEntitys
          .where()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerPedidosPendientesSync_fallo');
      return [];
    }
  }

  // ==================== DETALLES DE PEDIDO ====================

  Future<int> guardarDetallePedido(DetallePedidoEntity detalle) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        return await isar.detallePedidoEntitys.put(detalle);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarDetallePedido_fallo',
          extras: {'pedidoId': detalle.pedidoId});
      rethrow;
    }
  }

  Future<List<DetallePedidoEntity>> obtenerDetallesPorPedido(
      int pedidoId) async {
    try {
      final isar = await db;
      return await isar.detallePedidoEntitys
          .filter()
          .pedidoIdEqualTo(pedidoId)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerDetallesPorPedido_fallo',
          extras: {'pedidoId': pedidoId});
      return [];
    }
  }

  Future<void> eliminarDetallesPorPedido(int pedidoId) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarDetallesPorPedido_fallo',
          extras: {'pedidoId': pedidoId});
      rethrow;
    }
  }

  // ==================== RECEPCIONES ====================

  Future<int> guardarRecepcion(RecepcionEntity recepcion) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        return await isar.recepcionEntitys.put(recepcion);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarRecepcion_fallo',
          extras: {'pedidoId': recepcion.pedidoId});
      rethrow;
    }
  }

  Future<RecepcionEntity?> obtenerRecepcionPorPedido(int pedidoId) async {
    try {
      final isar = await db;
      return await isar.recepcionEntitys
          .filter()
          .pedidoIdEqualTo(pedidoId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerRecepcionPorPedido_fallo',
          extras: {'pedidoId': pedidoId});
      return null;
    }
  }

  Future<void> actualizarSyncStatusRecepcion(int id, bool sincronizado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final recepcion = await isar.recepcionEntitys.get(id);
        if (recepcion != null) {
          recepcion.sincronizado = sincronizado;
          recepcion.fechaSincronizacion = DateTime.now();
          await isar.recepcionEntitys.put(recepcion);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusRecepcion_fallo',
          extras: {'id': id});
      rethrow;
    }
  }

  // ==================== PROVEEDORES ====================

  Future<int> guardarProveedor(ProveedorEntity proveedor) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        return await isar.proveedorEntitys.put(proveedor);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarProveedor_fallo',
          extras: {'proveedorId': proveedor.id, 'nombre': proveedor.nombre});
      rethrow;
    }
  }

  Future<List<ProveedorEntity>> obtenerProveedores(
      {bool soloActivos = true}) async {
    try {
      final isar = await db;
      if (soloActivos) {
        return await isar.proveedorEntitys
            .filter()
            .activoEqualTo(true)
            .findAll();
      } else {
        return await isar.proveedorEntitys.where().findAll();
      }
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerProveedores_fallo');
      return [];
    }
  }

  Future<ProveedorEntity?> obtenerProveedorPorId(int id) async {
    try {
      final isar = await db;
      return await isar.proveedorEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerProveedorPorId_fallo',
          extras: {'id': id});
      return null;
    }
  }

  Future<ProveedorEntity?> obtenerProveedorPorSupabaseId(
      String supabaseId) async {
    try {
      final isar = await db;
      if (supabaseId.isEmpty) return null;
      return await isar.proveedorEntitys
          .filter()
          .supabaseIdEqualTo(supabaseId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerProveedorPorSupabaseId_fallo',
          extras: {'supabaseId': supabaseId});
      return null;
    }
  }

  Future<ProveedorEntity?> obtenerProveedorPorNombre(String nombre) async {
    try {
      final isar = await db;
      final nombreLimpio = nombre.trim();
      if (nombreLimpio.isEmpty) return null;

      var proveedor = await isar.proveedorEntitys
          .filter()
          .nombreEqualTo(nombreLimpio, caseSensitive: false)
          .findFirst();

      proveedor ??= await isar.proveedorEntitys
          .filter()
          .nombreContains(nombreLimpio, caseSensitive: false)
          .findFirst();

      return proveedor;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerProveedorPorNombre_fallo',
          extras: {'nombre': nombre});
      return null;
    }
  }

  Future<String?> obtenerSupabaseIdProveedorPorNombre(String nombre) async {
    try {
      final proveedor = await obtenerProveedorPorNombre(nombre);
      return proveedor?.supabaseId;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerSupabaseIdProveedorPorNombre_fallo',
          extras: {'nombre': nombre});
      return null;
    }
  }

  Future<void> actualizarSyncStatusProveedor(int id, bool sincronizado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final proveedor = await isar.proveedorEntitys.get(id);
        if (proveedor != null) {
          proveedor.sincronizado = sincronizado;
          proveedor.fechaSincronizacion = DateTime.now();
          await isar.proveedorEntitys.put(proveedor);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusProveedor_fallo',
          extras: {'id': id});
      rethrow;
    }
  }

  Future<List<ProveedorEntity>> obtenerProveedoresPendientesSync() async {
    try {
      final isar = await db;
      return await isar.proveedorEntitys
          .filter()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerProveedoresPendientesSync_fallo');
      return [];
    }
  }

  Future<void> desactivarProveedor(int id) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final proveedor = await isar.proveedorEntitys.get(id);
        if (proveedor != null) {
          proveedor.activo = false;
          await isar.proveedorEntitys.put(proveedor);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'desactivarProveedor_fallo', extras: {'id': id});
      rethrow;
    }
  }

  Future<List<ProductoEntity>> obtenerProductosPorProveedor(
      int proveedorId) async {
    try {
      final isar = await db;
      return await isar.productoEntitys
          .filter()
          .proveedorIdEqualTo(proveedorId)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerProductosPorProveedor_fallo',
          extras: {'proveedorId': proveedorId});
      return [];
    }
  }

  Future<bool> eliminarProveedor(int id) async {
    try {
      final isar = await db;
      final productos =
          await isar.productoEntitys.filter().proveedorIdEqualTo(id).findAll();
      if (productos.isNotEmpty) {
        return false;
      }
      return await isar.writeTxn(() async {
        return await isar.proveedorEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarProveedor_fallo', extras: {'id': id});
      return false;
    }
  }

  Future<List<ProveedorEntity>> buscarProveedores(String query) async {
    try {
      final isar = await db;
      if (query.trim().isEmpty) return [];
      final q = query.trim().toLowerCase();
      return await isar.proveedorEntitys
          .filter()
          .nombreContains(q, caseSensitive: false)
          .or()
          .empresaContains(q, caseSensitive: false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'buscarProveedores_fallo',
          extras: {'query': query});
      return [];
    }
  }

  // ==================== LOCALES ====================

  Future<LocalEntity?> obtenerLocalPorId(int id) async {
    try {
      final isar = await db;
      return await isar.localEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerLocalPorId_fallo', extras: {'id': id});
      return null;
    }
  }

  Future<LocalEntity?> obtenerLocalPorSupabaseId(String supabaseId) async {
    try {
      final isar = await db;
      if (supabaseId.isEmpty) return null;
      return await isar.localEntitys
          .filter()
          .supabaseIdEqualTo(supabaseId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerLocalPorSupabaseId_fallo',
          extras: {'supabaseId': supabaseId});
      return null;
    }
  }

  Future<int> guardarLocal(LocalEntity local) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        local.updatedAt = DateTime.now();
        local.createdAt ??= DateTime.now();
        return await isar.localEntitys.put(local);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarLocal_fallo',
          extras: {'localId': local.id, 'nombre': local.nombre});
      rethrow;
    }
  }

  Future<List<LocalEntity>> obtenerLocales({bool soloActivos = true}) async {
    try {
      final isar = await db;
      if (soloActivos) {
        return await isar.localEntitys.filter().activoEqualTo(true).findAll();
      }
      return await isar.localEntitys.where().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'obtenerLocales_fallo');
      return [];
    }
  }

  Future<LocalEntity?> obtenerLocalActivo() async {
    try {
      final isar = await db;
      final localSincronizado = await isar.localEntitys
          .filter()
          .activoEqualTo(true)
          .sincronizadoEqualTo(true)
          .supabaseIdIsNotNull()
          .sortByFechaSincronizacionDesc()
          .findFirst();

      if (localSincronizado != null) {
        return localSincronizado;
      }

      return await isar.localEntitys.filter().activoEqualTo(true).findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerLocalActivo_fallo');
      return null;
    }
  }

  Future<int> contarProductosPorDepartamento(int departamentoId) async {
    try {
      final isar = await db;
      final departamento = await isar.departamentoEntitys.get(departamentoId);
      if (departamento == null) return 0;

      final nombreDepartamento = departamento.nombre.trim().toLowerCase();
      final productos = await isar.productoEntitys.where().findAll();
      return productos
          .where((producto) =>
              producto.categoria.trim().toLowerCase() == nombreDepartamento)
          .length;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'contarProductosPorDepartamento_fallo',
          extras: {'departamentoId': departamentoId});
      return 0;
    }
  }

  Future<bool> eliminarLocal(int id) async {
    try {
      final isar = await db;
      final pedidos = await isar.pedidoEntitys
          .filter()
          .localOrigenIdEqualTo(id)
          .or()
          .localDestinoIdEqualTo(id)
          .findAll();
      if (pedidos.isNotEmpty) {
        debugPrint(
            '⚠️ No se puede eliminar el local $id porque tiene pedidos asociados.');
        return false;
      }

      final usuarios =
          await isar.usuarioEntitys.filter().localIdEqualTo(id).findAll();
      if (usuarios.isNotEmpty) {
        for (var u in usuarios) {
          u.localId = null;
        }
        await isar.writeTxn(() async {
          await isar.usuarioEntitys.putAll(usuarios);
        });
        debugPrint(
            '✅ ${usuarios.length} usuarios actualizados (localId → null)');
      }

      final departamentos =
          await isar.departamentoEntitys.filter().localIdEqualTo(id).findAll();
      if (departamentos.isNotEmpty) {
        for (var d in departamentos) {
          d.localId = null;
        }
        await isar.writeTxn(() async {
          await isar.departamentoEntitys.putAll(departamentos);
        });
        debugPrint(
            '✅ ${departamentos.length} departamentos actualizados (localId → null)');
      }

      final eliminado = await isar.writeTxn(() async {
        return await isar.localEntitys.delete(id);
      });

      if (eliminado) {
        debugPrint('✅ Local $id eliminado correctamente');
      }

      return eliminado;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarLocal_fallo', extras: {'id': id});
      return false;
    }
  }

  Future<void> actualizarSyncStatusLocal(int id, bool sincronizado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final local = await isar.localEntitys.get(id);
        if (local != null) {
          local.sincronizado = sincronizado;
          local.fechaSincronizacion = DateTime.now();
          await isar.localEntitys.put(local);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusLocal_fallo',
          extras: {'id': id});
      rethrow;
    }
  }

  Future<List<LocalEntity>> obtenerLocalesPendientesSync() async {
    try {
      final isar = await db;
      return await isar.localEntitys
          .filter()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerLocalesPendientesSync_fallo');
      return [];
    }
  }

  // ==================== DEPARTAMENTOS ====================

  Future<int> guardarDepartamento(DepartamentoEntity departamento) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        departamento.updatedAt = DateTime.now();
        departamento.createdAt ??= DateTime.now();
        return await isar.departamentoEntitys.put(departamento);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarDepartamento_fallo',
          extras: {
            'departamentoId': departamento.id,
            'nombre': departamento.nombre
          });
      rethrow;
    }
  }

  Future<List<DepartamentoEntity>> obtenerDepartamentos(
      {bool? soloActivos = true, int? localId}) async {
    try {
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
      if (soloActivos == true) {
        departamentos = departamentos.where((d) => d.activo).toList();
      }
      return departamentos;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerDepartamentos_fallo');
      return [];
    }
  }

  Future<DepartamentoEntity?> obtenerDepartamentoPorId(int id) async {
    try {
      final isar = await db;
      return await isar.departamentoEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerDepartamentoPorId_fallo',
          extras: {'id': id});
      return null;
    }
  }

  Future<bool> eliminarDepartamento(int id) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        return await isar.departamentoEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarDepartamento_fallo', extras: {'id': id});
      return false;
    }
  }

  Future<void> actualizarSyncStatusDepartamento(
      int id, bool sincronizado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final departamento = await isar.departamentoEntitys.get(id);
        if (departamento != null) {
          departamento.sincronizado = sincronizado;
          departamento.fechaSincronizacion = DateTime.now();
          await isar.departamentoEntitys.put(departamento);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusDepartamento_fallo',
          extras: {'id': id});
      rethrow;
    }
  }

  Future<List<DepartamentoEntity>> obtenerDepartamentosPendientesSync() async {
    try {
      final isar = await db;
      return await isar.departamentoEntitys
          .filter()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerDepartamentosPendientesSync_fallo');
      return [];
    }
  }

  // ==================== CÓDIGOS DE BARRAS ALIAS ====================

  Future<void> guardarCodigoAlias(CodigoBarrasAliasEntity alias) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.codigoBarrasAliasEntitys.put(alias);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarCodigoAlias_fallo',
          extras: {'codigo': alias.codigo});
      rethrow;
    }
  }

  Future<CodigoBarrasAliasEntity?> obtenerAliasPorCodigo(String codigo) async {
    try {
      final isar = await db;
      return await isar.codigoBarrasAliasEntitys
          .filter()
          .codigoEqualTo(codigo.trim())
          .activoEqualTo(true)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerAliasPorCodigo_fallo',
          extras: {'codigo': codigo});
      return null;
    }
  }

  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPorProducto(
      int productoId) async {
    try {
      final isar = await db;
      return await isar.codigoBarrasAliasEntitys
          .filter()
          .productoIdEqualTo(productoId)
          .activoEqualTo(true)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerAliasPorProducto_fallo',
          extras: {'productoId': productoId});
      return [];
    }
  }

  Future<void> desactivarAlias(int aliasId) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final alias = await isar.codigoBarrasAliasEntitys.get(aliasId);
        if (alias != null) {
          alias.activo = false;
          alias.sincronizado = false;
          await isar.codigoBarrasAliasEntitys.put(alias);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'desactivarAlias_fallo',
          extras: {'aliasId': aliasId});
      rethrow;
    }
  }

  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPendientesSync() async {
    try {
      final isar = await db;
      return await isar.codigoBarrasAliasEntitys
          .filter()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerAliasPendientesSync_fallo');
      return [];
    }
  }

  // ==================== LOTES ====================

  Future<void> guardarLote(LoteEntity lote) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.loteEntitys.put(lote);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarLote_fallo',
          extras: {'loteId': lote.id, 'productoId': lote.productoId});
      rethrow;
    }
  }

  Future<double> obtenerStockTotalPorProducto(int productoId) async {
    try {
      final isar = await db;
      final lotes = await isar.loteEntitys
          .filter()
          .productoIdEqualTo(productoId)
          .estadoEqualTo('activo')
          .findAll();
      return lotes.fold<double>(
          0.0, (sum, lote) => sum + lote.cantidadRestante);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerStockTotalPorProducto_fallo',
          extras: {'productoId': productoId});
      return 0.0;
    }
  }

  Future<List<LoteEntity>> obtenerLotesActivos(int productoId,
      {bool priorizarVencimiento = true}) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerLotesActivos_fallo',
          extras: {'productoId': productoId});
      return [];
    }
  }

  Future<bool> descontarLote(int loteId, double cantidad) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'descontarLote_fallo',
          extras: {'loteId': loteId});
      return false;
    }
  }

  Future<LoteEntity?> obtenerLoteParaVenta(int productoId,
      {bool priorizarVencimiento = true}) async {
    try {
      final lotes = await obtenerLotesActivos(
        productoId,
        priorizarVencimiento: priorizarVencimiento,
      );
      return lotes.isNotEmpty ? lotes.first : null;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerLoteParaVenta_fallo',
          extras: {'productoId': productoId});
      return null;
    }
  }

  Future<List<LoteEntity>> obtenerTodosLosLotes() async {
    try {
      final isar = await db;
      return await isar.loteEntitys.where().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerTodosLosLotes_fallo');
      return [];
    }
  }

  Future<List<ProductoEntity>> obtenerTodosLosProductos() async {
    return await obtenerProductos();
  }

  Future<int> contarLotes() async {
    try {
      final isar = await db;
      return await isar.loteEntitys.where().count();
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'contarLotes_fallo');
      return 0;
    }
  }

  Future<int> contarProductos() async {
    try {
      final isar = await db;
      return await isar.productoEntitys.where().count();
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'contarProductos_fallo');
      return 0;
    }
  }

  Future<Map<String, dynamic>> migrarStockExistenteALotes() async {
    try {
      final isar = await db;

      // Resolver el local activo dentro de la propia migración para que
      // sea autosuficiente y no dependa del orden de arranque del provider.
      final localActivo = await obtenerLocalActivo();
      if (localActivo == null) {
        debugPrint(
            '⚠️ migrarStockExistenteALotes: no hay local activo; migración omitida');
        return {
          'success': true,
          'lotesCreados': 0,
          'productosSinStock': 0,
          'productosConLotesPrevios': 0,
          'totalProductos': 0,
          'error': null,
          'omision': 'sin_local_activo',
        };
      }

      final int localId = localActivo.id;
      final productos = await isar.productoEntitys.where().findAll();
      final todosLosLotes = await isar.loteEntitys.where().findAll();

      int lotesCreados = 0;
      int productosSinStock = 0;
      int productosConLotesPrevios = 0;

      for (var p in productos) {
        final lotesExistentes =
            todosLosLotes.where((lote) => lote.productoId == p.id).toList();

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
          ..localId = localId
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'migrarStockExistenteALotes_fallo');
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

  Future<List<LoteEntity>> obtenerLotesPorLocal(int localId) async {
    try {
      final isar = await db;
      return await isar.loteEntitys.filter().localIdEqualTo(localId).findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerLotesPorLocal_fallo',
          extras: {'localId': localId});
      return [];
    }
  }

  Future<List<LoteEntity>> obtenerLotesPorLocalYEstado(
      int localId, String estado) async {
    try {
      final isar = await db;
      return await isar.loteEntitys
          .filter()
          .localIdEqualTo(localId)
          .estadoEqualTo(estado)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerLotesPorLocalYEstado_fallo',
          extras: {'localId': localId, 'estado': estado});
      return [];
    }
  }

  Future<List<LoteEntity>> obtenerLotesPorProductoYLocal(
      int productoId, int localId) async {
    try {
      final isar = await db;
      return await isar.loteEntitys
          .filter()
          .productoIdEqualTo(productoId)
          .localIdEqualTo(localId)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerLotesPorProductoYLocal_fallo',
          extras: {'productoId': productoId, 'localId': localId});
      return [];
    }
  }

  Future<Map<String, dynamic>> migrarLotesConLocal() async {
    try {
      final isar = await db;
      final lotesSinLocal =
          await isar.loteEntitys.filter().localIdEqualTo(0).findAll();

      if (lotesSinLocal.isEmpty) {
        return {
          'success': true,
          'actualizados': 0,
          'mensaje': 'Todos los lotes ya tienen local asignado'
        };
      }

      final localActivo =
          await isar.localEntitys.filter().activoEqualTo(true).findFirst();
      final int localFallback = localActivo?.id ?? 1;

      for (var lote in lotesSinLocal) {
        lote.localId = localFallback;
        lote.sincronizado = false;
        await isar.writeTxn(() async {
          await isar.loteEntitys.put(lote);
        });
      }

      return {
        'success': true,
        'actualizados': lotesSinLocal.length,
        'mensaje':
            '${lotesSinLocal.length} lotes actualizados al local $localFallback',
      };
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'migrarLotesConLocal_fallo');
      return {
        'success': false,
        'actualizados': 0,
        'mensaje': 'Error: ${e.toString()}',
      };
    }
  }

  Future<int> asignarSupabaseIdsAFaltantes() async {
    try {
      final isar = await db;
      final supabase = Supabase.instance.client;

      final productosSinId =
          await isar.productoEntitys.filter().supabaseIdIsNull().findAll();

      if (productosSinId.isEmpty) {
        debugPrint('✅ Todos los productos ya tienen supabaseId.');
        return 0;
      }

      debugPrint(
          '🔄 Asignando supabaseId a ${productosSinId.length} productos...');

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
          debugPrint(
              '✅ Producto ${p.nombre} (ID: ${p.id}) → supabaseId: $uuid');
        } else {
          debugPrint(
              '⚠️ Producto ${p.nombre} (ID: ${p.id}) no encontrado en Supabase.');
        }
      }

      debugPrint('✅ $actualizados productos actualizados con supabaseId.');
      return actualizados;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'asignarSupabaseIdsAFaltantes_fallo');
      return 0;
    }
  }

  Future<bool> eliminarLote(int id) async {
    try {
      final isar = await db;
      final lote = await isar.loteEntitys.get(id);
      if (lote == null) return false;
      if (lote.cantidadRestante > 0) return false;
      return await isar.writeTxn(() async {
        return await isar.loteEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarLote_fallo', extras: {'id': id});
      return false;
    }
  }

  // ==================== LOTES (MÉTODOS ADICIONALES) ====================

  Future<LoteEntity?> obtenerLotePorId(int id) async {
    try {
      final isar = await db;
      return await isar.loteEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerLotePorId_fallo', extras: {'id': id});
      return null;
    }
  }

  Future<List<MovimientoLoteEntity>> obtenerTodosMovimientosLote() async {
    try {
      final isar = await db;
      return await isar.movimientoLoteEntitys.where().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerTodosMovimientosLote_fallo');
      return [];
    }
  }

  Future<List<LoteEntity>> obtenerLotesPendientes() async {
    try {
      final isar = await db;
      return await isar.loteEntitys
          .filter()
          .estadoEqualTo('pendiente')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerLotesPendientes_fallo');
      return [];
    }
  }

  Future<List<LoteEntity>> obtenerLotesHistorial() async {
    try {
      final isar = await db;
      return await isar.loteEntitys
          .filter()
          .estadoEqualTo('agotado')
          .or()
          .estadoEqualTo('vencido')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerLotesHistorial_fallo');
      return [];
    }
  }

  Future<bool> verificarLote({
    required int loteId,
    required String codigoBarras,
    required double cantidadRecibida,
    required int usuarioId,
  }) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        final lote = await isar.loteEntitys.get(loteId);
        if (lote == null) return false;
        if (lote.estado != 'pendiente') return false;

        lote.codigoLoteProveedor = codigoBarras;
        lote.cantidadRestante = cantidadRecibida;
        lote.estado = 'activo';
        lote.sincronizado = false;
        await isar.loteEntitys.put(lote);

        final movimiento = MovimientoLoteEntity()
          ..loteId = lote.id
          ..tipo = 'activacion'
          ..cantidad = cantidadRecibida
          ..fecha = DateTime.now()
          ..usuarioId = usuarioId
          ..observaciones = 'Lote activado desde pedido'
          ..sincronizado = false;
        await isar.movimientoLoteEntitys.put(movimiento);

        final producto = await isar.productoEntitys.get(lote.productoId);
        if (producto != null) {
          producto.stock += cantidadRecibida;
          await isar.productoEntitys.put(producto);
        }

        return true;
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'verificarLote_fallo',
          extras: {'loteId': loteId, 'usuarioId': usuarioId});
      return false;
    }
  }

  Future<void> guardarMovimientoLote(MovimientoLoteEntity movimiento) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.movimientoLoteEntitys.put(movimiento);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarMovimientoLote_fallo',
          extras: {'loteId': movimiento.loteId, 'tipo': movimiento.tipo});
      rethrow;
    }
  }

  Future<List<MovimientoLoteEntity>> obtenerMovimientosPorLote(
      int loteId) async {
    try {
      final isar = await db;
      return await isar.movimientoLoteEntitys
          .filter()
          .loteIdEqualTo(loteId)
          .sortByFechaDesc()
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerMovimientosPorLote_fallo',
          extras: {'loteId': loteId});
      return [];
    }
  }

  Future<List<MovimientoLoteEntity>>
      obtenerMovimientosLotePendientesSync() async {
    try {
      final isar = await db;
      return await isar.movimientoLoteEntitys
          .filter()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerMovimientosLotePendientesSync_fallo');
      return [];
    }
  }

  // ==================== HISTORIAL DE CÓDIGOS POR PRODUCTO ====================

  Future<List<HistorialCodigoItem>> obtenerHistorialCodigosPorProducto(
      int productoId) async {
    try {
      final isar = await db;
      final producto = await isar.productoEntitys.get(productoId);
      final proveedorNombre = producto?.proveedorNombre ?? '';

      final List<HistorialCodigoItem> items = [];

      final alias = await isar.codigoBarrasAliasEntitys
          .filter()
          .productoIdEqualTo(productoId)
          .activoEqualTo(true)
          .findAll();
      for (var a in alias) {
        items.add(HistorialCodigoItem(
          codigo: a.codigo,
          proveedorNombre: proveedorNombre,
          fechaIngreso: a.fechaAsignacion,
          fechaVencimiento: null,
          cantidad: 0,
          precio: 0,
          tipo: 'alias',
        ));
      }

      final lotes = await isar.loteEntitys
          .filter()
          .productoIdEqualTo(productoId)
          .findAll();
      for (var l in lotes) {
        if (l.codigoLoteProveedor != null &&
            l.codigoLoteProveedor!.isNotEmpty) {
          items.add(HistorialCodigoItem(
            codigo: l.codigoLoteProveedor!,
            proveedorNombre: proveedorNombre,
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerHistorialCodigosPorProducto_fallo',
          extras: {'productoId': productoId});
      return [];
    }
  }

  // ==================== TELEGRAM CONFIG ====================

  Future<TelegramConfigEntity?> obtenerTelegramConfigPorUsuario(
      int usuarioId) async {
    try {
      final isar = await db;
      final configs = await isar.telegramConfigEntitys
          .filter()
          .usuarioIdEqualTo(usuarioId)
          .findAll();

      if (configs.isEmpty) return null;

      configs.sort((a, b) {
        final aTime = a.updatedAt ?? DateTime(1970);
        final bTime = b.updatedAt ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });

      return configs.first;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerTelegramConfigPorUsuario_fallo',
          extras: {'usuarioId': usuarioId});
      return null;
    }
  }

  Future<List<TelegramConfigEntity>> obtenerTodasTelegramConfigs() async {
    try {
      final isar = await db;
      return await isar.telegramConfigEntitys.where().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerTodasTelegramConfigs_fallo');
      return [];
    }
  }

  Future<List<TelegramConfigEntity>>
      obtenerTelegramConfigsPendientesSync() async {
    try {
      final isar = await db;
      return await isar.telegramConfigEntitys
          .filter()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerTelegramConfigsPendientesSync_fallo');
      return [];
    }
  }

  Future<int> guardarTelegramConfig(TelegramConfigEntity config) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        config.updatedAt = DateTime.now();
        config.createdAt ??= DateTime.now();
        return await isar.telegramConfigEntitys.put(config);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarTelegramConfig_fallo',
          extras: {'usuarioId': config.usuarioId});
      rethrow;
    }
  }

  Future<TelegramConfigEntity?> obtenerTelegramConfig() async {
    try {
      final isar = await db;
      return await isar.telegramConfigEntitys.where().findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerTelegramConfig_fallo');
      return null;
    }
  }

  Future<void> actualizarSyncStatusTelegramConfig(
      int id, bool sincronizado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final config = await isar.telegramConfigEntitys.get(id);
        if (config != null) {
          config.sincronizado = sincronizado;
          config.fechaSincronizacion = DateTime.now();
          await isar.telegramConfigEntitys.put(config);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusTelegramConfig_fallo',
          extras: {'id': id});
      rethrow;
    }
  }

  Future<List<TelegramConfigEntity>> obtenerTelegramConfigs() async {
    try {
      final isar = await db;
      return await isar.telegramConfigEntitys.where().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerTelegramConfigs_fallo');
      return [];
    }
  }

  Future<void> eliminarTelegramConfig(int id) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.telegramConfigEntitys.delete(id);
      });
      debugPrint('🗑️ Configuración de Telegram eliminada (ID: $id)');
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarTelegramConfig_fallo',
          extras: {'id': id});
      rethrow;
    }
  }

  // ==================== Sincronización general ====================

  Future<List<VentaEntity>> obtenerVentasPendientesSync() async {
    try {
      final isar = await db;
      return await isar.ventaEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .or()
          .syncStatusEqualTo('failed')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerVentasPendientesSync_fallo');
      return [];
    }
  }

  Future<void> actualizarSyncStatusVenta(int id, String nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final venta = await isar.ventaEntitys.get(id);
        if (venta != null) {
          venta.syncStatus = nuevoEstado;
          await isar.ventaEntitys.put(venta);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusVenta_fallo',
          extras: {'id': id});
      rethrow;
    }
  }

  Future<List<ProductoEntity>> obtenerProductosPendientesSync() async {
    try {
      final isar = await db;
      return await isar.productoEntitys
          .filter()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerProductosPendientesSync_fallo');
      return [];
    }
  }

  Future<List<LoteEntity>> obtenerLotesPendientesSync() async {
    try {
      final isar = await db;
      return await isar.loteEntitys
          .filter()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerLotesPendientesSync_fallo');
      return [];
    }
  }

  Future<void> guardarDetallesVenta(
      String ventaId, List<DetalleVentaEntity> detalles) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.detalleVentaEntitys
            .filter()
            .ventaIdFkEqualTo(ventaId)
            .deleteAll();
        for (var item in detalles) {
          item.ventaIdFk = ventaId;
          await isar.detalleVentaEntitys.put(item);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarDetallesVenta_fallo',
          extras: {'ventaId': ventaId});
      rethrow;
    }
  }

  Future<void> resetearSupabaseIdsIncorrectos() async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'resetearSupabaseIdsIncorrectos_fallo');
      rethrow;
    }
  }

  Future<void> inicializarUsuarioAdminPorDefecto() async {
    try {
      final isar = await db;
      await _inicializarUsuariosDemo(isar);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'inicializarUsuarioAdminPorDefecto_fallo');
      rethrow;
    }
  }

  // ==================== DASHBOARD / ESTADÍSTICAS ====================

  Future<Map<String, dynamic>> obtenerResumenDashboard() async {
    try {
      final isar = await db;
      final hoy = DateTime.now();
      final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
      final inicioSemana = inicioHoy.subtract(Duration(days: hoy.weekday - 1));
      final inicioMes = DateTime(hoy.year, hoy.month, 1);
      final finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59, 999);

      final totalHoy = await obtenerTotalVentasPorRango(inicioHoy, finDia);
      final totalSemana =
          await obtenerTotalVentasPorRango(inicioSemana, finDia);
      final totalMes = await obtenerTotalVentasPorRango(inicioMes, finDia);
      final totalGastosMes =
          await obtenerTotalGastosPorRango(inicioMes, finDia);
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
          .fechaBetween(inicioHoy, finDia,
              includeLower: true, includeUpper: true)
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerResumenDashboard_fallo');
      return {};
    }
  }

  Future<List<VentaEntity>> obtenerVentasPorPeriodo(String periodo) async {
    try {
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
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerVentasPorPeriodo_fallo',
          extras: {'periodo': periodo});
      return [];
    }
  }
}
