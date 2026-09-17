import 'package:isar/isar.dart';

part 'nomina_pago_entity.g.dart';

/// Registro histórico de un pago de nómina a un empleado.
@collection
class NominaPagoEntity {
  Id id = Isar.autoIncrement;

  @Index()
  late int usuarioId;

  @Index()
  late DateTime fechaPago;

  late DateTime periodoInicio;
  late DateTime periodoFin;

  // ══════════════════════════════════════════════════════════════
  // DESGLOSE
  // ══════════════════════════════════════════════════════════════

  double salarioBase = 0;
  double comisiones = 0;
  double bonos = 0;
  double propinas = 0;
  double deducciones = 0;
  double totalNeto = 0;

  String moneda = 'USD';
  double? tasaBcv;                // si hubo conversión USD ↔ VES

  // ══════════════════════════════════════════════════════════════
  // OPCIONAL
  // ══════════════════════════════════════════════════════════════

  String? observaciones;
  String? comprobanteUrl;         // URL del recibo PDF en Storage

  // ══════════════════════════════════════════════════════════════
  // METADATA
  // ══════════════════════════════════════════════════════════════

  DateTime createdAt = DateTime.now();
  DateTime? fechaSincronizacion;
  String syncStatus = 'pending';
  String? supabaseId;

  NominaPagoEntity();

  @ignore
  double get totalBruto => salarioBase + comisiones + bonos + propinas;
}