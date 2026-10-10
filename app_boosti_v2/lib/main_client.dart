import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap.dart';
import 'core/config/app_mode.dart';
import 'app.dart' as app;

/// Entry point para el flavor CLIENT.
///
/// Este es el punto de entrada oficial para la app de POS.
void main() async {
  final result = await bootstrap();

  runApp(
    ProviderScope(
      overrides: [
        appModeProvider.overrideWithValue(AppMode.client),
      ],
      child: app.BoostiPOS(
        supabaseInitialized: result.supabaseInitialized,
        mode: AppMode.client,
      ),
    ),
  );
}
