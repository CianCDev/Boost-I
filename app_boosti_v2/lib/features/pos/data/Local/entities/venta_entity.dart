// venta_entity.dart
import 'package:isar/isar.dart';
import 'detalle_venta_entity.dart';
import 'pago_venta_entity.dart';

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

  // Descuentos especiales (detal)
  bool tieneDescuentoEspecial = false;
  double montoDescuentoTotal = 0.0;

  // ──────────────── Ventas al Mayor (NUEVO) ────────────────

  /// 'detal' | 'mayor'
  @Index()
  String tipoVenta = 'detal';

  /// 'nota_entrega' | 'factura' | 'cotizacion'
  String? tipoDocumento;

  /// Si algún descuento de la venta requirió autorización.
  bool requiereAutorizacion = false;

  String? autorizadoPorNombre;
  String? autorizadoPorRol;
  DateTime? fechaAutorizacion;

  /// % de descuento total aplicado a la venta.
  double montoDescuentoPorcentaje = 0.0;

  /// 'contado' | 'credito'
  String tipoPago = 'contado';

  /// Si la venta se cobró con múltiples métodos.
  bool esMultipago = false;

  /// Snapshot fiscal del cliente al momento de la venta.
  String? clienteRif;
  String? clienteRazonSocial;

  // ──────────────── Relaciones ────────────────
  final items = IsarLinks<DetalleVentaEntity>();
  final pagos = IsarLinks<PagoVentaEntity>();

  String get ventaIdString => idSupabase ?? '';
  String get empleadoNombre => empleado;
}