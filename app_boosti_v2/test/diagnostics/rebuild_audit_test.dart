// test/diagnostics/rebuild_audit_test.dart
import 'dart:io';

import 'package:app_boosti_v2/features/pos/data/Local/entities/isar_service.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/inventory_catalog_screen.dart';
import 'package:app_boosti_v2/features/pos/presentation/screens/inventory_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_helpers.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // ✅ Bloquear HTTP real: cualquier `Image.network` falla rápido
    //    en vez de esperar indefinidamente por un servidor inexistente.
    HttpOverrides.global = _FastFailHttpOverrides();

    tempDir = await setupIsarForTest();
  });

  tearDownAll(() async {
    HttpOverrides.global = null;
    await tearDownIsarForTest(tempDir);
  });

  setUp(() async {
    final db = await IsarService().db;
    await db.writeTxn(() async => db.clear());

    // Sembrar usuario para que las pantallas no lancen
    // `No hay usuario autenticado`.
    await db.writeTxn(() async {
      await db.usuarioEntitys.put(_buildFakeUsuario()..id = 1);
    });
  });

  group('Rebuild audit', () {
    testWidgets(
      'InventoryCatalogScreen — primera apertura',
      (tester) async {
        final report = await _runRebuildAudit(
          tester,
          const InventoryCatalogScreen(),
          overrides: _usuarioOverride(),
        );
        report.printReport();
        expect(
          report.screenRebuilds,
          lessThan(20),
          reason: 'Rebuilds: ${report.screenRebuilds}',
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'InventoryScreen — primera apertura',
      (tester) async {
        final report = await _runRebuildAudit(
          tester,
          const InventoryScreen(),
          overrides: _usuarioOverride(),
        );
        report.printReport();
        expect(
          report.screenRebuilds,
          lessThan(20),
          reason: 'Rebuilds: ${report.screenRebuilds}',
        );
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}

// ══════════════════════════════════════════════════════════════
// HTTP OVERRIDES (para que Image.network no cuelgue)
// ══════════════════════════════════════════════════════════════

class _FastFailHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.connectionTimeout = const Duration(milliseconds: 100);
    return client;
  }
}

// ══════════════════════════════════════════════════════════════
// USUARIO FAKE
// ══════════════════════════════════════════════════════════════

UsuarioEntity _buildFakeUsuario() => UsuarioEntity()
  ..id = 1
  ..nombre = 'Tester'
  ..pin = '0000'
  ..rol = 'admin'
  ..activo = true
  ..estado = 'activo';

class _FakeUsuariosNotifier extends UsuariosNotifier {
  _FakeUsuariosNotifier(super.ref, UsuarioEntity? user){
    state = user;
  }
}

List<Override> _usuarioOverride() {
  return [
    usuarioActualProvider.overrideWith(
      (ref) => _FakeUsuariosNotifier(ref, _buildFakeUsuario()),
    ),
  ];
}

// ══════════════════════════════════════════════════════════════
// REPORTE
// ══════════════════════════════════════════════════════════════

class _RebuildReport {
  final String screenName;
  final int screenRebuilds;
  final List<String> providerEvents;

  const _RebuildReport({
    required this.screenName,
    required this.screenRebuilds,
    required this.providerEvents,
  });

  void printReport() {
    const sep = '═══════════════════════════════════════════════════';
    final div = '─' * 51;

    debugPrint(sep);
    debugPrint('REBUILD AUDIT: $screenName');
    debugPrint(div);
    debugPrint('· Screen rebuilds:   $screenRebuilds');
    debugPrint('· Provider events:   ${providerEvents.length}');
    debugPrint(div);
    debugPrint('PROVIDER EVENTS:');
    for (final e in providerEvents) {
      debugPrint('  → $e');
    }
    debugPrint(sep);
  }
}

// ══════════════════════════════════════════════════════════════
// CONTADOR DE REBUILDS
// ══════════════════════════════════════════════════════════════

class _RebuildProbe extends StatefulWidget {
  final Widget child;
  final void Function() onBuild;

  const _RebuildProbe({required this.child, required this.onBuild});

  @override
  State<_RebuildProbe> createState() => _RebuildProbeState();
}

class _RebuildProbeState extends State<_RebuildProbe> {
  @override
  Widget build(BuildContext context) {
    widget.onBuild();
    return widget.child;
  }
}

// ══════════════════════════════════════════════════════════════
// RUNNER
// ══════════════════════════════════════════════════════════════

Future<_RebuildReport> _runRebuildAudit(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
  Duration maxWait = const Duration(seconds: 5),
}) async {
  final observer = _CountingObserver();
  int rebuilds = 0;

  await tester.pumpWidget(
    ProviderScope(
      observers: [observer],
      overrides: overrides,
      child: MaterialApp(
        home: _RebuildProbe(
          onBuild: () => rebuilds++,
          child: screen,
        ),
      ),
    ),
  );

  // ─── Fase 1: pumps virtuales ──────────────────────────────────
  // 20 frames de 100 ms → procesa microtasks y rebuilds de Riverpod.
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  // ─── Fase 2: dejar correr I/O real con watchdog ───────────────
  // `runAsync` permite ejecutar código async fuera del FakeAsync. Así
  // un `Socket.connect`, `HttpClient` o `Future.delayed` real puede
  // fallar de verdad en lugar de quedar colgado para siempre.
  try {
    await tester
        .runAsync(() async {
      await Future<void>.delayed(maxWait);
    })
        .timeout(maxWait + const Duration(seconds: 1));
  } catch (_) {
    // Si el watchdog se agota, seguimos con lo medido.
  }

  // ─── Fase 3: pumps finales para consolidar ────────────────────
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }

  return _RebuildReport(
    screenName: screen.runtimeType.toString(),
    screenRebuilds: rebuilds,
    providerEvents: observer.events,
  );
}

class _CountingObserver extends ProviderObserver {
  final List<String> events = [];

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    events.add('${_name(provider)} · init');
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    events.add(
      '${_name(provider)} · ${_short(previousValue)} → ${_short(newValue)}',
    );
  }

  String _name(ProviderBase<Object?> provider) =>
      provider.name ?? provider.runtimeType.toString();

  String _short(Object? value) {
    if (value == null) return 'null';
    final s = value.toString().replaceAll('\n', ' ');
    return s.length <= 60 ? s : '${s.substring(0, 57)}…';
  }
}