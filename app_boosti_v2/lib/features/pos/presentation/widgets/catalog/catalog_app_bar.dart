// lib/features/pos/presentation/widgets/catalog/catalog_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/bcv_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../screens/inventory_screen.dart';
import '../../screens/pos_menu_screen.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../utils/panel_utils.dart';
import '../../controllers/bcv_controller.dart';
import '../../utils/top_product_utils.dart'; // ✅ Import para abrir productos destacados

class CatalogAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final UsuarioEntity? usuarioLogueado;

  const CatalogAppBar({super.key, this.usuarioLogueado});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final bcvState = ref.watch(bcvProvider);
    final lowStockCount = ref.read(catalogProvider.notifier).lowStockCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final LinearGradient gradient;
    if (isDark) {
      gradient = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF10B981), Color(0xFF059669)],
      );
    } else {
      gradient = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [Color(0xFF5352ED), Color(0xFF4840E8), Color(0xFF5955EE)],
      );
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: gradient),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      title: Text(
        isMobile ? '' : 'Catálogo',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: isTablet ? 22 : 18,
          color: Colors.white,
        ),
      ),
      // 🔥 LEADING: solo el botón de Productos Destacados (sin ícono de tienda)
      leading: _buildActionButton(
        context,
        icon: Icons.whatshot_rounded, // ✅ Ícono más visible (fuego)
        tooltip: 'Productos destacados',
        onPressed: () => showTopProducts(context),
        isTablet: isTablet,
      ),
      actions: [
        // Botón del panel lateral
        _buildActionButton(
          context,
          icon: Icons.menu_rounded,
          tooltip: 'Panel rápido',
          onPressed: () => showSidePanel(context),
          isTablet: isTablet,
        ),
        const SizedBox(width: 6),

        // Botón de Panel de Control POS
        _buildActionButton(
          context,
          icon: Icons.grid_view_rounded,
          tooltip: 'Panel de Control POS',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PosMenuScreen()),
          ),
          isTablet: isTablet,
        ),
        const SizedBox(width: 6),

        // Botón de inventario
        Tooltip(
          message: 'Ir a Gestión de Inventario',
          child: _InventoryBadge(
            lowStockCount: lowStockCount,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => InventoryScreen(
                  usuarioLogueado: usuarioLogueado!,
                  showAppBar: true,
                ),
              ),
            ),
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 4),

        // Badge BCV
        Tooltip(
          message: 'Tasa oficial BCV (Haz clic para actualizar)',
          child: _BcvBadge(
            bcvState: bcvState,
            onTap: () => ref.read(bcvProvider).actualizarTasa(),
            isTablet: isTablet,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // Widget reutilizable para botones de acción del AppBar
  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    final size = isTablet ? 48.0 : 40.0;
    final iconSize = isTablet ? 26.0 : 22.0;

    bool isHovered = false;

    return Tooltip(
      message: tooltip,
      child: StatefulBuilder(
        builder: (context, setState) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isHovered ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: Icon(icon, color: Colors.white, size: iconSize),
                onPressed: onPressed,
                padding: EdgeInsets.zero,
                splashRadius: isTablet ? 28 : 22,
                mouseCursor: SystemMouseCursors.click,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Widget para el badge de inventario (sin cambios)
class _InventoryBadge extends StatelessWidget {
  final int lowStockCount;
  final VoidCallback onPressed;
  final bool isTablet;

  const _InventoryBadge({
    required this.lowStockCount,
    required this.onPressed,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    bool isHovered = false;
    final size = isTablet ? 48.0 : 40.0;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: isHovered ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.inventory_2_outlined, color: Colors.white),
                  onPressed: onPressed,
                  padding: EdgeInsets.zero,
                  splashRadius: isTablet ? 28 : 22,
                  mouseCursor: SystemMouseCursors.click,
                ),
              ),
              if (lowStockCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF97316),
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$lowStockCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Widget para el badge de BCV (sin cambios)
class _BcvBadge extends StatelessWidget {
  final BcvController bcvState;
  final VoidCallback onTap;
  final bool isTablet;

  const _BcvBadge({
    required this.bcvState,
    required this.onTap,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: isTablet ? 8 : 6,
              ),
              margin: const EdgeInsets.only(left: 4, right: 8),
              decoration: BoxDecoration(
                color: isHovered
                    ? Colors.white.withValues(alpha: 0.1)
                    : (bcvState.cargando ? Colors.white.withValues(alpha: 0.15) : Colors.transparent),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: bcvState.cargando
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.8),
                  width: 1.5,
                ),
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: bcvState.cargando
                      ? SizedBox(
                          key: const ValueKey('loading'),
                          width: isTablet ? 18 : 14,
                          height: isTablet ? 18 : 14,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          key: const ValueKey('loaded'),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.currency_exchange,
                              size: isTablet ? 20 : 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'BCV: Bs. ${bcvState.tasa.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 15 : 13,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}