import 'dart:math';
// Eliminado import innecesario: import 'dart:convert';

// Solo importamos Sembast Web (re-exporta todo lo necesario)
import 'package:sembast_web/sembast_web.dart';
import 'package:flutter/foundation.dart';

// Entidades (Necesarias para las firmas de los métodos)
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

  Map<String, dynamic> toMap() => {
        'codigo': codigo,
        'proveedorNombre': proveedorNombre,
        'fechaIngreso': fechaIngreso.toIso8601String(),
        'fechaVencimiento': fechaVencimiento?.toIso8601String(),
        'cantidad': cantidad,
        'precio': precio,
        'tipo': tipo,
      };

  factory HistorialCodigoItem.fromMap(Map<String, dynamic> map) => HistorialCodigoItem(
        codigo: map['codigo'] ?? '',
        proveedorNombre: map['proveedorNombre'],
        fechaIngreso: DateTime.parse(map['fechaIngreso']),
        fechaVencimiento: map['fechaVencimiento'] != null ? DateTime.parse(map['fechaVencimiento']) : null,
        cantidad: (map['cantidad'] as num?)?.toDouble() ?? 0.0,
        precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
        tipo: map['tipo'] ?? 'alias',
      );
}

/// Servicio que reemplaza internamente a Isar por Sembast
/// Mantiene el nombre de clase para no romper los imports del proyecto.
class IsarService {
  static final IsarService _instance = IsarService._internal();
  factory IsarService() => _instance;
  IsarService._internal();

  late Database _db;
  bool _isInitialized = false;

  // Stores de Sembast (se mantienen los originales y se agregan nuevos)
  final _userStore = stringMapStoreFactory.store('usuarios');
  final _productStore = stringMapStoreFactory.store('productos');
  final _gastoStore = stringMapStoreFactory.store('gastos');
  final _ventaStore = stringMapStoreFactory.store('ventas');
  final _detalleVentaStore = stringMapStoreFactory.store('detalle_ventas');
  final _pedidoStore = stringMapStoreFactory.store('pedidos');
  final _detallePedidoStore = stringMapStoreFactory.store('detalle_pedidos');
  final _localStore = stringMapStoreFactory.store('locales');
  final _departamentoStore = stringMapStoreFactory.store('departamentos');
  final _proveedorStore = stringMapStoreFactory.store('proveedores');
  final _loteStore = stringMapStoreFactory.store('lotes');
  final _categoriaStore = stringMapStoreFactory.store('categorias');
  final _marcaStore = stringMapStoreFactory.store('marcas');
  final _clienteStore = stringMapStoreFactory.store('clientes');
  final _movimientoInventarioStore = stringMapStoreFactory.store('movimientos_inventario');
  final _turnoStore = stringMapStoreFactory.store('turnos');
  final _recepcionStore = stringMapStoreFactory.store('recepciones');
  final _telegramConfigStore = stringMapStoreFactory.store('telegram_config');
  final _codigoAliasStore = stringMapStoreFactory.store('codigo_alias');
  final _movimientoLoteStore = stringMapStoreFactory.store('movimientos_lote');
  final _logStore = stringMapStoreFactory.store('logs');

  // ==================== INICIALIZACIÓN ====================

  Future<Database> get db async {
    if (!_isInitialized) {
      _db = await databaseFactoryWeb.openDatabase('boost_pos_sembast.db_v4.db');
      await _inicializarDatosDemo();
      _isInitialized = true;
    }
    return _db;
  }

  Future<void> init() async {
    await db;
    debugPrint('✅ Sembast inicializado correctamente');
  }

  // ==================== MAPEO DE ENTIDADES ====================
  // (Evitamos errores de toJson/fromJson no existentes)

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
        'localId': u.localId,
        'dynamicId': u.dynamicId,
        'supabaseId': u.supabaseId,
        'sincronizado': u.sincronizado,
        'fechaSincronizacion': u.fechaSincronizacion?.toIso8601String(),
        'createdAt': u.createdAt?.toIso8601String(),
        'updatedAt': u.updatedAt?.toIso8601String(),
      };

  UsuarioEntity _mapToUsuario(Map<String, dynamic> map) {
    final usuario = UsuarioEntity()
      ..id = map['id'] as int? ?? 0
      ..nombre = map['nombre'] as String? ?? ''
      ..email = map['email'] as String? ?? ''
      ..password = map['password'] as String? ?? ''
      ..pin = map['pin'] as String? ?? ''
      ..rol = map['rol'] as String? ?? 'cajero'
      ..activo = map['activo'] as bool? ?? true
      ..estado = map['estado'] as String? ?? 'inactivo'
      ..cajaAsignada = map['cajaAsignada'] as String? ?? 'Caja Principal';
    usuario.localId = map['localId'] as int?;
    usuario.dynamicId = map['dynamicId'] as String? ?? ''; // ✅ CORREGIDO
    usuario.supabaseId = map['supabaseId'] as String?;
    usuario.sincronizado = map['sincronizado'] as bool? ?? false;
    usuario.fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.parse(map['fechaSincronizacion']) : null;
    usuario.createdAt = map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null;
    usuario.updatedAt = map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null;
    return usuario;
  }

  Map<String, dynamic> _productoToMap(ProductoEntity p) => {
        'id': p.id,
        'codigoBarras': p.codigoBarras,
        'nombre': p.nombre,
        'precioUnidad': p.precioUnidad,
        'stock': p.stock,
        'esPesado': p.esPesado,
        'categoria': p.categoria,
        'categoriaId': p.categoriaId,
        'proveedorId': p.proveedorId,
        'proveedorNombre': p.proveedorNombre,
        'proveedorTelefono': p.proveedorTelefono,
        'proveedorDireccion': p.proveedorDireccion,
        'proveedorEmail': p.proveedorEmail,
        'proveedorSupabaseId': p.proveedorSupabaseId,
        'marca': p.marca,
        'marcaSupabaseId': p.marcaSupabaseId,
        'stockMinimo': p.stockMinimo,
        'imagenUrl': p.imagenUrl,
        'activo': p.activo,
        'createdAt': p.createdAt?.toIso8601String(),
        'updatedAt': p.updatedAt?.toIso8601String(),
        'createdBy': p.createdBy,
        'createdByName': p.createdByName,
        'updatedBy': p.updatedBy,
        'updatedByName': p.updatedByName,
        'version': p.version,
        'supabaseId': p.supabaseId,
        'sincronizado': p.sincronizado,
        'fechaSincronizacion': p.fechaSincronizacion?.toIso8601String(),
      };

  ProductoEntity _mapToProducto(Map<String, dynamic> map) {
    final producto = ProductoEntity()
      ..id = map['id'] as int? ?? 0
      ..codigoBarras = map['codigoBarras'] as String? ?? ''
      ..nombre = map['nombre'] as String? ?? ''
      ..precioUnidad = (map['precioUnidad'] as num?)?.toDouble() ?? 0.0
      ..stock = (map['stock'] as num?)?.toDouble() ?? 0.0
      ..esPesado = map['esPesado'] as bool? ?? false
      ..categoria = map['categoria'] as String? ?? ''
      ..activo = map['activo'] as bool? ?? true
      ..stockMinimo = (map['stockMinimo'] as num?)?.toDouble() ?? 0.0
      ..imagenUrl = map['imagenUrl'] as String? ?? '';
    producto.categoriaId = map['categoriaId'] as int?;
    producto.proveedorId = map['proveedorId'] as int?;
    producto.proveedorNombre = map['proveedorNombre'] as String? ?? ''; // ✅ CORREGIDO
    producto.proveedorTelefono = map['proveedorTelefono'] as String? ?? ''; // ✅ CORREGIDO
    producto.proveedorDireccion = map['proveedorDireccion'] as String? ?? ''; // ✅ CORREGIDO
    producto.proveedorEmail = map['proveedorEmail'] as String? ?? ''; // ✅ CORREGIDO
    producto.proveedorSupabaseId = map['proveedorSupabaseId'] as String?;
    producto.marca = map['marca'] as String? ?? ''; // ✅ CORREGIDO
    producto.marcaSupabaseId = map['marcaSupabaseId'] as String?;
    producto.createdAt = map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null;
    producto.updatedAt = map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null;
    producto.createdBy = map['createdBy'] as int?; // ✅ CORREGIDO (era String?)
    producto.createdByName = map['createdByName'] as String?;
    producto.updatedBy = map['updatedBy'] as int?; // ✅ CORREGIDO (era String?)
    producto.updatedByName = map['updatedByName'] as String?;
    producto.version = map['version'] as int? ?? 1; // ✅ CORREGIDO (fallback a 1)
    producto.supabaseId = map['supabaseId'] as String?;
    producto.sincronizado = map['sincronizado'] as bool? ?? false;
    producto.fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.parse(map['fechaSincronizacion']) : null;
    return producto;
  }

  Map<String, dynamic> _localToMap(LocalEntity l) => {
        'id': l.id,
        'nombre': l.nombre,
        'direccion': l.direccion,
        'telefono': l.telefono,
        'email': l.email,
        'rif': l.rif,
        'activo': l.activo,
        'supabaseId': l.supabaseId,
        'sincronizado': l.sincronizado,
        'fechaSincronizacion': l.fechaSincronizacion?.toIso8601String(),
        'createdAt': l.createdAt?.toIso8601String(),
        'updatedAt': l.updatedAt?.toIso8601String(),
      };

  LocalEntity _mapToLocal(Map<String, dynamic> map) {
    final local = LocalEntity()
      ..id = map['id'] as int? ?? 0
      ..nombre = map['nombre'] as String? ?? ''
      ..direccion = map['direccion'] as String? ?? ''
      ..telefono = map['telefono'] as String? ?? ''
      ..email = map['email'] as String? ?? ''
      ..rif = map['rif'] as String? ?? ''
      ..activo = map['activo'] as bool? ?? true
      ..sincronizado = map['sincronizado'] as bool? ?? false;
    local.supabaseId = map['supabaseId'] as String?;
    local.fechaSincronizacion = map['fechaSincronizacion'] != null ? DateTime.parse(map['fechaSincronizacion']) : null;
    local.createdAt = map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null;
    local.updatedAt = map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null;
    return local;
  }

  // ==================== DATOS DEMO ====================

  Future<void> _inicializarDatosDemo() async {
    // Usuarios
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
        'localId': 1,
        'sincronizado': false,
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
        'localId': 1,
        'sincronizado': false,
      });
    }

    // Productos (usando código de barras como clave)
   if (await _productStore.count(_db) < 3) {
  await _productStore.record('75010001').put(_db, {
    'codigoBarras': '75010001',
    'nombre': 'Manzana Roja Importada',
    'precioUnidad': 3.50,
    'stock': 50.0,
    'esPesado': true,
    'categoria': 'Frutas',
    'proveedorId': 1,
    'stockMinimo': 10.0,
    'activo': true,
    'sincronizado': false,
    'imagenUrl': 'https://ik.imagekit.io/xnf3fil5g/manzanaroja.png',   // ✅ CORREGIDO
  });
  await _productStore.record('75010002').put(_db, {
    'codigoBarras': '75010002',
    'nombre': 'Arroz Premium 1kg',
    'precioUnidad': 1.20,
    'stock': 100.0,
    'esPesado': false,
    'categoria': 'Abarrotes',
    'proveedorId': 1,
    'stockMinimo': 15.0,
    'activo': true,
    'sincronizado': false,
    'imagenUrl': 'https://ik.imagekit.io/xnf3fil5g/arroz.png',    // ✅ CORREGIDO
  });
  await _productStore.record('75010003').put(_db, {
    'codigoBarras': '75010003',
    'nombre': 'Queso Blanco Duro',
    'precioUnidad': 6.80,
    'stock': 25.0,
    'esPesado': true,
    'categoria': 'Lácteos',
    'proveedorId': 1,
    'stockMinimo': 5.0,
    'activo': true,
    'sincronizado': false,
    'imagenUrl': 'https://ik.imagekit.io/xnf3fil5g/quesoduro.png',     // ✅ CORREGIDO
  });
}

    // 1. Local
    if (await _localStore.count(_db) == 0) {
      final local = LocalEntity()
        ..id = 1
        ..nombre = 'Local Principal'
        ..direccion = 'Av. Principal, Local 1'
        ..telefono = '0212-5551234'
        ..email = 'local@ejemplo.com'
        ..rif = 'J-12345678-9'
        ..activo = true
        ..sincronizado = false;
      await _localStore.record('local_1').put(_db, _localToMap(local));
    }

    // 2. Departamento
    if (await _departamentoStore.count(_db) == 0) {
      final depto = DepartamentoEntity()
        ..id = 1
        ..nombre = 'Abarrotes'
        ..descripcion = 'Productos de alimentos no perecederos'
        ..localId = 1
        ..activo = true
        ..sincronizado = false;
      await _departamentoStore.record('depto_1').put(_db, depto.toMap());
    }

    // 3. Proveedor
    if (await _proveedorStore.count(_db) == 0) {
      final prov = ProveedorEntity()
        ..id = 1
        ..nombre = 'Distribuidora Alimentos C.A.'
        ..empresa = 'Distribuidora Alimentos C.A.'
        ..rif = 'J-98765432-1'
        ..telefono = '0212-5559876'
        ..direccion = 'Zona Industrial, Galpón 5'
        ..email = 'ventas@distribuidora.com'
        ..activo = true
        ..sincronizado = false;
      await _proveedorStore.record('prov_1').put(_db, prov.toMap());
    }

    // 4. Gasto
    if (await _gastoStore.count(_db) == 0) {
      final gasto = GastoEntity()
        ..id = 1
        ..descripcion = 'Compra de papel higiénico'
        ..monto = 15.50
        ..moneda = 'USD'
        ..categoria = 'General'
        ..fecha = DateTime.now()
        ..usuarioId = 1
        ..usuarioNombre = 'Administrador'
        ..syncStatus = 'synced';
      await _gastoStore.record('gasto_1').put(_db, gasto.toMap());
    }

    // 5. Venta (con un detalle)
    if (await _ventaStore.count(_db) == 0) {
      final venta = VentaEntity()
        ..id = 1
        ..idSupabase = 'venta_demo_001'
        ..fecha = DateTime.now()
        ..total = 3.50
        ..subtotal = 3.50
        ..impuesto = 0.0
        ..metodoPago = 'Efectivo'
        ..documento = 0
        ..empleado = 'Administrador / Catálogo'
        ..syncStatus = 'synced';
      await _ventaStore.record('venta_1').put(_db, venta.toMap());

      // Detalle de la venta
      final detalle = DetalleVentaEntity()
        ..id = 1
        ..productoId = 1
        ..nombreProducto = 'Manzana Roja Importada'
        ..precioUnidad = 3.50
        ..cantidad = 1.0
        ..subtotal = 3.50
        ..ventaIdFk = 'venta_demo_001'
        ..syncStatus = 'synced';
      await _detalleVentaStore.record('detalle_1').put(_db, detalle.toMap());
    }

    // 6. Pedido (con un detalle)
    if (await _pedidoStore.count(_db) == 0) {
      final pedido = PedidoEntity()
        ..id = 1
        ..supabaseId = 'pedido_demo_001'
        ..localOrigenId = 1
        ..localDestinoId = 1
        ..usuarioId = 1
        ..fechaPedido = DateTime.now()
        ..estado = EstadoPedido.pendiente
        ..proveedorNombre = 'Distribuidora Alimentos C.A.'
        ..total = 25.00
        ..sincronizado = false;
      await _pedidoStore.record('pedido_1').put(_db, pedido.toMap());

      final detallePedido = DetallePedidoEntity()
        ..id = 1
        ..supabaseId = 1
        ..pedidoId = 1
        ..productoId = 2
        ..nombreProducto = 'Arroz Premium 1kg'
        ..cantidad = 20.0
        ..precioUnidad = 1.20
        ..subtotal = 24.00;
      await _detallePedidoStore.record('detalle_pedido_1').put(_db, detallePedido.toMap());
    }

    // 7. Lote
    if (await _loteStore.count(_db) == 0) {
      final lote = LoteEntity()
        ..id = 1
        ..productoId = 2
        ..codigoBarrasLote = '75010002'
        ..cantidadInicial = 100.0
        ..cantidadRestante = 100.0
        ..fechaIngreso = DateTime.now()
        ..estado = 'activo'
        ..sincronizado = false;
      await _loteStore.record('lote_1').put(_db, lote.toMap());
    }

    // 8. Cliente
    if (await _clienteStore.count(_db) == 0) {
      final cliente = ClienteEntity()
        ..id = 1
        ..nombre = 'Juan Pérez'
        ..documento = 'V-12345678'
        ..telefono = '0412-3456789'
        ..email = 'juan@example.com'
        ..activo = true
        ..frecuente = false;
      await _clienteStore.record('cliente_1').put(_db, cliente.toMap());
    }

    // 9. Categoría
    if (await _categoriaStore.count(_db) == 0) {
      final cat = CategoriaEntity(nombre: 'Frutas') // ✅ CORREGIDO
        ..id = 1
        ..descripcion = 'Frutas frescas'
        ..activo = true
        ..syncStatus = 'synced';
      await _categoriaStore.record('cat_1').put(_db, cat.toMap());

      final cat2 = CategoriaEntity(nombre: 'Abarrotes') // ✅ CORREGIDO
        ..id = 2
        ..descripcion = 'Alimentos no perecederos'
        ..activo = true
        ..syncStatus = 'synced';
      await _categoriaStore.record('cat_2').put(_db, cat2.toMap());
    }

    // 10. Marca
    if (await _marcaStore.count(_db) == 0) {
      final marca = MarcaEntity()
        ..id = 1
        ..nombre = 'Marca Demo'
        ..descripcion = 'Marca de ejemplo'
        ..activo = true
        ..syncStatus = 'synced';
      await _marcaStore.record('marca_1').put(_db, marca.toMap());
    }

    // 11. Turno (abierto para el admin)
    if (await _turnoStore.count(_db) == 0) {
      final turno = TurnoEntity()
        ..id = 1
        ..usuarioId = 1
        ..usuarioNombre = 'Administrador'
        ..cajaId = '1'
        ..cajaNombre = 'Caja Principal'
        ..fechaApertura = DateTime.now()
        ..montoInicial = 0.0
        ..estado = 'abierto'
        ..syncStatus = 'synced';
      await _turnoStore.record('turno_1').put(_db, turno.toMap());
    }
  }

  // Método auxiliar para inicializar usuarios demo si no existen (usado en inicializarUsuarioAdminPorDefecto)
  Future<void> _inicializarUsuariosDemo(IsarService isar) async {
    // Ya se crean en _inicializarDatosDemo, pero este método se llama desde afuera
    // Simplemente aseguramos que existan
    final count = await _userStore.count(await db);
    if (count == 0) {
      await _inicializarDatosDemo(); // Esto ya los crea, pero por si acaso
    }
  }

  // ==================== USUARIOS (Implementación Real) ====================

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

  Future<UsuarioEntity?> obtenerUsuarioPorSupabaseId(String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    final records = await _userStore.find(isar);
    for (var r in records) {
      if (r.value['supabaseId'] == supabaseId) {
        return _mapToUsuario(r.value);
      }
    }
    return null;
  }

  Future<UsuarioEntity?> obtenerUsuarioPorDynamicId(String dynamicId) async {
    final isar = await db;
    if (dynamicId.isEmpty) return null;
    final records = await _userStore.find(isar);
    for (var r in records) {
      if (r.value['dynamicId'] == dynamicId) {
        return _mapToUsuario(r.value);
      }
    }
    return null;
  }

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

  Future<bool> eliminarUsuario(int id) async {
    final isar = await db;
    return await _userStore.record(id.toString()).delete(isar) != null;
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
      if (u.nombre.toLowerCase() == nombreNorm.toLowerCase() &&
          u.pin == pinNorm &&
          u.activo) {
        return u;
      }
    }
    return null;
  }

  Future<void> inicializarUsuarioAdminPorDefecto() async {
    // Llamamos al método que inicializa usuarios demo si no existen
    await _inicializarUsuariosDemo(this);
  }

  // ==================== PRODUCTOS ====================

  Future<List<ProductoEntity>> obtenerProductos() async {
    final isar = await db;
    final records = await _productStore.find(isar);
    final Map<String, ProductoEntity> productosUnicos = {};
    for (final record in records) {
      final map = Map<String, dynamic>.from(record.value);
      final producto = _mapToProducto(map);
      if (!productosUnicos.containsKey(producto.codigoBarras)) {
        productosUnicos[producto.codigoBarras] = producto;
      }
    }
    return productosUnicos.values.toList();
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
    final key = producto.codigoBarras.isEmpty
        ? 'TEMP-${DateTime.now().millisecondsSinceEpoch}'
        : producto.codigoBarras;
    final map = _productoToMap(producto);
    map.remove('id');
    await _productStore.record(key).put(isar, map);
  }

  Future<void> eliminarProducto(int id) async {
    final isar = await db;
    await _productStore.record(id.toString()).delete(isar);
  }

  Future<void> eliminarProductoPorCodigo(String codigoBarras) async {
    final isar = await db;
    await _productStore.record(codigoBarras).delete(isar);
  }

  Future<List<ProductoEntity>> obtenerProductosStockBajo() async {
    final productos = await obtenerProductos();
    return productos.where((p) => p.stock <= p.stockMinimo).toList();
  }

  Future<void> actualizarStockProducto(int idProducto, double nuevoStock) async {
    final producto = await obtenerProductoPorId(idProducto);
    if (producto != null) {
      producto.stock = nuevoStock;
      await guardarProducto(producto);
    }
  }

  Future<ProductoEntity?> obtenerProductoPorCodigoBarrasExacto(String codigo) async {
    final isar = await db;
    final record = await _productStore.record(codigo).get(isar);
    if (record != null) {
      return _mapToProducto(record);
    }
    final records = await _productStore.find(isar);
    for (final r in records) {
      if (r.value['codigoBarras'] == codigo) {
        return _mapToProducto(r.value);
      }
    }
    return null;
  }

  Future<String> generarCodigoBarrasUnico() async {
    final isar = await db;
    final random = Random();
    String codigo;
    int intentos = 0;
    do {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final timestampPart = timestamp.length > 10 ? timestamp.substring(timestamp.length - 10) : timestamp;
      final randomNum = (100 + random.nextInt(899)).toString();
      codigo = 'B$timestampPart$randomNum';
      intentos++;
      final existente = await _productStore.record(codigo).get(isar);
      if (existente == null) {
        return codigo;
      }
      await Future.delayed(const Duration(milliseconds: 1));
    } while (intentos < 10);
    codigo = 'B${DateTime.now().microsecondsSinceEpoch}';
    return codigo;
  }

  Future<List<ProductoEntity>> obtenerTodosLosProductos() async => await obtenerProductos();

  Future<int> contarProductos() async => (await obtenerProductos()).length;

  Future<List<ProductoEntity>> obtenerProductosPendientesSync() async => [];

  // ==================== VENTAS Y DETALLES ====================

  Future<void> guardarVenta(VentaEntity venta, {List<DetalleVentaEntity>? detalles}) async {
    final isar = await db;
    final map = venta.toMap();
    final key = (venta.idSupabase ?? '').isNotEmpty ? venta.idSupabase! : 'venta_${DateTime.now().millisecondsSinceEpoch}';
    await _ventaStore.record(key).put(isar, map);
    if (detalles != null) {
      for (var detalle in detalles) {
        detalle.ventaIdFk = venta.idSupabase;
        final detKey = detalle.id != 0 ? detalle.id.toString() : 'detalle_${DateTime.now().millisecondsSinceEpoch}';
        await _detalleVentaStore.record(detKey).put(isar, detalle.toMap());
      }
    }
  }

  Future<List<VentaEntity>> obtenerVentas() async {
    final isar = await db;
    final records = await _ventaStore.find(isar);
    return records.map((e) => VentaEntity.fromMap(e.value)).toList();
  }

  Future<List<VentaEntity>> obtenerVentasPorRango(DateTime inicio, DateTime fin) async {
    final ventas = await obtenerVentas();
    return ventas.where((v) {
      final f = v.fecha;
      return f != null && f.isAfter(inicio) && f.isBefore(fin);
    }).toList();
  }

  Future<List<VentaEntity>> obtenerUltimasVentas(int cantidad) async {
    final ventas = await obtenerVentas();
    ventas.sort((a, b) => (b.fecha ?? DateTime(1970)).compareTo(a.fecha ?? DateTime(1970)));
    return ventas.take(cantidad).toList();
  }

  Future<List<DetalleVentaEntity>> obtenerDetallesPorVenta(String ventaId) async {
    final isar = await db;
    final records = await _detalleVentaStore.find(isar);
    return records
        .map((e) => DetalleVentaEntity.fromMap(e.value))
        .where((d) => d.ventaIdFk == ventaId)
        .toList();
  }

  Future<VentaEntity?> obtenerVentaPorIdString(String ventaIdString) async {
    final isar = await db;
    final record = await _ventaStore.record(ventaIdString).get(isar);
    return record != null ? VentaEntity.fromMap(record) : null;
  }

  Future<double> obtenerTotalVentasPorEmpleadoYRango(String empleado, DateTime inicio, DateTime fin) async {
    final ventas = await obtenerVentasPorRango(inicio, fin);
    double total = 0.0;
    for (var v in ventas) {
      if (v.empleado == empleado) {
        total += v.total;
      }
    }
    return total;
  }

  Future<List<VentaEntity>> obtenerVentasPendientesSync() async {
    final ventas = await obtenerVentas();
    return ventas.where((v) => v.syncStatus == 'pending' || v.syncStatus == 'failed').toList();
  }

  Future<void> actualizarSyncStatusVenta(int id, String nuevoEstado) async {
    final isar = await db;
    final record = await _ventaStore.record(id.toString()).get(isar);
    if (record != null) {
      record['syncStatus'] = nuevoEstado;
      await _ventaStore.record(id.toString()).put(isar, record);
    }
  }

  Future<void> guardarDetallesVenta(String ventaId, List<DetalleVentaEntity> detalles) async {
    final isar = await db;
    // Eliminar detalles antiguos
    final oldRecords = await _detalleVentaStore.find(isar);
    for (var r in oldRecords) {
      if (r.value['ventaIdFk'] == ventaId) {
        await _detalleVentaStore.record(r.key).delete(isar);
      }
    }
    // Guardar nuevos
    for (var item in detalles) {
      item.ventaIdFk = ventaId;
      final detKey = item.id != 0 ? item.id.toString() : 'detalle_${DateTime.now().millisecondsSinceEpoch}';
      await _detalleVentaStore.record(detKey).put(isar, item.toMap());
    }
  }

  // ==================== GASTOS ====================

  Future<void> guardarGasto(GastoEntity gasto) async {
    final isar = await db;
    final map = gasto.toMap();
    final key = gasto.id != 0 ? gasto.id.toString() : 'gasto_${DateTime.now().millisecondsSinceEpoch}';
    if (gasto.id == 0) {
      gasto.id = (await _gastoStore.count(isar)) + 1;
      map['id'] = gasto.id;
    }
    await _gastoStore.record(key).put(isar, map);
  }

  Future<List<GastoEntity>> obtenerGastos() async {
    final isar = await db;
    final records = await _gastoStore.find(isar);
    return records.map((e) => GastoEntity.fromMap(e.value)).toList();
  }

  Future<List<GastoEntity>> obtenerGastosPendientesSync() async => [];

  Future<void> actualizarSyncStatusGasto(int id, String nuevoEstado) async {}

  Future<double> obtenerTotalGastosPorRango(DateTime inicio, DateTime fin) async {
    final gastos = await obtenerGastos();
    double total = 0.0;
    for (var g in gastos) {
      final f = g.fecha;
      if (f != null && f.isAfter(inicio) && f.isBefore(fin)) {
        total += g.monto;
      }
    }
    return total;
  }

  // ==================== PEDIDOS Y DETALLES ====================

  Future<int> guardarPedido(PedidoEntity pedido) async {
    final isar = await db;
    final map = pedido.toMap();
    final key = pedido.id != 0 ? pedido.id.toString() : 'pedido_${DateTime.now().millisecondsSinceEpoch}';
    if (pedido.id == 0) {
      pedido.id = (await _pedidoStore.count(isar)) + 1;
      map['id'] = pedido.id;
    }
    await _pedidoStore.record(key).put(isar, map);
    return pedido.id;
  }

  Future<List<PedidoEntity>> obtenerPedidosPorLocalDestino(int localDestinoId) async {
    final isar = await db;
    final records = await _pedidoStore.find(isar);
    return records
        .map((e) => PedidoEntity.fromMap(e.value))
        .where((p) => p.localDestinoId == localDestinoId)
        .toList();
  }

  Future<List<PedidoEntity>> obtenerPedidosPorEstado(EstadoPedido estado, {int? localDestinoId}) async {
    final isar = await db;
    final records = await _pedidoStore.find(isar);
    var pedidos = records.map((e) => PedidoEntity.fromMap(e.value)).toList();
    pedidos = pedidos.where((p) => p.estado == estado).toList();
    if (localDestinoId != null) {
      pedidos = pedidos.where((p) => p.localDestinoId == localDestinoId).toList();
    }
    return pedidos;
  }

  Future<PedidoEntity?> obtenerPedidoPorId(int id) async {
    final isar = await db;
    final record = await _pedidoStore.record(id.toString()).get(isar);
    return record != null ? PedidoEntity.fromMap(record) : null;
  }

  Future<PedidoEntity?> obtenerPedidoPorSupabaseId(String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    final records = await _pedidoStore.find(isar);
    for (var r in records) {
      if (r.value['supabaseId'] == supabaseId) {
        return PedidoEntity.fromMap(r.value);
      }
    }
    return null;
  }

  Future<void> actualizarEstadoPedido(int id, EstadoPedido nuevoEstado) async {
    final isar = await db;
    final record = await _pedidoStore.record(id.toString()).get(isar);
    if (record != null) {
      record['estado'] = nuevoEstado.name;
      await _pedidoStore.record(id.toString()).put(isar, record);
    }
  }

  Future<void> cancelarPedido(int id) async {
    final isar = await db;
    final record = await _pedidoStore.record(id.toString()).get(isar);
    if (record != null) {
      record['estado'] = EstadoPedido.cancelado.name;
      record['sincronizado'] = false;
      await _pedidoStore.record(id.toString()).put(isar, record);
    }
  }

  Future<void> actualizarSyncStatusPedido(int id, bool sincronizado) async {
    final isar = await db;
    final record = await _pedidoStore.record(id.toString()).get(isar);
    if (record != null) {
      record['sincronizado'] = sincronizado;
      record['fechaSincronizacion'] = DateTime.now().toIso8601String();
      await _pedidoStore.record(id.toString()).put(isar, record);
    }
  }

  Future<List<PedidoEntity>> obtenerPedidosPendientesSync() async => [];

  // ==================== DETALLES DE PEDIDO ====================

  Future<int> guardarDetallePedido(DetallePedidoEntity detalle) async {
    final isar = await db;
    final key = detalle.id != 0 ? detalle.id.toString() : 'det_pedido_${DateTime.now().millisecondsSinceEpoch}';
    if (detalle.id == 0) {
      detalle.id = (await _detallePedidoStore.count(isar)) + 1;
    }
    await _detallePedidoStore.record(key).put(isar, detalle.toMap());
    return detalle.id;
  }

  Future<List<DetallePedidoEntity>> obtenerDetallesPorPedido(int pedidoId) async {
    final isar = await db;
    final records = await _detallePedidoStore.find(isar);
    return records
        .map((e) => DetallePedidoEntity.fromMap(e.value))
        .where((d) => d.pedidoId == pedidoId)
        .toList();
  }

  Future<void> eliminarDetallesPorPedido(int pedidoId) async {
    final isar = await db;
    final records = await _detallePedidoStore.find(isar);
    for (var r in records) {
      if (r.value['pedidoId'] == pedidoId) {
        await _detallePedidoStore.record(r.key).delete(isar);
      }
    }
  }

  // ==================== LOCALES ====================

  Future<LocalEntity?> obtenerLocalPorId(int id) async {
    final isar = await db;
    final record = await _localStore.record(id.toString()).get(isar);
    return record != null ? _mapToLocal(record) : null;
  }

  Future<LocalEntity?> obtenerLocalPorSupabaseId(String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    final records = await _localStore.find(isar);
    for (var r in records) {
      if (r.value['supabaseId'] == supabaseId) {
        return _mapToLocal(r.value);
      }
    }
    return null;
  }

  Future<int> guardarLocal(LocalEntity local) async {
    final isar = await db;
    final map = _localToMap(local);
    final key = local.id != 0 ? local.id.toString() : 'local_${DateTime.now().millisecondsSinceEpoch}';
    if (local.id == 0) {
      local.id = (await _localStore.count(isar)) + 1;
      map['id'] = local.id;
    }
    await _localStore.record(key).put(isar, map);
    return local.id;
  }

  Future<List<LocalEntity>> obtenerLocales({bool soloActivos = true}) async {
    final isar = await db;
    final records = await _localStore.find(isar);
    var locales = records.map((e) => _mapToLocal(e.value)).toList();
    if (soloActivos) {
      locales = locales.where((l) => l.activo).toList();
    }
    return locales;
  }

  Future<LocalEntity?> obtenerLocalActivo() async {
    final locales = await obtenerLocales(soloActivos: true);
    return locales.isNotEmpty ? locales.first : null;
  }

  Future<bool> eliminarLocal(int id) async {
    final isar = await db;
    // Verificar dependencias (pedidos)
    final pedidos = await obtenerPedidosPorLocalDestino(id);
    if (pedidos.isNotEmpty) {
      debugPrint('⚠️ No se puede eliminar el local $id porque tiene pedidos asociados.');
      return false;
    }
    // Actualizar usuarios que tenían este local
    final usuarios = await obtenerUsuarios();
    for (var u in usuarios) {
      if (u.localId == id) {
        u.localId = null;
        await guardarUsuario(u);
      }
    }
    // Actualizar departamentos que tenían este local
    final departamentos = await obtenerDepartamentos();
    for (var d in departamentos) {
      if (d.localId == id) {
        d.localId = null;
        await guardarDepartamento(d);
      }
    }
    return await _localStore.record(id.toString()).delete(isar) != null;
  }

  Future<void> actualizarSyncStatusLocal(int id, bool sincronizado) async {
    final isar = await db;
    final record = await _localStore.record(id.toString()).get(isar);
    if (record != null) {
      record['sincronizado'] = sincronizado;
      record['fechaSincronizacion'] = DateTime.now().toIso8601String();
      await _localStore.record(id.toString()).put(isar, record);
    }
  }

  Future<List<LocalEntity>> obtenerLocalesPendientesSync() async => [];

  // ==================== DEPARTAMENTOS ====================

  Future<int> guardarDepartamento(DepartamentoEntity departamento) async {
    final isar = await db;
    final map = departamento.toMap();
    final key = departamento.id != 0 ? departamento.id.toString() : 'depto_${DateTime.now().millisecondsSinceEpoch}';
    if (departamento.id == 0) {
      departamento.id = (await _departamentoStore.count(isar)) + 1;
      map['id'] = departamento.id;
    }
    await _departamentoStore.record(key).put(isar, map);
    return departamento.id;
  }

  Future<List<DepartamentoEntity>> obtenerDepartamentos({bool? soloActivos = true, int? localId}) async {
    final isar = await db;
    final records = await _departamentoStore.find(isar);
    var deptos = records.map((e) => DepartamentoEntity.fromMap(e.value)).toList();
    if (soloActivos == true) {
      deptos = deptos.where((d) => d.activo).toList();
    }
    if (localId != null) {
      deptos = deptos.where((d) => d.localId == localId).toList();
    }
    return deptos;
  }

  Future<DepartamentoEntity?> obtenerDepartamentoPorId(int id) async {
    final isar = await db;
    final record = await _departamentoStore.record(id.toString()).get(isar);
    return record != null ? DepartamentoEntity.fromMap(record) : null;
  }

  Future<bool> eliminarDepartamento(int id) async {
    final isar = await db;
    return await _departamentoStore.record(id.toString()).delete(isar) != null;
  }

  Future<void> actualizarSyncStatusDepartamento(int id, bool sincronizado) async {
    final isar = await db;
    final record = await _departamentoStore.record(id.toString()).get(isar);
    if (record != null) {
      record['sincronizado'] = sincronizado;
      record['fechaSincronizacion'] = DateTime.now().toIso8601String();
      await _departamentoStore.record(id.toString()).put(isar, record);
    }
  }

  Future<List<DepartamentoEntity>> obtenerDepartamentosPendientesSync() async => [];

  Future<int> contarProductosPorDepartamento(int departamentoId) async {
    final depto = await obtenerDepartamentoPorId(departamentoId);
    if (depto == null) return 0;
    final productos = await obtenerProductos();
    return productos.where((p) => p.categoria.trim().toLowerCase() == depto.nombre.trim().toLowerCase()).length;
  }

  // ==================== PROVEEDORES ====================

  Future<int> guardarProveedor(ProveedorEntity proveedor) async {
    final isar = await db;
    final map = proveedor.toMap();
    final key = proveedor.id != 0 ? proveedor.id.toString() : 'prov_${DateTime.now().millisecondsSinceEpoch}';
    if (proveedor.id == 0) {
      proveedor.id = (await _proveedorStore.count(isar)) + 1;
      map['id'] = proveedor.id;
    }
    await _proveedorStore.record(key).put(isar, map);
    return proveedor.id;
  }

  Future<List<ProveedorEntity>> obtenerProveedores({bool soloActivos = true}) async {
    final isar = await db;
    final records = await _proveedorStore.find(isar);
    var proveedores = records.map((e) => ProveedorEntity.fromMap(e.value)).toList();
    if (soloActivos) {
      proveedores = proveedores.where((p) => p.activo).toList();
    }
    return proveedores;
  }

  Future<ProveedorEntity?> obtenerProveedorPorId(int id) async {
    final isar = await db;
    final record = await _proveedorStore.record(id.toString()).get(isar);
    return record != null ? ProveedorEntity.fromMap(record) : null;
  }

  Future<ProveedorEntity?> obtenerProveedorPorSupabaseId(String supabaseId) async {
    // En demo, devolvemos null
    return null;
  }

  Future<List<ProveedorEntity>> buscarProveedores(String query) async {
    final proveedores = await obtenerProveedores(soloActivos: false);
    final q = query.toLowerCase();
    return proveedores.where((p) => p.nombre.toLowerCase().contains(q) || (p.empresa?.toLowerCase().contains(q) ?? false)).toList();
  }

  Future<void> desactivarProveedor(int id) async {
    final proveedor = await obtenerProveedorPorId(id);
    if (proveedor != null) {
      proveedor.activo = false;
      await guardarProveedor(proveedor);
    }
  }

  Future<List<ProveedorEntity>> obtenerProveedoresPendientesSync() async => [];

  Future<void> actualizarSyncStatusProveedor(int id, bool sincronizado) async {
    final isar = await db;
    final record = await _proveedorStore.record(id.toString()).get(isar);
    if (record != null) {
      record['sincronizado'] = sincronizado;
      record['fechaSincronizacion'] = DateTime.now().toIso8601String();
      await _proveedorStore.record(id.toString()).put(isar, record);
    }
  }

  Future<bool> eliminarProveedor(int id) async {
    final productos = await obtenerProductosPorProveedor(id);
    if (productos.isNotEmpty) return false;
    final isar = await db;
    return await _proveedorStore.record(id.toString()).delete(isar) != null;
  }

  Future<List<ProductoEntity>> obtenerProductosPorProveedor(int proveedorId) async {
    final productos = await obtenerProductos();
    return productos.where((p) => p.proveedorId == proveedorId).toList();
  }

  // ==================== CATEGORÍAS ====================

  Future<void> guardarCategoria(CategoriaEntity categoria) async {
    final isar = await db;
    final key = categoria.id != 0 ? categoria.id.toString() : 'cat_${DateTime.now().millisecondsSinceEpoch}';
    if (categoria.id == 0) {
      categoria.id = (await _categoriaStore.count(isar)) + 1;
    }
    await _categoriaStore.record(key).put(isar, categoria.toMap());
  }

  Future<List<CategoriaEntity>> obtenerCategorias({bool soloActivas = true}) async {
    final isar = await db;
    final records = await _categoriaStore.find(isar);
    var categorias = records.map((e) => CategoriaEntity.fromMap(e.value)).toList();
    if (soloActivas) {
      categorias = categorias.where((c) => c.activo).toList();
    }
    return categorias;
  }

  Future<CategoriaEntity?> obtenerCategoriaPorId(int id) async {
    final isar = await db;
    final record = await _categoriaStore.record(id.toString()).get(isar);
    return record != null ? CategoriaEntity.fromMap(record) : null;
  }

  Future<CategoriaEntity?> obtenerCategoriaPorSupabaseId(String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    final records = await _categoriaStore.find(isar);
    for (var r in records) {
      if (r.value['supabaseId'] == supabaseId) {
        return CategoriaEntity.fromMap(r.value);
      }
    }
    return null;
  }

  Future<List<CategoriaEntity>> obtenerCategoriasPendientesSync() async => [];

  // ==================== MARCAS ====================

  Future<void> guardarMarca(MarcaEntity marca) async {
    final isar = await db;
    final key = marca.id != 0 ? marca.id.toString() : 'marca_${DateTime.now().millisecondsSinceEpoch}';
    if (marca.id == 0) {
      marca.id = (await _marcaStore.count(isar)) + 1;
    }
    await _marcaStore.record(key).put(isar, marca.toMap());
  }

  Future<List<MarcaEntity>> obtenerMarcas({bool soloActivas = true}) async {
    final isar = await db;
    final records = await _marcaStore.find(isar);
    var marcas = records.map((e) => MarcaEntity.fromMap(e.value)).toList();
    if (soloActivas) {
      marcas = marcas.where((m) => m.activo).toList();
    }
    return marcas;
  }

  Future<MarcaEntity?> obtenerMarcaPorId(int id) async {
    final isar = await db;
    final record = await _marcaStore.record(id.toString()).get(isar);
    return record != null ? MarcaEntity.fromMap(record) : null;
  }

  Future<MarcaEntity?> obtenerMarcaPorSupabaseId(String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    final records = await _marcaStore.find(isar);
    for (var r in records) {
      if (r.value['supabaseId'] == supabaseId) {
        return MarcaEntity.fromMap(r.value);
      }
    }
    return null;
  }

  Future<List<MarcaEntity>> obtenerMarcasPendientesSync() async => [];

  Future<void> actualizarSyncStatusMarca(int id, String nuevoEstado) async {}

  Future<List<MarcaEntity>> buscarMarcas(String query) async {
    final marcas = await obtenerMarcas(soloActivas: false);
    final q = query.toLowerCase();
    return marcas.where((m) => m.nombre.toLowerCase().contains(q)).toList();
  }

  Future<bool> eliminarMarca(int id) async {
    final isar = await db;
    final productos = await obtenerProductos();
    final marca = await obtenerMarcaPorId(id);
    if (marca != null) {
      final asociados = productos.where((p) => p.marcaSupabaseId == marca.supabaseId).toList();
      if (asociados.isNotEmpty) {
        marca.activo = false;
        await guardarMarca(marca);
        return false;
      }
    }
    return await _marcaStore.record(id.toString()).delete(isar) != null;
  }

  // ==================== CLIENTES ====================

  Future<ClienteEntity> guardarCliente(ClienteEntity cliente) async {
    final isar = await db;
    final key = cliente.id != 0 ? cliente.id.toString() : 'cliente_${DateTime.now().millisecondsSinceEpoch}';
    if (cliente.id == 0) {
      cliente.id = (await _clienteStore.count(isar)) + 1;
    }
    await _clienteStore.record(key).put(isar, cliente.toMap());
    return cliente;
  }

  Future<List<ClienteEntity>> obtenerClientes({bool soloActivos = true, bool soloFrecuentes = false}) async {
    final isar = await db;
    final records = await _clienteStore.find(isar);
    var clientes = records.map((e) => ClienteEntity.fromMap(e.value)).toList();
    if (soloActivos) {
      clientes = clientes.where((c) => c.activo).toList();
    }
    if (soloFrecuentes) {
      clientes = clientes.where((c) => c.frecuente).toList();
    }
    return clientes;
  }

  Future<ClienteEntity?> obtenerClientePorId(int id) async {
    final isar = await db;
    final record = await _clienteStore.record(id.toString()).get(isar);
    return record != null ? ClienteEntity.fromMap(record) : null;
  }

  Future<ClienteEntity?> obtenerClientePorSupabaseId(String supabaseId) async {
    final isar = await db;
    if (supabaseId.isEmpty) return null;
    final records = await _clienteStore.find(isar);
    for (var r in records) {
      if (r.value['supabaseId'] == supabaseId) {
        return ClienteEntity.fromMap(r.value);
      }
    }
    return null;
  }

  Future<List<ClienteEntity>> buscarClientes(String query, {bool soloFrecuentes = false}) async {
    final clientes = await obtenerClientes(soloActivos: false);
    final q = query.toLowerCase();
    return clientes.where((c) =>
      c.nombre.toLowerCase().contains(q) ||
      (c.documento?.toLowerCase().contains(q) ?? false) ||
      (c.telefono?.contains(q) ?? false)
    ).toList();
  }

  Future<bool> eliminarCliente(int id) async {
    final isar = await db;
    return await _clienteStore.record(id.toString()).delete(isar) != null;
  }

  Future<void> actualizarSyncStatusCliente(int id, String nuevoEstado) async {}

  Future<List<ClienteEntity>> obtenerClientesPendientesSync() async => [];

  Future<void> actualizarEstadisticasCliente(int clienteId, double montoCompra) async {
    final cliente = await obtenerClientePorId(clienteId);
    if (cliente != null) {
      cliente.totalCompras += montoCompra;
      cliente.cantidadCompras += 1;
      cliente.ultimaCompra = DateTime.now();
      if (cliente.cantidadCompras >= 5) cliente.frecuente = true;
      await guardarCliente(cliente);
    }
  }

  // ==================== LOTES ====================

  Future<void> guardarLote(LoteEntity lote) async {
    final isar = await db;
    final key = lote.id != 0 ? lote.id.toString() : 'lote_${DateTime.now().millisecondsSinceEpoch}';
    if (lote.id == 0) {
      lote.id = (await _loteStore.count(isar)) + 1;
    }
    await _loteStore.record(key).put(isar, lote.toMap());
  }

  Future<List<LoteEntity>> obtenerTodosLosLotes() async {
    final isar = await db;
    final records = await _loteStore.find(isar);
    return records.map((e) => LoteEntity.fromMap(e.value)).toList();
  }

  Future<LoteEntity?> obtenerLotePorId(int id) async {
    final isar = await db;
    final record = await _loteStore.record(id.toString()).get(isar);
    return record != null ? LoteEntity.fromMap(record) : null;
  }

  Future<double> obtenerStockTotalPorProducto(int productoId) async {
    final lotes = await obtenerTodosLosLotes();
    double total = 0.0;
    for (var l in lotes) {
      if (l.productoId == productoId && l.estado == 'activo') {
        total += l.cantidadRestante;
      }
    }
    return total;
  }

  Future<List<LoteEntity>> obtenerLotesActivos(int productoId, {bool priorizarVencimiento = true}) async {
    final lotes = await obtenerTodosLosLotes();
    var activos = lotes.where((l) => l.productoId == productoId && l.estado == 'activo' && l.cantidadRestante > 0).toList();
    if (priorizarVencimiento) {
      activos.sort((a, b) {
        if (a.fechaVencimiento != null && b.fechaVencimiento != null) {
          return a.fechaVencimiento!.compareTo(b.fechaVencimiento!);
        }
        if (a.fechaVencimiento != null) return -1;
        if (b.fechaVencimiento != null) return 1;
        return a.fechaIngreso.compareTo(b.fechaIngreso);
      });
    } else {
      activos.sort((a, b) => a.fechaIngreso.compareTo(b.fechaIngreso));
    }
    return activos;
  }

  Future<LoteEntity?> obtenerLoteParaVenta(int productoId, {bool priorizarVencimiento = true}) async {
    final lotes = await obtenerLotesActivos(productoId, priorizarVencimiento: priorizarVencimiento);
    return lotes.isNotEmpty ? lotes.first : null;
  }

  Future<bool> descontarLote(int loteId, double cantidad) async {
    final lote = await obtenerLotePorId(loteId);
    if (lote == null || lote.cantidadRestante < cantidad) return false;
    lote.cantidadRestante -= cantidad;
    if (lote.cantidadRestante <= 0) {
      lote.cantidadRestante = 0;
      lote.estado = 'agotado';
    }
    lote.sincronizado = false;
    await guardarLote(lote);
    return true;
  }

  Future<bool> eliminarLote(int id) async {
    final lote = await obtenerLotePorId(id);
    if (lote == null || lote.cantidadRestante > 0) return false;
    final isar = await db;
    return await _loteStore.record(id.toString()).delete(isar) != null;
  }

  Future<int> contarLotes() async => (await obtenerTodosLosLotes()).length;

  Future<List<LoteEntity>> obtenerLotesPendientes() async {
    final lotes = await obtenerTodosLosLotes();
    return lotes.where((l) => l.estado == 'pendiente').toList();
  }

  Future<List<LoteEntity>> obtenerLotesHistorial() async {
    final lotes = await obtenerTodosLosLotes();
    return lotes.where((l) => l.estado == 'agotado' || l.estado == 'vencido').toList();
  }

  Future<List<LoteEntity>> obtenerLotesPendientesSync() async => [];

  Future<void> guardarMovimientoLote(MovimientoLoteEntity movimiento) async {
    final isar = await db;
    final key = movimiento.id != 0 ? movimiento.id.toString() : 'mov_lote_${DateTime.now().millisecondsSinceEpoch}';
    if (movimiento.id == 0) {
      movimiento.id = (await _movimientoLoteStore.count(isar)) + 1;
    }
    await _movimientoLoteStore.record(key).put(isar, movimiento.toMap());
  }

  Future<List<MovimientoLoteEntity>> obtenerMovimientosPorLote(int loteId) async {
    final isar = await db;
    final records = await _movimientoLoteStore.find(isar);
    return records
        .map((e) => MovimientoLoteEntity.fromMap(e.value))
        .where((m) => m.loteId == loteId)
        .toList();
  }

  Future<List<MovimientoLoteEntity>> obtenerMovimientosLotePendientesSync() async => [];

  Future<Map<String, dynamic>> migrarStockExistenteALotes() async {
    // Demo: solo devolvemos un resumen falso
    return {
      'success': true,
      'lotesCreados': 0,
      'productosSinStock': 0,
      'productosConLotesPrevios': 0,
      'totalProductos': await contarProductos(),
      'error': null,
    };
  }

  Future<bool> verificarLote({
    required int loteId,
    required String codigoBarras,
    required double cantidadRecibida,
    required int usuarioId,
  }) async {
    final lote = await obtenerLotePorId(loteId);
    if (lote == null || lote.estado != 'pendiente') return false;
    lote.codigoLoteProveedor = codigoBarras;
    lote.cantidadRestante = cantidadRecibida;
    lote.estado = 'activo';
    lote.sincronizado = false;
    await guardarLote(lote);
    final producto = await obtenerProductoPorId(lote.productoId);
    if (producto != null) {
      producto.stock += cantidadRecibida;
      await guardarProducto(producto);
    }
    await guardarMovimientoLote(MovimientoLoteEntity()
      ..loteId = lote.id
      ..tipo = 'activacion'
      ..cantidad = cantidadRecibida
      ..fecha = DateTime.now()
      ..usuarioId = usuarioId
      ..observaciones = 'Lote activado desde pedido'
      ..sincronizado = false);
    return true;
  }

  // ==================== CÓDIGOS DE BARRAS ALIAS ====================

  Future<void> guardarCodigoAlias(CodigoBarrasAliasEntity alias) async {
    final isar = await db;
    final key = alias.id != 0 ? alias.id.toString() : 'alias_${DateTime.now().millisecondsSinceEpoch}';
    if (alias.id == 0) {
      alias.id = (await _codigoAliasStore.count(isar)) + 1;
    }
    await _codigoAliasStore.record(key).put(isar, alias.toMap());
  }

  Future<CodigoBarrasAliasEntity?> obtenerAliasPorCodigo(String codigo) async {
    final isar = await db;
    final records = await _codigoAliasStore.find(isar);
    for (var r in records) {
      if (r.value['codigo'] == codigo && r.value['activo'] == true) {
        return CodigoBarrasAliasEntity.fromMap(r.value);
      }
    }
    return null;
  }

  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPorProducto(int productoId) async {
    final isar = await db;
    final records = await _codigoAliasStore.find(isar);
    return records
        .map((e) => CodigoBarrasAliasEntity.fromMap(e.value))
        .where((a) => a.productoId == productoId && a.activo)
        .toList();
  }

  Future<void> desactivarAlias(int aliasId) async {
    final isar = await db;
    final record = await _codigoAliasStore.record(aliasId.toString()).get(isar);
    if (record != null) {
      record['activo'] = false;
      record['sincronizado'] = false;
      await _codigoAliasStore.record(aliasId.toString()).put(isar, record);
    }
  }

  Future<List<CodigoBarrasAliasEntity>> obtenerAliasPendientesSync() async => [];

  // ==================== MOVIMIENTOS DE INVENTARIO ====================

  Future<void> guardarMovimientoInventario(MovimientoInventarioEntity movimiento) async {
    final isar = await db;
    final key = movimiento.id != 0 ? movimiento.id.toString() : 'mov_inv_${DateTime.now().millisecondsSinceEpoch}';
    if (movimiento.id == 0) {
      movimiento.id = (await _movimientoInventarioStore.count(isar)) + 1;
    }
    await _movimientoInventarioStore.record(key).put(isar, movimiento.toMap());
  }

  Future<List<MovimientoInventarioEntity>> obtenerMovimientosPendientesSync() async => [];

  Future<void> actualizarSyncStatusMovimiento(int id, String nuevoEstado) async {}

  // ==================== TURNOS ====================

  Future<void> guardarTurno(TurnoEntity turno) async {
    final isar = await db;
    final key = turno.id != 0 ? turno.id.toString() : 'turno_${DateTime.now().millisecondsSinceEpoch}';
    if (turno.id == 0) {
      turno.id = (await _turnoStore.count(isar)) + 1;
    }
    await _turnoStore.record(key).put(isar, turno.toMap());
  }

  Future<List<TurnoEntity>> obtenerTurnos() async {
    final isar = await db;
    final records = await _turnoStore.find(isar);
    return records.map((e) => TurnoEntity.fromMap(e.value)).toList();
  }

  Future<TurnoEntity?> obtenerTurnoAbiertoPorUsuario(int usuarioId) async {
    final turnos = await obtenerTurnos();
    for (var t in turnos) {
      if (t.usuarioId == usuarioId && t.estado == 'abierto') {
        return t;
      }
    }
    return null;
  }

  Future<void> cerrarTurno(int turnoId, double montoFinal) async {
    final isar = await db;
    final record = await _turnoStore.record(turnoId.toString()).get(isar);
    if (record != null) {
      record['fechaCierre'] = DateTime.now().toIso8601String();
      record['montoFinal'] = montoFinal;
      record['estado'] = 'cerrado';
      record['syncStatus'] = 'pending';
      await _turnoStore.record(turnoId.toString()).put(isar, record);
    }
  }

  Future<List<TurnoEntity>> obtenerTurnosPendientes() async => [];

  Future<void> marcarTurnoComoSincronizado(int turnoId) async {}

  // ==================== RECEPCIONES ====================

  Future<int> guardarRecepcion(RecepcionEntity recepcion) async {
    final isar = await db;
    final key = recepcion.id != 0 ? recepcion.id.toString() : 'recepcion_${DateTime.now().millisecondsSinceEpoch}';
    if (recepcion.id == 0) {
      recepcion.id = (await _recepcionStore.count(isar)) + 1;
    }
    await _recepcionStore.record(key).put(isar, recepcion.toMap());
    return recepcion.id;
  }

  Future<RecepcionEntity?> obtenerRecepcionPorPedido(int pedidoId) async {
    final isar = await db;
    final records = await _recepcionStore.find(isar);
    for (var r in records) {
      if (r.value['pedidoId'] == pedidoId) {
        return RecepcionEntity.fromMap(r.value);
      }
    }
    return null;
  }

  Future<void> actualizarSyncStatusRecepcion(int id, bool sincronizado) async {}

  // ==================== TELEGRAM CONFIG ====================

  Future<TelegramConfigEntity?> obtenerTelegramConfigPorUsuario(int usuarioId) async {
    final isar = await db;
    final records = await _telegramConfigStore.find(isar);
    for (var r in records) {
      if (r.value['usuarioId'] == usuarioId) {
        return TelegramConfigEntity.fromMap(r.value);
      }
    }
    return null;
  }

  Future<List<TelegramConfigEntity>> obtenerTodasTelegramConfigs() async {
    final isar = await db;
    final records = await _telegramConfigStore.find(isar);
    return records.map((e) => TelegramConfigEntity.fromMap(e.value)).toList();
  }

  Future<List<TelegramConfigEntity>> obtenerTelegramConfigsPendientesSync() async => [];

  Future<int> guardarTelegramConfig(TelegramConfigEntity config) async {
    final isar = await db;
    final key = config.id != 0 ? config.id.toString() : 'telegram_${DateTime.now().millisecondsSinceEpoch}';
    if (config.id == 0) {
      config.id = (await _telegramConfigStore.count(isar)) + 1;
    }
    await _telegramConfigStore.record(key).put(isar, config.toMap());
    return config.id;
  }

  Future<TelegramConfigEntity?> obtenerTelegramConfig() async {
    final isar = await db;
    final record = await _telegramConfigStore.record('telegram_config').get(isar);
    return record != null ? TelegramConfigEntity.fromMap(record) : null;
  }

  Future<void> actualizarSyncStatusTelegramConfig(int id, bool sincronizado) async {}

  Future<List<TelegramConfigEntity>> obtenerTelegramConfigs() async {
    final isar = await db;
    final records = await _telegramConfigStore.find(isar);
    return records.map((e) => TelegramConfigEntity.fromMap(e.value)).toList();
  }

  Future<void> eliminarTelegramConfig(int id) async {
    final isar = await db;
    await _telegramConfigStore.record(id.toString()).delete(isar);
  }

  // ==================== LOGS ====================

  Future<void> guardarLog(LogEntity log) async {
    final isar = await db;
    final key = log.id != 0 ? log.id.toString() : 'log_${DateTime.now().millisecondsSinceEpoch}';
    if (log.id == 0) {
      log.id = (await _logStore.count(isar)) + 1;
    }
    await _logStore.record(key).put(isar, log.toMap());
  }

  Future<List<LogEntity>> obtenerLogs() async {
    final isar = await db;
    final records = await _logStore.find(isar);
    return records.map((e) => LogEntity.fromMap(e.value)).toList();
  }

  Future<List<LogEntity>> obtenerLogsPendientesSync() async => [];

  Future<void> marcarLogsComoSincronizados(List<int> ids) async {}

  // ==================== HISTORIAL DE CÓDIGOS ====================

  Future<List<HistorialCodigoItem>> obtenerHistorialCodigosPorProducto(int productoId) async {
    final List<HistorialCodigoItem> items = [];
    // Alias
    final aliasList = await obtenerAliasPorProducto(productoId);
    for (var a in aliasList) {
      items.add(HistorialCodigoItem(
        codigo: a.codigo,
        proveedorNombre: null,
        fechaIngreso: a.fechaAsignacion ?? DateTime.now(),
        fechaVencimiento: null,
        cantidad: 0,
        precio: 0,
        tipo: 'alias',
      ));
    }
    // Lotes
    final lotes = await obtenerTodosLosLotes();
    for (var l in lotes) {
      if (l.productoId == productoId && l.codigoLoteProveedor != null && l.codigoLoteProveedor!.isNotEmpty) {
        items.add(HistorialCodigoItem(
          codigo: l.codigoLoteProveedor!,
          proveedorNombre: null,
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

  // ==================== DASHBOARD / ESTADÍSTICAS ====================

  Future<Map<String, dynamic>> obtenerResumenDashboard() async {
    final hoy = DateTime.now();
    final inicioHoy = DateTime(hoy.year, hoy.month, hoy.day);
    final inicioSemana = inicioHoy.subtract(Duration(days: hoy.weekday - 1));
    final inicioMes = DateTime(hoy.year, hoy.month, 1);
    final finDia = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59, 999);

    // Calcular totales con await
    final ventasHoy = await obtenerVentasPorRango(inicioHoy, finDia);
    final ventasSemana = await obtenerVentasPorRango(inicioSemana, finDia);
    final ventasMes = await obtenerVentasPorRango(inicioMes, finDia);
    final ventasAyer = await obtenerVentasPorRango(
      inicioHoy.subtract(const Duration(days: 1)),
      inicioHoy.subtract(const Duration(seconds: 1)),
    );

    double totalHoy = 0.0;
    for (var v in ventasHoy) {
      totalHoy += v.total;
    }
    double totalSemana = 0.0;
    for (var v in ventasSemana) {
      totalSemana += v.total;
    }
    double totalMes = 0.0;
    for (var v in ventasMes) {
      totalMes += v.total;
    }
    double totalAyer = 0.0;
    for (var v in ventasAyer) {
      totalAyer += v.total;
    }

    final totalGastosMes = await obtenerTotalGastosPorRango(inicioMes, finDia);
    final variacion = totalHoy > 0 && totalAyer > 0
        ? ((totalHoy - totalAyer) / totalAyer) * 100
        : 0.0;

    final ultimasVentas = await obtenerUltimasVentas(5);
    final topProductos = await obtenerProductosMasVendidos(5);
    final stockBajo = await obtenerProductosStockBajo();
    final ventasPorEmpleado = await obtenerVentasPorEmpleado(inicioSemana, finDia);
    final ventasPorDia = await obtenerVentasPorDia(7);
    final countVentasHoy = ventasHoy.length;

    return {
      'totalHoy': totalHoy,
      'totalSemana': totalSemana,
      'totalMes': totalMes,
      'totalGastosMes': totalGastosMes,
      'variacion': variacion,
      'ventasHoy': countVentasHoy,
      'ultimasVentas': ultimasVentas,
      'topProductos': topProductos,
      'stockBajo': stockBajo,
      'ventasPorEmpleado': ventasPorEmpleado,
      'ventasPorDia': ventasPorDia,
    };
  }

  Future<List<VentaEntity>> obtenerVentasPorPeriodo(String periodo) async {
    final now = DateTime.now();
    late DateTime inicioLocal, finLocal;
    if (periodo == 'todos') {
      return await obtenerVentas();
    } else if (periodo == 'dia') {
      inicioLocal = DateTime(now.year, now.month, now.day, 0, 0, 0);
      finLocal = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
    } else if (periodo == 'semana') {
      inicioLocal = DateTime(now.year, now.month, now.day - (now.weekday - 1), 0, 0, 0);
      finLocal = inicioLocal.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
    } else if (periodo == 'mes') {
      inicioLocal = DateTime(now.year, now.month, 1, 0, 0, 0);
      finLocal = DateTime(now.year, now.month + 1, 0, 23, 59, 59, 999);
    } else {
      return await obtenerVentas();
    }
    return await obtenerVentasPorRango(inicioLocal, finLocal);
  }

  // Métodos auxiliares para el dashboard
  Future<List<Map<String, dynamic>>> obtenerProductosMasVendidos(int limite) async {
    final detalles = await _detalleVentaStore.find(await db);
    final Map<String, double> acumulado = {};
    for (var r in detalles) {
      final d = DetalleVentaEntity.fromMap(r.value);
      acumulado[d.nombreProducto] = (acumulado[d.nombreProducto] ?? 0) + d.cantidad;
    }
    final lista = acumulado.entries.map((e) => {'nombre': e.key, 'cantidad': e.value}).toList();
    lista.sort((a, b) => (b['cantidad'] as double).compareTo(a['cantidad'] as double));
    return lista.take(limite).toList();
  }

  Future<Map<String, double>> obtenerVentasPorEmpleado(DateTime inicio, DateTime fin) async {
    final ventas = await obtenerVentasPorRango(inicio, fin);
    final Map<String, double> resultado = {};
    for (var v in ventas) {
      resultado[v.empleado] = (resultado[v.empleado] ?? 0) + v.total;
    }
    return resultado;
  }

  Future<List<Map<String, dynamic>>> obtenerVentasPorDia(int cantidadDias) async {
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day - cantidadDias + 1);
    final fin = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59, 999);
    final ventas = await obtenerVentasPorRango(inicio, fin);
    final Map<String, double> agrupado = {};
    for (var v in ventas) {
      final f = v.fecha;
      if (f == null) continue;
      final dia = DateTime(f.year, f.month, f.day);
      final key = dia.toIso8601String().substring(0, 10);
      agrupado[key] = (agrupado[key] ?? 0) + v.total;
    }
    final keys = agrupado.keys.toList()..sort();
    return keys.map((key) => {'fecha': key, 'total': agrupado[key] ?? 0}).toList();
  }

  Future<double> obtenerTotalVentasPorRango(DateTime inicio, DateTime fin) async {
    final ventas = await obtenerVentasPorRango(inicio, fin);
    double total = 0.0;
    for (var v in ventas) {
      total += v.total;
    }
    return total;
  }



  // ==================== MÉTODOS ADICIONALES (reseteo, asignación) ====================

  Future<void> resetearSupabaseIdsIncorrectos() async {}
  Future<int> asignarSupabaseIdsAFaltantes() async => 0;

  // ==================== MÉTODOS PARA LOTES CON LOCAL (stubs sin localId) ====================

  // Estos métodos no son necesarios para la demo porque LoteEntity no tiene localId.
  // Los dejamos como stubs que devuelven listas vacías.
  Future<List<LoteEntity>> obtenerLotesPorLocal(int localId) async => [];
  Future<List<LoteEntity>> obtenerLotesPorLocalYEstado(int localId, String estado) async => [];
  Future<List<LoteEntity>> obtenerLotesPorProductoYLocal(int productoId, int localId) async => [];
  Future<Map<String, dynamic>> migrarLotesConLocal() async {
    return {'success': true, 'actualizados': 0, 'mensaje': 'Migración no necesaria en demo web'};
  }

    // ==================== RESET PARA DEMO ====================

  /// Elimina todos los datos y vuelve a cargar los datos de demo.
  /// Útil para reiniciar la demostración desde el iframe.
  Future<void> resetAllData() async {
    final isar = await db;

    // Lista de todos los stores que usamos
    final stores = [
      _userStore,
      _productStore,
      _gastoStore,
      _ventaStore,
      _detalleVentaStore,
      _pedidoStore,
      _detallePedidoStore,
      _localStore,
      _departamentoStore,
      _proveedorStore,
      _loteStore,
      _categoriaStore,
      _marcaStore,
      _clienteStore,
      _movimientoInventarioStore,
      _turnoStore,
      _recepcionStore,
      _telegramConfigStore,
      _codigoAliasStore,
      _movimientoLoteStore,
      _logStore,
    ];

    // Eliminar todos los registros de cada store
    for (var store in stores) {
      final records = await store.find(isar);
      for (var record in records) {
        await store.record(record.key).delete(isar);
      }
    }

    // Volver a poblar la base con datos de ejemplo
    await _inicializarDatosDemo();
    debugPrint('✅ Datos de demo reiniciados correctamente');
  }
}