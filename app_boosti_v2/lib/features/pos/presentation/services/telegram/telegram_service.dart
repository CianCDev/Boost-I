// lib/features/pos/presentation/services/telegram/telegram_service.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/pedido_entity.dart';
import '../../../data/Local/entities/producto_entity.dart';
import '../../../data/Local/entities/telegram_config_entity.dart';

/// Resultado de verificar un token de bot con `getMe`.
class BotVerificationResult {
  final bool ok;
  final String? botUsername;
  final String? botName;
  final String? error;

  const BotVerificationResult({
    required this.ok,
    this.botUsername,
    this.botName,
    this.error,
  });
}

class TelegramService {
  final IsarService _isarService = IsarService();
  TelegramConfigEntity? _config;
  Timer? _pollingTimer;
  int _lastUpdateId = 0;

  static const String _apiBase = 'https://api.telegram.org/bot';

  static final TelegramService _instance = TelegramService._internal();
  factory TelegramService() => _instance;
  TelegramService._internal();

  // ============================================================
  // INICIALIZACIÓN
  // ============================================================

  Future<void> inicializar({int? usuarioId}) async {
    if (usuarioId != null) {
      _config = await _isarService.obtenerTelegramConfigPorUsuario(usuarioId);
      if (_config == null) {
        debugPrint('⚠️ No hay config de Telegram para usuario $usuarioId');
        return;
      }
    } else {
      _config = await _isarService.obtenerTelegramConfig();
      if (_config == null) {
        debugPrint('⚠️ No hay config de Telegram en Isar');
        return;
      }
    }

    debugPrint('📋 Comandos cargados: ${_config!.comandosPermitidos}');

    if (_config!.enabled && _config!.botToken.isNotEmpty) {
      final registrados = await actualizarComandosEnTelegram(
        _config!.comandosPermitidos,
      );
      if (!registrados) {
        debugPrint('❌ No se pudieron registrar comandos en Telegram');
      }
      _startPolling();
      debugPrint(
        '🤖 Bot iniciado (usuario ${_config!.usuarioId}, id ${_config!.id})',
      );
    } else {
      debugPrint('⚠️ Bot deshabilitado o sin configuración');
    }
  }

  Future<void> cambiarUsuario(int usuarioId) async {
    _pollingTimer?.cancel();
    await inicializar(usuarioId: usuarioId);
  }

  // ============================================================
  // VERIFICACIÓN DE TOKEN (getMe)
  // ============================================================

  /// Verifica un token contra el endpoint `getMe` de Telegram.
  ///
  /// Devuelve el username del bot si el token es válido. No requiere
  /// chat ID ni envía mensajes — es una verificación barata.
  Future<BotVerificationResult> verificarToken(String botToken) async {
    final token = botToken.trim();
    if (token.isEmpty) {
      return const BotVerificationResult(
        ok: false,
        error: 'Token vacío',
      );
    }

    try {
      final url = Uri.parse('$_apiBase$token/getMe');
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401 || response.statusCode == 404) {
        return const BotVerificationResult(
          ok: false,
          error: 'Token inválido o bot eliminado',
        );
      }

      if (response.statusCode != 200) {
        return BotVerificationResult(
          ok: false,
          error: 'HTTP ${response.statusCode}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['ok'] != true) {
        return BotVerificationResult(
          ok: false,
          error: data['description']?.toString() ?? 'Token inválido',
        );
      }

      final result = data['result'] as Map<String, dynamic>?;
      return BotVerificationResult(
        ok: true,
        botUsername: result?['username']?.toString(),
        botName: result?['first_name']?.toString(),
      );
    } on TimeoutException {
      return const BotVerificationResult(
        ok: false,
        error: 'Tiempo de espera agotado. Revisa tu conexión.',
      );
    } catch (e) {
      return BotVerificationResult(ok: false, error: e.toString());
    }
  }

  // ============================================================
  // ENVÍO DE MENSAJES
  // ============================================================

  /// Envía un mensaje de prueba usando un token y chat ID específicos.
  /// Útil antes de guardar la config (permite probar sin persistir).
  Future<bool> enviarMensajePrueba(
    String mensaje,
    String botToken,
    String chatId,
  ) async {
    return _sendMessageRaw(
      botToken: botToken.trim(),
      chatId: chatId.trim(),
      texto: mensaje,
    );
  }

  Future<bool> _enviarMensaje(String chatId, String texto) async {
    if (_config == null || _config!.botToken.isEmpty) return false;
    return _sendMessageRaw(
      botToken: _config!.botToken,
      chatId: chatId,
      texto: texto,
    );
  }

  /// Implementación única de envío. `parse_mode: HTML` consistente.
  Future<bool> _sendMessageRaw({
    required String botToken,
    required String chatId,
    required String texto,
  }) async {
    try {
      final url = Uri.parse('$_apiBase$botToken/sendMessage');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'chat_id': chatId,
              'text': texto,
              'parse_mode': 'HTML',
              'disable_web_page_preview': true,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['ok'] == true;
      }

      if (kDebugMode) {
        debugPrint('⚠️ sendMessage HTTP ${response.statusCode}: ${response.body}');
      }
      return false;
    } on TimeoutException {
      debugPrint('⚠️ Timeout enviando mensaje');
      return false;
    } catch (e) {
      debugPrint('❌ Error enviando mensaje: $e');
      return false;
    }
  }

  // ============================================================
  // POLLING DE MENSAJES
  // ============================================================

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_config == null || !_config!.enabled) {
        timer.cancel();
        return;
      }
      await _checkUpdates();
    });
  }

  Future<void> _checkUpdates() async {
    if (_config == null || _config!.botToken.isEmpty) return;

    try {
      final url = Uri.parse(
        '$_apiBase${_config!.botToken}/getUpdates'
        '?offset=${_lastUpdateId + 1}&timeout=10',
      );
      final response = await http
          .get(url)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['ok'] != true) return;

      final results = data['result'] as List<dynamic>? ?? [];

      for (final update in results) {
        final map = update as Map<String, dynamic>;
        final updateId = map['update_id'] as int?;
        if (updateId != null && updateId > _lastUpdateId) {
          _lastUpdateId = updateId;
        }

        final message = map['message'] as Map<String, dynamic>?;
        if (message == null) continue;

        final chat = message['chat'] as Map<String, dynamic>?;
        final chatId = chat?['id']?.toString() ?? '';
        final text = message['text']?.toString() ?? '';

        if (chatId == _config!.chatId && text.startsWith('/')) {
          await _procesarComando(chatId, text);
        }
      }
    } catch (e) {
      debugPrint('⚠️ Error polling Telegram: $e');
    }
  }

  // ============================================================
  // COMANDOS
  // ============================================================

  Future<void> _procesarComando(String chatId, String texto) async {
    final respuesta = await _ejecutarComando(texto);
    await _enviarMensaje(chatId, respuesta);
  }

  Future<String> _ejecutarComando(String texto) async {
    // Normalizamos: minúsculas y sin el @botname que Telegram añade.
    final raw = texto.trim().toLowerCase();
    final cmd = raw.contains('@') ? raw.split('@').first : raw;

    final permitidos = _config?.comandosPermitidos ?? [];
    if (!permitidos.contains(cmd)) {
      return '❌ Comando no permitido. Usa /ayuda para ver los disponibles.';
    }

    switch (cmd) {
      case '/ventas':
        return await _ventas();
      case '/stock':
        return await _stock();
      case '/pedidos':
        return await _pedidos();
      case '/resumen':
        return await _resumen();
      case '/ayuda':
        return _ayuda();
      case '/start':
        return _bienvenida();
      default:
        return '❓ Comando no reconocido. Usa /ayuda';
    }
  }

  Future<String> _ventas() async {
    try {
      final hoy = DateTime.now();
      final inicio = DateTime(hoy.year, hoy.month, hoy.day);
      final fin = inicio.add(const Duration(days: 1));
      final ventas = await _isarService.obtenerVentasPorRango(inicio, fin);

      if (ventas.isEmpty) return '📭 No hay ventas hoy.';

      final total = ventas.fold<double>(0.0, (s, v) => s + v.total);
      final totalBs = ventas.fold<double>(
        0.0,
        (s, v) => s + (v.totalBolivares.isNaN ? 0.0 : v.totalBolivares),
      );

      return '''
<b>📈 VENTAS DEL DÍA</b>
💰 Total: \$${total.toStringAsFixed(2)}
🇻🇪 Bs: ${totalBs.toStringAsFixed(2)}
🔄 Transacciones: ${ventas.length}
''';
    } catch (e) {
      return '❌ Error: $e';
    }
  }

  Future<String> _stock() async {
    try {
      final productos = await _isarService.obtenerProductos();
      final bajos = productos.where((p) => p.stock <= p.stockMinimo).toList();

      if (bajos.isEmpty) {
        return '✅ Todos los productos tienen stock adecuado.';
      }

      final lista = bajos
          .map((p) => '• ${p.nombre}: ${p.stock} (mín: ${p.stockMinimo})')
          .join('\n');

      return '<b>⚠️ STOCK BAJO</b>\n$lista';
    } catch (e) {
      return '❌ Error: $e';
    }
  }

  Future<String> _pedidos() async {
    try {
      final pedidos = await _isarService.obtenerPedidosPorEstado(
        EstadoPedido.pendiente,
      );

      if (pedidos.isEmpty) return '📭 No hay pedidos pendientes.';

      final total = pedidos.fold<double>(0.0, (s, p) => s + p.total);
      final lista = pedidos
          .map((p) =>
              '• ${p.proveedorNombre}: \$${p.total.toStringAsFixed(2)}')
          .join('\n');

      return '''
<b>📋 PEDIDOS PENDIENTES</b>
$lista

💰 Total: \$${total.toStringAsFixed(2)}
📦 Cantidad: ${pedidos.length} pedidos
''';
    } catch (e) {
      return '❌ Error: $e';
    }
  }

  Future<String> _resumen() async {
    try {
      final hoy = DateTime.now();
      final inicio = DateTime(hoy.year, hoy.month, hoy.day);
      final fin = inicio.add(const Duration(days: 1));

      final ventas = await _isarService.obtenerVentasPorRango(inicio, fin);
      final totalVentas = ventas.fold<double>(0.0, (s, v) => s + v.total);
      final totalBs = ventas.fold<double>(
        0.0,
        (s, v) => s + (v.totalBolivares.isNaN ? 0.0 : v.totalBolivares),
      );

      final productos = await _isarService.obtenerProductos();
      final stockBajo =
          productos.where((p) => p.stock <= p.stockMinimo).length;

      final pedidos = await _isarService.obtenerPedidosPorEstado(
        EstadoPedido.pendiente,
      );

      return '''
<b>📈 RESUMEN DEL NEGOCIO</b>
📅 ${hoy.day}/${hoy.month}/${hoy.year}

<b>💰 VENTAS DEL DÍA</b>
• Total: \$${totalVentas.toStringAsFixed(2)}
• Bs: ${totalBs.toStringAsFixed(2)}
• Transacciones: ${ventas.length}

<b>📦 INVENTARIO</b>
• Productos con stock bajo: $stockBajo

<b>📋 PEDIDOS</b>
• Pedidos pendientes: ${pedidos.length}
''';
    } catch (e) {
      return '❌ Error: $e';
    }
  }

  String _ayuda() {
    final comandos = _config?.comandosPermitidos ?? [];
    final lista = comandos.map((c) => '• $c').join('\n');
    return '<b>🤖 COMANDOS DISPONIBLES</b>\n$lista';
  }

  String _bienvenida() {
    return '👋 <b>Bot de BoostI POS activo.</b>\n'
        'Escribe /ayuda para ver los comandos disponibles.';
  }

  // ============================================================
  // ACTUALIZAR COMANDOS EN TELEGRAM
  // ============================================================

  Future<bool> actualizarComandosEnTelegram(List<String> comandos) async {
    if (_config == null || _config!.botToken.isEmpty) return false;
    if (comandos.isEmpty) return true;

    try {
      final commands = comandos.map((cmd) {
        String description;
        switch (cmd) {
          case '/ventas':
            description = '📊 Ver resumen de ventas del día';
            break;
          case '/stock':
            description = '📦 Ver productos con stock bajo';
            break;
          case '/pedidos':
            description = '📋 Ver pedidos pendientes';
            break;
          case '/resumen':
            description = '📈 Ver resumen completo del negocio';
            break;
          case '/ayuda':
            description = '❓ Mostrar comandos disponibles';
            break;
          default:
            description = 'Comando personalizado';
        }
        return {
          'command': cmd.replaceFirst('/', ''),
          'description': description,
        };
      }).toList();

      final url = Uri.parse('$_apiBase${_config!.botToken}/setMyCommands');
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'commands': commands}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['ok'] == true;
    } catch (e) {
      debugPrint('❌ Error actualizando comandos: $e');
      return false;
    }
  }

  // ============================================================
  // ALERTAS AUTOMÁTICAS
  // ============================================================

  Future<void> alertarStockBajo(List<ProductoEntity> productos) async {
    if (_config == null ||
        !_config!.notificarStockBajo ||
        _config!.chatId.isEmpty) {
      return;
    }

    final bajos = productos.where((p) => p.stock <= p.stockMinimo).toList();
    if (bajos.isEmpty) return;

    final lista = bajos
        .map((p) => '• ${p.nombre}: ${p.stock} (mín: ${p.stockMinimo})')
        .join('\n');

    final mensaje = '''
<b>⚠️ ALERTA DE STOCK BAJO</b>
Los siguientes productos tienen stock por debajo del mínimo:

$lista

🔔 Revisa el inventario.
''';

    await _enviarMensaje(_config!.chatId, mensaje);
  }

  // ============================================================
  // ACTUALIZAR CONFIGURACIÓN
  // ============================================================

  Future<void> actualizarConfig(TelegramConfigEntity nuevaConfig) async {
    _config = nuevaConfig;
    if (_config!.enabled && _config!.botToken.isNotEmpty) {
      await actualizarComandosEnTelegram(_config!.comandosPermitidos);
      _startPolling();
    } else {
      _pollingTimer?.cancel();
      debugPrint('⏹️ Bot de Telegram detenido');
    }
  }

  // ============================================================
  // LIMPIEZA
  // ============================================================

  void dispose() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _lastUpdateId = 0;
    debugPrint('🤖 Bot de Telegram detenido');
  }
}