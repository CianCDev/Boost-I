import 'dart:async';
import 'package:flutter/foundation.dart';

/// Servicio para conectar y leer datos de una balanza electrónica vía puerto serie.
/// NOTA: En Web, la balanza no está soportada. Los métodos están vacíos pero conservan su firma.
class ScaleService {
  // Variables internas (se mantienen, pero no se usan en Web)
  StreamController<double>? _weightController;

  /// Stream de pesos leídos desde la balanza.
  Stream<double> get weightStream {
    _weightController ??= StreamController<double>.broadcast();
    return _weightController!.stream;
  }

  /// Conecta al primer puerto serie disponible y configura la balanza.
  Future<bool> connect() async {
    if (kIsWeb) {
      debugPrint('La balanza no está disponible en Web');
      return false;
    }
    // Sin implementación en Web
    return false;
  }

  /// Desconecta la balanza y libera recursos.
  void disconnect() {
    // Vacío en Web
  }


  /// Convierte el texto recibido en peso (double).
  double? _parseWeightFromText(String raw) {
    // Vacío en Web
    return null;
  }

  void dispose() {
    disconnect();
  }
}