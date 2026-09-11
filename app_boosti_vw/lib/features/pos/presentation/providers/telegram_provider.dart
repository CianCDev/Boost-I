// lib/features/pos/presentation/providers/telegram_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_boosti_v2/features/pos/data/Local/entities/telegram_config_entity.dart';
import 'package:app_boosti_v2/features/pos/presentation/services/telegram/telegram_service.dart';
import 'isar_provider.dart';
import 'usuario_provider.dart'; // Necesario para obtener el usuario actual

// Provider centralizado de IsarService (debes tenerlo en isar_provider.dart)



// Provider para obtener la configuración del usuario actual
final telegramConfigProvider = FutureProvider<TelegramConfigEntity?>((ref) async {
  final usuario = ref.watch(usuarioActualProvider);
  if (usuario == null) return null;
  
  final isar = ref.watch(isarServiceProvider);
  return await isar.obtenerTelegramConfigPorUsuario(usuario.id);
});

// Provider para guardar la configuración (usando el usuario actual)
final guardarTelegramConfigProvider = FutureProvider.family<void, TelegramConfigEntity>((ref, config) async {
  final isar = ref.watch(isarServiceProvider);
  await isar.guardarTelegramConfig(config);
  
  // Actualizar el servicio de Telegram con la nueva configuración
  final telegramService = ref.watch(telegramServiceProvider);
  await telegramService.actualizarConfig(config);
});

// Provider para el servicio de Telegram (singleton)
final telegramServiceProvider = Provider<TelegramService>((ref) {
  return TelegramService();
});