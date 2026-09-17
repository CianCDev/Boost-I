// lib/features/pos/presentation/screens/telegram/telegram_config_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/security/secure_credentials.dart';
import '../../../data/Local/entities/log_entity.dart';
import '../../../data/Local/entities/telegram_config_entity.dart';
import '../../../domain/permissions/roles.dart';
import '../../providers/isar_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/usuario_provider.dart';
import '../../services/telegram/telegram_service.dart';
import '../../utils/input_decoration_helper.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/admin_validation_dialog.dart';
import '../../widgets/appbar.dart';
import '../../widgets/common/dialog_header.dart';
import '../../widgets/common/glass_dialog.dart';

class TelegramConfigScreen extends ConsumerStatefulWidget {
  const TelegramConfigScreen({super.key});

  @override
  ConsumerState<TelegramConfigScreen> createState() =>
      _TelegramConfigScreenState();
}

/// Estados de la pantalla según los chequeos previos.
enum _ScreenState { checking, unauthorized, loading, ready }

class _TelegramConfigScreenState extends ConsumerState<TelegramConfigScreen> {
  // Paleta
  static const _colorPrimary = Color(0xFF10B981);
  static const _colorDanger = Color(0xFFEF4444);
  static const _colorWarning = Color(0xFFF59E0B);

  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _botTokenController;
  late final TextEditingController _chatIdController;
  late final TextEditingController _chatNameController;

  _ScreenState _screenState = _ScreenState.checking;
  UserRole? _userRole;

  bool _enabled = false;
  bool _notificarStockBajo = true;
  bool _notificarVentas = false;
  bool _notificarPedidos = false;
  bool _obscureToken = true;

  List<String> _comandosPermitidos = ['/ventas', '/stock', '/ayuda'];
  static const List<String> _comandosDisponibles = [
    '/ventas',
    '/stock',
    '/pedidos',
    '/resumen',
    '/ayuda',
  ];

  /// Copia de la config persistida en Isar, para detectar cambios sin guardar.
  TelegramConfigEntity? _configGuardada;

  bool _isSaving = false;
  bool _isTesting = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _botTokenController = TextEditingController();
    _chatIdController = TextEditingController();
    _chatNameController = TextEditingController();
    _inicializarPantalla();
  }

  @override
  void dispose() {
    _botTokenController.dispose();
    _chatIdController.dispose();
    _chatNameController.dispose();
    super.dispose();
  }

  // ============================================================
  // INICIALIZACIÓN (rol + carga)
  // ============================================================

  Future<void> _inicializarPantalla() async {
    final usuario = ref.read(usuarioActualProvider);

    // 1) Verificar que hay usuario logueado.
    if (usuario == null) {
      setState(() => _screenState = _ScreenState.unauthorized);
      return;
    }

    // 2) Verificar rol permitido.
    final role = UserRole.fromString(usuario.rol);
    if (role != UserRole.admin && role != UserRole.supervisor) {
      setState(() {
        _userRole = role;
        _screenState = _ScreenState.unauthorized;
      });
      return;
    }

    _userRole = role;
    setState(() => _screenState = _ScreenState.loading);

    // 3) Cargar config existente.
    await _cargarConfiguracion();
  }

  Future<void> _cargarConfiguracion() async {
    try {
      final usuario = ref.read(usuarioActualProvider);
      if (usuario == null) {
        setState(() => _screenState = _ScreenState.unauthorized);
        return;
      }

      final isar = ref.read(isarServiceProvider);
      final config = await isar.obtenerTelegramConfigPorUsuario(usuario.id);

      if (!mounted) return;

      if (config != null) {
        _configGuardada = config;
        _botTokenController.text = config.botToken;
        _chatIdController.text = config.chatId;
        _chatNameController.text = config.nombreChat ?? '';
        _enabled = config.enabled;
        _notificarStockBajo = config.notificarStockBajo;
        _notificarVentas = config.notificarVentas;
        _notificarPedidos = config.notificarPedidos;
        _comandosPermitidos = List.from(config.comandosPermitidos);
      }

      setState(() => _screenState = _ScreenState.ready);
    } catch (e) {
      if (!mounted) return;
      setState(() => _screenState = _ScreenState.ready);
      _showSnack('Error al cargar configuración: $e', isError: true);
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool get _hayCambiosSinGuardar {
    final c = _configGuardada;
    if (c == null) {
      return _botTokenController.text.trim().isNotEmpty ||
          _chatIdController.text.trim().isNotEmpty ||
          _enabled;
    }
    return _botTokenController.text.trim() != c.botToken ||
        _chatIdController.text.trim() != c.chatId ||
        _chatNameController.text.trim() != (c.nombreChat ?? '') ||
        _enabled != c.enabled ||
        _notificarStockBajo != c.notificarStockBajo ||
        _notificarVentas != c.notificarVentas ||
        _notificarPedidos != c.notificarPedidos;
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? _colorDanger : _colorPrimary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ============================================================
  // GUARDAR CON VALIDACIÓN ADMIN
  // ============================================================

  Future<void> _guardarConfiguracion() async {
    // 1. Validar formulario.
    if (!(_formKey.currentState?.validate() ?? false)) {
      _showSnack(
        'Revisa los campos marcados en rojo.',
        isError: true,
      );
      return;
    }

    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null) {
      _showSnack('Usuario no autenticado.', isError: true);
      return;
    }

    final botToken = _botTokenController.text.trim();
    final chatId = _chatIdController.text.trim();

    // 2. Verificar el token con `getMe` si el bot está habilitado.
    if (_enabled) {
      setState(() => _isTesting = true);
      final verification =
          await TelegramService().verificarToken(botToken);
      if (!mounted) return;
      setState(() => _isTesting = false);

      if (!verification.ok) {
        _showSnack(
          '❌ Token inválido: ${verification.error ?? "desconocido"}',
          isError: true,
        );
        return;
      }

      // 3. Validación admin obligatoria para guardar.
      final ok = await AdminValidationDialog.show(
        context,
        ref,
        allowedRoles: const [UserRole.admin],
      );

      if (ok != true) {
        _showSnack('Autorización cancelada.', isError: true);
        return;
      }

      if (!mounted) return;
    }

    setState(() => _isSaving = true);

    try {
      // 4. Construir entidad.
      final config = TelegramConfigEntity()
        ..usuarioId = usuario.id
        ..botToken = botToken
        ..chatId = chatId
        ..nombreChat = _chatNameController.text.trim().isEmpty
            ? null
            : _chatNameController.text.trim()
        ..enabled = _enabled
        ..notificarStockBajo = _notificarStockBajo
        ..notificarVentas = _notificarVentas
        ..notificarPedidos = _notificarPedidos
        ..comandosPermitidos = List.from(_comandosPermitidos)
        ..sincronizado = false;

      // Si ya existía, mantenemos su id (Isar) y supabaseId.
      final previo = _configGuardada;
      if (previo != null) {
        config.id = previo.id;
        config.supabaseId = previo.supabaseId;
      }

      // 5. Guardar en Isar.
      final isar = ref.read(isarServiceProvider);
      await isar.guardarTelegramConfig(config);
      _configGuardada = config;

      // 6. Sincronizar con Supabase.
      try {
        final sync = ref.read(syncServiceProvider);
        await sync.sincronizarTelegramConfigPendientes();
      } catch (e) {
        debugPrint('⚠️ Sync Supabase falló (guardado local OK): $e');
      }

      // 7. Log de auditoría.
      await isar.guardarLog(
        LogEntity()
          ..accion = 'TELEGRAM_CONFIG_UPDATE'
          ..usuarioNombre = usuario.nombre
          ..usuarioRol = usuario.rol
          ..detalles = 'enabled=$_enabled, chatId=$chatId, '
              'comandos=${_comandosPermitidos.length}'
          ..fecha = DateTime.now()
          ..sincronizado = false,
      );

      // 8. Reiniciar bot.
      if (_enabled) {
        try {
          await TelegramService().inicializar(usuarioId: usuario.id);
        } catch (e) {
          debugPrint('⚠️ Error al reiniciar bot: $e');
        }
      } else {
        TelegramService().dispose();
      }

      if (!mounted) return;
      _showSnack('✅ Configuración guardada correctamente');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnack('❌ Error al guardar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ============================================================
  // PROBAR CONEXIÓN
  // ============================================================

  Future<void> _probarConexion() async {
    final botToken = _botTokenController.text.trim();
    final chatId = _chatIdController.text.trim();

    if (botToken.isEmpty || chatId.isEmpty) {
      _showSnack('Completa el token y chat ID primero.', isError: true);
      return;
    }

    // Avisar si hay cambios sin guardar (la prueba usa los valores actuales
    // del formulario, no los persistidos).
    if (_hayCambiosSinGuardar) {
      final continuar = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Cambios sin guardar'),
          content: const Text(
            'Estás probando con valores no guardados. '
            'Si funciona y cierras sin guardar, el bot seguirá usando la '
            'configuración anterior.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorPrimary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Probar igual'),
            ),
          ],
        ),
      );
      if (continuar != true) return;
    }

    setState(() => _isTesting = true);

    try {
      final service = TelegramService();

      // 1. Verificar token con getMe.
      final verification = await service.verificarToken(botToken);
      if (!verification.ok) {
        if (!mounted) return;
        _showSnack(
          '❌ Token inválido: ${verification.error ?? "desconocido"}',
          isError: true,
        );
        return;
      }

      // 2. Enviar mensaje de prueba.
      final mensaje = '🔔 <b>Prueba de conexión</b>\n'
          'Bot: @${verification.botUsername ?? "desconocido"}\n'
          'Comandos: ${_comandosPermitidos.join(", ")}\n'
          '📅 ${DateTime.now().toLocal().toString().substring(0, 19)}';

      final enviado = await service.enviarMensajePrueba(
        mensaje,
        botToken,
        chatId,
      );

      if (!mounted) return;
      _showSnack(
        enviado
            ? '✅ Bot verificado y mensaje enviado a @${verification.botUsername}'
            : '⚠️ Token válido pero no se pudo enviar al chat. '
                'Verifica que hayas iniciado el bot y el chat ID.',
        isError: !enviado,
      );
    } catch (e) {
      if (!mounted) return;
      _showSnack('❌ Error de conexión: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    switch (_screenState) {
      case _ScreenState.checking:
      case _ScreenState.loading:
        return _buildLoadingScaffold();
      case _ScreenState.unauthorized:
        return _buildUnauthorizedScaffold();
      case _ScreenState.ready:
        return _buildReadyScaffold();
    }
  }

  Widget _buildLoadingScaffold() {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: _colorPrimary),
      ),
    );
  }

  Widget _buildUnauthorizedScaffold() {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Configuración de Telegram',
        showBackButton: true,
        gradient: const LinearGradient(
          colors: [Color(0xFF64748B), Color(0xFF475569)],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 72,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 20),
              Text(
                'Acceso restringido',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _userRole == null
                    ? 'Debes iniciar sesión para acceder.'
                    : 'Solo administradores y supervisores pueden '
                        'configurar el bot de Telegram.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadyScaffold() {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    final gradient = isDark
        ? LinearGradient(
            colors: [
              _colorPrimary.withValues(alpha: 0.8),
              const Color(0xFF059669),
            ],
          )
        : const LinearGradient(
            colors: [_colorPrimary, Color(0xFF059669)],
          );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: CustomAppBar(
        title: 'Configuración de Telegram',
        showBackButton: true,
        gradient: gradient,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: _mostrarAyuda,
            tooltip: 'Ayuda',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = isMobile
              ? constraints.maxWidth * 0.95
              : 620.0.clamp(0.0, constraints.maxWidth * 0.9);

          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 24),
              physics: const BouncingScrollPhysics(),
              child: Container(
                width: maxWidth,
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildCredentialsSection(colorScheme, isDark, isMobile),
                        const SizedBox(height: 20),
                        _buildNotificationsSection(colorScheme, isMobile),
                        const SizedBox(height: 20),
                        _buildCommandsSection(colorScheme, isMobile),
                        const SizedBox(height: 16),
                        if (_enabled) ...[
                          _buildTestButton(isMobile),
                          const SizedBox(height: 12),
                        ],
                        _buildSaveButton(isMobile),
                      ],
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

  // ============================================================
  // SECCIONES UI
  // ============================================================

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _colorPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _colorPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _colorPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.telegram, color: _colorPrimary, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bot de Telegram',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Configura el bot para notificaciones y comandos',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: (v) => setState(() => _enabled = v),
            activeThumbColor: _colorPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsSection(
    ColorScheme colorScheme,
    bool isDark,
    bool isMobile,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.vpn_key_rounded,
                    color: _colorPrimary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Credenciales del Bot',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Token ──
            TextFormField(
              controller: _botTokenController,
              enabled: _enabled,
              obscureText: _obscureToken,
              enableSuggestions: false,
              autocorrect: false,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecorationHelper.build(
                context: context,
                label: 'Token del Bot *',
                prefixIcon: Icons.key,
                isDark: isDark,
              ).copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureToken
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  tooltip: _obscureToken ? 'Mostrar' : 'Ocultar',
                  onPressed: () =>
                      setState(() => _obscureToken = !_obscureToken),
                ),
              ),
              validator: (v) {
                if (!_enabled) return null;
                if (v == null || v.trim().isEmpty) {
                  return 'Requerido si el bot está habilitado';
                }
                if (!SecureCredentials.isValidTelegramToken(v)) {
                  return 'Formato inválido. Ej: 1234567890:ABC-DEF...';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Chat ID ──
            TextFormField(
              controller: _chatIdController,
              enabled: _enabled,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecorationHelper.build(
                context: context,
                label: 'Chat ID *',
                prefixIcon: Icons.chat,
                isDark: isDark,
                hintText: 'Ej: 123456789 o @mi_canal',
              ),
              validator: (v) {
                if (!_enabled) return null;
                if (v == null || v.trim().isEmpty) {
                  return 'Requerido si el bot está habilitado';
                }
                if (!SecureCredentials.isValidTelegramChatId(v)) {
                  return 'Usa un ID numérico o @username válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Nombre (opcional) ──
            TextFormField(
              controller: _chatNameController,
              enabled: _enabled,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecorationHelper.build(
                context: context,
                label: 'Nombre del Chat (opcional)',
                prefixIcon: Icons.label,
                isDark: isDark,
              ),
            ),
            const SizedBox(height: 12),

            // ── Info ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Para obtener el token, habla con @BotFather en Telegram. '
                      'El chat ID lo consigues con /start una vez configurado.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(ColorScheme colorScheme, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.notifications_active_rounded,
                    color: _colorPrimary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Notificaciones Automáticas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Eventos que quieres recibir por Telegram',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            _switchTile(
              value: _notificarStockBajo,
              onChanged: (v) => setState(() => _notificarStockBajo = v),
              title: 'Stock bajo',
              subtitle: 'Cuando un producto baja del stock mínimo',
              icon: Icons.warning_amber_rounded,
            ),
            _switchTile(
              value: _notificarVentas,
              onChanged: (v) => setState(() => _notificarVentas = v),
              title: 'Resumen diario de ventas',
              subtitle: 'Al final del día',
              icon: Icons.receipt_long_rounded,
            ),
            _switchTile(
              value: _notificarPedidos,
              onChanged: (v) => setState(() => _notificarPedidos = v),
              title: 'Nuevos pedidos a proveedores',
              subtitle: 'Al crear un pedido',
              icon: Icons.shopping_cart_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _switchTile({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      secondary: Icon(icon, color: _colorPrimary, size: 20),
      value: value,
      onChanged: _enabled ? onChanged : null,
      activeThumbColor: _colorPrimary,
    );
  }

  Widget _buildCommandsSection(ColorScheme colorScheme, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.code_rounded, color: _colorPrimary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Comandos Permitidos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Comandos que el bot aceptará',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _comandosDisponibles.map((comando) {
                final isSelected = _comandosPermitidos.contains(comando);
                return FilterChip(
                  label: Text(comando),
                  selected: isSelected,
                  onSelected: _enabled
                      ? (selected) {
                          setState(() {
                            if (selected) {
                              _comandosPermitidos.add(comando);
                            } else {
                              _comandosPermitidos.remove(comando);
                            }
                          });
                        }
                      : null,
                  selectedColor: _colorPrimary.withValues(alpha: 0.2),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  checkmarkColor: _colorPrimary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? _colorPrimary
                        : colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            if (_comandosPermitidos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _colorPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _colorPrimary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: _colorPrimary, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Activos: ${_comandosPermitidos.join(", ")}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _colorPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton(bool isMobile) {
    return SizedBox(
      height: isMobile ? 48 : 52,
      child: OutlinedButton.icon(
        onPressed: (_isSaving || _isTesting) ? null : _probarConexion,
        icon: _isTesting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _colorPrimary,
                ),
              )
            : Icon(Icons.telegram,
                color: _colorPrimary, size: isMobile ? 18 : 22),
        label: Text(_isTesting ? 'Verificando...' : 'Probar conexión'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: _colorPrimary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isMobile) {
    return SizedBox(
      height: isMobile ? 48 : 52,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _guardarConfiguracion,
        style: ElevatedButton.styleFrom(
          backgroundColor: _colorPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded),
        label: Text(
          _isSaving ? 'Guardando...' : 'Guardar configuración',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isMobile ? 14 : 16,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AYUDA
  // ============================================================

  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (_) => GlassDialog(
        accentColor: _colorPrimary,
        maxWidth: 520,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DialogHeader(
                icon: Icons.help_outline_rounded,
                title: 'Configurar Bot de Telegram',
                subtitle: 'Sigue estos pasos',
                color: _colorPrimary,
              ),
              const SizedBox(height: 16),
              const _HelpStep(
                index: 1,
                text: 'Crea un bot en Telegram hablando con @BotFather.',
              ),
              const _HelpStep(
                index: 2,
                text: 'Copia el token que te proporcione @BotFather.',
              ),
              const _HelpStep(
                index: 3,
                text: 'Inicia una conversación con tu bot y envía /start.',
              ),
              const _HelpStep(
                index: 4,
                text:
                    'Obtén tu chat ID con @userinfobot o con la API getUpdates.',
              ),
              const _HelpStep(
                index: 5,
                text:
                    'Configura notificaciones y comandos. Guarda con PIN de admin.',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _colorWarning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _colorWarning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded,
                        color: _colorWarning, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cada usuario tiene su propio bot. '
                        'El token se guarda asociado a tu cuenta.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _colorPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Entendido',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// STEP DE AYUDA (widget interno)
// ================================================================

class _HelpStep extends StatelessWidget {
  final int index;
  final String text;

  const _HelpStep({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF10B981),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}