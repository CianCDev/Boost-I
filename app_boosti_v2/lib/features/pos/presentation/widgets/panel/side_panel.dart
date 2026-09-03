// lib/features/panel/widgets/side_panel.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:provider/provider.dart';

import '../../controllers/panel_controller.dart';
import 'panel_button.dart';
import 'panel_header.dart';
import 'theme_toggle_tile.dart';
import '../printer_selection_widget.dart';

class SidePanel extends ConsumerStatefulWidget {
  final BuildContext screenContext;
  final VoidCallback onClose;

  const SidePanel({
    super.key,
    required this.screenContext,
    required this.onClose,
  });

  @override
  ConsumerState<SidePanel> createState() => _SidePanelState();
}

class _SidePanelState extends ConsumerState<SidePanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closePanel([VoidCallback? afterClose]) {
    _controller.reverse().then((_) {
      widget.onClose();
      if (afterClose != null) afterClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(widget.screenContext).size.width;
    final panelWidth = screenWidth < 600
        ? screenWidth * 0.85
        : (screenWidth < 1200 ? 380.0 : 400.0);
    final isDark = Theme.of(widget.screenContext).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _closePanel();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _closePanel,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withValues(alpha: 0.4 * _fadeAnimation.value),
              child: Align(
                alignment: Alignment.centerRight,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: GestureDetector(
                    onTap: () {},
                    child: Material(
                      color: Colors.transparent,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          bottomLeft: Radius.circular(24),
                        ),
                        // 🔥 FONDO CON GRADIENTE EN LUGAR DE GLASSMORPHISM
                        child: Container(
                          width: panelWidth,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            gradient: isDark
                                ? const LinearGradient(
                                    colors: [Color(0xFF23232D), Color(0xFF1A1A1A)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  )
                                : LinearGradient(
                                    // Lavanda/gris muy sutil, similar a image_a66fb3.png
                                    colors: [
                                      const Color(0xFFE8EAF6).withValues(alpha: 0.95),
                                      const Color(0xFFF4F5F7).withValues(alpha: 0.98),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomCenter,
                                  ),
                            border: Border(
                              left: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.05),
                                width: 1.0,
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              PanelHeader(onClose: _closePanel),
                              Expanded(
                                child: _buildButtonList(widget.screenContext),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildButtonList(BuildContext screenContext) {
    final controller = Provider.of<PanelController>(screenContext, listen: false);
    final ref = this.ref;

    final categories = [
      _Category(
        title: 'Configuración',
        icon: Icons.settings_rounded,
        items: [
          _PanelItem(
            icon: Icons.print_rounded,
            label: 'Cambiar impresora',
            color: Colors.blue,
            action: () {
              _closePanel(() {
                showDialog<void>(
                  context: screenContext,
                  builder: (_) => const PrinterSelectionDialog(),
                );
              });
            },
          ),
          _PanelItem(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Cambiar lector',
            color: Colors.indigo,
            action: () {
              _closePanel(() => controller.cambiarLector(screenContext));
            },
          ),
          _PanelItem(
            icon: Icons.switch_account_rounded,
            label: 'Cambiar cajero',
            color: Colors.purple,
            action: () {
              _closePanel(() => controller.cambiarCajero(screenContext));
            },
          ),
        ],
      ),
      _Category(
        title: 'Promociones',
        icon: Icons.local_offer_rounded,
        items: [
          _PanelItem(
            icon: Icons.people_rounded,
            label: 'Clientes frecuentes',
            color: Colors.green,
            action: () {
              _closePanel(() => controller.clientesFrecuentes(screenContext));
            },
          ),
          _PanelItem(
            icon: Icons.local_offer_rounded,
            label: 'Descuento especial',
            color: Colors.orange,
            action: () {
              _closePanel(() => controller.descuentoEspecial(screenContext));
            },
          ),
          _PanelItem(
            icon: Icons.add_circle_outline_rounded,
            label: 'Crear promoción',
            color: Colors.teal,
            action: () {
              _closePanel(() => controller.crearPromocion(screenContext));
            },
          ),
        ],
      ),
      _Category(
        title: 'Productos',
        icon: Icons.inventory_2_rounded,
        items: [
          _PanelItem(
            icon: Icons.inventory_2_rounded,
            label: 'Productos inactivos',
            color: Colors.red,
            action: () {
              _closePanel(() => controller.productosInactivos(screenContext));
            },
          ),
        ],
      ),
      _Category(
        title: 'Pedidos',
        icon: Icons.shopping_bag_rounded,
        items: [
          _PanelItem(
            icon: Icons.shopping_bag_rounded,
            label: 'Pedidos remotos',
            color: Colors.cyan,
            action: () {
              _closePanel(() => controller.pedidosRemotos(screenContext));
            },
          ),
        ],
      ),
      _Category(
        title: 'Sistema',
        icon: Icons.computer_rounded,
        items: [
          _PanelItem(
            icon: Icons.keyboard_rounded,
            label: 'Atajos de teclado',
            color: Colors.grey,
            action: () {
              _closePanel(() => controller.atajosTeclado(screenContext));
            },
          ),
          _PanelItem(
            icon: Icons.free_breakfast_rounded,
            label: 'Descanso',
            color: Colors.brown,
            action: () {
              _closePanel(() => controller.descanso(screenContext));
            },
          ),
        ],
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == categories.length - 1) {
          final cat = categories[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryHeader(cat, screenContext),
              ...cat.items.map(
                (item) => PanelButton(
                  icon: item.icon,
                  label: item.label,
                  color: item.color,
                  onTap: item.action,
                ),
              ),
              ThemeToggleTile(
                onTap: () {
                  _closePanel(() => controller.toggleTheme(screenContext, ref));
                },
              ),
            ],
          );
        } else if (index < categories.length) {
          final cat = categories[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCategoryHeader(cat, screenContext),
              ...cat.items.map(
                (item) => PanelButton(
                  icon: item.icon,
                  label: item.label,
                  color: item.color,
                  onTap: item.action,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCategoryHeader(_Category cat, BuildContext screenContext) {
    final isDark = Theme.of(screenContext).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(cat.icon, size: 16, color: isDark ? Colors.white54 : Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            cat.title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.grey.shade700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// Modelos
class _Category {
  final String title;
  final IconData icon;
  final List<_PanelItem> items;
  _Category({required this.title, required this.icon, required this.items});
}

class _PanelItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback action;
  _PanelItem({required this.icon, required this.label, required this.color, required this.action});
}