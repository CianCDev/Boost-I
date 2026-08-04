import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'telegram_config.dart';
import '/../../../features/pos/data/Local/entities/isar_service.dart';

class TelegramService {
  final TelegramConfig _config;
  final IsarService _isar = IsarService();
  Timer? _pollingTimer;
  int _lastUpdateId = 0;

  TelegramService(this._config) {
    if (_config.isValid) {
      _startPolling();
      debugPrint('🤖 Bot de Telegram activo');
    }
  }

  // ==========================================
  // ESCUCHAR MENSAJES (POLLING)
  // ==========================================

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkUpdates();
    });
  }

  Future<void> _checkUpdates() async {
    try {
      final url = Uri.parse(
        'https://api.telegram.org/bot${_config.botToken}/getUpdates?offset=${_lastUpdateId + 1}&timeout=30',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          for (var update in data['result']) {
            final updateId = update['update_id'];
            if (updateId > _lastUpdateId) {
              _lastUpdateId = updateId;
            }

            if (update.containsKey('message')) {
              final message = update['message'];
              final chatId = message['chat']['id'].toString();
              final text = message['text']?.toString() ?? '';

              if (chatId == _config.chatId && text.startsWith('/')) {
                await _procesarComando(chatId, text);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error polling Telegram: $e');
    }
  }

  // ==========================================
  // PROCESAR COMANDOS
  // ==========================================

  Future<void> _procesarComando(String chatId, String texto) async {
    final respuesta = await _ejecutarComando(texto);
    await _enviarMensaje(chatId, respuesta);
  }

  Future<String> _ejecutarComando(String texto) async {
    final cmd = texto.trim().toLowerCase();

    switch (cmd) {
      case '/ventas':
        return await _ventas();
      case '/stock':
        return await _stock();
      case '/ayuda':
        return _ayuda();
      case '/start':
        return _bienvenida();
      default:
        return '❓ Comando no reconocido. Usa /ayuda';
    }
  }

  // ==========================================
  // COMANDOS
  // ==========================================

  Future<String> _ventas() async {
    try {
      final ventas = await _isar.obtenerVentas();
      final hoy = DateTime.now();
      final inicio = DateTime(hoy.year, hoy.month, hoy.day);
      final fin = inicio.add(const Duration(days: 1));

      final ventasHoy = ventas.where((v) =>
          v.fecha.isAfter(inicio) && v.fecha.isBefore(fin)).toList();

      if (ventasHoy.isEmpty) return '📭 No hay ventas hoy.';

      final total = ventasHoy.fold(0.0, (sum, v) => sum + v.total);
      final totalBs = ventasHoy.fold(0.0, (sum, v) =>
          sum + (v.totalBolivares.isNaN ? 0.0 : v.totalBolivares));

      return '''
📈 VENTAS DEL DÍA
💰 Total: \$${total.toStringAsFixed(2)}
🇻🇪 Bs: ${totalBs.toStringAsFixed(2)}
🔄 Transacciones: ${ventasHoy.length}
''';
    } catch (e) {
      return '❌ Error: $e';
    }
  }

  Future<String> _stock() async {
    try {
      final productos = await _isar.obtenerProductos();
      final bajos = productos.where((p) => p.stock <= p.stockMinimo).toList();

      if (bajos.isEmpty) return '✅ Todos los productos tienen stock adecuado.';

      final lista = bajos.map((p) =>
          '• ${p.nombre}: ${p.stock} (mín: ${p.stockMinimo})').join('\n');

      return '⚠️ STOCK BAJO:\n$lista';
    } catch (e) {
      return '❌ Error: $e';
    }
  }

  String _ayuda() {
    return '''
🤖 COMANDOS:
/ventas - Ventas del día
/stock - Productos con stock bajo
/ayuda - Esto
/start - Bienvenida
''';
  }

  String _bienvenida() {
    return '👋 Bot de BoostI POS activo. Escribe /ayuda para comandos.';
  }

  // ==========================================
  // ENVIAR MENSAJE
  // ==========================================

  Future<void> _enviarMensaje(String chatId, String texto) async {
    try {
      final url = Uri.parse(
        'https://api.telegram.org/bot${_config.botToken}/sendMessage',
      );
      final payload = {
        'chat_id': chatId,
        'text': texto,
        'parse_mode': 'HTML',
      };
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
    } catch (e) {
      debugPrint('❌ Error enviando mensaje: $e');
    }
  }

  // ==========================================
  // ALERTA DE STOCK BAJO (pública)
  // ==========================================

  Future<void> alertarStockBajo(List<Map<String, dynamic>> productos) async {
    if (!_config.isValid || productos.isEmpty) return;

    final lista = productos.map((p) =>
        '• ${p['nombre']}: ${p['stock']} (mín: ${p['stockMinimo']})').join('\n');

    final mensaje = '''
⚠️ <b>ALERTA DE STOCK BAJO</b>
Los siguientes productos tienen stock por debajo del mínimo:

$lista

🔔 Por favor, revisa el inventario.
''';

    await _enviarMensaje(_config.chatId, mensaje);
  }

  // ==========================================
  // LIMPIEZA
  // ==========================================

  void dispose() {
    _pollingTimer?.cancel();
    debugPrint('🤖 Bot de Telegram detenido');
  }
}