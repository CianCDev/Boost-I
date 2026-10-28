import 'dart:io';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: unnecessary_import
import 'package:flutter/foundation.dart' show visibleForTesting;
import '../../../presentation/utils/pin_hasher.dart';
import '../../../presentation/utils/tenant_utils.dart';

// Entidades
import 'package:app_boosti_v2/features/pos/data/Local/entities/local_entity.dart';
import 'autorizacion_descuento_entity.dart';
import 'cart_session_entity.dart';
import 'cliente_entity.dart';
import 'estado_plato.dart';
import '../entities/turno_entity.dart';
import '../entities/log_entity.dart';
import '../entities/venta_entity.dart';
import 'venta_anulada_entity.dart';
import 'gasto_anulado_entity.dart';
import '../entities/detalle_venta_entity.dart';
import '../entities/detalle_pedido_entity.dart';
import '../entities/producto_entity.dart';
import '../entities/usuario_entity.dart';
import '../entities/pedido_entity.dart';
import '../entities/proveedor_entity.dart';
import '../entities/movimiento_inventario_entity.dart';
import 'receta_entity.dart';
import 'descuento_lote_plan.dart';
import '../entities/recepcion_entity.dart';
import 'categoria_entity.dart';
import 'codigo_barra_alia_entity.dart';
import '../entities/lote_entity.dart';
import '../entities/departamento_entity.dart';
import '../entities/mesa_entity.dart';
import '../entities/telegram_config_entity.dart';
import 'config_descuento_mayorista_entity.dart';
import 'cotizacion_mayor_entity.dart';
import 'empleado_entity.dart';
import 'gasto_entity.dart';
import 'marca_entity.dart';
import '../entities/movimiento_lote_entity.dart';
import '../../../presentation/services/error_service.dart'; // ✅ NUEVO
import 'horario_entity.dart';
import 'nomina_pago_entity.dart';
import 'pago_venta_entity.dart';
import 'suscripcion_entity.dart';
import 'plan_entity.dart';


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
Future<Isar> _initIsar({String? testDirectory}) async {
  if (_isarInstance != null && _isarInstance!.isOpen) {
    return _isarInstance!;
  }

  // ✅ Directorio base: el pasado por test o el de la app
  final Directory baseDir;
  if (testDirectory != null) {
    baseDir = Directory(testDirectory);
    await baseDir.create(recursive: true);
  } else {
    baseDir = await getApplicationDocumentsDirectory();
  }

  final prefs = await SharedPreferences.getInstance();
  final empresaId = prefs.getString('empresa_id') ?? 'default';
  final dbPath = '${baseDir.path}/isar_$empresaId';

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
        CartSessionEntitySchema,
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
        EmpleadoInfoEntitySchema,
        HorarioEntitySchema,
        NominaPagoEntitySchema,
        PagoVentaEntitySchema,
        CotizacionMayorEntitySchema,
        AutorizacionDescuentoEntitySchema,
        ConfigDescuentoMayoristaEntitySchema,
        PlanEntitySchema,
        SuscripcionEntitySchema,
        VentaAnuladaEntitySchema,
        GastoAnuladoEntitySchema,
        MesaEntitySchema,
        RecetaEntitySchema,
      ],
      directory: dbPath,
      inspector: testDirectory == null,
    );
    debugPrint('✅ Isar abierto en: $dbPath');
  } catch (e) {
    debugPrint('⚠️ Error abriendo Isar en $dbPath: $e');
    final fallbackPath = '${baseDir.path}/isar_default';
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
        CartSessionEntitySchema,
        MarcaEntitySchema,
        MovimientoLoteEntitySchema,
        EmpleadoInfoEntitySchema,
        HorarioEntitySchema,
        NominaPagoEntitySchema,
        ClienteEntitySchema,
        PagoVentaEntitySchema,
        CotizacionMayorEntitySchema,
        AutorizacionDescuentoEntitySchema,
        ConfigDescuentoMayoristaEntitySchema,
        PlanEntitySchema,
        SuscripcionEntitySchema,
        VentaAnuladaEntitySchema,
        GastoAnuladoEntitySchema,
        MesaEntitySchema,
        RecetaEntitySchema,
      ],
      directory: fallbackPath,
      inspector: testDirectory == null,
    );
    debugPrint('✅ Isar abierto en ruta por defecto: $fallbackPath');
  }

  // ═══════════════════════════════════════════════════════════════
  // ✅ MIGRACIONES DE DATOS
  //
  // Siempre corren al abrir la BD, independiente del ambiente.
  // Antes estaban dentro de `if (!skipDemoInit)` → nunca se
  // ejecutaban en producción y los PINs legacy quedaban en texto
  // plano para siempre.
  // ═══════════════════════════════════════════════════════════════
  try {
    await migrarPinsAHash(isar);
  } catch (e) {
    debugPrint('⚠️ Error migrando PINs a hash: $e');
  }

  _isarInstance = isar;
  return isar;
}



/// ══════════════════════════════════════════════════════════════
/// MÉTODOS SOLO PARA TESTS
/// ══════════════════════════════════════════════════════════════

/// Cierra y limpia la instancia actual de Isar.
/// Necesario entre tests para garantizar aislamiento.
@visibleForTesting
static Future<void> resetForTesting() async {
  if (_instance._isarInstance != null && _instance._isarInstance!.isOpen) {
    await _instance._isarInstance!.close();
  }
  _instance._isarInstance = null;
}

@visibleForTesting
Future<bool> forzarPinLegacyParaTest(
  int usuarioId,
  String pinPlano,
) async {
  try {
    final isar = await db;
    return await isar.writeTxn(() async {
      final u = await isar.usuarioEntitys.get(usuarioId);
      if (u == null) return false;
      u.pin = pinPlano; // texto plano, sin hashear
      await isar.usuarioEntitys.put(u);
      return true;
    });
  } catch (e, stack) {
    ErrorService.captureError(
      e,
      stack: stack,
      hint: 'forzarPinLegacyParaTest_fallo',
      extras: {'usuarioId': usuarioId},
    );
    return false;
  }
}

/// Inicializa la BD en un directorio temporal específico.
/// No crea datos demo para que los tests controlen los datos.
@visibleForTesting
Future<void> initForTesting(String directoryPath) async {
  _isarInstance = await _initIsar(testDirectory: directoryPath);
}

/// Obtiene los usuarios que fueron modificados localmente (ej. cambio de PIN) 
  /// y están pendientes de subir a Supabase.
  Future<List<UsuarioEntity>> obtenerUsuariosNoSincronizados() async {
    final isar = await db; // Usa la variable de tu instancia de Isar
    return await isar.usuarioEntitys // Revisa si tu autogenerado lo llama usuarioEntitys o usuarios
        .filter()
        .sincronizadoEqualTo(false)
        .findAll();
  }


  /// Valida el PIN ingresado contra los usuarios locales activos.
  /// Maneja tanto PINs hasheados como PINs en texto plano (migración en caliente).
  Future<UsuarioEntity?> validarPin(String pinIngresado) async {
    final isar = await db; // Usa la variable que te da la instancia de Isar
    
    // Traemos a los usuarios activos. Revisa si tu colección se llama 
    // usuarioEntitys o usuarios según lo haya generado Isar.
    final usuarios = await isar.usuarioEntitys.where().findAll();

    for (final usuario in usuarios) {
      // 1. Verificamos si el PIN coincide usando el Hasher
      if (PinHasher.verify(pinIngresado, usuario.pin)) {
        return usuario;
      }
      
      // 2. Soporte para migración: Si el PIN guardado aún está en texto plano
      if (!PinHasher.isHashed(usuario.pin) && usuario.pin == pinIngresado) {
        // Opcional: Aquí podrías hashear el PIN y guardarlo para futuras veces,
        // pero por ahora solo permitimos el acceso.
        return usuario;
      }
    }

    // Retorna null si el PIN no coincide con ningún usuario
    return null;
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

  Future<void> guardarUsuario(UsuarioEntity usuario) async {
    try {
      // Hashear el PIN si viene en plano (regla aplicada en un solo punto)
      if (usuario.pin.isNotEmpty &&
          !PinHasher.isHashed(usuario.pin)) {
        usuario.pin = PinHasher.hashWithNewSalt(usuario.pin);
      }
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.usuarioEntitys.put(usuario);
      });
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

/// Obtiene TODOS los usuarios registrados localmente (activos e inactivos).
/// 
/// Útil para el selector de login, que debe mostrar a todos los usuarios
/// sin importar su estado, permitiendo al administrador elegir cualquier cuenta.
/// 
/// Parámetros:
///   - [localId]: Si se especifica, filtra los usuarios por ese local.
///                Si es null, devuelve todos los usuarios del dispositivo.
Future<List<UsuarioEntity>> obtenerTodosLosUsuarios({int? localId}) async {
  try {
    final isar = await db;
    if (localId != null) {
      return await isar.usuarioEntitys
          .filter()
          .localIdEqualTo(localId)
          .findAll();
    }
    return await isar.usuarioEntitys.where().findAll();
  } catch (e, stack) {
    ErrorService.captureError(
      e,
      stack: stack,
      hint: 'obtenerTodosLosUsuarios_fallo',
      extras: {'localId': localId},
    );
    return [];
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

      // Buscamos por nombre (el PIN se valida en Dart, no en Isar,
      // porque puede estar hasheado con salt aleatorio).
      final candidatos = await isar.usuarioEntitys
          .filter()
          .nombreEqualTo(nombreNormalizado, caseSensitive: false)
          .findAll();

      for (final usuario in candidatos) {
        final storedPin = usuario.pin;
        if (storedPin.isEmpty) continue;

        // Caso 1: PIN ya hasheado → verificar con PinHasher
        if (PinHasher.isHashed(storedPin)) {
          if (PinHasher.verify(pinNormalizado, storedPin)) {
            return usuario;
          }
          continue;
        }

        // Caso 2: PIN en plano (legacy) → comparar y migrar en caliente
        if (storedPin == pinNormalizado) {
          usuario.pin = PinHasher.hashWithNewSalt(pinNormalizado);
          await isar.writeTxn(() async {
            await isar.usuarioEntitys.put(usuario);
          });
          debugPrint(
              '🔐 PIN migrado a hash para "${usuario.nombre}" (ID: ${usuario.id})');
          return usuario;
        }
      }

      return null;
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

  Future<bool> eliminarCategoriaFisica(int id) async {
  try {
    final isar = await db;
    return await isar.writeTxn(() async {
      return await isar.categoriaEntitys.delete(id);
    });
  } catch (e, stack) {
    ErrorService.captureError(e,
        stack: stack,
        hint: 'eliminarCategoriaFisica_fallo',
        extras: {'id': id});
    return false;
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
      // ⚠️ GUARD DE CÓDIGO VACÍO (Capa 1 de 2).
      //
      // `codigoBarras` está en un `@Index(unique: true)`. El constructor de
      // `ProductoEntity` lo deja en `''`, y tanto `ProductoEntity.fromJson`
      // como `sync_service` colapsan un `codigo_barras` nulo a `''`. Con dos
      // productos así, el segundo `put()` violaba el índice y —mientras el
      // índice tuvo `replace: true`— BORRABA al primero sin error ni aviso.
      //
      // Se deriva aquí una clave única en vez de dejar el hueco. Con el
      // `replace: false` de la Capa 2, un duplicado real que se colara por
      // otro camino da `IsarUniqueViolationError`, que sí se ve.
      //
      // El `trim()` cubre el caso "   " (espacios), que `isEmpty` no pilla.
      if (producto.codigoBarras.trim().isEmpty) {
        final uuid = producto.supabaseId;
        producto.codigoBarras = (uuid != null && uuid.isNotEmpty)
            ? 'SB-$uuid'
            : 'AUTO-${DateTime.now().microsecondsSinceEpoch}-'
                '${producto.nombre.hashCode.abs()}';
      }

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

  // ⚠️ `actualizarStockProducto` fue eliminado (Lote C).
  //
  //   No tenía NINGÚN caller (0 referencias fuera de su definición) y
  //   escribía `producto.stock` sin mirar los lotes. Era uno de los 11
  //   escritores ciegos que rompían la igualdad
  //   `producto.stock == SUM(lotes.cantidad_restante)`.
  //
  //   Para cambiar stock, usar `recalcularStockDe([id])` después de
  //   mover la cantidad en los lotes.

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
        venta.syncStatus =
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

  // ═══════════════════════════════════════════════════════════════
  // ANULACIONES DE VENTA
  // ═══════════════════════════════════════════════════════════════

  /// Registra la anulación de una venta.
  ///
  /// NO modifica la venta original. Solo inserta un registro nuevo.
 /* Future<void> guardarVentaAnulada(VentaAnuladaEntity anulacion) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.ventaAnuladaEntitys.put(anulacion);
    });
  }

  /// Devuelve la anulación de una venta específica (si existe).
  Future<VentaAnuladaEntity?> obtenerAnulacionDeVenta(String ventaIdOriginal) async {
    final isar = await db;
    return isar.ventaAnuladaEntitys
        .filter()
        .ventaIdOriginalEqualTo(ventaIdOriginal)
        .findFirst();
  }

  /// Lista de todas las anulaciones del tenant.
  Future<List<VentaAnuladaEntity>> obtenerVentasAnuladas(String tenantId) async {
    final isar = await db;
    return isar.ventaAnuladaEntitys
        .filter()
        .tenantIdEqualTo(tenantId)
        .sortByFechaAnulacionDesc()
        .findAll();
  }

  // ═══════════════════════════════════════════════════════════════
  // ANULACIONES DE GASTO
  // ═══════════════════════════════════════════════════════════════

  Future<void> guardarGastoAnulado(GastoAnuladoEntity anulacion) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.gastoAnuladoEntitys.put(anulacion);
    });
  }

  Future<GastoAnuladoEntity?> obtenerAnulacionDeGasto(int gastoIdOriginal) async {
    final isar = await db;
    return isar.gastoAnuladoEntitys
        .filter()
        .gastoIdOriginalEqualTo(gastoIdOriginal)
        .findFirst();
  }

  /// Devuelve los IDs de gastos anulados del tenant (para filtrar en UI).
  Future<Set<int>> obtenerIdsGastosAnulados(String tenantId) async {
    final isar = await db;
    final lista = await isar.gastoAnuladoEntitys
        .filter()
        .tenantIdEqualTo(tenantId)
        .findAll();
    return lista.map((a) => a.gastoIdOriginal).toSet();
  }
*/
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

   // ==================== CARRITOS EN ESPERA (PARK SALE) ====================

  /// Devuelve los CARRITOS APARCADOS de retail de un usuario.
  ///
  /// ⚠️ R.2: excluye las comandas de restaurante (`mesaId != null`). Se
  /// filtran en Dart y no con una segunda condición de Isar porque los
  /// métodos generados (`mesaIdIsNull()`) solo viven sobre la extensión
  /// `QFilterCondition`, y no se pueden encadenar dos condiciones.
  /// El volumen es pequeño, así que el coste es irrelevante.
  ///
  /// Las comandas se leen con `obtenerComandasDeLocal` o
  /// `obtenerComandaPorSessionId`.
  Future<List<CartSessionEntity>> obtenerSesionesDeUsuario(
      int usuarioId) async {
    try {
      final isar = await db;
      final sesiones = await isar.cartSessionEntitys
          .filter()
          .usuarioIdEqualTo(usuarioId)
          .findAll();

      // Ordenar: primero las más recientes
      sesiones.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return sesiones.where((s) => s.mesaId == null).toList();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerSesionesDeUsuario_fallo',
          extras: {'usuarioId': usuarioId});
      return [];
    }
  }

  // ============================================================
  // COMANDAS (restaurante · R.2)
  //
  // `CartSessionEntity` NO tiene campo `localId`: una comanda se ancla a
  // una MESA, y el local se deduce de esa mesa. Por eso el filtro por
  // local se resuelve en dos pasos (mesas del local → mesaIds).
  // ============================================================

  /// Comandas vivas (abiertas o enviadas) de las mesas de un local.
  ///
  /// Las comandas `cerrada` y `cancelada` se conservan en Isar (histórico)
  /// pero no se devuelven aquí.
  Future<List<CartSessionEntity>> obtenerComandasDeLocal(int localId) async {
    try {
      final mesas = await obtenerMesasDelLocal(localId);
      if (mesas.isEmpty) return [];

      final mesaIds = mesas.map((m) => m.id).toSet();

      final isar = await db;
      final comandas = await isar.cartSessionEntitys
          .filter()
          .mesaIdIsNotNull()
          .findAll();

      return comandas
          .where((c) => mesaIds.contains(c.mesaId))
          .where((c) =>
              c.comandaEstado == ComandaEstado.abierta ||
              c.comandaEstado == ComandaEstado.enviada)
          .toList();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerComandasDeLocal_fallo',
          extras: {'localId': localId});
      return [];
    }
  }

  /// Busca una comanda por su `sessionId` determinístico (`mesa:<id>`).
  ///
  /// Devuelve null si no existe O si ya no está viva (cerrada/cancelada).
  Future<CartSessionEntity?> obtenerComandaPorSessionId(
      String sessionId) async {
    try {
      final isar = await db;
      final comanda = await isar.cartSessionEntitys
          .filter()
          .sessionIdEqualTo(sessionId)
          .findFirst();
      if (comanda == null) return null;
      if (comanda.comandaEstado == ComandaEstado.cerrada ||
          comanda.comandaEstado == ComandaEstado.cancelada) {
        return null;
      }
      return comanda;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerComandaPorSessionId_fallo',
          extras: {'sessionId': sessionId});
      return null;
    }
  }

  /// Lee una comanda por su id de Isar, sea cual sea su estado.
  ///
  /// A diferencia de `obtenerComandaPorSessionId`, NO filtra comandas
  /// cerradas ni canceladas: el KDS necesita leer el histórico para
  /// validar transiciones. Quien decide si una comanda viva es
  /// `ComandasNotifier._avanzarEstado`.
  Future<CartSessionEntity?> obtenerComandaPorId(int id) async {
    try {
      final isar = await db;
      return await isar.cartSessionEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerComandaPorId_fallo',
          extras: {'id': id});
      return null;
    }
  }

  /// Guarda o actualiza una comanda.
  Future<int> guardarComanda(CartSessionEntity comanda) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        comanda.updatedAt = DateTime.now();
        // ⚠️ NO usar `createdAt ??= ...` aquí: en `CartSessionEntity` ese
        // campo es `DateTime` NO-nullable (con default `DateTime.now()`), a
        // diferencia de `DepartamentoEntity` donde sí es `DateTime?`.
        // Aquí el `??=` sería código muerto.
        return await isar.cartSessionEntitys.put(comanda);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarComanda_fallo',
          extras: {
            'comandaId': comanda.id,
            'sessionId': comanda.sessionId
          });
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // R.3 · KDS — ciclo de estados de los platos
  //
  // ⚠️ PATRÓN OBLIGATORIO PARA MODIFICAR UN ITEM:
  //
  // `CartSessionItem` es `@embedded`, NO una colección. Isar no puede
  // filtrar ni escribir un item suelto: hay que LEER la comanda entera,
  // mutar el array `items` en memoria y hacer `put()` de la comanda
  // COMPLETA dentro de un `writeTxn`. Por eso todos estos métodos
  // reciben (o devuelven) la comanda, nunca un item suelto.
  //
  // No existe `where().estadoPlatoEqualTo(...)`: `obtenerComandasConItemsEnCola`
  // filtra y ordena EN DART.
  // ═══════════════════════════════════════════════════════════════

  /// Estados en los que un plato sigue vivo en el KDS.
  static const estadosVisiblesEnKds = <EstadoPlato>{
    EstadoPlato.enCola,
    EstadoPlato.enPreparacion,
    EstadoPlato.listo,
  };

  /// Comandas del local con al menos un plato visible en el KDS.
  ///
  /// Orden FIFO: por el `enviadoACocinaAt` MÁS ANTIGUO de cada comanda
  /// (no por el de la comanda), que es lo que el cocinero necesita ver.
  ///
  /// ⚠️ `CartSessionEntity` NO tiene `localId`: la comanda se ancla a la
  /// MESA, así que el aislamiento por local se hace vía ids de mesas
  /// (`obtenerComandasDeLocal`), igual que en R.2. Y los items son
  /// `@embedded`, así que el filtro de `estadoPlato` va en DART: no
  /// existe `where().estadoPlatoEqualTo(...)`.
  Future<List<CartSessionEntity>> obtenerComandasConItemsEnCola(
      int localId) async {
    try {
      final comandas = await obtenerComandasDeLocal(localId);

      final conCola = comandas
          .where((c) => c.items
              .any((i) => estadosVisiblesEnKds.contains(i.estadoPlato)))
          .toList();

      conCola.sort(_compararPorColaAntigua);

      return conCola;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerComandasConItemsEnCola_fallo',
          extras: {'localId': localId});
      return [];
    }
  }

  /// FIFO: comanda cuya cola es más antigua primero.
  ///
  /// Las comandas sin `enviadoACocinaAt` (nunca enviadas) van al final, y
  /// a igual timestamp la más antigua por `createdAt`.
  static int _compararPorColaAntigua(
      CartSessionEntity a, CartSessionEntity b) {
    DateTime? masAntiguo(CartSessionEntity c) {
      DateTime? mejor;
      for (final i in c.items) {
        if (!estadosVisiblesEnKds.contains(i.estadoPlato)) continue;
        final t = i.enviadoACocinaAt;
        if (t == null) continue;
        if (mejor == null || t.isBefore(mejor)) mejor = t;
      }
      return mejor;
    }

    final ta = masAntiguo(a);
    final tb = masAntiguo(b);

    if (ta == null && tb == null) return a.createdAt.compareTo(b.createdAt);
    if (ta == null) return 1;
    if (tb == null) return -1;

    final cmp = ta.compareTo(tb);
    return cmp != 0 ? cmp : a.createdAt.compareTo(b.createdAt);
  }

  /// Cambia el `estadoPlato` de UN item y sella su timestamp.
  ///
  /// Devuelve `comandaId` si se escribió, o `-1` si falló (comanda ausente
  /// o `itemIndex` fuera de rango).
  ///
  /// ⚠️ NO valida la transición: eso es responsabilidad de
  /// `ComandasNotifier.transicionValida`. Aquí solo se ejecuta.
  Future<int> actualizarItemDeComanda(
    int comandaId,
    int itemIndex,
    EstadoPlato nuevo, {
    DateTime? timestamp,
  }) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        final comanda = await isar.cartSessionEntitys.get(comandaId);
        if (comanda == null) return -1;
        if (itemIndex < 0 || itemIndex >= comanda.items.length) return -1;

        final item = comanda.items[itemIndex];
        item.estadoPlato = nuevo;

        final cuando = timestamp ?? DateTime.now();
        switch (nuevo) {
          case EstadoPlato.pendiente:
            item.enviadoACocinaAt = null;
            item.preparacionIniciadaAt = null;
            item.listoAt = null;
            item.entregadoAt = null;
          case EstadoPlato.enCola:
            item.enviadoACocinaAt = cuando;
          case EstadoPlato.enPreparacion:
            item.preparacionIniciadaAt = cuando;
          case EstadoPlato.listo:
            item.listoAt = cuando;
          case EstadoPlato.entregado:
            item.entregadoAt = cuando;
          case EstadoPlato.cancelado:
            // Cancelar no sella ningún timestamp de cocina.
            break;
        }

        comanda.updatedAt = DateTime.now();
        await isar.cartSessionEntitys.put(comanda);
        return comanda.id;
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarItemDeComanda_fallo',
          extras: {
            'comandaId': comandaId,
            'itemIndex': itemIndex,
            'estado': nuevo.name,
          });
      return -1;
    }
  }

  /// Cambia la pausa de UN item, SIN tocar su `estadoPlato`.
  ///
  /// R.3.2. Deliberadamente separado de `actualizarItemDeComanda`:
  /// pausar y avanzar son ejes ortogonales (un plato puede estar
  /// `enPreparacion` Y pausado), así que un método único con 8
  /// parámetros opcionales sería imposible de leer.
  ///
  /// Al pausar (`pausado: true`) sella `pausadoEn`. Al reanudar limpia
  /// los tres campos de pausa.
  ///
  /// Devuelve `comandaId` si escribió, `-1` si falló.
  Future<int> actualizarPausaItem(
    int comandaId,
    int itemIndex, {
    required bool pausado,
    String? motivo,
  }) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        final comanda = await isar.cartSessionEntitys.get(comandaId);
        if (comanda == null) return -1;
        if (itemIndex < 0 || itemIndex >= comanda.items.length) return -1;

        final item = comanda.items[itemIndex];
        item.pausado = pausado;

        if (pausado) {
          item.pausadoEn = DateTime.now();
          item.motivoPausa = (motivo != null && motivo.trim().isNotEmpty)
              ? motivo.trim()
              : null;
        } else {
          item.pausadoEn = null;
          item.motivoPausa = null;
        }

        comanda.updatedAt = DateTime.now();
        await isar.cartSessionEntitys.put(comanda);
        return comanda.id;
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarPausaItem_fallo',
          extras: {
            'comandaId': comandaId,
            'itemIndex': itemIndex,
            'pausado': pausado,
          });
      return -1;
    }
  }

  /// Manda a la cola del KDS los platos que siguen `pendiente`.
  ///
  /// Idempotente por diseño: si no hay pendientes, no escribe nada.
  /// Devuelve cuántos platos entraron.
  Future<int> marcarPendientesComoEnCola(
      int comandaId, DateTime cuando) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        final comanda = await isar.cartSessionEntitys.get(comandaId);
        if (comanda == null) return 0;

        var marcados = 0;
        for (final item in comanda.items) {
          if (item.estadoPlato != EstadoPlato.pendiente) continue;
          item.estadoPlato = EstadoPlato.enCola;
          item.enviadoACocinaAt = cuando;
          marcados++;
        }

        if (marcados == 0) return 0;

        comanda.updatedAt = DateTime.now();
        await isar.cartSessionEntitys.put(comanda);
        return marcados;
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'marcarPendientesComoEnCola_fallo',
          extras: {'comandaId': comandaId});
      return 0;
    }
  }

  /// Elimina una comanda por id.
  ///
  /// R.2 no lo usa en el flujo normal (cancelar CONSERVA la comanda como
  /// histórico). Queda para limpieza futura.
  Future<bool> eliminarComanda(int id) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        return await isar.cartSessionEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarComanda_fallo', extras: {'id': id});
      return false;
    }
  }

  /// Marca el estado de sync de una comanda. Lo usa R.1b.
  Future<void> actualizarSyncStatusComanda(
      int id, bool sincronizado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final comanda = await isar.cartSessionEntitys.get(id);
        if (comanda != null) {
          comanda.sincronizado = sincronizado;
          comanda.fechaSincronizacion =
              sincronizado ? DateTime.now() : null;
          comanda.updatedAt = DateTime.now();
          await isar.cartSessionEntitys.put(comanda);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusComanda_fallo',
          extras: {'id': id});
    }
  }

  /// Cuenta cuántas sesiones tiene un usuario.
  Future<int> contarSesionesDeUsuario(int usuarioId) async {
    try {
      final isar = await db;
      return await isar.cartSessionEntitys
          .filter()
          .usuarioIdEqualTo(usuarioId)
          .count();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'contarSesionesDeUsuario_fallo',
          extras: {'usuarioId': usuarioId});
      return 0;
    }
  }

  /// Guarda o actualiza una sesión.
  Future<void> guardarSesion(CartSessionEntity sesion) async {
    try {
      final isar = await db;
      sesion.updatedAt = DateTime.now();
      await isar.writeTxn(() async {
        await isar.cartSessionEntitys.put(sesion);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarSesion_fallo',
          extras: {'sessionId': sesion.sessionId, 'usuarioId': sesion.usuarioId});
      rethrow;
    }
  }

  /// Elimina una sesión por su UUID.
  Future<bool> eliminarSesion(String sessionId) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        final sesion = await isar.cartSessionEntitys
            .filter()
            .sessionIdEqualTo(sessionId)
            .findFirst();
        if (sesion == null) return false;
        return await isar.cartSessionEntitys.delete(sesion.id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarSesion_fallo',
          extras: {'sessionId': sessionId});
      return false;
    }
  }

  /// Elimina TODAS las sesiones de un usuario.
  /// Se llama al cerrar sesión.
  Future<int> eliminarSesionesDeUsuario(int usuarioId) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        final sesiones = await isar.cartSessionEntitys
            .filter()
            .usuarioIdEqualTo(usuarioId)
            .findAll();
        if (sesiones.isEmpty) return 0;

        final ids = sesiones.map((s) => s.id).toList();
        return await isar.cartSessionEntitys.deleteAll(ids);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarSesionesDeUsuario_fallo',
          extras: {'usuarioId': usuarioId});
      return 0;
    }
  }

  /// Marca como abandonadas las sesiones con más de 24h.
  /// Se llama al cargar sesiones.
  Future<int> marcarSesionesAbandonadas(int usuarioId) async {
    try {
      final isar = await db;
      final limite = DateTime.now().subtract(const Duration(hours: 24));
      int actualizadas = 0;

      await isar.writeTxn(() async {
        final sesiones = await isar.cartSessionEntitys
            .filter()
            .usuarioIdEqualTo(usuarioId)
            .createdAtLessThan(limite)
            .findAll();

        for (final s in sesiones) {
          if (s.status != CartSessionStatus.abandonado) {
            s.status = CartSessionStatus.abandonado;
            await isar.cartSessionEntitys.put(s);
            actualizadas++;
          }
        }
      });

      return actualizadas;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'marcarSesionesAbandonadas_fallo',
          extras: {'usuarioId': usuarioId});
      return 0;
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

  Future<List<ClienteEntity>> obtenerClientes({
  bool soloActivos = true,
  bool soloFrecuentes = false,
}) async {
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

/// Busca clientes por nombre, teléfono, email, RIF, razón social
/// o documento (numérico).
///
/// ⚠️ `documento` cambió a `int?`. El filtro numérico se hace en Dart
/// sobre los resultados del filtro textual, para no perder performance
/// con un index extra.
Future<List<ClienteEntity>> buscarClientes(
  String query, {
  bool soloFrecuentes = false,
}) async {
  try {
    final isar = await db;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    // Intentar parsear como número (para búsqueda por documento)
    final qInt = int.tryParse(q);

    // 1️⃣ Filtro textual en Isar (nombre, teléfono, email)
    var filter = isar.clienteEntitys
        .filter()
        .nombreContains(q, caseSensitive: false)
        .or()
        .telefonoContains(q, caseSensitive: false)
        .or()
        .emailContains(q, caseSensitive: false);

    if (soloFrecuentes) {
      filter = filter.and().frecuenteEqualTo(true);
    }

    final porTexto = await filter.findAll();

    // 2️⃣ Filtro adicional en Dart para RIF, razón social y documento int
    //    (Isar no soporta `contains` sobre campos que no están indexados
    //    con esa estrategia; para listas cortas es aceptable)
    final todos = await isar.clienteEntitys
        .filter()
        .optional(soloFrecuentes, (f) => f.frecuenteEqualTo(true))
        .findAll();

    final porCamposExtra = todos.where((c) {
      final rif = (c.rif ?? '').toLowerCase();
      final razon = (c.razonSocial ?? '').toLowerCase();
      final docStr = c.documento?.toString() ?? '';

      final matchRif = rif.contains(q);
      final matchRazon = razon.contains(q);
      final matchDoc = qInt != null && c.documento == qInt;
      final matchDocStr = qInt == null && docStr.contains(q);

      return matchRif || matchRazon || matchDoc || matchDocStr;
    }).toList();

    // 3️⃣ Merge sin duplicados (por id)
    final vistos = <int>{};
    final resultado = <ClienteEntity>[];

    for (final c in [...porTexto, ...porCamposExtra]) {
      if (vistos.add(c.id)) {
        resultado.add(c);
      }
    }

    return resultado;
  } catch (e, stack) {
    ErrorService.captureError(e,
        stack: stack,
        hint: 'buscarClientes_fallo',
        extras: {'query': query, 'soloFrecuentes': soloFrecuentes});
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

  /// Borra TODAS las colecciones de Isar registradas en la instancia.
  ///
  /// Usado al crear un tenant nuevo (signup "Crear mi empresa") para no
  /// mezclar datos con el tenant anterior. Sin esto, el negocio nuevo
  /// hereda el catálogo/ventas/lotes del viejo — y como el JWT nuevo no
  /// los autoriza por RLS, el sync falla con `row-level security violation`.
  ///
  /// ⚠️ Por qué wipe y no borrado selectivo: la instancia de Isar es
  /// única para todos los tenants. `isar_service.dart:118` calcula el
  /// path como `isar_${prefs['empresa_id'] ?? 'default'}`, pero nadie
  /// escribe esa key → siempre resuelve `isar_default`. Un borrado
  /// selectivo dejaría residuos de tablas que hoy no figuran en el
  /// wipe y que volverían a filtrarse.
  ///
  /// 🔴 NO BORRAR `planEntitys` (catálogo global de la plataforma):
  /// `basico`/`pro`/`corporativo`/`trial` son de TODOS los tenants, no
  /// del negocio que se da de alta. Borrarlos deja a
  /// `planPorIdProvider` sin fuente y `featureFlagsProvider` cae en
  /// `planActivo = false`, que esconde el menú entero.
  ///
  /// ⚠️ `suscripcionEntitys` tampoco: es por tenant y
  /// `obtenerSuscripcion(tenantId)` ya filtra por `tenantId`.
  ///
  /// ⚠️ No rethrow: si una colección falla, se reporta a Sentry y se
  /// sigue. Dejar al usuario con datos stale es preferible a dejarlo
  /// sin cuenta creada.
  Future<void> wipeAll() async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await isar.ventaEntitys.clear();
        await isar.detalleVentaEntitys.clear();
        await isar.productoEntitys.clear();
        await isar.usuarioEntitys.clear();
        await isar.movimientoInventarioEntitys.clear();
        await isar.gastoEntitys.clear();
        await isar.logEntitys.clear();
        await isar.pedidoEntitys.clear();
        await isar.detallePedidoEntitys.clear();
        await isar.recepcionEntitys.clear();
        await isar.cartSessionEntitys.clear();
        await isar.turnoEntitys.clear();
        await isar.localEntitys.clear();
        await isar.proveedorEntitys.clear();
        await isar.codigoBarrasAliasEntitys.clear();
        await isar.loteEntitys.clear();
        await isar.departamentoEntitys.clear();
        await isar.telegramConfigEntitys.clear();
        await isar.categoriaEntitys.clear();
        await isar.marcaEntitys.clear();
        await isar.movimientoLoteEntitys.clear();
        await isar.clienteEntitys.clear();
        await isar.empleadoInfoEntitys.clear();
        await isar.horarioEntitys.clear();
        await isar.nominaPagoEntitys.clear();
        await isar.pagoVentaEntitys.clear();
        await isar.cotizacionMayorEntitys.clear();
        await isar.autorizacionDescuentoEntitys.clear();
        await isar.configDescuentoMayoristaEntitys.clear();
        await isar.ventaAnuladaEntitys.clear();
        await isar.gastoAnuladoEntitys.clear();
        await isar.mesaEntitys.clear();
        await isar.recetaEntitys.clear();
      });
      debugPrint('🧹 [wipeAll] Isar limpio (sin tocar planes ni suscripciones)');
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'wipeAll_fallo');
      debugPrint('⚠️ [wipeAll] Falló la limpieza: $e');
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

  /// Elimina los locales cuyo `supabaseId` NO está en [permitidos].
  ///
  /// 🎯 Por qué existe (2026-10-15)
  ///
  /// La policy `locales` tenía un segundo brazo que le devolvía los
  /// locales de todos los tenants al owner del SaaS. Esos locales
  /// quedaron cacheados en Isar de este dispositivo y, cuando el RLS
  /// se cerró, siguieron ahí: datos de otros tenants en una base local.
  ///
  /// ⚠️ Por qué NO se purga "lo que no sea el tenant del claim"
  ///
  /// El usuario puede tener varios locales legítimos (`usuarios_locales`
  /// le asigna uno por fila, y `mis_locales()` devuelve 2 para JAHTLABS).
  /// Borrar todo lo que no sea el claim DEJARÍA FUERA el local alterno y
  /// `setLocalActual()` fallaría al intentar cambiar a él, porque exige
  /// que el local exista en Isar.
  ///
  /// La lista blanca sale de `mis_locales()` — el mismo RPC que
  /// alimenta el selector de local — así que por construcción nunca
  /// borra un local al que el usuario tiene derecho, y sí borra el
  /// residuo de otras cuentas con las que se usó este dispositivo.
  ///
  /// Si [permitidos] viene vacío NO borra nada: una RPC caída por red no
  /// puede convertirse en un borrado masivo.
  ///
  /// Devuelve cuántos locales eliminó.
  Future<int> purgarLocalesFueraDe(Set<String> permitidos) async {
    if (permitidos.isEmpty) return 0;
    try {
      final isar = await db;
      final todos = await isar.localEntitys.where().findAll();

      final aBorrar = todos.where((l) {
        final sid = l.supabaseId;
        // Sin supabaseId no se puede Emiliar a qué tenant pertenece:
        // es residuo de una versión anterior y no se puede sincronizar.
        if (sid == null || sid.isEmpty) return true;
        return !permitidos.contains(sid);
      }).toList(growable: false);

      if (aBorrar.isEmpty) return 0;

      await isar.writeTxn(() async {
        await isar.localEntitys.deleteAll(aBorrar.map((l) => l.id).toList());
      });

      debugPrint(
        '🧹 [locales] Purgados ${aBorrar.length} local(es) fuera de '
        'mis_locales(): ${aBorrar.map((l) => l.nombre).join(', ')}',
      );
      return aBorrar.length;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'purgarLocalesFueraDe_fallo');
      return 0;
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

  /// Devuelve el local activo del tenant actual.
  ///
  /// Prioridad (de mayor a menor):
  ///   1. El local cuyo `id` coincide con `prefs['localActualId']`.
  ///      Es la ELECCIÓN EXPLÍCITA del usuario (hot-switch) y la fuente
  ///      más fresca: `local_actual_provider.setLocalActual` la escribe
  ///      ANTES de pedir el cambio de tenant en Supabase.
  ///   2. El local cuyo `supabaseId` coincide con el `tenant_id` del JWT.
  ///   3. El primer local `activo = true`.
  ///
  /// ⚠️ Por qué prefs va PRIMERO y no el JWT
  /// El hot-switch escribe prefs en `local_actual_provider.dart:152` y
  /// recién después refresca el tenant (`:159`). Durante esa ventana el
  /// JWT todavía apunta al local ANTERIOR. Con el orden inverso (JWT
  /// primero), este método devolvía el local viejo y además lo
  /// reactivaba con `local.activo = true`, resucitando justo el local
  /// que `marcarLocalComoActivo` acababa de desactivar. Resultado: dos
  /// locales activos y pedidos/lotes asignados al que el usuario dejó.
  ///
  /// 🎯 FIX previo: antes se usaba `sortByFechaSincronizacionDesc()`, que
  ///    era no determinístico entre syncs y no respetaba el tenant.
  Future<LocalEntity?> obtenerLocalActivo() async {
    try {
      final isar = await db;
      final prefs = await SharedPreferences.getInstance();

      // ── Prioridad 1: prefs['localActualId'] ──
      final idPrefs = prefs.getInt('localActualId');
      if (idPrefs != null && idPrefs > 0) {
        final local = await isar.localEntitys.get(idPrefs);
        if (local != null && local.activo) {
          return local;
        }
        debugPrint(
          '⚠️ [obtenerLocalActivo] localActualId=$idPrefs no válido. '
          'Cayendo a JWT.',
        );
      }

      // ── Prioridad 2: el tenant del JWT ──
      final tenantJwt = getTenantIdFromJWT();
      if (tenantJwt != null && tenantJwt.isNotEmpty) {
        final local = await isar.localEntitys
            .filter()
            .supabaseIdEqualTo(tenantJwt)
            .findFirst();

        if (local != null) {
          if (!local.activo) {
            debugPrint(
              '⚠️ [obtenerLocalActivo] Local "${local.nombre}" del JWT '
              'estaba inactivo. Reactivando.',
            );
            local.activo = true;
            await isar.writeTxn(() async {
              await isar.localEntitys.put(local);
            });
          }
          return local;
        }

        debugPrint(
          '⚠️ [obtenerLocalActivo] Sin local para tenant JWT $tenantJwt. '
          'Cayendo a primer activo.',
        );
      }

      // ── Prioridad 3: primer activo ──
      final fallback = await isar.localEntitys
          .filter()
          .activoEqualTo(true)
          .findFirst();

      if (fallback != null) {
        await prefs.setInt('localActualId', fallback.id);
        debugPrint(
          '⚠️ [obtenerLocalActivo] Fallback a "${fallback.nombre}" '
          '(id=${fallback.id})',
        );
      }

      return fallback;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerLocalActivo_fallo');
      return null;
    }
  }

  /// Marca un local como el único activo en Isar.
  ///
  /// Desactiva todos los demás locales y activa solo el indicado.
  /// Persiste el ID en `prefs['localActualId']` para coherencia.
  ///
  /// 🎯 FIX: antes no existía restricción unique en `LocalEntity.activo`,
  ///    así que podía haber 2+ locales con `activo = true` a la vez.
  /// Marca un local como activo.
  ///
  /// ⚠️ MULTI-LOCAL: desde el fix del hot-switch, esto **NO desactiva** los
  /// demás locales. Varios locales de un mismo tenant pueden estar activos
  /// a la vez.
  ///
  /// Antes este método dejaba un único local activo, lo que hacía desaparecer
  /// locales de la pestaña "Activos" cada vez que se cambiaba de local.
  /// `activo` significa "este local está habilitado", no "es el actual".
  ///
  /// El "local actual" vive en `LocalEntity.prefs['localActualId']` y en el
  /// estado de `localActualProvider`.
  Future<void> marcarLocalComoActivo(int id) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final local = await isar.localEntitys.get(id);
        if (local != null && !local.activo) {
          local.activo = true;
          local.updatedAt = DateTime.now();
          await isar.localEntitys.put(local);
        }
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('localActualId', id);

      debugPrint('✅ [IsarService] Local $id marcado como activo.');
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'marcarLocalComoActivo_fallo',
          extras: {'localId': id});
      rethrow;
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

  /// Asigna `departamentoId` a varios productos en un SOLO `writeTxn`.
///
/// R.3.2 · Onboarding del KDS: en vez de editar 200 productos uno a uno, se
/// dice "Bebidas → Barra" y se resuelve de golpe.
///
/// Por defecto SOLO toca los que tienen `departamentoId == null`, para no
/// pisar un trabajo previo. [sobrescribir] fuerza el reemplazo de todos.
///
/// `departamentoId` es `int?` a propósito: pasar `null` desasigna (deja el
/// producto como venta directa, fuera del KDS).
///
/// El filtro por `departamentoIdIsNull()` va DENTRO del método, y no en el
/// caller, para que la operación sea atómica: si el caller filtrara por su
/// cuenta, otro proceso podría cambiar un producto entre el filtro y el
/// `put()`.
///
/// Devuelve cuántos productos se modificaron.
Future<int> asignarDepartamentoAProductos(
  List<int> productoIds,
  int? departamentoId, {
  bool sobrescribir = false,
}) async {
  if (productoIds.isEmpty) return 0;

  try {
    final isar = await db;
    return await isar.writeTxn<int>(() async {
      var modificados = 0;

      for (final id in productoIds) {
        final producto = await isar.productoEntitys.get(id);
        if (producto == null) continue;
        if (!sobrescribir && producto.departamentoId != null) continue;

        producto.departamentoId = departamentoId;
        producto.updatedAt = DateTime.now();
        // ⚠️ `sincronizado = false` fuerza que el `SyncService` lo reevalúe
        // en el próximo push. El campo es local-only (no va en `toJson`),
        // así que hoy no sale nada, pero si R.1b añade la columna a Supabase
        // esto ya está preparado.
        producto.sincronizado = false;
        await isar.productoEntitys.put(producto);
        modificados++;
      }

      return modificados;
    });
  } catch (e, stack) {
    ErrorService.captureError(e,
        stack: stack,
        hint: 'asignarDepartamentoAProductos_fallo',
        extras: {
          'cantidad': productoIds.length,
          'departamentoId': departamentoId,
          'sobrescribir': sobrescribir,
        });
    return 0;
  }
}

/// Productos de una categoría concreta.
///
/// R.3.2 · Sostiene al bulk "asignar estaciones por categoría". Usa el filtro
/// generado (`categoriaIdEqualTo`), no Dart: `categoriaId` es un campo real
/// de `ProductoEntity`, así que la query es indexable.
Future<List<ProductoEntity>> obtenerProductosPorCategoriaId(
  int categoriaId,
) async {
  try {
    final isar = await db;
    return await isar.productoEntitys
        .filter()
        .categoriaIdEqualTo(categoriaId)
        .findAll();
  } catch (e, stack) {
    ErrorService.captureError(e,
        stack: stack,
        hint: 'obtenerProductosPorCategoriaId_fallo',
        extras: {'categoriaId': categoriaId});
    return [];
  }
}

/// Productos que aún NO tienen estación de preparación asignada.
///
/// R.3.2 · Sirve para que el KDS y el formulario de producto digan cuántos
/// quedan por configurar en vez de dejar al usuario adivinarlo.
Future<int> contarProductosSinEstacion() async {
  try {
    final isar = await db;
    return await isar.productoEntitys
        .filter()
        .departamentoIdIsNull()
        .count();
  } catch (e, stack) {
    ErrorService.captureError(e,
        stack: stack,
        hint: 'contarProductosSinEstacion_fallo');
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

  // ═══════════════════════════════════════════════════════════════
  // MESAS (restaurante · R.1)
  //
  // R.1b añadirá `obtenerMesasPendientesSync()` junto a los métodos de
  // subida/bajada a Supabase. Aquí solo hay CRUD local.
  // ═══════════════════════════════════════════════════════════════

  /// Guarda o actualiza una mesa.
  ///
  /// recalcula `claveUnica` antes de persistir: es el índice único que
  /// impide "Mesa 1" duplicada dentro del mismo local. Si el provider ya
  /// lo hizo, se vuelve a calcular aquí igual (es idempotente).
  Future<int> guardarMesa(MesaEntity mesa) async {
    try {
      final isar = await db;
      mesa.recalcularClaveUnica();
      return await isar.writeTxn<int>(() async {
        mesa.updatedAt = DateTime.now();
        mesa.createdAt ??= DateTime.now();
        return await isar.mesaEntitys.put(mesa);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarMesa_fallo',
          extras: {'mesaId': mesa.id, 'nombre': mesa.nombre});
      rethrow;
    }
  }

  Future<MesaEntity?> obtenerMesaPorId(int id) async {
    try {
      final isar = await db;
      return await isar.mesaEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerMesaPorId_fallo', extras: {'id': id});
      return null;
    }
  }

  /// Mesas del local, ordenadas por `ordenGrid` y luego por nombre.
  Future<List<MesaEntity>> obtenerMesasDelLocal(int localId) async {
    try {
      final isar = await db;
      final mesas = await isar.mesaEntitys
          .filter()
          .localIdEqualTo(localId)
          .sortByOrdenGrid()
          .thenByNombre()
          .findAll();
      return mesas;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerMesasDelLocal_fallo',
          extras: {'localId': localId});
      return [];
    }
  }

  /// true si el local ya tiene una mesa con ese `claveUnica`.
  ///
  /// `excluirId` permite editar una mesa sin que choque consigo misma.
  Future<bool> existeMesaConClave(String claveUnica, {int? excluirId}) async {
    try {
      final isar = await db;
      final existentes = await isar.mesaEntitys
          .filter()
          .claveUnicaEqualTo(claveUnica)
          .findAll();
      if (excluirId == null) return existentes.isNotEmpty;
      return existentes.any((m) => m.id != excluirId);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'existeMesaConClave_fallo',
          extras: {'claveUnica': claveUnica});
      // Ante duda, bloquear: es preferible un falso positivo que dejar
      // pasar dos mesas con el mismo nombre.
      return true;
    }
  }

  /// Elimina una mesa por id.
  ///
  /// La regla "solo si está libre" vive en `MesasProvider`, que es quien
  /// conoce el estado; aquí solo se ejecuta el borrado.
  Future<bool> eliminarMesa(int id) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        return await isar.mesaEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarMesa_fallo', extras: {'id': id});
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // R.4 · RECETAS
  // ═══════════════════════════════════════════════════════════════

  /// Guarda o actualiza una receta.
  ///
  /// El sello `createdAt`/`updatedAt` se pone aquí (no en la UI) para que
  /// sea imposible guardar una receta sin auditar. Mismo criterio que
  /// `guardarMesa`.
  ///
  /// ⚠️ Marca la receta como NO sincronizada. Sin esto, editar una receta
  /// que ya había subido dejaba `sincronizado` en `true` y el push la
  /// ignoraba para siempre: el cambio se veía en este dispositivo y en
  /// ningún otro.
  ///
  /// [marcarPendiente] existe para el PULL de `sync_service`, que escribe
  /// datos que vienen de la nube: ahí la receta ya está sincronizada y
  /// marcarla pendiente la haría empujarse sola en el siguiente ciclo,
  /// para siempre.
  Future<int> guardarReceta(
    RecetaEntity receta, {
    bool marcarPendiente = true,
  }) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        receta.updatedAt = DateTime.now();
        receta.createdAt ??= DateTime.now();
        if (marcarPendiente) receta.sincronizado = false;
        return await isar.recetaEntitys.put(receta);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarReceta_fallo',
          extras: {
            'recetaId': receta.id,
            'localId': receta.localId,
            'productoId': receta.productoId,
          });
      rethrow;
    }
  }

  /// Receta por id de Isar, o `null`.
  ///
  /// Lo usa el pull del sync: el `id_isar` de la nube es el id local del
  /// dispositivo que la creó, así que es la clave de cruce.
  Future<RecetaEntity?> obtenerRecetaPorId(int id) async {
    try {
      final isar = await db;
      return await isar.recetaEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerRecetaPorId_fallo',
          extras: {'id': id});
      return null;
    }
  }

  /// Recetas pendientes de subir.
  ///
  /// Filtra por `sincronizado == false`. `guardarReceta` es quien lo pone en
  /// `false`, incluso al editar una receta ya sincronizada.
  Future<List<RecetaEntity>> obtenerRecetasPendientesSync() async {
    try {
      final isar = await db;
      return await isar.recetaEntitys
          .filter()
          .sincronizadoEqualTo(false)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerRecetasPendientesSync_fallo');
      return [];
    }
  }

  /// Marca una receta como sincronizada, sin tocar `updatedAt`.
  ///
  /// ⚠️ Relee la fila dentro de la transacción. `items` es `@embedded`: si
  /// se hiciera `put` de una instancia vieja se perderían los ingredientes
  /// que se hubieran guardado mientras tanto.
  Future<void> marcarRecetaSincronizada(int id, {String? supabaseId}) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final receta = await isar.recetaEntitys.get(id);
        if (receta == null) return;
        receta.sincronizado = true;
        receta.fechaSincronizacion = DateTime.now();
        if (supabaseId != null && supabaseId.isNotEmpty) {
          receta.supabaseId = supabaseId;
        }
        await isar.recetaEntitys.put(receta);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'marcarRecetaSincronizada_fallo',
          extras: {'id': id});
    }
  }

  /// Receta del producto en ESTE local, o `null`.
  ///
  /// ⚠️ El filtro por `localId` va en DART a propósito. Isar 3 no compone
  /// índices, así que la alternativa sería un índice único sobre
  /// `productoId`, que está descartado: los ids de producto son locales a
  /// cada base y dos sucursales pueden tener el producto 7 con recetas
  /// distintas. El coste es traer todas las recetas del producto y quedarse
  /// con la del local: un producto tiene poquísimas recetas (una), así que
  /// la lista es de tamaño 1–2 en el caso normal.
  Future<RecetaEntity?> obtenerRecetaPorProducto(
    int localId,
    int productoId,
  ) async {
    try {
      final isar = await db;
      final candidatas = await isar.recetaEntitys
          .filter()
          .productoIdEqualTo(productoId)
          .findAll();

      for (final receta in candidatas) {
        if (receta.localId == localId) return receta;
      }
      return null;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerRecetaPorProducto_fallo',
          extras: {'localId': localId, 'productoId': productoId});
      return null;
    }
  }

  /// Todas las recetas del local, por nombre de plato.
  ///
  /// Se filtran solo las ACTIVAS. La UI de G.2 quiere las activas; las
  /// inactivas se consultan por `obtenerRecetaPorProducto` si alguna vez
  /// hay que editarlas.
  Future<List<RecetaEntity>> obtenerRecetasDelLocal(int localId) async {
    try {
      final isar = await db;
      return await isar.recetaEntitys
          .filter()
          .localIdEqualTo(localId)
          .activoEqualTo(true)
          .sortByNombrePlato()
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerRecetasDelLocal_fallo',
          extras: {'localId': localId});
      return [];
    }
  }

  /// Elimina una receta por id.
  ///
  /// Devuelve `false` si no existía o si Isar falló, en vez de tragarse el
  /// error: el caller tiene que poder distinguir "no había nada" de "no se
  /// pudo borrar" para no mostrar un "borrado" que no ocurrió.
  Future<bool> eliminarReceta(int id) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        return await isar.recetaEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'eliminarReceta_fallo', extras: {'id': id});
      return false;
    }
  }

  /// Productos marcados como ingrediente en este local.
  ///
  /// Solo `esIngrediente == true`: los `null` (nunca revisados) y los
  /// `false` (revisados y descartados) quedan fuera, que es justo lo que
  /// hace útil `esIngrediente` como `bool?` en vez de `bool`.
  ///
  /// ⚠️ `ProductoEntity` NO tiene `localId`: el aislamiento por local se
  /// hace igual que en `obtenerComandasDeLocal`, vía el filtro de la UI. Por
  /// eso este método recibe el id pero no lo usa en la query.
  Future<List<ProductoEntity>> obtenerIngredientes(int localId) async {
    try {
      final isar = await db;
      return await isar.productoEntitys
          .filter()
          .esIngredienteEqualTo(true)
          .activoEqualTo(true)
          .sortByNombre()
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerIngredientes_fallo',
          extras: {'localId': localId});
      return [];
    }
  }

  Future<void> actualizarSyncStatusMesa(int id, bool sincronizado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final mesa = await isar.mesaEntitys.get(id);
        if (mesa != null) {
          mesa.sincronizado = sincronizado;
          mesa.fechaSincronizacion = sincronizado ? DateTime.now() : null;
          mesa.updatedAt = DateTime.now();
          await isar.mesaEntitys.put(mesa);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusMesa_fallo',
          extras: {'id': id});
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

  // ==================== PAGOS DE VENTA (Wholesale) ====================

  Future<int> guardarPagoVenta(PagoVentaEntity pago) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        return await isar.pagoVentaEntitys.put(pago);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarPagoVenta_fallo',
          extras: {'ventaIdFk': pago.ventaIdFk, 'metodo': pago.metodo});
      rethrow;
    }
  }

  Future<List<PagoVentaEntity>> obtenerPagosPorVenta(int ventaIdFk) async {
    try {
      final isar = await db;
      return await isar.pagoVentaEntitys
          .filter()
          .ventaIdFkEqualTo(ventaIdFk)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerPagosPorVenta_fallo',
          extras: {'ventaIdFk': ventaIdFk});
      return [];
    }
  }

  Future<List<PagoVentaEntity>> obtenerPagosPorVentaSupabaseId(
      String ventaSupabaseId) async {
    try {
      if (ventaSupabaseId.isEmpty) return [];
      final isar = await db;
      return await isar.pagoVentaEntitys
          .filter()
          .ventaSupabaseIdEqualTo(ventaSupabaseId)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerPagosPorVentaSupabaseId_fallo',
          extras: {'ventaSupabaseId': ventaSupabaseId});
      return [];
    }
  }

  Future<List<PagoVentaEntity>> obtenerPagosVentaPendientesSync() async {
    try {
      final isar = await db;
      return await isar.pagoVentaEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .or()
          .syncStatusEqualTo('failed')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerPagosVentaPendientesSync_fallo');
      return [];
    }
  }

  Future<void> actualizarSyncStatusPagoVenta(int id, String nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final pago = await isar.pagoVentaEntitys.get(id);
        if (pago != null) {
          pago.syncStatus = nuevoEstado;
          pago.updatedAt = DateTime.now();
          await isar.pagoVentaEntitys.put(pago);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusPagoVenta_fallo',
          extras: {'id': id, 'nuevoEstado': nuevoEstado});
      rethrow;
    }
  }


    // ==================== COTIZACIONES MAYOR ====================

  Future<int> guardarCotizacion(CotizacionMayorEntity cotizacion) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        cotizacion.updatedAt = DateTime.now();
        cotizacion.createdAt ??= DateTime.now();
        return await isar.cotizacionMayorEntitys.put(cotizacion);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarCotizacion_fallo',
          extras: {'numero': cotizacion.numero});
      rethrow;
    }
  }

  Future<List<CotizacionMayorEntity>> obtenerCotizaciones(
      {String? estado}) async {
    try {
      final isar = await db;
      List<CotizacionMayorEntity> lista;
      if (estado == null || estado.isEmpty) {
        lista = await isar.cotizacionMayorEntitys.where().findAll();
      } else {
        lista = await isar.cotizacionMayorEntitys
            .filter()
            .estadoEqualTo(estado)
            .findAll();
      }
      // Ordenar en Dart (fechaEmision no tiene @Index)
      lista.sort((a, b) => b.fechaEmision.compareTo(a.fechaEmision));
      return lista;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerCotizaciones_fallo');
      return [];
    }
  }

  Future<CotizacionMayorEntity?> obtenerCotizacionPorId(int id) async {
    try {
      final isar = await db;
      return await isar.cotizacionMayorEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerCotizacionPorId_fallo',
          extras: {'id': id});
      return null;
    }
  }

  Future<CotizacionMayorEntity?> obtenerCotizacionPorSupabaseId(
      String supabaseId) async {
    try {
      if (supabaseId.isEmpty) return null;
      final isar = await db;
      return await isar.cotizacionMayorEntitys
          .filter()
          .supabaseIdEqualTo(supabaseId)
          .findFirst();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerCotizacionPorSupabaseId_fallo',
          extras: {'supabaseId': supabaseId});
      return null;
    }
  }

  Future<List<CotizacionMayorEntity>> obtenerCotizacionesPendientesSync() async {
    try {
      final isar = await db;
      return await isar.cotizacionMayorEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .or()
          .syncStatusEqualTo('failed')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerCotizacionesPendientesSync_fallo');
      return [];
    }
  }

  Future<void> actualizarSyncStatusCotizacion(int id, String nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final cot = await isar.cotizacionMayorEntitys.get(id);
        if (cot != null) {
          cot.syncStatus = nuevoEstado;
          cot.updatedAt = DateTime.now();
          await isar.cotizacionMayorEntitys.put(cot);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusCotizacion_fallo',
          extras: {'id': id, 'nuevoEstado': nuevoEstado});
      rethrow;
    }
  }

  Future<bool> eliminarCotizacion(int id) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        return await isar.cotizacionMayorEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarCotizacion_fallo',
          extras: {'id': id});
      return false;
    }
  }

  /// Genera el próximo número de cotización con formato COT-YYYY-NNNN.
  ///
  /// Revisa todas las cotizaciones del año actual y devuelve el siguiente
  /// correlativo. Si algo falla, devuelve un fallback con timestamp.
  Future<String> generarNumeroCotizacion() async {
    try {
      final isar = await db;
      final anio = DateTime.now().year;
      final prefijo = 'COT-$anio-';

      final todas = await isar.cotizacionMayorEntitys
          .filter()
          .numeroStartsWith(prefijo)
          .findAll();

      int maxNum = 0;
      for (final c in todas) {
        final partes = c.numero.split('-');
        if (partes.length >= 3) {
          final num = int.tryParse(partes[2]);
          if (num != null && num > maxNum) maxNum = num;
        }
      }

      final siguiente = (maxNum + 1).toString().padLeft(4, '0');
      return '$prefijo$siguiente';
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'generarNumeroCotizacion_fallo');
      // Fallback: timestamp
      final ts = DateTime.now().millisecondsSinceEpoch % 10000;
      return 'COT-${DateTime.now().year}-${ts.toString().padLeft(4, '0')}';
    }
  }
  // ==================== CONFIG DESCUENTOS MAYORISTAS ====================

  Future<int> guardarConfigDescuento(
      ConfigDescuentoMayoristaEntity config) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        config.updatedAt = DateTime.now();
        config.createdAt;
        return await isar.configDescuentoMayoristaEntitys.put(config);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarConfigDescuento_fallo',
          extras: {'nombre': config.nombre});
      rethrow;
    }
  }

  Future<List<ConfigDescuentoMayoristaEntity>> obtenerConfigDescuentos(
      {bool soloActivos = true}) async {
    try {
      final isar = await db;
      if (soloActivos) {
        return await isar.configDescuentoMayoristaEntitys
            .filter()
            .activoEqualTo(true)
            .findAll();
      }
      return await isar.configDescuentoMayoristaEntitys.where().findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerConfigDescuentos_fallo');
      return [];
    }
  }

  Future<ConfigDescuentoMayoristaEntity?> obtenerConfigDescuentoPorId(
      int id) async {
    try {
      final isar = await db;
      return await isar.configDescuentoMayoristaEntitys.get(id);
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerConfigDescuentoPorId_fallo',
          extras: {'id': id});
      return null;
    }
  }

  Future<bool> eliminarConfigDescuento(int id) async {
    try {
      final isar = await db;
      return await isar.writeTxn(() async {
        return await isar.configDescuentoMayoristaEntitys.delete(id);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'eliminarConfigDescuento_fallo',
          extras: {'id': id});
      return false;
    }
  }

  Future<List<ConfigDescuentoMayoristaEntity>>
      obtenerConfigDescuentosPendientesSync() async {
    try {
      final isar = await db;
      return await isar.configDescuentoMayoristaEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .or()
          .syncStatusEqualTo('failed')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerConfigDescuentosPendientesSync_fallo');
      return [];
    }
  }

  Future<void> actualizarSyncStatusConfigDescuento(
      int id, String nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final config = await isar.configDescuentoMayoristaEntitys.get(id);
        if (config != null) {
          config.syncStatus = nuevoEstado;
          config.updatedAt = DateTime.now();
          await isar.configDescuentoMayoristaEntitys.put(config);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusConfigDescuento_fallo',
          extras: {'id': id, 'nuevoEstado': nuevoEstado});
      rethrow;
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

  /// Recalcula `producto.stock` de cada id como `SUM(lotes activos)`.
  ///
  /// **Modelo: lotes es la fuente única de verdad.** `producto.stock` es
  /// un cache derivado. TODO cambio de `lotes.cantidad_restante` debe
  /// terminar llamando a este método para los productos afectados.
  ///
  /// Antes cada sitio hacía su propio `producto.stock = ...` a ciegas y
  /// había 14 escritores distintos, 11 de los cuales ignoraban los
  /// lotes. Eso producía dos verdades en conflicto: la UI muestra
  /// `producto.stock` mientras la validación de venta usa
  /// `SUM(lotes)`.
  ///
  /// Un solo `writeTxn` para todos los ids: si algo falla, no hay
  /// actualización parcial.
  Future<void> recalcularStockDe(List<int> productoIds) async {
    if (productoIds.isEmpty) return;
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        for (final id in productoIds) {
          final lotes = await isar.loteEntitys
              .filter()
              .productoIdEqualTo(id)
              .estadoEqualTo('activo')
              .findAll();
          final nuevoStock = lotes.fold<double>(
              0.0, (sum, lote) => sum + lote.cantidadRestante);
          final producto = await isar.productoEntitys.get(id);
          if (producto == null) continue;
          if (producto.stock == nuevoStock) continue;
          producto.stock = nuevoStock;
          await isar.productoEntitys.put(producto);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'recalcularStockDe_fallo',
          extras: {'productoIds': productoIds});
    }
  }

  Future<List<LoteEntity>> obtenerLotesPorProducto(int productoId) async {
    if (productoId <= 0) return [];
    final isar = await db;
    return await isar.loteEntitys
        .filter()
        .productoIdEqualTo(productoId)
        .findAll();
  }

  ///
  /// [localId] filtra por local. ⚠️ NO es decorativo: con 2 locales en el
  /// mismo dispositivo, sin este filtro el FEFO de la caja descuenta del
  /// lote del OTRO local, que no es el que está vendiendo esta pantalla.
  /// `LoteEntity.localId == null` (lotes legacy, anteriores al
  /// multi-local) se admite igual: negarles el stock dejaría sin vender a
  /// los datos viejos.
  Future<List<LoteEntity>> obtenerLotesActivos(
    int productoId, {
    bool priorizarVencimiento = true,
    int? localId,
  }) async {
    try {
      final isar = await db;
      var query = isar.loteEntitys
          .filter()
          .productoIdEqualTo(productoId)
          .estadoEqualTo('activo')
          .and()
          .cantidadRestanteGreaterThan(0);
      if (localId != null) {
        query = query.and().group((q) => q
            .localIdEqualTo(localId)
            .or()
            .localIdIsNull());
      }
      final lotes = await query.findAll();

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

  // ═══════════════════════════════════════════════════════════════
  // DESCUENTO ATÓMICO DE LOTES · venta retail y consumo de recetas
  // ═══════════════════════════════════════════════════════════════
  //
  // Hasta aquí el descuento de stock eran N `writeTxn` independientes
  // (`descontarLote`, uno por lote) y el alta de la venta en otra más. Un
  // fallo a mitad dejaba stock descontado sin venta (o al revés): es la
  // deuda "procesarVenta no tiene transacción" de `docs/TODO.md`.
  //
  // Contrato nuevo (2 pasos):
  //   1. `planificarDescuentoLotes` calcula el reparto FEFO con una
  //      LECTURA y no escribe nada. El caller valida (retail aborta si
  //      hay faltante; el KDS no, se avisa).
  //   2. `registrarVentaConDescuento` (venta) o `aplicarDescuentosLotes`
  //      (KDS) ejecutan descuentos + recalculos de stock + alta de la
  //      venta/movimientos en UNA sola transacción. `descontarLote` sigue
  //      existiendo para los callers que pagan el precio de su
  //      fragmentación (ajustes, anulaciones), pero los caminos de venta
  //      ya no lo usan.

  /// Mismo umbral que `VentaCalculator.cantidadEsCero` (0.001).
  ///
  /// No se importa el calculator a propósito: es de la capa de
  /// presentación y `isar_service` es data/dominio. Duplicar 1 constante
  /// vale la pena para no invertir la flecha de dependencias.
  static const double _toleranciaCantidad = 0.001;

  /// Calcula el reparto FEFO para descontar [cantidad] del producto
  /// [productoId], SOLO LECTURA.
  ///
  /// Devuelve un plan de lotes y, si no alcanzó, [PlanificacionLote].
  /// es quien dice cuánto faltó. El caller decide qué hacer con él:
  ///   · venta retail: abortar antes de tocar NADA.
  ///   · KDS: aplicar lo que haya y avisar (Q3).
  ///
  /// Con `localId` el FEFO solo usa lotes de ese local (o legacy sin
  /// local); ver `obtenerLotesActivos`.
  ///
  /// El plan es un SNAPSHOT de una lectura. Aplicarlo revalida cada lote
  /// dentro de la transacción: si otra caja del mismo dispositivo movió
  /// el lote entretanto, la transacción aborta.
  Future<PlanificacionLote> planificarDescuentoLotes({
    required int productoId,
    required double cantidad,
    int? localId,
  }) async {
    if (cantidad <= _toleranciaCantidad) {
      // Residuo de redondeo (o un dato raro con negativo): no hay nada
      // que planificar. Mismo criterio que `cantidadEsCero`.
      return PlanificacionLote(
        productoId: productoId,
        faltante: 0,
        plan: const [],
      );
    }

    final lotes = await obtenerLotesActivos(
      productoId,
      priorizarVencimiento: true,
      localId: localId,
    );

    final plan = <DescuentoLotePlan>[];
    var pendiente = cantidad;
    for (final lote in lotes) {
      if (pendiente <= _toleranciaCantidad) break;
      final aDescontar = pendiente > lote.cantidadRestante
          ? lote.cantidadRestante
          : pendiente;
      if (aDescontar <= _toleranciaCantidad) continue;
      plan.add(DescuentoLotePlan(
        loteId: lote.id,
        productoId: productoId,
        cantidad: aDescontar,
      ));
      pendiente -= aDescontar;
    }

    final faltante = pendiente <= _toleranciaCantidad ? 0.0 : pendiente;
    return PlanificacionLote(
      productoId: productoId,
      faltante: faltante,
      plan: plan,
    );
  }

  /// Aplica [plan] en UNA transacción: descuenta los lotes, recalcula el
  /// stock desde ellos y guarda [movimientos] con `stockResultante` REAL
  /// (leído del producto ya actualizado, no del valor que traía).
  ///
  /// Si un lote ya no tiene lo que el plan prometió, lanza
  /// `StockInsuficienteException` y la transacción entera se descarta:
  /// ni un lote ni un movimiento quedan a medio camino.
  ///
  /// Es el camino del KDS (`comanda_provider._descontarRecetaDeItem`),
  /// donde el faltante se tolera (Q3): el plan que llega acá ya se
  /// construyó con los faltantes separados.
  Future<void> aplicarDescuentosLotes({
    required List<DescuentoLotePlan> plan,
    List<MovimientoInventarioEntity> movimientos = const [],
  }) async {
    try {
      final isar = await db;
      if (plan.isEmpty && movimientos.isEmpty) return;

      await isar.writeTxn(() async {
        await _descontarPlanEnTransaccion(isar, plan);

        final afectados = <int>{...plan.map((p) => p.productoId)};
        for (final mov in movimientos) {
          afectados.add(mov.productoId);
        }
        await _recalcularStockEnTransaccion(isar, afectados.toList());

        for (final mov in movimientos) {
          mov.syncStatus =
              mov.syncStatus.isEmpty ? 'pending' : mov.syncStatus;
          final producto = await isar.productoEntitys.get(mov.productoId);
          mov.stockResultante = producto?.stock ?? 0.0;
          await isar.movimientoInventarioEntitys.put(mov);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'aplicarDescuentosLotes_fallo',
          extras: {
            'pasos': plan.length,
            'movimientos': movimientos.length,
          });
      rethrow;
    }
  }

  /// La venta completa en UNA transacción: descuento del plan + recálculo
  /// de stock + alta de la venta con sus detalles. O queda TODO, o no
  /// queda NADA.
  ///
  /// Reemplaza la secuencia `descontarLote` × N → `recalcularStockDe` →
  /// `guardarVenta`, que eran 3 grupos de transacciones distintas: si
  /// `guardarVenta` fallaba, el stock ya estaba consumido sin venta que
  /// lo justifique.
  ///
  /// El alta de la venta replica EXACTAMENTE la de `guardarVenta`
  /// (normalizar `syncStatus`, asignar `ventaIdFk` a los detalles): era la
  /// única escritura real de ese método; aquí no puede llamarlo a sí
  /// mismo porque `writeTxn` anidado no existe en Isar 3.
  Future<void> registrarVentaConDescuento({
    required VentaEntity venta,
    List<DetalleVentaEntity> detalles = const [],
    required List<DescuentoLotePlan> plan,
  }) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        await _descontarPlanEnTransaccion(isar, plan);
        await _recalcularStockEnTransaccion(
          isar,
          plan.map((p) => p.productoId).toSet().toList(),
        );

        venta.syncStatus = (venta.syncStatus?.isEmpty ?? true)
            ? 'pending'
            : venta.syncStatus;
        await isar.ventaEntitys.put(venta);

        for (var item in detalles) {
          item.ventaIdFk ??= venta.idSupabase;
        }
        if (detalles.isNotEmpty) {
          await isar.detalleVentaEntitys.putAll(detalles);
        }
      });
      debugPrint('✅ Venta guardada con éxito (atómica). ID: ${venta.id}');
    } catch (e, stackTrace) {
      ErrorService.captureError(
        e,
        stack: stackTrace,
        hint: 'registrarVentaConDescuento_fallo',
        extras: {
          'ventaId': venta.id,
          'total': venta.total,
          'detallesCount': detalles.length,
          'pasosPlan': plan.length,
          'usuario': venta.empleado,
        },
      );
      debugPrint('❌ Error en la venta atómica: $e');
      rethrow;
    }
  }

  /// Descuenta el plan revalidando CADA lote dentro de la transacción.
  ///
  /// Misma física que `descontarLote` (0 exacto pasa a `agotado`,
  /// `sincronizado = false`), pero sin abrir `writeTxn`: el caller ya está
  /// dentro de una. `writeTxn` anidado no existe en Isar 3.
  Future<void> _descontarPlanEnTransaccion(
    Isar isar,
    List<DescuentoLotePlan> plan,
  ) async {
    for (final paso in plan) {
      if (paso.cantidad <= _toleranciaCantidad) continue;

      final lote = await isar.loteEntitys.get(paso.loteId);
      if (lote == null) {
        throw StockInsuficienteException(
          loteId: paso.loteId,
          productoId: paso.productoId,
          disponible: 0,
          requerido: paso.cantidad,
        );
      }
      if (lote.cantidadRestante < paso.cantidad - _toleranciaCantidad) {
        throw StockInsuficienteException(
          loteId: paso.loteId,
          productoId: paso.productoId,
          disponible: lote.cantidadRestante,
          requerido: paso.cantidad,
        );
      }

      lote.cantidadRestante -= paso.cantidad;
      if (lote.cantidadRestante <= _toleranciaCantidad) {
        lote.cantidadRestante = 0;
        lote.estado = 'agotado';
      }
      lote.sincronizado = false;
      await isar.loteEntitys.put(lote);
    }
  }

  /// Recálculo de `producto.stock` desde los lotes, ya dentro de una
  /// transacción (idéntico al cuerpo de `recalcularStockDe`, sin `txn`).
  ///
  /// NO filtra por `localId` a propósito: `ProductoEntity` no tiene local
  /// y el stock derivado suma TODOS los lotes activos del producto
  /// (incluidos los legacy con `localId = null`).
  Future<void> _recalcularStockEnTransaccion(
    Isar isar,
    List<int> productoIds,
  ) async {
    for (final id in productoIds) {
      final lotes = await isar.loteEntitys
          .filter()
          .productoIdEqualTo(id)
          .estadoEqualTo('activo')
          .findAll();
      final nuevoStock = lotes.fold<double>(
          0.0, (sum, lote) => sum + lote.cantidadRestante);
      final producto = await isar.productoEntitys.get(id);
      if (producto == null) continue;
      if (producto.stock == nuevoStock) continue;
      producto.stock = nuevoStock;
      await isar.productoEntitys.put(producto);
    }
  }

  /// Ajusta el stock TOTAL de un producto al valor `stockObjetivo`,
  /// distribuyendo el delta entre lotes activos.
  ///
  /// Modelo: lotes = fuente única de verdad. Existe para que el editor
  /// de productos (el textbox de stock) NO escriba `producto.stock`
  /// directo: convierte el valor deseado en operaciones sobre lotes.
  ///
  /// - delta > 0 → suma al lote activo más antiguo, o crea uno si no hay.
  /// - delta < 0 → descuenta lotes en orden FEFO. Falla si no alcanza.
  /// - Al final recalcula el cache derivado (`producto.stock`).
  ///
  /// Retorna `true` si el ajuste se aplicó, `false` si el descuento no
  /// alcanzó o si hubo un error.
  ///
  /// ⚠️ `LoteEntityQuerySortBy` no expone `sortById()` (Isar no genera
  /// un ordenador para el `Id` implícito), así que ambos caminos
  /// ordenan en Dart.
  Future<bool> ajustarStockDesdeEditor({
    required int productoId,
    required double stockObjetivo,
    required int usuarioId,
    String? motivo,
  }) async {
    try {
      final stockActual = await obtenerStockTotalPorProducto(productoId);
      final delta = stockObjetivo - stockActual;

      // Tolerancia para errores de coma flotante (0.1 + 0.2 != 0.3).
      if (delta.abs() < 0.0001) {
        return true;
      }

      // El lote necesita `localId` para que, al subirlo,
      // `sincronizarLotesPendientes` resuelva el `tenant_id`. Sin esto
      // el lote se crearía con `localId = null` → `tenant_id = null` al
      // subir → RLS lo rechaza y el ajuste de inventario se pierde
      // silenciosamente en la nube.
      final localActivo = await obtenerLocalActivo();
      final int? localIdActivo = localActivo?.id;

      if (delta > 0) {
        // Sumar al primer lote activo (orden estable por id), o crear
        // uno si el producto no tiene lotes todavía.
        final isar = await db;
        await isar.writeTxn(() async {
          final lotes = await isar.loteEntitys
              .filter()
              .productoIdEqualTo(productoId)
              .estadoEqualTo('activo')
              .findAll();
          lotes.sort((a, b) => a.id.compareTo(b.id));

          if (lotes.isEmpty) {
            final lote = LoteEntity()
              ..productoId = productoId
              ..cantidadInicial = delta
              ..cantidadRestante = delta
              ..estado = 'activo'
              ..codigoLoteProveedor =
                  'EDIT-${DateTime.now().millisecondsSinceEpoch}'
              ..localId = localIdActivo
              ..sincronizado = false;
            await isar.loteEntitys.put(lote);

            // Alta de stock desde el editor: el lote nace con
            // `inicial == restante`, así que el invariante
            // `restante <= inicial` ya se cumple. Se registra igual
            // para que el lote `EDIT-` no aparezca en el historial sin
            // origen explicado.
            await isar.movimientoLoteEntitys.put(
              MovimientoLoteEntity()
                ..loteId = lote.id
                ..tipo = 'reposicion'
                ..cantidad = delta
                ..stockAntes = stockActual
                ..stockDespues = stockObjetivo
                ..fecha = DateTime.now()
                ..usuarioId = usuarioId
                ..observaciones = motivo
                ..sincronizado = false,
            );
          } else {
            final lote = lotes.first;
            lote.cantidadRestante += delta;

            // ⚠️ Clamp de Opción A: `cantidadInicial` sube junto con
            // `cantidadRestante`.
            //
            // Sin esto, editar el stock hacia arriba solo acumulaba sobre
            // `restante` y dejaba `restante > inicial`. Así se explican
            // los tres casos medidos en la nube, todos con
            // `inicial = 100`:
            //   · Arroz       → 512   (se tipeó 512)
            //   · 133cf99a    → 200   (se tipeó 200)
            //   · 20680fa5    → 150   (se tipeó 150)
            //
            // Con el clamp, `inicial` deja de ser "lo que llegó del
            // proveedor" y pasa a ser "lo recibido + reposiciones". Es la
            // semántica correcta bajo el modelo "lotes = fuente única":
            // el lote es un acumulador del producto, no un acta de
            // recepción. Y `producto.stock` no cambia: `recalcularStockDe`
            // lo recalcula como `SUM(restante)` más abajo.
            lote.cantidadInicial += delta;
            lote.sincronizado = false;
            await isar.loteEntitys.put(lote);

            await isar.movimientoLoteEntitys.put(
              MovimientoLoteEntity()
                ..loteId = lote.id
                ..tipo = 'reposicion'
                ..cantidad = delta
                ..stockAntes = stockActual
                ..stockDespues = stockObjetivo
                ..fecha = DateTime.now()
                ..usuarioId = usuarioId
                ..observaciones = motivo
                ..sincronizado = false,
            );
          }
        });
      } else {
        // delta < 0 → descontar FEFO.
        double restante = -delta;
        final isar = await db;
        final lotes = await isar.loteEntitys
            .filter()
            .productoIdEqualTo(productoId)
            .estadoEqualTo('activo')
            .findAll();

        // Orden FEFO manual: vencimiento más próximo primero, nulos al
        // final, desempate por id.
        lotes.sort((a, b) {
          final fa = a.fechaVencimiento;
          final fb = b.fechaVencimiento;
          if (fa == null && fb == null) return a.id.compareTo(b.id);
          if (fa == null) return 1;
          if (fb == null) return -1;
          final cmp = fa.compareTo(fb);
          return cmp != 0 ? cmp : a.id.compareTo(b.id);
        });

        for (final lote in lotes) {
          if (restante <= 0.0001) break;
          final descontar = restante < lote.cantidadRestante
              ? restante
              : lote.cantidadRestante;
          if (descontar <= 0) continue;
          final ok = await descontarLote(lote.id, descontar);
          if (!ok) return false;
          restante -= descontar;
        }

        if (restante > 0.0001) {
          // Stock insuficiente. Los lotes ya descontados NO se revierten:
          // el ajuste queda parcial, y `recalcularStockDe` de abajo lo
          // refleja para que la UI no mienta.
          await recalcularStockDe([productoId]);
          return false;
        }
      }

      await recalcularStockDe([productoId]);
      return true;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'ajustarStockDesdeEditor_fallo',
          extras: {'productoId': productoId, 'stockObjetivo': stockObjetivo});
      return false;
    }
  }

  /// ⚠️ `hardResetInventario` fue eliminado (Bloque G, PASO 3).
  ///
  ///   Era un borrado masivo de lotes + movimientos + stock, usado por
  ///   un one-shot de bootstrap durante la fase de pruebas. El one-shot
  ///   ya se había eliminado (Bloque F, F5) y este método quedó con 0
  ///   callers: era un borrado destructivo latente en una clase de
  ///   servicio, con el riesgo de que alguien lo invocara por error.
  ///
  ///   Si hay que rehacer el reset de inventario, la forma correcta es
  ///   el script `supabase/migrations/20261009000005_reset_inventario_pruebas.sql`
  ///   contra la nube + la descarga normal, no un borrado local.

  /// Suma `cantidad` a un lote existente. Si estaba agotado, lo reactiva.
  ///
  /// Usado por la anulación de ventas para devolver la mercadería al
  /// lote que se consumió. Con el modelo "lotes = fuente única de
  /// verdad" la devolución va al LOTE, nunca a `producto.stock`.
  Future<void> devolverALote(int loteId, double cantidad) async {
    if (cantidad <= 0) return;
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final lote = await isar.loteEntitys.get(loteId);
        if (lote == null) return;
        lote.cantidadRestante += cantidad;

        // ⚠️ Clamp de Opción A, mismo motivo que en
        // `ajustarStockDesdeEditor`: sin esto una devolución repetida
        // sobre un lote ya lleno deja `restante > inicial`.
        //
        // Una devolución NO registra movimiento acá: el lote ya viene de
        // una venta anulada y esa operación ya dejó su rastro. Acá solo
        // se corrige el invariante.
        lote.cantidadInicial += cantidad;

        if (lote.cantidadRestante > 0 && lote.estado == 'agotado') {
          lote.estado = 'activo';
        }
        lote.sincronizado = false;
        await isar.loteEntitys.put(lote);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'devolverALote_fallo',
          extras: {'loteId': loteId, 'cantidad': cantidad});
    }
  }

  /// Crea un lote de devolución.
  ///
  /// Se usa cuando el detalle de la venta NO registró el lote original:
  /// el retail (`VentaService.procesarVenta`) descuenta lotes con un
  /// bucle FEFO que no guarda qué lotes tocó, así que `loteIdIsar` llega
  /// `null`. El mayorista sí lo registra (`venta_mayor_service:432`).
  ///
  /// ⚠️ La trazabilidad FEFO se degrada: la unidad devuelta entra como
  /// la más antigua del producto y se consumirá antes que la mercancía
  /// con fecha de vencimiento real. Es un compromiso consciente para no
  /// perder unidades.
  Future<void> crearLoteDevolucion({
    required int productoId,
    required double cantidad,
    required String nota,
  }) async {
    if (cantidad <= 0) return;
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final lote = LoteEntity()
          ..productoId = productoId
          ..cantidadInicial = cantidad
          ..cantidadRestante = cantidad
          ..estado = 'activo'
          ..codigoLoteProveedor = nota
          ..sincronizado = false;
        await isar.loteEntitys.put(lote);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'crearLoteDevolucion_fallo',
          extras: {'productoId': productoId, 'cantidad': cantidad});
    }
  }

  Future<LoteEntity?> obtenerLoteParaVenta(
    int productoId, {
    bool priorizarVencimiento = true,
    int? localId,
  }) async {
    try {
      final lotes = await obtenerLotesActivos(
        productoId,
        priorizarVencimiento: priorizarVencimiento,
        localId: localId,
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

  /// Obtiene lotes con stock restante que ya pasaron su fecha de vencimiento.
  ///
  /// Útil para alertas en inventario: muestra productos que hay que retirar
  /// o consumir urgentemente.
  ///
  /// ⚠️ El `fechaVencimientoIsNotNull()` NO es decorativo. En Isar un
  /// `null` ordena como "menor que cualquier valor", así que un lote SIN
  /// fecha de vencimiento cumple `fechaVencimientoLessThan(hoy)` y entraba
  /// en la lista. El diálogo de inventario hacía `lote.fechaVencimiento!`
  /// y estallaba con "Null check operator used on a null value" (visto
  /// 2026-10-26: 18 de 19 lotes sin fecha). Un lote sin fecha no está
  /// vencido; simplemente no se controla por vencimiento.
  Future<List<LoteEntity>> obtenerLotesVencidosConStock() async {
    try {
      final isar = await db;
      final ahora = DateTime.now();
      final inicioDia = DateTime(ahora.year, ahora.month, ahora.day);
      return await isar.loteEntitys
          .filter()
          .cantidadRestanteGreaterThan(0)
          .and()
          .fechaVencimientoIsNotNull()
          .and()
          .fechaVencimientoLessThan(inicioDia)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerLotesVencidosConStock_fallo');
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
      // El `productoId` se captura fuera del closure para poder recalcular
      // el stock DESPUÉS: `recalcularStockDe` abre su propio `writeTxn` y
      // Isar no admite transacciones anidadas.
      int? productoIdAfectado;
      final ok = await isar.writeTxn(() async {
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

        productoIdAfectado = lote.productoId;

        return true;
      });

      if (ok && productoIdAfectado != null) {
        // Lotes = fuente única de verdad. Antes se hacía
        // `producto.stock += cantidadRecibida` sobre un lote que acababa
        // de recibir `cantidadRestante = cantidadRecibida`: doble conteo.
        await recalcularStockDe([productoIdAfectado!]);
      }

      return ok;
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

    // ==================== AUTORIZACIONES DE DESCUENTO ====================

  Future<List<AutorizacionDescuentoEntity>> obtenerAutorizacionesPorVenta(
      int ventaIdFk) async {
    try {
      final isar = await db;
      return await isar.autorizacionDescuentoEntitys
          .filter()
          .ventaIdFkEqualTo(ventaIdFk)
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'obtenerAutorizacionesPorVenta_fallo',
          extras: {'ventaIdFk': ventaIdFk});
      return [];
    }
  }


 Future<int> guardarAutorizacionDescuento(
    AutorizacionDescuentoEntity entidad,
  ) async {
    try {
      final isar = await db;
      return await isar.writeTxn<int>(() async {
        return await isar.autorizacionDescuentoEntitys.put(entidad);
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'guardarAutorizacionDescuento_fallo',
          extras: {
            'descuentoSolicitado': entidad.descuentoSolicitado,
            'solicitadoPorNombre': entidad.solicitadoPorNombre,
          });
      rethrow;
    }
  }

  Future<List<AutorizacionDescuentoEntity>>
      obtenerAutorizacionesPendientesSync() async {
    try {
      final isar = await db;
      return await isar.autorizacionDescuentoEntitys
          .filter()
          .syncStatusEqualTo('pending')
          .or()
          .syncStatusEqualTo('failed')
          .findAll();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerAutorizacionesPendientesSync_fallo');
      return [];
    }
  }

  Future<void> actualizarSyncStatusAutorizacion(
      int id, String nuevoEstado) async {
    try {
      final isar = await db;
      await isar.writeTxn(() async {
        final autz = await isar.autorizacionDescuentoEntitys.get(id);
        if (autz != null) {
          autz.syncStatus = nuevoEstado;
          await isar.autorizacionDescuentoEntitys.put(autz);
        }
      });
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack,
          hint: 'actualizarSyncStatusAutorizacion_fallo',
          extras: {'id': id, 'nuevoEstado': nuevoEstado});
      rethrow;
    }
  }

  /// Para reportes de auditoría: autorizaciones en un rango de fechas.
  Future<List<AutorizacionDescuentoEntity>> obtenerAutorizacionesPorPeriodo(
    DateTime inicio,
    DateTime fin,
  ) async {
    try {
      final isar = await db;
      final lista = await isar.autorizacionDescuentoEntitys
          .filter()
          .fechaBetween(inicio, fin, includeLower: true, includeUpper: true)
          .findAll();
      lista.sort((a, b) => b.fecha.compareTo(a.fecha));
      return lista;
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerAutorizacionesPorPeriodo_fallo');
      return [];
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

  // ================================ métodos para pinshash=============================

  Future<void> migrarPinsAHash(Isar isar) async {
    try {
      final usuarios = await isar.usuarioEntitys.where().findAll();
      int migrados = 0;
      for (final u in usuarios) {
        if (u.pin.isNotEmpty && !PinHasher.isHashed(u.pin)) {
          u.pin = PinHasher.hashWithNewSalt(u.pin);
          await isar.writeTxn(() async {
            await isar.usuarioEntitys.put(u);
          });
          migrados++;
        }
      }
      if (migrados > 0) {
        debugPrint('🔐 PINs migrados a hash: $migrados');
      } else {
        debugPrint('🔐 Todos los PINs ya están hasheados');
      }
    } catch (e, stack) {
      ErrorService.captureError(e, stack: stack, hint: 'migrarPinsAHash_fallo');
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
      final variacion = totalVentasAyer > 0
          ? ((totalHoy - totalVentasAyer) / totalVentasAyer) * 100
          : (totalHoy > 0 ? 100.0 : 0.0);

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

      // ── Comparativas reales (no dependen del largo de ventasPorDia) ──
      final inicioSemanaAnterior =
          inicioSemana.subtract(const Duration(days: 7));
      final finSemanaAnterior =
          inicioSemana.subtract(const Duration(milliseconds: 1));
      final inicioMesAnterior = DateTime(hoy.year, hoy.month - 1, 1);
      final finMesAnterior = inicioMes.subtract(const Duration(milliseconds: 1));

      final totalSemanaAnterior = await obtenerTotalVentasPorRango(
        inicioSemanaAnterior,
        finSemanaAnterior,
      );
      final totalMesAnterior = await obtenerTotalVentasPorRango(
        inicioMesAnterior,
        finMesAnterior,
      );
      final gastosHoy = await obtenerTotalGastosPorRango(inicioHoy, finDia);

      final ventasDelMes = await isar.ventaEntitys
          .filter()
          .fechaBetween(inicioMes, finDia,
              includeLower: true, includeUpper: true)
          .findAll();
      final ventasMes = ventasDelMes.length;

      // ── Ventas por hora de HOY (horas pico) ──
      final ventasDeHoy = await isar.ventaEntitys
          .filter()
          .fechaBetween(inicioHoy, finDia,
              includeLower: true, includeUpper: true)
          .findAll();
      final porHora = List<double>.filled(24, 0);
      for (final v in ventasDeHoy) {
        final hora = v.fecha?.hour;
        if (hora != null && hora >= 0 && hora < 24) {
          porHora[hora] += v.total;
        }
      }
      final ventasPorHora = <Map<String, dynamic>>[
        for (var h = 0; h < 24; h++) {'hora': h, 'total': porHora[h]},
      ];

      // ── Métodos de pago del mes ──
      final metodos = <String, Map<String, double>>{};
      for (final v in ventasDelMes) {
        final clave = v.metodoPago.trim().isEmpty
            ? 'Sin especificar'
            : v.metodoPago.trim();
        final actual =
            metodos.putIfAbsent(clave, () => {'total': 0.0, 'count': 0.0});
        actual['total'] = actual['total']! + v.total;
        actual['count'] = actual['count']! + 1;
      }

      // ── Top productos del MES (no de toda la historia) ──
      final topProductosMes = await obtenerProductosMasVendidosEnRango(
        inicioMes,
        finDia,
        limite: 5,
      );

      // ── Productos activos sin ninguna venta en 30 días ──
      final sinRotacion = await obtenerProductosSinRotacion(
        inicioHoy.subtract(const Duration(days: 30)),
        finDia,
      );

      // ── Anulaciones del mes ──
      final todasAnuladas = await isar.ventaAnuladaEntitys.where().findAll();
      final anuladasMes = todasAnuladas
          .where((a) =>
              !a.fechaAnulacion.isBefore(inicioMes) &&
              !a.fechaAnulacion.isAfter(finDia))
          .toList();
      final montoAnuladoMes =
          anuladasMes.fold<double>(0, (s, a) => s + a.montoOriginal);

      // ── Estado del salón (solo hay filas en modo restaurante) ──
      final mesas = await isar.mesaEntitys.where().findAll();
      final mesasOcupadas =
          mesas.where((m) => m.estado == MesaEstado.ocupada).length;
      final comandas = await isar.cartSessionEntitys.where().findAll();
      final comandasAbiertas = comandas.where((c) {
        if (c.mesaId == null) return false;
        return c.comandaEstado == ComandaEstado.abierta ||
            c.comandaEstado == ComandaEstado.enviada;
      }).length;

      return {
        'totalHoy': totalHoy,
        'totalSemana': totalSemana,
        'totalMes': totalMes,
        'totalGastosMes': totalGastosMes,
        'variacion': variacion,
        'ventasHoy': ventasHoy,
        'ultimasVentas': ultimasVentas,
        'topProductos': topProductosMes.isEmpty ? topProductos : topProductosMes,
        'stockBajo': stockBajo,
        'ventasPorEmpleado': ventasPorEmpleado,
        'ventasPorDia': ventasPorDia,
        // ── Comparativas ──
        'totalAyer': totalVentasAyer,
        'totalSemanaAnterior': totalSemanaAnterior,
        'totalMesAnterior': totalMesAnterior,
        'gastosHoy': gastosHoy,
        // ── Tickets ──
        'ventasMes': ventasMes,
        'ticketPromedioHoy': ventasHoy > 0 ? totalHoy / ventasHoy : 0.0,
        'ticketPromedioMes': ventasMes > 0 ? totalMes / ventasMes : 0.0,
        // ── Distribuciones ──
        'ventasPorHora': ventasPorHora,
        'ventasPorMetodoPago': metodos,
        // ── Calidad de la operación ──
        'productosSinRotacion': sinRotacion,
        'anulacionesMes': anuladasMes.length,
        'montoAnuladoMes': montoAnuladoMes,
        // ── Salón ──
        'mesasTotales': mesas.length,
        'mesasOcupadas': mesasOcupadas,
        'comandasAbiertas': comandasAbiertas,
      };
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerResumenDashboard_fallo');
      return {};
    }
  }

  /// Top de productos vendidos DENTRO de un rango de fechas.
  ///
  /// A diferencia de [obtenerProductosMasVendidos], que suma toda la
  /// historia, este acota a las ventas del período. Devuelve
  /// `{nombre, cantidad, monto}`.
  Future<List<Map<String, dynamic>>> obtenerProductosMasVendidosEnRango(
    DateTime inicio,
    DateTime fin, {
    int limite = 5,
  }) async {
    try {
      final isar = await db;
      final ventas = await isar.ventaEntitys
          .filter()
          .fechaBetween(inicio, fin,
              includeLower: true, includeUpper: true)
          .findAll();
      final ids = ventas
          .map((v) => v.idSupabase)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();
      if (ids.isEmpty) return [];

      final detalles = await isar.detalleVentaEntitys.where().findAll();
      final cantidades = <String, double>{};
      final montos = <String, double>{};
      for (final d in detalles) {
        if (!ids.contains(d.ventaIdFk)) continue;
        cantidades[d.nombreProducto] =
            (cantidades[d.nombreProducto] ?? 0) + d.cantidad;
        montos[d.nombreProducto] =
            (montos[d.nombreProducto] ?? 0) + d.subtotal;
      }

      final lista = cantidades.entries
          .map((e) => <String, dynamic>{
                'nombre': e.key,
                'cantidad': e.value,
                'monto': montos[e.key] ?? 0.0,
              })
          .toList()
        ..sort((a, b) =>
            (b['cantidad'] as double).compareTo(a['cantidad'] as double));

      return lista.take(limite).toList();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerProductosMasVendidosEnRango_fallo');
      return [];
    }
  }

  /// Productos activos que NO registraron ninguna venta en el rango.
  ///
  /// Sirve para detectar inventario inmovilizado: producto que existe,
  /// está activo y no se vendió ni una vez en 30 días.
  Future<List<ProductoEntity>> obtenerProductosSinRotacion(
    DateTime inicio,
    DateTime fin, {
    int limite = 8,
  }) async {
    try {
      final isar = await db;
      final ventas = await isar.ventaEntitys
          .filter()
          .fechaBetween(inicio, fin,
              includeLower: true, includeUpper: true)
          .findAll();
      final ids = ventas
          .map((v) => v.idSupabase)
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet();

      final vendidos = <int>{};
      if (ids.isNotEmpty) {
        final detalles = await isar.detalleVentaEntitys.where().findAll();
        for (final d in detalles) {
          if (!ids.contains(d.ventaIdFk)) continue;
          final pid = d.productoId;
          if (pid != null) vendidos.add(pid);
        }
      }

      final productos = await isar.productoEntitys
          .filter()
          .activoEqualTo(true)
          .findAll();
      final sinVenta = productos
          .where((p) => !vendidos.contains(p.id))
          .toList()
        ..sort((a, b) => a.nombre.compareTo(b.nombre));

      return sinVenta.take(limite).toList();
    } catch (e, stack) {
      ErrorService.captureError(e,
          stack: stack, hint: 'obtenerProductosSinRotacion_fallo');
      return [];
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

  // ═══════════════════════════════════════════════════════════════
  // ANULACIONES DE VENTA
  // ═══════════════════════════════════════════════════════════════

  /// Registra la anulación de una venta.
  ///
  /// NO modifica la venta original. Solo inserta un registro nuevo.
  Future<void> guardarVentaAnulada(VentaAnuladaEntity anulacion) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.ventaAnuladaEntitys.put(anulacion);
    });
  }

  /// Devuelve la anulación de una venta específica (si existe).
  Future<VentaAnuladaEntity?> obtenerAnulacionDeVenta(
      String ventaIdOriginal) async {
    if (ventaIdOriginal.isEmpty) return null;
    final isar = await db;
    return isar.ventaAnuladaEntitys
        .filter()
        .ventaIdOriginalEqualTo(ventaIdOriginal)
        .findFirst();
  }

  /// Lista de todas las anulaciones del tenant.
  Future<List<VentaAnuladaEntity>> obtenerVentasAnuladas(
      String tenantId) async {
    if (tenantId.isEmpty) return [];
    final isar = await db;
    return isar.ventaAnuladaEntitys
        .filter()
        .tenantIdEqualTo(tenantId)
        .sortByFechaAnulacionDesc()
        .findAll();
  }

  // ═══════════════════════════════════════════════════════════════
  // ANULACIONES DE GASTO
  // ═══════════════════════════════════════════════════════════════

  Future<void> guardarGastoAnulado(GastoAnuladoEntity anulacion) async {
    final isar = await db;
    await isar.writeTxn(() async {
      await isar.gastoAnuladoEntitys.put(anulacion);
    });
  }

  Future<GastoAnuladoEntity?> obtenerAnulacionDeGasto(
      int gastoIdOriginal) async {
    final isar = await db;
    return isar.gastoAnuladoEntitys
        .filter()
        .gastoIdOriginalEqualTo(gastoIdOriginal)
        .findFirst();
  }

  /// Devuelve los IDs de gastos anulados del tenant (para filtrar en UI).
  Future<Set<int>> obtenerIdsGastosAnulados(String tenantId) async {
    if (tenantId.isEmpty) return {};
    final isar = await db;
    final lista = await isar.gastoAnuladoEntitys
        .filter()
        .tenantIdEqualTo(tenantId)
        .findAll();
    return lista.map((a) => a.gastoIdOriginal).toSet();
  }
}
