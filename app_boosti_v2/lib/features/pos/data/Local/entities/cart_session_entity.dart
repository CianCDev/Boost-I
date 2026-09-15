import 'package:isar/isar.dart';

part 'cart_session_entity.g.dart';

enum CartSessionStatus {
  enEspera,
  abandonado,
}

@collection
class CartSessionEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String sessionId;

  @Index()
  late int usuarioId;

  String nombre = 'Carrito';

  // ✅ Inicializado con lista vacía para evitar LateInitializationError
  List<String> itemsNombres = [];

  // ==================== CLIENTE (opcional) ====================
  int? clienteIsarId;
  String? clienteSupabaseId;
  String? clienteNombre;
  String? clienteDocumento;

  // ==================== NOTAS ====================
  String? notas;

  // ==================== CONFIG IVA (congelada) ====================
  String configIvaPais = 'VE';
  double configIvaPorcentaje = 0.16;
  bool configIvaPreciosIncluyenIva = true;
  bool ivaHabilitado = true;

  // ==================== TIMESTAMPS ====================
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  // ==================== ESTADO ====================
  @Enumerated(EnumType.name)
  CartSessionStatus status = CartSessionStatus.enEspera;

  List<CartSessionItem> items = [];

  CartSessionEntity();

  @ignore
  bool get esAbandonado =>
      DateTime.now().difference(createdAt) > const Duration(hours: 24);

  @ignore
  int get cantidadItems => items.length;

  @ignore
  double get total {
    return items.fold<double>(0.0, (sum, item) {
      return sum + (item.precioUnidad * item.cantidad);
    });
  }
}

@embedded
class CartSessionItem {
  String productoId = '';
  String productoNombre = '';
  String productoCodigoBarras = '';
  String productoCategoria = 'General';
  double precioUnidad = 0.0;
  double precioOriginal = 0.0;
  double cantidad = 0.0;
  bool esPesado = false;
  bool esDescuentoEspecial = false;

  CartSessionItem();
}