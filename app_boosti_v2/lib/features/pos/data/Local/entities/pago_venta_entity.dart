// lib/features/pos/data/Local/entities/pago_venta_entity.dart
import 'package:isar/isar.dart';

part 'pago_venta_entity.g.dart';

/// Registra cada pago aplicado a una venta.
///
/// Una venta puede tener **N** pagos (multipago), uno por método.
/// También soporta pago único donde habrá 1 sola fila.
@collection
class PagoVentaEntity {
  Id id = Isar.autoIncrement;

  @Index()
  String? supabaseId;

  @Index()
  String? tenantId;

  /// ID local (Isar) de la venta asociada.
  @Index()
  int? ventaIdFk;

  /// UUID de la venta en Supabase (para sync).
  @Index()
  String? ventaSupabaseId;

  /// ID local del pago (para sync con Supabase).
  int? idIsar;

  /// 'efectivo_usd' | 'efectivo_bs' | 'punto' | 'pago_movil'
  /// | 'transferencia_bs' | 'binance_pay' | 'transferencia_usdt'
  /// | 'zelle' | 'paypal' | 'otros'
  @Index()
  String metodo = 'efectivo_usd';

  /// Monto en la moneda del método (USD, VES o USDT).
  double monto = 0.0;

  /// 'USD' | 'VES' | 'USDT'
  String moneda = 'USD';

  /// Monto convertido a USD con la tasa del día.
  double montoUsdEquivalente = 0.0;

  /// Tasa BCV usada al momento del pago.
  double? tasaBcv;

  /// Número de referencia / confirmación.
  String? referencia;

  /// Últimos 4 dígitos de la tarjeta / instrumento.
  String? ultimosDigitos;

  /// Wallet destino si es cripto.
  String? walletDestino;

  /// Hash de transacción si es cripto.
  String? hashTransaccion;

  /// Red de la cripto (TRC20, ERC20, etc.).
  String? redCripto;

  /// Banco emisor si es transferencia.
  String? bancoEmisor;

  /// Titular del pago.
  String? titular;

  /// Fecha del pago.
  DateTime fecha = DateTime.now();

  /// 'pending' | 'synced' | 'failed'
  String syncStatus = 'pending';

  DateTime? createdAt;
  DateTime? updatedAt;

  PagoVentaEntity();

  // ──────────────── Serialización ────────────────

  Map<String, dynamic> toSupabaseJson() {
    return {
      if (supabaseId != null) 'id': supabaseId,
      'tenant_id': tenantId,
      'venta_id': ventaSupabaseId,
      'id_isar': id,
      'metodo': metodo,
      'monto': monto,
      'moneda': moneda,
      'monto_usd_equivalente': montoUsdEquivalente,
      'tasa_bcv': tasaBcv,
      'referencia': referencia,
      'ultimos_digitos': ultimosDigitos,
      'wallet_destino': walletDestino,
      'hash_transaccion': hashTransaccion,
      'banco_emisor': bancoEmisor,
      'titular': titular,
      'fecha': fecha.toIso8601String(),
      'created_at': (createdAt ?? fecha).toIso8601String(),
      'updated_at': (updatedAt ?? fecha).toIso8601String(),
    };
  }

  factory PagoVentaEntity.fromSupabase(Map<String, dynamic> json) {
    return PagoVentaEntity()
      ..supabaseId = json['id'] as String?
      ..tenantId = json['tenant_id'] as String?
      ..ventaSupabaseId = json['venta_id'] as String?
      ..idIsar = (json['id_isar'] as num?)?.toInt()
      ..metodo = json['metodo'] as String? ?? 'efectivo_usd'
      ..monto = (json['monto'] as num?)?.toDouble() ?? 0.0
      ..moneda = json['moneda'] as String? ?? 'USD'
      ..montoUsdEquivalente =
          (json['monto_usd_equivalente'] as num?)?.toDouble() ?? 0.0
      ..tasaBcv = (json['tasa_bcv'] as num?)?.toDouble()
      ..referencia = json['referencia'] as String?
      ..ultimosDigitos = json['ultimos_digitos'] as String?
      ..walletDestino = json['wallet_destino'] as String?
      ..hashTransaccion = json['hash_transaccion'] as String?
      ..bancoEmisor = json['banco_emisor'] as String?
      ..titular = json['titular'] as String?
      ..fecha = json['fecha'] != null
          ? DateTime.parse(json['fecha'] as String)
          : DateTime.now()
      ..syncStatus = 'synced'
      ..createdAt = json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null
      ..updatedAt = json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null;
  }
}