// lib/features/legal/data/legal_acceptance_store.dart

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'legal_texts.dart';

/// Registro de que un usuario acepto una version concreta del documento legal.
///
/// ## Que garantiza y que no
///
/// **Garantiza** que en ese dispositivo se mostro el texto de la version
/// `v` y que el usuario marco las dos casillas antes de continuar.
///
/// **No garantiza** que ese texto era exactamente el que JAHTLABS publico
/// ese dia. Un usuario con acceso al almacenamiento del dispositivo puede
/// alterar la marca de tiempo. Para prueba con valor legal hay que subir la
/// aceptacion al servidor con marca de tiempo del servidor; la migracion
/// `20261018000001_legal_acceptance.sql` deja la tabla lista para eso.
///
/// ## Por que el stockage es local
///
/// El registro se escribe en el alta, antes de que exista el PIN. El
/// dispositivo puede estar sin conexion y el flujo no puede depender de la
/// nube para avanzar. El envio al servidor, si procede, se hace aparte.
class LegalAcceptanceStore {
  LegalAcceptanceStore(this._prefs);

  final SharedPreferences _prefs;

  static const String _prefijo = 'legal_aceptado_';

  /// Devuelve el registro de aceptacion de [userId], o `null` si no hay.
  ///
  /// Si la version guardada no coincide con [kLegalVersion] devuelve `null`:
  /// el texto cambio y hay que volver a pedir la aceptacion.
  Acceptance? leer(String userId) {
    final bruto = _prefs.getString('$_prefijo$userId');
    if (bruto == null || bruto.isEmpty) return null;

    try {
      final mapa = jsonDecode(bruto);
      if (mapa is! Map) return null;

      final version = mapa['version'];
      final usuario = mapa['usuarioId'];
      final aceptadoEn = mapa['aceptadoEn'];

      if (version is! String || usuario is! String || aceptadoEn is! String) {
        return null;
      }

      return Acceptance(
        version: version,
        usuarioId: usuario,
        aceptadoEn: DateTime.tryParse(aceptadoEn),
      );
    } on FormatException {
      // Registro corrupto: se descarta y se vuelve a pedir la aceptacion.
      debugPrint('legal: registro de aceptacion ilegible para $userId');
      return null;
    }
  }

  /// Si el usuario ya acepto la version vigente.
  bool yaAcepto(String userId) {
    final a = leer(userId);
    return a != null && a.version == kLegalVersion && a.aceptadoEn != null;
  }

  /// Registra la aceptacion.
  ///
  /// Devuelve `true` si se guardo. Un `false` significa que no se pudo
  /// escribir en disco: la pantalla debe bloquear el avance en ese caso,
  /// porque aceptar sin registro es peor que no tener aceptacion.
  ///
  /// Es `Future` porque `SharedPreferences.setString` lo es. No awaitar
  /// devolviendo `true` a ciegas seria mentir: el registro podria no haber
  /// llegado al disco.
  Future<bool> registrar(String userId, {DateTime? momento}) async {
    final ahora = momento ?? DateTime.now();
    final registro = Acceptance(
      version: kLegalVersion,
      usuarioId: userId,
      aceptadoEn: ahora,
    );
    return _prefs.setString('$_prefijo$userId', jsonEncode(registro.toJson()));
  }

  /// Borra la aceptacion. Lo usa el cambio de version del documento.
  void borrar(String userId) {
    _prefs.remove('$_prefijo$userId');
  }
}

/// Un registro de aceptacion.
class Acceptance {
  final String version;
  final String usuarioId;
  final DateTime? aceptadoEn;

  const Acceptance({
    required this.version,
    required this.usuarioId,
    this.aceptadoEn,
  });

  Map<String, Object?> toJson() => {
        'version': version,
        'usuarioId': usuarioId,
        'aceptadoEn': aceptadoEn?.toIso8601String(),
      };
}