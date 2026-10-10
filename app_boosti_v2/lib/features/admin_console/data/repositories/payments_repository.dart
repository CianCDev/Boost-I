import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/payment.dart';

/// Repositorio de pagos del Control Center.
///
/// Mapea la tabla `pagos`. Los pagos se registran manualmente (no hay
/// pasarela integrada), por eso [registrar] es un `INSERT` simple.
class PaymentsRepository {
  /// Se resuelve en cada llamada para no capturar el cliente antes de
  /// que `Supabase.initialize()` se haya ejecutado.
  SupabaseClient get _client => Supabase.instance.client;

  // ═══════════════════════════════════════════════════════════════
  // LECTURA
  // ═══════════════════════════════════════════════════════════════

  /// Lista los pagos de un tenant ordenados por `created_at` DESC.
  Future<List<Payment>> listarPorTenant(String tenantId) async {
    try {
      final response = await _client
          .from('pagos')
          .select('*')
          .eq('tenant_id', tenantId)
          .order('created_at', ascending: false);

      return response.map(Payment.fromMap).toList();
    } catch (e, stack) {
      debugPrint(
        '[PaymentsRepository] Error listando pagos de $tenantId: $e',
      );
      debugPrint('[PaymentsRepository] Stack: $stack');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ESCRITURA
  // ═══════════════════════════════════════════════════════════════

  /// Registra un pago manual.
  ///
  /// [estado] debe ser uno de: 'pendiente', 'pagado', 'fallido',
  /// 'reembolsado'. Lanza [Exception] si el insert falla.
  Future<void> registrar({
    required String tenantId,
    String? suscripcionId,
    required double monto,
    String moneda = 'USD',
    required String estado,
    String? metodo,
    String? referencia,
    DateTime? pagadoEn,
    DateTime? periodoInicio,
    DateTime? periodoFin,
    String? notas,
    required String? registradoPor,

    /// Factor multiplicativo de [monedaOriginal] a USD. Ver
    /// [Payment.tasaConversion] para el detalle de la invariante.
    double? tasaConversion,

    /// Monto y moneda tal como los ingresó el usuario. `monto` y
    /// `moneda` quedan normalizados a USD para los cálculos internos.
    double? montoOriginal,
    String? monedaOriginal,
  }) async {
    try {
      await _client.from('pagos').insert({
        'tenant_id': tenantId,
        'suscripcion_id': suscripcionId,
        'monto': monto,
        'moneda': moneda,
        'estado': estado,
        'metodo': metodo,
        'referencia': referencia,
        'pagado_en': pagadoEn?.toIso8601String(),
        'periodo_inicio': periodoInicio?.toIso8601String(),
        'periodo_fin': periodoFin?.toIso8601String(),
        'notas': notas,
        'registrado_por': registradoPor,
        'tasa_conversion': tasaConversion,
        'monto_original': montoOriginal,
        'moneda_original': monedaOriginal,
      });

      debugPrint(
        '[PaymentsRepository] Pago registrado: $monto $moneda ($estado)',
      );
    } catch (e, stack) {
      debugPrint('[PaymentsRepository] Error registrando pago: $e');
      debugPrint('[PaymentsRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo registrar el pago: $e'),
        stack,
      );
    }
  }

  /// Cambia el estado de un pago existente.
  ///
  /// Lanza [Exception] si el update falla o si el pago no existe.
  Future<void> actualizarEstado(String pagoId, String nuevoEstado) async {
    try {
      final response = await _client
          .from('pagos')
          .update({'estado': nuevoEstado})
          .eq('id', pagoId)
          .select('id');

      if (response.isEmpty) {
        debugPrint('[PaymentsRepository] Pago no encontrado: $pagoId');
        Error.throwWithStackTrace(
          Exception('El pago $pagoId no existe'),
          StackTrace.current,
        );
      }

      debugPrint('[PaymentsRepository] Pago $pagoId → $nuevoEstado');
    } catch (e, stack) {
      debugPrint(
        '[PaymentsRepository] Error actualizando pago $pagoId: $e',
      );
      debugPrint('[PaymentsRepository] Stack: $stack');
      Error.throwWithStackTrace(
        Exception('No se pudo actualizar el estado del pago: $e'),
        stack,
      );
    }
  }
}
