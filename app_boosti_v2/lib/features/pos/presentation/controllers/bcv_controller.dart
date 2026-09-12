// lib/features/pos/presentation/controllers/bcv_controller.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/configuracion_moneda.dart';
import '../services/bcv_service.dart';

/// Controlador global de tasas de cambio con persistencia local.
///
/// Persiste las últimas tasas en `SharedPreferences` para que si la app
/// se abre sin internet, se muestren los últimos valores conocidos.
class BcvController extends ChangeNotifier {
  // ══════════════════════════════════════════════════════════════
  // CONSTANTES
  // ══════════════════════════════════════════════════════════════
  static const String _prefsKeyTasaDolar = 'bcv_tasa_dolar';
  static const String _prefsKeyTasaEuro = 'bcv_tasa_euro';
  static const String _prefsKeyPais = 'bcv_pais';
  static const String _prefsKeyTimestamp = 'bcv_timestamp';

  // ══════════════════════════════════════════════════════════════
  // ESTADO
  // ══════════════════════════════════════════════════════════════
  double _tasaDolar = 36.50;
  double get tasa => _tasaDolar; // Alias legacy

  double _tasaEuro = 0.0;
  double get tasaEuro => _tasaEuro;

  bool _cargando = false;
  bool get cargando => _cargando;

  String _ultimaActualizacion = 'Nunca';
  String get ultimaActualizacion => _ultimaActualizacion;

  DateTime? _ultimoUpdateRemoto;
  DateTime? get ultimoUpdateRemoto => _ultimoUpdateRemoto;

  /// Indica si las tasas mostradas provienen de caché (no de la API).
  bool _desdeCache = false;
  bool get desdeCache => _desdeCache;

  ConfiguracionMoneda _config = ConfiguracionMoneda.porDefecto();
  ConfiguracionMoneda get config => _config;

  bool _initialized = false;

  // ══════════════════════════════════════════════════════════════
  // SINGLETON
  // ══════════════════════════════════════════════════════════════
  static final BcvController _instance = BcvController._internal();
  factory BcvController() => _instance;
  BcvController._internal();

  // ══════════════════════════════════════════════════════════════
  // INICIALIZACIÓN
  // ══════════════════════════════════════════════════════════════

  /// Carga la última tasa guardada en SharedPreferences.
  /// Se llama una sola vez al inicio de la app.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar país
      final codigoPais = prefs.getString(_prefsKeyPais);
      if (codigoPais != null && ConfiguracionMoneda.porPais.containsKey(codigoPais)) {
        _config = ConfiguracionMoneda.porPais[codigoPais]!;
      }

      // Cargar tasas
      final tasaGuardada = prefs.getDouble(_prefsKeyTasaDolar);
      final tasaEuroGuardada = prefs.getDouble(_prefsKeyTasaEuro);
      final timestampStr = prefs.getString(_prefsKeyTimestamp);

      if (tasaGuardada != null && tasaGuardada > 0) {
        _tasaDolar = tasaGuardada;
        _desdeCache = true;
      }
      if (tasaEuroGuardada != null && tasaEuroGuardada > 0) {
        _tasaEuro = tasaEuroGuardada;
        _desdeCache = true;
      }
      if (timestampStr != null) {
        _ultimoUpdateRemoto = DateTime.tryParse(timestampStr);
        _ultimaActualizacion = _formatearHora(_ultimoUpdateRemoto);
      }

      debugPrint(
          '📦 Tasas cargadas de caché: USD=${_tasaDolar.toStringAsFixed(2)} '
          'EUR=${_tasaEuro.toStringAsFixed(2)} (${_config.codigoPais})');

      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Error cargando tasas de caché: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════
  // ACTUALIZACIÓN
  // ══════════════════════════════════════════════════════════════

  /// Actualiza las tasas del USD y EUR del país configurado.
  /// Persiste las nuevas tasas en SharedPreferences si son válidas.
  Future<void> actualizarTasa() async {
    if (_cargando) return;

    _cargando = true;
    notifyListeners();

    bool algunaActualizada = false;

    try {
      // Tasa USD
      final nuevaTasaDolar =
          await BcvService.obtenerTasaDolarDelPais(_config);
      if (nuevaTasaDolar > 0) {
        _tasaDolar = nuevaTasaDolar;
        algunaActualizada = true;
      }

      // Tasa EUR
      if (_config.manejaEuro) {
        final nuevaTasaEuro =
            await BcvService.obtenerTasaEuroDelPais(_config);
        if (nuevaTasaEuro > 0) {
          _tasaEuro = nuevaTasaEuro;
          algunaActualizada = true;
        }
      }

      if (algunaActualizada) {
        _ultimoUpdateRemoto = DateTime.now();
        _ultimaActualizacion = _formatearHora(_ultimoUpdateRemoto);
        _desdeCache = false;

        // ✅ Persistir en SharedPreferences
        await _persistirTasas();

        debugPrint(
            '✅ Tasas actualizadas: USD=${_tasaDolar.toStringAsFixed(2)} '
            'EUR=${_tasaEuro.toStringAsFixed(2)}');
      } else {
        debugPrint('⚠️ No se pudo actualizar ninguna tasa. Se mantiene caché.');
        _desdeCache = true;
      }
    } catch (e) {
      debugPrint('❌ Error actualizando tasas: $e');
      _desdeCache = true;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  /// Persiste las tasas actuales en SharedPreferences.
  Future<void> _persistirTasas() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefsKeyTasaDolar, _tasaDolar);
      await prefs.setDouble(_prefsKeyTasaEuro, _tasaEuro);
      await prefs.setString(_prefsKeyPais, _config.codigoPais);
      await prefs.setString(
        _prefsKeyTimestamp,
        _ultimoUpdateRemoto?.toIso8601String() ?? '',
      );
    } catch (e) {
      debugPrint('⚠️ Error persistiendo tasas: $e');
    }
  }

  /// Cambia el país y recarga las tasas.
  Future<void> setPais(ConfiguracionMoneda config) async {
    if (_config.codigoPais == config.codigoPais) return;

    _config = config;
    _tasaEuro = 0.0;
    _desdeCache = true;
    notifyListeners();

    await actualizarTasa();
  }

  // ══════════════════════════════════════════════════════════════
  // CONVERSIONES
  // ══════════════════════════════════════════════════════════════

  double usdALocal(double usd) {
    if (_tasaDolar <= 0) return 0.0;
    return usd * _tasaDolar;
  }

  double eurALocal(double eur) {
    if (_tasaEuro <= 0) return 0.0;
    return eur * _tasaEuro;
  }

  double localAUsd(double local) {
    if (_tasaDolar <= 0) return 0.0;
    return local / _tasaDolar;
  }

  double usdAEur(double usd) {
    if (_tasaDolar <= 0 || _tasaEuro <= 0) return 0.0;
    final local = usd * _tasaDolar;
    return local / _tasaEuro;
  }

  double eurAUsd(double eur) {
    if (_tasaDolar <= 0 || _tasaEuro <= 0) return 0.0;
    final local = eur * _tasaEuro;
    return local / _tasaDolar;
  }

  // ══════════════════════════════════════════════════════════════
  // HELPERS
  // ══════════════════════════════════════════════════════════════

  String formatearLocal(double monto) => _config.formatear(monto);
  String formatearUsd(double monto) => _config.formatearUsd(monto);
  String formatearEur(double monto) => _config.formatearEur(monto);

  String _formatearHora(DateTime? fecha) {
    if (fecha == null) return 'Nunca';
    final local = fecha.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}