import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/Local/entities/isar_service.dart';
import '../../data/Local/entities/usuario_entity.dart';
import '../../presentation/providers/usuario_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/responsive_helper.dart';
import '../widgets/admin_validation_dialog.dart';
import '../widgets/cambiar_pin_dialog.dart';
import 'login_screen.dart';

class UserSettingsScreen extends ConsumerStatefulWidget {
  final UsuarioEntity usuarioLogueado;

  const UserSettingsScreen({super.key, required this.usuarioLogueado});

  @override
  ConsumerState<UserSettingsScreen> createState() => _UserSettingsScreenState();
}

class _UserSettingsScreenState extends ConsumerState<UserSettingsScreen> {
  final IsarService _isarService = IsarService();
  final TextEditingController _nombreController = TextEditingController();
  bool _editandoNombre = false;
  bool _guardandoNombre = false;

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.usuarioLogueado.nombre;
  }

  @override
  void dispose() {
    _nombreController.dispose();
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
      ref.read(usuarioActualProvider.notifier).setUsuario(widget.usuarioLogueado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Nombre actualizado correctamente'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
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
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authProvider.notifier).logout();
      ref.read(usuarioActualProvider.notifier).clearUsuario();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    final color = const Color(0xFF8B5CF6);
    final theme = Theme.of(context);

    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    // 🔥 Tamaños adaptativos - AHORA MÁS GRANDES
    final double maxWidth = isMobile
        ? double.infinity
        : (isTablet ? 900 : 1200); // Más ancho

    final double paddingHorizontal = isMobile
        ? 16
        : (isTablet ? 60 : 80); // Más padding lateral

    final double paddingVertical = isMobile
        ? 16
        : (isTablet ? 36 : 48); // Más padding vertical

    final double avatarRadius = isMobile
        ? 32
        : (isTablet ? 56 : 72); // Avatar más grande

    final double fontSizeTitle = isMobile
        ? 18
        : (isTablet ? 26 : 32); // Títulos más grandes

    final double fontSizeBody = isMobile
        ? 14
        : (isTablet ? 17 : 20); // Texto corporal más grande

    final double fontSizeSubtitle = isMobile
        ? 12
        : (isTablet ? 15 : 18); // Subtítulos más grandes

    final double cardPadding = isMobile
        ? 16
        : (isTablet ? 24 : 32); // Más padding en tarjetas

    final double sectionSpacing = isMobile
        ? 24
        : (isTablet ? 36 : 48); // Más separación entre secciones

    final double iconSize = isMobile ? 24 : (isTablet ? 28 : 32);
    final double switchScale = isMobile ? 1.0 : (isTablet ? 1.2 : 1.4);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Ajustes de Usuario',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ],
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
                // ========== ENCABEZADO DE PERFIL ==========
                Container(
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.05),
                        color.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              color,
                              color.withValues(alpha: 0.7),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.3),
                              blurRadius: 20,
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
                                color: theme.textTheme.bodyLarge?.color,
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
                                      color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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

                SizedBox(height: sectionSpacing),

                // ========== SECCIÓN: INFORMACIÓN PERSONAL ==========
                _buildSectionHeader(
                  'Información Personal',
                  Icons.person_outline_rounded,
                  theme,
                  isMobile,
                  fontSizeTitle,
                ),
                const SizedBox(height: 12),

                // ---- Cambiar nombre ----
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  color: theme.cardTheme.color,
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
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Nuevo nombre',
                                  labelStyle: TextStyle(
                                    fontSize: fontSizeBody,
                                    color: theme.textTheme.bodyMedium?.color,
                                  ),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: Icon(
                                    Icons.person_outline_rounded,
                                    size: iconSize,
                                    color: theme.textTheme.bodyMedium?.color,
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
                                        color: theme.textTheme.bodyMedium?.color,
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
                      : MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: ListTile(
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
                                color: theme.textTheme.bodyLarge?.color,
                              ),
                            ),
                            subtitle: Text(
                              widget.usuarioLogueado.nombre,
                              style: TextStyle(
                                fontSize: fontSizeSubtitle,
                                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
                const SizedBox(height: 12),

                // ---- Cambiar PIN ----
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  color: theme.cardTheme.color,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
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
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      subtitle: Text(
                        'Actualizar tu PIN de ${widget.usuarioLogueado.rol}',
                        style: TextStyle(
                          fontSize: fontSizeSubtitle,
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: iconSize * 0.6,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      ),
                      onTap: _cambiarPin,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // ---- Tema oscuro ----
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  color: theme.cardTheme.color,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
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
                                  color: theme.textTheme.bodyLarge?.color,
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  isDark ? 'Activado' : 'Desactivado',
                                  key: ValueKey(isDark),
                                  style: TextStyle(
                                    fontSize: fontSizeSubtitle,
                                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
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
                              ref.read(themeProvider.notifier).setTheme(
                                value ? ThemeMode.dark : ThemeMode.light,
                              );
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

                SizedBox(height: sectionSpacing),

                // ========== SECCIÓN: ACCIONES ==========
                _buildSectionHeader(
                  'Acciones',
                  Icons.settings_rounded,
                  theme,
                  isMobile,
                  fontSizeTitle,
                ),
                const SizedBox(height: 12),

                // ---- Cerrar sesión ----
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: theme.dividerColor.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  color: theme.cardTheme.color,
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
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
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        ),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: iconSize * 0.6,
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
                      ),
                      onTap: _cerrarSesion,
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

  Widget _buildSectionHeader(
  String title,
  IconData icon,
  ThemeData theme,
  bool isMobile,
  double fontSizeTitle,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Row(
      children: [
        Icon(
          icon,
          size: isMobile ? 20 : 28,
          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 16 : 22,
            color: theme.textTheme.bodyMedium?.color,
            letterSpacing: 0.5,
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            margin: const EdgeInsets.only(left: 20),
            color: theme.dividerColor.withValues(alpha: 0.2),
          ),
        ),
      ],
    ),
  );
}
}