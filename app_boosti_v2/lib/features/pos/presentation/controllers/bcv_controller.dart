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
  // CICLO DE VIDA
  // ══════════════════════════════════════════════════════════════

  /// `true` desde que el controller se dispone.
  ///
  /// ⚠️ `ChangeNotifier` NO tiene `mounted` (eso es de `StateNotifier`), así que
  /// hace falta esta bandera. `init()` se lanza desde el factory del provider
  /// sin `await` (`bcv_provider.dart:12`), de modo que su `await` puede
  /// resolverse DESPUÉS de que el container se haya cerrado y
  /// `notifyListeners()` lanzaría "was used after being disposed".
  ///
  /// La guarda se aplica dentro de [_notifyIfChanged], que es el ÚNICO punto
  /// del archivo que llama a `notifyListeners()`.
  bool _disposed = false;

  @override
  void dispose() {
    // `ChangeNotifier.dispose()` NO es idempotente: la segunda llamada entra en
    // el assert de Flutter y lanza en debug. Con el hot-switch el controller
    // se invalida y luego el container se dispone, así que `dispose()` puede
    // llegar dos veces. La guarda evita el crash y es inocua: tras la primera
    // llamada, `super.dispose()` ya limpió los listeners.
    if (_disposed) return;
    _disposed = true;
    super.dispose();
  }

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

  /// `true` si la tasa mostrada NO viene de la red en este momento.
  ///
  /// ## Solo `cacheObsoleta`
  /// Antes incluía `cacheReciente` y `manual`, y eso hacía que el selector
  /// mostrara "Sin conexión. Mostrando los últimos valores guardados."
  /// con una tasa de 20 minutos. Peor: `main_pos_screen._ensureFreshBcvRate`
  /// NO consulta si la caché tiene menos de 6 h, así que `cacheReciente`
  /// era el estado NORMAL tras abrir la app, no una señal de fallo. El
  /// aviso era un falso positivo que enseñaba al cajero a ignorar el
  /// indicador.
  ///
  /// Ahora solo se marca cuando la tasa tiene más de [maxEdadCache]. La
  /// tasa manual se informa aparte con [tasaEsManual], porque es otra
  /// cosa: no es que no pudimos leerla, es que el usuario la puso.
  bool get desdeCache => _estadoTasa == EstadoTasa.cacheObsoleta;

  /// `true` si la tasa la ingressó el usuario manualmente.
  ///
  /// No es un fallo de conexión: es una decisión suya.
  bool get tasaEsManual => _estadoTasa == EstadoTasa.manual;

  String? get mensajeAdvertencia {
    switch (_estadoTasa) {
      case EstadoTasa.sinTasa:
        return 'No hay tasa BCV disponible. Ingresa una manualmente.';
      case EstadoTasa.cacheObsoleta:
        final edad = edadTasa;
        final horas = edad?.inHours;
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

  /// Constructor por instancia. NO es singleton.
  ///
  /// ⚠️ Antes era `factory BcvController() => _instance` con un
  /// `static final _instance`. El singleton era incompatible con el
  /// ciclo de vida que Riverpod da al notifier: `runOnDispose` llama
  /// `notifier.dispose()` cuando el `ProviderScope` muere, y con un
  /// singleton esa marca de "disposed" es permanente en todo el isolate.
  /// El siguiente `create` recibía el mismo objeto muerto y `addListener`
  /// reventaba con "was used after being disposed".
  ///
  /// No había ningún motivo para el singleton: `BcvController()` se
  /// invocaba una sola vez en lib/ (dentro de `bcv_provider.dart`) y
  /// cero veces en test/. Todos los consumidores acceden vía
  /// `ref.watch(bcvProvider)` / `ref.read(bcvProvider)`.
  BcvController();

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
    // Guarda estándar: el controller puede haberse dispuesto durante un await.
    // Va AQUÍ y no en cada llamante porque este es el único punto del
    // archivo que llega a `notifyListeners()`.
    if (_disposed) return;
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
        // `_formatearFecha` y no `_formatearHora`: lo que se persiste es
        // la fecha de la TASA, que puede ser de ayer. Mostrar solo la
        // hora hacía ver como fresco un valor de la madrugada anterior.
        _ultimaActualizacion = _formatearFecha(_ultimoUpdateRemoto);
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
      final nuevoUsd =
          await BcvService.obtenerTasaDolarConFecha(_config);
      if (nuevoUsd.tasa > 0) _tasaDolar = nuevoUsd.tasa;

      if (_config.manejaEuro) {
        final nuevoEur =
            await BcvService.obtenerTasaEuroConFecha(_config);
        if (nuevoEur.tasa > 0) _tasaEuro = nuevoEur.tasa;
      }

      fetchOk = _tasaDolar > 0;

      if (fetchOk) {
        // 📅 La fecha de la TASA, no la del fetch.
        //
        // La BCV publica una vez por día (medianoche, -04:00). Guardar
        // `DateTime.now()` acá hacía que una tasa de la madrugada
        // pareciera de la tarde: hasta 24 h de frescura inventada, que es
        // justo lo que el usuario necesita saber para decidir si cobra
        // con ella.
        //
        // Si la API no trae fecha, caemos a `now()`: es peor que nada,
        // pero es el comportamiento anterior y no rompe el flujo.
        _ultimoUpdateRemoto = nuevoUsd.fecha ?? DateTime.now();
        _ultimaActualizacion = _formatearFecha(_ultimoUpdateRemoto);
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

  /// Fecha + hora de la tasa.
  ///
  /// Se usa cuando la fecha viene de la API y por lo tanto puede ser de
  /// HACE DÍAS, no de hace minutos. Mostrar solo "21:22" de una tasa de
  /// ayer al mediodía es indistinguible de una tasa fresca.
  String _formatearFecha(DateTime? fecha) {
    if (fecha == null) return 'Nunca';
    final local = fecha.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final anio = local.year.toString().padLeft(4, '0');
    return '$dia/$mes/$anio ${_formatearHora(fecha)}';
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