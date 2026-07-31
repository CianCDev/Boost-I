import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HardwareGatewayClient {
  WebSocketChannel? _channel;
  final StreamController<double> _pesoController = StreamController<double>.broadcast();

  Stream<double> get streamPeso => _pesoController.stream;
  bool _estaConectado = false;
  bool get estaConectado => _estaConectado;

  void conectarGateway({String host = 'localhost', int port = 8080}) {
    try {
      final url = Uri.parse('ws://$host:$port');
      _channel = WebSocketChannel.connect(url);
      _estaConectado = true;

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['tipo'] == 'PESO_BALANZA') {
            double peso = double.tryParse(data['peso'].toString()) ?? 0.000;
            _pesoController.add(peso);
          }
        },
        onError: (error) {
          debugPrint('Error en WebSocket Gateway: $error');
          _estaConectado = false;
        },
        onDone: () {
          _estaConectado = false;
        },
      );
    } catch (e) {
      _estaConectado = false;
      debugPrint('No se pudo conectar con el Gateway: $e');
    }
  }

  void dispose() {
    _channel?.sink.close();
    _pesoController.close();
  }
}