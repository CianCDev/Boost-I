import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/bcv_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../utils/responsive_helper.dart';
import '../../screens/inventory_screen.dart';
import '../../screens/pos_menu_screen.dart';
import '../../../data/Local/entities/usuario_entity.dart';

class CatalogAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final UsuarioEntity? usuarioLogueado;

  const CatalogAppBar({super.key, this.usuarioLogueado});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final bcvState = ref.watch(bcvProvider);
    final lowStockCount = ref.read(catalogProvider.notifier).lowStockCount;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      leadingWidth: 85,
      leading: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(Icons.storefront, color: colorScheme.onPrimary, size: 32),
        ),
      ),
      title: Text(
        isMobile ? '' : 'Catálogo',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: colorScheme.onPrimary),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: isDark
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primaryContainer.withValues(alpha: 0.9),
                    colorScheme.primary,
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color.fromRGBO(68, 109, 241, 1), Color.fromARGB(255, 85, 59, 235)],
                ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: colorScheme.onPrimary,
      actions: [
        Tooltip(
          message: 'Panel de Control POS',
          child: Container(
            width: isTablet ? 44 : 36,
            height: isTablet ? 44 : 36,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.grid_view_rounded, color: colorScheme.onPrimary, size: 24),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PosMenuScreen())),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Tooltip(
          message: 'Ir a Gestión de Inventario',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: isTablet ? 44 : 36,
                height: isTablet ? 44 : 36,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFBBF24), Color(0xFFF59E0B)],
                  ),
                  shape: BoxShape.circle,
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
                ),
              ),
              if (lowStockCount > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$lowStockCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: 'Tasa oficial BCV (Haz clic para actualizar)',
          child: InkWell(
            onTap: () => ref.read(bcvProvider).actualizarTasa(),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              margin: const EdgeInsets.only(left: 4, right: 8),
              decoration: BoxDecoration(
                color: bcvState.cargando
                    ? colorScheme.onPrimary.withValues(alpha: 0.25)
                    : colorScheme.onPrimary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.onPrimary.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.currency_exchange, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 6),
                  if (bcvState.cargando)
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    )
                  else
                    Text(
                      'BCV: Bs. ${bcvState.tasa.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}