// lib/features/pos/presentation/screens/telegram/telegram_config_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/presentation/providers/telegram_provider.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/responsive_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/utils/input_decoration_helper.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/telegram/telegram_service.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/sync_service.dart';

class TelegramConfigScreen extends ConsumerStatefulWidget {
  const TelegramConfigScreen({super.key});

  @override
  ConsumerState<TelegramConfigScreen> createState() => _TelegramConfigScreenState();
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
  final List<String> _comandosDisponibles = ['/ventas', '/stock', '/ayuda', '/pedidos', '/resumen'];
  
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

  Future<void> _cargarConfiguracion() async {
    setState(() => _isLoading = true);
    try {
      final config = await ref.read(telegramConfigProvider.future);
      if (config != null) {
        _botTokenController.text = config.botToken ?? '';
        _chatIdController.text = config.chatId ?? '';
        _chatNameController.text = config.nombreChat ?? '';
        _enabled = config.enabled;
        _notificarStockBajo = config.notificarStockBajo;
        _notificarVentas = config.notificarVentas;
        _notificarPedidos = config.notificarPedidos;
        _comandosPermitidos = List.from(config.comandosPermitidos);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar configuración: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _guardarConfiguracion() async {
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, corrige los campos marcados'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    final config = TelegramConfigEntity()
      ..botToken = _botTokenController.text.trim()
      ..chatId = _chatIdController.text.trim()
      ..nombreChat = _chatNameController.text.trim().isNotEmpty ? _chatNameController.text.trim() : null
      ..enabled = _enabled
      ..notificarStockBajo = _notificarStockBajo
      ..notificarVentas = _notificarVentas
      ..notificarPedidos = _notificarPedidos
      ..comandosPermitidos = _comandosPermitidos
      ..sincronizado = false;

    try {
      // 1. Guardar en Isar
      await ref.read(guardarTelegramConfigProvider(config).future);
      
      // 2. Sincronizar con Supabase
      final syncService = SyncService();
      await syncService.sincronizarTelegramConfigPendientes();
      await syncService.descargarTelegramConfigDesdeSupabase();
      
      // 3. Reiniciar el servicio de Telegram si está habilitado
      if (_enabled) {
        await TelegramService().inicializar();
      }

      // ✅ Verificar mounted ANTES de mostrar SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Configuración guardada y sincronizada correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // ✅ NO cerramos el diálogo automáticamente para que el usuario vea el mensaje
        // El usuario puede cerrar manualmente con el botón X o con el botón "Cerrar"
        setState(() => _isSaving = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al guardar: $e'), backgroundColor: Colors.red),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _probarConexion() async {
    final botToken = _botTokenController.text.trim();
    final chatId = _chatIdController.text.trim();

    if (botToken.isEmpty || chatId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa Token y Chat ID primero'), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    setState(() => _isSaving = true);

    try {
      final service = TelegramService();
      final mensajePrueba = '🔔 *Prueba de conexión desde BoostI POS*\n\n'
          '✅ El bot está configurado correctamente.\n'
          '📅 ${DateTime.now().toLocal().toString().substring(0, 19)}';

      final enviado = await service.enviarMensajePrueba(mensajePrueba, botToken, chatId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enviado 
                ? '✅ Mensaje de prueba enviado correctamente' 
                : '❌ Error al enviar mensaje. Verifica Token y Chat ID.'),
            backgroundColor: enviado ? Colors.green : Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text(
          'Configuración de Telegram',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF10B981),
                const Color(0xFF059669),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 2,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _mostrarAyuda,
            tooltip: 'Ayuda',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF10B981)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildCredentialsSection(colorScheme, isDark),
                      const SizedBox(height: 24),
                      _buildNotificationsSection(colorScheme),
                      const SizedBox(height: 24),
                      _buildCommandsSection(colorScheme),
                      const SizedBox(height: 16),
                      if (_enabled) ...[
                        _buildTestButton(),
                        const SizedBox(height: 16),
                      ],
                      _buildSaveButton(),
                      const SizedBox(height: 12),
                      // Botón para cerrar manualmente
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.telegram, color: Color(0xFF10B981), size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bot de Telegram',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(
                  'Configura el bot para recibir notificaciones y comandos',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: (value) => setState(() => _enabled = value),
            activeColor: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsSection(ColorScheme colorScheme, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.vpn_key_rounded, color: const Color(0xFF10B981), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Credenciales del Bot',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                if (_enabled && (v == null || v.trim().isEmpty)) {
                  return 'Requerido si el bot está habilitado';
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
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Para obtener el Token, habla con @BotFather en Telegram. '
                      'El Chat ID puedes obtenerlo con el comando /start una vez configurado.',
                      style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
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

  Widget _buildNotificationsSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: const Color(0xFF10B981), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Notificaciones Automáticas',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12)),
      secondary: Icon(icon, color: const Color(0xFF10B981), size: 20),
      value: value,
      onChanged: enabled ? onChanged : null,
      activeColor: const Color(0xFF10B981),
    );
  }

  Widget _buildCommandsSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.code_rounded, color: const Color(0xFF10B981), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Comandos Permitidos',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  selectedColor: const Color(0xFF10B981).withValues(alpha: 0.2),
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  checkmarkColor: const Color(0xFF10B981),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF10B981) : colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      height: 44,
      child: OutlinedButton.icon(
        onPressed: _isSaving ? null : _probarConexion,
        icon: Icon(Icons.telegram, color: const Color(0xFF10B981)),
        label: const Text('Probar conexión con Telegram'),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _guardarConfiguracion,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save_rounded),
        label: Text(
          _isSaving ? 'Guardando...' : 'Guardar Configuración',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Bot de Telegram'),
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
              Text('4. Obtén tu Chat ID (puedes usar @userinfobot para obtenerlo).'),
              SizedBox(height: 8),
              Text('5. Configura las notificaciones y comandos permitidos.'),
              SizedBox(height: 8),
              Text('6. Guarda la configuración y el bot se activará automáticamente.'),
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