// lib/features/pos/presentation/screens/main_pos_screen.dart
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:app_boosti_v2/features/pos/presentation/providers/business_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../domain/permissions/roles.dart';
import '../providers/auth_provider.dart';
import '../providers/bcv_provider.dart';
import '../providers/local_actual_provider.dart';
import '../providers/usuario_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/catalog/bcv_moneda_selector.dart';
import '../widgets/menu/pos_menu_card.dart';
import 'cash_closing_screen.dart';
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
    final needsUpdate =
        ultima == null || DateTime.now().difference(ultima).inHours >= 6;
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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

  /// Realinea el JWT con el local que se está viendo.
  ///
  /// ⚠️ Quedó sin consumidor al eliminar el `VistaPreviaBanner`. Se conserva
  /// (es `public` y no es código muerto desde el punto de vista de la API de
  /// la pantalla) por si el hot-switch del side panel necesita reemitir el
  /// JWT sin cambiar de local. `GuardTenantActivo` es lo que hoy bloquea las
  /// acciones cross-tenant; esto es el camino para *resolver* el
  /// desalineamiento.
  ///
  /// NO usa `logout()` a propósito: `AuthNotifier.logout()` preserva la
  /// sesión de Supabase (varios cajeros comparten tablet), así que cerrar
  /// sesión desde acá dejaría el JWT exactamente igual.
  Future<bool> realinearTenantConLocalActual() async {
    final localId = ref.read(localActualProvider);
    if (localId == null) return false;

    final isar = IsarService();
    final local = await isar.obtenerLocalPorId(localId);
    if (local?.supabaseId == null || local!.supabaseId!.isEmpty) {
      return false;
    }

    // `cambiarLocal` ya hace set_active_tenant + refreshSession y alinea
    // las 3 fuentes (TenantNotifier, LocalActualNotifier, LocalEntity).
    await ref.read(authProvider.notifier).cambiarLocal(local.supabaseId!);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final usuario = ref.watch(usuarioActualProvider);
    final flags = ref.watch(featureFlagsProvider); // 🎯 NUEVO

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final role = UserRole.fromString(usuario.rol);
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final roleColor = _roleColor(role);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: _WelcomeBackground(seed: roleColor),
          ),
          SafeArea(
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
                              roleColor,
                            ),
                            const SizedBox(height: 12),
                            _QuickAccessGrid(
                              role: role,
                              flags: flags, // 🎯 NUEVO
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
        ],
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
    // AppBar directo. Antes iba envuelto en `PreferredSize` + `Column`, y
    // ese envoltorio existía únicamente para colgar el `VistaPreviaBanner`
    // debajo: el alto del `PreferredSize` era `kToolbarHeight + _altoBanner`.
    // Un `Column` pelado no implementa `PreferredSizeWidget`, así que al
    // sacar el banner el `Column` tiene que irse también.
    //
    // ⚠️ El banner se eliminó por redundancia: `GuardTenantActivo` sigue
    // bloqueando las 4 acciones críticas (cobrar, descuento, crear pedido,
    // activar lote) y el hot-switch vive en el side panel. Lo que se
    // perdió es el aviso *previo*: ahora el desalineamiento se manifiesta
    // como un bloqueo sin explicación previa.
    //
    // ⚠️ AppBar CRUDO a propósito, no `CustomAppBar`.
    //
    // `CustomAppBar` (widgets/appbar.dart) está compartido por ~30
    // pantallas y tiene el contenido hardcodeado a BLANCO
    // (`foregroundColor`, `iconTheme` y el `ColorFilter` del logo).
    // Acá no sirve: el POS principal es la única pantalla con
    // `extendBodyBehindAppBar: true` sobre `_WelcomeBackground`, así
    // que una barra clara + texto blanco = ilegible. Tocar ese widget
    // para arreglarlo rompería las otras 30, así que la variante
    // clara vive acá, local.
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      // ⚠️ TRANSPARENTE a propósito: no hay barra. El fondo con
      // blobs del body se ve completo y el AppBar solo aporta los
      // elementos. Por eso los iconos van blancos con una base
      // circular propia (ver `_AppBarIconButton`): sin base, el
      // blanco se pierde contra `#F4F3FF` (~1.05:1).
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.white),
      leadingWidth: 85,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          // Misma base blanca que los botones: sin ella el logo
          // flota suelto sobre los blobs y pierde jerarquía.
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SvgPicture.asset(
            // ⚠️ `logoboosti300px.svg` es el asset DECLARADO en
            // pubspec.yaml. `logo.svg` existe en disco pero NO está
            // en el bundle → `SvgPicture.asset` no lo encuentra.
            'assets/logoboosti300px.svg',
            fit: BoxFit.contain,
            // Sin `ColorFilter`: el logo va a color real. Forzarlo
            // a blanco lo borraba sobre el fondo claro.
          ),
        ),
      ),
      title: const Text(
        'Inicio',
        style: TextStyle(
          // Negro suave, no `Colors.black`: sobre el fondo con
          // blobs el negro puro vibra y se ve sucio.
          fontWeight: FontWeight.w700,
          fontSize: 18,
          letterSpacing: -0.2,
          color: Color(0xFF111827),
          shadows: [
            // Halo blanco: garantiza legibilidad aunque un blob
            // violeta/azure pase justo por detrás del texto.
            Shadow(color: Color(0x99FFFFFF), blurRadius: 8),
          ],
        ),
      ),
      actions: [
        const _BcvBadge(),
        const SizedBox(width: 4),
        _AppBarIconButton(
          icon: Icons.person_rounded,
          tooltip: 'Mi perfil',
          // Glifo oscuro sobre la base blanca (no blanco sobre
          // blanco, que era el bug de legibilidad).
          color: const Color(0xFF111827),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserSettingsScreen()),
          ),
        ),
        const SizedBox(width: 2),
        _AppBarIconButton(
          icon: Icons.logout_rounded,
          tooltip: 'Cerrar sesión',
          // Rojo: distingue la acción destructiva del perfil a un
          // vistazo, sin necesidad de texto.
          color: const Color(0xFFEF4444),
          onTap: _confirmLogout,
        ),
        const SizedBox(width: 10),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// FONDO — BLOBS ANIMADOS (aurora suave, visible en claro y oscuro)
// ═══════════════════════════════════════════════════════════════════════

class _WelcomeBackground extends StatefulWidget {
  /// Color semilla (normalmente el color del rol del usuario).
  final Color seed;

  const _WelcomeBackground({required this.seed});

  @override
  State<_WelcomeBackground> createState() => _WelcomeBackgroundState();
}

class _WelcomeBackgroundState extends State<_WelcomeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      // 35s → movimientos muy lentos, sensación "aurora".
      duration: const Duration(seconds: 35),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.seed;

    // Paleta derivada del color del rol → cada rol tiene su "ambiente".
    final c1 = base; // rol
    final c2 = Color.lerp(base, const Color(0xFF8B5CF6), 0.55)!; // violeta
    final c3 = Color.lerp(base, const Color(0xFF06B6D4), 0.60)!; // cyan
    final c4 = Color.lerp(base, const Color(0xFFEC4899), 0.45)!; // rosa
    final c5 = Color.lerp(base, const Color(0xFFF59E0B), 0.50)!; // ámbar

    // ✅ Alphas recalibrados:
    //    - claro: 0.35/0.28/0.18 → los blobs SÍ se ven sobre blanco
    //    - oscuro: 0.24/0.18/0.12 → ambiente sin ser agresivo
    final alphaStrong = isDark ? 0.24 : 0.35;
    final alphaSoft = isDark ? 0.18 : 0.28;
    final alphaFaint = isDark ? 0.12 : 0.18;

    return RepaintBoundary(
      child: IgnorePointer(
        child: ClipRect(
          child: Stack(
            children: [
              // ── Capa base: gradiente diagonal muy sutil (rompe el blanco plano) ──
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? const [
                              Color(0xFF0F172A),
                              Color(0xFF0B1220),
                            ]
                          : const [
                              Color(0xFFF7F9FF),
                              Color(0xFFEFF3FB),
                            ],
                    ),
                  ),
                ),
              ),

              // ── Blobs animados ──
              AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final t = _c.value * 2 * math.pi;

                  return Stack(
                    children: [
                      // 1 · arriba-izquierda (el más fuerte, marca el tono)
                      Positioned(
                        top: -120 + 35 * math.sin(t),
                        left: -90 + 60 * math.cos(t * 0.9),
                        child: _Blob(
                          size: 420,
                          color: c1.withValues(alpha: alphaStrong),
                          blur: 90,
                        ),
                      ),

                      // 2 · arriba-derecha
                      Positioned(
                        top: -80 + 45 * math.cos(t * 0.8),
                        right: -120 + 65 * math.sin(t * 1.1),
                        child: _Blob(
                          size: 480,
                          color: c2.withValues(alpha: alphaSoft),
                          blur: 100,
                        ),
                      ),

                      // 3 · abajo-centro
                      Positioned(
                        bottom: -160 + 45 * math.sin(t * 1.3),
                        left: 120 + 90 * math.cos(t * 0.7),
                        child: _Blob(
                          size: 400,
                          color: c3.withValues(alpha: alphaSoft),
                          blur: 90,
                        ),
                      ),

                      // 4 · medio-derecha
                      Positioned(
                        top: 240 + 55 * math.sin(t * 0.6),
                        right: -140 + 45 * math.cos(t * 1.2),
                        child: _Blob(
                          size: 340,
                          color: c4.withValues(alpha: alphaFaint),
                          blur: 80,
                        ),
                      ),

                      // 5 · medio-izquierda (rellena el vacío central al hacer scroll)
                      Positioned(
                        top: 520 + 40 * math.cos(t * 0.9),
                        left: -160 + 70 * math.sin(t * 0.8),
                        child: _Blob(
                          size: 320,
                          color: c5.withValues(alpha: alphaFaint),
                          blur: 80,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Blob individual: círculo con gradiente radial suave + blur.
///
/// `RepaintBoundary` cachea el resultado del blur → al mover el blob
/// solo se recompone la capa, no se recalcula el filtro. Rendimiento ✅.
class _Blob extends StatelessWidget {
  final double size;
  final Color color;
  final double blur;

  const _Blob({
    required this.size,
    required this.color,
    this.blur = 60,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color,
                color.withValues(alpha: 0),
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
      ),
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

  /// Distingue hover de "presionado". Sin esto no hay `AnimatedScale`
  /// con dos intensidades: el squash al click se sentiría igual que el
  /// lift del hover.
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bcv = ref.watch(bcvProvider);

    return Tooltip(
      message: 'Ver tasas de cambio',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          onTap: () => BcvMonedaSelectorDialog.mostrar(context),
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            // 1.04 al hover, 0.94 al presionar. Escala el hit area
            // incluida: el gesto se siente elástico sin salir del chip.
            scale: _pressed ? 0.94 : (_hovered ? 1.04 : 1.0),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // Violeta SÓLIDO del design system. Es el único elemento
                // de la barra con color propio: lo que lo hace legible sin
                // necesidad de una barra de fondo, y ata el grupo de
                // acciones a la identidad de la app.
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _hovered
                      ? const [Color(0xFF4840E8), Color(0xFF3B34CE)]
                      : const [Color(0xFF5352ED), Color(0xFF4840E8)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  // Sombra siempre presente, no solo en hover: sin ella el
                  // chip "flota" sin peso sobre el fondo con blobs.
                  BoxShadow(
                    color: const Color(0xFF3B34CE).withValues(
                      alpha: _hovered ? 0.40 : 0.24,
                    ),
                    blurRadius: _hovered ? 14 : 8,
                    offset: Offset(0, _hovered ? 4 : 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.currency_exchange_rounded,
                    size: 14,
                    // El celeste sobre violeta daba ~2.6:1. Con blanco
                    // sube a ~4.8:1 (WCAG AA pide 4.5:1).
                    color: _hovered ? Colors.white : const Color(0xFFE0F2FE),
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
                        // Blanco sobre violeta = ~5.4:1.
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                ],
              ),
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
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() {
          _hovered = false;
          _pressed = false;
        }),
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) => setState(() => _pressed = true),
          onTapUp: (_) => setState(() => _pressed = false),
          onTapCancel: () => setState(() => _pressed = false),
          child: AnimatedScale(
            // Hover levanta (1.06), presionar hunde (0.92). El squash es
            // más marcado que el lift a propósito: es lo que confirma el
            // click sin necesidad de abrir un diálogo.
            scale: _pressed ? 0.92 : (_hovered ? 1.06 : 1.0),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                // Base BLANCA sobre AppBar sin fondo: es lo que le da
                // peso al botón y lo separa de los blobs.
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _hovered
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
                  width: _hovered ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    // Azul noche en vez de negro puro: negro al 8% sobre
                    // fondo claro se ve gris sucio; el tinte lo hace
                    // parecer sombra y no manchas.
                    color: const Color(0xFF0F172A).withValues(
                      alpha: _hovered ? 0.18 : 0.08,
                    ),
                    blurRadius: _hovered ? 16 : 8,
                    offset: Offset(0, _hovered ? 5 : 2),
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                size: 22,
                // ⚠️ Glifo OSCURO sobre base blanca. Con blanco el icono
                // se borraba dentro de su propio círculo (~1.05:1).
                // `#111827` sobre `#FFFFFF` = ~16.9:1.
                color: widget.color,
              ),
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
// GUÍA RÁPIDA POR ROL (mini-cards con hover, estilo PosMenuCard)
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header con icono degradado ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      roleColor.withValues(alpha: 0.25),
                      roleColor.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.lightbulb_rounded,
                  color: roleColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Cómo empezar?',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.4,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Guía para ${role.label.toLowerCase()} · ${steps.length} pasos',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: -0.1,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Pasos como mini-cards ──
          ...steps.asMap().entries.map((entry) {
            return _GuideStepCard(
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

class _GuideStepCard extends StatefulWidget {
  final int number;
  final _GuideStep step;
  final Color color;
  final bool isLast;

  const _GuideStepCard({
    required this.number,
    required this.step,
    required this.color,
    required this.isLast,
  });

  @override
  State<_GuideStepCard> createState() => _GuideStepCardState();
}

class _GuideStepCardState extends State<_GuideStepCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Padding(
      padding: EdgeInsets.only(bottom: widget.isLast ? 0 : 10),
      child: MouseRegion(
        cursor: SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered
                ? widget.color.withValues(alpha: isDark ? 0.10 : 0.05)
                : (isDark
                    ? colorScheme.surfaceContainer.withValues(alpha: 0.45)
                    : colorScheme.surfaceContainerLowest
                        .withValues(alpha: 0.7)),
            borderRadius: BorderRadius.circular(14),
            // ✅ Ancho FIJO (1.0) para no romper el layout en hover
            border: Border.all(
              color: _hovered
                  ? widget.color.withValues(alpha: 0.45)
                  : colorScheme.outlineVariant.withValues(alpha: 0.25),
              width: 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Número circular (se rellena y hace glow en hover) ──
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOut,
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _hovered
                      ? widget.color
                      : widget.color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  boxShadow: _hovered
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '${widget.number}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: _hovered ? Colors.white : widget.color,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // ── Caja del icono (estilo PosMenuCard) ──
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  widget.step.icon,
                  size: 20,
                  color: widget.color,
                ),
              ),
              const SizedBox(width: 12),

              // ── Título + descripción ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.step.title,
                      style: TextStyle(
                        fontSize: isMobile ? 14.5 : 15,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.step.description != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        widget.step.description!,
                        style: TextStyle(
                          fontSize: isMobile ? 12.5 : 13,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                          letterSpacing: -0.05,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// GRID DE ACCESOS RÁPIDOS
// ═══════════════════════════════════════════════════════════════════════

class _QuickAccessGrid extends StatelessWidget {
  final UserRole role;
  final FeatureFlags flags; // 🎯 NUEVO
  final bool isMobile;
  final bool isTablet;

  const _QuickAccessGrid({
    required this.role,
    required this.flags, // 🎯 NUEVO
    required this.isMobile,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final items = _quickItemsForRole(role, flags); // 🎯 CAMBIO

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

    final crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 3);
    final double itemHeight = isMobile ? 135 : 105;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisExtent: itemHeight,
        crossAxisSpacing: isMobile ? 10 : 12,
        mainAxisSpacing: isMobile ? 10 : 12,
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
          compactMode: isMobile,
        );
      },
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

List<_QuickAccessItem> _quickItemsForRole(UserRole role, FeatureFlags flags) {
  final items = <_QuickAccessItem>[];

  // ── POS ──
  //
  // TODO(R.2): antes esta tarjeta se ocultaba en modo restaurante con
  // `&& !flags.requiereMesa`, dejando al usuario sin forma de cobrar.
  // El reemplazo real es "en restaurante el POS rápido se abre por mesa",
  // y eso depende de la pantalla de mesas + comandas, que es R.1/R.2.
  // Hasta entonces el POS se mantiene visible en todos los modos.
  // Restaurar el gate en R.2, cuando exista el flujo por mesa.
  if (Permissions.canAccessPos(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.point_of_sale_rounded,
      title: 'Punto de venta',
      subtitle: 'Cobra órdenes y gestiona el carrito',
      color: const Color(0xFF10B981),
      screenBuilder: () => const InventoryCatalogScreen(),
    ));
  }

  // ── Inventario ── (oculto en modo servicios)
  if (Permissions.canAccessInventory(role) && flags.mostrarInventario) {
    items.add(_QuickAccessItem(
      icon: Icons.inventory_2_outlined,
      title: 'Inventario',
      subtitle: 'Consulta y edita productos',
      color: const Color(0xFF3B82F6),
      screenBuilder: () => const InventoryScreen(),
    ));
  }

  // ── Empleados ── (siempre, si el rol lo permite)
  if (Permissions.canAccessEmployees(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.badge_rounded,
      title: 'Empleados',
      subtitle: 'Fichas, nómina y estadísticas',
      color: const Color(0xFF10B981),
      screenBuilder: () => const EmployeesScreen(),
    ));
  }

  // ── Dashboard ── (requiere feature del plan)
  if (Permissions.canViewDashboard(role) && flags.dashboard) {
    items.add(_QuickAccessItem(
      icon: Icons.dashboard_rounded,
      title: 'Dashboard',
      subtitle: 'Métricas, tendencias y actividad',
      color: const Color(0xFF06B6D4),
      screenBuilder: () => const DashboardScreen(),
    ));
  }

  // ── Historial de ventas ──
  if (Permissions.canViewDashboard(role) && flags.historialVentas) {
    items.add(_QuickAccessItem(
      icon: Icons.receipt_long_rounded,
      title: 'Historial de ventas',
      subtitle: 'Filtra por período, empleado o método',
      color: const Color(0xFF8B5CF6),
      screenBuilder: () => const SalesHistoryScreen(),
    ));
  }

  // ── Cierre de caja ── (siempre disponible)
  if (Permissions.canOpenCashRegister(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.payments_outlined,
      title: 'Cierre de caja',
      subtitle: 'Corte del día y arqueo por método',
      color: const Color(0xFFF59E0B),
      screenBuilder: () => const CashClosingScreen(),
    ));
  }

  // ── Lotes ── (requiere plan + no servicios)
  if (Permissions.canManageLotes(role) && flags.mostrarLotes) {
    items.add(_QuickAccessItem(
      icon: Icons.inventory_2_rounded,
      title: 'Lotes y vencimientos',
      subtitle: 'Trazabilidad y control de caducidad',
      color: const Color(0xFF8B5CF6),
      screenBuilder: () => const LotesScreen(),
    ));
  }

  // ── Pedidos a proveedores ── (requiere plan + no servicios)
  if (Permissions.canAccessInventory(role) &&
      flags.pedidosProveedores &&
      !flags.esServicios) {
    items.add(_QuickAccessItem(
      icon: Icons.shopping_cart_rounded,
      title: 'Pedidos a proveedores',
      subtitle: 'Crea, recibe y gestiona pedidos',
      color: const Color(0xFFEC4899),
      screenBuilder: () => const PedidosProveedorScreen(),
    ));
  }

  // ── Proveedores ── (oculto en servicios)
  if (Permissions.canAccessInventory(role) && !flags.esServicios) {
    items.add(_QuickAccessItem(
      icon: Icons.local_shipping_outlined,
      title: 'Proveedores',
      subtitle: 'Catálogo de aliados comerciales',
      color: const Color(0xFF6366F1),
      screenBuilder: () => const ProveedoresScreen(),
    ));
  }

  // ── Gastos ── (sin cambios)
  if (Permissions.canViewFinancials(role)) {
    items.add(_QuickAccessItem(
      icon: Icons.payments_outlined,
      title: 'Gastos',
      subtitle: 'Registra y consulta egresos',
      color: const Color(0xFFEF4444),
      screenBuilder: () => const GastosScreen(),
    ));
  }

  // ── Locales ── (requiere plan multi-local)
  if (Permissions.canManageLocales(role) && flags.multiLocal) {
    items.add(_QuickAccessItem(
      icon: Icons.store_rounded,
      title: 'Locales',
      subtitle: 'Sucursales y multi-local',
      color: const Color(0xFF0EA5E9),
      screenBuilder: () => const LocalesScreen(),
    ));
  }

  // ── Departamentos ── (requiere plan)
  if (Permissions.canManageLocales(role) && flags.departamentos) {
    items.add(_QuickAccessItem(
      icon: Icons.business_center_rounded,
      title: 'Departamentos',
      subtitle: 'Organización interna del negocio',
      color: const Color(0xFF6366F1),
      screenBuilder: () => const DepartamentosScreen(),
    ));
  }

  // ── Telegram ── (requiere plan)
  if (Permissions.canManageTelegram(role) && flags.telegram) {
    items.add(_QuickAccessItem(
      icon: Icons.telegram,
      title: 'Bot de Telegram',
      subtitle: 'Notificaciones al móvil',
      color: const Color(0xFF0EA5E9),
      screenBuilder: () => const TelegramConfigScreen(),
    ));
  }

  // ── Menú completo ── (siempre, si no es rol employees-only)
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
