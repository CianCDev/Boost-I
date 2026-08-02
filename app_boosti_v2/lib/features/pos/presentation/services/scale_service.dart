import 'dart:async';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter/material.dart';


class ScaleService {
  SerialPort? _port;
  final StreamController<double> _weightController = StreamController<double>.broadcast();

  bool get isConnected => _port?.isOpen ?? false;
  Stream<double> get weightStream => _weightController.stream;

  Future<void> connect() async {
    try {
      final ports = SerialPort.availablePorts;
      if (ports.isEmpty) throw Exception('No se encontró ningún puerto serie.');
      
      final portName = ports.first; 
      
      _port = SerialPort(portName);
      _port!.openReadWrite();
      
      final config = SerialPortConfig()
        ..baudRate = 9600
        ..bits = 8
        ..parity = SerialPortParity.none
        ..stopBits = 1;
      
      _port!.config = config;

      final reader = SerialPortReader(_port!);
      reader.stream.listen((data) {
        final String raw = String.fromCharCodes(data).trim();
        final match = RegExp(r'(\d+\.?\d*)').firstMatch(raw);
        if (match != null) {
          final double weight = double.tryParse(match.group(0) ?? '0') ?? 0.0;
          _weightController.add(weight);
        }
      });
    } catch (e) {
      debugPrint('Error conectando a la balanza: $e');
    }
  }

  void disconnect() {
    _port?.close();
    _port = null;
  }

  void dispose() {
    disconnect();
    _weightController.close();
  }
}