// lib/features/pos/presentation/widgets/catalog/catalog_app_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:flutter_svg/flutter_svg.dart'; // ✅ Agregar import
import '../../providers/bcv_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../screens/inventory_screen.dart';
import '../../screens/pos_menu_screen.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import 'top_products_utils.dart';

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

    // ✅ Degradados según modo
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

    final bcvBackgroundColor = Colors.transparent;
    final bcvBorderColor = Colors.white;
    final bcvTextColor = Colors.white;
    final bcvIconColor = Colors.white;

    // Variables de estado para el hover
    bool isInventoryHovered = false;
    bool isBcvHovered = false;

    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: gradient,
        ),
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
      // 🔥 LOGO SVG EN BLANCO (reemplaza Image.asset)
      leadingWidth: isTablet ? 104 : 96,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            context,
            icon: Icons.trending_up_rounded,
            tooltip: 'Productos destacados',
            onPressed: () => showTopProducts(context),
            isTablet: isTablet,
          ),
          const SizedBox(width: 4),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Icon(
              Icons.storefront,
              color: Colors.white,
              size: isTablet ? 36 : 32,
            ),
          ),
        ],
      ),
      actions: [
        // Panel de Control
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
          child: StatefulBuilder(
            builder: (context, setState) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => isInventoryHovered = true),
                onExit: (_) => setState(() => isInventoryHovered = false),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isTablet ? 48 : 40,
                      height: isTablet ? 48 : 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: isInventoryHovered ? 0.15 : 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.inventory_2_outlined, color: Colors.white),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InventoryScreen(
                              usuarioLogueado: usuarioLogueado!,
                              showAppBar: true,
                            ),
                          ),
                        ),
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
          ),
        ),
        const SizedBox(width: 4),

        // Badge BCV
        Tooltip(
          message: 'Tasa oficial BCV (Haz clic para actualizar)',
          child: StatefulBuilder(
            builder: (context, setState) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                onEnter: (_) => setState(() => isBcvHovered = true),
                onExit: (_) => setState(() => isBcvHovered = false),
                child: GestureDetector(
                  onTap: () => ref.read(bcvProvider).actualizarTasa(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 16 : 12,
                      vertical: isTablet ? 8 : 6,
                    ),
                    margin: const EdgeInsets.only(left: 4, right: 8),
                    decoration: BoxDecoration(
                      color: isBcvHovered 
                          ? Colors.white.withValues(alpha: 0.1) 
                          : (bcvState.cargando ? Colors.white.withValues(alpha: 0.15) : bcvBackgroundColor),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: bcvState.cargando
                            ? Colors.white.withValues(alpha: 0.3)
                            : bcvBorderColor.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
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
                                    color: bcvIconColor,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'BCV: Bs. ${bcvState.tasa.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: isTablet ? 15 : 13,
                                      color: bcvTextColor,
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
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
    required bool isTablet,
  }) {
    final size = isTablet ? 48.0 : 40.0;
    final iconSize = isTablet ? 26.0 : 22.0;
    
    bool isActionHovered = false;

    return Tooltip(
      message: tooltip,
      child: StatefulBuilder(
        builder: (context, setState) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => isActionHovered = true),
            onExit: (_) => setState(() => isActionHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isActionHovered ? 0.15 : 0.08),
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