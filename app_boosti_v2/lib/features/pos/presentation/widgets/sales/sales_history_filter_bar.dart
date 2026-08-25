import 'package:flutter/material.dart';

class SalesHistoryFilterBar extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;
  final bool isMobile;
  final bool isTablet;

  final List<String> mesesDropdown;
  final String mesSeleccionado;
  final List<int> aniosDisponibles;
  final int anioSeleccionado;
  final ValueChanged<String> onMesChanged;
  final ValueChanged<int> onAnioChanged;

  const SalesHistoryFilterBar({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.isMobile,
    required this.isTablet,
    required this.mesesDropdown,
    required this.mesSeleccionado,
    required this.aniosDisponibles,
    required this.anioSeleccionado,
    required this.onMesChanged,
    required this.onAnioChanged,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Botones de período
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _PeriodButton(
                key: const ValueKey('dia'),
                selected: selectedPeriod == 'dia',
                icon: Icons.today,
                label: 'Hoy',
                onTap: () => onPeriodChanged('dia'),
                isMobile: isMobile,
                isTablet: isTablet,
              ),
              const SizedBox(width: 8),
              _PeriodButton(
                key: const ValueKey('semana'),
                selected: selectedPeriod == 'semana',
                icon: Icons.date_range,
                label: 'Semana',
                onTap: () => onPeriodChanged('semana'),
                isMobile: isMobile,
                isTablet: isTablet,
              ),
              const SizedBox(width: 8),
              _PeriodButton(
                key: const ValueKey('mes'),
                selected: selectedPeriod == 'mes',
                icon: Icons.calendar_month,
                label: 'Mes',
                onTap: () => onPeriodChanged('mes'),
                isMobile: isMobile,
                isTablet: isTablet,
              ),
              const SizedBox(width: 8),
              _PeriodButton(
                key: const ValueKey('anio'),
                selected: selectedPeriod == 'anio',
                icon: Icons.calendar_today,
                label: 'Año',
                onTap: () => onPeriodChanged('anio'),
                isMobile: isMobile,
                isTablet: isTablet,
              ),
              const SizedBox(width: 8),
              _PeriodButton(
                key: const ValueKey('todos'),
                selected: selectedPeriod == 'todos',
                icon: Icons.all_inclusive,
                label: 'Todas',
                onTap: () => onPeriodChanged('todos'),
                isMobile: isMobile,
                isTablet: isTablet,
              ),
            ],
          ),
        ),

        // Selectores de mes/año (con transición)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: selectedPeriod == 'mes'
              ? _buildMonthYearSelectors(context)
              : selectedPeriod == 'anio'
                  ? _buildYearSelector(context)
                  : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }

  Widget _buildMonthYearSelectors(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      key: const ValueKey('month_year_selectors'),
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: isTablet ? 56 : 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.primary, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: mesSeleccionado,
                  icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary, size: isTablet ? 30 : 22),
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 14,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  items: mesesDropdown.map((mes) {
                    return DropdownMenuItem(
                      value: mes,
                      child: Text(
                        mes == 'Actual' ? 'Mes Actual' : mes,
                        style: TextStyle(fontSize: isTablet ? 16 : 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) onMesChanged(val);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: isTablet ? 56 : 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: colorScheme.primary, width: 1.5),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: anioSeleccionado,
                  icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary, size: isTablet ? 30 : 22),
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 14,
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  items: aniosDisponibles.map((anio) {
                    return DropdownMenuItem(
                      value: anio,
                      child: Text(
                        '$anio${anio == DateTime.now().year ? ' (Actual)' : ''}',
                        style: TextStyle(fontSize: isTablet ? 16 : 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) onAnioChanged(val);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      key: const ValueKey('year_selector'),
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        height: isTablet ? 56 : 42,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colorScheme.primary, width: 1.5),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: anioSeleccionado,
            icon: Icon(Icons.arrow_drop_down, color: colorScheme.primary, size: isTablet ? 30 : 22),
            style: TextStyle(
              fontSize: isTablet ? 18 : 14,
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            items: aniosDisponibles.map((anio) {
              return DropdownMenuItem(
                value: anio,
                child: Text(
                  '$anio${anio == DateTime.now().year ? ' (Actual)' : ''}',
                  style: TextStyle(fontSize: isTablet ? 16 : 13),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) onAnioChanged(val);
            },
          ),
        ),
      ),
    );
  }
}

// ✅ Widget separado para manejar su propio estado de hover
class _PeriodButton extends StatefulWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isMobile;
  final bool isTablet;

  const _PeriodButton({
    super.key,
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  State<_PeriodButton> createState() => _PeriodButtonState();
}

class _PeriodButtonState extends State<_PeriodButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final double fontSize = widget.isTablet ? 18 : 13;
    final double iconSize = widget.isTablet ? 24 : 16;
    final double verticalPadding = widget.isTablet ? 14 : 8;
    final double horizontalPadding = widget.isTablet ? 28 : 16;
    final double borderRadius = widget.isTablet ? 28 : 22;

    return MouseRegion(
      onEnter: (_) => setState(() => isHovering = true),
      onExit: (_) => setState(() => isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: isHovering
              ? Matrix4.diagonal3Values(1.05, 1.05, 1.0)
              : Matrix4.identity(),
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: horizontalPadding,
          ),
          decoration: BoxDecoration(
            color: widget.selected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: widget.selected
                  ? colorScheme.primary
                  : (isHovering
                      ? colorScheme.primary.withValues(alpha: 0.5)
                      : colorScheme.outline.withValues(alpha: 0.3)),
              width: widget.selected ? 2.0 : 1.5,
            ),
            boxShadow: widget.selected
                ? [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : (isHovering
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: iconSize,
                color: widget.selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                    color: widget.selected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}