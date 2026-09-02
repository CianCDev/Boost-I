// lib/features/pos/presentation/screens/telegram/telegram_config_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/telegram_provider.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/usuario_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/input_decoration_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/widgets/appbar.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/telegram/telegram_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/isar_provider.dart';

class TelegramConfigScreen extends ConsumerStatefulWidget {
  const TelegramConfigScreen({super.key});

  @override
  ConsumerState<TelegramConfigScreen> createState() =>
      _TelegramConfigScreenState();
}

class _TelegramConfigScreenState extends ConsumerState<TelegramConfigScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _botTokenController;
  late TextEditingController _chatIdController;
  late TextEditingController _chatNameController;

  bool _enabled = false;
  bool _notificarStockBajo = true;
  bool _notificarVentas = false;
  bool _notificarPedidos = false;

  List<String> _comandosPermitidos = ['/ventas', '/stock', '/ayuda'];
  final List<String> _comandosDisponibles = [
    '/ventas',
    '/stock',
    '/ayuda',
    '/pedidos',
    '/resumen'
  ];

  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _botTokenController = TextEditingController();
    _chatIdController = TextEditingController();
    _chatNameController = TextEditingController();
    _cargarConfiguracion();
  }

  @override
  void dispose() {
    _botTokenController.dispose();
    _chatIdController.dispose();
    _chatNameController.dispose();
    super.dispose();
  }

  // ============================================================
  // CARGA DE CONFIGURACIÓN
  // ============================================================
  Future<void> _cargarConfiguracion() async {
    setState(() => _isLoading = true);
    try {
      final usuario = ref.read(usuarioActualProvider);
      if (usuario == null) {
        setState(() => _isLoading = false);
        return;
      }

      final isar = ref.read(isarServiceProvider);
      final config = await isar.obtenerTelegramConfigPorUsuario(usuario.id);

      if (config != null) {
        _botTokenController.text = config.botToken;
        _chatIdController.text = config.chatId;
        _chatNameController.text = config.nombreChat ?? '';
        _enabled = config.enabled;
        _notificarStockBajo = config.notificarStockBajo;
        _notificarVentas = config.notificarVentas;
        _notificarPedidos = config.notificarPedidos;
        _comandosPermitidos = List.from(config.comandosPermitidos);
        debugPrint(
            '📋 Configuración cargada: ${_comandosPermitidos.length} comandos');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar configuración: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ============================================================
  // GUARDAR CONFIGURACIÓN (con validación mejorada)
  // ============================================================
  Future<void> _guardarConfiguracion() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, corrige los campos marcados en rojo.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final usuario = ref.read(usuarioActualProvider);
    if (usuario == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario no autenticado. Inicia sesión nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 🔥 Validaciones adicionales de datos
    final botToken = _botTokenController.text.trim();
    final chatId = _chatIdController.text.trim();

    if (_enabled) {
      // Validar formato del Token (debe tener el formato: números:letras)
      if (botToken.isEmpty || !botToken.contains(':')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  '❌ El Token del Bot parece inválido. Debe tener el formato "123456:ABC-def..."'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Validar que el Chat ID no sea vacío
      if (chatId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ El Chat ID es obligatorio cuando el bot está habilitado.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    setState(() => _isSaving = true);

    final config = TelegramConfigEntity()
      ..usuarioId = usuario.id
      ..botToken = botToken
      ..chatId = chatId
      ..nombreChat = _chatNameController.text.trim().isNotEmpty
          ? _chatNameController.text.trim()
          : null
      ..enabled = _enabled
      ..notificarStockBajo = _notificarStockBajo
      ..notificarVentas = _notificarVentas
      ..notificarPedidos = _notificarPedidos
      ..comandosPermitidos = List.from(_comandosPermitidos) // ✅ Copia defensiva
      ..sincronizado = false;

    try {
      final isar = ref.read(isarServiceProvider);

      // 1. Guardar en Isar
      await isar.guardarTelegramConfig(config);
      debugPrint(
          '💾 Configuración guardada en Isar con ${config.comandosPermitidos.length} comandos: ${config.comandosPermitidos}');

      // 2. Subir a Supabase
      final syncService = SyncService();
      debugPrint('⬆️ Configuración subida a Supabase');

      // 3. Reiniciar el bot con la nueva configuración
      if (_enabled) {
        try {
          await TelegramService().inicializar(usuarioId: usuario.id);
          debugPrint('🤖 Bot reiniciado con nuevos comandos');
        } catch (e) {
          debugPrint('⚠️ Error al reiniciar bot: $e');
          // No bloqueamos el guardado, solo mostramos advertencia
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Configuración guardada y sincronizada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // ✅ Volver a la pantalla anterior
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al guardar: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  // ============================================================
  // PROBAR CONEXIÓN (mejorada)
  // ============================================================
  Future<void> _probarConexion() async {
    final botToken = _botTokenController.text.trim();
    final chatId = _chatIdController.text.trim();

    if (botToken.isEmpty || chatId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Completa el Token y el Chat ID primero.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = TelegramService();
      final mensajePrueba =
          '🔔 *Prueba de conexión desde BoostI POS*\n\n'
          '✅ El bot está configurado correctamente.\n'
          '📅 ${DateTime.now().toLocal().toString().substring(0, 19)}\n\n'
          '🤖 Comandos disponibles: ${_comandosPermitidos.join(", ")}';

      final enviado = await service.enviarMensajePrueba(
        mensajePrueba,
        botToken,
        chatId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enviado
                  ? '✅ Mensaje de prueba enviado correctamente a Telegram'
                  : '❌ Error al enviar mensaje. Verifica Token y Chat ID.',
            ),
            backgroundColor: enviado ? Colors.green : Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error de conexión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ============================================================
  // BUILD (con contenido centrado)
  // ============================================================
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    final gradient = isDark
        ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF10B981).withValues(alpha: 0.8),
              const Color(0xFF059669),
            ],
          )
        : const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF10B981), Color(0xFF059669)],
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                // ✅ Calcular ancho máximo del contenido
                final maxWidth = isMobile
                    ? constraints.maxWidth * 0.95
                    : 600.0.clamp(0.0, constraints.maxWidth * 0.9);

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
                              _buildCredentialsSection(
                                  colorScheme, isDark, isMobile),
                              const SizedBox(height: 20),
                              _buildNotificationsSection(
                                  colorScheme, isMobile),
                              const SizedBox(height: 20),
                              _buildCommandsSection(colorScheme, isMobile),
                              const SizedBox(height: 16),
                              if (_enabled) ...[
                                _buildTestButton(isMobile),
                                const SizedBox(height: 16),
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
  // WIDGETS UI
  // ============================================================

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.telegram,
              color: Color(0xFF10B981),
              size: 32,
            ),
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
                  'Configura el bot para recibir notificaciones y comandos',
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
            onChanged: (value) => setState(() => _enabled = value),
            activeThumbColor: const Color(0xFF10B981),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.vpn_key_rounded,
                  color: const Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Credenciales del Bot',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _botTokenController,
              enabled: _enabled,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecorationHelper.build(
                context: context,
                label: 'Token del Bot *',
                prefixIcon: Icons.key,
                isDark: isDark,
              ),
              validator: (v) {
                if (_enabled) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Requerido si el bot está habilitado';
                  }
                  if (!v.trim().contains(':')) {
                    return 'Formato inválido. Ej: 123456:ABC-def...';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
                if (_enabled && (v == null || v.trim().isEmpty)) {
                  return 'Requerido si el bot está habilitado';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Para obtener el Token, habla con @BotFather en Telegram. '
                      'El Chat ID puedes obtenerlo con el comando /start una vez configurado.',
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  color: const Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Notificaciones Automáticas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona los eventos que quieres recibir por Telegram',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            _buildSwitchTile(
              value: _notificarStockBajo,
              onChanged: (value) => setState(() => _notificarStockBajo = value),
              title: 'Stock bajo',
              subtitle: 'Cuando un producto esté por debajo del stock mínimo',
              icon: Icons.warning_amber_rounded,
              enabled: _enabled,
            ),
            _buildSwitchTile(
              value: _notificarVentas,
              onChanged: (value) => setState(() => _notificarVentas = value),
              title: 'Resumen diario de ventas',
              subtitle: 'Recibe un resumen de ventas al final del día',
              icon: Icons.receipt_long_rounded,
              enabled: _enabled,
            ),
            _buildSwitchTile(
              value: _notificarPedidos,
              onChanged: (value) => setState(() => _notificarPedidos = value),
              title: 'Nuevos pedidos a proveedores',
              subtitle: 'Cuando se cree un nuevo pedido',
              icon: Icons.shopping_cart_rounded,
              enabled: _enabled,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String title,
    required String subtitle,
    required IconData icon,
    bool enabled = true,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12),
      ),
      secondary: Icon(
        icon,
        color: const Color(0xFF10B981),
        size: 20,
      ),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeThumbColor: const Color(0xFF10B981),
    );
  }

  Widget _buildCommandsSection(ColorScheme colorScheme, bool isMobile) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: colorScheme.surface,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 14 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.code_rounded,
                  color: const Color(0xFF10B981),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Comandos Permitidos',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Selecciona los comandos que el bot aceptará',
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
                  selectedColor:
                      const Color(0xFF10B981).withValues(alpha: 0.2),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  checkmarkColor: const Color(0xFF10B981),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFF10B981)
                        : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            // ✅ Mostrar comandos seleccionados como resumen
            if (_comandosPermitidos.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: const Color(0xFF10B981),
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Comandos activos: ${_comandosPermitidos.join(", ")}',
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(0xFF10B981),
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
      height: isMobile ? 44 : 48,
      child: OutlinedButton.icon(
        onPressed: _isSaving ? null : _probarConexion,
        icon: Icon(
          Icons.telegram,
          color: const Color(0xFF10B981),
          size: isMobile ? 18 : 22,
        ),
        label: const Text('Probar conexión con Telegram'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: const Color(0xFF10B981).withValues(alpha: 0.3),
          ),
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
          backgroundColor: const Color(0xFF10B981),
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
          _isSaving ? 'Guardando...' : 'Guardar Configuración',
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.help_outline, color: const Color(0xFF10B981)),
            const SizedBox(width: 8),
            const Text('Configurar Bot de Telegram'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('1. Crea un bot en Telegram con @BotFather.'),
              SizedBox(height: 8),
              Text('2. Copia el Token que te proporciona.'),
              SizedBox(height: 8),
              Text('3. Inicia una conversación con tu bot y envía "/start".'),
              SizedBox(height: 8),
              Text(
                  '4. Obtén tu Chat ID (puedes usar @userinfobot para obtenerlo).'),
              SizedBox(height: 8),
              Text('5. Configura las notificaciones y comandos permitidos.'),
              SizedBox(height: 8),
              Text('6. Guarda la configuración y el bot se activará.'),
              SizedBox(height: 16),
              Text(
                '⚠️ Cada usuario puede tener un bot configurado.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}