// lib/features/pos/presentation/widgets/panel/side_panel.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;

// ✅ Eliminado: import '../../controllers/panel_controller.dart';
// ✅ Import del Provider de Riverpod
import '../../providers/panel_provider.dart'; 

import '../../../data/Local/entities/isar_service.dart';
import '../../../data/Local/entities/log_entity.dart';
import '../../../data/Local/entities/usuario_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lock_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../services/sync_service.dart';
import '../clientes/clientes_dialog.dart';
import 'cambiar_cajero_dialog.dart';
import 'descuentos_especiales_dialog.dart';
import 'keyboard_shortcuts_dialog.dart';
import 'panel_button.dart';
import 'panel_header.dart';
import 'productos_inactivos_dialog.dart';
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
  late double _panelWidth;

  @override
  void initState() {
    super.initState();

    final screenSize = MediaQuery.of(widget.screenContext).size;
    _panelWidth = screenSize.width < 600
        ? screenSize.width * 0.85
        : (screenSize.width < 1200 ? 380.0 : 400.0);

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
    }).catchError((e) {
      widget.onClose();
      if (afterClose != null) afterClose();
    });
  }

  // ==================== CAMBIAR CAJERO ====================

  void _mostrarCambiarCajero(BuildContext context) {
    final authState = ref.read(authProvider);
    final currentUser = authState.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay usuario autenticado'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!['admin', 'supervisor'].contains(currentUser.rol)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No tienes permisos para cambiar el cajero'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CambiarCajeroDialog(),
    );
  }

  // ==================== DESCANSO ====================

  void _mostrarDialogoDescanso(
    BuildContext context,
    UsuarioEntity currentUser,
    LockStateNotifier lockNotifier,
  ) {
    if (currentUser.rol.toLowerCase() != 'cajero') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo un cajero puede iniciar el descanso'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _DialogoDescanso(
        usuario: currentUser,
        onConfirm: () async {
          // 1. Marcar usuario inactivo
          final isar = IsarService();
          final sync = SyncService();

          await isar.actualizarEstadoUsuario(currentUser.id, 'inactivo');
          await sync.actualizarEstadoUsuarioEnSupabase(currentUser.id, 'inactivo');

          // 2. Registrar log
          await isar.guardarLog(
            LogEntity()
              ..accion = 'DESCANSO_INICIADO'
              ..usuarioNombre = currentUser.nombre
              ..usuarioRol = currentUser.rol
              ..detalles = 'Usuario entró en modo descanso'
              ..fecha = DateTime.now()
              ..sincronizado = false,
          );

          // 3. BLOQUEAR PANTALLA usando lockProvider
          lockNotifier.manualRest();
        },
      ),
    );
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(widget.screenContext).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _closePanel();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final fadeValue = _fadeAnimation.value;
          return FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: _closePanel,
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.black.withValues(alpha: 0.4 * fadeValue),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: child!,
                  ),
                ),
              ),
            ),
          );
        },
        child: _buildPanelContent(isDark),
      ),
    );
  }

  // ✅ Contenido separado y cacheado.
  Widget _buildPanelContent(bool isDark) {
    return GestureDetector(
      onTap: () {},
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            bottomLeft: Radius.circular(24),
          ),
          child: Container(
            width: _panelWidth,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF23232D), Color(0xFF1A1A1A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
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
    );
  }

  Widget _buildButtonList(BuildContext screenContext) {
    // ✅ Usamos `ref` directamente (propiedad de ConsumerState)
    final controller = ref.read(panelControllerProvider);
    
    final usuarioActual = ref.watch(usuarioActualProvider);
    final puedeCambiarCajero = usuarioActual != null &&
        (usuarioActual.rol == 'admin' || usuarioActual.rol == 'supervisor');

    // ==================== DEFINICIÓN DE CATEGORÍAS ====================
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
          if (puedeCambiarCajero)
            _PanelItem(
              icon: Icons.switch_account_rounded,
              label: 'Cambiar cajero',
              color: Colors.purple,
              action: () {
                _closePanel(() => _mostrarCambiarCajero(screenContext));
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
              _closePanel(() {
                ClientesDialog.show(screenContext);
              });
            },
          ),
          _PanelItem(
            icon: Icons.local_offer_rounded,
            label: 'Descuento especial',
            color: Colors.orange,
            action: () {
              _closePanel(() {
                DescuentoEspecialDialog.show(screenContext);
              });
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
              _closePanel(() {
                ProductosInactivosDialog.show(screenContext);
              });
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
              _closePanel(() {
                KeyboardShortcutsDialog.show(screenContext);
              });
            },
          ),
          _PanelItem(
            icon: Icons.free_breakfast_rounded,
            label: 'Descanso',
            color: Colors.brown,
            action: () {
              if (usuarioActual?.rol.toLowerCase() == 'cajero') {
                final usuario = usuarioActual;
                final lockNotifier = ref.read(lockProvider.notifier);
                _closePanel(() => _mostrarDialogoDescanso(
                      screenContext,
                      usuario!,
                      lockNotifier,
                    ));
              }
            },
          ),
        ],
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == categories.length) {
          return ThemeToggleTile(
            onTap: () {
              _closePanel(() => controller.toggleTheme(screenContext, ref));
            },
          );
        }
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

// ==================== MODELOS ====================

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

// ==================== DIÁLOGO DE DESCANSO (estilizado) ====================

class _DialogoDescanso extends StatelessWidget {
  final UsuarioEntity usuario;
  final VoidCallback onConfirm;

  const _DialogoDescanso({required this.usuario, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [Colors.grey[900]!.withValues(alpha: 0.9), Colors.grey[850]!.withValues(alpha: 0.95)]
                : [Colors.white.withValues(alpha: 0.85), const Color(0xFFF5F6FA).withValues(alpha: 0.9)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.4),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.12),
              blurRadius: 40,
              spreadRadius: 4,
              offset: const Offset(0, 20),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: isDark ? ImageFilter.blur(sigmaX: 12, sigmaY: 12) : ImageFilter.blur(sigmaX: 6, sigmaY: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.brown.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.free_breakfast_rounded, size: 48, color: Colors.brown.shade600),
                ),
                const SizedBox(height: 16),
                Text(
                  '¿Iniciar descanso?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${usuario.nombre}, la caja se bloqueará.\nNecesitarás tu PIN para reanudar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      icon: const Icon(Icons.free_breakfast_rounded),
                      label: const Text('Ir a descanso'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        elevation: 4,
                        shadowColor: Colors.brown.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}