// venta_entity.dart
import 'package:isar/isar.dart';
import 'detalle_venta_entity.dart';

part 'venta_entity.g.dart';

@collection
class VentaEntity {
  Id id = Isar.autoIncrement;
  
  @Index()
  String? idSupabase; 
  
  DateTime? fecha;
  double total = 0.0;
  double subtotal = 0.0;
  double impuesto = 0.0;
  double tasaBcv = 0.0;
  double totalBolivares = 0.0;
  String metodoPago = '';
  int documento = 0;
  String empleado = 'Administrador / Catálogo';
  String? syncStatus = 'pending';
  int? clienteId;
  String? clienteNombre;
  String? clienteDocumento;
  // 🔥 Nuevos campos
  bool tieneDescuentoEspecial = false;
  double montoDescuentoTotal = 0.0;

  final items = IsarLinks<DetalleVentaEntity>();

  String get ventaIdString => idSupabase ?? '';
  String get empleadoNombre => empleado;
}