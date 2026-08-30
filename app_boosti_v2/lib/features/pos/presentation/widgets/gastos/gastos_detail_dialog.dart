import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/Local/entities/gasto_entity.dart';
import '../../providers/bcv_provider.dart';

class GastosDetailDialog extends ConsumerWidget {
  final String title;
  final List<GastoEntity> gastos;
  final Color color;

  const GastosDetailDialog({
    super.key,
    required this.title,
    required this.gastos,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    if (gastos.length == 1) {
      return _buildSingleDetail(context, ref, colorScheme);
    }

    return _buildListDialog(context, ref, colorScheme);
  }

  // 🎯 Diálogo para un solo gasto
  Widget _buildSingleDetail(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    final gasto = gastos.first;
    final fechaLocal = gasto.fecha.toLocal();
    final fechaStr =
        '${fechaLocal.day}/${fechaLocal.month}/${fechaLocal.year} ${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';
    // ignore: unused_local_variable
    final montoUSD = gasto.moneda == 'USD' ? gasto.monto : 0.0;
    final montoBs = gasto.moneda == 'Bs' ? gasto.monto : 0.0;

    // Calcular conversión a Bs. si es USD
    double montoEnBs = montoBs;
    if (gasto.moneda == 'USD') {
      // Usar la tasa guardada en el gasto, o la tasa actual
      final tasaBcv = gasto.tasaBcv ?? ref.read(bcvProvider).tasa;
      montoEnBs = gasto.monto * tasaBcv;
    }

    // Icono de categoría
    IconData categoryIcon;
    switch (gasto.categoria.toLowerCase()) {
      case 'alimentación':
        categoryIcon = Icons.restaurant_rounded;
        break;
      case 'transporte':
        categoryIcon = Icons.directions_car_rounded;
        break;
      case 'servicios':
        categoryIcon = Icons.construction_rounded;
        break;
      default:
        categoryIcon = Icons.category_rounded;
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: BoxConstraints(
          maxWidth: 400,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Título
              Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Icono grande de categoría
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  categoryIcon,
                  color: color,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),

              // Categoría
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Text(
                  gasto.categoria,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Descripción
              Text(
                gasto.descripcion,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),

              // Monto en USD
              if (gasto.moneda == 'USD') ...[
                Text(
                  '\$${gasto.monto.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  'USD',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                // Equivalente en Bs.
                Text(
                  '≈ Bs. ${montoEnBs.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else ...[
                // Si es Bs.
                Text(
                  'Bs. ${gasto.monto.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  'Bolívares',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Fecha y usuario
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          fechaStr,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    if (gasto.usuarioNombre.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, size: 16, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            'Registrado por: ${gasto.usuarioNombre}',
                            style: TextStyle(
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📋 Diálogo para lista de gastos (varios)
  Widget _buildListDialog(BuildContext context, WidgetRef ref, ColorScheme colorScheme) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: colorScheme.surface,
      title: Row(
        children: [
          Icon(Icons.receipt_long_rounded, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: gastos.length,
          separatorBuilder: (context, index) => Divider(
            color: colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),
          itemBuilder: (context, index) {
            final g = gastos[index];
            final fechaLocal = g.fecha.toLocal();
            final fechaStr =
                '${fechaLocal.day}/${fechaLocal.month}/${fechaLocal.year} ${fechaLocal.hour.toString().padLeft(2, '0')}:${fechaLocal.minute.toString().padLeft(2, '0')}';

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(
                  Icons.money_off_rounded,
                  color: color,
                  size: 20,
                ),
              ),
              title: Text(
                g.descripcion,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${g.moneda == 'USD' ? '\$' : 'Bs. '}${g.monto.toStringAsFixed(2)} • $fechaStr',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  g.categoria,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}