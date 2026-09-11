// lib/features/pos/data/Local/entities/sembast_service.dart
import 'package:flutter/foundation.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';

class SembastService {
  SembastService._internal();
  static final SembastService _instance = SembastService._internal();
  factory SembastService() => _instance;

  late Database _db;

  final _userStore = stringMapStoreFactory.store('usuarios');
  final _productStore = stringMapStoreFactory.store('productos');
  final _ventaStore = stringMapStoreFactory.store('ventas');

  Future<void> init() async {
    // En Web, siempre usamos IndexedDB
    _db = await databaseFactoryWeb.openDatabase('boost_pos.db');
    await _seedDemoData();
  }

  Future<List<Map<String, dynamic>>> obtenerUsuarios() async {
    final records = await _userStore.find(_db);
    return records.map((e) => e.value).toList();
  }

  Future<Map<String, dynamic>?> validarLogin(String nombre, String pin) async {
    final users = await obtenerUsuarios();
    final nombreNorm = nombre.trim().toLowerCase();
    final pinNorm = pin.trim();
    for (final u in users) {
      if ((u['nombre'] as String).toLowerCase() == nombreNorm &&
          u['pin'] == pinNorm &&
          u['activo'] == true) {
        return u;
      }
    }
    return null;
  }

  Future<void> guardarUsuario(Map<String, dynamic> usuario) async {
    final id = usuario['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _userStore.record(id).put(_db, usuario);
  }

  Future<List<Map<String, dynamic>>> obtenerProductos() async {
    return (await _productStore.find(_db)).map((e) => e.value).toList();
  }

  Future<void> guardarProducto(Map<String, dynamic> producto) async {
    final id = producto['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _productStore.record(id).put(_db, producto);
  }

  Future<void> guardarVenta(Map<String, dynamic> venta) async {
    final id = venta['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();
    await _ventaStore.record(id).put(_db, venta);
  }

  Future<void> _seedDemoData() async {
    if (await _userStore.count(_db) == 0) {
      await _userStore.record('1').put(_db, {
        'id': 1,
        'nombre': 'Administrador',
        'pin': '1234',
        'rol': 'admin',
        'activo': true,
      });
      await _userStore.record('2').put(_db, {
        'id': 2,
        'nombre': 'yan camacaro',
        'pin': '1010',
        'rol': 'cajero',
        'activo': true,
      });
    }
  }
}