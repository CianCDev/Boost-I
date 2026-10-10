import 'package:flutter/material.dart';

import '../../../pos/presentation/widgets/common/card_action_button.dart';
import '../../../pos/presentation/widgets/common/glass_card.dart';
import '../../../pos/presentation/widgets/common/status_badge.dart';
import '../../data/models/plan.dart';

/// Tarjeta de un plan comercial en la pantalla de gestión.
///
/// Presenta precio, límites y modos habilitados, más las acciones de
/// editar / activar / eliminar. No conoce providers: recibe callbacks.
class PlanCard extends StatelessWidget {
  final Plan plan;
  final VoidCallback? onEditar;
  final VoidCallback? onToggleActivo;
  final VoidCallback? onEliminar;

  /// `true` mientras la operación de la card está en curso: se muestran
  /// spinners en vez de los botones para evitar dobles toques.
  final bool cargando;

  const PlanCard({
    super.key,
    required this.plan,
    this.onEditar,
    this.onToggleActivo,
    this.onEliminar,
    this.cargando = false,
  });

  // Paleta de docs/business_rules.md.
  static const Color _verde = Color(0xFF10B981);
  static const Color _rojo = Color(0xFFEF4444);
  static const Color _violeta = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Inactivo no usa gris hardcodeado: el color neutro del tema.
    final colorAcento = plan.activo ? _verde : colorScheme.onSurfaceVariant;

    return GlassCard(
      margin: EdgeInsets.zero,
      showStatusBar: true,
      statusColor: colorAcento,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Identidad ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            plan.nombre,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: plan.activo ? 'Activo' : 'Inactivo',
                          color: colorAcento,
                          size: StatusBadgeSize.small,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plan.id,
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if ((plan.descripcion ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        plan.descripcion!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              // ── Precios ──
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    plan.precioMensualFormateado,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _violeta,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'o ${plan.precioAnualFormateado}/año',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          // ── Límites ──
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: [
              _limite(
                Icons.store_rounded,
                'Locales: '
                    '${plan.esIlimitadoEnLocales ? '∞' : plan.maxLocales}',
                colorScheme,
              ),
              _limite(
                Icons.people_rounded,
                'Usuarios: '
                    '${plan.esIlimitadoEnUsuarios ? '∞' : plan.maxUsuarios}',
                colorScheme,
              ),
            ],
          ),
          // ── Modos habilitados ──
          if (plan.modosHabilitados.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final modo in plan.modosHabilitados) _chipModo(modo),
              ],
            ),
          ],
          // ── Acciones ──
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (cargando)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else ...[
                CardActionButton(
                  icon: Icons.edit_rounded,
                  color: _violeta,
                  tooltip: 'Editar plan',
                  onPressed: onEditar ?? () {},
                ),
                CardActionButton(
                  icon: plan.activo
                      ? Icons.toggle_on_rounded
                      : Icons.toggle_off_rounded,
                  color: plan.activo ? _verde : colorAcento,
                  tooltip: plan.activo ? 'Desactivar' : 'Activar',
                  onPressed: onToggleActivo ?? () {},
                ),
                CardActionButton(
                  icon: Icons.delete_rounded,
                  color: _rojo,
                  tooltip: 'Eliminar plan',
                  onPressed: onEliminar ?? () {},
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _limite(IconData icon, String texto, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 5),
        Text(
          texto,
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _chipModo(String modo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _violeta.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _violeta.withValues(alpha: 0.3)),
      ),
      child: Text(
        modo,
        style: const TextStyle(fontSize: 10, color: _violeta),
      ),
    );
  }
}
