// lib/features/pos/presentation/screens/user_settings_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../providers/auth_provider.dart';
import '../providers/business_mode_provider.dart';
import '../providers/themes/theme_provider.dart';
import '../providers/usuario_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/admin_validation_dialog.dart';
import '../widgets/appbar.dart';
import '../widgets/cambiar_pin_dialog.dart';
import 'login_screen.dart';
import 'configuracion_modo_negocio_screen.dart';

class UserSettingsScreen extends ConsumerStatefulWidget {
  /// ⚠️ Deprecado: usar `usuarioActualProvider` internamente.
  @Deprecated('Use usuarioActualProvider instead.')
  final UsuarioEntity? usuarioLogueado;

  const UserSettingsScreen({super.key, this.usuarioLogueado});

  @override
  ConsumerState<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends ConsumerState<UserSettingsScreen>
    with SingleTickerProviderStateMixin {
  final IsarService _isarService = IsarService();
  final TextEditingController _nombreController = TextEditingController();
  bool _editandoNombre = false;
  bool _guardandoNombre = false;
  late AnimationController _themeAnimationController;

  @override
  void initState() {
    super.initState();
    _themeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _themeAnimationController.dispose();
    super.dispose();
  }

  Future<void> _cambiarNombre(UsuarioEntity usuario) async {
    final nuevoNombre = _nombreController.text.trim();
    if (nuevoNombre.isEmpty || nuevoNombre == usuario.nombre) {
      setState(() => _editandoNombre = false);
      return;
    }

    setState(() => _guardandoNombre = true);

    try {
      usuario.nombre = nuevoNombre;
      await _isarService.guardarUsuario(usuario);

      if (!mounted) return;
      ref.read(usuarioActualProvider.notifier).setUsuario(usuario);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Nombre actualizado correctamente'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al actualizar nombre: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _guardandoNombre = false;
          _editandoNombre = false;
        });
      }
    }
  }

  Future<void> _cambiarPin(UsuarioEntity usuario) async {
    final esAdmin = usuario.rol == 'admin';

    if (esAdmin) {
      await showDialog(
        context: context,
        builder: (_) => AdminPinChangeDialog(
          admin: usuario,
          isarService: _isarService,
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (dialogContext) => AdminValidationDialog(
          onSuccess: () {
            showDialog(
              context: dialogContext,
              builder: (_) => CashierPinChangeDialog(
                cajero: usuario,
                isarService: _isarService,
              ),
            );
          },
          onCancel: () {},
        ),
      );
    }
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
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

  // ══════════════════════════════════════════════════════════════════
  // ACCIONES DE MODO DE NEGOCIO
  // ══════════════════════════════════════════════════════════════════

  Future<void> _cambiarModoNegocio(UsuarioEntity usuario) async {
    if (usuario.rol != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Solo los administradores pueden cambiar el modo'),
          backgroundColor: Color(0xFFF59E0B),
        ),
      );
      return;
    }

    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const ConfiguracionModoNegocioScreen(),
      ),
    );

    // Al volver, el provider ya se actualizó solo → la card se refresca.
  }

  // ══════════════════════════════════════════════════════════════════
  // HELPERS DE ESTILO
  // ══════════════════════════════════════════════════════════════════

  /// Fondo con gradiente + blobs animados (coherente con MainPosScreen).
  Widget _buildAnimatedBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: RepaintBoundary(
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? const [Color(0xFF0F172A), Color(0xFF0B1220)]
                    : const [Color(0xFFF7F9FF), Color(0xFFEFF3FB)],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -140,
                  left: -100,
                  child: _StaticBlob(
                    size: 380,
                    color: const Color(0xFF8B5CF6)
                        .withValues(alpha: isDark ? 0.20 : 0.16),
                  ),
                ),
                Positioned(
                  bottom: -180,
                  right: -120,
                  child: _StaticBlob(
                    size: 420,
                    color: const Color(0xFF06B6D4)
                        .withValues(alpha: isDark ? 0.15 : 0.12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Card con glass + hover animado + entrada staggered.
  Widget _buildInteractiveCard({
    required Widget child,
    required bool isDark,
    required int entryIndex,
    VoidCallback? onTap,
    Color accentColor = const Color(0xFF8B5CF6),
    bool enabled = true,
  }) {
    return _StaggeredEntry(
      index: entryIndex,
      child: _HoverCard(
        isDark: isDark,
        onTap: enabled ? onTap : null,
        accentColor: accentColor,
        child: child,
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final usuario =
        ref.watch(usuarioActualProvider) ?? widget.usuarioLogueado;
    final modoActual = ref.watch(businessModeProvider);

    if (usuario == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_nombreController.text.isEmpty) {
      _nombreController.text = usuario.nombre;
    }

    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final esAdmin = usuario.rol == 'admin';

    final double maxWidth =
        isMobile ? double.infinity : (isTablet ? 900 : 1100);
    final double paddingHorizontal = isMobile ? 16 : (isTablet ? 60 : 80);
    final double paddingVertical = isMobile ? 16 : (isTablet ? 36 : 48);
    final double sectionSpacing = isMobile ? 28 : (isTablet ? 36 : 44);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Ajustes',
        centerTitle: false,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: paddingHorizontal,
                    vertical: paddingVertical,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ═══ HEADER DE PERFIL ═══
                      _StaggeredEntry(
                        index: 0,
                        child: _buildProfileHeader(
                          usuario,
                          isDark,
                          isMobile,
                          isTablet,
                        ),
                      ),

                      SizedBox(height: sectionSpacing),

                      // ═══ NEGOCIO (modo de negocio) ═══
                      _StaggeredEntry(
                        index: 1,
                        child: _buildSectionHeader(
                          'Negocio',
                          Icons.storefront_rounded,
                          theme,
                          isMobile,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInteractiveCard(
                        isDark: isDark,
                        entryIndex: 2,
                        onTap: () => _cambiarModoNegocio(usuario),
                        accentColor: modoActual.color,
                        enabled: esAdmin,
                        child: _buildModoNegocioTile(
                          modoActual,
                          isDark,
                          isMobile,
                          esAdmin,
                          theme,
                        ),
                      ),

                      SizedBox(height: sectionSpacing),

                      // ═══ INFORMACIÓN PERSONAL ═══
                      _StaggeredEntry(
                        index: 3,
                        child: _buildSectionHeader(
                          'Cuenta',
                          Icons.person_outline_rounded,
                          theme,
                          isMobile,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildInteractiveCard(
                        isDark: isDark,
                        entryIndex: 4,
                        onTap: () =>
                            setState(() => _editandoNombre = true),
                        accentColor: const Color(0xFF3B82F6),
                        child: _editandoNombre
                            ? _buildNombreEditForm(usuario, isDark, isMobile)
                            : _buildTile(
                                icon: Icons.person_outline_rounded,
                                iconColor: const Color(0xFF3B82F6),
                                title: 'Nombre de usuario',
                                subtitle: usuario.nombre,
                                isDark: isDark,
                                isMobile: isMobile,
                                trailing: Icons.edit_rounded,
                              ),
                      ),
                      const SizedBox(height: 12),

                      _buildInteractiveCard(
                        isDark: isDark,
                        entryIndex: 5,
                        onTap: () => _cambiarPin(usuario),
                        accentColor: const Color(0xFF0EA5E9),
                        child: _buildTile(
                          icon: Icons.lock_reset_rounded,
                          iconColor: const Color(0xFF0EA5E9),
                          title: 'Cambiar PIN de acceso',
                          subtitle: 'Actualizar tu PIN de ${usuario.rol}',
                          isDark: isDark,
                          isMobile: isMobile,
                          trailing: Icons.arrow_forward_ios_rounded,
                        ),
                      ),

                      SizedBox(height: sectionSpacing),

                      // ═══ PERSONALIZACIÓN ═══
                      _StaggeredEntry(
                        index: 6,
                        child: _buildSectionHeader(
                          'Personalización',
                          Icons.palette_outlined,
                          theme,
                          isMobile,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Toggle de tema oscuro
                      _buildInteractiveCard(
                        isDark: isDark,
                        entryIndex: 7,
                        accentColor: const Color(0xFFF59E0B),
                        child: _buildThemeToggle(isDark, isMobile, theme),
                      ),

                      SizedBox(height: sectionSpacing),

                      // ═══ ACCIONES ═══
                      _StaggeredEntry(
                        index: 8,
                        child: _buildSectionHeader(
                          'Acciones',
                          Icons.settings_rounded,
                          theme,
                          isMobile,
                        ),
                      ),
                      const SizedBox(height: 12),

                      _buildInteractiveCard(
                        isDark: isDark,
                        entryIndex: 9,
                        onTap: _cerrarSesion,
                        accentColor: const Color(0xFFEF4444),
                        child: _buildTile(
                          icon: Icons.logout_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: 'Cerrar sesión',
                          subtitle: 'Salir de la aplicación',
                          isDark: isDark,
                          isMobile: isMobile,
                          titleColor: const Color(0xFFEF4444),
                          trailing: Icons.arrow_forward_ios_rounded,
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

  // ══════════════════════════════════════════════════════════════════
  // HEADER DE PERFIL
  // ══════════════════════════════════════════════════════════════════

  Widget _buildProfileHeader(
    UsuarioEntity usuario,
    bool isDark,
    bool isMobile,
    bool isTablet,
  ) {
    final colorPrimary = const Color(0xFF8B5CF6);
    final theme = Theme.of(context);
    final avatarRadius = (isMobile ? 32 : (isTablet ? 48 : 60)).toDouble();
    final fontSizeTitle = (isMobile ? 20 : (isTablet ? 26 : 30)).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 18 : 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorPrimary.withValues(alpha: isDark ? 0.22 : 0.12),
                colorPrimary.withValues(alpha: 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: colorPrimary.withValues(alpha: isDark ? 0.35 : 0.25),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: colorPrimary.withValues(alpha: 0.15),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar con gradiente + ring
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorPrimary,
                      Color.lerp(colorPrimary, Colors.black, 0.3)!,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorPrimary.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  child: Text(
                    usuario.nombre.isNotEmpty
                        ? usuario.nombre[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: avatarRadius * 0.9,
                      fontWeight: FontWeight.w900,
                      color: colorPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      usuario.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: fontSizeTitle,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRolBadge(usuario.rol, isMobile),
                        if (usuario.cajaAsignada.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              '· ${usuario.cajaAsignada}',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 13,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurfaceVariant,
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
        ),
      ),
    );
  }

  Widget _buildRolBadge(String rol, bool isMobile) {
    final color = rol == 'admin'
        ? const Color(0xFF3B82F6)
        : rol == 'supervisor'
            ? const Color(0xFF8B5CF6)
            : const Color(0xFF10B981);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.25),
            color.withValues(alpha: 0.15),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.40), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            rol.toUpperCase(),
            style: TextStyle(
              fontSize: isMobile ? 10 : 11,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TILE GENÉRICO
  // ══════════════════════════════════════════════════════════════════

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required bool isMobile,
    IconData? trailing,
    Color? titleColor,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: 14,
      ),
      child: Row(
        children: [
          // Contenedor del icono con gradiente radial
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  iconColor.withValues(alpha: 0.22),
                  iconColor.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.20),
                width: 1,
              ),
            ),
            child: Icon(icon, color: iconColor, size: isMobile ? 20 : 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? theme.colorScheme.onSurface,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 12.5,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 12),
            Icon(
              trailing,
              size: 18,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // FORMULARIO DE NOMBRE
  // ══════════════════════════════════════════════════════════════════

  Widget _buildNombreEditForm(
    UsuarioEntity usuario,
    bool isDark,
    bool isMobile,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      child: Column(
        children: [
          TextField(
            controller: _nombreController,
            autofocus: true,
            style: TextStyle(
              fontSize: isMobile ? 14 : 15,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              labelText: 'Nuevo nombre',
              labelStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outline_rounded),
            ),
            onSubmitted: (_) => _cambiarNombre(usuario),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _editandoNombre = false;
                    _nombreController.text = usuario.nombre;
                  });
                },
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _guardandoNombre
                    ? null
                    : () => _cambiarNombre(usuario),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _guardandoNombre
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TILE DE MODO DE NEGOCIO
  // ══════════════════════════════════════════════════════════════════

  Widget _buildModoNegocioTile(
    BusinessMode modo,
    bool isDark,
    bool isMobile,
    bool esAdmin,
    ThemeData theme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: 16,
      ),
      child: Row(
        children: [
          // Contenedor del modo con gradiente y color del modo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  modo.color.withValues(alpha: 0.25),
                  modo.color.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: modo.color.withValues(alpha: 0.30),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: modo.color.withValues(alpha: 0.15),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(
              modo.icon,
              color: modo.color,
              size: isMobile ? 22 : 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      modo.label,
                      style: TextStyle(
                        fontSize: isMobile ? 15 : 16,
                        fontWeight: FontWeight.w800,
                        color: modo.color,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (!esAdmin) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.lock_rounded,
                        size: 12,
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.5),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  esAdmin
                      ? '${modo.description} · Toca para cambiar'
                      : '${modo.description} · Solo admin',
                  style: TextStyle(
                    fontSize: isMobile ? 11.5 : 12.5,
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (esAdmin)
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TOGGLE DE TEMA
  // ══════════════════════════════════════════════════════════════════

  Widget _buildThemeToggle(bool isDark, bool isMobile, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 20,
        vertical: 12,
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            transform: isDark
                ? (Matrix4.identity()..rotateZ(0.15))
                : Matrix4.identity(),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFF59E0B).withValues(alpha: 0.25),
                  const Color(0xFFF59E0B).withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                width: 1,
              ),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                key: ValueKey(isDark),
                color: const Color(0xFFF59E0B),
                size: isMobile ? 20 : 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tema oscuro',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 15,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isDark ? 'Activado' : 'Desactivado',
                    key: ValueKey(isDark),
                    style: TextStyle(
                      fontSize: isMobile ? 12 : 12.5,
                      color: isDark
                          ? const Color(0xFFF59E0B)
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isDark ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDark,
            onChanged: (value) {
              _themeAnimationController.forward(from: 0.0);
              ref.read(themeProvider.notifier).setTheme(
                    value ? ThemeMode.dark : ThemeMode.light,
                  );
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) _themeAnimationController.reverse();
              });
            },
            activeThumbColor: const Color(0xFFF59E0B),
            activeTrackColor: const Color(0xFFF59E0B).withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // HEADER DE SECCIÓN CON DIVIDER ANIMADO
  // ══════════════════════════════════════════════════════════════════

  Widget _buildSectionHeader(
    String title,
    IconData icon,
    ThemeData theme,
    bool isMobile,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              size: isMobile ? 14 : 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: isMobile ? 12 : 13,
              color: theme.colorScheme.onSurface,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.40),
                    theme.colorScheme.primary.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════

/// Card con hover animado: escala, glow y borde teñido.
class _HoverCard extends StatefulWidget {
  final Widget child;
  final bool isDark;
  final VoidCallback? onTap;
  final Color accentColor;

  const _HoverCard({
    required this.child,
    required this.isDark,
    this.onTap,
    this.accentColor = const Color(0xFF8B5CF6),
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final clickeable = widget.onTap != null;
    final hoverActivo = _hovered && clickeable;

    final baseColor = widget.isDark
        ? const Color(0xFF1A1A1A).withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.70);

    final hoverColor = widget.isDark
        ? const Color(0xFF23232D).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.92);

    return MouseRegion(
      cursor: clickeable
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: hoverActivo ? 1.005 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hoverActivo
                  ? widget.accentColor.withValues(alpha: 0.45)
                  : (widget.isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.30)),
              width: hoverActivo ? 1.4 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDark
                    ? Colors.black.withValues(alpha: 0.35)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: hoverActivo ? 20 : 14,
                spreadRadius: 1,
                offset: Offset(0, hoverActivo ? 6 : 4),
              ),
              if (hoverActivo)
                BoxShadow(
                  color: widget.accentColor.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Material(
                color: hoverActivo ? hoverColor : baseColor,
                child: InkWell(
                  onTap: widget.onTap,
                  borderRadius: BorderRadius.circular(16),
                  splashColor:
                      widget.accentColor.withValues(alpha: 0.10),
                  highlightColor:
                      widget.accentColor.withValues(alpha: 0.06),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Entry staggered — animación de entrada en cascada.
class _StaggeredEntry extends StatefulWidget {
  final int index;
  final Widget child;

  const _StaggeredEntry({required this.index, required this.child});

  @override
  State<_StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<_StaggeredEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    final curva = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(curva);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.10),
      end: Offset.zero,
    ).animate(curva);

    final delay = Duration(milliseconds: 60 * widget.index);
    Future.delayed(delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Blob estático con blur radial.
class _StaticBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _StaticBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color, color.withValues(alpha: 0)],
            ),
          ),
        ),
      ),
    );
  }
}