// lib/features/pos/presentation/widgets/empleado/employees_toolbar.dart
import 'package:flutter/material.dart';

import '../../screens/empleados/employees_enums.dart';
import '../../utils/responsive_helper.dart';
import '../common/filtro_chip_template.dart';
import '../common/segmented_toggle.dart';
import 'empleado_card.dart' show kCardBorder;

/// Toolbar completa de la pantalla de empleados:
/// filtros de estado + dropdown dpto + dropdown orden + agrupar + vista.
class EmployeesToolbar extends StatelessWidget {
  final List<String> departamentos;

  final EmployeeFilter filter;
  final EmployeeSort sort;
  final EmployeeView view;
  final String? departamentoFiltro;
  final bool agruparPorDepartamento;

  final ValueChanged<EmployeeFilter> onFilterChanged;
  final ValueChanged<EmployeeSort> onSortChanged;
  final ValueChanged<EmployeeView> onViewChanged;
  final ValueChanged<String?> onDepartamentoChanged;
  final ValueChanged<bool> onAgruparChanged;

  /// Devuelve el conteo de usuarios que matchean el filtro.
  final int Function(EmployeeFilter) contarPorFiltro;

  const EmployeesToolbar({
    super.key,
    required this.departamentos,
    required this.filter,
    required this.sort,
    required this.view,
    required this.departamentoFiltro,
    required this.agruparPorDepartamento,
    required this.onFilterChanged,
    required this.onSortChanged,
    required this.onViewChanged,
    required this.onDepartamentoChanged,
    required this.onAgruparChanged,
    required this.contarPorFiltro,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFiltros(),
        const SizedBox(height: 10),
        _buildDropdowns(context),
        const SizedBox(height: 10),
        _buildBottomRow(context, isMobile),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FILTROS DE ESTADO
  // ═══════════════════════════════════════════════════════════

  Widget _buildFiltros() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          for (final f in EmployeeFilter.values) ...[
            FiltroChip(
              label: f.label,
              icon: f.icon,
              color: f.color,
              selected: filter == f,
              size: FiltroChipSize.small,
              count: contarPorFiltro(f),
              onTap: () => onFilterChanged(f),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DROPDOWNS
  // ═══════════════════════════════════════════════════════════

  Widget _buildDropdowns(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildDepartamentoDropdown(context)),
        const SizedBox(width: 8),
        Expanded(child: _buildOrdenDropdown(context)),
      ],
    );
  }

  Widget _buildDepartamentoDropdown(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  final valor = departamentoFiltro;

  return _dropdownContainer(
    context,
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String?>(
        value: valor,
        isExpanded: true,
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: colorScheme.onSurfaceVariant,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        borderRadius: BorderRadius.circular(12),
        // Texto del botón cerrado
        hint: _dropdownLabel('Departamento', Icons.apartment_rounded),
        // 🎯 NO usamos selectedItemBuilder.
        //    En su lugar, permitimos que `DropdownButton` renderice el
        //    item seleccionado directamente (es la opción más estable).
        items: [
          DropdownMenuItem<String?>(
            value: null,
            child: _dropdownItem(
              'Todos los departamentos',
              Icons.all_inclusive_rounded,
              colorScheme.onSurfaceVariant,
            ),
          ),
          ...departamentos.map(
            (d) => DropdownMenuItem<String?>(
              value: d,
              child: _dropdownItem(
                d,
                Icons.apartment_rounded,
                const Color(0xFF3B82F6),
              ),
            ),
          ),
          DropdownMenuItem<String?>(
            value: '__none__',
            child: _dropdownItem(
              'Sin departamento',
              Icons.remove_circle_outline_rounded,
              colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        onChanged: onDepartamentoChanged,
      ),
    ),
  );
}

  Widget _buildOrdenDropdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return _dropdownContainer(
      context,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<EmployeeSort>(
          value: sort,
          isExpanded: true,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: colorScheme.onSurfaceVariant,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          borderRadius: BorderRadius.circular(12),
          items: EmployeeSort.values
              .map(
                (s) => DropdownMenuItem<EmployeeSort>(
                  value: s,
                  child: _dropdownItem(
                    s.label,
                    s.icon,
                    const Color(0xFF8B5CF6),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onSortChanged(v);
          },
        ),
      ),
    );
  }

  Widget _dropdownContainer(BuildContext context, {required Widget child}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // Verde del design system en vez de `outlineVariant` (gris
          // casi negro en tema claro). Mismo criterio que
          // `kCardBorder` en `empleado_card.dart`.
          color: kCardBorder.withValues(alpha: 0.3),
        ),
      ),
      child: child,
    );
  }

  Widget _dropdownItem(String text, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _dropdownLabel(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF3B82F6)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════
  // AGRUPAR + VISTA
  // ═══════════════════════════════════════════════════════════

  Widget _buildBottomRow(BuildContext context, bool isMobile) {
    return Row(
      children: [
        _buildAgruparToggle(context),
        const Spacer(),
        SegmentedToggle<EmployeeView>(
          selected: view,
          accentColor: const Color(0xFF8B5CF6),
          compact: isMobile,
          onChanged: onViewChanged,
          // Borde verde para acompañar las cards de abajo en vez del
          // gris `Colors.grey.shade300` por defecto.
          borderColor: kCardBorder.withValues(alpha: 0.3),
          items: const [
            SegmentedToggleItem(
              value: EmployeeView.detailed,
              label: 'Detallada',
              icon: Icons.grid_view_rounded,
            ),
            SegmentedToggleItem(
              value: EmployeeView.compact,
              label: 'Compacta',
              icon: Icons.grid_on_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAgruparToggle(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activo = agruparPorDepartamento;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onAgruparChanged(!activo),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: activo
                ? const Color(0xFF10B981).withValues(alpha: 0.15)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: activo
                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                  : kCardBorder.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                activo
                    ? Icons.check_box_rounded
                    : Icons.check_box_outline_blank_rounded,
                size: 16,
                color: activo
                    ? const Color(0xFF10B981)
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                'Agrupar por Dpto',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: activo
                      ? const Color(0xFF10B981)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}