// lib/features/pos/presentation/controllers/bcv_controller.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/configuracion_moneda.dart';
import '../services/bcv_service.dart';

/// Controlador global de tasas de cambio con persistencia local.
///
/// Persiste las últimas tasas en `SharedPreferences` para que si la app
/// se abre sin internet, se muestren los últimos valores conocidos.
///
/// **Optimización de emisiones**: solo llama `notifyListeners()` cuando
/// alguno de los campos observables cambia realmente. Esto evita rebuilds
/// innecesarios de las pantallas que dependen del tipo de cambio
/// (catálogo, inventario, cobro, etc.).
class BcvController extends ChangeNotifier {
  // ══════════════════════════════════════════════════════════════
  // CONSTANTES
  // ══════════════════════════════════════════════════════════════
  static const String _prefsKeyTasaDolar = 'bcv_tasa_dolar';
  static const String _prefsKeyTasaEuro = 'bcv_tasa_euro';
  static const String _prefsKeyPais = 'bcv_pais';
  static const String _prefsKeyTimestamp = 'bcv_timestamp';

  /// Tolerancia al comparar tasas → evita falsos positivos por redondeo.
  static const double _epsilonTasa = 0.001;

  // ══════════════════════════════════════════════════════════════
  // ESTADO
  // ══════════════════════════════════════════════════════════════
  double _tasaDolar = 36.50;
  /// Alias legacy.
  double get tasa => _tasaDolar;

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

  /// Indica si el país configurado maneja euro.
  bool get manejaEuro => _config.manejaEuro;

  bool _initialized = false;

  // ══════════════════════════════════════════════════════════════
  // SINGLETON
  // ══════════════════════════════════════════════════════════════
  static final BcvController _instance = BcvController._internal();
  factory BcvController() => _instance;
  BcvController._internal();

  // ══════════════════════════════════════════════════════════════
  // SNAPSHOT Y NOTIFICACIÓN CONDICIONAL
  // ══════════════════════════════════════════════════════════════

  /// Fotografía del estado observable. Todos los campos que el UI
  /// puede leer deben ir aquí para que `_notifyIfChanged` los detecte.
  _BcvSnapshot _snapshot() => _BcvSnapshot(
        usd: _tasaDolar,
        eur: _tasaEuro,
        cargando: _cargando,
        desdeCache: _desdeCache,
        ultimaActualizacion: _ultimaActualizacion,
        ultimoUpdateIso: _ultimoUpdateRemoto?.toIso8601String(),
        pais: _config.codigoPais,
      );

  /// Solo emite si el estado cambió respecto al snapshot dado.
  /// Evita rebuilds espurios cuando `notifyListeners()` se llama sin
  /// cambios reales (p. ej. actualizar la tasa con el mismo valor).
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

  /// Carga la última tasa guardada en SharedPreferences.
  /// Se llama una sola vez al inicio de la app.
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    final antes = _snapshot();

    try {
      final prefs = await SharedPreferences.getInstance();

      // Cargar país
      final codigoPais = prefs.getString(_prefsKeyPais);
      if (codigoPais != null &&
          ConfiguracionMoneda.porPais.containsKey(codigoPais)) {
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
      if (timestampStr != null && timestampStr.isNotEmpty) {
        _ultimoUpdateRemoto = DateTime.tryParse(timestampStr);
        _ultimaActualizacion = _formatearHora(_ultimoUpdateRemoto);
      }

      debugPrint(
          '📦 Tasas cargadas de caché: USD=${_tasaDolar.toStringAsFixed(2)} '
          'EUR=${_tasaEuro.toStringAsFixed(2)} (${_config.codigoPais})');
    } catch (e) {
      debugPrint('⚠️ Error cargando tasas de caché: $e');
    }

    // Solo emitimos si algo cambió realmente respecto al estado inicial.
    _notifyIfChanged(antes, reason: 'init');
  }

  // ══════════════════════════════════════════════════════════════
  // ACTUALIZACIÓN
  // ══════════════════════════════════════════════════════════════

  /// Actualiza las tasas del USD y EUR del país configurado.
  /// Persiste las nuevas tasas en SharedPreferences si son válidas.
  Future<void> actualizarTasa() async {
    if (_cargando) return;

    // ── Fase 1: marcar loading ─────────────────────────────────
    final antesDeLoading = _snapshot();
    _cargando = true;
    _notifyIfChanged(antesDeLoading, reason: 'loading→true');

    // Snapshot tras entrar en loading → con este comparamos al final.
    final enCarga = _snapshot();
    final usdAntes = _tasaDolar;
    final eurAntes = _tasaEuro;

    try {
      // Tasa USD
      final nuevaTasaDolar =
          await BcvService.obtenerTasaDolarDelPais(_config);
      if (nuevaTasaDolar > 0 &&
          (nuevaTasaDolar - _tasaDolar).abs() >= _epsilonTasa) {
        _tasaDolar = nuevaTasaDolar;
      }

      // Tasa EUR (solo si el país maneja euro)
      if (_config.manejaEuro) {
        final nuevaTasaEuro =
            await BcvService.obtenerTasaEuroDelPais(_config);
        if (nuevaTasaEuro > 0 &&
            (nuevaTasaEuro - _tasaEuro).abs() >= _epsilonTasa) {
          _tasaEuro = nuevaTasaEuro;
        }
      }

      // ¿Cambió alguna tasa? Comparar con los valores ANTES del trabajo.
      final cambioUsd = (_tasaDolar - usdAntes).abs() >= _epsilonTasa;
      final cambioEur = (_tasaEuro - eurAntes).abs() >= _epsilonTasa;

      if (cambioUsd || cambioEur) {
        _ultimoUpdateRemoto = DateTime.now();
        _ultimaActualizacion = _formatearHora(_ultimoUpdateRemoto);
        _desdeCache = false;
        await _persistirTasas();

        debugPrint(
            '✅ Tasas actualizadas: USD=${_tasaDolar.toStringAsFixed(2)} '
            'EUR=${_tasaEuro.toStringAsFixed(2)}');
      } else {
        debugPrint(
            'ℹ️ Sin cambios en las tasas (valores idénticos al caché).');
      }
    } catch (e) {
      debugPrint('❌ Error actualizando tasas: $e');
      _desdeCache = true;
    } finally {
      _cargando = false;
      // Solo emite si el resultado del trabajo cambió algo (tasa, cache,
      // timestamp) además del loading→false.
      _notifyIfChanged(enCarga, reason: 'loading→false');
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

    final antes = _snapshot();
    _config = config;
    _tasaEuro = 0.0;
    _desdeCache = true;
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

  // ══════════════════════════════════════════════════════════════
  // DEBUG
  // ══════════════════════════════════════════════════════════════

  /// Representación legible para el `ProviderObserver` y logs.
  /// Sin esto, todos los emits salen como "Instance of 'BcvController'"
  /// y es imposible saber si algo cambió de verdad.
  @override
  String toString() {
    return 'BcvController(usd=${_tasaDolar.toStringAsFixed(2)}, '
        'eur=${_tasaEuro.toStringAsFixed(2)}, '
        'cargando=$_cargando, cache=$_desdeCache, '
        'pais=${_config.codigoPais})';
  }
}

// ══════════════════════════════════════════════════════════════
// SNAPSHOT
// ══════════════════════════════════════════════════════════════

/// Snapshot inmutable del estado observable del `BcvController`.
/// Solo para comparación con `==` — no se persiste ni se expone.
@immutable
class _BcvSnapshot {
  final double usd;
  final double eur;
  final bool cargando;
  final bool desdeCache;
  final String ultimaActualizacion;
  final String? ultimoUpdateIso;
  final String pais;

  const _BcvSnapshot({
    required this.usd,
    required this.eur,
    required this.cargando,
    required this.desdeCache,
    required this.ultimaActualizacion,
    required this.ultimoUpdateIso,
    required this.pais,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _BcvSnapshot &&
          other.usd == usd &&
          other.eur == eur &&
          other.cargando == cargando &&
          other.desdeCache == desdeCache &&
          other.ultimaActualizacion == ultimaActualizacion &&
          other.ultimoUpdateIso == ultimoUpdateIso &&
          other.pais == pais;

  @override
  int get hashCode => Object.hash(
        usd,
        eur,
        cargando,
        desdeCache,
        ultimaActualizacion,
        ultimoUpdateIso,
        pais,
      );

  @override
  String toString() => '_BcvSnapshot(usd=$usd, eur=$eur, '
      'cargando=$cargando, cache=$desdeCache)';
}