import 'package:flutter/foundation.dart';
import '../services/bcv_service.dart';

class BcvController extends ChangeNotifier {
  double _tasa = 36.50; // Valor de respaldo inicial
  bool _cargando = false;
  String _ultimaActualizacion = 'Nunca';

  double get tasa => _tasa;
  bool get cargando => _cargando;
  String get ultimaActualizacion => _ultimaActualizacion;

  // Singleton opcional para acceder fácilmente desde cualquier vista
  static final BcvController _instance = BcvController._internal();
  factory BcvController() => _instance;
  BcvController._internal();

  Future<void> actualizarTasa() async {
    _cargando = true;
    notifyListeners();

    final nuevaTasa = await BcvService.obtenerTasaBcv();
    if (nuevaTasa > 0) {
      _tasa = nuevaTasa;
      final now = DateTime.now();
      _ultimaActualizacion = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    }

    _cargando = false;
    notifyListeners();
  }
}