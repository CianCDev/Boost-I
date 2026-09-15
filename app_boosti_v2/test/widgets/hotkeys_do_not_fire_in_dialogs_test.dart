// test/widgets/hotkeys_do_not_fire_in_dialogs_test.dart
import 'package:app_boosti_v2/features/pos/presentation/utils/keyboard_shortcut_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Estado del harness que registra cuántas veces se disparó el hotkey.
class _HotkeyHarness extends StatefulWidget {
  final List<int> disparos;
  const _HotkeyHarness({required this.disparos});

  @override
  State<_HotkeyHarness> createState() => _HotkeyHarnessState();
}

class _HotkeyHarnessState extends State<_HotkeyHarness> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.addHandler(_manejar);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_manejar);
    _searchFocusNode.dispose();
    super.dispose();
  }

  /// ─── Misma lógica que InventoryCatalogScreen ───
  bool get _hayRutaEncima {
    try {
      final route = ModalRoute.of(context);
      return route != null && !route.isCurrent;
    } catch (_) {
      return false;
    }
  }

  bool get _hayTextFieldEnFoco {
    final primaryFocus = FocusManager.instance.primaryFocus;
    if (primaryFocus == null) return false;
    if (primaryFocus == _searchFocusNode) return false;

    final ctx = primaryFocus.context;
    if (ctx == null) return false;

    final widget = ctx.widget;
    final tipo = widget.runtimeType.toString();
    if (widget is EditableText) return true;
    if (tipo == 'EditableText') return true;
    if (tipo == 'TextField') return true;
    if (tipo == 'TextFormField') return true;

    try {
      final el = ctx as Element;
      final editable = el.findAncestorWidgetOfExactType<EditableText>();
      if (editable != null) return true;
    } catch (_) {}

    return false;
  }

  bool _manejar(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final key = event.logicalKey;

    // Escape siempre procesa
    if (key == LogicalKeyboardKey.escape) return true;

    // Guardas
    if (_hayRutaEncima || _hayTextFieldEnFoco) return false;

    // Hotkeys 1-9
     final int? numero = KeyboardShortcutHelper.keyToDigit(key);
    if (numero != null) {
      if (_searchFocusNode.hasFocus) return false;   // ✅ NUEVA LÍNEA
      widget.disparos.add(numero);
      return true;
    }

    return false;
  }

  /// Botón que abre un diálogo con un TextField dentro.
  void _abrirDialogoConInput(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Dialog con input'),
        content: const TextField(
          autofocus: true,
          decoration: InputDecoration(labelText: 'PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(labelText: 'Buscador'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _abrirDialogoConInput(context),
              child: const Text('Abrir dialog'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  group('Hotkeys 1-9 — regresión', () {
    testWidgets('SIN foco en ningún TextField, "5" dispara el hotkey',
        (tester) async {
      final disparos = <int>[];

      await tester.pumpWidget(
        MaterialApp(home: _HotkeyHarness(disparos: disparos)),
      );
      await tester.pumpAndSettle();

      // Nos aseguramos de que NO hay foco en ningún input
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
      await tester.pumpAndSettle();

      expect(disparos, [5]);
    });

    testWidgets('CON foco en el buscador, "5" NO dispara el hotkey',
        (tester) async {
      final disparos = <int>[];

      await tester.pumpWidget(
        MaterialApp(home: _HotkeyHarness(disparos: disparos)),
      );
      await tester.pumpAndSettle();

      // Enfocar el buscador
      await tester.tap(find.widgetWithText(TextField, 'Buscador'));
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
      await tester.pumpAndSettle();

      expect(disparos, isEmpty);
    });

    testWidgets(
      'CON un AlertDialog abierto y su TextField enfocado, '
      '"5" NO dispara el hotkey',
      (tester) async {
        final disparos = <int>[];

        await tester.pumpWidget(
          MaterialApp(home: _HotkeyHarness(disparos: disparos)),
        );
        await tester.pumpAndSettle();

        // Abrir el dialog
        await tester.tap(find.text('Abrir dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Dialog con input'), findsOneWidget);

        // Enviar la tecla 5 dentro del dialog
        await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
        await tester.pumpAndSettle();

        // El hotkey NO debe haberse disparado
        expect(disparos, isEmpty);
      },
    );

    testWidgets(
      'CON un AlertDialog abierto pero SIN TextField enfocado, '
      '"5" NO dispara el hotkey (guard por ModalRoute)',
      (tester) async {
        final disparos = <int>[];

        await tester.pumpWidget(
          MaterialApp(home: _HotkeyHarness(disparos: disparos)),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Abrir dialog'));
        await tester.pumpAndSettle();

        // Quitar el foco del TextField del dialog, pero dejar el dialog abierto
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
        await tester.pumpAndSettle();

        // El hotkey sigue bloqueado porque hay una ModalRoute encima
        expect(disparos, isEmpty);
      },
    );

    testWidgets('después de cerrar el dialog, "5" vuelve a disparar',
        (tester) async {
      final disparos = <int>[];

      await tester.pumpWidget(
        MaterialApp(home: _HotkeyHarness(disparos: disparos)),
      );
      await tester.pumpAndSettle();

      // Abrir y cerrar el dialog
      await tester.tap(find.text('Abrir dialog'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      // Quitar foco por si quedó residual
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.digit5);
      await tester.pumpAndSettle();

      expect(disparos, [5]);
    });

    testWidgets('numpad también funciona', (tester) async {
      final disparos = <int>[];

      await tester.pumpWidget(
        MaterialApp(home: _HotkeyHarness(disparos: disparos)),
      );
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.numpad7);
      await tester.pumpAndSettle();

      expect(disparos, [7]);
    });

    testWidgets('teclas no numéricas no disparan', (tester) async {
      final disparos = <int>[];

      await tester.pumpWidget(
        MaterialApp(home: _HotkeyHarness(disparos: disparos)),
      );
      await tester.pumpAndSettle();

      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(LogicalKeyboardKey.keyA);
      await tester.sendKeyEvent(LogicalKeyboardKey.digit0);
      await tester.pumpAndSettle();

      expect(disparos, isEmpty);
    });
  });
}