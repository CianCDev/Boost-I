// lib/features/pos/presentation/widgets/restaurante/propina_mesero_dialog.dart
//
// R.4 · Propina voluntaria + mesero, justo antes de cobrar una mesa.
//
// ⚠️ POR QUÉ ESTE DIÁLOGO EXISTE
//
// La propina no se decide al abrir la mesa, sino al cobrarla. Por eso no
// vive en la comanda: viaja como parámetro del cobro y termina en la venta.
//
// ⚠️ POR QUÉ NO TOCA NINGUNA ENTIDAD
//
// `DetalleVentaEntity.productoId` es nullable (`detalle_ventas.producto_id`
// es `bigint` sin NOT NULL en el baseline), así que la propina entra como
// una línea "Propina" más. El mesero se guarda en `VentaEntity.empleado`,
// que ya existe y ya se sincroniza como `empleado_nombre`. Cero cambios de
// esquema, local o remoto.
//
// ⚠️ CONSECUENCIA ACEPTADA
//
// `VentaEntity.total` incluye la propina, así que "ventas del día" y
// "productos más vendidos" la suman. El IVA queda correcto porque los
// reportes usan `venta.impuesto`, no `total - subtotal`.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:app_boosti_v2/features/pos/data/Local/entities/usuario_entity.dart';
import '../common/dialog_header.dart';
import '../common/glass_dialog.dart';

/// Lo que devuelve [PropinaMeseroDialog] al confirmar.
///
/// `null` (el diálogo se cerró) significa "no cobrar": el caller debe
/// abortar el cobro entero, no cobrar sin propina.
class ResultadoPropina {
  /// Monto en USD. Puede ser 0: el cliente decide no dejar propina.
  final double propina;

  /// Empleado que atendió la mesa. Nunca vacío: es obligatorio.
  final String meseroNombre;

  const ResultadoPropina({
    required this.propina,
    required this.meseroNombre,
  });
}

/// Pregunta por la propina y por el mesero antes de abrir `CobrarDialog`.
///
/// El caller ([CatalogActions.mostrarModalCobro]) solo lo abre cuando el
/// local es de restaurante, la venta viene de una comanda y hay al menos
/// un empleado habilitado. Sin empleados se omite el paso completo: pedir
/// un mesero que no existe dejaría la mesa sin poder cobrarse.
class PropinaMeseroDialog extends StatefulWidget {
  /// Total del consumo (con IVA), sin propina.
  final double totalConsumo;

  /// Empleados habilitados del local. Nunca vacío (ver el caller).
  final List<UsuarioEntity> meseros;

  const PropinaMeseroDialog({
    super.key,
    required this.totalConsumo,
    required this.meseros,
  });

  @override
  State<PropinaMeseroDialog> createState() => _PropinaMeseroDialogState();
}

class _PropinaMeseroDialogState extends State<PropinaMeseroDialog> {
  /// Porcentaje elegido con los chips. `null` = monto escrito a mano.
  /// `0` = "Sin propina" (el chip por defecto).
  int? _porcentaje = 0;

  double _propina = 0.0;

  int? _meseroId;

  final _montoController = TextEditingController();

  static const _porcentajes = [0, 5, 10, 15];

  @override
  void dispose() {
    _montoController.dispose();
    super.dispose();
  }

  double get _totalACobrar =>
      _redondearDosDecimales(widget.totalConsumo + _propina);

  /// Marca un chip de porcentaje y refleja el monto en el campo de texto.
  ///
  /// `0 %` limpia el campo en vez de escribir "0.00": un cero escrito a
  /// mano se lee como "no se pudo calcular", y aquí es una decisión.
  void _aplicarPorcentaje(int porcentaje) {
    setState(() {
      _porcentaje = porcentaje;
      _propina = porcentaje == 0
          ? 0.0
          : _redondearDosDecimales(widget.totalConsumo * porcentaje / 100);
      _montoController.text =
          porcentaje == 0 ? '' : _propina.toStringAsFixed(2);
    });
  }

  /// Monto libre. Deselecciona los chips porque el valor ya no es suyo.
  void _aplicarMontoLibre(String texto) {
    final limpio = texto.trim().replaceAll(',', '.');
    final monto = double.tryParse(limpio) ?? 0.0;
    setState(() {
      _porcentaje = null;
      _propina = monto.isFinite && monto > 0
          ? _redondearDosDecimales(monto)
          : 0.0;
    });
  }

  void _confirmar() {
    final mesero = widget.meseros.firstWhere((u) => u.id == _meseroId);
    Navigator.of(context).pop(
      ResultadoPropina(
        propina: _propina,
        meseroNombre: mesero.nombre,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorTexto = isDark ? Colors.white : const Color(0xFF111827);
    final colorSecundario = isDark ? Colors.white60 : Colors.black54;
    final puedeConfirmar = _meseroId != null;

    return GlassDialog(
      maxWidth: 520,
      accentColor: const Color(0xFF14B8A6),
      // En landscape de teléfono la altura útil baja a ~320 dp: sin scroll
      // el campo de monto o el selector de mesero quedarían fuera.
      scrollable: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DialogHeader(
              icon: Icons.volunteer_activism_rounded,
              title: 'Propina y mesero',
              subtitle:
                  'Consumo: \$${widget.totalConsumo.toStringAsFixed(2)}',
              color: const Color(0xFF14B8A6),
            ),
            const SizedBox(height: 20),

            // ── Propina ──────────────────────────────────────────────
            Text(
              '¿Dejan propina?',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorTexto,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _porcentajes.map((pct) {
                final seleccionado = _porcentaje == pct;
                return ChoiceChip(
                  label: Text(pct == 0 ? 'Sin propina' : '$pct %'),
                  selected: seleccionado,
                  onSelected: (_) => _aplicarPorcentaje(pct),
                  selectedColor: const Color(0xFF14B8A6).withValues(
                    alpha: isDark ? 0.28 : 0.18,
                  ),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        seleccionado ? FontWeight.bold : FontWeight.w500,
                    color: seleccionado ? colorTexto : colorSecundario,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _montoController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              onChanged: _aplicarMontoLibre,
              style: TextStyle(fontSize: 15, color: colorTexto),
              decoration: InputDecoration(
                labelText: 'Monto de propina',
                hintText: '0.00',
                prefixText: '\$ ',
                prefixStyle: TextStyle(color: colorSecundario),
                helperText: 'Opcional. La propina no paga IVA.',
                helperStyle: TextStyle(fontSize: 11, color: colorSecundario),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Total en vivo ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF14B8A6).withValues(
                  alpha: isDark ? 0.16 : 0.10,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF14B8A6).withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total a cobrar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: colorSecundario,
                          ),
                        ),
                        if (_propina > 0)
                          Text(
                            'Incluye \$${_propina.toStringAsFixed(2)} '
                            'de propina',
                            style: TextStyle(
                              fontSize: 11,
                              color: colorSecundario,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${_totalACobrar.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: colorTexto,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // ── Mesero ───────────────────────────────────────────────
            Text(
              'Mesero que atendió la mesa',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: colorTexto,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _meseroId,
              isExpanded: true,
              decoration: InputDecoration(
                hintText: 'Elegir mesero (obligatorio)',
                prefixIcon: Icon(
                  Icons.person_outline_rounded,
                  color: colorSecundario,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: widget.meseros
                  .map(
                    (u) => DropdownMenuItem<int>(
                      value: u.id,
                      child: Text(
                        '${u.nombre} · ${u.rol}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) => setState(() => _meseroId = id),
            ),
            const SizedBox(height: 22),

            // ── Acciones ─────────────────────────────────────────────
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: puedeConfirmar ? _confirmar : null,
                  icon: const Icon(Icons.point_of_sale_rounded, size: 18),
                  label: const Text('Continuar al cobro'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

double _redondearDosDecimales(double valor) =>
    (valor * 100).roundToDouble() / 100;
