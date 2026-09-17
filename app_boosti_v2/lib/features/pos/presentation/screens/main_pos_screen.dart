// lib/features/pos/presentation/screens/main_pos_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/permissions/roles.dart';
import '../providers/auth_provider.dart';
import '../providers/bcv_provider.dart';
import '../providers/usuario_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/catalog/bcv_moneda_selector.dart';
import '../widgets/menu/pos_menu_card.dart';
import 'cash_closing_screen.dart';
import 'configuracion_empresa_screen.dart';
import 'dashboard_screen.dart';
import 'departamentos/departamentos_screen.dart';
import 'empleados/employees_screen.dart';
import 'gastos_screen.dart';
import 'inventory_catalog_screen.dart';
import 'inventory_screen.dart';
import 'locales/locales_screen.dart';
import 'login_screen.dart';
import 'lotes_screen.dart';
import 'pedido/pedidos_screen.dart';
import 'pos_menu_screen.dart';
import 'proveedores/proveedores_screen.dart';
import 'sales_history_screen.dart';
import 'telegram/telegram_config_screen.dart';
import 'user_settings_screen.dart';

// ═══════════════════════════════════════════════════════════════════════
// PANTALLA PRINCIPAL
// ═══════════════════════════════════════════════════════════════════════

class MainPosScreen extends ConsumerStatefulWidget {
  const MainPosScreen({super.key});

  @override
  ConsumerState<MainPosScreen> createState() => _MainPosScreenState();
}

class _MainPosScreenState extends ConsumerState<MainPosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureFreshBcvRate());
  }

  Future<void> _ensureFreshBcvRate() async {
    if (!mounted) return;
    final bcv = ref.read(bcvProvider);
    if (bcv.cargando) return;

    final ultima = bcv.ultimoUpdateRemoto;
    final needsUpdate = ultima == null ||
        DateTime.now().difference(ultima).inHours >= 6;
    if (!needsUpdate) return;

    try {
      await ref.read(bcvProvider).actualizarTasa();
    } catch (e) {
      debugPrint('⚠️ Refresh BCV falló (no bloquea): $e');
    }
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    ref.read(usuarioActualProvider.notifier).clearUsuario();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider);

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final role = UserRole.fromString(usuario.rol);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 14 : 24,
            vertical: isMobile ? 16 : 22,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AnimatedEntry(
                    index: 0,
                    child: _WelcomeHeader(usuario: usuario, role: role),
                  ),
                  const SizedBox(height: 20),
                  _AnimatedEntry(
                    index: 1,
                    child: _RoleGuideCard(role: role),
                  ),
                  const SizedBox(height: 28),
                  _AnimatedEntry(
                    index: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSectionTitle(
                          'ACCESOS RÁPIDOS',
                          _roleColor(role),
                        ),
                        const SizedBox(height: 12),
                        _QuickAccessGrid(
                          role: role,
                          isMobile: isMobile,
                          isTablet: isTablet,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: color,
          ),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leadingWidth: 85,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: SvgPicture.asset(
          'assets/logoboosti300px.svg',
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(
            Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
      title: const Text(
        'Inicio',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(68, 109, 241, 1),
              Color.fromARGB(255, 85, 59, 235),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 2,
      foregroundColor: Colors.white,
      actions: [
        const _BcvBadge(),
        const SizedBox(width: 4),
        _AppBarIconButton(
          icon: Icons.person_rounded,
          tooltip: 'Mi perfil',
          color: Colors.white,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserSettingsScreen()),
          ),
        ),
        const SizedBox(width: 2),
        _AppBarIconButton(
          icon: Icons.logout_rounded,
          tooltip: 'Cerrar sesión',
          color: const Color(0xFFEF4444),
          onTap: _confirmLogout,
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// APPBAR — BADGE BCV
// ═══════════════════════════════════════════════════════════════════════

class _BcvBadge extends ConsumerStatefulWidget {
  const _BcvBadge();

  @override
  ConsumerState<_BcvBadge> createState() => _BcvBadgeState();
}

class _BcvBadgeState extends ConsumerState<_BcvBadge> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bcv = ref.watch(bcvProvider);

    return Tooltip(
      message: 'Ver tasas de cambio',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () => BcvMonedaSelectorDialog.mostrar(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: _hovered ? 0.28 : 0.18),
                  Colors.white.withValues(alpha: _hovered ? 0.16 : 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withValues(alpha: _hovered ? 0.7 : 0.4),
                width: 1,
              ),
              boxShadow: _hovered
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.currency_exchange_rounded,
                  size: 14,
                  color: Color(0xFF38BDF8),
                ),
                const SizedBox(width: 6),
                if (bcv.cargando)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: Colors.white,
                    ),
                  )
                else
                  Text(
                    'Bs. ${bcv.tasa.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// APPBAR — BOTÓN DE ICONO CON HOVER
// ═══════════════════════════════════════════════════════════════════════

class _AppBarIconButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _AppBarIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  State<_AppBarIconButton> createState() => _AppBarIconButtonState();
}

class _AppBarIconButtonState extends State<_AppBarIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: _hovered ? 0.20 : 0.0),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.icon,
              size: 22,
              color: widget.color,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ANIMACIÓN DE ENTRADA
// ═══════════════════════════════════════════════════════════════════════

class _AnimatedEntry extends StatelessWidget {
  final int index;
  final Widget child;

  const _AnimatedEntry({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, inner) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: inner),
        );
      },
      child: child,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// HERO DE BIENVENIDA
// ═══════════════════════════════════════════════════════════════════════

class _WelcomeHeader extends StatelessWidget {
  final UsuarioEntity usuario;
  final UserRole role;

  const _WelcomeHeader({required this.usuario, required this.role});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final roleColor = _roleColor(role);
    final hora = DateTime.now().hour;
    final saludo = _greetingForHour(hora);
    final inicial =
        usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : '?';

    return Container(
      padding: EdgeInsets.all(isMobile ? 18 : 22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            roleColor,
            Color.lerp(roleColor, Colors.black, 0.28)!,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: roleColor.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: isMobile ? 26 : 32,
              backgroundColor: Colors.white,
              child: Text(
                inicial,
                style: TextStyle(
                  fontSize: isMobile ? 22 : 28,
                  fontWeight: FontWeight.w800,
                  color: roleColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$saludo, ${usuario.nombre.split(' ').first}',
                  style: TextStyle(
                    fontSize: isMobile ? 17 : 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _roleIcon(role),
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            role.label,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                              height: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (usuario.cajaAsignada.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '· ${usuario.cajaAsignada}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// GUÍA RÁPIDA POR ROL (sin glass — sólida, rápida)
// ═══════════════════════════════════════════════════════════════════════

class _RoleGuideCard extends StatelessWidget {
  final UserRole role;

  const _RoleGuideCard({required this.role});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final steps = _guideStepsForRole(role);
    final roleColor = _roleColor(role);

    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceContainerHigh : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: roleColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Cómo empezar?',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Guía para ${role.label.toLowerCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...steps.asMap().entries.map((entry) {
            return _GuideStepRow(
              number: entry.key + 1,
              step: entry.value,
              color: roleColor,
              isLast: entry.key == steps.length - 1,
            );
          }),
        ],
      ),
    );
  }
}

class _GuideStepRow extends StatelessWidget {
  final int number;
  final _GuideStep step;
  final Color color;
  final bool isLast;

  const _GuideStepRow({
    required this.number,
    required this.step,
    required this.color,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 1.5,
                  height: 22,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  color: color.withValues(alpha: 0.2),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(step.icon, size: 14, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (step.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.description!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// GRID DE ACCESOS RÁPIDOS
// ═══════════════════════════════════════════════════════════════════════

class _QuickAccessGrid extends StatelessWidget {
  final UserRole role;
  final bool isMobile;
  final bool isTablet;

  const _QuickAccessGrid({
    required this.role,
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final items = _quickItemsForRole(role);

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Text(
            'No hay accesos disponibles para tu rol.',
            style: TextStyle(fontSize: 13),
          ),
        ),
      );
    }

    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isMobile ? 3.2 : 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        return PosMenuCard(
          title: item.title,
          subtitle: item.subtitle,
          icon: item.icon,
          color: item.color,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => item.screenBuilder()),
          ),
        );
      },
    );
  }
}

class _QuickAccessCard extends StatefulWidget {
  final _QuickAccessItem item;

  const _QuickAccessCard({required this.item});

  @override
  State<_QuickAccessCard> createState() => _QuickAccessCardState();
}

class _QuickAccessCardState extends State<_QuickAccessCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);
    final item = widget.item;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => item.screenBuilder()),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: EdgeInsets.all(isMobile ? 14 : 16),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHigh
                    .withValues(alpha: _hovered ? 0.9 : 0.7)
                : Colors.white.withValues(alpha: _hovered ? 1.0 : 0.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hovered
                  ? item.color.withValues(alpha: 0.5)
                  : colorScheme.outlineVariant.withValues(alpha: 0.3),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: isDark ? 0.2 : (_hovered ? 0.08 : 0.04),
                ),
                blurRadius: _hovered ? 14 : 8,
                offset: Offset(0, _hovered ? 5 : 3),
              ),
            ],
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color
                      .withValues(alpha: _hovered ? 0.20 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  item.icon,
                  size: isMobile ? 22 : 24,
                  color: item.color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// MODELOS DE DATOS
// ═══════════════════════════════════════════════════════════════════════

class _GuideStep {
  final IconData icon;
  final String title;
  final String? description;

  const _GuideStep({
    required this.icon,
    required this.title,
    this.description,
  });
}

class _QuickAccessItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Widget Function() screenBuilder;

  const _QuickAccessItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.screenBuilder,
  });
}

// ═══════════════════════════════════════════════════════════════════════
// HELPERS DE ROL
// ═══════════════════════════════════════════════════════════════════════

Color _roleColor(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return const Color(0xFF3B82F6);
    case UserRole.supervisor:
      return const Color(0xFF8B5CF6);
    case UserRole.rrhh:
      return const Color(0xFF10B981);
    case UserRole.cajero:
      return const Color(0xFF14B8A6);
    case UserRole.auditor:
      return const Color(0xFF64748B);
    case UserRole.almacen:
      return const Color(0xFFF59E0B);
    case UserRole.dev:
      return const Color(0xFF06B6D4);
    case UserRole.soporte:
      return const Color(0xFF6366F1);
  }
}

IconData _roleIcon(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return Icons.admin_panel_settings_rounded;
    case UserRole.supervisor:
      return Icons.supervisor_account_rounded;
    case UserRole.rrhh:
      return Icons.badge_rounded;
    case UserRole.cajero:
      return Icons.point_of_sale_rounded;
    case UserRole.auditor:
      return Icons.verified_rounded;
    case UserRole.almacen:
      return Icons.inventory_2_rounded;
    case UserRole.dev:
      return Icons.terminal_rounded;
    case UserRole.soporte:
      return Icons.support_agent_rounded;
  }
}

String _greetingForHour(int hour) {
  if (hour >= 5 && hour < 12) return 'Buenos días';
  if (hour >= 12 && hour < 19) return 'Buenas tardes';
  return 'Buenas noches';
}

// ═══════════════════════════════════════════════════════════════════════
// GUÍA POR ROL
// ═══════════════════════════════════════════════════════════════════════

List<_GuideStep> _guideStepsForRole(UserRole role) {
  switch (role) {
    case UserRole.cajero:
      return const [
        _GuideStep(
          icon: Icons.point_of_sale_rounded,
          title: 'Abre el punto de venta',
          description: 'Desde "Punto de venta" o "Catálogo".',
        ),
        _GuideStep(
          icon: Icons.shopping_cart_rounded,
          title: 'Selecciona productos',
          description: 'Busca por nombre o escanea el código de barras.',
        ),
        _GuideStep(
          icon: Icons.payments_outlined,
          title: 'Cobra la orden',
          description: 'Elige el método de pago y confirma.',
        ),
        _GuideStep(
          icon: Icons.receipt_long_rounded,
          title: 'Entrega el ticket',
          description: 'Se imprime automáticamente si hay impresora.',
        ),
      ];

    case UserRole.supervisor:
      return const [
        _GuideStep(
          icon: Icons.dashboard_rounded,
          title: 'Revisa el Dashboard',
          description: 'Métricas del día, semana y mes.',
        ),
        _GuideStep(
          icon: Icons.receipt_long_rounded,
          title: 'Consulta las ventas',
          description: 'Historial con filtros por período y método.',
        ),
        _GuideStep(
          icon: Icons.payments_outlined,
          title: 'Cierra la caja',
          description: 'Al final del turno, haz el arqueo.',
        ),
        _GuideStep(
          icon: Icons.verified_user_rounded,
          title: 'Autoriza acciones',
          description: 'Tu PIN habilita descuentos y cambios especiales.',
        ),
        _GuideStep(
          icon: Icons.people_alt_rounded,
          title: 'Supervisa al equipo',
          description: 'Consulta el monitor de empleados.',
        ),
      ];

    case UserRole.admin:
      return const [
        _GuideStep(
          icon: Icons.settings_rounded,
          title: 'Configura tu empresa',
          description: 'URL y Anon Key de Supabase.',
        ),
        _GuideStep(
          icon: Icons.store_rounded,
          title: 'Crea tus locales',
          description: 'Sucursales y departamentos.',
        ),
        _GuideStep(
          icon: Icons.people_alt_rounded,
          title: 'Invita a tu equipo',
          description: 'Usuarios, roles y permisos.',
        ),
        _GuideStep(
          icon: Icons.inventory_2_outlined,
          title: 'Carga tu inventario',
          description: 'Productos, precios y proveedores.',
        ),
        _GuideStep(
          icon: Icons.telegram,
          title: 'Activa alertas',
          description: 'Recibe avisos de stock por Telegram.',
        ),
      ];

    case UserRole.rrhh:
      return const [
        _GuideStep(
          icon: Icons.badge_rounded,
          title: 'Gestiona empleados',
          description: 'Fichas completas de cada persona.',
        ),
        _GuideStep(
          icon: Icons.schedule_rounded,
          title: 'Define horarios',
          description: 'Turnos, días libres y tolerancias.',
        ),
        _GuideStep(
          icon: Icons.payments_outlined,
          title: 'Registra salarios',
          description: 'Base, comisiones y bonos.',
        ),
        _GuideStep(
          icon: Icons.receipt_rounded,
          title: 'Consulta nómina',
          description: 'Historial de pagos por período.',
        ),
      ];

    case UserRole.almacen:
      return const [
        _GuideStep(
          icon: Icons.inventory_2_outlined,
          title: 'Actualiza el stock',
          description: 'Entradas, salidas y ajustes.',
        ),
        _GuideStep(
          icon: Icons.inventory_2_rounded,
          title: 'Controla los lotes',
          description: 'Trazabilidad y vencimientos.',
        ),
        _GuideStep(
          icon: Icons.shopping_cart_rounded,
          title: 'Crea pedidos',
          description: 'A proveedores con cantidades exactas.',
        ),
        _GuideStep(
          icon: Icons.local_shipping_outlined,
          title: 'Registra recepciones',
          description: 'Verifica lo que llega físicamente.',
        ),
        _GuideStep(
          icon: Icons.print_rounded,
          title: 'Imprime etiquetas',
          description: 'Individuales o por lote.',
        ),
      ];

    case UserRole.auditor:
      return const [
        _GuideStep(
          icon: Icons.history_edu_rounded,
          title: 'Revisa el log',
          description: 'Auditoría de todas las acciones.',
        ),
        _GuideStep(
          icon: Icons.dashboard_rounded,
          title: 'Consulta el Dashboard',
          description: 'Métricas del período que necesites.',
        ),
        _GuideStep(
          icon: Icons.payments_outlined,
          title: 'Verifica cierres',
          description: 'Cuadres de caja y métodos de pago.',
        ),
        _GuideStep(
          icon: Icons.inventory_2_outlined,
          title: 'Audita inventario',
          description: 'Compara stock físico vs sistema.',
        ),
        _GuideStep(
          icon: Icons.receipt_long_rounded,
          title: 'Valida gastos',
          description: 'Revisa egresos y sus comprobantes.',
        ),
      ];

    case UserRole.dev:
      return const [
        _GuideStep(
          icon: Icons.terminal_rounded,
          title: 'Herramientas técnicas',
          description: 'Diagnóstico y logs del sistema.',
        ),
        _GuideStep(
          icon: Icons.build_circle_outlined,
          title: 'Diagnóstico de lotes',
          description: 'Verifica integridad del inventario.',
        ),
        _GuideStep(
          icon: Icons.print_rounded,
          title: 'Prueba hardware',
          description: 'Impresoras, balanzas, lectores.',
        ),
        _GuideStep(
          icon: Icons.cloud_sync_rounded,
          title: 'Sincronización',
          description: 'Forzar o diagnosticar sync.',
        ),
        _GuideStep(
          icon: Icons.dashboard_rounded,
          title: 'Rendimiento',
          description: 'Tiempos de carga y errores.',
        ),
      ];

    case UserRole.soporte:
      return const [
        _GuideStep(
          icon: Icons.support_agent_rounded,
          title: 'Atiende incidencias',
          description: 'Diagnostica y resuelve problemas.',
        ),
        _GuideStep(
          icon: Icons.history_edu_rounded,
          title: 'Consulta logs',
          description: 'Revisa el historial de acciones.',
        ),
        _GuideStep(
          icon: Icons.visibility_rounded,
          title: 'Monitor de empleados',
          description: 'Estado en tiempo real del equipo.',
        ),
        _GuideStep(
          icon: Icons.cloud_sync_rounded,
          title: 'Estado de sync',
          description: 'Verifica pendientes de sincronización.',
        ),
      ];
  }
}

// ═══════════════════════════════════════════════════════════════════════
// ACCESOS RÁPIDOS POR ROL
// ═══════════════════════════════════════════════════════════════════════

List<_QuickAccessItem> _quickItemsForRole(UserRole role) {
  final items = <_QuickAccessItem>[];

  if (Permissions.canAccessPos(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.point_of_sale_rounded,
      title: 'Punto de venta',
      subtitle: 'Cobra órdenes y gestiona el carrito',
      color: const Color(0xFF10B981),
      screenBuilder: () => const InventoryCatalogScreen(),
    ));
  }

  if (Permissions.canAccessInventory(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.inventory_2_outlined,
      title: 'Inventario',
      subtitle: 'Consulta y edita productos',
      color: const Color(0xFF3B82F6),
      screenBuilder: () => const InventoryScreen(),
    ));
  }

  if (Permissions.canAccessEmployees(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.badge_rounded,
      title: 'Empleados',
      subtitle: 'Fichas, nómina y estadísticas',
      color: const Color(0xFF10B981),
      screenBuilder: () => const EmployeesScreen(),
    ));
  }

  if (Permissions.canViewDashboard(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.dashboard_rounded,
      title: 'Dashboard',
      subtitle: 'Métricas, tendencias y actividad',
      color: const Color(0xFF06B6D4),
      screenBuilder: () => const DashboardScreen(),
    ));
  }

  if (Permissions.canViewDashboard(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.receipt_long_rounded,
      title: 'Historial de ventas',
      subtitle: 'Filtra por período, empleado o método',
      color: const Color(0xFF8B5CF6),
      screenBuilder: () => const SalesHistoryScreen(),
    ));
  }

  if (Permissions.canOpenCashRegister(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.payments_outlined,
      title: 'Cierre de caja',
      subtitle: 'Corte del día y arqueo por método',
      color: const Color(0xFFF59E0B),
      screenBuilder: () => const CashClosingScreen(),
    ));
  }

  if (Permissions.canManageLotes(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.inventory_2_rounded,
      title: 'Lotes y vencimientos',
      subtitle: 'Trazabilidad y control de caducidad',
      color: const Color(0xFF8B5CF6),
      screenBuilder: () => const LotesScreen(),
    ));
  }

  if (Permissions.canAccessInventory(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.shopping_cart_rounded,
      title: 'Pedidos a proveedores',
      subtitle: 'Crea, recibe y gestiona pedidos',
      color: const Color(0xFFEC4899),
      screenBuilder: () => const PedidosProveedorScreen(),
    ));
  }

  if (Permissions.canAccessInventory(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.local_shipping_outlined,
      title: 'Proveedores',
      subtitle: 'Catálogo de aliados comerciales',
      color: const Color(0xFF6366F1),
      screenBuilder: () => const ProveedoresScreen(),
    ));
  }

  if (Permissions.canViewFinancials(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.payments_outlined,
      title: 'Gastos',
      subtitle: 'Registra y consulta egresos',
      color: const Color(0xFFEF4444),
      screenBuilder: () => const GastosScreen(),
    ));
  }

  if (Permissions.canManageLocales(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.store_rounded,
      title: 'Locales',
      subtitle: 'Sucursales y multi-local',
      color: const Color(0xFF0EA5E9),
      screenBuilder: () => const LocalesScreen(),
    ));
  }

  if (Permissions.canManageLocales(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.business_center_rounded,
      title: 'Departamentos',
      subtitle: 'Organización interna del negocio',
      color: const Color(0xFF6366F1),
      screenBuilder: () => const DepartamentosScreen(),
    ));
  }

  if (Permissions.canManageTelegram(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.telegram,
      title: 'Bot de Telegram',
      subtitle: 'Notificaciones al móvil',
      color: const Color(0xFF0EA5E9),
      screenBuilder: () => const TelegramConfigScreen(),
    ));
  }

  if (Permissions.canAccessSettings(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.settings_rounded,
      title: 'Configuración de empresa',
      subtitle: 'Supabase y credenciales',
      color: const Color(0xFF64748B),
      screenBuilder: () => const ConfiguracionEmpresaScreen(),
    ));
  }

  if (!Permissions.isEmployeesOnlyRole(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.apps_rounded,
      title: 'Menú completo',
      subtitle: 'Todas las opciones del sistema',
      color: const Color(0xFF64748B),
      screenBuilder: () => const PosMenuScreen(),
    ));
  }

  return items;
}