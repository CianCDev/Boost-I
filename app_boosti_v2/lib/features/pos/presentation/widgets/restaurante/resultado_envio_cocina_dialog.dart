// lib/features/pos/presentation/widgets/restaurante/resultado_envio_cocina_dialog.dart
//
// Resultado del envío a cocina, como DIÁLOGO y no como SnackBar.
//
// El SnackBar naranja que había antes tapaba justo la barra de Total /
// Enviar / Cobrar, y desaparecía en 4 segundos: si el mesero estaba
// mirando la mesa, no leía nada. Peor aún, un envío de 6 platos y uno de 1
// decían lo mismo ("1 plato(s) enviado(s)") porque el texto se armaba con
// `enviados.length`, que es el número de ITEMS ENTRADOS A LA COLA en ese
// envío, no los platos de la comanda.
//
// Aquí el diálogo:
//   · lista los platos que salieron, con cantidad y estación,
//   · no se cierra solo (el mesero decide cuándo siguió),
//   · usa `AlertDialog` plano, igual que el resto de diálogos de riesgo
//     de esta pantalla (`_cancelar`, `ConfirmarCobroPendientesDialog`):
//     el vidrio de `GlassDialog` compite con el texto bajo luz de cocina.
import 'package:flutter/material.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/cart_session_entity.dart';

/// Diálogo de resultado de `ComandasNotifier.enviarACocina`.
///
/// Clase de puro servicio: no tiene estado, solo muestra.
class ResultadoEnvioCocinaDialog {
  ResultadoEnvioCocinaDialog._();

  static const _verde = Color(0xFF10B981);
  static const _rojo = Color(0xFFEF4444);

  /// Éxito: al menos un plato entró a la cola.
  ///
  /// [mesa] es el nombre visible ("Privado 1"). [platos] son los items que
  /// devolvió el provider (los que pasaron de `pendiente` a `enCola` en
  /// este envío), NO la comanda completa.
  static Future<void> mostrarExito(
    BuildContext context, {
    required String mesa,
    required List<CartSessionItem> platos,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) {
        final totalPlatos = platos.length;
        final totalUnidades = platos.fold<double>(
          0,
          (suma, p) => suma + p.cantidad,
        );

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: _verde),
              SizedBox(width: 8),
              Expanded(child: Text('Enviado a cocina')),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _resumen(mesa, totalPlatos, totalUnidades),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 260),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: platos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemBuilder: (_, i) {
                        final plato = platos[i];
                        final estacion = plato.estacionNombre;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 34,
                              child: Text(
                                _cantidad(plato.cantidad),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(plato.productoNombre),
                                  if (estacion != null && estacion.isNotEmpty)
                                    Text(
                                      estacion,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(ctx)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _verde),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
  }

  /// Error: no se envió nada. Se muestra el motivo tal cual lo dejó el
  /// provider (ya está en español y describe la causa concreta).
  static Future<void> mostrarError(
    BuildContext context, {
    required String mensaje,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.error_outline_rounded, color: _rojo),
            SizedBox(width: 8),
            Expanded(child: Text('No se envió a cocina')),
          ],
        ),
        content: Text(mensaje, style: const TextStyle(height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  static String _resumen(String mesa, int platos, double unidades) {
    final esUno = platos == 1 && unidades == 1;
    if (esUno) return '1 plato de $mesa salió a cocina.';
    return '$platos platos de $mesa salieron a cocina '
        '(${_cantidad(unidades)} en total).';
  }

  /// 1.000 kg se ve distinto de 1 unidad: redondear esconde la diferencia
  /// entre un plato pesado y uno contado.
  static String _cantidad(double valor) {
    if (valor == valor.roundToDouble()) return valor.toInt().toString();
    return valor.toStringAsFixed(3);
  }
}
