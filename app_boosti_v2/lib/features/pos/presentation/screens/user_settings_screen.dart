import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../presentation/providers/usuario_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/themes/theme_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/admin_validation_dialog.dart';
import '../widgets/appbar.dart';
import '../widgets/cambiar_pin_dialog.dart';
import 'login_screen.dart';

class UserSettingsScreen extends ConsumerStatefulWidget {
  final UsuarioEntity usuarioLogueado;

  const UserSettingsScreen({super.key, required this.usuarioLogueado});

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
    _nombreController.text = widget.usuarioLogueado.nombre;
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

  Future<void> _cambiarNombre() async {
    final nuevoNombre = _nombreController.text.trim();
    if (nuevoNombre.isEmpty || nuevoNombre == widget.usuarioLogueado.nombre) {
      setState(() => _editandoNombre = false);
      return;
    }

    setState(() => _guardandoNombre = true);

    try {
      widget.usuarioLogueado.nombre = nuevoNombre;
      await _isarService.guardarUsuario(widget.usuarioLogueado);

      if (!mounted) return;
      ref.read(usuarioActualProvider.notifier).setUsuario(widget.usuarioLogueado);

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

  Future<void> _cambiarPin() async {
    final esAdmin = widget.usuarioLogueado.rol == 'admin';

    if (esAdmin) {
      await showDialog(
        context: context,
        builder: (context) => AdminPinChangeDialog(
          admin: widget.usuarioLogueado,
          isarService: _isarService,
        ),
      );
    } else {
      await showDialog(
        context: context,
        builder: (context) => AdminValidationDialog(
          onSuccess: () {
            showDialog(
              context: context,
              builder: (context) => CashierPinChangeDialog(
                cajero: widget.usuarioLogueado,
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
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
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      if (!mounted) return;

      ref.read(usuarioActualProvider.notifier).clearUsuario();

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Widget para tarjetas con glassmorphism
  Widget _buildGlassCard({
    required Widget child,
    required bool isDark,
    double? elevation,
    VoidCallback? onTap,
  }) {
    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: elevation ?? 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1A1A1A).withValues(alpha: 0.65)
                    : Colors.white.withValues(alpha: 0.70),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  // Widget para sección con título e ícono
  Widget _buildSectionHeader(
    String title,
    IconData icon,
    ThemeData theme,
    bool isMobile,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: isMobile ? 20 : 26,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isMobile ? 16 : 20,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.5,
            ),
          ),
          Expanded(
            child: Container(
              height: 1.5,
              margin: const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    theme.dividerColor.withValues(alpha: 0.3),
                    theme.dividerColor.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final colorPrimary = const Color(0xFF8B5CF6);
    final theme = Theme.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double maxWidth = isMobile ? double.infinity : (isTablet ? 900 : 1200);
    final double paddingHorizontal = isMobile ? 16 : (isTablet ? 60 : 80);
    final double paddingVertical = isMobile ? 16 : (isTablet ? 36 : 48);
    final double avatarRadius = isMobile ? 32 : (isTablet ? 56 : 72);
    final double fontSizeTitle = isMobile ? 18 : (isTablet ? 26 : 32);
    final double fontSizeBody = isMobile ? 14 : (isTablet ? 17 : 20);
    final double fontSizeSubtitle = isMobile ? 12 : (isTablet ? 15 : 18);
    final double cardPadding = isMobile ? 16 : (isTablet ? 24 : 32);
    final double sectionSpacing = isMobile ? 24 : (isTablet ? 36 : 48);
    final double iconSize = isMobile ? 24 : (isTablet ? 28 : 32);
    final double switchScale = isMobile ? 1.0 : (isTablet ? 1.2 : 1.4);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        title: 'Ajustes de Usuario',
        centerTitle: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: paddingHorizontal,
              vertical: paddingVertical,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ========== ENCABEZADO DE PERFIL (GLASS) ==========
                _buildGlassCard(
                  isDark: isDark,
                  elevation: 20,
                  child: Padding(
                    padding: EdgeInsets.all(cardPadding),
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                colorPrimary,
                                colorPrimary.withValues(alpha: 0.7),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withValues(alpha: 0.4),
                                blurRadius: 24,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: avatarRadius,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              widget.usuarioLogueado.nombre.isNotEmpty
                                  ? widget.usuarioLogueado.nombre[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: avatarRadius * 0.9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.usuarioLogueado.nombre,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: fontSizeTitle,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: widget.usuarioLogueado.rol == 'admin'
                                          ? const Color(0xFF3B82F6).withValues(alpha: 0.15)
                                          : const Color(0xFF10B981).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      widget.usuarioLogueado.rol.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        fontWeight: FontWeight.bold,
                                        color: widget.usuarioLogueado.rol == 'admin'
                                            ? const Color(0xFF3B82F6)
                                            : const Color(0xFF10B981),
                                      ),
                                    ),
                                  ),
                                  if (widget.usuarioLogueado.cajaAsignada.isNotEmpty) ...[
                                    const SizedBox(width: 12),
                                    Text(
                                      '• ${widget.usuarioLogueado.cajaAsignada}',
                                      style: TextStyle(
                                        fontSize: isMobile ? 12 : 14,
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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

                SizedBox(height: sectionSpacing),

                // ========== SECCIÓN: INFORMACIÓN PERSONAL ==========
                _buildSectionHeader(
                  'Información Personal',
                  Icons.person_outline_rounded,
                  theme,
                  isMobile,
                ),
                const SizedBox(height: 12),

                // Card de nombre (glass + hover)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A1A).withValues(alpha: 0.65)
                                : Colors.white.withValues(alpha: 0.70),
                          ),
                          child: _editandoNombre
                              ? Padding(
                                  padding: EdgeInsets.all(cardPadding),
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: _nombreController,
                                        autofocus: true,
                                        style: TextStyle(
                                          fontSize: fontSizeBody,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        decoration: InputDecoration(
                                          labelText: 'Nuevo nombre',
                                          labelStyle: TextStyle(
                                            fontSize: fontSizeBody,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide(
                                              color: isDark
                                                  ? Colors.white.withValues(alpha: 0.2)
                                                  : Colors.black.withValues(alpha: 0.1),
                                            ),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.person_outline_rounded,
                                            size: iconSize,
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                        onSubmitted: (_) => _cambiarNombre(),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              setState(() {
                                                _editandoNombre = false;
                                                _nombreController.text = widget.usuarioLogueado.nombre;
                                              });
                                            },
                                            child: Text(
                                              'Cancelar',
                                              style: TextStyle(
                                                fontSize: fontSizeBody,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          ElevatedButton(
                                            onPressed: _guardandoNombre ? null : _cambiarNombre,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF10B981),
                                              foregroundColor: Colors.white,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: isMobile ? 20 : 32,
                                                vertical: isMobile ? 12 : 16,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: _guardandoNombre
                                                ? const SizedBox(
                                                    width: 28,
                                                    height: 28,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(
                                                    'Guardar',
                                                    style: TextStyle(
                                                      fontSize: fontSizeBody,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              : ListTile(
                                  contentPadding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: 8),
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.person_outline_rounded,
                                      color: const Color(0xFF3B82F6),
                                      size: iconSize,
                                    ),
                                  ),
                                  title: Text(
                                    'Nombre de usuario',
                                    style: TextStyle(
                                      fontSize: fontSizeBody,
                                      fontWeight: FontWeight.w500,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  subtitle: Text(
                                    widget.usuarioLogueado.nombre,
                                    style: TextStyle(
                                      fontSize: fontSizeSubtitle,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.edit_rounded,
                                      color: const Color(0xFF3B82F6),
                                      size: iconSize,
                                    ),
                                    onPressed: () => setState(() => _editandoNombre = true),
                                  ),
                                  onTap: () => setState(() => _editandoNombre = true),
                                  dense: false,
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Card de cambiar PIN (glass + hover)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A1A).withValues(alpha: 0.65)
                                : Colors.white.withValues(alpha: 0.70),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0EA5E9).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock_reset_rounded,
                                color: const Color(0xFF0EA5E9),
                                size: iconSize,
                              ),
                            ),
                            title: Text(
                              'Cambiar PIN de acceso',
                              style: TextStyle(
                                fontSize: fontSizeBody,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            subtitle: Text(
                              'Actualizar tu PIN de ${widget.usuarioLogueado.rol}',
                              style: TextStyle(
                                fontSize: fontSizeSubtitle,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: iconSize * 0.6,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            onTap: _cambiarPin,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ========== TEMA OSCURO (GLASS) ==========
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFFF59E0B).withValues(alpha: 0.2)
                          : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.08),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1A1A1A).withValues(alpha: 0.65)
                              : Colors.white.withValues(alpha: 0.70),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: 10),
                          child: Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                transform: isDark
                                    ? (Matrix4.identity()..rotateZ(0.2))
                                    : Matrix4.identity(),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  transitionBuilder: (child, animation) {
                                    return ScaleTransition(
                                      scale: animation,
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                    key: ValueKey(isDark),
                                    color: const Color(0xFFF59E0B),
                                    size: iconSize,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tema oscuro',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: fontSizeBody,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 400),
                                      switchInCurve: Curves.easeOutCubic,
                                      switchOutCurve: Curves.easeInCubic,
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, -0.2),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        isDark ? 'Activado' : 'Desactivado',
                                        key: ValueKey(isDark),
                                        style: TextStyle(
                                          fontSize: fontSizeSubtitle,
                                          fontWeight: FontWeight.w500,
                                          color: isDark
                                              ? const Color(0xFFF59E0B)
                                              : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Transform.scale(
                                scale: switchScale,
                                child: Switch(
                                  value: isDark,
                                  onChanged: (value) {
                                    _themeAnimationController.forward(from: 0.0);
                                    ref.read(themeProvider.notifier).setTheme(
                                      value ? ThemeMode.dark : ThemeMode.light,
                                    );
                                    Future.delayed(const Duration(milliseconds: 500), () {
                                      _themeAnimationController.reverse();
                                    });
                                  },
                                  activeThumbColor: const Color(0xFFF59E0B),
                                  activeTrackColor: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                                  inactiveThumbColor: Colors.grey.shade400,
                                  inactiveTrackColor: Colors.grey.shade300,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: sectionSpacing),

                // ========== SECCIÓN: ACCIONES ==========
                _buildSectionHeader(
                  'Acciones',
                  Icons.settings_rounded,
                  theme,
                  isMobile,
                ),
                const SizedBox(height: 12),

                // Card de cerrar sesión (glass + hover)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.3),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.4)
                              : Colors.black.withValues(alpha: 0.08),
                          blurRadius: 16,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1A1A1A).withValues(alpha: 0.65)
                                : Colors.white.withValues(alpha: 0.70),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.logout_rounded,
                                color: const Color(0xFFEF4444),
                                size: iconSize,
                              ),
                            ),
                            title: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              'Salir de la aplicación',
                              style: TextStyle(
                                fontSize: fontSizeSubtitle,
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            trailing: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: iconSize * 0.6,
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                            onTap: _cerrarSesion,
                          ),
                        ),
                      ),
                    ),
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