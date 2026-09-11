// lib/features/pos/presentation/providers/telegram_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/telegram/telegram_service.dart';
import 'isar_provider.dart';
import 'usuario_provider.dart';

// ============================================================
// PROVIDER PARA OBTENER LA CONFIGURACIÓN DEL USUARIO ACTUAL
// ============================================================
final telegramConfigProvider = FutureProvider<TelegramConfigEntity?>((ref) async {
  final usuario = ref.watch(usuarioActualProvider);
  if (usuario == null) return null;
  
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerTelegramConfigPorUsuario(usuario.id);
});

// ============================================================
// PROVIDER PARA GUARDAR LA CONFIGURACIÓN
// ============================================================
final guardarTelegramConfigProvider = FutureProvider.family<void, TelegramConfigEntity>((ref, config) async {
  final isar = ref.watch(isarServiceProvider);
  
  // Verificar que el usuario existe (opcional)
  final usuario = await isar.obtenerUsuarioPorId(config.usuarioId);
  if (usuario == null) {
    throw Exception('Usuario no encontrado');
  }
  
  // Guardar localmente
  await isar.guardarTelegramConfig(config);
  
  // Actualizar el servicio de Telegram con la nueva configuración
  final telegramService = ref.watch(telegramServiceProvider);
  await telegramService.actualizarConfig(config);
  
  debugPrint('✅ Configuración de Telegram guardada para usuario ID: ${config.usuarioId}');
});

// ============================================================
// PROVIDER PARA ELIMINAR LA CONFIGURACIÓN
// ============================================================
final eliminarTelegramConfigProvider = FutureProvider.family<void, int>((ref, configId) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.eliminarTelegramConfig(configId);
  debugPrint('🗑️ Configuración de Telegram eliminada (ID: $configId)');
  
  // Detener el bot si estaba activo
  final telegramService = ref.watch(telegramServiceProvider);
  telegramService.dispose();
});

// ============================================================
// PROVIDER PARA EL SERVICIO DE TELEGRAM (SINGLETON)
// ============================================================
final telegramServiceProvider = Provider<TelegramService>((ref) {
  return TelegramService();
});

// ============================================================
// PROVIDER PARA VERIFICAR SI EL BOT ESTÁ ACTIVO PARA EL USUARIO ACTUAL
// ============================================================
final telegramBotActivoProvider = FutureProvider<bool>((ref) async {
  final config = await ref.watch(telegramConfigProvider.future);
  return config != null && config.enabled && config.botToken.isNotEmpty && config.chatId.isNotEmpty;
});

// ============================================================
// PROVIDER PARA INICIALIZAR EL BOT DEL USUARIO ACTUAL
// ============================================================
final inicializarTelegramBotProvider = FutureProvider<void>((ref) async {
  final usuario = ref.watch(usuarioActualProvider);
  if (usuario == null) return;
  
  final config = await ref.watch(telegramConfigProvider.future);
  if (config != null && config.enabled) {
    final telegramService = ref.watch(telegramServiceProvider);
    await telegramService.inicializar(usuarioId: usuario.id);
  }
});

// ============================================================
// PROVIDER PARA ENVIAR MENSAJE DE PRUEBA
// ============================================================
final enviarMensajePruebaTelegramProvider = FutureProvider.family<bool, ({
  String botToken,
  String chatId,
  String mensaje,
})>((ref, params) async {
  final telegramService = ref.watch(telegramServiceProvider);
  return await telegramService.enviarMensajePrueba(
    params.mensaje,
    params.botToken,
    params.chatId,
  );
});

// ============================================================
// PROVIDER PARA OBTENER TODAS LAS CONFIGURACIONES (SOLO ADMIN)
// ============================================================
final todasTelegramConfigsProvider = FutureProvider<List<TelegramConfigEntity>>((ref) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerTodasTelegramConfigs();
});

// ============================================================
// PROVIDER PARA OBTENER LA CONFIGURACIÓN DE UN USUARIO ESPECÍFICO
// ============================================================
final telegramConfigPorUsuarioProvider = FutureProvider.family<TelegramConfigEntity?, int>((ref, usuarioId) async {
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerTelegramConfigPorUsuario(usuarioId);
});