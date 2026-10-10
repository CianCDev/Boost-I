import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/bootstrap.dart';
import 'core/config/app_mode.dart';
import 'app.dart' as app;

/// Entry point para el flavor ADMIN.
///
/// Este es el punto de entrada oficial para el Control Center.
void main() async {
  final result = await bootstrap();

  runApp(
    ProviderScope(
      overrides: [
        appModeProvider.overrideWithValue(AppMode.admin),
      ],
      child: app.BoostiPOS(
        supabaseInitialized: result.supabaseInitialized,
        mode: AppMode.admin,
      ),
    ),
  );
}
