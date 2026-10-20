import 'package:sentry_flutter/sentry_flutter.dart';

/// Limpia datos personales y credenciales antes de enviar un evento a Sentry.
///
/// ## Por que existe
///
/// `SentryFlutter.init` con `beforeSend` filtra por **tipo** de excepcion
/// (ver `bootstrap.dart`), pero el contenido del error viaja sin limpiar. Un
/// `throwable.toString()` de una consulta a Supabase puede llevar dentro el
/// SQL de una venta, el RIF de un cliente o un telefono. Eso cruza la
/// frontera del dispositivo del cliente hacia un servidor de terceros.
///
/// La LOPDP (Ley Organica de Proteccion de Datos Personales, vigente) trata
/// cedula, RIF, telefono y correo como datos personales. `AGENTS.MD` seccion 3
/// marca la privacidad como requisito no negociable.
///
/// ## Que reemplaza
///
/// Cada patron se sustituye por su etiqueta entre corchetes. Se conserva la
/// forma del texto para que el error siga siendo legible al diagnosticarlo.
///
/// Lo que **no** se limpia:
///
/// - Los identificadores de tenant: son UUID aleatorios, no identifican a
///   una persona y sin ellos ningun bug de aislamiento es diagnosticable.
/// - Los mensajes en espanol sin datos: siguen legibles.
///
/// ## Riesgo residual
///
/// Un dato que no case con ningun patron sale sin limpiar. Los patrones cubren
/// formatos con estructura reconocible, por lo que un dato libre en prosa
/// ("el cliente Juan Perez pidio...") no se detecta. Para eso esta el control
/// de acceso al proyecto de Sentry, que debe ser de JAHTLABS.
class PiiScrubber {
  PiiScrubber._();

  /// Sustituye los patrones de la lista por su etiqueta.
  static String scrub(String texto) {
    if (texto.isEmpty) return texto;
    var out = texto;
    for (final p in _patrones) {
      if (p.usaGrupos) {
        // `String.replaceAll` NO expande `$1`: hay que devolver la
        // sustitucion desde el callback. Por eso el patron de JSON lleva
        // `$1`/`$2` en su etiqueta y se resuelve aqui.
        out = out.replaceAllMapped(p.re, (m) {
          var r = p.etiqueta;
          for (var g = 1; g <= m.groupCount; g++) {
            r = r.replaceAll('\$$g', m.group(g) ?? '');
          }
          return r;
        });
      } else {
        out = out.replaceAll(p.re, p.etiqueta);
      }
    }
    return out;
  }

  /// Devuelve un evento limpio. El original queda intacto.
  ///
  /// `SentryEvent` en sentry 9.x expone `throwable` solo como getter: no hay
  /// setter para reescribir la excepcion. Por eso se reconstruye el evento en
  /// vez de mutarlo. Si algo falla a mitad, el llamador conserva el original.
  static SentryEvent scrubEvent(SentryEvent event) {
    return SentryEvent(
      eventId: event.eventId,
      timestamp: event.timestamp,
      platform: event.platform,
      logger: event.logger,
      serverName: event.serverName,
      release: event.release,
      dist: event.dist,
      environment: event.environment,
      modules: event.modules,
      message: _scrubMessage(event.message),
      transaction: event.transaction,
      throwable: _scrubThrowable(event.throwable),
      level: event.level,
      culprit: event.culprit,
      tags: event.tags,
      extra: _scrubExtra(event.extra),
      fingerprint: event.fingerprint,
      user: event.user,
      contexts: _scrubContexts(event.contexts),
      breadcrumbs: event.breadcrumbs,
      sdk: event.sdk,
      request: event.request,
      debugMeta: event.debugMeta,
      exceptions: event.exceptions,
      threads: event.threads,
      type: event.type,
    );
  }

  static Object? _scrubThrowable(Object? t) {
    if (t == null) return null;

    // `ThrowableMechanism` envuelve al error con metadata del mecanismo.
    // Hay que desenvolver la envoltura: limpiar `t.toString()` daria el texto
    // plano y perderiamos el tipo, que es justo lo que sirve para agrupar
    // errores del mismo tipo en el panel.
    if (t is ThrowableMechanism) {
      final interno = t.throwable;
      if (interno == null) return t;
      final original = interno is String ? interno : interno.toString();
      final limpio = scrub(original);
      if (limpio == original) return t;

      return ThrowableMechanism(t.mechanism, limpio, snapshot: t.snapshot);
    }

    final original = t is String ? t : t.toString();
    final limpio = scrub(original);
    // Un String es un throwable valido: se manda el mensaje ya saneado en
    // lugar de reenviar el objeto original con el dato dentro.
    return limpio == original ? t : limpio;
  }

  static SentryMessage? _scrubMessage(SentryMessage? m) {
    if (m == null) return null;
    final original = m.formatted;
    final limpio = scrub(original);
    return limpio == original ? m : SentryMessage(limpio);
  }

  /// `Contexts` extiende `MapView`, que es **inmutable**: no admite asignar
  /// una clave. Si no hay nada que limpiar se devuelve el original intacto;
  /// si hay, se reconstruye desde el mapa ya limpio.
  ///
  /// Reconstruir tiene un costo: `fromJson` solo conserva los tipos que
  /// Sentry reconoce. Por eso la rama "sin cambios" es la que se ejecuta en
  /// la mayoria de los eventos.
  static Contexts _scrubContexts(Contexts c) {
    if (c.isEmpty) return c;

    var cambio = false;
    final datos = <String, dynamic>{};
    c.forEach((clave, valor) {
      final limpio = _limpiaValor(valor, 0);
      if (limpio != valor) cambio = true;
      datos[clave] = limpio;
    });

    return cambio ? Contexts.fromJson(datos) : c;
  }

  static Map<String, dynamic>? _scrubExtra(Map<String, dynamic>? e) {
    if (e == null || e.isEmpty) return e;
    final salida = Map<String, dynamic>.from(e);
    for (final clave in e.keys.toList()) {
      // La clave se revisa tambien en el primer nivel. Revisar solo el
      // valor dejaba pasar `{'tokenSesion': 'abc123'}` entero: el valor no
      // matchea ningun patron y la clave nunca se miraba.
      if (_claveSensible(clave)) {
        if (salida[clave] != _redactado) salida[clave] = _redactado;
        continue;
      }
      final valor = e[clave];
      final limpio = _limpiaValor(valor, 0);
      if (limpio != valor) salida[clave] = limpio;
    }
    return salida;
  }

  /// Recorre un valor de Sentry hasta una profundidad razonable.
  static Object? _limpiaValor(Object? v, int profundidad) {
    if (profundidad > 3) return v;
    if (v is String) return scrub(v);
    if (v is Map) {
      final salida = <String, dynamic>{};
      v.forEach((clave, valor) {
        final k = '$clave';
        salida[k] =
            _claveSensible(k) ? _redactado : _limpiaValor(valor, profundidad + 1);
      });
      return salida;
    }
    if (v is List) {
      return v.map((e) => _limpiaValor(e, profundidad + 1)).toList();
    }
    return v;
  }

  static const String _redactado = '[REDACTADO]';

  /// Si la clave de un diccionario parece contener una credencial.
  static bool _claveSensible(String key) {
    final k = key.toLowerCase().replaceAll(RegExp('[^a-z]'), '');
    for (final p in _clavesSensible) {
      if (k.contains(p)) return true;
    }
    return false;
  }

  static const _clavesSensible = <String>[
    'password', 'contrasena', 'passwd', 'secret', 'token', 'apikey',
    'anonkey', 'publishablekey', 'privatekey', 'authorization',
    'dsn', 'cookie', 'bearer',
  ];

  /// Los patrones, en orden: los mas especificos primero.
  ///
  /// Un patron general de "cadena larga de digitos" va al final porque
  /// se comeria el RIF y el telefono si fuera el primero.
  static final List<_Patron> _patrones = [
    // JWT: tres segmentos base64url separados por punto.
    _Patron(RegExp(r'\beyJ[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}\.[A-Za-z0-9_-]{8,}'),
        '[JWT]'),

    // Credencial nueva de Supabase: sb_publishable_ / sb_secret_.
    _Patron(RegExp(r'\bsb_(?:publishable|secret)_[A-Za-z0-9_-]+'), '[CREDENCIAL]'),

    // Clave anonima antigua de Supabase.
    _Patron(RegExp(r'\bey[A-Za-z0-9]{20,}\b'), '[CLAVE]'),

    // JSON con clave sensible. Se conservan las comillas y el separador.
    _Patron.grupos(RegExp(
            r'("(?:password|contrasena|secret|token|apikey|anon_?key)"\s*:\s*")[^"]*(")'),
        r'$1[REDACTADO]$2'),

    // RIF o cedula con prefijo: J-12345678-9, V-12345678901.
    //
    // Hasta 11 digitos: el padron tiene que cubrir el RIF de persona
    // juridica (J-12345678-9) y el de persona natural (V-12345678901) sin
    // que el patron de numeros se coma el resto y deje el prefijo colgando.
    _Patron(RegExp(r'\b[JVG]-?\s?\d{6,11}-?\d?\b'), '[RIF]'),

    // Correo electronico.
    _Patron(RegExp(r'\b[\w.+-]+@[\w-]+\.[\w.-]{2,}\b'), '[CORREO]'),

    // Telefono venezolano: 0412-1234567, 0412 123 4567, +58 412 123 4567.
    //
    // El prefijo de pais va en un grupo COMPLETAMENTE opcional. Escribir
    // `\+?58?\s?` deja el "5" como literal, y entonces el patron entero
    // falla en cuanto el numero no empieza por "+58": "0412-1234567" se
    // escapa entero. Un grupo que puede faltar entero se escribe
    // `(?:\+?58)?`, no con los cuantificadores sueltos.
    _Patron(RegExp(r'(?:\+?58[\s.-]?)?\b0?4(?:1[24-9]|2[46]|5[01])'
            r'[\s.-]?\d{3}[\s.-]?\d{4}\b'),
        '[TELEFONO]'),

    // Direccion IP.
    _Patron(RegExp(r'\b(?:\d{1,3}\.){3}\d{1,3}\b'), '[IP]'),

    // Cadena larga de digitos sueltos: tarjetas, RIF sin prefijo,
    // identificadores fiscales. A partir de siete digitos.
    //
    // Las lookarounds son lo que protege los UUID. Un `\b\d{7,}\b` normal
    // matchea el bloque final de `9c7380a4-1111-2222-3333-444455556666`,
    // porque el guion no es un caracter de palabra: el `\b` de la derecha
    // cae entre el guion y el primer digito. Con `(?<![\w-])` y `(?![\w-])`
    // el numero solo se acepta si no esta pegado a otra cosa.
    _Patron(RegExp(r'(?<![\w-])\d{7,}(?![\w-])'), '[NUMERO]'),
  ];
}

/// Un patron de limpieza y la etiqueta con la que se sustituye.
///
/// [usaGrupos] indica que la etiqueta lleva `$1`/`$2`, lo que obliga a
/// pasar por `replaceAllMapped` en vez de `replaceAll`.
class _Patron {
  final RegExp re;
  final String etiqueta;
  final bool usaGrupos;

  const _Patron(this.re, this.etiqueta) : usaGrupos = false;
  const _Patron.grupos(this.re, this.etiqueta) : usaGrupos = true;
}