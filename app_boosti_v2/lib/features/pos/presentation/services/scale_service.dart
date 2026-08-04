// lib/features/pos/presentation/services/scale_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:platform_serial/platform_serial.dart';

/// Servicio para conectar y leer datos de una balanza electrónica vía puerto serie.
class ScaleService {
  SerialPort? _port;
  StreamSubscription<String>? _textSubscription;
  StreamController<double>? _weightController;
  bool _isConnected = false;

  /// Stream de pesos leídos desde la balanza.
  Stream<double> get weightStream {
    _weightController ??= StreamController<double>.broadcast();
    return _weightController!.stream;
  }

  /// Conecta al primer puerto serie disponible y configura la balanza.
  Future<bool> connect() async {
    if (_isConnected) {
      debugPrint('⚠️ La balanza ya está conectada');
      return true;
    }

    try {
      final manager = SerialManager();

      // Obtener lista de puertos disponibles
      final ports = await manager.getAvailablePorts();
      if (ports.isEmpty) {
        debugPrint('⚠️ No hay puertos seriales disponibles');
        return false;
      }

      final portInfo = ports.first;
      final portName = portInfo.portName;
      debugPrint('🔌 Intentando conectar a $portName...');

      // Abrir puerto con configuración explícita para la balanza
      _port = await manager.openPortFromConfig(
        SerialConfig(
          portName: portName,
          baudRate: 9600,
          dataBits: 8,
          parity: SerialParity.none,
          stopBits: SerialStopBits.one,
        ),
      );

      if (_port == null) {
        debugPrint('❌ No se pudo abrir el puerto $portName');
        return false;
      }

      // Suscribirse al stream de texto (asumiendo que la balanza envía texto ASCII)
      _textSubscription = _port!.textStream.listen(
        (String data) {
          final peso = _parseWeightFromText(data);
          if (peso != null) {
            _weightController?.add(peso);
          }
        },
        onError: (error) {
          debugPrint('❌ Error leyendo datos: $error');
          _disconnect();
        },
        onDone: () {
          debugPrint('🔴 Conexión con balanza cerrada');
          _isConnected = false;
        },
      );

      _isConnected = true;
      debugPrint('✅ Balanza conectada en $portName');
      return true;
    } catch (e) {
      debugPrint('❌ Error conectando balanza: $e');
      _disconnect();
      return false;
    }
  }

  /// Desconecta la balanza y libera recursos.
  void disconnect() => _disconnect();

  void _disconnect() {
    _isConnected = false;
    _textSubscription?.cancel();
    _textSubscription = null;
    _port?.close();
    _port = null;
    _weightController?.close();
    _weightController = null;
    debugPrint('🔌 Balanza desconectada');
  }

  /// Convierte el texto recibido en peso (double).
  double? _parseWeightFromText(String raw) {
    try {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) return null;

      // Buscar número en el string (ej. " 1.234 kg")
      final RegExp regex = RegExp(r'(\d+\.\d+|\d+)');
      final match = regex.firstMatch(trimmed);
      if (match == null) return null;

      final peso = double.tryParse(match.group(0)!);
      if (peso == null || peso < 0) return null;
      return peso;
    } catch (e) {
      debugPrint('⚠️ Error parseando peso: $e');
      return null;
    }
  }

  void dispose() => disconnect();
}