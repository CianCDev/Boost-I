import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class OtaUpdateService {
  static final ShorebirdUpdater _updater = ShorebirdUpdater();
  static SharedPreferences? _prefs;

  static void checkForUpdateSilently() {
    try {
      if (kIsWeb || !kReleaseMode || !_updater.isAvailable) {
        Sentry.captureMessage('ota_no_inicializado');
        _persistAttempt('no_inicializado');
        return;
      }

      SharedPreferences.getInstance().then((prefs) {
        _prefs = prefs;
        final String selectedTrack = trackActual();
        prefs.setString('ota_track', selectedTrack);

        return _updater
            .checkForUpdate(track: UpdateTrack(selectedTrack))
            .timeout(const Duration(seconds: 5))
            .then((status) {
          if (status == UpdateStatus.outdated) {
            Sentry.captureMessage('ota_patch_disponible');
            prefs.setBool('ota_patch_pendiente', true);
            return _updater.update(track: UpdateTrack(selectedTrack)).then((_) {
              Sentry.captureMessage('ota_patch_aplicado');
              return _updater.readNextPatch().then((patch) {
                if (patch != null) {
                  prefs.setInt('ota_patch_number', patch.number);
                }
                _persistAttempt('success');
              });
            });
          }

          prefs.setBool('ota_patch_pendiente', false);
          _persistAttempt('no_update');
          return Future<void>.value();
        });
      }).catchError((Object error, StackTrace stack) {
        Sentry.captureException(error, stackTrace: stack);
        Sentry.captureMessage('ota_error');
        _persistAttempt('error');
      });
    } catch (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      Sentry.captureMessage('ota_error');
      _persistAttempt('error');
    }
  }

  static Future<bool> hayPatchPendiente() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ota_patch_pendiente') ?? false;
  }

  static String trackActual() {
    return _prefs?.getString('ota_track') ?? 'stable';
  }

  static void _persistAttempt(String state) {
    final now = DateTime.now().toUtc().toIso8601String();
    final prefs = _prefs;
    if (prefs == null) {
      return;
    }

    prefs.setString('ota_ultima_comprobacion', now);
    prefs.setString('ota_estado_ultimo_intento', state);
    prefs.setString('ota_track', trackActual());
    prefs.setString('ota_release_version', '1.0.0+1');
  }
}
