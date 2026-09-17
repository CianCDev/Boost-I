import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

class OtaUpdateService {
  static final ShorebirdUpdater _updater = ShorebirdUpdater();

  static Future<void> checkForUpdateSilently() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String selectedTrack = prefs.getString('ota_track') ?? 'stable';

      if (kIsWeb || !kReleaseMode || !_updater.isAvailable) {
        Sentry.captureMessage('ota_no_inicializado');
        await _persistAttempt(prefs, 'no_inicializado', selectedTrack);
        return;
      }

      await prefs.setString('ota_track', selectedTrack);

      final status = await _updater
          .checkForUpdate(track: UpdateTrack(selectedTrack))
          .timeout(const Duration(seconds: 5));

      if (status == UpdateStatus.outdated) {
        Sentry.captureMessage('ota_patch_disponible');
        await prefs.setBool('ota_patch_pendiente', true);

        await _updater.update(track: UpdateTrack(selectedTrack));
        Sentry.captureMessage('ota_patch_aplicado');

        final patch = await _updater.readNextPatch();
        if (patch != null) {
          await prefs.setInt('ota_patch_number', patch.number);
        }
        
        await _persistAttempt(prefs, 'success', selectedTrack);
      } else {
        await prefs.setBool('ota_patch_pendiente', false);
        await _persistAttempt(prefs, 'no_update', selectedTrack);
      }
    } on TimeoutException catch (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      Sentry.captureMessage('ota_timeout');
      await _tryPersistErrorState('timeout');
    } catch (error, stack) {
      Sentry.captureException(error, stackTrace: stack);
      Sentry.captureMessage('ota_error');
      await _tryPersistErrorState('error');
    }
  }

  static Future<bool> hayPatchPendiente() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('ota_patch_pendiente') ?? false;
  }

  static Future<String> trackActual() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('ota_track') ?? 'stable';
  }

  static Future<void> _persistAttempt(
    SharedPreferences prefs,
    String state,
    String track,
  ) async {
    final now = DateTime.now().toUtc().toIso8601String();
    
    // Es recomendable usar SharedPreferences asíncrono para asegurar la escritura
    await prefs.setString('ota_ultima_comprobacion', now);
    await prefs.setString('ota_estado_ultimo_intento', state);
    await prefs.setString('ota_track', track);
    
    // TODO: Considerar usar package_info_plus en lugar de hardcodear esto
    await prefs.setString('ota_release_version', '1.0.0+1');
  }

  static Future<void> _tryPersistErrorState(String state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final track = prefs.getString('ota_track') ?? 'stable';
      await _persistAttempt(prefs, state, track);
    } catch (_) {
      // Ignoramos fallos secundarios si ya estamos intentando loguear un error
    }
  }
}