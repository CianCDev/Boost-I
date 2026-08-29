// lib/features/pos/presentation/services/telegram/telegram_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/producto_entity.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/pedido_entity.dart';

class TelegramService {
  final IsarService _isarService = IsarService();
  TelegramConfigEntity? _config;
  Timer? _pollingTimer;
  int _lastUpdateId = 0;
  bool _isRunning = false;

  // Singleton
  static final TelegramService _instance = TelegramService._internal();
  factory TelegramService() => _instance;
  TelegramService._internal();

  // ==========================================
  // INICIALIZACIÓN
  // ==========================================

  Future<void> inicializar() async {
    // 🔥 Cargar la configuración desde Isar (siempre la primera)
    _config = await _isarService.obtenerTelegramConfig();
    
    if (_config != null && _config!.enabled && _config!.botToken.isNotEmpty) {
      // Actualizar comandos en Telegram
      await actualizarComandosEnTelegram(_config!.comandosPermitidos);
      _startPolling();
      debugPrint('🤖 Bot de Telegram iniciado correctamente (ID: ${_config!.id})');
    } else {
      debugPrint('⚠️ Bot de Telegram deshabilitado o sin configuración');
    }
  }

  // ==========================================
  // POLLING DE MENSAJES
  // ==========================================

  void _startPolling() {
    _pollingTimer?.cancel();
    _isRunning = true;
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_config == null || !_config!.enabled) {
        _isRunning = false;
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
        'https://api.telegram.org/bot${_config!.botToken}/getUpdates?offset=${_lastUpdateId + 1}&timeout=30',
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

              // Solo responder al chat configurado
              if (chatId == _config!.chatId && text.startsWith('/')) {
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
    final comandosPermitidos = _config?.comandosPermitidos ?? [];

    if (!comandosPermitidos.contains(cmd)) {
      return '❌ Comando no permitido. Usa /ayuda para ver los comandos disponibles.';
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

  // ==========================================
  // COMANDOS
  // ==========================================

  Future<String> _ventas() async {
    try {
      final ventas = await _isarService.obtenerVentas();
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
      final productos = await _isarService.obtenerProductos();
      final bajos = productos.where((p) => p.stock <= p.stockMinimo).toList();

      if (bajos.isEmpty) return '✅ Todos los productos tienen stock adecuado.';

      final lista = bajos.map((p) =>
          '• ${p.nombre}: ${p.stock} (mín: ${p.stockMinimo})').join('\n');

      return '⚠️ STOCK BAJO:\n$lista';
    } catch (e) {
      return '❌ Error: $e';
    }
  }

  Future<String> _pedidos() async {
    try {
      final pedidos = await _isarService.obtenerPedidosPorEstado(
        EstadoPedido.pendiente,
      );

      if (pedidos.isEmpty) {
        return '📭 No hay pedidos pendientes.';
      }

      final total = pedidos.fold<double>(0.0, (sum, p) => sum + p.total);
      final lista = pedidos.map((p) => 
        '• ${p.proveedorNombre}: \$${p.total.toStringAsFixed(2)}'
      ).join('\n');

      return '''
📋 PEDIDOS PENDIENTES
$lista

💰 Total: \$${total.toStringAsFixed(2)}
📦 Cantidad: ${pedidos.length} pedidos
''';
    } catch (e) {
      return '❌ Error al obtener pedidos: $e';
    }
  }

  Future<String> _resumen() async {
    try {
      final hoy = DateTime.now();
      final inicio = DateTime(hoy.year, hoy.month, hoy.day);
      final fin = inicio.add(const Duration(days: 1));

      final ventasHoy = await _isarService.obtenerVentasPorRango(inicio, fin);
      final totalVentas = ventasHoy.fold<double>(0.0, (sum, v) => sum + v.total);
      final totalBs = ventasHoy.fold<double>(0.0, (sum, v) => 
        sum + (v.totalBolivares.isNaN ? 0.0 : v.totalBolivares)
      );

      final productos = await _isarService.obtenerProductos();
      final stockBajo = productos.where((p) => p.stock <= p.stockMinimo).length;

      final pedidos = await _isarService.obtenerPedidosPorEstado(
        EstadoPedido.pendiente,
      );

      return '''
📈 RESUMEN DEL NEGOCIO
📅 ${hoy.day}/${hoy.month}/${hoy.year}

💰 VENTAS DEL DÍA
• Total: \$${totalVentas.toStringAsFixed(2)}
• Bs: ${totalBs.toStringAsFixed(2)}
• Transacciones: ${ventasHoy.length}

📦 INVENTARIO
• Productos con stock bajo: $stockBajo

📋 PEDIDOS
• Pedidos pendientes: ${pedidos.length}

🔔 Total de ingresos: \$${totalVentas.toStringAsFixed(2)}
''';
    } catch (e) {
      return '❌ Error al generar resumen: $e';
    }
  }

  String _ayuda() {
    final comandos = _config?.comandosPermitidos ?? [];
    final listaComandos = comandos.map((c) => '$c').join('\n');
    return '''
🤖 COMANDOS DISPONIBLES:
$listaComandos

📌 Para más información, contacta al administrador.
''';
  }

  String _bienvenida() {
    return '👋 Bot de BoostI POS activo.\nEscribe /ayuda para ver los comandos disponibles.';
  }

  // ==========================================
  // ENVIAR MENSAJE
  // ==========================================

  Future<bool> _enviarMensaje(String chatId, String texto) async {
    if (_config == null || _config!.botToken.isEmpty) return false;

    try {
      final url = Uri.parse(
        'https://api.telegram.org/bot${_config!.botToken}/sendMessage',
      );
      final payload = {
        'chat_id': chatId,
        'text': texto,
        'parse_mode': 'HTML',
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error enviando mensaje: $e');
      return false;
    }
  }

  // ==========================================
  // ACTUALIZAR COMANDOS EN TELEGRAM
  // ==========================================

  Future<bool> actualizarComandosEnTelegram(List<String> comandos) async {
    if (_config == null || _config!.botToken.isEmpty) {
      debugPrint('❌ No se puede actualizar comandos: botToken vacío');
      return false;
    }

    try {
      final List<Map<String, String>> commands = comandos.map((cmd) {
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

      final url = Uri.parse(
        'https://api.telegram.org/bot${_config!.botToken}/setMyCommands',
      );
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'commands': commands}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          debugPrint('✅ Comandos actualizados en Telegram: ${commands.length} comandos');
          return true;
        } else {
          debugPrint('❌ Error al actualizar comandos: ${data['description']}');
          return false;
        }
      } else {
        debugPrint('❌ Error HTTP al actualizar comandos: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Excepción al actualizar comandos: $e');
      return false;
    }
  }

  // ==========================================
  // ALERTAS AUTOMÁTICAS
  // ==========================================

  Future<void> alertarStockBajo(List<ProductoEntity> productos) async {
    if (_config == null || !_config!.notificarStockBajo || _config!.chatId.isEmpty) {
      return;
    }

    final bajos = productos.where((p) => p.stock <= p.stockMinimo).toList();
    if (bajos.isEmpty) return;

    final lista = bajos.map((p) =>
        '• ${p.nombre}: ${p.stock} (mín: ${p.stockMinimo})').join('\n');

    final mensaje = '''
⚠️ <b>ALERTA DE STOCK BAJO</b>
Los siguientes productos tienen stock por debajo del mínimo:

$lista

🔔 Por favor, revisa el inventario.
''';

    await _enviarMensaje(_config!.chatId, mensaje);
  }

  // ==========================================
  // ACTUALIZAR CONFIGURACIÓN
  // ==========================================

  Future<void> actualizarConfig(TelegramConfigEntity nuevaConfig) async {
    _config = nuevaConfig;
    if (_config!.enabled && _config!.botToken.isNotEmpty) {
      await actualizarComandosEnTelegram(_config!.comandosPermitidos);
      _startPolling();
      debugPrint('🤖 Bot de Telegram reiniciado con nueva configuración');
    } else {
      _pollingTimer?.cancel();
      _isRunning = false;
      debugPrint('⏹️ Bot de Telegram detenido');
    }
  }

  // ==========================================
  // MÉTODO PÚBLICO PARA PRUEBA
  // ==========================================

  Future<bool> enviarMensajePrueba(String mensaje, String botToken, String chatId) async {
    try {
      final url = Uri.parse('https://api.telegram.org/bot$botToken/sendMessage');
      final payload = {
        'chat_id': chatId,
        'text': mensaje,
        'parse_mode': 'Markdown',
      };
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 10));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('❌ Error enviando mensaje de prueba: $e');
      return false;
    }
  }

  // ==========================================
  // LIMPIEZA
  // ==========================================

  void dispose() {
    _pollingTimer?.cancel();
    _isRunning = false;
    debugPrint('🤖 Bot de Telegram detenido');
  }
}