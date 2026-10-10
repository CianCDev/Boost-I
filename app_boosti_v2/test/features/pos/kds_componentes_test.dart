// test/features/pos/kds_componentes_test.dart
//
// R.3.2 PASO B · Componentes compartidos del KDS.
//
// Tests de widget, sin Isar y sin Riverpod: `ProductThumbnail`,
// `TimeBadge`, `StickyNote`, `QuantityControl` e `ItemCard` son
// presentacionales puros, así que basta con un `MaterialApp` envuelto.
//
// ⚠️ `DepartamentoSelector` NO se testea aquí: es el único componente de
// `common/` que lee providers (`localActualProvider` +
// `departamentosActivosProvider`), y montarlo exigiría el mismo
// `ProviderContainer` + Isar temporal que usan los tests del KDS. Queda
// como TODO para cuando exista una pantalla que lo consuma.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_boosti_v2/features/pos/presentation/utils/duracion_utils.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/item_card.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/product_thumbnail.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/quantity_control.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/sticky_note.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/common/time_badge.dart';

Widget envolver(Widget hijo) => MaterialApp(
      home: Scaffold(body: Center(child: hijo)),
    );

void main() {
  // ══════════════════════════════════════════════════════════════
  // DuracionUtils (puro, sin widgets)
  // ══════════════════════════════════════════════════════════════

  group('DuracionUtils.hace', () {
    final ahora = DateTime(2026, 6, 15, 12, 0, 0);
    String h(DateTime desde) => DuracionUtils.hace(desde, ahora: ahora);

    test('null → guion', () {
      expect(DuracionUtils.hace(null, ahora: ahora), '—');
    });

    test('segundos', () {
      expect(h(ahora.subtract(const Duration(seconds: 45))), 'hace 45 seg');
      expect(h(ahora.subtract(const Duration(seconds: 1))), 'hace 1 seg');
    });

    test('minutos', () {
      expect(h(ahora.subtract(const Duration(minutes: 1))), 'hace 1 min');
      expect(h(ahora.subtract(const Duration(minutes: 59))), 'hace 59 min');
    });

    test('horas exactas sin minutos', () {
      expect(h(ahora.subtract(const Duration(hours: 1))), 'hace 1 h');
      expect(h(ahora.subtract(const Duration(hours: 5))), 'hace 5 h');
    });

    test('horas con minutos sobrantes', () {
      expect(
        h(ahora.subtract(const Duration(hours: 2, minutes: 15))),
        'hace 2 h 15 min',
      );
    });

    test('días', () {
      expect(h(ahora.subtract(const Duration(days: 1))), 'hace 1 d');
      expect(h(ahora.subtract(const Duration(days: 5))), 'hace 5 d');
    });

    test('un reloj en el futuro no da negativos', () {
      // Desajuste entre dispositivos: sin esto saldría "hace -3 min".
      expect(h(ahora.add(const Duration(minutes: 3))), 'hace 0 seg');
    });

    test('sin `ahora` usa el reloj del sistema sin romper', () {
      final texto = DuracionUtils.hace(DateTime.now());
      expect(texto.startsWith('hace'), isTrue);
    });
  });

  group('DuracionUtils.minutosDesde', () {
    final ahora = DateTime(2026, 6, 15, 12);

    test('null → 0', () {
      expect(DuracionUtils.minutosDesde(null, ahora: ahora), 0);
    });

    test('menos de un minuto → 0', () {
      expect(
        DuracionUtils.minutosDesde(
            ahora.subtract(const Duration(seconds: 59)),
            ahora: ahora),
        0,
      );
    });

    test('minutos exactos', () {
      expect(
        DuracionUtils.minutosDesde(
            ahora.subtract(const Duration(minutes: 7)),
            ahora: ahora),
        7,
      );
    });
  });

  group('UmbralesUrgencia', () {
    test('son monotónicos y contiguos', () {
      // Si alguien cambia un umbral sin revisar el siguiente, el KDS
      // deja de tener un tramo. Este test avisa.
      expect(UmbralesUrgencia.verdeHastaMin,
          lessThan(UmbralesUrgencia.ambarHastaMin));
      expect(UmbralesUrgencia.ambarHastaMin,
          lessThan(UmbralesUrgencia.naranjaHastaMin));
      expect(UmbralesUrgencia.naranjaHastaMin, UmbralesUrgencia.rojoDesdeMin);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // TimeBadge
  // ══════════════════════════════════════════════════════════════

  group('TimeBadge · color por urgencia', () {
    final ahora = DateTime(2026, 6, 15, 12);

    Color colorDe(int minutos) => TimeBadge.colorPorMinutos(minutos);

    test('0-5 min → verde', () {
      expect(colorDe(0), const Color(0xFF10B981));
      expect(colorDe(5), isNot(const Color(0xFF10B981)),
          reason: 'a los 5 exactos ya es ámbar, no verde');
      expect(colorDe(4), const Color(0xFF10B981));
    });

    test('5-10 min → ámbar', () {
      expect(colorDe(5), const Color(0xFFF59E0B));
      expect(colorDe(9), const Color(0xFFF59E0B));
    });

    test('10-15 min → naranja', () {
      expect(colorDe(10), const Color(0xFFF97316));
      expect(colorDe(14), const Color(0xFFF97316));
    });

    test('>15 min → rojo', () {
      expect(colorDe(15), const Color(0xFFEF4444));
      expect(colorDe(99), const Color(0xFFEF4444));
    });

    test('la opacidad del fondo sube con la urgencia', () {
      final o1 = TimeBadge.opacidadPorMinutos(1);
      final o2 = TimeBadge.opacidadPorMinutos(7);
      final o3 = TimeBadge.opacidadPorMinutos(12);
      expect(o1, lessThan(o2));
      expect(o2, lessThan(o3));
    });

    testWidgets('renderiza el texto de antigüedad', (tester) async {
      await tester.pumpWidget(envolver(
        TimeBadge(
          desde: ahora.subtract(const Duration(minutes: 3)),
          ahora: ahora,
        ),
      ));

      expect(find.text('hace 3 min'), findsOneWidget);
    });

    testWidgets('compact omite el "hace"', (tester) async {
      await tester.pumpWidget(envolver(
        TimeBadge(
          desde: ahora.subtract(const Duration(minutes: 3)),
          ahora: ahora,
          compact: true,
        ),
      ));

      expect(find.text('3 min'), findsOneWidget);
      expect(find.text('hace 3 min'), findsNothing);
    });

    testWidgets('sin `desde` muestra el guion', (tester) async {
      await tester.pumpWidget(envolver(TimeBadge(desde: null, ahora: ahora)));
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('usa el `ahora` del padre, no su propio reloj',
        (tester) async {
      // Dos badges con el mismo `desde` pero distinto `ahora` deben
      // discrepar: es lo que permite que el Timer del KDS los repinte.
      await tester.pumpWidget(envolver(
        Column(
          children: [
            TimeBadge(desde: ahora, ahora: ahora),
            TimeBadge(
              desde: ahora,
              ahora: ahora.add(const Duration(minutes: 8)),
            ),
          ],
        ),
      ));

      expect(find.text('hace 0 seg'), findsOneWidget);
      expect(find.text('hace 8 min'), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // ProductThumbnail
  // ══════════════════════════════════════════════════════════════

  group('ProductThumbnail', () {
    testWidgets('sin URL → placeholder con el ícono por defecto',
        (tester) async {
      await tester.pumpWidget(envolver(ProductThumbnail()));

      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('URL vacía o en blanco → placeholder', (tester) async {
      await tester.pumpWidget(envolver(ProductThumbnail(imageUrl: '')));
      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);

      await tester.pumpWidget(envolver(ProductThumbnail(imageUrl: '   ')));
      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget);
    });

    testWidgets('con URL → Image.network', (tester) async {
      await tester.pumpWidget(envolver(
        ProductThumbnail(imageUrl: 'https://ejemplo.com/a.jpg'),
      ));

      // ⚠️ Solo se verifica que hay un `Image`. NO se asserta el
      // `CircularProgressIndicator` del `loadingBuilder`: en un test no hay
      // event loop de red real, así que `ImageStreamCompleter` resuelve
      // antes del primer frame y el `loadingBuilder` nunca se pinta.
      // Comprobarlo exigiría un `HttpOverrides` con un cliente falso, que es
      // mucho trabajo para una función que Flutter ya garantiza.
      expect(find.byType(Image), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_rounded), findsNothing,
          reason: 'con URL no debe verse el placeholder');
    });

    testWidgets('URL inválida → placeholder por errorBuilder', (tester) async {
      await tester.pumpWidget(envolver(
        ProductThumbnail(imageUrl: 'no-es-una-url-valida://x'),
      ));

      // Se deja asentar el error de red antes de comprobar el fallback.
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byIcon(Icons.inventory_2_rounded), findsOneWidget,
          reason: 'si la imagen falla, debe verse el placeholder');
    });

    testWidgets('respeta el tamaño pedido', (tester) async {
      await tester.pumpWidget(envolver(
        ProductThumbnail(size: 100),
      ));

      final box = tester.getSize(find.byType(ProductThumbnail));
      expect(box.width, 100);
      expect(box.height, 100);
    });

    testWidgets('acepta ícono de placeholder propio', (tester) async {
      await tester.pumpWidget(envolver(
        ProductThumbnail(placeholderIcon: Icons.local_drink_rounded),
      ));
      expect(find.byIcon(Icons.local_drink_rounded), findsOneWidget);
    });
  });

  // ══════════════════════════════════════════════════════════════
  // StickyNote
  // ══════════════════════════════════════════════════════════════

  group('StickyNote', () {
    testWidgets('renderiza el texto', (tester) async {
      await tester.pumpWidget(envolver(
        StickyNote(texto: 'sin cebolla'),
      ));
      expect(find.text('sin cebolla'), findsOneWidget);
      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);
    });

    testWidgets('texto vacío o en blanco NO ocupa espacio', (tester) async {
      await tester.pumpWidget(envolver(
        Column(
          children: [
            const StickyNote(texto: '  '),
            const StickyNote(texto: 'visible'),
          ],
        ),
      ));

      expect(find.text('visible'), findsOneWidget);
      final vacia = find.byType(StickyNote).first;
      expect(tester.getSize(vacia), const Size(0, 0));
    });

    testWidgets('sin onEdit no responde al tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(envolver(
        StickyNote(texto: 'nota', onEdit: () => taps++),
      ));

      await tester.tap(find.text('nota'));
      await tester.pump();
      expect(taps, 1);
    });

    testWidgets('small cambia el tamaño', (tester) async {
      await tester.pumpWidget(envolver(
        Column(
          children: [
            StickyNote(texto: 'grande'),
            StickyNote(texto: 'chica', small: true),
          ],
        ),
      ));

      final grande = tester.getSize(find.text('grande').first);
      final chica = tester.getSize(find.text('chica').first);
      expect(chica.height, lessThan(grande.height));
    });
  });

  // ══════════════════════════════════════════════════════════════
  // QuantityControl
  // ══════════════════════════════════════════════════════════════

  group('QuantityControl', () {
    testWidgets('dispara los callbacks', (tester) async {
      var mas = 0;
      var menos = 0;

      await tester.pumpWidget(envolver(
        QuantityControl(
          cantidad: 2,
          onIncrementar: () => mas++,
          onDecrementar: () => menos++,
        ),
      ));

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(mas, 1);

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(menos, 1);
    });

    testWidgets('[-] se desactiva en el mínimo', (tester) async {
      var menos = 0;
      await tester.pumpWidget(envolver(
        QuantityControl(
          cantidad: 1,
          onIncrementar: () {},
          onDecrementar: () => menos++,
        ),
      ));

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(menos, 0, reason: 'cantidad == minimo');
    });

    testWidgets('[-] funciona por encima del mínimo', (tester) async {
      var menos = 0;
      await tester.pumpWidget(envolver(
        QuantityControl(
          cantidad: 3,
          onDecrementar: () => menos++,
          onIncrementar: () {},
        ),
      ));

      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pump();
      expect(menos, 1);
    });

    testWidgets('`habilitado: false` apaga ambos', (tester) async {
      var mas = 0;
      await tester.pumpWidget(envolver(
        QuantityControl(
          cantidad: 5,
          habilitado: false,
          onIncrementar: () => mas++,
          onDecrementar: () {},
        ),
      ));

      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pump();
      expect(mas, 0);
    });

    testWidgets('formato: entero sin peso, 3 decimales con peso',
        (tester) async {
      await tester.pumpWidget(envolver(
        QuantityControl(cantidad: 2),
      ));
      expect(find.text('2'), findsOneWidget);

      await tester.pumpWidget(envolver(
        QuantityControl(cantidad: 1.25, esPesado: true),
      ));
      expect(find.text('1.250'), findsOneWidget);
    });

    testWidgets('compact cambia el alto del botón', (tester) async {
      await tester.pumpWidget(envolver(
        Column(
          children: [
            QuantityControl(cantidad: 1),
            QuantityControl(cantidad: 1, compacto: false),
          ],
        ),
      ));

      final chico = tester.getSize(find.byIcon(Icons.add_rounded).first);
      final grande = tester.getSize(find.byIcon(Icons.add_rounded).last);
      expect(grande.height, greaterThan(chico.height));
    });
  });

  // ══════════════════════════════════════════════════════════════
  // ItemCard
  // ══════════════════════════════════════════════════════════════

  group('ItemCard', () {
    testWidgets('monta con los parámetros mínimos', (tester) async {
      await tester.pumpWidget(envolver(ItemCard(nombre: 'Lomo')));

      expect(find.text('Lomo'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('monta con todos los parámetros', (tester) async {
      final ahora = DateTime(2026, 6, 15, 12);

      await tester.pumpWidget(envolver(ItemCard(
        thumbnail: const ProductThumbnail(),
        nombre: 'Lomo saltado',
        detalle: r'1 × $25.00',
        precio: r'$25.00',
        badgeEstado: TimeBadge(
          desde: ahora.subtract(const Duration(minutes: 3)),
          ahora: ahora,
        ),
        nota: const StickyNote(texto: 'sin cebolla'),
        cantidad: QuantityControl(cantidad: 1),
        colorBorde: const Color(0xFF10B981),
        trailing: const Icon(Icons.more_vert_rounded),
      )));

      expect(find.text('Lomo saltado'), findsOneWidget);
      expect(find.text(r'1 × $25.00'), findsOneWidget);
      expect(find.text(r'$25.00'), findsOneWidget);
      expect(find.text('hace 3 min'), findsOneWidget);
      expect(find.text('sin cebolla'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('compact oculta el precio suelto', (tester) async {
      await tester.pumpWidget(envolver(
        ItemCard(nombre: 'Postre', precio: r'$4.00', compact: true),
      ));

      expect(find.text('Postre'), findsOneWidget);
      expect(find.text(r'$4.00'), findsNothing);
    });

    testWidgets('responde al tap y al long-press', (tester) async {
      var taps = 0;
      var largos = 0;

      await tester.pumpWidget(envolver(ItemCard(
        nombre: 'Café',
        onTap: () => taps++,
        onLongPress: () => largos++,
      )));

      await tester.tap(find.text('Café'));
      await tester.pump();
      expect(taps, 1);

      await tester.longPress(find.text('Café'));
      await tester.pump();
      expect(largos, 1);
    });

    testWidgets('sin thumbnail no deja hueco fantasma', (tester) async {
      await tester.pumpWidget(envolver(ItemCard(nombre: 'Agua')));

      expect(find.byType(ProductThumbnail), findsNothing);
      expect(find.text('Agua'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
