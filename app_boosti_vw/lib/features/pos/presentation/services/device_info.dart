import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Clave para guardar el ID en SharedPreferences
  static const String _deviceIdKey = 'device_persistent_id';

  /// Obtiene un identificador único y persistente para este dispositivo/instalación.
  /// Este ID se genera una sola vez y se guarda en SharedPreferences.
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Intentar recuperar el ID guardado
    String? deviceId = prefs.getString(_deviceIdKey);
    if (deviceId != null && deviceId.isNotEmpty) {
      return deviceId;
    }

    // 2. No existe, lo generamos (UUID v4)
    deviceId = const Uuid().v4();

    // 3. Lo guardamos para siempre
    await prefs.setString(_deviceIdKey, deviceId);

    log('Nuevo Device ID generado y guardado: $deviceId');
    return deviceId;
  }

  /// Opcional: Obtener información adicional del sistema (solo para debug/auditoría)
 Future<Map<String, dynamic>> getDeviceInfo() async {
  try {
    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      return {
        'platform': 'Android',
        'model': androidInfo.model,
        'brand': androidInfo.brand,
        'sdk': androidInfo.version.sdkInt, // ✅ CORREGIDO
        'id': await getDeviceId(),
      };
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      return {
        'platform': 'iOS',
        'model': iosInfo.model,
        'name': iosInfo.name,
        'systemVersion': iosInfo.systemVersion,
        'id': await getDeviceId(),
      };
    } else if (Platform.isWindows) {
      final windowsInfo = await _deviceInfo.windowsInfo;
      return {
        'platform': 'Windows',
        'computerName': windowsInfo.computerName, // ✅ CORREGIDO
        'userName': windowsInfo.userName,          // ✅ CORREGIDO
        'osVersion': windowsInfo.csdVersion,        // ✅ CORREGIDO
        'id': await getDeviceId(),
      };
    } else {
      // Web, Linux, macOS (si los soportas)
      return {
        'platform': 'Other',
        'id': await getDeviceId(),
      };
    }
  } catch (e) {
    log('Error obteniendo información del dispositivo: $e');
    return {
      'platform': 'Unknown',
      'id': await getDeviceId(),
    };
  }
}

  // --- Helpers para detectar plataforma ---
  // ignore: unused_element, unnecessary_null_comparison
  Future<bool> _isAndroid() async => await _deviceInfo.androidInfo != null;
  // ignore: unused_element, unnecessary_null_comparison
  Future<bool> _isIOS() async => await _deviceInfo.iosInfo != null;
  // ignore: unused_element, unnecessary_null_comparison
  Future<bool> _isWindows() async => await _deviceInfo.windowsInfo != null;
}