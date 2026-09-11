import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class BcvService {
  static const String _urlApi = 'https://ve.dolarapi.com/v1/dolares/oficial';

  static Future<double> obtenerTasaBcv() async {
    try {
      final response = await http.get(Uri.parse(_urlApi)).timeout(
        const Duration(seconds: 5),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final double tasa = (data['promedio'] as num).toDouble();
        return tasa;
      }
      return 0.0;
    } catch (e) {
      debugPrint('Excepción al conectar con la API del BCV: $e');
      return 0.0; 
    }
  }
}