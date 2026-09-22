// lib/features/pos/presentation/controllers/bcv_controller.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/configuracion_moneda.dart';
import '../services/bcv_service.dart';

enum EstadoTasa {
  sinTasa,
  online,
  cacheReciente,
  cacheObsoleta,
  manual,
}

class BcvController extends ChangeNotifier {
  // ══════════════════════════════════════════════════════════════
  // CONSTANTES
  // ══════════════════════════════════════════════════════════════
  static const String _prefsKeyTasaDolar = 'bcv_tasa_dolar';
  static const String _prefsKeyTasaEuro = 'bcv_tasa_euro';
  static const String _prefsKeyPais = 'bcv_pais';
  static const String _prefsKeyTimestamp = 'bcv_timestamp';
  static const String _prefsKeyIsManual = 'bcv_is_manual'; // 💡 NUEVO: Persistencia estado manual

  static const double _epsilonTasa = 0.001;
  static const Duration maxEdadCache = Duration(hours: 24);

  // ══════════════════════════════════════════════════════════════
  // ESTADO
  // ══════════════════════════════════════════════════════════════
  double _tasaDolar = 0.0;
  double get tasa => _tasaDolar;

  double _tasaEuro = 0.0;
  double get tasaEuro => _tasaEuro;

  bool _cargando = false;
  bool get cargando => _cargando;

  String _ultimaActualizacion = 'Nunca';
  String get ultimaActualizacion => _ultimaActualizacion;

  DateTime? _ultimoUpdateRemoto;
  DateTime? get ultimoUpdateRemoto => _ultimoUpdateRemoto;

  EstadoTasa _estadoTasa = EstadoTasa.sinTasa;
  EstadoTasa get estadoTasa => _estadoTasa;

  ConfiguracionMoneda _config = ConfiguracionMoneda.porDefecto();
  ConfiguracionMoneda get config => _config;

  bool get manejaEuro => _config.manejaEuro;
  bool _initialized = false;

  // ── Getters de conveniencia ─────────
  bool get tieneTasa => _tasaDolar > 0;

  bool get tasaEsConfiable =>
      _estadoTasa == EstadoTasa.online ||
      _estadoTasa == EstadoTasa.cacheReciente ||
      _estadoTasa == EstadoTasa.manual;

  bool get tasaObsoleta => _estadoTasa == EstadoTasa.cacheObsoleta;
  bool get sinTasa => _estadoTasa == EstadoTasa.sinTasa;

  Duration? get edadTasa => _ultimoUpdateRemoto == null
      ? null
      : DateTime.now().difference(_ultimoUpdateRemoto!);

  bool get puedeOperar => tieneTasa;

  bool get desdeCache =>
      _estadoTasa == EstadoTasa.cacheReciente ||
      _estadoTasa == EstadoTasa.cacheObsoleta ||
      _estadoTasa == EstadoTasa.manual;

  String? get mensajeAdvertencia {
    switch (_estadoTasa) {
      case EstadoTasa.sinTasa:
        return 'No hay tasa BCV disponible. Ingresa una manualmente.';
      case EstadoTasa.cacheObsoleta:
        final edad = edadTasa;
        final horas = edad == null ? null : edad.inHours;
        return horas == null
            ? 'Tasa BCV desde caché sin fecha conocida. Verifica antes de cobrar.'
            : 'Tasa BCV desactualizada (hace $horas h). Verifica antes de cobrar.';
      case EstadoTasa.cacheReciente:
        return 'Tasa BCV desde caché. Conéctate para actualizarla.';
      case EstadoTasa.manual:
        return 'Usando tasa ingresada manualmente.';
      case EstadoTasa.online:
        return null;
    }
  }

  // ══════════════════════════════════════════════════════════════
  // SINGLETON
  // ══════════════════════════════════════════════════════════════
  static final BcvController _instance = BcvController._internal();
  factory BcvController() => _instance;
  BcvController._internal();

  // ══════════════════════════════════════════════════════════════
  // SNAPSHOT Y NOTIFICACIÓN
  // ══════════════════════════════════════════════════════════════
  _BcvSnapshot _snapshot() => _BcvSnapshot(
        usd: _tasaDolar,
        eur: _tasaEuro,
        cargando: _cargando,
        estado: _estadoTasa,
        ultimaActualizacion: _ultimaActualizacion,
        ultimoUpdateIso: _ultimoUpdateRemoto?.toIso8601String(),
        pais: _config.codigoPais,
      );

  void _notifyIfChanged(_BcvSnapshot before, {required String reason}) {
    final current = _snapshot();
    if (current == before) return;
    if (kDebugMode) {
      debugPrint('🔔 BCV emit [$reason] $current');
    }
    notifyListeners();
  }

  // ══════════════════════════════════════════════════════════════
  // INICIALIZACIÓN
  // ══════════════════════════════════════════════════════════════
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final antes = _snapshot();

    try {
      final prefs = await SharedPreferences.getInstance();

      final codigoPais = prefs.getString(_prefsKeyPais);
      if (codigoPais != null &&
          ConfiguracionMoneda.porPais.containsKey(codigoPais)) {
        _config = ConfiguracionMoneda.porPais[codigoPais]!;
      }

      final timestampStr = prefs.getString(_prefsKeyTimestamp);
      if (timestampStr != null && timestampStr.isNotEmpty) {
        _ultimoUpdateRemoto = DateTime.tryParse(timestampStr);
        _ultimaActualizacion = _formatearHora(_ultimoUpdateRemoto);
      }

      final tasaGuardada = prefs.getDouble(_prefsKeyTasaDolar);
      final tasaEuroGuardada = prefs.getDouble(_prefsKeyTasaEuro);
      final isManual = prefs.getBool(_prefsKeyIsManual) ?? false; // 💡 NUEVO

      if (tasaGuardada != null && tasaGuardada > 0) {
        _tasaDolar = tasaGuardada;
        // 💡 CORRECCIÓN: Si era manual, mantenerlo manual al reiniciar.
        _estadoTasa = isManual ? EstadoTasa.manual : _evaluarEstadoCache();
      } else {
        _estadoTasa = EstadoTasa.sinTasa;
      }

      if (tasaEuroGuardada != null && tasaEuroGuardada > 0) {
        _tasaEuro = tasaEuroGuardada;
      }

      debugPrint(
        '📦 Tasas cargadas: USD=${_tasaDolar.toStringAsFixed(2)} '
        'EUR=${_tasaEuro.toStringAsFixed(2)} '
        'estado=$_estadoTasa (${_config.codigoPais})',
      );
    } catch (e) {
      debugPrint('⚠️ Error cargando tasas de caché: $e');
      _estadoTasa = EstadoTasa.sinTasa;
    }

    _notifyIfChanged(antes, reason: 'init');
  }

  EstadoTasa _evaluarEstadoCache() {
    if (_ultimoUpdateRemoto == null) return EstadoTasa.cacheObsoleta;
    final edad = DateTime.now().difference(_ultimoUpdateRemoto!);
    return edad > maxEdadCache
        ? EstadoTasa.cacheObsoleta
        : EstadoTasa.cacheReciente;
  }

  // ══════════════════════════════════════════════════════════════
  // ACTUALIZACIÓN REMOTA
  // ══════════════════════════════════════════════════════════════
  Future<void> actualizarTasa() async {
    if (_cargando) return;

    final antesDeLoading = _snapshot();
    _cargando = true;
    _notifyIfChanged(antesDeLoading, reason: 'loading→true');

    final enCarga = _snapshot();
    final usdAntes = _tasaDolar;
    final eurAntes = _tasaEuro;
    var fetchOk = false;

    try {
      final nuevaTasaDolar = await BcvService.obtenerTasaDolarDelPais(_config);
      if (nuevaTasaDolar > 0) _tasaDolar = nuevaTasaDolar;

      if (_config.manejaEuro) {
        final nuevaTasaEuro = await BcvService.obtenerTasaEuroDelPais(_config);
        if (nuevaTasaEuro > 0) _tasaEuro = nuevaTasaEuro;
      }

      fetchOk = _tasaDolar > 0;

      if (fetchOk) {
        _ultimoUpdateRemoto = DateTime.now();
        _ultimaActualizacion = _formatearHora(_ultimoUpdateRemoto);
        _estadoTasa = EstadoTasa.online;

        final cambioUsd = (_tasaDolar - usdAntes).abs() >= _epsilonTasa;
        final cambioEur = (_tasaEuro - eurAntes).abs() >= _epsilonTasa;

        debugPrint(
          cambioUsd || cambioEur
              ? '✅ Tasas actualizadas: USD=${_tasaDolar.toStringAsFixed(2)} '
                  'EUR=${_tasaEuro.toStringAsFixed(2)}'
              : 'ℹ️ Sincronizado sin cambios (mismo valor, timestamp renovado).',
        );

        await _persistirTasas(esManual: false); // 💡 NUEVO
      }
    } catch (e) {
      debugPrint('❌ Error actualizando tasas: $e');
      if (_tasaDolar > 0) {
        // No pisamos el estado manual si falló la actualización
        if (_estadoTasa != EstadoTasa.manual) {
           _estadoTasa = _evaluarEstadoCache();
        }
      } else {
        _estadoTasa = EstadoTasa.sinTasa;
      }
    } finally {
      _cargando = false;
      _notifyIfChanged(enCarga, reason: 'loading→false');
    }
  }

  Future<void> setTasaManual(double tasa, {double? tasaEur}) async {
    if (tasa <= 0) return;

    final antes = _snapshot();
    _tasaDolar = tasa;
    if (tasaEur != null && tasaEur > 0) _tasaEuro = tasaEur;
    _ultimoUpdateRemoto = DateTime.now();
    _ultimaActualizacion = _formatearHora(_ultimoUpdateRemoto);
    _estadoTasa = EstadoTasa.manual;
    _notifyIfChanged(antes, reason: 'setTasaManual');
    
    await _persistirTasas(esManual: true); // 💡 NUEVO
  }

  Future<void> _persistirTasas({required bool esManual}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefsKeyTasaDolar, _tasaDolar);
      await prefs.setDouble(_prefsKeyTasaEuro, _tasaEuro);
      await prefs.setString(_prefsKeyPais, _config.codigoPais);
      await prefs.setString(
        _prefsKeyTimestamp,
        _ultimoUpdateRemoto?.toIso8601String() ?? '',
      );
      await prefs.setBool(_prefsKeyIsManual, esManual); // 💡 NUEVO
    } catch (e) {
      debugPrint('⚠️ Error persistiendo tasas: $e');
    }
  }

  Future<void> setPais(ConfiguracionMoneda config) async {
    if (_config.codigoPais == config.codigoPais) return;

    final antes = _snapshot();
    _config = config;
    
    // 💡 CORRECCIÓN: Reset de tasas al cambiar país para evitar "tasa frankenstein"
    _tasaDolar = 0.0;
    _tasaEuro = 0.0;
    _estadoTasa = EstadoTasa.sinTasa; 
    
    _notifyIfChanged(antes, reason: 'setPais(${config.codigoPais})');

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
    return (usd * _tasaDolar) / _tasaEuro;
  }

  double eurAUsd(double eur) {
    if (_tasaDolar <= 0 || _tasaEuro <= 0) return 0.0;
    return (eur * _tasaEuro) / _tasaDolar;
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

  @override
  String toString() {
    return 'BcvController(usd=${_tasaDolar.toStringAsFixed(2)}, '
        'eur=${_tasaEuro.toStringAsFixed(2)}, '
        'cargando=$_cargando, estado=$_estadoTasa, '
        'pais=${_config.codigoPais})';
  }
}

// ══════════════════════════════════════════════════════════════
// SNAPSHOT
// ══════════════════════════════════════════════════════════════

@immutable
class _BcvSnapshot {
  final double usd;
  final double eur;
  final bool cargando;
  final EstadoTasa estado;
  final String ultimaActualizacion;
  final String? ultimoUpdateIso;
  final String pais;

  const _BcvSnapshot({
    required this.usd,
    required this.eur,
    required this.cargando,
    required this.estado,
    required this.ultimaActualizacion,
    required this.ultimoUpdateIso,
    required this.pais,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    // 💡 CORRECCIÓN: Usar epsilon definido para evitar rebuilds por variaciones microscópicas de la API.
    return other is _BcvSnapshot &&
        (other.usd - usd).abs() < BcvController._epsilonTasa &&
        (other.eur - eur).abs() < BcvController._epsilonTasa &&
        other.cargando == cargando &&
        other.estado == estado &&
        other.ultimaActualizacion == ultimaActualizacion &&
        other.ultimoUpdateIso == ultimoUpdateIso &&
        other.pais == pais;
  }

  @override
  int get hashCode => Object.hash(
        usd,
        eur,
        cargando,
        estado,
        ultimaActualizacion,
        ultimoUpdateIso,
        pais,
      );

  @override
  String toString() => '_BcvSnapshot(usd=$usd, eur=$eur, '
      'cargando=$cargando, estado=$estado)';
}