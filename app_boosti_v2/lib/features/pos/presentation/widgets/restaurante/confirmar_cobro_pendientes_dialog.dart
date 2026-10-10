// lib/features/pos/presentation/widgets/restaurante/confirmar_cobro_pendientes_dialog.dart
//
// R.3.4 · Aviso de platos sin servir antes de cobrar.
//
// ⚠️ POR QUÉ UN ARCHIVO PROPIO Y NO INLINE EN LA PANTALLA
//
// Estaba dentro de `ComandaScreen._confirmarCobroConPendientes`, un
// método privado de un `ConsumerStatefulWidget`. Probarlo exigía montar la
// pantalla completa (con su `Timer.periodic`, su `addPostFrameCallback` y
// su I/O real contra Isar dentro del `FakeAsync` del test, que ya sabemos
// que se cuelga). Como widget aparte se prueba en un `MaterialApp` vacío.
//
// ⚠️ POR QUÉ USA `AlertDialog` Y NO `GlassDialog`
//
// A primera vista `common/glass_dialog.dart` sería lo del repo, pero los
// diálogos de confirmación de riesgo —cancelar comanda, cobrar con
// pendientes— usan `AlertDialog` plano a propósito: el fondo translúcido de
// `GlassDialog` compite con el texto en pantalla pequeña y con luz de
// cocina. `_cancelar` (comanda_screen.dart) y `_NotaItemDialog` hacen lo
// mismo. La coherencia está en ser LEGIBLE, no en usar el mismo container.
import 'package:flutter/material.dart';

/// Diálogo "¿cobrar igual?" con platos todavía en cocina.
///
/// Clase de puro servicio: no tiene estado, solo muestra y devuelve.
class ConfirmarCobroPendientesDialog {
  ConfirmarCobroPendientesDialog._();

  /// Muestra el diálogo.
  ///
  /// Devuelve `true` si el usuario elige [Cobrar igual], `false` si elige
  /// [Esperar] o cierra el diálogo con el botón atrás.
  ///
  /// ⚠️ Con [enCocina] y [listos] a 0 **no abre nada** y devuelve `true`
  /// directamente. Preguntar "¿cobrar igual?" sin nada que enseñar es un
  /// susto sin motivo, y la decisión de no preguntar tiene que vivir aquí
  /// y no en el caller: si se quedara en quien llama, el siguiente que use
  /// este diálogo se saltaría la guarda sin querer.
  static Future<bool> mostrar(
    BuildContext context, {
    required int enCocina,
    required int listos,
  }) async {
    if (enCocina <= 0 && listos <= 0) return true;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Hay platos pendientes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (enCocina > 0) ...[
              Text('· $enCocina plato${enCocina == 1 ? '' : 's'} '
                  'en cocina'),
              const SizedBox(height: 4),
            ],
            if (listos > 0)
              Text('· $listos listo${listos == 1 ? '' : 's'} '
                  'para servir'),
            const SizedBox(height: 12),
            const Text('¿Cobrar igual?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Esperar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cobrar igual'),
          ),
        ],
      ),
    );

    // `null` = cerrado con el botón atrás. Es una decisión consciente
    // tratarlo como "no cobrar": ante la duda, no cobrar.
    return confirm == true;
  }
}
