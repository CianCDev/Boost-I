import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Genera el número fiscal de cada venta.
///
/// Formato: `{deviceId}-{year}-{counter}`, ej. `P123-2026-0001`.
///
/// ## Por dispositivo
/// Cada punto de emisión tiene su propia secuencia, válido bajo
/// Providencia 00071. **Dos dispositivos del mismo negocio pueden
/// generar el mismo número.** Secuencia server-side es post-v1; la
/// migración `20261012000003` trae la query para detectarlo.
///
/// ## Concurrencia
/// `read → +1 → write` sobre `SharedPreferences` no es atómico: dos
/// ventas simultáneas leen el mismo contador y emiten el mismo número.
/// En la POS las ventas se registran de a una, pero el widget está
/// disponible en cualquier flujo async, así que el acceso se serializa
/// con un lock. `Future` en Dart es single-thread, así que encadenar las
/// llamadas con `.then` alcanza: no hace falta `Mutex`.
class DocumentoFiscalService {
  static const _keyDevice = 'fiscal_device_id';
  static const _keyCounterPrefix = 'fiscal_counter_';

  /// Cola serial: cada llamada espera a que termine la anterior.
  static Future<void> _cola = Future<void>.value();

  static String _formatear(String deviceId, int year, int counter) =>
      '$deviceId-$year-${counter.toString().padLeft(4, '0')}';

  /// Devuelve el próximo número fiscal de forma segura aunque se
  /// invoque concurrentemente.
  static Future<String> siguiente() {
    final operacion = _cola.then((_) => _generarBloqueado());
    // Si una generación falla, la cola tiene que seguir viva: sin esto,
    // un error deja `_cola` con error y TODAS las ventas siguientes
    // fallan con la misma excepción.
    _cola = operacion.then<void>((_) {}, onError: (_, __) {});
    return operacion;
  }

  static Future<String> _generarBloqueado() async {
    final prefs = await SharedPreferences.getInstance();

    var deviceId = prefs.getString(_keyDevice);
    if (deviceId == null || deviceId.isEmpty) {
      // 5 dígitos de aleatoriedad en vez de `millisecondsSinceEpoch % 100000`:
      // dos tablets instalados en el mismo milisegundo (restauración de
      // backup, clonación de imagen) generarían el mismo punto de emisión.
      final rnd = Random();
      deviceId = 'P${10000 + rnd.nextInt(90000)}';
      await prefs.setString(_keyDevice, deviceId);
    }

    final year = DateTime.now().year;
    final keyCounter = '$_keyCounterPrefix$year';

    // ⚠️ El contador es POR AÑO: al cambiar de año arranca en 1. Es lo
    //    que pide la norma, y también evita que el `int` de
    //    SharedPreferences crezca para siempre.
    final counter = (prefs.getInt(keyCounter) ?? 0) + 1;
    await prefs.setInt(keyCounter, counter);

    return _formatear(deviceId, year, counter);
  }
}
