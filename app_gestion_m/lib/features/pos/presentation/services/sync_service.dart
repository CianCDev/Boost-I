import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/venta_entity.dart';

class SyncService {
  final IsarService _isarService = IsarService();
  final Connectivity _connectivity = Connectivity();
  
  // Endpoint de tu API Backend
  final String _apiUrl = 'https://tu-api.com/api/ventas/sync';

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Inicia la escucha activa de la conexión a internet
  void iniciarMonitoreo() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final tieneConexion = results.any((result) => result != ConnectivityResult.none);
      if (tieneConexion) {
        sincronizarVentasPendientes();
      }
    });
  }

  /// Cancela la suscripción al destruir el servicio
  void detenerMonitoreo() {
    _connectivitySubscription?.cancel();
  }

  /// Método principal de sincronización
  Future<int> sincronizarVentasPendientes() async {
    if (_isSyncing) return 0;
    _isSyncing = true;

    int ventasSincronizadas = 0;

    try {
      // 1. Obtener ventas no sincronizadas de Isar
      final pendientes = await _isarService.obtenerVentasPendientesSync();

      if (pendientes.isEmpty) {
        _isSyncing = false;
        return 0;
      }

      debugPrint('🔄 Iniciando sincronización de ${pendientes.length} ventas...');

      for (var venta in pendientes) {
        final exito = await _enviarVentaAlServidor(venta);

        if (exito) {
          // 2. Marcar como sincronizada en la base de datos local
          venta.sincronizado = true;
          await _isarService.guardarVenta(venta);
          ventasSincronizadas++;
        } else {
          // Si una falla, pausamos para reintentar en el siguiente ciclo
          break;
        }
      }
    } catch (e) {
      debugPrint('❌ Error durante la sincronización: $e');
    } finally {
      _isSyncing = false;
    }

    return ventasSincronizadas;
  }

  /// Convierte la entidad de Isar a JSON y la envía al backend
  Future<bool> _enviarVentaAlServidor(VentaEntity venta) async {
    try {
      final payload = jsonEncode({
        'venta_id_string': venta.ventaIdString,
        'fecha': venta.fecha.toIso8601String(),
        'total': venta.total,
        'subtotal': venta.subtotal,
        'impuesto': venta.impuesto,
        'metodo_pago': venta.metodoPago,
        'cedula_cliente': venta.cedulaCliente,
        'empleado': venta.empleado,
        'items': venta.items.map((item) => {
          'nombre_producto': item.nombreProducto,
          'precio_unidad': item.precioUnidad,
          'cantidad': item.cantidad,
          'subtotal': item.subtotal,
        }).toList(),
      });

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('✅ Venta ${venta.ventaIdString} subida con éxito');
        return true;
      } else {
        debugPrint('⚠️ Error backend (${response.statusCode}): ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('🚫 Error de red al enviar venta ${venta.ventaIdString}: $e');
      return false;
    }
  }
}