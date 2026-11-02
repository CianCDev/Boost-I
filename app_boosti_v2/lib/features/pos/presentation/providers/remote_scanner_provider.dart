// lib/features/pos/presentation/providers/remote_scanner_provider.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/tenant_utils.dart';

/// Escáner remoto: un celular envía códigos de barras y la PC (POS) los
/// recibe por un canal *broadcast* de Supabase Realtime.
///
/// El canal es por tenant (`barcode_scanner_<tenantId>`), así que dos
/// locales distintos nunca se cruzan aunque compartan proyecto.
///
/// - PC / tablet: [startListening] y escucha [onCodeReceived].
/// - Celular: [sendCode] y no escucha (ver la nota en
///   `inventory_catalog_screen.dart`: un equipo que envía y escucha a la
///   vez se agregaría su propio código al carrito).
class RemoteScannerNotifier extends StateNotifier<bool> {
  RemoteScannerNotifier() : super(false);

  /// Evento del canal. Cambiarlo rompe la compatibilidad entre versiones
  /// de la app: celular y PC tienen que usar el mismo string.
  static const String _evento = 'barcode_scanned';

  /// Canal del dispositivo que RECIBE (PC).
  RealtimeChannel? _canalEscucha;

  /// Canal del dispositivo que ENVÍA (celular).
  ///
  /// Se reutiliza entre envíos: `subscribe()` solo se puede llamar una
  /// vez por instancia y lanza si se repite
  /// (`realtime_channel.dart:148`). Por eso el estado del join se lleva
  /// con [_envioSuscrito] y no con el `joinedOnce` del paquete (que es
  /// `@internal`).
  RealtimeChannel? _canalEnvio;
  bool _envioSuscrito = false;

  final StreamController<String> _codigos =
      StreamController<String>.broadcast();

  /// Códigos recibidos. Es un stream *broadcast*: si no hay nadie
  /// escuchando (la pantalla del POS está cerrada), el evento se pierde.
  Stream<String> get onCodeReceived => _codigos.stream;

  /// `true` mientras el canal de escucha está suscrito.
  bool get escuchando => state;

  static String _nombreCanal(String tenantId) => 'barcode_scanner_$tenantId';

  /// Extrae el código del mensaje de broadcast.
  ///
  /// ⚠️ `realtime_client 2.13.0` entrega el mensaje COMPLETO del servidor
  /// (`{event, payload, topic}`), no solo el payload que mandó el emisor.
  /// Por eso lo normal es leer `payload['payload']['code']`. Se acepta
  /// también `payload['code']` por si una versión futura aplana el
  /// mensaje.
  static String? _codigoDePayload(Map<String, dynamic> payload) {
    final directo = payload['code'];
    if (directo is String && directo.trim().isNotEmpty) {
      return directo.trim();
    }

    final interno = payload['payload'];
    if (interno is Map) {
      final anidado = interno['code'];
      if (anidado is String && anidado.trim().isNotEmpty) {
        return anidado.trim();
      }
    }
    return null;
  }

  /// Empieza a escuchar códigos de otros dispositivos (PC).
  ///
  /// Idempotente: llamarlo de nuevo no crea otro canal ni duplica
  /// eventos.
  void startListening() {
    if (_canalEscucha != null) return;

    final tenantId = getTenantIdFromJWT();
    if (tenantId == null || tenantId.isEmpty) {
      debugPrint('📡 [RemoteScanner] Sin tenant en el JWT: no se escucha.');
      return;
    }

    final canal = Supabase.instance.client.channel(_nombreCanal(tenantId));
    _canalEscucha = canal;

    canal
        .onBroadcast(
      event: _evento,
      callback: (payload) {
        // Log de diagnóstico: muestra el mensaje crudo del servidor.
        // Si el código no se encuentra, este es el que dice dónde está.
        debugPrint('📡 [RemoteScanner] RAW payload: $payload');
        if (!mounted) return;
        final codigo = _codigoDePayload(payload);
        if (codigo == null) return;
        debugPrint('📡 [RemoteScanner] Código recibido: $codigo');
        _codigos.add(codigo);
      },
    )
        .subscribe((status, error) {
      if (!mounted) return;
      state = status == RealtimeSubscribeStatus.subscribed;
      debugPrint(
        '📡 [RemoteScanner] Estado: $status'
        '${error != null ? ' · $error' : ''}',
      );
    });
  }

  /// Envía un código desde el celular.
  ///
  /// Devuelve `true` si el mensaje salió. No espera confirmación del
  /// receptor: broadcast es *fire-and-forget*.
  Future<bool> sendCode(String code) async {
    final limpio = code.trim();
    if (limpio.isEmpty) return false;

    final tenantId = getTenantIdFromJWT();
    if (tenantId == null || tenantId.isEmpty) {
      debugPrint('📡 [RemoteScanner] Sin tenant en el JWT: no se envía.');
      return false;
    }

    try {
      final canal = _canalEnvio ??=
          Supabase.instance.client.channel(_nombreCanal(tenantId));

      if (!_envioSuscrito) {
        _envioSuscrito = true;
        // `subscribe()` es síncrono y devuelve el canal, no un Future.
        // Si todavía no está unido, `sendBroadcastMessage` cae solo al
        // endpoint REST (`realtime_channel.dart:793`), así que no hace
        // falta esperar la confirmación del join.
        canal.subscribe((status, error) {
          if (status == RealtimeSubscribeStatus.channelError ||
              status == RealtimeSubscribeStatus.closed) {
            // Un canal cerrado no se puede volver a suscribir: se
            // descarta y el próximo envío crea uno nuevo.
            _canalEnvio = null;
            _envioSuscrito = false;
            debugPrint(
              '📡 [RemoteScanner] Canal de envío $status: $error',
            );
          }
        });
      }

      final respuesta = await canal.sendBroadcastMessage(
        event: _evento,
        payload: {'code': limpio},
      );
      final ok = respuesta == ChannelResponse.ok;
      debugPrint(
        '📡 [RemoteScanner] Código enviado: $limpio '
        '(${ok ? 'ok' : 'error'})',
      );
      return ok;
    } catch (e) {
      debugPrint('📡 [RemoteScanner] Fallo al enviar "$limpio": $e');
      return false;
    }
  }

  /// Deja de escuchar. El canal de envío se conserva para no reconectar
  /// en cada código.
  void stopListening() {
    final canal = _canalEscucha;
    _canalEscucha = null;
    if (mounted) state = false;
    if (canal != null) {
      Supabase.instance.client.removeChannel(canal);
    }
  }

  @override
  void dispose() {
    final escucha = _canalEscucha;
    final envio = _canalEnvio;
    _canalEscucha = null;
    _canalEnvio = null;
    _envioSuscrito = false;
    if (escucha != null) {
      Supabase.instance.client.removeChannel(escucha);
    }
    if (envio != null) {
      Supabase.instance.client.removeChannel(envio);
    }
    _codigos.close();
    super.dispose();
  }
}

final remoteScannerProvider =
    StateNotifierProvider<RemoteScannerNotifier, bool>((ref) {
  return RemoteScannerNotifier();
});
