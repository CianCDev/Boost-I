// lib/features/pos/presentation/screens/restaurante/kds_ticket_card.dart
//
// R.3.2 PASO E · Tarjeta de un ticket de cocina.
//
// ⚠️ POR QUÉ ES UN ARCHIVO PROPIO
//
// `ComandaScreen` (PASO C) tiene sus propios botones de estado, pero son
// los del MESERO: editar cantidad, editar nota. Los del COCINERO son
// distintos (avanzar estado, pausar con motivo) y no encajan en el
// `trailing` de una `ItemCard` de tamaño comanda. Mezclarlos convertiría
// los dos archivos en una bolsa de funciones con `if (esKds)` por todas
// partes.
//
// No tiene estado propio: el reloj se lo inyecta el padre (`ahora`), igual
// que `TimeBadge`. Así todos los badges de la pantalla comparten una sola
// referencia temporal y no pueden discrepar entre sí.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/Local/entities/cart_session_entity.dart';
import '../../../data/Local/entities/estado_plato.dart';
import '../../../data/Local/entities/isar_service.dart';
import '../../providers/comanda_provider.dart';
import '../../providers/esc_pos_provider.dart';
import '../../providers/kds_ticket.dart';
import '../../services/ticket_cocina_service.dart';
import '../../utils/duracion_utils.dart';
import '../../widgets/common/glass_card.dart';
import '../../widgets/common/item_card.dart';
import '../../widgets/common/product_thumbnail.dart';
import '../../widgets/common/quantity_control.dart';
import '../../widgets/common/sticky_note.dart';
import '../../widgets/common/time_badge.dart';

/// Rojo de bloqueo. No sale de `TimeBadge` porque ahí es "urgencia", y
/// un plato pausado no está "`> 15 min`": está parado.
const _rojoPausa = Color(0xFFEF4444);
const _verdeListo = Color(0xFF10B981);
const _azulIniciar = Color(0xFF3B82F6);
const _ambarPausa = Color(0xFFF59E0B);

/// Un ticket del KDS: cabecera con mesa + antigüedad, y una `ItemCard` por
/// plato con los botones que apliquen a su estado.
class KdsTicketCard extends ConsumerWidget {
  final KdsTicket ticket;

  /// Reloj del frame. Lo pasa `KdsScreen`, que lo refresca cada 30 s.
  final DateTime ahora;

  const KdsTicketCard({
    super.key,
    required this.ticket,
    required this.ahora,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    // ⚠️ POR QUÉ SE FILTRA AQUÍ SI `ticketsEnCola` YA FILTRA
    //
    // `ComandasState.ticketsEnCola` (comanda_provider.dart:106) descarta
    // los items no visibles al construir el ticket, así que en producción
    // esta lista ya viene limpia. El filtro es una red de seguridad: la
    // tarjeta es un componente PÚBLICO y depende de una garantía que vive
    // dos archivos más allá. Si alguien la rompe, el fallo sería "el
    // cocinero ve platos ya entregados", que es de las cosas que más
    // confianza rompen en una cocina.
    //
    // ⚠️ Filtrar NO re-indexa. El índice real viaja dentro de cada
    // `KdsTicketItem` (`ti.itemIndex`), no por posición en la lista, así
    // que descartar un item intermedio no desplaza los siguientes. Es
    // justo el caso que cubre el test "el índice es el REAL".
    final visibles = ticket.items
        .where(
          (i) => IsarService.estadosVisiblesEnKds.contains(i.item.estadoPlato),
        )
        .toList();

    // Sin nada que pintar no hay tarjeta: se dibujaría una cabecera
    // colgando sobre cero platos.
    if (visibles.isEmpty) return const SizedBox.shrink();

    // Los minutos y los contadores se calculan sobre la lista FILTRADA,
    // no sobre `ticket.items`: si no, la cabecera diría "3 platos" con
    // uno solo dibujado, y el chip de pausados contaría los que no se ven.
    final minutos = DuracionUtils.minutosDesde(
      ticket.entradaEn,
      ahora: ahora,
    );
    final pausados = visibles.where((i) => i.item.pausado).length;

    return GlassCard(
      padding: const EdgeInsets.all(12),
      showStatusBar: true,
      statusColor: TimeBadge.colorPorMinutos(minutos),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cabecera(context, ref, colorScheme, visibles.length, pausados),
          const SizedBox(height: 10),
          for (var i = 0; i < visibles.length; i++) ...[
            _fila(context, ref, visibles[i]),
            if (i < visibles.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // CABECERA
  // ════════════════════════════════════════════════════════════════

  /// [total] y [pausados] los pasa [build] ya calculados sobre la lista
  /// de items VISIBLES, no sobre `ticket.items`.
  ///
  /// [context] y [ref] llegan como parámetros porque aquí van a hacer falta
  /// para los botones de reimprimir y PDF. No es una manía: en un
  /// `ConsumerWidget`, `context` solo existe como parámetro de [build], y
  /// este método privado no tiene otra forma de alcanzarlo.
  Widget _cabecera(
    BuildContext context,
    WidgetRef ref,
    ColorScheme cs,
    int total,
    int pausados,
  ) {
    final etiqueta = total == 1 ? '1 plato' : '$total platos';

    return Row(
      children: [
        Icon(
          Icons.table_restaurant_rounded,
          size: 18,
          color: cs.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ticket.mesaNombre,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                etiqueta,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (pausados > 0) ...[
          _chipPausas(cs, pausados),
          const SizedBox(width: 6),
        ],
        TimeBadge(desde: ticket.entradaEn, ahora: ahora, compact: true),
        const SizedBox(width: 2),
        IconButton(
          icon: const Icon(Icons.print_outlined, size: 20),
          tooltip: 'Reimprimir',
          onPressed: () => _reimprimir(context, ref),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
          tooltip: 'PDF',
          onPressed: () => _compartirPdf(context, ref),
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(4),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  // R.3.3 · IMPRESIÓN Y PDF
  // ════════════════════════════════════════════════════════════════

  /// Reimprime este ticket en la impresora térmica.
  ///
  /// Sin impresora configurada devuelve `false` y se avisa con el
  /// Snackbar rojo. No es un error: es que nadie ha configurado una.
  Future<void> _reimprimir(BuildContext context, WidgetRef ref) async {
    final impresora = ref.read(printerProvider)?.device;

    final ok = await TicketCocinaService.imprimirEnImpresora(
      ticket,
      impresora: impresora,
    );

    // El awaited puede cruzar un rebuild de la lista y el context quedar
    // colgando; sin esta guarda, `ScaffoldMessenger.of` revienta.
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Ticket enviado a la impresora' : 'No se pudo reimprimir',
        ),
        backgroundColor:
            ok ? const Color(0xFF10B981) : const Color(0xFFEF4444),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Genera el PDF y lo ofrece por el share sheet.
  ///
  /// ⚠️ Solo los items VISIBLES: el `ticket` que llega aquí es el que
  /// pinta la pantalla, pero el servicio vuelve a filtrar por estado, así
  /// que un plato ya entregado nunca sale en papel aunque el modelo lo
  /// conserve.
  Future<void> _compartirPdf(BuildContext context, WidgetRef ref) async {
    final ruta = await TicketCocinaService.generarPdf(ticket);

    if (!context.mounted) return;

    if (ruta == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo generar el PDF'),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    // El share lo abre `compartirPdf`, que muestra su propio Snackbar de
    // éxito: no se duplica aquí.
    await TicketCocinaService.compartirPdf(context, ruta);
  }

  /// "2 pausados". No es un botón: avisar de que el pedido está
  /// bloqueado es tan importante como el motivo, pero el motivo se lee
  /// en la fila.
  Widget _chipPausas(ColorScheme cs, int cantidad) {
    final texto =
        cantidad == 1 ? '1 pausado' : '$cantidad pausados';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: _rojoPausa.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _rojoPausa.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pause_circle_filled, size: 11, color: _rojoPausa),
          const SizedBox(width: 4),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _rojoPausa,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  // FILA DE PLATO
  // ════════════════════════════════════════════════════════════════

  Widget _fila(BuildContext context, WidgetRef ref, KdsTicketItem ti) {
    final item = ti.item;
    final minutos = DuracionUtils.minutosDesde(
      ti.entradaEn,
      ahora: ahora,
    );
    final pausado = item.pausado;
    final nota = (item.nota?.trim().isNotEmpty ?? false)
        ? StickyNote(texto: item.nota!.trim(), small: true)
        : null;

    return ItemCard(
      compact: true,
      thumbnail: ProductThumbnail(imageUrl: item.imagenUrl, size: 40),
      nombre: item.productoNombre,
      detalle: '${_cantidad(item)} x \$${item.precioUnidad.toStringAsFixed(2)}',
      badgeEstado: TimeBadge(
        desde: ti.entradaEn,
        ahora: ahora,
        compact: true,
        colorForzado: pausado ? _rojoPausa : null,
      ),
      nota: nota,
      // El cocinero NO edita cantidades: el plato ya está pedido. Se
      // pinta deshabilitado para que se lea el número sin insinuar que
      // se puede cambiar.
      cantidad: QuantityControl(
        cantidad: item.cantidad,
        esPesado: item.esPesado,
        habilitado: false,
      ),
      colorBorde:
          pausado ? _rojoPausa : TimeBadge.colorPorMinutos(minutos),
      trailing: _acciones(context, ref, ti),
    );
  }

  /// "2" o "1.250 kg". Nunca "2.0 x 3.50": el decimal solo cuando el
  /// producto se vende a peso.
  String _cantidad(CartSessionItem item) {
    if (item.esPesado) return '${item.cantidad.toStringAsFixed(3)} kg';
    return '${item.cantidad.round()}';
  }

  // ════════════════════════════════════════════════════════════════
  // BOTONES POR ESTADO
  // ════════════════════════════════════════════════════════════════

  /// `null` = este estado no tiene acción posible desde el KDS.
  ///
  /// Los estados sin acción son los que ni siquiera llegan aquí
  /// (`pendiente`, `entregado`, `cancelado` no están en
  /// `IsarService.estadosVisiblesEnKds`), pero el `switch` los cubre
  /// igual para que un estado nuevo no reviente la pantalla.
  Widget? _acciones(
    BuildContext context,
    WidgetRef ref,
    KdsTicketItem ti,
  ) {
    final item = ti.item;

    // El bloqueo gana al estado: un plato pausado que además esté
    // "listo" no se entrega hasta que alguien lo reanude.
    if (item.pausado) {
      return _boton(
        etiqueta: 'Reanudar',
        icono: Icons.play_arrow_rounded,
        color: _verdeListo,
        onTap: () => ref
            .read(comandasProvider.notifier)
            .reanudarItem(ti.comandaId, ti.itemIndex),
      );
    }

    final notifier = ref.read(comandasProvider.notifier);

    switch (item.estadoPlato) {
      case EstadoPlato.enCola:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _boton(
              etiqueta: 'Iniciar',
              icono: Icons.play_arrow_rounded,
              color: _azulIniciar,
              onTap: () =>
                  notifier.marcarEnPreparacion(ti.comandaId, ti.itemIndex),
            ),
            const SizedBox(width: 6),
            _boton(
              etiqueta: 'Pausar',
              icono: Icons.pause_rounded,
              color: _ambarPausa,
              onTap: () => _pausar(context, ref, ti),
            ),
          ],
        );

      case EstadoPlato.enPreparacion:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _boton(
              etiqueta: 'Listo',
              icono: Icons.check_rounded,
              color: _verdeListo,
              onTap: () => notifier.marcarListo(ti.comandaId, ti.itemIndex),
            ),
            const SizedBox(width: 6),
            _boton(
              etiqueta: 'Pausar',
              icono: Icons.pause_rounded,
              color: _ambarPausa,
              onTap: () => _pausar(context, ref, ti),
            ),
          ],
        );

      case EstadoPlato.listo:
        return _boton(
          etiqueta: 'Entregado',
          icono: Icons.send_rounded,
          color: _azulIniciar,
          onTap: () =>
              notifier.marcarEntregado(ti.comandaId, ti.itemIndex),
        );

      case EstadoPlato.pendiente:
      case EstadoPlato.entregado:
      case EstadoPlato.cancelado:
        return null;
    }
  }

  /// Abre el diálogo y, si vuelve con algo (incluido texto vacío), pausa.
  Future<void> _pausar(
    BuildContext context,
    WidgetRef ref,
    KdsTicketItem ti,
  ) async {
    final motivo = await _PausaItemDialog.mostrar(context);
    // `null` = canceló. No se pausa nada.
    if (motivo == null) return;
    await ref
        .read(comandasProvider.notifier)
        .pausarItem(ti.comandaId, ti.itemIndex, motivo);
  }

  // ════════════════════════════════════════════════════════════════
  // BOTÓN
  // ════════════════════════════════════════════════════════════════

  Widget _boton({
    required String etiqueta,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: etiqueta,
      child: Material(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icono, size: 16, color: color),
                const SizedBox(width: 5),
                Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// DIÁLOGO DE PAUSA
// ══════════════════════════════════════════════════════════════════

/// Pide el motivo de la pausa.
///
/// Devuelve `null` si el cocinero cancela; en ese caso NO se pausa nada.
/// Un motivo vacío es válido: se guarda como `null` y el plato aparece
/// pausado igual (pause sin explicación es información: "no preguntes,
/// ahora no").
class _PausaItemDialog extends StatefulWidget {
  static Future<String?> mostrar(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const _PausaItemDialog(),
    );
  }

  const _PausaItemDialog();

  @override
  State<_PausaItemDialog> createState() => _PausaItemDialogState();
}

class _PausaItemDialogState extends State<_PausaItemDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _aceptar() {
    // `normalizarMotivoPausa` es el que decide si queda `null`; aquí
    // solo se pasa el texto tal cual para no normalizar dos veces.
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final max = ComandasNotifier.maxCharsMotivoPausa;

    return AlertDialog(
      title: const Text('Pausar el plato'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opcional. Anota por qué para que el mesero pueda avisar.',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: max,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _aceptar(),
            decoration: const InputDecoration(
              hintText: 'Falta pescado, espera al comensal...',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: _ambarPausa),
          onPressed: _aceptar,
          child: const Text('Pausar'),
        ),
      ],
    );
  }
}
