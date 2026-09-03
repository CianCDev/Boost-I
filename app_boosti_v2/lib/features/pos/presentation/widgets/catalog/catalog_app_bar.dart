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
import '../../utils/top_product_utils.dart';
import 'search_bar.dart';
import '../../controllers/bcv_controller.dart';

class CatalogAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final UsuarioEntity? usuarioLogueado;
  final VoidCallback? onScanPressed;
  final FocusNode? searchFocusNode;

  const CatalogAppBar({
    super.key,
    this.usuarioLogueado,
    this.onScanPressed,
    this.searchFocusNode,
  });

  static final FocusNode _defaultFocusNode = FocusNode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final isMobile = ResponsiveHelper.isMobile(context);
    final bcvState = ref.watch(bcvProvider);
    final lowStockCount = ref.read(catalogProvider.notifier).lowStockCount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradient = isDark
        ? const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF10B981), Color(0xFF059669)],
          )
        : const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF5352ED), Color(0xFF4840E8), Color(0xFF5955EE)],
          );

    Widget buildActionButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback onPressed,
    }) {
      final btnSize = isMobile ? 36.0 : (isTablet ? 44.0 : 40.0);
      final iSize = isMobile ? 20.0 : (isTablet ? 24.0 : 20.0);

      return Tooltip(
        message: tooltip,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: StatefulBuilder(
            builder: (context, setState) {
              // ignore: unused_local_variable
              bool hover = false;
              return MouseRegion(
                onEnter: (_) => setState(() => hover = true),
                onExit: (_) => setState(() => hover = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: btnSize,
                  height: btnSize,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: Icon(icon, color: Colors.white, size: iSize),
                    onPressed: onPressed,
                    padding: EdgeInsets.zero,
                    splashRadius: btnSize * 0.6,
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    final focusNode = searchFocusNode ?? _defaultFocusNode;
    Widget safeSearchBar = ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 40),
      child: CatalogSearchBar(
        focusNode: focusNode,
        onScanPressed: onScanPressed ?? () {},
      ),
    );

    final appBar = AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: isMobile ? 2 : 4,
      centerTitle: isMobile,
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: gradient),
      ),
      // 🔥 Leading: Siempre el botón de Destacados
      leading: Center(
        child: buildActionButton(
          icon: Icons.whatshot_rounded,
          tooltip: 'Destacados (F3)',
          onPressed: () => showTopProducts(context),
        ),
      ),
      // 📌 Title: BCV en móvil, SearchBar en escritorio
      title: isMobile
          ? _BcvBadge(
              bcvState: bcvState,
              onTap: () => ref.read(bcvProvider).actualizarTasa(),
              isTablet: isTablet,
              isMobile: isMobile,
            )
          : (isDesktop
              ? safeSearchBar
              : Text(
                  'Catálogo',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 22 : 18,
                    color: Colors.white,
                  ),
                )),
      // 📋 Actions: Panel rápido, Inventario, POS, (y en escritorio BCV + Avatar)
      actions: [
        buildActionButton(
          icon: Icons.menu_rounded,
          tooltip: 'Panel rápido (F4)',
          onPressed: () => showSidePanel(context),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Inventario',
          child: Center(
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
              isMobile: isMobile,
            ),
          ),
        ),
        const SizedBox(width: 6),
        buildActionButton(
          icon: Icons.grid_view_rounded,
          tooltip: 'Panel POS',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PosMenuScreen()),
          ),
        ),
        // En escritorio mostramos BCV y Avatar
        if (!isMobile) ...[
          const SizedBox(width: 12),
          Center(
            child: _BcvBadge(
              bcvState: bcvState,
              onTap: () => ref.read(bcvProvider).actualizarTasa(),
              isTablet: isTablet,
              isMobile: isMobile,
            ),
          ),
          if (usuarioLogueado != null) ...[
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                radius: isTablet ? 20 : 16,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: Text(
                  usuarioLogueado!.nombre[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ],
        if (isMobile) const SizedBox(width: 8), // Margen final
      ],
    );

    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: appBar,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _InventoryBadge extends StatelessWidget {
  final int lowStockCount;
  final VoidCallback onPressed;
  final bool isTablet;
  final bool isMobile;

  const _InventoryBadge({
    required this.lowStockCount,
    required this.onPressed,
    required this.isTablet,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    bool isHovered = false;
    final size = isMobile ? 36.0 : (isTablet ? 44.0 : 40.0);

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
                  color: Colors.white.withValues(alpha: isHovered ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.inventory_2_outlined,
                    color: Colors.white,
                    size: isMobile ? 20 : (isTablet ? 24 : 20),
                  ),
                  onPressed: onPressed,
                  padding: EdgeInsets.zero,
                  splashRadius: size * 0.6,
                ),
              ),
              if (lowStockCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5), // Borde para mayor legibilidad
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$lowStockCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
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

class _BcvBadge extends StatelessWidget {
  final BcvController bcvState;
  final VoidCallback onTap;
  final bool isTablet;
  final bool isMobile;

  const _BcvBadge({
    required this.bcvState,
    required this.onTap,
    required this.isTablet,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    bool isHovered = false;
    final fontSize = isMobile ? 12.0 : (isTablet ? 15.0 : 13.0); 

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
              // Diseño tipo "Píldora" optimizado
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : (isTablet ? 16 : 12),
                vertical: isMobile ? 6 : (isTablet ? 8 : 6),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isHovered || bcvState.cargando ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isHovered ? 0.9 : 0.4),
                  width: 1.2,
                ),
              ),
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: bcvState.cargando
                    ? SizedBox(
                        width: isMobile ? 14 : 18,
                        height: isMobile ? 14 : 18,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.currency_exchange,
                            size: isMobile ? 15 : (isTablet ? 20 : 16),
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            // Se eliminó la palabra "BCV:" en móvil para que sea más compacto y elegante
                            isMobile ? 'Bs. ${bcvState.tasa.toStringAsFixed(2)}' : 'BCV: Bs. ${bcvState.tasa.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}